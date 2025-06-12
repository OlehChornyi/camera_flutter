import 'package:flutter/material.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu({
    super.key,
    required this.onSwitchCameraTap,
    required this.onAddOverlayTap,
    required this.onPlayStopTap,
    required this.onTakeImageTap,
  });

  final Function() onSwitchCameraTap;
  final Function() onAddOverlayTap;
  final Function() onPlayStopTap;
  final Function() onTakeImageTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 2),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(50),
                    borderRadius: BorderRadius.circular(56),
                  ),
                  child: IconButton(
                    onPressed: onSwitchCameraTap,
                    icon: Icon(
                      Icons.cameraswitch,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(50),
                    borderRadius: BorderRadius.circular(56),
                  ),
                  child: IconButton(
                    onPressed: onAddOverlayTap,
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.white),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: GestureDetector(
                  onTap: onPlayStopTap,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 48, 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(56),
                ),
                child: IconButton(
                  onPressed: onTakeImageTap,
                  icon: Icon(
                    Icons.image_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
