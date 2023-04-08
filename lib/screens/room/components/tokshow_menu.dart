import 'dart:math' as math;

import 'package:tokshop/utils/styles.dart';
import 'package:tokshop/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/room_controller.dart';

@immutable
class TokShowMenu extends StatefulWidget {
  const TokShowMenu({
    Key? key,
    this.initialOpen,
    required this.distance,
    required this.children,
  }) : super(key: key);

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  TokShowMenuState createState() => TokShowMenuState();
}

class TokShowMenuState extends State<TokShowMenu>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _expandAnimation;

  final TokShowController _homeController = Get.find<TokShowController>();

  @override
  void initState() {
    super.initState();
    _homeController.expandableFabOpen.value = widget.initialOpen ?? false;
    _homeController.expandableFabAnimationController = AnimationController(
      value: _homeController.expandableFabOpen.value ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _homeController.expandableFabAnimationController,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void closeFab() {
    setState(() {
      _homeController.expandableFabOpen.value = false;
      _homeController.expandableFabAnimationController.reverse();
    });
  }

  void _toggle() {
    _homeController.expandableFabOpen.value =
        !_homeController.expandableFabOpen.value;
    if (_homeController.expandableFabOpen.isTrue) {
      _homeController.expandableFabAnimationController.forward();
    } else {
      _homeController.expandableFabAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 50.0,
      height: 50.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return Obx(() {
      return IgnorePointer(
        ignoring: _homeController.expandableFabOpen.value,
        child: AnimatedContainer(
          transformAlignment: Alignment.center,
          transform: Matrix4.diagonal3Values(
            _homeController.expandableFabOpen.value ? 0.7 : 1.0,
            _homeController.expandableFabOpen.value ? 0.7 : 1.0,
            1.0,
          ),
          duration: const Duration(milliseconds: 250),
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          child: AnimatedOpacity(
            opacity: _homeController.expandableFabOpen.value ? 0.0 : 1.0,
            curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
            duration: const Duration(milliseconds: 250),
            child: Obx(() {
              return FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _toggle,
                child: Stack(
                  children: [
                    const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.more_horiz,
                          color: Colors.black,
                        )),
                    if (_homeController
                            .currentRoom.value.raisedHands!.isNotEmpty &&
                        _homeController.currentRoom.value.ownerId!.id ==
                            FirebaseAuth.instance.currentUser!.uid)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 0.02.sw,
                          height: 0.01.sh,
                          decoration: BoxDecoration(
                              color: Styles.red,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      )
                  ],
                ),
              );
            }),
          ),
        ),
      );
    });
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 4.0,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: Colors.black,
      ),
    );
  }
}
