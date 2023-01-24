import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class CustomBackButton extends StatefulWidget {
  const CustomBackButton({super.key});

  @override
  State<CustomBackButton> createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton> {
  @override
  Widget build(BuildContext context) {
    return BackButton(onPressed: () {
      Navigator.popUntil(
          context,
          (route) =>
              route.settings.name == "/lobby" || route.settings.name == "/");
    });
  }
}
