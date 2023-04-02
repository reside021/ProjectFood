import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String userID;
  final String message;
  final Timestamp timestamp;

  ChatModel({
    required this.userID,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'message': message,
      'timestamp': timestamp,
    };
  }

}
