import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:language_pal/auth/presentation/signInPage.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
// NOTE: Very hacky way to avoid Navigator
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
