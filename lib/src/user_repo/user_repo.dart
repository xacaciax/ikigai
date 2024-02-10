// import 'package:shared_preferences/shared_preferences.dart';
// import 'user.dart';

// /// A local store to save and retrieve user data
// class UserRepository {
//   static final UserRepository _instance = UserRepository._internal();
//   Future<SharedPreferences> _prefsFuture;

//   UserRepository._internal() : _prefsFuture = SharedPreferences.getInstance();

//   factory UserRepository() => _instance;

//   Future<void> saveUserData(UserData userData) async {
//     final prefs = await _prefsFuture;
//     await prefs.setString('user_id', userData.id);
//     await prefs.setString('user_name', userData.name);
//     await prefs.setString('user_chat_summary', userData.chatSummary);
//   }

//   Future<UserData?> getUserData() async {
//     final prefs = await _prefsFuture;
//     final id = prefs.getString('user_id');
//     final name = prefs.getString('user_name');
//     final chatSummary = prefs.getString('user_chat_summary');

//     if (id != null && name != null && chatSummary != null) {
//       return UserData(id: id, name: name, chatSummary: chatSummary);
//     }
//     return null;
//   }

//   Future<void> updateUserData(
//       {String? id, String? name, String? email, String? chatSummary}) async {
//     final prefs = await _prefsFuture;
//     if (id != null) await prefs.setString('user_id', id);
//     if (name != null) await prefs.setString('user_name', name);
//     if (chatSummary != null) {
//       final existingSummary = prefs.getString('user_chat_summary');
//       await prefs.setString(
//           'user_chat_summary', '$existingSummary $chatSummary');
//     }
//   }

//   Future<void> clearAllUserData() async {
//     final prefs = await _prefsFuture;
//     await prefs.remove('user_id');
//     await prefs.remove('user_name');
//     await prefs.remove('user_chat_summary');
//   }
// }
