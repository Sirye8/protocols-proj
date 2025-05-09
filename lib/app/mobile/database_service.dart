import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService{
  // Create database reference with both app and URL
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instanceFor(
      app: Firebase.app(), // Required app parameter
      databaseURL: 'https://protocolsproj-default-rtdb.europe-west1.firebasedatabase.app/'
  );

  // Create
  Future<void> create({
    required String path,
    required Map<String, dynamic> data,
  }) async{
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.set(data);
  }

  // Multi Create
  Future<void> multiCreate(Map<String, dynamic> userInfo) async {
    try {
      await _firebaseDatabase.ref().update(userInfo);
    } catch (e) {
      throw Exception('Multi-create failed: $e');
    }
  }

  // Read
  Future<DataSnapshot?> read({required String path}) async{
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    final DataSnapshot snapshot = await ref.get();
    return snapshot.exists ? snapshot : null;
  }

  // Update
  Future<void> update({
    required String path,
    required Map<String, dynamic> data,
  }) async{
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.update(data);
  }

  //Delete
  Future<void> delete({required String path}) async{
    final DatabaseReference ref = _firebaseDatabase.ref().child(path);
    await ref.remove();
  }
}