import 'package:cloud_firestore/cloud_firestore.dart';

class RequestHelpModel {
  final String id;
  final Timestamp timeCreate;
  final String theme;

  RequestHelpModel({
    required this.id,
    required this.timeCreate,
    required this.theme,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timeCreate': timeCreate,
      'theme': theme,
    };
  }
}
