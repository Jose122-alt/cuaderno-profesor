import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  final db = await Db.create('mongodb://localhost:27017/cuaderno');
  await db.open();

  print('Conectado a la base de datos MongoDB.');

  try {
    final collections = await db.getCollectionNames();
    print('Colecciones en la base de datos:');
    for (var collectionName in collections) {
      print('- $collectionName');
    }
  } catch (e) {
    print('Error al obtener las colecciones: $e');
  } finally {
    await db.close();
    print('Conexión a la base de datos cerrada.');
  }
}
