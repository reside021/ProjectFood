import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_food/bloc/auth_cubit.dart';
import 'package:project_food/screens/main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmAuthScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  final int? resendToken;

  const ConfirmAuthScreen({
    Key? key,
    required this.phone,
    required this.verificationId,
    required this.resendToken,
  }) : super(key: key);

  @override
  State<ConfirmAuthScreen> createState() => _ConfirmAuthScreenState();
}

class _ConfirmAuthScreenState extends State<ConfirmAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _code = "";
  bool _isVisibleProgressSend = false;

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      // invalid
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isVisibleProgressSend = true;
    });

    context.read<AuthCubit>().signIn(
          code: _code,
          verificationId: widget.verificationId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (prevState, currentState) {
          if (currentState is AuthSignedIn) {
            Navigator.pushNamedAndRemoveUntil(
                context, MainScreen.id, (route) => false);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "Code confirmation",
                        style: GoogleFonts.ubuntu(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        maxLength: 6,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2.0),
                          ),
                          hintText: "Code from SMS",
                          hintStyle: GoogleFonts.ubuntu(fontSize: 18),
                        ),
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.ubuntu(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                        validator: (value) {
                          if (value!.length < 6) {
                            return 'The code consists of 6 characters!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _code = value!.trim();
                        },
                      ),
                      Visibility(
                        visible: _isVisibleProgressSend,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Color(0xFFe41f26),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Authorization, please wait...",
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          _submit(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFe41f26),
                          foregroundColor: const Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(235, 55),
                        ),
                        child: Text(
                          "Confirm",
                          style: GoogleFonts.ubuntu(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't get the code?",
                            style: GoogleFonts.ubuntu(
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<AuthCubit>().resendSms(
                                savedVerificationId: widget.verificationId,
                                phone: widget.phone,
                                savedResendToken: widget.resendToken,
                              );
                            },
                            child: Text(
                              "Send again",
                              style: GoogleFonts.ubuntu(
                                fontSize: 15,
                                color: const Color(0xFFe41f26),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Change the number",
                          style: GoogleFonts.ubuntu(
                            fontSize: 15,
                            color: const Color(0xFFe41f26),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
