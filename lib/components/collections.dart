import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stash_app/main.dart';
import 'package:stash_app/services/collections.dart';
import 'package:stash_app/store.dart';

class Collections extends StatefulWidget {
  const Collections({super.key});

  @override
  State<Collections> createState() => _CollectionsState();
}

class _CollectionsState extends State<Collections> {
  Future<List<Collection>> fetchData() async {
    final user = context.get<Signal<User?>>();
    return await collectionsList(user.value!.token);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.get<Signal<User?>>();

    String newCollectionTitle = "";
    String newCollectionDescription = "";
    bool newCollectionPublished = false;

    Future<void> createNewCollection() async {
      await collectionsCreate(user.value?.token as String, newCollectionTitle,
          newCollectionDescription, newCollectionPublished);

      if (mounted) {
        Navigator.of(context).pop(false);
        setState(() {});
      }
    }

    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  child: const ShadCard(
                    title: Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: ShadImage.square(size: 16, LucideIcons.plus)),
                    description: Text("Crear una nueva colección"),
                  ),
                  onTap: () => showShadDialog(
                    context: context,
                    builder: (context) => ShadDialog(
                      title: const Text(
                          textAlign: TextAlign.left, 'Nueva colección'),
                      description: const Text(
                          textAlign: TextAlign.left,
                          "Introduce los datos de una nueva colección."),
                      content: Container(
                        width: 375,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ShadInputFormField(
                                id: 'title',
                                label: const Text('Titulo'),
                                onChanged: (value) => setState(() {
                                  newCollectionTitle = value;
                                }),
                              ),
                              ShadInputFormField(
                                id: 'description',
                                label: const Text('Descripción'),
                                onChanged: (value) => setState(() {
                                  newCollectionDescription = value;
                                }),
                              ),
                            ]),
                      ),
                      actions: [
                        ShadButton.ghost(
                          text: const Text('Cerrar'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        ShadButton(
                          text: const Text("Crear"),
                          onPressed: createNewCollection,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        }

        return GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                child: const ShadCard(
                  title: Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShadImage.square(size: 16, LucideIcons.plus)),
                  description: Text("Crear una nueva colección"),
                ),
                onTap: () => showShadDialog(
                  context: context,
                  builder: (context) => ShadDialog(
                    title: const Text(
                        textAlign: TextAlign.left, 'Nueva colección'),
                    description: const Text(
                        textAlign: TextAlign.left,
                        "Introduce los datos de una nueva colección."),
                    content: Container(
                      width: 375,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ShadInputFormField(
                              id: 'title',
                              label: const Text('Titulo'),
                              onChanged: (value) => setState(() {
                                newCollectionTitle = value;
                              }),
                            ),
                            ShadInputFormField(
                              id: 'description',
                              label: const Text('Descripción'),
                              onChanged: (value) => setState(() {
                                newCollectionDescription = value;
                              }),
                            ),
                          ]),
                    ),
                    actions: [
                      ShadButton.ghost(
                        text: const Text('Cerrar'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      ShadButton(
                        text: const Text("Crear"),
                        onPressed: createNewCollection,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ...snapshot.data!.map(
              (collection) => AspectRatio(
                aspectRatio: 1,
                child: GestureDetector(
                  onTap: () {
                    context.go('/collection?id=${collection.id}');
                  },
                  child: ShadCard(
                    title: Text(collection.title),
                    description: Text(collection.description),
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
