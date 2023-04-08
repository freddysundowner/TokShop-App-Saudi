import 'package:flutter/material.dart';

void showFilterBottomSheet(BuildContext context, Widget builderWidget,
    {double initialChildSize = 0.6}) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return DraggableScrollableSheet(
              initialChildSize: initialChildSize,
              expand: false,
              builder: (BuildContext productContext,
                  ScrollController scrollController) {
                return builderWidget;
              });
        });
      });
}
