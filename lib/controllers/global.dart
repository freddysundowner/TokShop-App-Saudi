import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/services/room_api.dart';
import 'package:tokshop/services/user_api.dart';

import '../services/shop_api.dart';
import '../utils/utils.dart';

class GlobalController extends GetxController with GetTickerProviderStateMixin {
  var currentsearchtab = 0.obs;
  var tabPosition = 0.obs;
  TextEditingController searchShopController = TextEditingController();
  TextEditingController searchText = TextEditingController();
  var isSearching = false.obs;
  var canback = false.obs;

  var searchresults = [].obs;
  var searchoption = "".obs;
  var searchPageNumber = 1.obs;
  var isScrroll = true.obs;
  var tabIndex = 0.obs;
  var innertabIndex = 0.obs;
  Rxn<TabController> tabController = Rxn(null);
  Rxn<TabController> innertabsController = Rxn(null);
  final scrollcontroller = ScrollController();
  var switchtabIndex = 0.obs;
  Rxn<TabController> sellertabController = Rxn(null);
  var sellertabIndex = 0.obs;

  Rxn<TabController> buyertabcontroller = Rxn(null);
  Rxn<TabController> userSwitchtabController = Rxn(null);
  @override
  void onInit() {
    super.onInit();
    userSwitchtabController.value = TabController(
      initialIndex: switchtabIndex.value,
      length: 2,
      vsync: this,
    );
    buyertabcontroller.value = TabController(
      initialIndex: innertabIndex.value,
      length: 2,
      vsync: this,
    );
    sellertabController.value = TabController(
      initialIndex: sellertabIndex.value,
      length: 3,
      vsync: this,
    );
    innertabsController.value = TabController(
      initialIndex: innertabIndex.value,
      length: 3,
      vsync: this,
    );

    tabController.value = TabController(
      initialIndex: tabIndex.value,
      length: 2,
      vsync: this,
    );
    scrollcontroller.addListener(() {
      if (scrollcontroller.position.atEdge) {
        var nextPageTrigger = 0.7 * scrollcontroller.position.maxScrollExtent;
        if (scrollcontroller.position.pixels > nextPageTrigger) {
          if (isScrroll.isTrue) {
            search();
          }
        }
      }
    });
  }

  searchItems() async {
    String searchBy = searchoption.value;
    if (searchBy == "people") {
      return UserAPI().getAllUsers(searchPageNumber.value.toString(),
          title: searchShopController.text.trim().toString());
    } else if (searchBy == "tokshows") {
      searchBy = "rooms";
      return RoomAPI().getActiveTokshows();
    } else if (searchBy == "channels") {
      searchBy = "club";
    } else if (searchBy == "products") {
      searchBy = "products";

      Get.find<ProductController>().getAllroducts(
          title: searchShopController.text.trim().toString(),
          featured: false,
          page: searchPageNumber.value.toString());
    } else if (searchBy == "shops") {
      searchBy = "shops";
      return BrandApi.searchShop(searchPageNumber.value.toString(),
          title: searchShopController.text.trim().toString());
    }
  }

  Future<void> search() async {
    isSearching.value = true;
    try {
      var results = await searchItems();
      if (searchoption.value != "shops" && searchoption.value != "tokshows") {
        if (results["totalDoc"] > searchresults.length) {
          searchPageNumber = searchPageNumber + 1;
        } else {
          isScrroll.value = false;
        }
      }

      if (searchoption.value == "people") {
        for (var i = 0; i < results["users"].length; i++) {
          if (results["users"][i]['_id'] !=
              FirebaseAuth.instance.currentUser!.uid) {
            searchresults.add(results["users"][i]);
          }
        }
      } else if (searchoption.value == "products") {
        searchresults.value = results["products"];
      } else if (searchoption.value == "shops") {
        searchresults.value = results["brands"];
      } else if (searchoption.value == "tokshows") {
        searchresults.value = results["rooms"];
      }
      isSearching.value = false;
    } catch (e, s) {
      printOut("$e $s");
      isSearching.value = false;
    }
  }
}
