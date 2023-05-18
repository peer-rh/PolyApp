import 'package:flutter/material.dart';
import 'package:poly_app/common/ui/custom_icons.dart';

class CustomBox extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? minHeight;

  const CustomBox(
      {required this.child,
      this.backgroundColor,
      this.borderColor,
      this.borderWidth,
      this.minHeight,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints:
          minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
      padding: EdgeInsets.all(17 - (borderWidth ?? 1)),
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: (borderColor != null)
            ? Border.all(
                color: borderColor ?? Theme.of(context).colorScheme.surface,
                width: borderWidth ?? 1,
              )
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class NextStepWidget extends StatelessWidget {
  final String nextStepTitle;
  final void Function(BuildContext) onNextStep;
  const NextStepWidget(
      {required this.nextStepTitle, required this.onNextStep, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onNextStep(context),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    alignment: Alignment.center,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.primary),
                    child: Icon(
                      CustomIcons.lockopen,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 16,
                    )),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Up Next:",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      nextStepTitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
                Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onBackground,
                  size: 24,
                )
              ],
            )));
  }
}
