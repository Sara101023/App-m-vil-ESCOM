import '../entities/admin_entity.dart';
import '../repositories/i_auth_repository.dart';

class LoginAdminUseCase {
  final IAuthRepository repository;

  LoginAdminUseCase(this.repository);

  Future<AdminEntity?> ejecutar(String username, String password) {
    return repository.login(username, password);
  }
}