import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInput;
import 'package:go_router/go_router.dart';
import 'package:movix/Models/Profil.dart';
import 'package:movix/Services/date_service.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/login.dart';
import 'package:movix/Services/settings.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLogin = false;
  bool _obscurePassword = true;
  String _appVersion = "1.0.0";

  @override
  void initState() {
    super.initState();
    initializeDateService();
    _getAppVersion();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
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
      // Signaler aux gestionnaires de mots de passe que l'autofill est terminé
      // Cela permet de proposer la sauvegarde des identifiants
      TextInput.finishAutofillContext();
      context.go('/home');
    } else {
      Globals.showSnackbar("Identifiant ou mot de passe incorrect.",
          backgroundColor: Globals.COLOR_MOVIX_RED);
    }

    setState(() => _isLogin = false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Globals.darkModeNotifier,
      builder: (context, isDarkMode, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Globals.COLOR_BACKGROUND,
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          _buildHeader(),
                          const SizedBox(height: 48),
                          _buildLoginForm(),
                          const SizedBox(height: 32),
                          _buildFooter(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _buildDarkModeToggle(),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: _buildEnvironmentToggle(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Globals.COLOR_SURFACE,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Globals.COLOR_SHADOW.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              Globals.darkModeNotifier.value
                  ? 'assets/images/logo_dark.png'
                  : 'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Bienvenue',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Globals.COLOR_TEXT_DARK,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous pour continuer',
          style: TextStyle(
            fontSize: 16,
            color: Globals.COLOR_TEXT_DARK_SECONDARY,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Identifiant',
            hint: 'Entrez votre identifiant',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Mot de passe',
            hint: 'Entrez votre mot de passe',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Globals.COLOR_TEXT_SECONDARY,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 32),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<String>? autofillHints,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Globals.COLOR_TEXT_DARK,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          autocorrect: false,
          enableSuggestions: !obscureText,
          style: TextStyle(
            fontSize: 16,
            color: Globals.COLOR_TEXT_DARK,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Globals.COLOR_TEXT_DARK_SECONDARY,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              icon,
              color: Globals.COLOR_TEXT_SECONDARY,
              size: 22,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Globals.COLOR_SURFACE,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Globals.COLOR_TEXT_SECONDARY.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Globals.COLOR_MOVIX,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLogin ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Globals.COLOR_MOVIX,
          disabledBackgroundColor: Globals.COLOR_MOVIX.withOpacity(0.6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLogin
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Se connecter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Version $_appVersion',
      style: TextStyle(
        fontSize: 13,
        color: Globals.COLOR_TEXT_SECONDARY,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDarkModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Globals.COLOR_SHADOW.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Globals.darkModeNotifier.value
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          color: Globals.COLOR_ADAPTIVE_ACCENT,
        ),
        onPressed: () async {
          final newValue = !Globals.darkModeNotifier.value;
          await setDarkMode(newValue);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildEnvironmentToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Globals.COLOR_SHADOW.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEnvironmentDialog(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_outlined,
                color: Globals.COLOR_ADAPTIVE_ACCENT,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                kDebugMode ? 'Debug' : Globals.API_ENVIRONMENT.displayName,
                style: TextStyle(
                  color: Globals.COLOR_ADAPTIVE_ACCENT,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnvironmentDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Globals.COLOR_SURFACE,
              Globals.COLOR_SURFACE.withOpacity(0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Globals.COLOR_TEXT_GRAY.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.15),
                            Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.08),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_outlined,
                        color: Globals.COLOR_ADAPTIVE_ACCENT,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Environnement API',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Globals.COLOR_TEXT_DARK,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Globals.COLOR_TEXT_GRAY.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...ApiEnvironment.values.map((env) {
                final isSelected = env == Globals.API_ENVIRONMENT;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.1)
                        : Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.3)
                          : Globals.COLOR_TEXT_GRAY.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Globals.COLOR_ADAPTIVE_ACCENT
                            : Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      env.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Globals.COLOR_TEXT_DARK,
                      ),
                    ),
                    subtitle: Text(
                      env.url,
                      style: TextStyle(
                        fontSize: 12,
                        color: Globals.COLOR_TEXT_GRAY,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Globals.COLOR_ADAPTIVE_ACCENT,
                            size: 20,
                          )
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      await Future<void>.delayed(const Duration(milliseconds: 100));
                      await setApiEnvironment(env);
                      setState(() {});
                    },
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
