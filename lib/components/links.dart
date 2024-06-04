import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stash_app/main.dart';
import 'package:stash_app/services/collections.dart';
import 'package:stash_app/services/links.dart';
import 'package:stash_app/store.dart';
import 'package:url_launcher/url_launcher.dart';

class Links extends StatefulWidget {
  const Links({super.key});

  @override
  State<Links> createState() => _LinksState();
}

class _LinksState extends State<Links> {
  final formKey = GlobalKey<ShadFormState>();

  Future<List<Link>> fetchData() async {
    final user = context.get<Signal<User?>>();
    return await linksList(user.value!.token);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.get<Signal<User?>>();

    String newLinkTitle = "";
    String newLinkDescription = "";
    String newLinkUrl = "";
    bool newLinkPublished = false;

    Future<void> createNewLink() async {
      if (!formKey.currentState!.saveAndValidate()) {
        return;
      }

      await linksCreate(user.value?.token as String, newLinkTitle,
          newLinkDescription, newLinkUrl, newLinkPublished);

      if (mounted) {
        Navigator.of(context).pop(false);
        setState(() {});
      }
    }

    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        Widget newLinkDialog() => AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                child: const ShadCard(
                  title: Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShadImage.square(size: 16, LucideIcons.plus)),
                  description: Text("Crear un nuevo link"),
                ),
                onTap: () => showShadDialog(
                  context: context,
                  builder: (context) => ShadDialog(
                    title: const Text(textAlign: TextAlign.left, 'Nuevo link'),
                    description: const Text(
                        textAlign: TextAlign.left,
                        "Introduce los datos de un nuevo link."),
                    content: Container(
                      width: 375,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ShadForm(
                            key: formKey,
                            child: Column(
                              children: [
                                ShadInputFormField(
                                  id: 'title',
                                  label: const Text('Titulo'),
                                  onChanged: (value) => setState(() {
                                    newLinkTitle = value;
                                  }),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Por favor, introduce un título.';
                                    }

                                    return null;
                                  },
                                ),
                                ShadInputFormField(
                                  id: 'description',
                                  label: const Text('Descripción'),
                                  onChanged: (value) => setState(() {
                                    newLinkDescription = value;
                                  }),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Por favor, introduce una descripción.';
                                    }

                                    return null;
                                  },
                                ),
                                ShadInputFormField(
                                  id: 'url',
                                  label: const Text('URL'),
                                  onChanged: (value) => setState(() {
                                    newLinkUrl = value;
                                  }),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Por favor, introduce una URL.';
                                    }

                                    if (!Uri.parse(value).isAbsolute) {
                                      return 'Por favor, introduce una URL válida.';
                                    }

                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ShadButton.ghost(
                        text: const Text('Cerrar'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      ShadButton(
                        text: const Text("Crear"),
                        onPressed: createNewLink,
                      ),
                    ],
                  ),
                ),
              ),
            );

        if (!snapshot.hasData) {
          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [newLinkDialog()],
          );
        }

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            newLinkDialog(),
            ...snapshot.data!.map(
              (link) => AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  onTap: () {
                    final Uri url = Uri.parse(link.url);
                    launchUrl(url);
                  },
                  child: ShadCard(
                    title: Text(link.title),
                    description: Text(link.description),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
