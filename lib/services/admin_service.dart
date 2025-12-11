import 'mongo_service.dart';
import '../models/admin.dart';

class AdminService {

  Future<int> addAdmin(Admin admin) async {
    final coll = MongoService.instance.collection('admins');
    await coll.insertOne(admin.toMap());
    return 1;
  }

  Future<Admin?> getAdminByAccountNumber(String accountNumber) async {
    final coll = MongoService.instance.collection('admins');
    final doc = await coll.findOne({'accountNumber': accountNumber});
    if (doc == null) return null;
    return Admin.fromMap(Map<String, dynamic>.from(doc));
  }
}
