import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:project_food/screens/auth_screen.dart';
import '../screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  // not used
  Future<void> authUser(BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.id, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, AuthScreen.id, (route) => false);
    }
  }

  Future<void> sendCode({required String phone}) async {
    emit(const AuthLoading());
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          emit(AuthCodeSent(
            verificationId: verificationId,
            phone: phone,
            resendToken: resendToken,
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (error) {
      emit(AuthFailure(message: "${error.message}"));
    }
  }

  Future<bool> checkExists(String docID) async {
    bool exist = false;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(docID)
          .get()
          .then((doc) {
        exist = doc.exists;
      });
      return exist;
    } catch (e) {
      // If any error
      return exist;
    }
  }

  Future<void> signIn({
    required String code,
    required String verificationId,
  }) async {
    emit(const AuthLoading());
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);
      final userCredential = await auth.signInWithCredential(credential);
      final docID = userCredential.user!.uid;

      if (!await checkExists(docID)) {
        FirebaseFirestore.instance.collection("users").doc(docID).set({
          "userID": userCredential.user!.uid,
          "userName": userCredential.user!.displayName,
          "phone": userCredential.user!.phoneNumber,
        });
      }

      emit(const AuthSignedIn());
    } on FirebaseAuthException catch (error) {
      emit(AuthFailure(message: "${error.message}"));
    }
  }

  Future<void> resendSms({
    required String savedVerificationId,
    required String phone,
    required int? savedResendToken,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: savedResendToken,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {},
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (error) {
      emit(AuthFailure(message: "${error.message}"));
    }
  }

  Future<void> signOut() async {
    await SharedPreferences.getInstance().then((pref) => pref.clear());
    await FirebaseAuth.instance.signOut();
  }
}
