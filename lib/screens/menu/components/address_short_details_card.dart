import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../models/address.dart';
import '../../../utils/text.dart';

class AddressShortDetailsCard extends StatelessWidget {
  final Address address;
  final Function onTap;

  const AddressShortDetailsCard(
      {Key? key, required this.address, required this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$full_name: ${address.name}",
                style: TextStyle(
                  fontSize: 12.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "$address_one: ${address.addrress1}",
                style: TextStyle(
                  fontSize: 12.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (address.addrress2 != null)
                Text(
                  "$address_two: ${address.addrress2}",
                  style: TextStyle(
                    fontSize: 12.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                "$state: ${address.state}",
                style: TextStyle(
                  fontSize: 12.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "$city: ${address.city}",
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "$phone: ${address.phone}",
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "$country: ${address.country}",
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
