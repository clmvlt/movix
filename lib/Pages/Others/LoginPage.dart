import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Profil.dart';
import 'package:movix/Services/date_service.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/login.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = false;
  String _appVersion = "1.0.0";

  @override
  void initState() {
    super.initState();
    initializeDateService();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // En cas d'erreur, on garde la version par défaut
      print('Erreur lors de la récupération de la version: $e');
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Globals.showSnackbar("Veuillez remplir tous les champs.",
          backgroundColor: Globals.COLOR_MOVIX_YELLOW);
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
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLoginCard(),
                      ],
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Globals.COLOR_SHADOW.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Globals.COLOR_MOVIX.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Connexion',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Globals.COLOR_TEXT_DARK,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildModernTextField(
            controller: _emailController,
            label: 'Identifiant',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 24),
          _buildModernTextField(
            controller: _passwordController,
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 32),
          _buildModernLoginButton(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        "Version $_appVersion",
        style: TextStyle(
          fontSize: 14,
          color: Globals.COLOR_TEXT_SECONDARY,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Globals.COLOR_SHADOW.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          color: Globals.COLOR_TEXT_DARK,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Globals.COLOR_TEXT_DARK,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          floatingLabelStyle: TextStyle(
            color: Globals.COLOR_MOVIX,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Globals.COLOR_MOVIX.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Globals.COLOR_MOVIX,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Globals.COLOR_SURFACE_SECONDARY,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Globals.COLOR_MOVIX,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildModernLoginButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Globals.COLOR_MOVIX.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Globals.COLOR_SHADOW.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLogin ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLogin 
              ? Globals.COLOR_TEXT_SECONDARY 
              : Globals.COLOR_MOVIX,
          disabledBackgroundColor: Globals.COLOR_TEXT_SECONDARY,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLogin
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Connexion en cours...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              )
            : const Text(
                'Se connecter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
      ),
    );
  }
}
