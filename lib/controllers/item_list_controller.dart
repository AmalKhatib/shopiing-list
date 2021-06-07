import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/controllers/auth_controllers.dart';
import 'package:shopping_list_app/models/item_model.dart';
import 'package:shopping_list_app/repositories/custom_exception.dart';
import 'package:shopping_list_app/repositories/item_repository.dart';

final itemListControllerProvider =
    StateNotifierProvider<ItemListController, AsyncValue<List<Item>>>((ref) {
  final user = ref.watch(authControllerProvider);
  return ItemListController(ref.read, user?.uid);
});

final itemListExceptionProvider = StateProvider<CustomException?>((_) => null);

class ItemListController extends StateNotifier<AsyncValue<List<Item>>> {
  final Reader _reader;
  final String? userId;

  ItemListController(this._reader, this.userId) : super(AsyncValue.loading()){
    if(userId != null)
      retrieveItems();
  }

  Future<void> retrieveItems({bool isRefreshing = false}) async {
    if (isRefreshing) state = AsyncValue.loading();
    try {
      final items =
          await _reader(itemRepositoryProvider).retrieveItems(userId: userId);
      if (mounted) state = AsyncValue.data(items);
    } on CustomException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem({required String name, bool obtained = false}) async {
    try {
      var item = Item(name: name, obtained: obtained);
      final itemId = await _reader(itemRepositoryProvider)
          .createItem(userId: userId, item: item);
      item = Item(id: itemId, name: name, obtained: obtained);

      state.whenData((items) { state = AsyncValue.data(items..add(item));});
    } on CustomException catch (e) {
      _reader(itemListExceptionProvider).state = e;
    }
  }

  Future<void> updateItem({required Item updatedItem}) async {
    try {
      await _reader(itemRepositoryProvider)
          .updateItem(userId: userId, item: updatedItem);
      state.whenData((items) {
        state = AsyncValue.data(
        [
          for (final item in items)
            if (item.id == updatedItem.id) updatedItem else
              item,
        ]
        );
      });
    } on CustomException catch (e) {
      _reader(itemListExceptionProvider).state = e;
    }
  }

  Future<void> deleteItem({required String itemId}) async {
    try {
      await _reader(itemRepositoryProvider).deleteItem(userId: userId, itemId: itemId);
      state.whenData((items) => state = AsyncValue.data(items..removeWhere((item) => item.id == itemId)));
    } on CustomException catch (e) {
      _reader(itemListExceptionProvider).state = e;
    }
  }
}
