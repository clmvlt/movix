import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movix/API/pharmacy_fetcher.dart';
import 'package:movix/Models/Command.dart';
import 'package:movix/Services/globals.dart';
import 'package:movix/Widgets/CustomButton.dart';

class PharmacyInfosPage extends StatefulWidget {
  final Command command;

  const PharmacyInfosPage({super.key, required this.command});

  @override
  _PharmacyInfosPageState createState() => _PharmacyInfosPageState();
}

class _PharmacyInfosPageState extends State<PharmacyInfosPage> {
  late Future<Map<String, dynamic>?> _pharmacyInfo;

  @override
  void initState() {
    super.initState();
    _pharmacyInfo = getPharmacyInfos(widget.command.cip);
  }

  TextSpan parseText(String? text) {
    if (text == null || text.isEmpty) {
      return const TextSpan(
        text: "Aucune information disponible",
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
      );
    }

    final RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
        ));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Globals.COLOR_MOVIX_RED,
        ),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
      ));
    }

    return TextSpan(children: spans);
  }

  void showImageFullscreen(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Center(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarTextStyle: Globals.appBarTextStyle,
        titleTextStyle: Globals.appBarTextStyle,
        title: const Text("Informations"),
        backgroundColor: Globals.COLOR_MOVIX,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _pharmacyInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            final String informations = (data["informations"] as String?) ??
                'Aucune information disponible';
            final List<dynamic>? photos = data["photos"] as List<dynamic>?;

            return Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Instructions",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                RichText(
                                  text: parseText(informations),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (photos != null && photos.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Photos",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...photos.map<Widget>((photo) {
                          final String? imageUrl = photo["path"] as String?;
                          if (imageUrl == null || imageUrl.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return GestureDetector(
                            onTap: () => showImageFullscreen(imageUrl),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[200],
                                      child: const Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0)
                    .copyWith(bottom: 8.0, top: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: customButton(
                      onPressed: () {
                        context.push('/addinfospharmacy',
                            extra: {'command': widget.command});
                      },
                      label: "Ajouter des instructions"),
                ),
              ),
            );
          } else {
            return const Center(child: Text("Aucune donnée disponible"));
          }
        },
      ),
    );
  }
}
