import 'package:get/get.dart';

class ProductImageSwiper extends GetxController {
  final _currentImageIndex = 0.obs;
  int get currentImageIndex {
    return _currentImageIndex.value;
  }

  set currentImageIndex(int index) {
    _currentImageIndex.value = index;
    refresh();
  }
}
