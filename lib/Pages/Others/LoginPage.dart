import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Services/date_service.dart';
import 'package:movix/Services/login.dart';
import 'package:movix/Models/Profil.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/update_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = false;
  late String _appVersion = "";

  @override
  void initState() {
    super.initState();
    getAppVersion().then((value) {
      setState(() {
        _appVersion = value;
      });
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Globals.showSnackbar("Veuillez remplir tous les champs.",
          backgroundColor: Colors.orange);
      return;
    }

    setState(() => _isLogin = true);

    Profil? profil = await login(email, password);

    if (profil != null) {
      context.go('/home');
    } else {
      Globals.showSnackbar("Identifiant ou mot de passe incorrect.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
    }

    setState(() => _isLogin = false);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Globals.COLOR_MOVIX;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.movie_filter_outlined,
                    size: 64, color: primaryColor),
                const SizedBox(height: 20),
                Text(
                  'Bienvenue sur Movix',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  getFormatedTodayFR(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildTextField(
                    controller: _emailController,
                    label: 'Identifiant',
                    icon: Icons.email),
                const SizedBox(height: 20),
                _buildTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    icon: Icons.lock,
                    obscureText: true),
                const SizedBox(height: 30),
                _buildLoginButton(),
                const SizedBox(height: 40),
                Text(
                  "v$_appVersion",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildLoginButton() {
    const primaryColor = Globals.COLOR_MOVIX;

    return ElevatedButton(
      onPressed: _isLogin ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: primaryColor.withOpacity(0.5),
        elevation: 4,
      ),
      child: _isLogin
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : const Text('Se connecter',
              style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}
