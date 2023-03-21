import 'package:flutter/widgets.dart';
import 'package:language_pal/auth/presentation/sign_in_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late Widget child;

  void setChild(Widget c) {
    setState(() {
      child = c;
    });
  }

  @override
  void initState() {
    child = SignInPage(setChild);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
