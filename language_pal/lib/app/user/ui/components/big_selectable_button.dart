import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BigSelectableButton extends StatelessWidget {
  final bool selected;
  final String emoji;
  final String title;
  final void Function() onTap;
  const BigSelectableButton(
      {this.selected = false,
      required this.emoji,
      required this.title,
      required this.onTap,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 1,
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 60)),
                const SizedBox(width: 16),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(title,
                        maxLines: 1,
                        style: GoogleFonts.nunito(
                            fontSize: 30,
                            color: selected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
