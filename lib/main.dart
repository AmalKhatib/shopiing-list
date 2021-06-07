import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/controllers/auth_controllers.dart';
import 'package:shopping_list_app/controllers/item_list_controller.dart';
import 'package:shopping_list_app/repositories/custom_exception.dart';

import 'models/item_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    final authController = watch(authControllerProvider.notifier);

    return Scaffold(
      body: ProviderListener(
          provider: itemListExceptionProvider,
          onChange: (BuildContext context,
              StateController<CustomException?> customException) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(customException.state!.message!)));
          },
          child: Container(child: ItemList(),)),
      appBar: AppBar(
          title: Text("Shopping list"),
          leading: authController != null
              ? IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    context.read(authControllerProvider.notifier).signOut();
                  })
              : null),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddItemDialog.show(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ItemList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    final itemListState = watch(itemListControllerProvider);
    return itemListState.when(
      data: (items) => items.isEmpty
          ? Center(
              child: Text("Tap + to add"),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                var item = items[index];
                return ListTile(
                  key: ValueKey(item.id),
                  trailing: Checkbox(
                    value: item.obtained,
                    onChanged: (value) {
                      item = Item(name: item.name, obtained: value!, id: item.id);
                      context.read(itemListControllerProvider.notifier).updateItem(updatedItem: item);
                    }
                  ),
                  onTap: () => AddItemDialog.show(context, item: item,),
                  onLongPress: () => context.read(itemListControllerProvider.notifier).deleteItem(itemId: item.id!),
                );
              }),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, _) => ItemListError(
        message:
            error is CustomException ? error.message! : "Something went wrong",
      ),
    );
  }
}

class ItemListError extends ConsumerWidget {
  final String message;

  ItemListError({required this.message});

  @override
  Widget build(BuildContext context, watch) {
    return Center(
        child: TextButton(
      onPressed: () => context
          .read(itemListControllerProvider.notifier)
          .retrieveItems(isRefreshing: true),
      child: Text("Resfresh!"),
    ));
  }
}

class AddItemDialog extends StatelessWidget {
  static void show(BuildContext context, {Item? item}) {
    showDialog(
        context: context,
        builder: (context) => AddItemDialog(
              item: item,
            ));
  }

  Item? item;

  AddItemDialog({Key? key, this.item});

  bool get isUpdating => item != null;

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    return Dialog(
      child: Column(
        children: [
          TextField(
            controller: textController,
          ),
          TextButton(
              onPressed: () {
                item =
                    Item(id: item?.id, name: textController.value.text.trim());
                isUpdating
                    ? context
                        .read(itemListControllerProvider.notifier)
                        .updateItem(updatedItem: item!)
                    : context
                        .read(itemListControllerProvider.notifier)
                        .addItem(name: textController.text.trim());
                Navigator.of(context).pop();
              },
              child: Text(isUpdating ? "update" : "Add"))
        ],
      ),
    );
  }
}
