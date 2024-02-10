///model name
const kGpt3TurboInstruct = 'gpt-3.5-turbo-instruct';

///chat complete 3.5 and gpt-4
const kChatGptTurboModel = 'gpt-3.5-turbo'; // gpt 3.5
const kChatGptTurbo0301Model = 'gpt-3.5-turbo-0301';
const kChatGpt4 = 'gpt-4';
const kChatGpt40314 = 'gpt-4-0314';
const kChatGpt432k = 'gpt-4-32k';
const kChatGpt432k0314 = 'gpt-4-32k-0314';
const kChatGptTurbo0613 = 'gpt-3.5-turbo-0613';
const kChatGptTurbo1106 = 'gpt-3.5-turbo-1106';
const kChatGptTurbo16k0613 = 'gpt-3.5-turbo-16k-0613';
const kChatGpt40631 = 'gpt-4-0613';
const kGpt41106Preview = 'gpt-4-1106-preview';
const kGpt4VisionPreview = 'gpt-4-vision-preview';

sealed class ChatModel {
  String model;
  ChatModel({required this.model});
}

class GptTurboChatModel extends ChatModel {
  GptTurboChatModel() : super(model: kChatGptTurboModel);
}

class GptTurbo0301ChatModel extends ChatModel {
  GptTurbo0301ChatModel() : super(model: kChatGptTurbo0301Model);
}

class ChatModelFromValue extends ChatModel {
  ChatModelFromValue({required super.model});
}

class Gpt4ChatModel extends ChatModel {
  Gpt4ChatModel() : super(model: kChatGpt4);
}

class Gpt40314ChatModel extends ChatModel {
  Gpt40314ChatModel() : super(model: kChatGpt40314);
}

class Gpt432kChatModel extends ChatModel {
  Gpt432kChatModel() : super(model: kChatGpt432k);
}

class Gpt432k0314ChatModel extends ChatModel {
  Gpt432k0314ChatModel() : super(model: kChatGpt432k0314);
}

class GptTurbo0631Model extends ChatModel {
  GptTurbo0631Model() : super(model: kChatGptTurbo0613);
}

class GptTurbo1106Model extends ChatModel {
  GptTurbo1106Model() : super(model: kChatGptTurbo1106);
}

class GptTurbo16k0631Model extends ChatModel {
  GptTurbo16k0631Model() : super(model: kChatGptTurbo16k0613);
}

class Gpt40631ChatModel extends ChatModel {
  Gpt40631ChatModel() : super(model: kChatGpt40631);
}

class Gpt4VisionPreviewChatModel extends ChatModel {
  Gpt4VisionPreviewChatModel() : super(model: kGpt4VisionPreview);
}

class Gpt41106PreviewChatModel extends ChatModel {
  Gpt41106PreviewChatModel() : super(model: kGpt41106Preview);
}
