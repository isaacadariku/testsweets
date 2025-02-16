import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testsweets/src/ui/driver_layout/driver_layout_view.dart';
import 'package:testsweets/src/ui/widget_capture/widget_capture_view.dart';

class TestSweetsOverlayView extends StatelessWidget {
  final Widget child;

  /// The projectId as seen in the settings of the TestSweets project
  final String projectId;

  /// Puts the overlay into widget capture mode
  final bool captureWidgets;

  /// When true we add the TestSweets overlay, default is true
  final bool enabled;

  const TestSweetsOverlayView({
    Key? key,
    required this.child,
    required this.projectId,
    this.captureWidgets = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: enabled
          ? captureWidgets
              ? WidgetCaptureView(child: child, projectId: projectId)
              : DriverLayoutView(child: child, projectId: projectId)
          : child,
    );
  }
}
