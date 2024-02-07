import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:ikigai_advisor/src/advisor_chat/chat_widgets.dart/message_text.dart';
import 'package:intl/intl.dart'; // For formatting dates

import '../models/chat_suggestion.dart';
import '../user_repo/user_repo.dart';
import 'advisory_phases.dart';
import 'advisory_prompts.dart';
import 'chat_types/chat_message.dart';
import 'chat_widgets.dart/contact_card.dart';
import 'chat_widgets.dart/survey_question_card.dart';
import 'constants.dart';
import 'openai_api.dart';

// TODO convert vars and methods to private with underscore
// TODO add custom survey widget and control flow for survey responses

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
  List<ChatMessage> messages = [];

  /// Resets if user is not ready for career suggestions so that the AI can continue asking questions and gathering information
  int _maxInteractions = INTERACTIONS_COUNT;

  /// Will be used to track the phase of the conversation and configure system prompts
  AdvisoryPhase discussionPhase = AdvisoryPhase.introduction;

  /// Used to store chat history so that the advisor can keep "context" of past conversations
  final UserRepository _user = UserRepository();

  String summaries = '';

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
    initDiscussion();
    setState(() {
      discussionPhase = AdvisoryPhase.questions;
    });
  }

  @override
  void dispose() {
    // _openai.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void initDiscussion() {
    // final String systemLevelPrompt =
    //     advisoryPrompts[AdvisoryPhase.introduction.name] as String;
    // _openai.requestCompletion(
    //   userPrompt: 'hey there',
    //   systemPrompt: systemLevelPrompt,
    // );
    // Ensures introduction message is present immediately when user navigates to chat.

    setState(
      () => messages.add(
        ChatMessage(
            messageContent: INTRO_TEXT,
            timestamp: '',
            isMe: false,
            isJson: false),
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
        setState(() {
          messages.add(ChatMessage(
            messageContent:
                'Based on what we have discussed so far, here are some suggestions. Take a look and let me know what you think. None of these may be appealing and that is totally okay. Take note of why and then circle back here and we can discuss further :) ',
            timestamp: DateFormat('hh:mm a').format(DateTime.now()),
            isMe: false,
            isJson: false,
          ));
        });
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
              isJson: false,
              isContactCard: true,
              additionalData: option,
            ));
          });
        }
        setState(() {
          summaries += 'suggested so far: $forSummaries';
        });
      }
      // TODO handle other kinds of message types here.
      // TODO handle the edge case where Json cannot be parsed here.
    } else {
      ChatMessage message = ChatMessage(
        messageContent: completion.data,
        isMe: false,
        timestamp: DateFormat('hh:mm a').format(DateTime.now()),
        isJson: completion.isJson,
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
    setState(() {
      _maxInteractions--;
      messages.add(ChatMessage(
        messageContent: text,
        timestamp: DateFormat('hh:mm a').format(DateTime.now()),
        isMe: true,
        isJson: false,
      ));
    });
    _textController.clear();

    _postFrameScrollToBottom();
    developer.log('Interaction count is $_maxInteractions');
    if (_maxInteractions <= 0) {
      checkIn();
      _postFrameScrollToBottom();
      return;
    }

    /// Send user message to OpenAI for completion
    final context = suggestionsProvided ? summaries : '';
    await _openai.requestCompletion(
      userPrompt: text,
      systemPrompt:
          '${advisoryPrompts[discussionPhase.name] as String} here is a summary of the previous conversation $context',
    );
    // Give the ListView builder some time to build the new item
    _postFrameScrollToBottom();
  }

  void _postFrameScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  /// After some number of interactions, the advisor checks in with the user to see if they are ready for career suggestions
  /// if [SurveyResponses.yes] then the advisor will summarize the conversation so far and suggest careers based on the user's chat history
  /// if [SurveyResponses.no] or [SurveyResponses.almost] then the advisor will continue asking questions to gather more information
  void checkIn() {
    setState(() {
      messages.add(ChatMessage(
        messageContent: SURVEY_TEXT,
        timestamp: DateFormat('hh:mm a').format(DateTime.now()),
        isMe: true,
        isOptionsSurvey: true,
        isJson: false,
      ));
    });
  }

  void onSurveyResponse(String response) async {
    final String allMessages =
        messages.map((message) => message.messageContent).join(' ');

    if (response == SurveyResponses.no.name ||
        response == SurveyResponses.almost.name) {
      setState(() {
        _maxInteractions = INTERACTIONS_COUNT; // reset interaction count
      });
      // User is not ready for career suggestions, we want to make sure the current context is included in the system prompt
      // so that the conversation feels like it naturally continues.
      await saveSummary(allMessages);
      final systemPrompt =
          '${advisoryPrompts[AdvisoryPhase.questions.name] as String} and we already discussed $summaries so now let us continue the conversation.';
      _openai.requestCompletion(
        userPrompt: userNotReady,
        systemPrompt: systemPrompt,
      );
    } else {
      saveSummary(allMessages);
      suggest(allMessages);
    }
  }

  Future<void> saveSummary(String currentMessages) async {
    String? summary = await _openai.requestSummaryCompletion(
      userPrompt: systemRequestSummary,
      systemPrompt: requestSummary + currentMessages,
    );
    if (summary == null) {
      developer.log('Error: Could not summarize the conversation');
      return;
    }
    setState(
      () => summaries += summary,
    );
  }

  void suggest(String currentMessages) async {
    _openai.requestJsonCompletion(
      userPrompt: userReady,
      systemPrompt:
          '${advisoryPrompts[AdvisoryPhase.suggestions.name] as String}. We just discussed $currentMessages and in the past we discussed $summaries.',
    );
    setState(() => {
          suggestionsProvided = true,
          _maxInteractions = INTERACTIONS_COUNT,
        });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  ListTile errorTile() {
    return ListTile(
      title: Text('Uh oh, Something went wrong :\'('),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ikigai Advisor Chat'),
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
                    child: SurveyQuestionCard(
                      messageContent: msg.messageContent,
                      handleResponseCallback: onSurveyResponse,
                    ),
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
                        // Handle contact card tap
                        developer.log('Contact tapped');
                      },
                    ),
                  ),
                );
              } else {
                return ListTile(
                  horizontalTitleGap: 10,
                  leading: msg.isMe ? null : CircleAvatar(child: Text('IA')),
                  title: Align(
                    alignment:
                        msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: msg.isMe
                            ? Colors.blue.shade100
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: msg.isMe
                          ? Text(msg.messageContent)
                          // Only the last message will be animated
                          : index == messages.length - 1
                              ? CustomAnimatedText(
                                  messageContent: msg.messageContent)
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
                    alignment:
                        msg.isMe ? Alignment.bottomRight : Alignment.bottomLeft,
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
          )),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Send a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
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
          SizedBox(height: 25)
        ],
      ),
    );
  }
}
