import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget
{
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context)
  {
    return AppBar
    (
      toolbarHeight: 80,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Image.asset(
          'assets/bianchiii-logo.png',
          height: 60,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.black,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}