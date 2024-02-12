import 'dart:developer' as developer;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:ikigai_advisor/src/advisor_chat/survey_types.dart';
import 'package:intl/intl.dart'; // For formatting dates

import '../models/chat_suggestion.dart';
// import '../user_repo/user_repo.dart';
import 'advisory_phases.dart';
import 'advisory_prompts.dart';
import 'chat_types/chat_message.dart';
import 'chat_widgets/checklist_select_survey.dart';
import 'chat_widgets/contact_card.dart';
import 'chat_widgets/three_option_survey.dart';
import 'constants.dart';
import 'openai_api.dart';
import '../models/chat_interest_area.dart';

// TODO convert vars and methods to private with underscore

class ChatView extends StatefulWidget {
  static const routeName = '/chat';
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _textController = TextEditingController();

  /// ScrollController to scroll to the bottom of the list view when new messages are added
  final ScrollController _scrollController = ScrollController();
  final _openai = OpenAI();

  /// All messages in chat thread, consumed by ListView.builder
  List<ChatMessage> messages = [];

  /// Collects survey results while in [AdvisorPhase.surveys]
  List<String> _surveyResults = [];

  /// Resets if user is not ready for career suggestions so that the AI can continue asking questions and gathering information
  int _maxInteractions = INTERACTIONS_COUNT;

  /// Will be used to track the phase of the conversation and configure system prompts
  AdvisoryPhase discussionPhase = AdvisoryPhase.introduction;

  /// Used to store chat history so that the advisor can keep "context" of past conversations
  // final UserRepository _user = UserRepository();

  /// Periodically check the length of this and compress to be less than 2048 tokens
  String summaries = '';

  /// When [AdvisoryPhase.surveys] is reached, this count determines which survey to generate and display
  int _surveyCount = 3;

  /// Determines whether or not to display suggestions intro message
  bool suggestionsProvided = false;

  @override
  void initState() {
    super.initState();
    _openai.completionsStream.listen((completion) {
      handleIncomingMessages(completion);
      _postFrameScrollToBottom();
    }, onError: (error) {
      developer.log(error);
    });
    initAdvisorySession();
    setState(() {
      discussionPhase = AdvisoryPhase.questions;
    });
  }

  @override
  void dispose() {
    _openai.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void initAdvisorySession() {
    // Manually poplulate introduction the advisor here instead of using the ChatGPT, ensures intro is immediately available
    setState(
      () => messages.add(
        ChatMessage(
          messageContent: INTRO_TEXT,
          timestamp: '',
          isMe: false,
        ),
      ),
    );
  }

  /// Incoming messages can be JSON or String, depending on how the request was made.
  void handleIncomingMessages(StreamItem completion) {
    if (completion.isJson == true) {
      final json = completion.data;

      // It may be possible this data will not arrive in the shape we expect. There is a way via the openai function_calls
      // to ensure the data here is exactly as we expect. Stretch goal: implement function_calls.
      if (json['generated_suggestions'] != null) {
        if (!suggestionsProvided) {
          setState(() {
            messages.add(ChatMessage(
              messageContent: SUGGESTIONS_INTRO,
              timestamp: DateFormat('hh:mm a').format(DateTime.now()),
              isMe: false,
            ));
          });
        }
        String forSummaries = '';
        final options = json['generated_suggestions'] as List;
        for (var e in options) {
          final option = Suggestion.fromJson(e);
          forSummaries += option.careerTitle;
          setState(() {
            messages.add(ChatMessage(
              messageContent: '',
              timestamp: DateFormat('hh:mm a').format(DateTime.now()),
              isMe: false,
              isContactCard: true,
              additionalData: option,
            ));
          });
        }
        setState(() {
          summaries += ' Suggested so far: $forSummaries';
        });

        // TODO handle other kinds of message types here.
        // TODO handle the edge case where Json cannot be parsed here.
      } else if (json['generated_lists'] != null) {
        final survey = json['generated_lists'] as List;

        List<InterestArea> areasOfInterest = survey
            .map<InterestArea>((json) => InterestArea.fromJson(json))
            .toList();

        setState(() {
          messages.add(ChatMessage(
            messageContent: '',
            timestamp: DateFormat('hh:mm a').format(DateTime.now()),
            isMe: false,
            isListOptions: true,
            additionalData: areasOfInterest, // List<InterestArea>
          ));
        });
      }
    } else {
      ChatMessage message = ChatMessage(
        messageContent: completion.data,
        isMe: false,
        timestamp: DateFormat('hh:mm a').format(DateTime.now()),
      );
      setState(() {
        messages.add(message);
      });
    }
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;
    print('maxInteractions: $_maxInteractions');
    print('Discussion phase: $discussionPhase');
    print('Current summaries: $summaries');
    print('Suggestions provided: $suggestionsProvided');

    setState(() {
      _maxInteractions--;
      messages.add(ChatMessage(
        messageContent: text,
        timestamp: DateFormat('hh:mm a').format(DateTime.now()),
        isMe: true,
      ));
    });
    _textController.clear();
    _postFrameScrollToBottom();

    if (_maxInteractions <= 0) {
      checkIn();
      _postFrameScrollToBottom();
      return;
    }

    /// Sometimes the advisor asks a question, the user responds but then the advisor's next response lacks context
    final lastAdvisorResponse = messages.last.messageContent;
    final context = suggestionsProvided ? summaries : '';
    await _openai.requestCompletion(
      userPrompt: text,
      systemPrompt:
          '${advisoryPrompts[discussionPhase.name] as String} here is the last response you gave me $lastAdvisorResponse and a summary of the previous conversations $context',
    );
    _postFrameScrollToBottom(ANIMATED_TEXT_OFFSET);
  }

  /// After some number of interactions, the advisor checks in with the user to see if they are ready for career suggestions
  /// if [ThreeOptions.yes] then the advisor will summarize the conversation so far and suggest careers based on the user's chat history
  /// if [ThreeOptions.no] or [ThreeOptions.almost] then the advisor will continue asking questions to gather more information
  void checkIn() {
    setState(() {
      messages.add(ChatMessage(
        messageContent: suggestionsProvided
            ? 'Are you ready for some more career suggestions?'
            : SURVEY_TEXT,
        timestamp: DateFormat('hh:mm a').format(DateTime.now()),
        isMe: true,
        isOptionsSurvey: true,
      ));
    });
  }

  /// Orchestrates the survey phase of the conversation, based on [_surveyCount] displays 1 of 3 dynamic surveys and
  /// saves results to [_surveyResults] for future use as additional context to be added to [summaries]
  void surveyHandler(List<String> selectedOptions) {
    if (_surveyCount > 0) {
      switch (_surveyCount) {
        case 3:
          setState(() {
            messages.add(ChatMessage(
              messageContent:
                  'Let\'s use some sureveys to get a better sense of your interests, values, and strengths. Your responses will help me make better career suggestions.',
              timestamp: DateFormat('hh:mm a').format(DateTime.now()),
              isMe: false,
            ));
          });
          _postFrameScrollToBottom(ANIMATED_TEXT_OFFSET);
          getSurvey(summaries, SurveyType.interests);
          break;
        case 2:
          getSurvey(summaries, SurveyType.strengths);
          break;
        case 1:
          getSurvey(summaries, SurveyType.careerValues);
          break;
        default:
          getSurvey(summaries, SurveyType.interests);
      }
      final String surveyResult = selectedOptions.map((s) => s).join(' ');
      setState(() {
        _surveyCount--;
        _surveyResults.add(surveyResult);
      });

      /// All surveys have been completed
    } else if (_surveyCount == 0) {
      final String surveyResults = _surveyResults.map((r) => r).join(' ');
      setState(() {
        _surveyCount = 3;
        discussionPhase = AdvisoryPhase.questions;
      });

      /// Use survey results to pick up with exploring via questions again
      _openai.requestCompletion(
        userPrompt: 'Here are the results of the surveys $surveyResults.',
        systemPrompt:
            '${advisoryPrompts[discussionPhase.name] as String} summary of the previous conversations $summaries for context and the results of surveys $surveyResults.',
      );
      _postFrameScrollToBottom(ANIMATED_TEXT_OFFSET);

      /// Add survey results to summaries to keep for future context
      saveSummary(surveyResults);
    }
  }

  /// Displays a check-in to see if the user is ready for career suggestions
  /// If user selects [ThreeOptions.yes] then the advisor will summarize the conversation so far
  /// and suggest careers based on the user's chat history
  /// If user selects [ThreeOptions.no] then the advisor switch to [AdvisoryPhase.surveys] and generate as series of surveys to gather information
  /// If user selects [ThreeOptions.almost] then the advisor will continue asking questions to gather more information
  void onThreeOptionSelect(String response) async {
    final String allMessages =
        messages.map((message) => message.messageContent).join(' ');

    if (response == ThreeOptions.almost.name) {
      /// Capture and "compress" the summary of the conversation so far before inluding it in the next system prompt.
      /// This will have the effect of the advisor retaining context while minimizing token usage while allowing the LLM
      /// to "zoom in" on any topic covered so far instead of staying on most recent topic. Ideally this has the effect of
      /// the advisory asking a broader range of questions instead of getting too deep into into one topic.
      ///
      /// To change the behavior of the advisor so that it stays more exactly on topic instead of "zooming out" to ask a broad question
      /// pass [allMessages] to the system prompt instead of [summaries].
      await saveSummary(allMessages);
      final systemPrompt =
          '${advisoryPrompts[AdvisoryPhase.questions.name] as String} and we already discussed $summaries so now let us discuss the results.';
      _openai.requestCompletion(
        userPrompt: userNotReady,
        systemPrompt: systemPrompt,
      );
    } else if (response == ThreeOptions.no.name) {
      setState(() {
        discussionPhase = AdvisoryPhase.surveys;
      });
      surveyHandler([allMessages]);
    } else {
      suggest(allMessages);
    }

    /// Always "compress" summaries to ensure they are less than 2048 tokens and can be included in future
    /// system prompts. This will allow the advisor to retain context of past conversations and ask more informed questions.
    saveSummary(allMessages);

    /// Reset the interaction count so that the advisor can continue asking questions and gathering information after survey or suggest phase
    setState(() {
      _maxInteractions = INTERACTIONS_COUNT;
    });
  }

  /// Uses [currentMessages] and [summaries] to generate a summary of the conversation so far,
  /// having the effect of compressing the chat history
  Future<void> saveSummary(String currentMessages) async {
    String? summary = await _openai.requestSummaryCompletion(
      userPrompt: systemRequestSummary,
      systemPrompt:
          '${requestSummary}Current conversation:$currentMessages. Current summaries:$summaries.',
    );
    if (summary == null) {
      developer.log('Error: Could not summarize the conversation');
      return;
    }
    setState(
      () => summaries = summary,
    );
  }

  /// Gets career suggestions which will then be displayed as contact cards in the chat thread
  void suggest(String currentMessages) async {
    _openai.requestJsonCompletion(
      userPrompt: userReady,
      systemPrompt:
          '${advisoryPrompts[AdvisoryPhase.suggestions.name] as String}. We just discussed $currentMessages and in the past we discussed $summaries.',
    );
    setState(
      () => suggestionsProvided = true,
    );
  }

  /// Gets Json for survey [SurveyType] using [currentContext] of conversation
  void getSurvey(String currentContext, SurveyType type) async {
    final String surveyPrompt = surveyPrompts[type.name] as String;
    _openai.requestJsonCompletion(
      userPrompt: 'Here is a summary of our discussion $currentContext.',
      systemPrompt: surveyPrompt,
    );
  }

  void _postFrameScrollToBottom([int? offset]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;
        final position = offset == null ? max : max + offset;
        _scrollController.animateTo(
          position,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  ListTile errorTile() {
    return ListTile(
      title: Text('Uh oh, Something went wrong :\'('),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Ikigai Advisor Chat',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                restorationId: 'chat_list_view',
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final ChatMessage msg = messages[index];

                  if (msg.isOptionsSurvey) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0, left: 10),
                        child: ThreeOptionsCard(
                          messageContent: msg.messageContent,
                          handleResponseCallback: onThreeOptionSelect,
                        ),
                      ),
                    );
                  } else if (msg.isListOptions) {
                    return Center(
                      child: ChecklistSelectSurvey(
                        surveyOptions: msg.additionalData,
                        onSurveyOptionsSelected: surveyHandler,
                      ),
                    );
                  } else if (msg.isContactCard) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0, left: 10),
                        child: ContactCardButton(
                          contactName: msg.additionalData?.name ?? 'mock name',
                          contactProfession: msg.additionalData?.careerTitle ??
                              'mock career title',
                          onTap: () {
                            developer.log('Contact tapped');
                          },
                        ),
                      ),
                    );
                  } else {
                    return ListTile(
                      horizontalTitleGap: 10,
                      leading:
                          msg.isMe ? null : CircleAvatar(child: Text('IA')),
                      title: Align(
                        alignment: msg.isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: msg.isMe
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: msg.isMe
                              ? Text(msg.messageContent)
                              // Only the last message will be animated
                              // TODO do not re-animate on re-render
                              : index == messages.length - 1
                                  ? AnimatedTextKit(
                                      onFinished: _postFrameScrollToBottom,
                                      isRepeatingAnimation: false,
                                      totalRepeatCount: 0,
                                      animatedTexts: [
                                        TyperAnimatedText(
                                          msg.messageContent,
                                          speed:
                                              const Duration(milliseconds: 30),
                                        ),
                                      ],
                                    )
                                  : Text(msg.messageContent),
                        ),
                      ),
                      trailing: msg.isMe
                          ? CircleAvatar(
                              backgroundColor: Colors.tealAccent.shade200,
                              child: Text('ME'),
                            )
                          : null,
                      subtitle: Align(
                        alignment: msg.isMe
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        child: Padding(
                          padding: msg.isMe
                              ? EdgeInsets.only(right: 10)
                              : EdgeInsets.only(left: 10),
                          child: Text(
                            msg.timestamp,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: null,
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Send a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade900,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () => sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5)
          ],
        ),
      ),
    );
  }
}
