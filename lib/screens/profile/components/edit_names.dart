import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/services/user_api.dart';

import '../../../utils/text.dart';

class EditNames extends StatelessWidget {
  EditNames({Key? key}) : super(key: key);

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    firstNameController.text = authController.usermodel.value!.firstName!;
    lastNameController.text = authController.usermodel.value!.lastName!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(edit_names),
            InkWell(
              onTap: () async {
                await UserAPI().updateUser({
                  "firstName": firstNameController.text,
                  "lastName": lastNameController.text
                }, FirebaseAuth.instance.currentUser!.uid);
                authController.usermodel.value!.firstName =
                    firstNameController.text;
                authController.usermodel.value!.lastName =
                    lastNameController.text;
                authController.usermodel.refresh();
                Get.back();
              },
              child: Text(
                done,
                style: TextStyle(color: Colors.blue),
              ),
            )
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: firstNameController,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                labelText:first_name,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              minLines: 1,
              maxLines: 5, // allow user to enter 5 line in textfield
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            TextFormField(
              controller: lastNameController,
              autocorrect: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                labelText:last_name,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              minLines: 1,
              maxLines: 5, // allow user to enter 5 line in textfield
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );
  }
}
