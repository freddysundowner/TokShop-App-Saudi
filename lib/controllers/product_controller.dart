import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/channel.dart';
import 'package:tokshop/models/interests.dart';

import '../models/product.dart';
import '../services/client.dart';
import '../services/end_points.dart';
import '../services/product_api.dart';
import '../services/shop_api.dart';
import 'auth_controller.dart';

enum ImageType {
  local,
  network,
}

class CustomImage {
  final ImageType imgType;
  final String path;
  CustomImage({this.imgType = ImageType.local, required this.path});
  @override
  String toString() {
    return "Instance of Custom Image: {imgType: $imgType, path: $path}";
  }
}

class ProductController extends GetxController
    with GetTickerProviderStateMixin {
  Rxn<Product> currentProduct = Rxn();
  Rxn<Product> productObservable = Rxn();
  RxList<Product> relatedProducts = RxList([]);
  RxList<Product> marketplaceProducts = RxList([]);
  RxInt allProductsCount = RxInt(0);
  RxList<Product> allproducts = RxList([]);
  RxList<Product> homeallproducts = RxList([]);
  RxList<Product> profileproducts = RxList([]);
  RxList<Product> interestsProducts = RxList([]);
  RxList<Product> channelProducts = RxList([]);
  RxList<Channel> categories = RxList([]);
  RxList<Interests> subcategories = RxList([]);
  RxBool showsearch = RxBool(false);
  var searchEnabled = false.obs;
  var products = [].obs;
  var loading = false.obs;
  var loadingRelatedProducts = false.obs;
  var loadingSingleProduct = false.obs;
  var loadingcateries = false.obs;
  var loadingproducts = false.obs;
  var showingCategories = false.obs;
  RxList<Interests> pickedProductCategories = RxList([]);

  var userProducts = [].obs;
  var userProductsLoading = false.obs;
  RxInt selectedPage = 0.obs;
  Rxn<Interests> selectedInterest = Rxn(null);
  Rxn<Channel> selectedChannel = Rxn(null);
  var error = "".obs;
  Product get product => productObservable.value!;
  set product(Product value) => productObservable.value = value;
  TextEditingController searchText = TextEditingController();

  final TextEditingController qtyFieldController = TextEditingController();
  final TextEditingController discoountedPrice = TextEditingController();
  final TextEditingController titleFieldController = TextEditingController();
  final TextEditingController discountPriceFieldController =
      TextEditingController();
  final TextEditingController originalPriceFieldController =
      TextEditingController();
  final TextEditingController variantFieldController = TextEditingController();
  final TextEditingController sellerFieldController = TextEditingController();
  final TextEditingController highlightsFieldController =
      TextEditingController();
  final TextEditingController desciptionFieldController =
      TextEditingController();
  Rxn<TabController> tabController = Rxn(null);
  var tabIndex = 0.obs;

  var isScrroll = true.obs;
  var searchPageNumber = 1.obs;
  final homepageScroller = ScrollController();
  final searchController = ScrollController();
  final marketplacecontroller = ScrollController();
  var selectedImages = [].obs;
  final _selectedImages = [].obs;

  set initialSelectedImages(List<CustomImage> images) {
    _selectedImages.value = images;
  }

  void setSelectedImageAtIndex(CustomImage image, int index) {
    if (index < selectedImages.length) {
      selectedImages[index] = image;
    }
  }

  void addNewSelectedImage(CustomImage image) {
    _selectedImages.add(image);
  }

  scrollControllerCustom() {
    final marketplacecontroller = ScrollController();
    marketplacecontroller.addListener(() {
      if (marketplacecontroller.position.atEdge) {
        var nextPageTrigger =
            0.7 * marketplacecontroller.position.maxScrollExtent;
        if (marketplacecontroller.position.pixels > nextPageTrigger) {
          if (isScrroll.isTrue) {
            _getProducts(
                page: searchPageNumber.value.toString(),
                title: searchText.text);
          }
        }
      }
    });
    return marketplacecontroller;
  }

  @override
  void onInit() {
    super.onInit();
    tabController.value = TabController(
      initialIndex: tabIndex.value,
      length: 2,
      vsync: this,
    );
  }

  _getProducts({String page = "1", String title = ""}) async {
    var response = await ProductPI.getAllroducts(page, title: title);
    List list = response["products"];
    allproducts.addAll(list.map((e) => Product.fromJson(e)).toList());
    marketplaceProducts.value = allproducts;
    print(homeallproducts.length);
    if (response["totalDoc"] > allproducts.length) {
      searchPageNumber.value++;
    } else {
      isScrroll.value = false;
    }
  }

  getCategories() async {
    try {
      categories.clear();
      subcategories.clear();
      loadingcateries.value = true;
      var response = await ProductPI.getCategories();
      List list = response;
      categories.value = list.map((e) => Channel.fromJson(e)).toList();
      for (var e in categories) {
        e.subinterests?.forEach((element) {
          subcategories.add(element);
        });
      }
      loadingcateries.value = false;
    } catch (e) {
      print(e);
      loadingcateries.value = false;
    }
  }

  getAllroducts(
      {String page = "1",
      String userid = "",
      String type = "",
      String title = "",
      String interest = "",
      String channel = "",
      String limit = "15",
      bool featured = false}) async {
    try {
      searchPageNumber.value = 1;
      allProductsCount.value = 0;
      isScrroll.value = true;
      var response = await ProductPI.getAllroducts(page,
          title: title,
          featured: featured,
          userid: userid,
          interest:
              selectedInterest.value != null ? selectedInterest.value!.id! : "",
          channel: selectedChannel.value != null
              ? selectedInterest.value != null
                  ? ""
                  : selectedChannel.value!.id!
              : "",
          limit: limit);
      List list = response["products"];
      List<Product> products = list.map((e) => Product.fromJson(e)).toList();
      if (interest.isNotEmpty) {
        interestsProducts.value = products;
      } else if (channel.isNotEmpty) {
        channelProducts.value = products;
      } else if (type == "home") {
        homeallproducts.value = products;
      } else if (type == "profile") {
        profileproducts.value = products;
      } else if (channel.isEmpty && interest.isEmpty) {
        allproducts.value = products;
        marketplaceProducts.value = allproducts.value;
      }
      if (response["totalDoc"] > allproducts.length) {
        searchPageNumber.value++;
      } else {
        isScrroll.value = false;
      }
      allProductsCount.value = response["totalDoc"];
    } catch (e) {
      print(e);
    }
  }

  getProductCategories({String page = "1", String title = ""}) async {
    try {
      allproducts.clear();
      searchPageNumber.value = 1;
      isScrroll.value = true;
      loadingproducts.value = true;
      var response = await ProductPI.getAllroducts(page, title: title);

      List list = response["products"];
      allproducts.value = list.map((e) => Product.fromJson(e)).toList();
      if (response["totalDoc"] > allproducts.length) {
        searchPageNumber.value++;
      }
      loadingproducts.value = false;
      refresh();
    } catch (e) {
      loadingproducts.value = false;
    }
  }

  Future<void> fetchUserProducts() async {
    try {
      userProductsLoading.value = true;
      userProducts.value = [];
      var response = await ProductPI.getAllroducts("1",
          userid: FirebaseAuth.instance.currentUser!.uid);
      List products = response["products"];
      if (products.isNotEmpty) {
        //if a product has images, add it to the user products list
        for (var i = 0; i < products.length; i++) {
          userProducts.add(products.elementAt(i));
        }
      } else {
        userProducts.value = [];
      }
      userProducts.refresh();
      userProductsLoading.value = false;

      update();
    } catch (e) {
      userProductsLoading.value = false;
    }
  }

  saveProduct() {
    Map<String, dynamic> productdata = {
      "name": titleFieldController.text,
      "price": originalPriceFieldController.text,
      "quantity": qtyFieldController.text,
      "discountedPrice": discoountedPrice.text,
      "description": desciptionFieldController.text,
      "shopId": Get.find<AuthController>().currentuser!.shopId!.id,
      "ownerId": FirebaseAuth.instance.currentUser!.uid,
      "variations": variantFieldController.text,
      "interest": pickedProductCategories.map((element) => element.id).toList()
    };

    return ProductPI.saveProduct(productdata);
  }

  updateProduct(String productid) async {
    Map<String, dynamic> productdata = {
      "name": titleFieldController.text,
      "price": originalPriceFieldController.text,
      "discountedPrice": discoountedPrice.text,
      "quantity": qtyFieldController.text,
      "description": desciptionFieldController.text,
      "variations": variantFieldController.text,
      "interest": pickedProductCategories.map((element) => element.id).toList()
    };
    var response = await DbBase().databaseRequest(
        updateproduct + productid, DbBase().patchRequestType,
        body: productdata);

    return jsonDecode(response);
  }

  getProductById(Product product) async {
    loadingSingleProduct.value = true;
    var response = await ProductPI().getProductById(product.id!);
    print("guku ${response["shippingMethods"]} ${product.id!}");
    currentProduct.value = Product.fromJson(response);
    currentProduct.value!.images = product.images;
    currentProduct.refresh();
    loadingSingleProduct.value = false;
  }

  getRelatedProductByInterest(Product product) async {
    loadingRelatedProducts.value = true;
    var response = await ProductPI.getAllroducts(
      "1",
      limit: "15",
      interest: product.interest!.isNotEmpty ? product.interest!.first.id! : "",
    );
    List list = response["products"];
    relatedProducts.value = list.map((e) => Product.fromJson(e)).toList();
    relatedProducts.refresh();
    loadingRelatedProducts.value = false;
  }
}
