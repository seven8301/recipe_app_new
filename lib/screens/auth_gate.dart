import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthGate extends StatefulWidget {
  final Widget home;
  const AuthGate({super.key, required this.home});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    AuthService().load().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (AuthService().loggedIn) return widget.home;
    Future.microtask(
      () => Navigator.of(context).pushReplacementNamed('/login'),
    );
    return const Scaffold(body: SizedBox.shrink());
  }
}