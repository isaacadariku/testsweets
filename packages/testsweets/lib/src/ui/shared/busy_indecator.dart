import 'package:flutter/material.dart';
import 'package:testsweets/src/ui/shared/shared_styles.dart';

import 'app_colors.dart';

class BusyIndicator extends StatelessWidget {
  final bool enable;
  const BusyIndicator({Key? key, required this.enable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return enable
        ? Container(
            color: kcBackground.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: blackBoxDecoration,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(kcPrimaryPurple),
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}
