import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:trackermobile/services/auth/sign_in_auth.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final companyEmailProvider = StateProvider<String?>((ref) => null);

// Company ID
// final companyIdProvider = StateProvider<String?>((ref) => null);

final signInControllerProvider =
    StateNotifierProvider<SignInController, AsyncValue<User?>>((ref) {
      final repo = ref.read(authRepositoryProvider);
      return SignInController(repo);
    });

class SignInController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repo;

  SignInController(this._repo) : super(const AsyncData(null));

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
