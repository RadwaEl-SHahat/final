import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class HomeCard extends StatelessWidget {

  final  image;
  final String label;

  const HomeCard({super.key, this.image, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          padding:   EdgeInsets.all(6),
          width: 200,
          decoration: BoxDecoration(
              color: Color(0x174267),
              boxShadow: [
                BoxShadow(
                    color: Colors.indigoAccent,
                    blurRadius:5
                )
              ]
          ),
          child: Column(
              children: [
                Container(
                    color: Colors.white,
                    child: Image.asset(image)),
                SizedBox(height: 10),
                Text(
                  label,
                  style: GoogleFonts.robotoCondensed(
                    color:Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]),
        ),
      ),
    )
    ;
  }
}
