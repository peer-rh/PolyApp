import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  final double size;
  const Logo(this.size, {super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Language",
              style: GoogleFonts.nunito(
                fontSize: size,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              )),
          Text("Pal",
              style: GoogleFonts.nunito(
                fontSize: size,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
