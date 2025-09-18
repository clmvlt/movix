import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/login.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Globals.darkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: Globals.COLOR_BACKGROUND,
          appBar: AppBar(
            backgroundColor: Globals.COLOR_MOVIX,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 32,
                  width: 32,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Text(
                  "Page d'Accueil",
                  style: TextStyle(color: Globals.COLOR_TEXT_LIGHT),
                ),
              ],
            ),
            toolbarTextStyle: Globals.appBarTextStyle,
            titleTextStyle: Globals.appBarTextStyle,
            actions: [
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.more_vert, color: Globals.COLOR_TEXT_LIGHT, size: 20),
                ),
                color: Globals.COLOR_SURFACE,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                offset: const Offset(0, 8),
                onSelected: (value) {
                  if (value == 'deconnexion') {
                    logout().then((out) {
                      if (out) {
                        if (context.mounted) {
                          context.go('/login');
                        }
                        Globals.showSnackbar("Vous êtes déconnecté");
                      } else {
                        Globals.showSnackbar("Une erreur s'est produite.",
                            backgroundColor: Globals.COLOR_MOVIX_RED);
                      }
                    });
                  }
                  if (value == 'settings') context.push('/settings');
                  if (value == 'spooler') context.push('/spooler');
                  if (value == 'update') context.push('/update');
                  if (value == 'test') context.push('/test');
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Globals.COLOR_MOVIX.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.settings,
                              color: Globals.COLOR_MOVIX,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Paramètres',
                                  style: TextStyle(
                                    color: Globals.COLOR_TEXT_DARK,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Configuration de l\'app',
                                  style: TextStyle(
                                    color: Globals.COLOR_TEXT_SECONDARY,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'spooler',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Globals.COLOR_MOVIX_YELLOW.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.list_alt,
                              color: Globals.COLOR_MOVIX_YELLOW,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Voir le spooler',
                                  style: TextStyle(
                                    color: Globals.COLOR_TEXT_DARK,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Actions en attente',
                                  style: TextStyle(
                                    color: Globals.COLOR_TEXT_SECONDARY,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'update',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Globals.COLOR_MOVIX_GREEN.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.system_update,
                              color: Globals.COLOR_MOVIX_GREEN,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mise à jour',
                                  style: TextStyle(
                                    color: Globals.COLOR_TEXT_DARK,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Vérifier les mises à jour',
                                  style: TextStyle(
                                    color: Globals.COLOR_TEXT_SECONDARY,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (kDebugMode)
                    PopupMenuItem<String>(
                      value: 'test',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.deblur_rounded,
                                color: Colors.purple,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Page de test',
                                    style: TextStyle(
                                      color: Globals.COLOR_TEXT_DARK,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Mode développeur',
                                    style: TextStyle(
                                      color: Globals.COLOR_TEXT_SECONDARY,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Séparateur visuel
                  PopupMenuItem<String>(
                    height: 1,
                    enabled: false,
                    child: Container(
                      height: 1,
                      color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'deconnexion',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Globals.COLOR_MOVIX_RED.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.logout,
                              color: Globals.COLOR_MOVIX_RED,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Déconnexion',
                                  style: TextStyle(
                                    color: Globals.COLOR_MOVIX_RED,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Se déconnecter de l\'app',
                                  style: TextStyle(
                                    color: Globals.COLOR_TEXT_SECONDARY,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 32),
                _buildSectionHeader('Mes outils'),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildModernButtonGrid(context),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    final profil = Globals.profil;
    if (profil == null) return const SizedBox.shrink();

    final hour = DateTime.now().hour;
    String greeting = 'Bonsoir';
    IconData greetingIcon = Icons.nights_stay;
    
    if (hour >= 5 && hour < 12) {
      greeting = 'Bonjour';
      greetingIcon = Icons.wb_sunny;
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Bon après-midi';
      greetingIcon = Icons.wb_sunny_outlined;
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Globals.COLOR_MOVIX,
            Globals.COLOR_MOVIX.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Globals.COLOR_MOVIX.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              greetingIcon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${profil.firstName} ${profil.lastName}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profil.account.societe,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Globals.COLOR_MOVIX,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Globals.COLOR_TEXT_DARK,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButtonGrid(BuildContext context) {
    final buttons = <Widget>[];
    
    // Bouton Tournées (toujours affiché)
    buttons.add(_buildModernButton(
      context: context,
      title: 'Tournées',
      subtitle: 'Gérer les livraisons',
      icon: Icons.local_shipping,
      iconPath: 'assets/images/chargement.png',
      color: Globals.COLOR_MOVIX,
      onPressed: () => context.go('/tours'),
    ));

    // Bouton Pharmacies (si pas web)
    if (Globals.profil?.isWeb ?? false) {
      buttons.add(_buildModernButton(
        context: context,
        title: 'Pharmacies',
        subtitle: 'Rechercher & consulter',
        icon: Icons.local_pharmacy,
        color: Globals.COLOR_MOVIX_GREEN,
        onPressed: () => context.push('/pharmacies'),
      ));
    }

    // Bouton Avtrans (si autorisé)
    if (Globals.profil?.isAvtrans ?? false) {
      buttons.add(_buildModernButton(
        context: context,
        title: 'AVTRANS',
        subtitle: 'Accès pointage',
        icon: Icons.web,
        iconPath: 'assets/images/av_logo.png',
        color: Globals.COLOR_AVTRANS,
        onPressed: () async {
          final token = Globals.profil?.token;
          final url = 'https://avtrans-concept.com/admin/log/$token';
          final uri = Uri.parse(url);

          try {
            // Essayer directement de lancer l'URL sans vérifier canLaunchUrl
            // car sur certains Android, canLaunchUrl retourne false même avec un navigateur installé
            bool launched = false;

            // Essayer d'abord avec le mode externe (ouvre dans le navigateur par défaut)
            try {
              launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (launched) {
                debugPrint('URL lancée avec succès en mode externe');
                return;
              }
            } catch (e) {
              debugPrint('Échec du mode externalApplication: $e');
            }

            // Si ça échoue, essayer avec platformDefault
            if (!launched) {
              try {
                launched = await launchUrl(
                  uri,
                  mode: LaunchMode.platformDefault,
                );
                if (launched) {
                  debugPrint('URL lancée avec succès en mode platformDefault');
                  return;
                }
              } catch (e) {
                debugPrint('Échec du mode platformDefault: $e');
              }
            }

            // En dernier recours, essayer avec le navigateur in-app
            if (!launched) {
              try {
                launched = await launchUrl(
                  uri,
                  mode: LaunchMode.inAppWebView,
                  webViewConfiguration: const WebViewConfiguration(
                    enableJavaScript: true,
                    enableDomStorage: true,
                  ),
                );
                if (launched) {
                  debugPrint('URL lancée avec succès en mode inAppWebView');
                  return;
                }
              } catch (e) {
                debugPrint('Échec du mode inAppWebView: $e');
              }
            }

            // Si tous les modes échouent, afficher un message d'erreur détaillé
            if (!launched) {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Globals.COLOR_SURFACE,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.warning_amber_outlined, color: Globals.COLOR_MOVIX_YELLOW),
                      const SizedBox(width: 8),
                      Text('Impossible d\'ouvrir le lien', style: TextStyle(color: Globals.COLOR_TEXT_DARK)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Le lien n\'a pas pu être ouvert automatiquement.',
                        style: TextStyle(color: Globals.COLOR_TEXT_DARK),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'URL:',
                        style: TextStyle(color: Globals.COLOR_TEXT_DARK_SECONDARY, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        url,
                        style: TextStyle(color: Globals.COLOR_MOVIX, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vous pouvez copier cette URL et l\'ouvrir manuellement dans votre navigateur.',
                        style: TextStyle(color: Globals.COLOR_TEXT_DARK_SECONDARY, fontSize: 12),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK', style: TextStyle(color: Globals.COLOR_MOVIX)),
                    ),
                  ],
                ),
              );
            }
          } catch (e) {
            // Gestion d'erreur générale
            debugPrint('Erreur lors du lancement de l\'URL: $e');
            Globals.showSnackbar(
              "Erreur lors de l'ouverture du navigateur: ${e.toString()}",
              backgroundColor: Globals.COLOR_MOVIX_RED,
              icon: Icons.error_outline,
            );
          }
        },
      ));
    }

    // Bouton Inventaire (si autorisé)
    if (Globals.profil?.isStock ?? false) {
      buttons.add(_buildModernButton(
        context: context,
        title: 'Inventaire',
        subtitle: 'Gestion du stock',
        icon: Icons.inventory,
        iconPath: 'assets/images/inventaire.png',
        color: Globals.COLOR_MOVIX_YELLOW,
        onPressed: () {
          debugPrint(Globals.profil?.isStock.toString());
        },
      ));
    }

    // Bouton Paramètres (toujours affiché)
    buttons.add(_buildModernButton(
      context: context,
      title: 'Paramètres',
      subtitle: 'Configuration',
      icon: Icons.settings,
      iconPath: 'assets/images/settings.png',
      color: Globals.COLOR_TEXT_SECONDARY,
      onPressed: () => context.push('/settings'),
    ));

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: buttons,
    );
  }

  Widget _buildModernButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    IconData? icon,
    String? iconPath,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Globals.COLOR_SURFACE,
              Globals.COLOR_SURFACE.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(24),
            splashColor: color.withOpacity(0.1),
            highlightColor: color.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.15),
                          color.withOpacity(0.08),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: iconPath != null
                        ? Padding(
                            padding: const EdgeInsets.all(14),
                            child: Image.asset(
                              iconPath,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(
                            icon,
                            size: 36,
                            color: color,
                          ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Globals.COLOR_TEXT_DARK,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Globals.COLOR_TEXT_SECONDARY,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
