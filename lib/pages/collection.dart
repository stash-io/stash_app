import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stash_app/components/links.dart';
import 'package:stash_app/components/scrollable.dart';
import 'package:stash_app/services/collections.dart';
import 'package:stash_app/store.dart';

class CollectionScreen extends StatefulWidget {
  final String? id;
  const CollectionScreen({super.key, this.id});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  Future<Collection> fetchData() async {
    final user = context.get<Signal<User?>>();
    return await collectionsFind(user.value!.token, int.parse(widget.id!));
  }

  @override
  Widget build(BuildContext context) {
    return ScrollScreen(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("loading...");
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShadButton(
                      onPressed: () {
                        context.go('/');
                      },
                      icon: const ShadImage.square(
                          size: 16, LucideIcons.arrowLeft),
                    ),
                    ShadButton.destructive(
                      onPressed: () {
                        showShadDialog(
                          context: context,
                          builder: (context) => ShadDialog.alert(
                            title: const Text(
                              '¿Estas seguro?',
                              textAlign: TextAlign.left,
                            ),
                            description: const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Esta acción es irreversible. ¿Estás seguro de que quieres eliminar esta colección?',
                                textAlign: TextAlign.left,
                              ),
                            ),
                            actions: [
                              ShadButton.ghost(
                                text: const Text('Cancelar'),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              ShadButton.destructive(
                                  text: const Text('Eliminar'),
                                  onPressed: () async {
                                    await collectionsDelete(
                                        context
                                            .get<Signal<User?>>()
                                            .value!
                                            .token,
                                        snapshot.data!.id);

                                    if (mounted) {
                                      ShadToaster.of(context).show(
                                        const ShadToast(
                                          title: const Text(
                                              'Colección eliminada.'),
                                          description: const Text(
                                              'La colección ha sido eliminada correctamente.'),
                                        ),
                                      );

                                      context.go('/');
                                    }
                                  }),
                            ],
                          ),
                        );
                      },
                      icon: const ShadImage.square(size: 16, LucideIcons.trash),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  snapshot.data!.title,
                  style: ShadTheme.of(context).textTheme.h2,
                ),
                const SizedBox(height: 16),
                Text(
                  snapshot.data!.description,
                  style: ShadTheme.of(context).textTheme.p,
                ),
                const SizedBox(height: 16),
                Links(
                  collectionId: snapshot.data!.id,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
