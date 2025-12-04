import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movix/API/profile_fetcher.dart';
import 'package:movix/Pages/Others/ChangePasswordPage.dart';
import 'package:movix/Pages/Others/ImageCropPage.dart';
import 'package:movix/Services/globals.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _birthdayController;

  String? _newProfilPictureBase64;
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final profil = Globals.profil;
    _firstNameController = TextEditingController(text: profil?.firstName ?? '');
    _lastNameController = TextEditingController(text: profil?.lastName ?? '');
    _emailController = TextEditingController(text: profil?.email ?? '');
    _birthdayController = TextEditingController(text: profil?.birthday ?? '');

    if (profil?.birthday != null && profil!.birthday.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(profil.birthday);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Globals.COLOR_BACKGROUND,
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: Text('Mon Profil', style: TextStyle(color: Globals.COLOR_TEXT_LIGHT)),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Globals.COLOR_TEXT_LIGHT,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _firstNameController,
                label: 'Prenom',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prenom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameController,
                label: 'Nom',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email (optionnel)',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 16),
              _buildChangePasswordButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    final profil = Globals.profil;
    final hasExistingPicture = profil != null && profil.profilPicture.isNotEmpty;

    ImageProvider? imageProvider;
    if (_newProfilPictureBase64 != null) {
      imageProvider = MemoryImage(base64Decode(_newProfilPictureBase64!));
    } else if (hasExistingPicture) {
      imageProvider = NetworkImage('${Globals.API_URL}/${profil.profilPicture.replaceAll('\\', '/').replaceFirst(RegExp(r'^/+'), '')}');
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Globals.COLOR_SURFACE,
              border: Border.all(
                color: Globals.COLOR_MOVIX.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Globals.COLOR_MOVIX.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: imageProvider != null
                  ? Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                  : Icon(
                      Icons.person,
                      size: 60,
                      color: Globals.COLOR_TEXT_GRAY,
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Globals.COLOR_MOVIX,
                  border: Border.all(
                    color: Globals.COLOR_SURFACE,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Globals.COLOR_SURFACE,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Globals.COLOR_TEXT_GRAY.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Text(
                'Choisir une photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Globals.COLOR_TEXT_DARK,
                ),
              ),
              const SizedBox(height: 20),
              _buildImageSourceOption(
                icon: Icons.camera_alt,
                title: 'Prendre une photo',
                onTap: () async {
                  Navigator.pop(context);
                  // Délai pour iOS 18 compatibility
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                  _pickImage(ImageSource.camera);
                },
              ),
              _buildImageSourceOption(
                icon: Icons.photo_library,
                title: 'Choisir dans la galerie',
                onTap: () async {
                  Navigator.pop(context);
                  // Délai pour iOS 18 compatibility
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Globals.COLOR_MOVIX.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Globals.COLOR_MOVIX),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Globals.COLOR_TEXT_DARK,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Globals.COLOR_TEXT_GRAY,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    if (!mounted) return;

    final Uint8List? croppedBytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute<Uint8List>(
        builder: (context) => ImageCropPage(imageFile: File(pickedFile.path)),
      ),
    );

    if (croppedBytes != null) {
      setState(() {
        _newProfilPictureBase64 = base64Encode(croppedBytes);
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: Globals.COLOR_TEXT_DARK,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Globals.COLOR_TEXT_GRAY,
        ),
        prefixIcon: Icon(
          icon,
          color: Globals.COLOR_MOVIX,
        ),
        filled: true,
        fillColor: Globals.COLOR_SURFACE,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Globals.COLOR_TEXT_GRAY.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Globals.COLOR_MOVIX,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Globals.COLOR_MOVIX_RED,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Globals.COLOR_MOVIX_RED,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _birthdayController,
          style: TextStyle(
            color: Globals.COLOR_TEXT_DARK,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: 'Date de naissance',
            labelStyle: TextStyle(
              color: Globals.COLOR_TEXT_GRAY,
            ),
            prefixIcon: Icon(
              Icons.cake_outlined,
              color: Globals.COLOR_MOVIX,
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: Globals.COLOR_TEXT_GRAY,
            ),
            filled: true,
            fillColor: Globals.COLOR_SURFACE,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Globals.COLOR_TEXT_GRAY.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Globals.COLOR_MOVIX,
              onPrimary: Colors.white,
              surface: Globals.COLOR_SURFACE,
              onSurface: Globals.COLOR_TEXT_DARK,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Globals.COLOR_MOVIX,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Enregistrer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await updateProfil(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      birthday: _birthdayController.text,
      email: _emailController.text,
      profilPicture: _newProfilPictureBase64,
    );

    setState(() => _isLoading = false);

    if (result.profil != null) {
      Globals.profil = result.profil;
      if (mounted) {
        Globals.showSnackbar(
          'Profil mis a jour avec succes',
          backgroundColor: Globals.COLOR_MOVIX_GREEN,
          icon: Icons.check_circle,
        );
        Navigator.pop(context);
      }
    } else {
      Globals.showSnackbar(
        result.error ?? 'Erreur inconnue',
        backgroundColor: Globals.COLOR_MOVIX_RED,
        icon: Icons.error_outline,
      );
    }
  }

  Widget _buildChangePasswordButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const ChangePasswordPage(),
            ),
          );
        },
        icon: const Icon(Icons.lock_outline),
        label: const Text(
          'Changer le mot de passe',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Globals.COLOR_MOVIX,
          side: BorderSide(
            color: Globals.COLOR_MOVIX.withOpacity(0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
