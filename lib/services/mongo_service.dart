import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  MongoService._internal();
  static final MongoService instance = MongoService._internal();

  Db? _db;

  Db get db => _db!;

  Future<void> init({String? connectionString, String? dbName}) async {
    final conn = connectionString ?? 'mongodb://127.0.0.1:27017';
    final name = dbName ?? 'cuadernoprofe';
    _db = await Db.create('$conn/$name');
    await _db!.open();
  }

  DbCollection collection(String name) {
    return db.collection(name);
  }
}
