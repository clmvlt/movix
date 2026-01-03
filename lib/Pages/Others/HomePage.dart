import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Services/login.dart';
import 'package:movix/Services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Check initial au lancement de la HomePage
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkAndShowUpdateDialog(context);
    });
  }

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
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Globals.COLOR_SURFACE,
                elevation: 8,
                onSelected: (value) {
                  switch (value) {
                    case 'settings':
                      context.push('/settings');
                      break;
                    case 'spooler':
                      context.push('/spooler');
                      break;
                    case 'update':
                      context.push('/update');
                      break;
                    case 'test':
                      context.push('/test');
                      break;
                    case 'logout':
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
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'settings',
                    padding: EdgeInsets.zero,
                    child: _buildPopupMenuItem(
                      icon: Icons.settings,
                      iconColor: Globals.COLOR_ADAPTIVE_ACCENT,
                      title: 'Paramètres',
                      subtitle: 'Configuration de l\'app',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'spooler',
                    padding: EdgeInsets.zero,
                    child: _buildPopupMenuItem(
                      icon: Icons.list_alt,
                      iconColor: Globals.COLOR_MOVIX_YELLOW,
                      title: 'Voir le spooler',
                      subtitle: 'Actions en attente',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'update',
                    padding: EdgeInsets.zero,
                    child: _buildPopupMenuItem(
                      icon: Icons.system_update,
                      iconColor: Globals.COLOR_MOVIX_GREEN,
                      title: 'Mise à jour',
                      subtitle: 'Vérifier les mises à jour',
                    ),
                  ),
                  if (kDebugMode)
                    PopupMenuItem<String>(
                      value: 'test',
                      padding: EdgeInsets.zero,
                      child: _buildPopupMenuItem(
                        icon: Icons.deblur_rounded,
                        iconColor: Colors.purple,
                        title: 'Page de test',
                        subtitle: 'Mode développeur',
                      ),
                    ),
                  const PopupMenuDivider(height: 1),
                  PopupMenuItem<String>(
                    value: 'logout',
                    padding: EdgeInsets.zero,
                    child: _buildPopupMenuItem(
                      icon: Icons.logout,
                      iconColor: Globals.COLOR_MOVIX_RED,
                      title: 'Déconnexion',
                      subtitle: 'Se déconnecter de l\'app',
                      titleColor: Globals.COLOR_MOVIX_RED,
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.more_vert, color: Globals.COLOR_TEXT_LIGHT, size: 20),
                ),
              ),
              ),
            ],
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildWelcomeCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(child: _buildQuickAccessGrid()),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopupMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? titleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor ?? Globals.COLOR_TEXT_DARK,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Globals.COLOR_TEXT_SECONDARY,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final profil = Globals.profil;
    if (profil == null) return const SizedBox.shrink();

    final hour = DateTime.now().hour;
    final isBirthday = profil.isBirthday();
    String greeting = 'Bonsoir';
    IconData greetingIcon = Icons.nightlight_round;

    if (isBirthday) {
      greeting = 'Joyeux anniversaire';
      greetingIcon = Icons.cake_outlined;
    } else if (hour >= 5 && hour < 12) {
      greeting = 'Bonjour';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Bon après-midi';
      greetingIcon = Icons.wb_sunny_outlined;
    }

    final hasProfilPicture = profil.profilPicture.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBirthday
              ? const Color(0xFFFFD700).withOpacity(0.5)
              : Globals.COLOR_MOVIX.withOpacity(0.1),
          width: isBirthday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isBirthday
                ? const Color(0xFFFFD700).withOpacity(0.15)
                : Globals.COLOR_MOVIX.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await context.push('/profile');
              if (mounted) setState(() {});
            },
            child: Hero(
              tag: 'profile_picture',
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.15),
                      Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(
                    color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: hasProfilPicture
                      ? Image.network(
                          '${Globals.API_URL}/${profil.profilPicture.replaceAll('\\', '/').replaceFirst(RegExp(r'^/+'), '')}',
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person_outline_rounded,
                            size: 36,
                            color: Globals.COLOR_ADAPTIVE_ACCENT,
                          ),
                        )
                      : Icon(
                          Icons.person_outline_rounded,
                          size: 36,
                          color: Globals.COLOR_ADAPTIVE_ACCENT,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      greetingIcon,
                      size: 16,
                      color: isBirthday
                          ? const Color(0xFFFFD700)
                          : Globals.COLOR_TEXT_SECONDARY,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      greeting,
                      style: TextStyle(
                        color: isBirthday
                            ? const Color(0xFFFFD700)
                            : Globals.COLOR_TEXT_SECONDARY,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isBirthday) ...[
                      const SizedBox(width: 6),
                      const Text('🎂', style: TextStyle(fontSize: 14)),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "${profil.firstName} ${profil.lastName}",
                  style: TextStyle(
                    color: Globals.COLOR_TEXT_DARK,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Globals.COLOR_ADAPTIVE_ACCENT.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    profil.account.societe,
                    style: TextStyle(
                      color: Globals.COLOR_ADAPTIVE_ACCENT,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final buttons = <Map<String, dynamic>>[];

    // Bouton Tournées (toujours affiché)
    buttons.add({
      'title': 'Tournées',
      'subtitle': 'Gérer les livraisons',
      'icon': Icons.local_shipping_outlined,
      'color': Globals.COLOR_ADAPTIVE_ACCENT,
      'onPressed': () => context.go('/tours'),
    });

    // Bouton Pharmacies (si isWeb)
    if (Globals.profil?.isWeb ?? false) {
      buttons.add({
        'title': 'Pharmacies',
        'subtitle': 'Rechercher & consulter',
        'icon': Icons.local_pharmacy_outlined,
        'color': Globals.COLOR_MOVIX_GREEN,
        'onPressed': () => context.push('/pharmacies'),
      });
    }

    // Bouton Gérer les tournées (si isWeb OU isAdmin)
    if ((Globals.profil?.isWeb ?? false) || (Globals.profil?.isAdmin ?? false)) {
      buttons.add({
        'title': 'Gérer les tournées',
        'subtitle': 'Consulter par date',
        'icon': Icons.calendar_month_outlined,
        'color': Globals.COLOR_MOVIX_YELLOW,
        'onPressed': () => context.push('/manage-tours'),
      });
    }

    // Bouton Avtrans (si autorisé)
    if (Globals.profil?.isAvtrans ?? false) {
      buttons.add({
        'title': 'AVTRANS',
        'subtitle': 'Accès pointage',
        'icon': Icons.web_outlined,
        'iconPath': 'assets/images/av_logo.png',
        'color': const Color(0xFF1E3A8A), // Bleu foncé du logo AVTRANS
        'onPressed': () async {
          final token = Globals.profil?.token;
          final url = 'https://avtrans-concept.com/admin/log/$token';
          final uri = Uri.parse(url);

          try {
            bool launched = false;

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

            if (!launched) {
              if (!context.mounted) return;
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Globals.COLOR_SURFACE,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.warning_amber_outlined,
                          color: Globals.COLOR_MOVIX_YELLOW),
                      const SizedBox(width: 8),
                      Text('Impossible d\'ouvrir le lien',
                          style: TextStyle(color: Globals.COLOR_TEXT_DARK)),
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
                        style: TextStyle(
                            color: Globals.COLOR_TEXT_DARK_SECONDARY,
                            fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        url,
                        style: TextStyle(color: Globals.COLOR_MOVIX, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vous pouvez copier cette URL et l\'ouvrir manuellement dans votre navigateur.',
                        style: TextStyle(
                            color: Globals.COLOR_TEXT_DARK_SECONDARY,
                            fontSize: 12),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: TextStyle(color: Globals.COLOR_MOVIX)),
                    ),
                  ],
                ),
              );
            }
          } catch (e) {
            debugPrint('Erreur lors du lancement de l\'URL: $e');
            Globals.showSnackbar(
              "Erreur lors de l'ouverture du navigateur: ${e.toString()}",
              backgroundColor: Globals.COLOR_MOVIX_RED,
              icon: Icons.error_outline,
            );
          }
        },
      });
    }

    // Bouton Inventaire (si autorisé)
    if (Globals.profil?.isStock ?? false) {
      buttons.add({
        'title': 'Inventaire',
        'subtitle': 'Gestion du stock',
        'icon': Icons.inventory_2_outlined,
        'iconPath': 'assets/images/inventaire.png',
        'color': Globals.COLOR_MOVIX_YELLOW,
        'onPressed': () {
          debugPrint(Globals.profil?.isStock.toString());
        },
      });
    }

    // Bouton Mon Profil (toujours affiché)
    buttons.add({
      'title': 'Mon Profil',
      'subtitle': 'Modifier mes infos',
      'icon': Icons.person_outline_rounded,
      'color': Globals.COLOR_MOVIX_GREEN,
      'onPressed': () async {
        await context.push('/profile');
        if (mounted) setState(() {});
      },
    });

    // Bouton Paramètres (toujours affiché)
    buttons.add({
      'title': 'Paramètres',
      'subtitle': 'Configuration',
      'icon': Icons.settings_outlined,
      'color': Globals.COLOR_ADAPTIVE_ACCENT,
      'onPressed': () => context.push('/settings'),
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: buttons
            .map((button) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildActionCard(
                    title: button['title'] as String,
                    subtitle: button['subtitle'] as String,
                    icon: button['icon'] as IconData?,
                    iconPath: button['iconPath'] as String?,
                    color: button['color'] as Color,
                    onPressed: button['onPressed'] as VoidCallback,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    IconData? icon,
    String? iconPath,
    required Color color,
    required VoidCallback onPressed,
  }) {
    // Si c'est AVTRANS, on utilise la couleur pleine, sinon l'opacité habituelle
    final isAvtrans = title == 'AVTRANS';
    final backgroundColor = isAvtrans ? color : color.withOpacity(0.1);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Globals.COLOR_SURFACE,
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onPressed,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: iconPath != null
                ? Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Globals.COLOR_TEXT_DARK,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Globals.COLOR_TEXT_GRAY,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Globals.COLOR_TEXT_GRAY,
          size: 20,
        ),
      ),
    );
  }
}
