import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_quickstart/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null) {
        Navigator.of(context).pushReplacementNamed('/account');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              label: Text('Email'),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              try {
                final email = _emailController.text.trim();
                await supabase.auth.signInWithOtp(
                  email: email,
                  emailRedirectTo:
                      'io.supabase.flutterquickstart://login-callback/',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Check your inbox')));
                }
              } on AuthException catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Error occured, please retry.'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
