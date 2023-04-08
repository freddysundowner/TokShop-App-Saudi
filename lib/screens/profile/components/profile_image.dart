import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  String path;
  double? width;
  double? height;
  ProfileImage(
      {Key? key, required this.path, this.width = 55, this.height = 55})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: path != ""
          ? CachedNetworkImage(
              imageUrl: path,
              imageBuilder: (context, imageProvider) => Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Container(
                  width: width,
                  height: height,
                  child: const CircularProgressIndicator()),
              errorWidget: (context, url, error) => Image.asset(
                "assets/icons/profile_placeholder.png",
                width: width,
                height: height,
              ),
            )
          : CircleAvatar(
              radius: double.parse(width.toString()) * 0.5,
              child: Image.asset("assets/icons/profile_placeholder.png",
                  width: width, height: height),
            ),
    );
  }
}
