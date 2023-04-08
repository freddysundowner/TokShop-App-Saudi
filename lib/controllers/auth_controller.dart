import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tokshop/models/stripe_account.dart';
import 'package:tokshop/models/interests.dart';
import 'package:tokshop/screens/auth/select_interests.dart';
import 'package:tokshop/screens/auth/welcome_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tokshop/screens/checkout/payment_methods/stripe_setup.dart';
import 'package:tokshop/screens/payments/payout_settings.dart';
import 'package:tokshop/services/client.dart';
import 'package:tokshop/utils/configs.dart';
import 'package:tokshop/utils/styles.dart';

import '../models/user.dart';
import '../screens/auth/additional_userInfo.dart';
import '../screens/home/main_page.dart';
import '../services/connection_state.dart';
import '../services/user_api.dart';
import '../utils/text.dart';
import 'notifications_controller.dart';
import 'chat_controller.dart';
import 'checkout_controller.dart';
import 'wishlist_controller.dart';
import 'product_controller.dart';
import 'room_controller.dart';
import 'shop_controller.dart';
import 'user_controller.dart';
import 'wallet_controller.dart';

class AuthController extends GetxController {
  Rxn<UserModel> usermodel = Rxn<UserModel>();

  UserModel? get currentuser => usermodel.value;
  final TextEditingController emailFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  final TextEditingController fnameFieldController = TextEditingController();
  final TextEditingController lnameFieldController = TextEditingController();
  final TextEditingController usernameFieldController = TextEditingController();
  final TextEditingController confirmPasswordFieldController =
      TextEditingController();
  final TextEditingController bioFieldController = TextEditingController();
  final TokShowController _homeController = Get.put(TokShowController());
  RxList<StripeAccount> userStripeAccountData = RxList([]);
  var supportsAppleSignIn = false.obs;
  RxList<Interests> selectedItemList = RxList([]);

  var connectionstate = true.obs;
  var gettingStripeBankAccounts = false.obs;
  var deletingStripeBankAccounts = false.obs;

  var error = "".obs;
  var profileimage = "".obs;
  var isLoading = true.obs;
  var passwordVisible = false.obs;

  final Rx<File> _chosenImage = Rx(File(""));

  File get chosenImage => _chosenImage.value;

  set setChosenImage(File img) {
    _chosenImage.value = img;
  }

  var renewUpgrade = true.obs;
  var chosenInterests = [].obs;
  var googleLoading = false.obs;

  final ConnectionStateChecker _connectivity = ConnectionStateChecker.instance;

  @override
  void onInit() {
    super.onInit();
    _checkAppleAvailability();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (source.keys.toList()[0] == ConnectivityResult.mobile ||
          source.keys.toList()[0] == ConnectivityResult.wifi) {
        connectionstate.value = true;
        Get.closeAllSnackbars();
      } else {
        connectionstate.value = false;
        Get.snackbar(
          "",
          "",
          snackPosition: SnackPosition.TOP,
          borderRadius: 0,
          titleText: const Text(
            check_your_internet_connection,
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontFamily: "InterBold"),
          ),
          margin: const EdgeInsets.all(0),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(hours: 6000),
        );
      }
    });
  }

  Future loginRegisterSocial(String type) async {
    try {
      Map<String, dynamic> authData = {
        "email": emailFieldController.text,
        "firstName": fnameFieldController.text,
        "type": type,
        "profilePhoto": profileimage.value,
        "userName": usernameFieldController.text.isEmpty
            ? emailFieldController.text
            : usernameFieldController.text
      };

      Map<String, dynamic> userData =
          await UserAPI.socialAuthentication(authData);
      if (userData["success"] == false) {
        error.value = technical_error_happened;
      } else {
        UserModel userModel = await _authenticate(userData);
        if (userData["newuser"] == true) {
          await FirebaseAuth.instance.currentUser!
              .updateDisplayName(userModel.userName);
          await FirebaseAuth.instance.currentUser!
              .updateEmail(userModel.email!);
        }
        if (usermodel.value!.interests.isEmpty) {
          return Get.offAll(() => SelectInterests());
        } else {
          await callInit();
          return Get.offAll(() => MainPage());
        }
      }
    } catch (error) {
      print(error);
      Get.back();
    }
  }

  _authenticate(Map<String, dynamic> userData) async {
    userData["data"]["authtoken"] = userData["authtoken"];
    userData["data"]["accessToken"] = userData["accessToken"];

    UserModel userModel = UserModel.fromJson(userData["data"]);
    await FirebaseAuth.instance.signInWithCustomToken(userModel.authtoken!);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("access_token", userModel.accessToken!);

    //update one signal id
    var userOneSignalId = await OneSignal.shared.getDeviceState();
    await UserAPI().updateUser({"notificationToken": userOneSignalId!.userId},
        FirebaseAuth.instance.currentUser!.uid);

    usermodel.value = userModel;
    return userModel;
  }

  callInit() {
    Get.put(ShopController()).getBrands(page: "1", type: "home");
    Get.put(ProductController()).getCategories();
    Get.find<ProductController>().getAllroducts(type: "home", limit: "4");
    Get.put(TokShowController()).getActiveTokshows();
    Get.find<TokShowController>().fetchEvents();

    if (usermodel.value!.shopId != null &&
        usermodel.value!.payoutMethod == null) {
      Future.delayed(const Duration(microseconds: 5)).then((value) {
        var snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'Your products wont be visible or they wont be bought untill you setup payout settings',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      child: const Text(
                        dismiss,
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(Get.context!)
                            .removeCurrentSnackBar(
                                reason: SnackBarClosedReason.dismiss);
                      },
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(Get.context!)
                            .removeCurrentSnackBar(
                                reason: SnackBarClosedReason.dismiss);
                        Get.to(() => PayoutSettings());
                      },
                      child: const Text(
                        setup_now,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          duration: Duration(minutes: 3565),
        );
        ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
      });
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Map<String, dynamic> parseJwtPayLoad(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  Map<String, dynamic> parseJwtHeader(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[0]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';
      final userEmail = '${appleCredential.email}';
      if (appleCredential.email != null) {
        emailFieldController.text = userEmail;
      } else {
        if (appleCredential.identityToken != null) {
          emailFieldController.text =
              parseJwtPayLoad(appleCredential.identityToken!)["email"];
        }
      }

      if (appleCredential.givenName != null) {
        fnameFieldController.text = displayName;
        await loginRegisterSocial("apple");
      } else {
        var check =
            await UserAPI.getUserCheckByEmail(emailFieldController.text);
        if (check["success"] == true) {
          await loginRegisterSocial("apple");
        } else {
          Get.back();
          Get.to(() => AddAccountUserInfo());
        }
      }
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  void _checkAppleAvailability() async {
    if (Platform.isIOS) {
      supportsAppleSignIn.value = await SignInWithApple.isAvailable();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      GoogleSignInAccount? response = await _googleSignIn.signIn();
      if (response != null) {
        fnameFieldController.text = response.displayName!;
        emailFieldController.text = response.email;
        usernameFieldController.text = response.email;
        profileimage.value = response.photoUrl!;
        await loginRegisterSocial("google");
      }
    } catch (error) {
      Get.back();
    }
  }

  // Future<void> signInWithFacebook() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance
  //         .login(permissions: ["email", "public_profile"]);
  //     switch (result.status) {
  //       case LoginStatus.success:
  //         var respnse = await DbBase().databaseRequest(
  //             'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${result.accessToken!.token}',
  //             DbBase().getRequestType);
  //         var userData = jsonDecode(respnse);
  //         print("facebookCredential ${userData}");
  //
  //         fnameFieldController.text = userData["first_name"];
  //         lnameFieldController.text = userData["last_name"];
  //         emailFieldController.text = userData["email"];
  //         usernameFieldController.text = userData["name"];
  //         profileimage.value = userData["picture"]["data"]["url"];
  //         await loginRegisterSocial("faceboook");
  //         break;
  //       case LoginStatus.cancelled:
  //         print("cancelled");
  //         break;
  //       case LoginStatus.failed:
  //         print("failed");
  //         break;
  //       default:
  //         return null;
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     Get.back();
  //   }
  //
  //   // try {
  //   //   GoogleSignInAccount? response = await _googleSignIn.signIn();
  //   //   if (response != null) {
  //   //     fnameFieldController.text = response.displayName!;
  //   //     emailFieldController.text = response.email;
  //   //     usernameFieldController.text = response.email;
  //   //     profileimage.value = response.photoUrl!;
  //   //     await loginRegisterSocial("google");
  //   //   }
  //   // } catch (error) {
  //   //   Get.back();
  //   // }
  // }

  signOut() async {
    try {
      if (_homeController.currentRoom.value.id != null) {
        await _homeController.leaveRoom();
      }
      await UserAPI().updateUser(
          {"notificationToken": ""}, FirebaseAuth.instance.currentUser!.uid);

      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }
      // if (Get.find<AuthController>().usermodel.value!.logintype == "facebook") {
      //   await FacebookAuth.instance.logOut();
      // }

      FirebaseAuth.instance.signOut();
      Get.offAll(const WelcomeScreen());

      chosenInterests.value = [];

      ChatController().dispose();
      CheckOutController().dispose();
      TokShowController().dispose();
      NotificationsController().dispose();
      WishListController().dispose();
      ProductController().dispose();
      ShopController().dispose();
      UserController().dispose();
      WalletController().dispose();
    } catch (error) {
      print("error logout $error");
    }
  }

  getAccountBalances() async {
    var response = await UserAPI().getUserBalances();
    usermodel.value!.pendingWallet = response["pending"][0]["amount"] / 100;
    usermodel.value!.wallet = response["available"][0]["amount"] / 100;
    usermodel.refresh();
  }

  getConnectedStripeBanks() async {
    try {
      gettingStripeBankAccounts.value = true;
      userStripeAccountData.value = [];
      List accounts = await UserAPI.getConnectedStripeBanks();

      userStripeAccountData.value =
          accounts.map((e) => StripeAccount.fromJson(e)).toList();
      userStripeAccountData.refresh();
    } catch (e) {
    } finally {
      gettingStripeBankAccounts.value = false;
    }
  }

  deleteStripeBankAccount() async {
    deletingStripeBankAccounts.value = true;
    var response = await UserAPI.deleteStripeBankAccount();
    deletingStripeBankAccounts.value = false;
    if (response["error"] != null) {
      var errorDialog = Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 200,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.red,
                  size: 45,
                ),
                const SizedBox(height: 19.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    need_to_add_another_bank_account,
                    style: TextStyle(color: primarycolor, fontSize: 16.sp),
                  ),
                ),
                const SizedBox(height: 19.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        child: Text(
                          okay,
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => StripeSetup());
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        child: Text(
                          add_another_one,
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
      showDialog(
          context: Get.context!,
          builder: (context) {
            return errorDialog;
          });
    }
  }
}
