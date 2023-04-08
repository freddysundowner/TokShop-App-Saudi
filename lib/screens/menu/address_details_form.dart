import 'dart:convert';

import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/screens/home/create_room.dart';

import '../../controllers/checkout_controller.dart';
import '../../models/address.dart';
import '../../services/user_api.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

//ignore: must_be_immutable
class AddressDetailsForm extends StatelessWidget {
  Address? addressToEdit;
  bool? showsave = true;

  AddressDetailsForm({this.addressToEdit, this.showsave, Key? key})
      : super(key: key);

  CheckOutController checkOutController = Get.find<CheckOutController>();

  @override
  Widget build(BuildContext context) {
    if (addressToEdit != null) {
      checkOutController.addressReceiverFieldController.text =
          addressToEdit!.name;
      checkOutController.addressLine1FieldController.text =
          addressToEdit!.addrress1;
      checkOutController.addressLine2FieldController.text =
          addressToEdit!.addrress2;
      checkOutController.phoneFieldController.text = addressToEdit!.phone;
      checkOutController.countryFieldController.text = addressToEdit!.country;
      checkOutController.stateFieldController.text = addressToEdit!.state;
      checkOutController.cityFieldController.text = addressToEdit!.city;
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(ship_address),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: checkOutController.formKey,
          child: ListView(
            children: [
              SizedBox(height: 5.h),
              buildReceiverField(),
              SizedBox(height: 5.h),
              buildAddressLine1Field(),
              SizedBox(height: 5.h),
              buildAddressLine2Field(),
              SizedBox(height: 5.h),
              buildPhoneField(),
              SizedBox(height: 5.h),
              CSCPicker(
                showStates: true,
                showCities: true,
                flagState: CountryFlag.DISABLE,
                dropdownDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: primarycolor, width: 1)),
                disabledDropdownDecoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.transparent,
                    border: Border.all(color: primarycolor, width: 1)),
                countrySearchPlaceholder: "$country",
                currentCountry: checkOutController.countryFieldController.text,
                currentState: checkOutController.stateFieldController.text,
                currentCity: checkOutController.cityFieldController.text,
                stateSearchPlaceholder: "$state",
                citySearchPlaceholder: "$city",
                countryDropdownLabel: "*$country",
                stateDropdownLabel: "*$state",
                cityDropdownLabel: "*$city",
                selectedItemStyle: TextStyle(
                  color: primarycolor,
                  fontSize: 14.sp,
                ),
                dropdownHeadingStyle: TextStyle(
                    color: primarycolor,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold),
                dropdownItemStyle: TextStyle(
                  color: primarycolor,
                  fontSize: 14.sp,
                ),
                dropdownDialogRadius: 10.0,
                searchBarRadius: 10.0,
                onCountryChanged: (value) {
                  checkOutController.countryFieldController.text = value;
                },
                onStateChanged: (value) {
                  if (value != null) {
                    checkOutController.stateFieldController.text = value;
                  }
                },
                onCityChanged: (value) {
                  if (value != null) {
                    checkOutController.cityFieldController.text = value;
                  }
                },
              ),
              SizedBox(height: 5.h),
              if (showsave == true)
                DefaultButton(
                  text: addressToEdit == null ? save : update,
                  press: addressToEdit == null
                      ? () => saveNewAddressButtonCallback(context)
                      : () => saveEditedAddressButtonCallback(context),
                ),
            ],
          ),
        ),
      ),
    );

    //return form;
  }

  Widget buildReceiverField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 3.0,
        ),
        Text(
          full_name,
          style: TextStyle(color: primarycolor, fontSize: 14.sp),
        ),
        const SizedBox(
          height: 3.0,
        ),
        TextFormField(
          controller: checkOutController.addressReceiverFieldController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            filled: true,
            hintStyle:
                const TextStyle(color: Styles.neutralGrey3, fontSize: 14),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(4.0)),
          ),
          validator: (value) {
            if (checkOutController
                .addressReceiverFieldController.text.isEmpty) {
              return names_are_required;
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Widget buildAddressLine1Field() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 3.0,
        ),
        Text(
          address_one,
          style: TextStyle(color: primarycolor, fontSize: 14.sp),
        ),
        const SizedBox(
          height: 3.0,
        ),
        TextFormField(
          controller: checkOutController.addressLine1FieldController,
          keyboardType: TextInputType.streetAddress,
          decoration: InputDecoration(
            hintStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Styles.dullGreyColor),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
                borderSide: const BorderSide(color: Styles.hintColor),
                borderRadius: BorderRadius.circular(4.0)),
          ),
          validator: (value) {
            if (checkOutController.addressLine1FieldController.text.isEmpty) {
              return address_is_required;
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Widget buildAddressLine2Field() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 3.0,
        ),
        Text(
          address_two,
          style: TextStyle(color: primarycolor, fontSize: 14.sp),
        ),
        const SizedBox(
          height: 3.0,
        ),
        TextFormField(
          controller: checkOutController.addressLine2FieldController,
          keyboardType: TextInputType.streetAddress,
          decoration: InputDecoration(
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(4.0)),
          ),
        ),
      ],
    );
  }

  Widget buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 3.0,
        ),
        Text(
          phone_number,
          style: TextStyle(color: primarycolor, fontSize: 14.sp),
        ),
        const SizedBox(
          height: 3.0,
        ),
        TextFormField(
          controller: checkOutController.phoneFieldController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(4.0)),
          ),
          validator: (value) {
            if (checkOutController.phoneFieldController.text.isEmpty) {
              return phone_number_is_required;
            } else if (checkOutController.phoneFieldController.text.length !=
                10) {
              return only_10_digits;
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Future<void> saveNewAddressButtonCallback(BuildContext context) async {
    if (checkOutController.formKey.currentState!.validate()) {
      final Address newAddress = generateAddressObject();
      dynamic response;
      String snackbarMessage = saved_successfully;
      try {
        response = UserAPI.addAddressForCurrentUser(newAddress);
        await showDialog(
          context: context,
          builder: (context) {
            return AsyncProgressDialog(
              response,
              message: const Text(adding_address),
              onError: (e) {
                snackbarMessage = e.toString();
              },
            );
          },
        );

        var awaitedResponse = await response;
        if (await awaitedResponse["success"] == true) {
          Get.back();
          authController.usermodel.value!.address =
              Address.fromJson(awaitedResponse["data"]);
          userController.myAddresses
              .add(Address.fromJson(awaitedResponse["data"]));
          userController.myAddresses.refresh();
          authController.usermodel.refresh();
          snackbarMessage = address_saved_successfully;
        } else {
          throw "Coundn't save the address due to unknown reason";
        }
      } catch (e, s) {
        printOut("Error saving address $e $s");
        snackbarMessage = something_went_wrong;
      } finally {
        showSnackBack(context, snackbarMessage);
      }
    }
  }

  Future<void> saveEditedAddressButtonCallback(BuildContext context) async {
    if (checkOutController.formKey.currentState!.validate()) {
      final Address newAddress = generateAddressObject(id: addressToEdit!.id);

      dynamic response;
      String snackbarMessage = updated_successfully;
      try {
        response =
            UserAPI.updateAddressForCurrentUser(newAddress, addressToEdit!.id!);
        await showDialog(
          context: context,
          builder: (context) {
            return AsyncProgressDialog(
              response,
              message: const Text(updating_address),
              onError: (e) {
                snackbarMessage = e.toString();
              },
            );
          },
        );
        var waitedResponse = await response;
        if (waitedResponse["success"] == true) {
          snackbarMessage = address_updated_successfully;
          Get.find<UserController>().gettingMyAddrresses();
        } else {
          throw "Couldn't update address due to unknown reason";
        }
      } on FirebaseException catch (e) {
        printOut("Error editing address. Firebase exception $e ");
        snackbarMessage = something_went_wrong;
      } catch (e, s) {
        printOut("Error editing address $e $s");
        snackbarMessage = something_went_wrong;
      } finally {
        Get.back();
        showSnackBack(context, snackbarMessage);
        checkOutController.clearAddressTextControllers();
      }
    }
  }

  Address generateAddressObject({String? id}) {
    return Address(
      name: checkOutController.addressReceiverFieldController.text,
      addrress1: checkOutController.addressLine1FieldController.text,
      addrress2: checkOutController.addressLine2FieldController.text,
      country: checkOutController.countryFieldController.text,
      city: checkOutController.cityFieldController.text,
      state: checkOutController.stateFieldController.text,
      phone: checkOutController.phoneFieldController.text,
      userId: FirebaseAuth.instance.currentUser!.uid,
    );
  }
}
