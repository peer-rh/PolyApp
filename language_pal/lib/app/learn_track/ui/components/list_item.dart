import 'package:flutter/material.dart';
import 'package:poly_app/common/ui/custom_ink_well.dart';

class ListItem extends StatelessWidget {
  final bool highlighted;
  final bool enabled;
  final String title;
  final IconData icon;
  final void Function() onTap;

  const ListItem({
    this.highlighted = false,
    required this.enabled,
    required this.title,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: highlighted ? 7 : 8, horizontal: highlighted ? 15 : 16),
        decoration: BoxDecoration(
            border: Border.all(
                width: highlighted ? 2 : 1,
                color: highlighted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: enabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant),
                height: 24,
                width: 24,
                child: Icon(icon,
                    size: 16,
                    color: enabled
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleSmall!),
            const Spacer(),
            const Icon(Icons.chevron_right)
          ],
        ),
      ),
    );
  }
}
