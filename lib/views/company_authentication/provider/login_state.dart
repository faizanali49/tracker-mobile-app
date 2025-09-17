import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:trackermobile/views/company_authentication/provider/login_auth.dart';

final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<User?>>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LoginController(repo);
});

class LoginController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repo;

  LoginController(this._repo) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _repo.signInCompany(email: email, password: password);
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
