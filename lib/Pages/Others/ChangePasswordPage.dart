import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/API/profile_fetcher.dart' as profile_api;

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _currentPasswordError;
  PasswordStrength _passwordStrength = PasswordStrength.none;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_validateCurrentPassword);
    _newPasswordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_validateCurrentPassword);
    _newPasswordController.removeListener(_updatePasswordStrength);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _validateCurrentPassword() {
    final currentPassword = _currentPasswordController.text;
    if (currentPassword.isEmpty) {
      setState(() => _currentPasswordError = null);
      return;
    }

    final storedHash = Globals.profil?.passwordHash ?? '';
    if (storedHash.isEmpty) {
      setState(() => _currentPasswordError = null);
      return;
    }

    final inputHash = _hashPassword(currentPassword);
    if (inputHash != storedHash) {
      setState(() => _currentPasswordError = 'Mot de passe incorrect');
    } else {
      setState(() => _currentPasswordError = null);
    }
  }

  void _updatePasswordStrength() {
    final password = _newPasswordController.text;
    setState(() {
      _passwordStrength = _calculatePasswordStrength(password);
    });
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;

    int score = 0;

    // Longueur
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Contient des minuscules
    if (password.contains(RegExp(r'[a-z]'))) score++;

    // Contient des majuscules
    if (password.contains(RegExp(r'[A-Z]'))) score++;

    // Contient des chiffres
    if (password.contains(RegExp(r'[0-9]'))) score++;

    // Contient des caractères spéciaux
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  Future<void> _changePassword() async {
    // Vérifier le mot de passe actuel d'abord
    if (_currentPasswordError != null) {
      Globals.showSnackbar(
        "Le mot de passe actuel est incorrect.",
        backgroundColor: Globals.COLOR_MOVIX_RED,
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      Globals.showSnackbar(
        "Les mots de passe ne correspondent pas.",
        backgroundColor: Globals.COLOR_MOVIX_RED,
      );
      return;
    }

    if (_newPasswordController.text.isEmpty || _currentPasswordController.text.isEmpty) {
      Globals.showSnackbar(
        "Veuillez remplir tous les champs.",
        backgroundColor: Globals.COLOR_MOVIX_RED,
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await profile_api.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        Navigator.pop(context);
        Globals.showSnackbar(
          "Mot de passe modifié avec succès.",
          backgroundColor: Globals.COLOR_MOVIX_GREEN,
        );
      }
    } else {
      Globals.showSnackbar(
        error,
        backgroundColor: Globals.COLOR_MOVIX_RED,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Text('Changer le mot de passe', style: TextStyle(color: Globals.COLOR_TEXT_LIGHT)),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSectionTitle('Mot de passe actuel'),
            const SizedBox(height: 12),
            _buildPasswordCard(
              controller: _currentPasswordController,
              label: 'Entrez votre mot de passe actuel',
              obscure: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
              errorText: _currentPasswordError,
              icon: Icons.lock_outline,
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('Nouveau mot de passe'),
            const SizedBox(height: 12),
            _buildPasswordCard(
              controller: _newPasswordController,
              label: 'Entrez votre nouveau mot de passe',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              icon: Icons.lock_reset,
            ),
            const SizedBox(height: 12),
            _buildPasswordStrengthIndicator(),
            const SizedBox(height: 20),
            _buildPasswordCard(
              controller: _confirmPasswordController,
              label: 'Confirmez le nouveau mot de passe',
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icons.lock_clock,
            ),
            const SizedBox(height: 16),
            _buildPasswordRequirements(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Globals.COLOR_MOVIX,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Confirmer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Globals.COLOR_TEXT_GRAY,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildPasswordCard({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required IconData icon,
    String? errorText,
  }) {
    final hasError = errorText != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasError
              ? Globals.COLOR_MOVIX_RED.withOpacity(0.5)
              : Globals.COLOR_TEXT_GRAY.withOpacity(0.1),
          width: 1,
        ),
      ),
      color: Globals.COLOR_SURFACE,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasError
                        ? Globals.COLOR_MOVIX_RED.withOpacity(0.1)
                        : Globals.COLOR_MOVIX.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: hasError ? Globals.COLOR_MOVIX_RED : Globals.COLOR_MOVIX,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: obscure,
                    style: TextStyle(
                      color: Globals.COLOR_TEXT_DARK,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: label,
                      hintStyle: TextStyle(
                        color: Globals.COLOR_TEXT_GRAY.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Globals.COLOR_TEXT_GRAY,
                  ),
                  onPressed: onToggle,
                ),
              ],
            ),
            if (hasError) ...[
              Padding(
                padding: const EdgeInsets.only(left: 48, bottom: 8),
                child: Text(
                  errorText,
                  style: TextStyle(
                    color: Globals.COLOR_MOVIX_RED,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordStrength == PasswordStrength.none) {
      return const SizedBox.shrink();
    }

    Color strengthColor;
    String strengthText;
    double strengthValue;

    switch (_passwordStrength) {
      case PasswordStrength.weak:
        strengthColor = Globals.COLOR_MOVIX_RED;
        strengthText = 'Faible';
        strengthValue = 0.33;
        break;
      case PasswordStrength.medium:
        strengthColor = Colors.orange;
        strengthText = 'Moyen';
        strengthValue = 0.66;
        break;
      case PasswordStrength.strong:
        strengthColor = Globals.COLOR_MOVIX_GREEN;
        strengthText = 'Fort';
        strengthValue = 1.0;
        break;
      case PasswordStrength.none:
        return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Globals.COLOR_SURFACE,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Force du mot de passe',
                  style: TextStyle(
                    color: Globals.COLOR_TEXT_GRAY,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: strengthColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    strengthText,
                    style: TextStyle(
                      color: strengthColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: strengthValue,
                backgroundColor: Globals.COLOR_TEXT_GRAY.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _newPasswordController.text;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exigences du mot de passe',
              style: TextStyle(
                color: Globals.COLOR_TEXT_DARK,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildRequirementRow('Au moins 8 caractères', password.length >= 8),
            _buildRequirementRow('Une lettre majuscule', password.contains(RegExp(r'[A-Z]'))),
            _buildRequirementRow('Une lettre minuscule', password.contains(RegExp(r'[a-z]'))),
            _buildRequirementRow('Un chiffre', password.contains(RegExp(r'[0-9]'))),
            _buildRequirementRow('Un caractère spécial', password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Globals.COLOR_MOVIX_GREEN : Globals.COLOR_TEXT_GRAY.withOpacity(0.5),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Globals.COLOR_TEXT_DARK : Globals.COLOR_TEXT_GRAY,
              fontSize: 13,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
}
