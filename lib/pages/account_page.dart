import 'package:flutter/material.dart';
import 'package:supabase_quickstart/components/avatar.dart';
import 'package:supabase_quickstart/main.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _usernameController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _getInitialProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _getInitialProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final data =
        await supabase.from('profiles').select().eq('id', userId).single();
    setState(() {
      _usernameController.text = data['username'];
      _websiteController.text = data['website'];
      _imageUrl = data['avatar_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Avatar(
              imageUrl: _imageUrl,
              onUpload: (imageUrl) async {
                setState(() {
                  _imageUrl = imageUrl;
                });
                final userId = supabase.auth.currentUser!.id;
                await supabase
                    .from('profiles')
                    .update({'avatar_url': imageUrl}).eq('id', userId);
              }),
          const SizedBox(height: 12),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              label: Text('Username'),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(
              label: Text('Website'),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final username = _usernameController.text.trim();
              final website = _websiteController.text.trim();
              final userId = supabase.auth.currentUser!.id;

              await supabase.from('profiles').update({
                'username': username,
                'website': website,
              }).eq('id', userId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Your data has been saved')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
