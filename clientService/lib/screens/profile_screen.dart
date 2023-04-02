import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_food/screens/order_history.dart';
import 'package:project_food/screens/text_support_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_food/bloc/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/window_error.dart';
import '../widgets/window_loading.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = "profile_screen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController userNameController;
  late TextEditingController phoneController;

  String newUserName = "";
  String newPhone = "";

  final _formKey = GlobalKey();

  @override
  void initState() {
    userNameController = TextEditingController();
    phoneController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    userNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  final Stream<DocumentSnapshot<Map<String, dynamic>>> _usersStream =
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();

  void _updateInfo() {
    FocusManager.instance.primaryFocus?.unfocus();
    final userRef = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    userRef.update({"userName": userNameController.text}).then(
        (value) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              duration: Duration(seconds: 2),
              content: Text("Profile successfully updated!"),
            )),
        onError: (e) => print("Error updating document $e"));
  }

  Widget windowProfile() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFe41f26),
        title: Text(
          "Profile",
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthCubit>().signOut();
              Navigator.pushNamedAndRemoveUntil(
                      context, AuthScreen.id, (route) => false);
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height * 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 15.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Name",
                              style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          TextFormField(
                            controller: userNameController,
                            style:
                                GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                            textAlignVertical: TextAlignVertical.center,
                            onFieldSubmitted: (_) {
                              _updateInfo();
                            },
                            onChanged: (value) {
                              newUserName = value;
                            },
                            onTapOutside: (value) {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                            decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.edit)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                "Phone",
                                style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: phoneController,
                            style:
                                GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: true,
                            decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            )),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () => _updateInfo(),
                            style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                Colors.white,
                              ),
                              foregroundColor: MaterialStatePropertyAll(
                                Color(0xFFe41f26),
                              ),
                              fixedSize: MaterialStatePropertyAll(
                                Size(200, 50),
                              ),
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  side: BorderSide(
                                    color: Color(0xFFe41f26),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              "Save",
                              style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(OrderHistory.id);
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Color(0xFFe41f26),
                  ),
                  fixedSize: MaterialStatePropertyAll(
                    Size(270, 50),
                  ),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                child: Text(
                  "Order history",
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Text(
                          "If you have any problems or other questions, please let us know",
                          textAlign: TextAlign.center,
                          style:
                              GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(TextSupportScreen.id);
                          },
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              Color(0xFFe41f26),
                            ),
                            fixedSize: MaterialStatePropertyAll(
                              Size(270, 50),
                            ),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            "Write",
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            const url = "tel://+79118125505";
                            await canLaunchUrl(Uri.parse(url))
                                ? await launchUrl(Uri.parse(url))
                                : throw 'Could not launch $url';
                          },
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                              Color(0xFFe41f26),
                            ),
                            fixedSize: MaterialStatePropertyAll(
                              Size(270, 50),
                            ),
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            "Call",
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const WindowError();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const WindowLoading();
          }

          final data = snapshot.data?.data() as Map<String, dynamic>;

          if (newUserName.isEmpty) {
            userNameController.text = data["userName"] ?? "";
          } else {
            userNameController.text = newUserName;
          }
          userNameController.selection =
              TextSelection.collapsed(offset: userNameController.text.length);
          if (newPhone.isEmpty) {
            phoneController.text = data["phone"];
          } else {
            phoneController.text = newPhone;
          }
          phoneController.selection =
              TextSelection.collapsed(offset: phoneController.text.length);

          return windowProfile();
        });
  }
}
