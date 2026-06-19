import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/crypto_helper.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final DatabaseHelper _db;
  const AuthRepositoryImpl(this._db);

  @override
  Future<AdminEntity?> login(String username, String password) async {
    final admin = await _db.getAdmin(username);
    if (admin == null) return null;

    final hashOk = CryptoHelper.verifyPassword(password, admin['password_hash'] as String);
    if (!hashOk) return null;

    return AdminEntity(
      id: admin['id'] as int,
      username: admin['username'] as String,
      nombre: admin['nombre'] as String,
      createdAt: admin['created_at'] as String,
    );
  }
}