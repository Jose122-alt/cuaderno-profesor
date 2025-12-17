import 'package:mongo_dart/mongo_dart.dart';
import '../lib/services/mongo_service.dart';

void main() async {
  await MongoService.instance.init(connectionString: 'mongodb://localhost:27017', dbName: 'cuaderno');

  print('Conectado a la base de datos MongoDB.');

  // --- Cleanup existing data ---
  print('Limpiando colecciones existentes...');
  await MongoService.instance.collection('students').remove({});
  print('Colección students limpiada.');
  await MongoService.instance.collection('teachers').remove({});
  print('Colección teachers limpiada.');
  await MongoService.instance.collection('courses').remove({});
  print('Colección courses limpiada.');
  await MongoService.instance.collection('enrollments').remove({});
  print('Colección enrollments limpiada.');
  await MongoService.instance.collection('activities').remove({});
  print('Colección activities limpiada.');
  await MongoService.instance.collection('evaluations').remove({});
  print('Colección evaluations limpiada.');
  await MongoService.instance.collection('attendanceRecords').remove({});
  print('Colección attendanceRecords limpiada.');
  await MongoService.instance.collection('evidences').remove({});
  print('Colección evidences limpiada.');
  print('Todas las colecciones han sido limpiadas.');

  await MongoService.instance.db.close();
  print('Conexión a la base de datos cerrada.');
}
