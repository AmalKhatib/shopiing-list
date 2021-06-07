import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/general_providers.dart';
import 'package:shopping_list_app/models/item_model.dart';
import 'package:shopping_list_app/repositories/custom_exception.dart';

final itemRepositoryProvider =
    Provider<ItemRepository>((ref) => ItemRepository(ref.read));

abstract class BaseItemRepository {
  Future<List<Item>> retrieveItems({required String userId});
  Future<String> createItem({required String userId, required Item item});
  Future<void> deleteItem({required String userId, required String itemId});
  Future<void> updateItem({required String userId, required Item item});
}

class ItemRepository implements BaseItemRepository {
  final Reader _reader;

  ItemRepository(this._reader);

  @override
  Future<String> createItem(
      {required String? userId, required Item item}) async {
    try {
      final docRef = await _reader(firebaseFirestoreProvider)
          .collection("users")
          .doc(userId)
          .collection("lists")
          .add(item.toJson());
      return docRef.id;
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> deleteItem(
      {required String? userId, required String itemId}) async {
    try {
      final docRef = await _reader(firebaseFirestoreProvider)
          .collection("users")
          .doc(userId)
          .collection("lists")
          .doc(itemId)
          .delete();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<List<Item>> retrieveItems({required String? userId}) async {
    try {
      final snap = await _reader(firebaseFirestoreProvider)
          .collection("lists")
          .doc(userId)
          .collection("items")
          .get();
      return snap.docs.map((doc) => Item.fromJson(doc.data())).toList();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  @override
  Future<void> updateItem({required String? userId, required Item item}) async {
    try {
      final docRef = await _reader(firebaseFirestoreProvider)
          .collection("users")
          .doc(userId)
          .collection("lists")
          .doc(item.id)
          .update(item.toJson());
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }
}
