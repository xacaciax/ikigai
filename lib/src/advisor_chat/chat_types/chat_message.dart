// TODO break these out into separate models?
class ChatMessage {
  String messageContent;
  String timestamp;
  bool isMe;
  bool isJson;
  bool isContactCard;
  bool isOptionsSurvey;
  bool isListOptions;

  /// This is to be use to attach data for the custom message types like ContactCard, OptionsSurvey, etc.
  dynamic additionalData; // List<Suggestion>, etc.

  ChatMessage({
    required this.messageContent,
    required this.timestamp,
    required this.isMe,
    required this.isJson,
    this.isOptionsSurvey = false,
    this.isContactCard = false,
    this.isListOptions = false,
    this.additionalData = const {},
  });
}
