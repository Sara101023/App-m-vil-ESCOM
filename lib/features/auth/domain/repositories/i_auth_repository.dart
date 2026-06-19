import '../entities/admin_entity.dart';

abstract class IAuthRepository {
  Future<AdminEntity?> login(String username, String password);
}