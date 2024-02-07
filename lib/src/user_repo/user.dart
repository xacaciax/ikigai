class UserData {
  final String id;
  final String name;

  /// Concatenated summaries of the user's chat history to feed back into the model for better completions
  final String chatSummary;

  UserData({required this.id, required this.name, this.chatSummary = ''});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'chatSummary': chatSummary,
      };

  factory UserData.fromMap(Map<String, dynamic> map) => UserData(
        id: map['id'],
        name: map['name'],
        chatSummary: map['chatSummary'],
      );
}
