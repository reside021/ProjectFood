import 'package:cloud_firestore/cloud_firestore.dart';

class SupportModel {
  final String id;
  final Timestamp timeCreate;
  final String theme;
  final String idUser;
  final bool isOpen;

  SupportModel({
    required this.id,
    required this.timeCreate,
    required this.theme,
    required this.idUser,
    required this.isOpen
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timeCreate': timeCreate,
      'theme': theme,
      'idUser': idUser,
      'isOpen': isOpen
    };
  }
}
