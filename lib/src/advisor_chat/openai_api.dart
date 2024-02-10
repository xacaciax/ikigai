import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ikigai_advisor/src/models/completions/request/response_format.dart';

import '../models/completions/enums/chatgpt_models.dart';
import '../models/completions/enums/roles.dart';
import '../models/completions/request/chat_completion_request.dart';
import '../models/completions/request/request_message.dart';
import '../models/completions/response/chat_completion_response.dart';
import '../models/http_header.dart';

class StreamItem {
  final bool isJson;
  final dynamic data;

  StreamItem({
    required this.isJson,
    required this.data,
  });

  factory StreamItem.fromJson(Map<String, dynamic> json) {
    return StreamItem(
      isJson: json['isJson'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isJson': isJson,
      'data': data,
    };
  }
}

class OpenAI {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] as String;
  final String apiUrl = dotenv.env['OPENAI_COMPLETIONS_URL'] as String;

  static final OpenAI _instance = OpenAI._internal();

  final _streamController = StreamController<StreamItem>.broadcast();

  OpenAI._internal();

  factory OpenAI() {
    return _instance;
  }
  Stream<StreamItem> get completionsStream => _streamController.stream;

  Future<StreamItem?> requestCompletion({
    required String userPrompt,
    required String systemPrompt,
  }) async {
    final headers = HttpHeaders(apiKey: apiKey).defaultHeaders;
    List<Request_Message> messages = [
      Request_Message(role: Role.system, content: systemPrompt),
      Request_Message(role: Role.user, content: userPrompt),
    ];
    ChatCompleteText completionRequest = ChatCompleteText(
      model: GptTurboChatModel(),
      messages: messages,
      maxToken: 150,
    );
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(completionRequest.toJson()),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = jsonDecode(response.body);
        ChatCTResponse chatCompletion = ChatCTResponse.fromJson(responseJson);
        String? result =
            chatCompletion.choices.first.message?.content ?? 'No response.';
        _streamController.add(StreamItem(isJson: false, data: result));
      } else {
        developer.log(
            'Request failed with status: ${response.statusCode}. ${response.body}');
        _streamController.addError('Error: Could not complete request.');
      }
    } catch (e) {
      developer.log('Caught exception: $e');
      _streamController.addError('Error: Exception when calling OpenAI.');
    }
  }

  Future<void> requestJsonCompletion({
    required String userPrompt,
    required String systemPrompt,
  }) async {
    final headers = HttpHeaders(apiKey: apiKey).defaultHeaders;
    List<Request_Message> messages = [
      Request_Message(role: Role.system, content: systemPrompt),
      Request_Message(role: Role.user, content: userPrompt),
    ];
    ChatCompleteText completionRequestJSON = ChatCompleteText(
      //This is the recommended model for returing JSON completions.
      model: Gpt41106PreviewChatModel(),
      responseFormat: ResponseFormat.jsonObject,
      messages: messages,
      // Enough tokens to ensure the complete JSON response is returned.
      maxToken: 400,
      // This is the recommended temperature for JSON responses as we need accuracy to be high.
      temperature: 1.0,
    );
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(completionRequestJSON.toJson()),
      );

      if (response.statusCode == 200) {
        final ChatCTResponse chatCompletion =
            ChatCTResponse.fromJson(jsonDecode(response.body));
        final Map<String, dynamic> jsonData =
            jsonDecode(chatCompletion.choices.first.message?.content ?? '{}');
        _streamController.add(StreamItem(isJson: true, data: jsonData));
      } else {
        developer.log(
            'Request failed with status: ${response.statusCode}. ${response.body}');
        _streamController.addError('Error: Could not complete request.');
      }
    } catch (e) {
      developer.log('Caught exception: $e');
      _streamController.addError('Error: Exception when calling OpenAI.');
    }
  }

  Future<String?> requestSummaryCompletion({
    required String userPrompt,
    required String systemPrompt,
  }) async {
    final headers = HttpHeaders(apiKey: apiKey).defaultHeaders;
    List<Request_Message> messages = [
      Request_Message(role: Role.system, content: systemPrompt),
      Request_Message(role: Role.user, content: userPrompt),
    ];
    ChatCompleteText completionRequest = ChatCompleteText(
      model: GptTurboChatModel(),
      messages: messages,

      /// To save on tokens and storage, we want to keep summaries to stay succinct.
      maxToken: 100,
    );
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(completionRequest.toJson()),
      );
      if (response.statusCode == 200) {
        ChatCTResponse chatCompletion =
            ChatCTResponse.fromJson(jsonDecode(response.body));
        return chatCompletion.choices.first.message?.content ?? 'No response.';
      } else {
        developer.log(
            'Request failed with status: ${response.statusCode}. ${response.body}');
        _streamController.addError('Error: Could not complete request.');
      }
    } catch (e) {
      developer.log('Caught exception: $e');
      _streamController.addError('Error: Exception when calling OpenAI.');
    }
    return null;
  }

  // TODO Optimized for streaming, finish implementation
  Future<void> requestCompletionStream({
    required String userPrompt,
    required String systemPrompt,
  }) async {
    final headers = HttpHeaders(apiKey: apiKey).defaultHeaders;
    List<Request_Message> messages = [
      Request_Message(role: Role.system, content: systemPrompt),
      Request_Message(role: Role.user, content: userPrompt),
    ];
    ChatCompleteText completionRequest = ChatCompleteText(
      model: GptTurboChatModel(),
      messages: messages,
      maxToken: 100,
      stream: true,
    );

    try {
      final request = http.Request('POST', Uri.parse(apiUrl))
        ..headers.addAll(headers)
        ..body = jsonEncode(completionRequest.toJson());

      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200) {
        final List<int> chunks = [];
        streamedResponse.stream.listen(
          (chunk) {
            chunks.addAll(chunk);
          },
          onDone: () {
            try {
              final rawData = utf8.decode(chunks);
              final dataList = rawData
                  .split('\n')
                  .where((element) => element.isNotEmpty)
                  .toList();

              final List<String> msgChunk = [];
              for (final line in dataList) {
                if (line.startsWith('data: ')) {
                  // remove 'data' prefix
                  final data = line.substring(6);
                  if (data.startsWith('[DONE]')) {
                    developer.log('stream response is done');
                    return;
                  }
                  // TODO handle NULL values :(
                  final json = jsonDecode(data);
                  String completionText =
                      json['choices'][0]['delta']['content'];
                  msgChunk.add(completionText);

                  if (completionText.contains('\n')) {
                    _streamController.add(
                        StreamItem(isJson: false, data: msgChunk.join(' ')));
                    msgChunk.clear();
                  }
                }
              }
            } catch (e) {
              developer.log('Error parsing accumulated JSON: $e');
            }
          },
          onError: (e) {
            developer.log('Stream error: $e');
          },
        );
      } else {
        developer
            .log('Request failed with status: ${streamedResponse.statusCode}.');
        _streamController.addError('Error: Could not complete request.');
      }
    } catch (e) {
      developer.log('Caught exception: $e');
      _streamController.addError('Error: Exception when calling OpenAI.');
    }
  }

  void dispose() {
    _streamController.close();
  }
}
