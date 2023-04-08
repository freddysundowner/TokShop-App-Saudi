import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/screens/profile/components/edit_bio.dart';
import 'package:tokshop/screens/profile/components/edit_username.dart';
import 'package:tokshop/screens/profile/components/edit_names.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../services/firestore_files_access_service.dart';
import '../../services/local_files_access_service.dart';
import '../../services/user_api.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

class EditProfile extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController firstNameController = TextEditingController();
  UserModel profile;
  EditProfile({Key? key, required this.profile}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: primarycolor, //change your color here
        ),
        title: const Text(edit_profile),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: Obx(() => Column(
                  children: [
                    SizedBox(height: 40.h),
                    GestureDetector(
                      child: buildDisplayPictureAvatar(context),
                      onTap: () {
                        getImageFromUser(context);
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => EditNames());
                      },
                      child: Row(
                        children: [
                          Text(
                            name,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Obx(
                            () => Text(
                              "${authController.usermodel.value!.firstName!} ${authController.usermodel.value!.lastName!}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12.sp),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => EditUsername());
                      },
                      child: Row(
                        children: [
                          Text(
                            username,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Obx(
                            () => Text(
                              "@${authController.usermodel.value!.userName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12.sp),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => EditBio());
                      },
                      child: Row(
                        children: [
                          Text(
                            bio,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Obx(
                            () => Text(
                              authController.usermodel.value!.bio!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12.sp),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    SizedBox(height: 80.h),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget buildDisplayPictureAvatar(BuildContext context) {
    ImageProvider? backImage;
    if (authController.chosenImage.path.isNotEmpty) {
      backImage = MemoryImage(authController.chosenImage.readAsBytesSync());
    } else if (authController.currentuser!.profilePhoto != "") {
      final String? url = authController.currentuser!.profilePhoto;
      if (url != null) backImage = NetworkImage(url);
    }
    return backImage == null
        ? Image.asset("assets/icons/profile_placeholder.png",
            width: 0.35.sw, height: 0.16.sh)
        : CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            backgroundImage: backImage,
          );
  }

  void getImageFromUser(BuildContext context) async {
    try {
      String path;
      String snackbarMessage = image_picked;
      path = await choseImageFromLocalFiles(context,
          aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 2));
      authController.setChosenImage = File(path);
      uploadImageToFirestorage(context);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            snackbarMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: kPrimaryColor,
        ),
      );
    } finally {}
    // bodyState.setChosenImage = File(path);
  }

  Future<void> uploadImageToFirestorage(BuildContext context) async {
    bool uploadDisplayPictureStatus = false;
    String snackbarMessage = "";
    try {
      final downloadUrl = await FirestoreFilesAccess().uploadFileToPath(
          authController.chosenImage,
          UserAPI().getPathForCurrentUserDisplayPicture());

      uploadDisplayPictureStatus =
          await UserAPI.uploadDisplayPictureForCurrentUser(downloadUrl);
      if (uploadDisplayPictureStatus == true) {
        authController.currentuser!.profilePhoto = downloadUrl;
        authController.usermodel.value!.profilePhoto = downloadUrl;
        authController.usermodel.refresh();
        _userController.currentProfile.value.profilePhoto = downloadUrl;
        _userController.currentProfile.refresh();
        snackbarMessage = display_picture_updated;
      } else {
        throw "Coulnd't update display picture due to unknown reason";
      }
    } on FirebaseException catch (e) {
      snackbarMessage = "$something_went_wrong ${e.toString()}";
    } catch (e) {
      snackbarMessage = "$something_went_wrong ${e.toString()}";
    } finally {
      authController.usermodel.value = await UserAPI.getUserById();
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            snackbarMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: kPrimaryColor,
        ),
      );
    }
  }
}
