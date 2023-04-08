import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/shop_controller.dart';
import 'package:tokshop/widgets/text_form_field.dart';

import '../../../utils/text.dart';
import '../../../utils/utils.dart';

class StripeSetup extends StatelessWidget {
  StripeSetup({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  final ShopController shopController = Get.find<ShopController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    shopController.firstNameController.text =
        authController.usermodel.value!.firstName!;
    shopController.lastNameController.text =
        authController.usermodel.value!.lastName!;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          add_bank_details,
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 0.015.sh,
                ),
                CSCPicker(
                  showStates: true,
                  showCities: true,
                  defaultCountry: CscCountry.United_States,
                  flagState: CountryFlag.DISABLE,
                  disableCountry: true,

                  dropdownDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(color: primarycolor, width: 1)),
                  disabledDropdownDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.transparent,
                      border: Border.all(color: primarycolor, width: 1)),
                  countrySearchPlaceholder: "Country",
                  stateSearchPlaceholder: "State",
                  citySearchPlaceholder: "City",
                  countryDropdownLabel: "*Country",
                  stateDropdownLabel: "*State",
                  cityDropdownLabel: "*City",
                  selectedItemStyle: TextStyle(
                    color: primarycolor,
                    fontSize: 14.sp,
                  ),

                  ///DropdownDialog Heading style [OPTIONAL PARAMETER]
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
                  onCountryChanged: (value) {},
                  onStateChanged: (value) {
                    shopController.accountState.value = value.toString();
                  },
                  onCityChanged: (value) {
                    shopController.accountCity.value = value.toString();
                  },
                ),
                CustomTextFormField(
                  controller: shopController.addressController,
                  hint: "605 W Maude Ave",
                  validate: true,
                  label: address,
                ),
                CustomTextFormField(
                  controller: shopController.accountNumberController,
                  hint: "000123456789",
                  validate: true,
                  label: account_number,
                ),
                CustomTextFormField(
                  controller: shopController.routingNumberController,
                  hint: "110000000",
                  label: shopController.pickedCountry.value == 1
                      ? bank_identifier_code
                      : routing_number,
                  validate: true,
                ),
                CustomTextFormField(
                  controller: shopController.postalCodeController,
                  hint: "94085",
                  validate: true,
                  label: postal_code,
                ),
                CustomTextFormField(
                  controller: shopController.phoneNumberController,
                  hint: "+17297409480",
                  validate: true,
                  label: phone_number,
                ),
                SizedBox(
                  height: 0.015.sh,
                ),
                Text(
                  date_of_birth,
                  style: TextStyle(color: primarycolor, fontSize: 14.sp),
                ),
                SizedBox(
                  height: 0.01.sh,
                ),
                Obx(() {
                  return InkWell(
                    onTap: () {
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(1900, 5, 5, 20, 50),
                          maxTime: DateTime.now()
                              .subtract(const Duration(days: 366 * 18)),
                          theme: const DatePickerTheme(
                              itemStyle: TextStyle(color: primarycolor),
                              cancelStyle: TextStyle(color: primarycolor),
                              doneStyle: TextStyle(color: kPrimaryColor)),
                          onConfirm: (date) {
                        shopController.birthDateHolder.value = date.toString();
                      }, locale: LocaleType.en);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            shopController.birthDateHolder.isNotEmpty
                                ? "${DateTime.parse(shopController.birthDateHolder.value).day}"
                                    "-${DateTime.parse(shopController.birthDateHolder.value).month}"
                                    "-${DateTime.parse(shopController.birthDateHolder.value).year}"
                                : "DOB",
                            style: TextStyle(
                                fontSize: 16.sm,
                                fontWeight: FontWeight.w400,
                                color: primarycolor),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  );
                }),
                CustomTextFormField(
                  controller: shopController.ssnNumberController,
                  hint: "0000",
                  validate: true,
                  label: last_digits,
                ),
                SizedBox(
                  height: 0.03.sh,
                ),
                Obx(() {
                  return Center(
                    child: InkWell(
                      onTap: () async {
                        if (shopController.accountCity.value.isEmpty ||
                            shopController.accountState.value.isEmpty) {
                          Get.snackbar("Error", city_and_state_are_required);
                        } else {
                          if (_formKey.currentState!.validate()) {
                            await shopController.createStripeConnectAccount();
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: shopController.creatingStripeAccount.isFalse
                                ? Text(
                                    add,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18.sp),
                                  )
                                : const CircularProgressIndicator(
                                    color: Colors.white,
                                  )),
                      ),
                    ),
                  );
                }),
                SizedBox(
                  height: 0.03.sh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} //+17297409480
