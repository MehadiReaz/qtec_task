import 'package:flutter/material.dart';

class SortButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SortButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        'assets/images/sort.png',
        // width: 24,
        // height: 24,
      ),
      onPressed: onPressed,
    );
  }
}
