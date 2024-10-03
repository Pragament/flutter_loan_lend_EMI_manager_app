import 'package:flutter/material.dart';

class Legend extends StatelessWidget {
  final List<Color> colors; // List of colors for each loan/lend
  final List<String> labels; // Corresponding labels for the colors

  const Legend({
    Key? key,
    required this.colors,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(colors.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(4), // Rounded corners
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
