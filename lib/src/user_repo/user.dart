enum CurrentMode { exploring, planning }

class UserData {
  final String id;
  final String name;

  /// Concatenated summaries of the user's chat history to feed back into the model for better completions
  final String chatHistory;

  /// When user has narrowed down career options, they can switch to planning mode.
  /// They may got back and forth between these over time.
  final CurrentMode focus = CurrentMode.exploring;

  UserData({
    required this.id,
    required this.name,
    this.chatHistory = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'chatHistory': chatHistory,
      };

  factory UserData.fromMap(Map<String, dynamic> map) => UserData(
        id: map['id'],
        name: map['name'],
        chatHistory: map['chatHistory'],
      );
}
