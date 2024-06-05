import 'dart:async';

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
  final int? collectionId;

  const Links({super.key, this.collectionId});

  @override
  State<Links> createState() => _LinksState();
}

class _LinksState extends State<Links> {
  final formKey = GlobalKey<ShadFormState>();

  Future<List<Link>> fetchData() async {
    final user = context.get<Signal<User?>>();

    if (widget.collectionId != null) {
      return await linksListFilterCollectionId(
          user.value!.token, widget.collectionId!);
    }

    return await linksList(user.value!.token);
  }

  String collectionsSearch = "";
  Map<String, String> collections = {};
  Map<String, String> get filteredCollections => {
        for (final collection in collections.entries)
          if (collection.value
              .toLowerCase()
              .contains(collectionsSearch.toLowerCase()))
            collection.key: collection.value
      };

  Future<void> loadCollections() async {
    final user = context.get<Signal<User?>>();
    final collectionsResponse = await collectionsList(user.value!.token);

    setState(() {
      collections = {
        for (final collection in collectionsResponse)
          collection.id.toString(): collection.title
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.get<Signal<User?>>();

    String newLinkTitle = "";
    String newLinkDescription = "";
    String newLinkUrl = "";
    bool newLinkPublished = false;
    int? newLinkCollectionId;

    String editingLinkTitle = "";
    String editingLinkDescription = "";
    String editingLinkUrl = "";
    bool editingLinkPublished = false;
    int? editingLinkCollectionId;

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

    Future<void> updateLink(int id) async {
      if (!formKey.currentState!.saveAndValidate()) {
        return;
      }

      await linksUpdate(
          user.value?.token as String,
          id,
          editingLinkTitle,
          editingLinkDescription,
          editingLinkUrl,
          editingLinkPublished,
          editingLinkCollectionId);

      if (mounted) {
        Navigator.of(context).pop(false);
        setState(() {});
      }
    }

    Future<void> deleteLink(int id) async {
      await linksDelete(context.get<Signal<User?>>().value!.token, id);

      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(
            title: Text('Link eliminado.'),
            description: Text('El link ha sido eliminado correctamente.'),
          ),
        );

        Navigator.of(context).pop(false);
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
                onTap: () async {
                  setState(() {
                    newLinkCollectionId = widget.collectionId;
                  });

                  await loadCollections();

                  showShadDialog(
                    context: context,
                    builder: (context) => ShadDialog(
                      title:
                          const Text(textAlign: TextAlign.left, 'Nuevo link'),
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          child: ShadSwitchFormField(
                                            id: 'published',
                                            label: const Text('Publicado'),
                                            initialValue: newLinkPublished,
                                            onChanged: (value) => setState(() {
                                              newLinkPublished = value;
                                            }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4, bottom: 4, top: 8),
                                          child: Text(
                                            'Colección',
                                            style: ShadTheme.of(context)
                                                .textTheme
                                                .small,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ShadSelect<String>.withSearch(
                                    minWidth: 350,
                                    placeholder: const Text(
                                        'Selecciona una colección...'),
                                    onSearchChanged: (value) => setState(
                                        () => collectionsSearch = value),
                                    searchPlaceholder:
                                        const Text('Buscar colección'),
                                    initialValue:
                                        newLinkCollectionId.toString(),
                                    options: [
                                      const ShadOption(
                                          value: "-1",
                                          child: Text("Sin colección")),
                                      ...collections.entries.map(
                                        (collection) {
                                          return Offstage(
                                            offstage: !filteredCollections
                                                .containsKey(collection.key),
                                            child: ShadOption(
                                              value: collection.key,
                                              child: Text(collection.value),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                    selectedOptionBuilder: (context, value) =>
                                        Text(collections[value] ??
                                            "Sin colección"),
                                    onChanged: (value) => setState(() {
                                      newLinkCollectionId = int.parse(value);
                                    }),
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
                  );
                },
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
                  onLongPress: () async {
                    await loadCollections();

                    editingLinkTitle = link.title;
                    editingLinkDescription = link.description;
                    editingLinkUrl = link.url;
                    editingLinkPublished = link.published;
                    editingLinkCollectionId =
                        link.collectionId == null ? -1 : link.collectionId!;

                    showShadDialog(
                      context: context,
                      builder: (context) => ShadDialog(
                        title: const Text(
                            textAlign: TextAlign.left, 'Editar link'),
                        description: const Text(
                            textAlign: TextAlign.left,
                            "Aqui puedes editar el link o borrarlo."),
                        content: Container(
                          width: 375,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            // mainAxisSize: MainAxisSize.min,
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ShadForm(
                                key: formKey,
                                child: Column(
                                  children: [
                                    ShadInputFormField(
                                      id: 'title',
                                      label: const Text('Titulo'),
                                      initialValue: link.title,
                                      onChanged: (value) => setState(() {
                                        editingLinkTitle = value;
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
                                      initialValue: link.description,
                                      onChanged: (value) => setState(() {
                                        editingLinkDescription = value;
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
                                      initialValue: link.url,
                                      onChanged: (value) => setState(() {
                                        editingLinkUrl = value;
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 2),
                                            child: ShadSwitchFormField(
                                              id: 'published',
                                              label: const Text('Publicado'),
                                              initialValue:
                                                  editingLinkPublished,
                                              onChanged: (value) =>
                                                  setState(() {
                                                editingLinkPublished = value;
                                              }),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4, bottom: 4, top: 8),
                                            child: Text(
                                              'Colección',
                                              style: ShadTheme.of(context)
                                                  .textTheme
                                                  .small,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ShadSelect<String>.withSearch(
                                      minWidth: 350,
                                      placeholder: const Text(
                                          'Selecciona una colección...'),
                                      onSearchChanged: (value) => setState(
                                          () => collectionsSearch = value),
                                      searchPlaceholder:
                                          const Text('Buscar colección'),
                                      initialValue:
                                          editingLinkCollectionId.toString(),
                                      options: [
                                        const ShadOption(
                                            value: "-1",
                                            child: Text("Sin colección")),
                                        ...collections.entries.map(
                                          (collection) {
                                            return Offstage(
                                              offstage: !filteredCollections
                                                  .containsKey(collection.key),
                                              child: ShadOption(
                                                value: collection.key,
                                                child: Text(collection.value),
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                      selectedOptionBuilder: (context, value) =>
                                          Text(collections[value] ??
                                              "Sin colección"),
                                      onChanged: (value) => setState(() {
                                        editingLinkCollectionId =
                                            int.parse(value);
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          ShadButton(
                            text: const Text('Guardar'),
                            onPressed: () => updateLink(link.id),
                          ),
                          ShadButton.destructive(
                            text: const Text("Borrar"),
                            onPressed: () => showShadDialog(
                              context: context,
                              builder: (context) => ShadDialog.alert(
                                title: const Text(
                                  '¿Estas seguro?',
                                  textAlign: TextAlign.left,
                                ),
                                description: const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'Esta acción es irreversible. ¿Estás seguro de que quieres eliminar este link?',
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                actions: [
                                  ShadButton.destructive(
                                    text: const Text('Eliminar'),
                                    onPressed: () => deleteLink(link.id),
                                  ),
                                  ShadButton.ghost(
                                    text: const Text('Cancelar'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
