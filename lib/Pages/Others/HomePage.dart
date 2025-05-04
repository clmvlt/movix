import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Services/login.dart';
import 'package:movix/Services/globals.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Page d'Accueil",
        ),
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'deconnexion') {
                logout().then((out) {
                  if (out) {
                    Globals.showSnackbar("Vous êtes déconnecté");
                    context.go('/login');
                  } else {
                    Globals.showSnackbar("Une erreur s'est produite.",
                        backgroundColor: Globals.COLOR_MOVIX_RED);
                  }
                });
              }
              if (value == 'settings') {
                context.push('/settings');
              }
              if (value == 'spooler') {
                context.push('/spooler');
              }
              if (value == 'update') {
                context.push('/update');
              }
              if (value == 'test') {
                context.push('/test');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'deconnexion',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Globals.COLOR_MOVIX),
                      SizedBox(width: 10),
                      Text('Déconnexion'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Globals.COLOR_MOVIX),
                      SizedBox(width: 10),
                      Text('Paramètres'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'update',
                  child: Row(
                    children: [
                      Icon(Icons.system_update, color: Globals.COLOR_MOVIX),
                      SizedBox(width: 10),
                      Text('Mise à jour'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'spooler',
                  child: Row(
                    children: [
                      Icon(Icons.list_alt, color: Globals.COLOR_MOVIX),
                      SizedBox(width: 10),
                      Text('Voir le spooler'),
                    ],
                  ),
                ),
                if (kDebugMode)
                  const PopupMenuItem<String>(
                    value: 'test',
                    child: Row(
                      children: [
                        Icon(Icons.deblur_rounded, color: Globals.COLOR_MOVIX),
                        SizedBox(width: 10),
                        Text('Page de test'),
                      ],
                    ),
                  ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildProfileCard(),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildCustomButton(
                    context,
                    title: 'Tournées',
                    iconPath: 'assets/images/chargement.png',
                    onPressed: () {
                      context.go('/tours');
                    },
                  ),
                  if (Globals.profil?.isStock ?? false)
                    _buildCustomButton(
                      context,
                      title: 'Inventaire',
                      iconPath: 'assets/images/inventaire.png',
                      onPressed: () {
                        debugPrint(Globals.profil?.isStock.toString());
                      },
                    ),
                  if (Globals.profil?.isAVTrans ?? false)
                    _buildCustomButton(
                      context,
                      title: 'Pointage',
                      iconPath: 'assets/images/av_icon.png',
                      onPressed: () async {
                        final token = Globals.profil?.token;
                        final url =
                            'https://avtrans-concept.com/admin/log/$token';

                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final profil = Globals.profil;

    if (profil == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        color: Globals.COLOR_MOVIX,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Globals.COLOR_MOVIX),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${profil.firstName} ${profil.lastName}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profil.email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    ...[
                      const SizedBox(height: 6),
                      Text(
                        profil.societe,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton(
    BuildContext context, {
    required String title,
    String? iconPath,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Image.asset(
                  iconPath,
                  width: 60,
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Globals.COLOR_MOVIX,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
