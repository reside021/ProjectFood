import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:project_food/bloc/auth_cubit.dart';
import 'package:project_food/screens/confirm_auth_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatefulWidget {
  static const String id = "auth_screen";

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isVisibleProgressSend = false;
  String _phone = "";
  final phoneController = TextEditingController();

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();

    setState(() {
      _isVisibleProgressSend = true;
    });

    context.read<AuthCubit>().sendCode(phone: _phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (prevState, currentState) {
          if (currentState is AuthFailure) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Error"),
                  content: Text(currentState.message),
                  actions: [
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
          if (currentState is AuthCodeSent) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ConfirmAuthScreen(
                    phone: currentState.phone,
                    verificationId: currentState.verificationId,
                    resendToken: currentState.resendToken,
                  );
                },
              ),
            ).then((_) => setState(() {
                  _isVisibleProgressSend = false;
                  // phoneController.clear();
                }));
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
                      const SizedBox(height: 50),
                      Container(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width / 1.5,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("images/image_holder.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Authorization",
                        style: GoogleFonts.ubuntu(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // номер телефона
                      IntlPhoneField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        initialCountryCode: 'RU',
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onSaved: (value) {
                          _phone = value!.completeNumber;
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
                                "Trying to send a message...",
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
                          "Send the code",
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w700,
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
