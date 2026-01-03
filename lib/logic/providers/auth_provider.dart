import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../data/services/api_service.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/api_constants.dart';

final flutterSecureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final dioProvider = Provider((ref) => Dio());

final apiServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(flutterSecureStorageProvider);
  return ApiService(dio, storage);
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(apiServiceProvider), ref.watch(flutterSecureStorageProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._apiService, this._storage) : super(const AsyncValue.data(null)) {
    // Disabled auto-login - app always starts at login screen
    // _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        state = const AsyncValue.data(null);
        return;
      }

      // Verify token/get user me
      final response = await _apiService.get(ApiConstants.me);
      // The API response for /me returns { success: true, data: { ... } }
      // But the User model expects flattened or structured data.
      // Let's adjust based on backend response: { success: true, data: { _id, email, role, ... } }
      // The User model constructor expects a token, which /me doesn't return.
      
      final userData = response.data['data'];
      // We need to inject the token back into the user model or manage it separately.
      // For now, let's just reconstruct the User object.
      
      final user = User(
          id: userData['_id'],
          email: userData['email'],
          role: userData['role'],
          token: token
      );
      
      state = AsyncValue.data(user);
    } catch (e) {
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      // Backend: { success: true, _id, email, role, token }
      // Note: Backend login response structure in auth.controller.js:
      // { success: true, _id: ..., email: ..., role: ..., token: ... }
      
      // My User.fromJson expects keys: _id, email, role, token
      // This matches perfectly.
      
      final user = User.fromJson(data);
      
      await _storage.write(key: 'jwt_token', value: user.token);
      await _storage.write(key: 'user_role', value: user.role);

      state = AsyncValue.data(user);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final message = e.response?.data['message'] ?? e.message;
        state = AsyncValue.error(message, StackTrace.current);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> register(String email, String password, String role) async {
      state = const AsyncValue.loading();
      try {
          final response = await _apiService.post(ApiConstants.register, data: {
              'email': email,
              'password': password,
              'role': role
          });
          
          final data = response.data;
          final user = User.fromJson(data);
          
          await _storage.write(key: 'jwt_token', value: user.token);
          await _storage.write(key: 'user_role', value: user.role);
          
          state = AsyncValue.data(user);
      } catch (e) {
        if (e is DioException && e.response?.data != null) {
          final message = e.response?.data['message'] ?? e.message;
          state = AsyncValue.error(message, StackTrace.current);
        } else {
          state = AsyncValue.error(e, StackTrace.current);
        }
      }
  }

  Future<void> registerCompany({
    required String email,
    required String password,
    required String companyName,
    required String companyInitials,
    required String companyPhone,
    required String adminName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.post(ApiConstants.register, data: {
        'email': email,
        'password': password,
        'role': 'HR',
        'companyName': companyName,
        'companyInitials': companyInitials,
        'companyPhone': companyPhone,
        'adminName': adminName,
      });

      final data = response.data;
      final user = User.fromJson(data);

      await _storage.write(key: 'jwt_token', value: user.token);
      await _storage.write(key: 'user_role', value: user.role);

      state = AsyncValue.data(user);
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final message = e.response?.data['message'] ?? e.message;
        state = AsyncValue.error(message, StackTrace.current);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _apiService.put(ApiConstants.changePassword, data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
         final message = e.response?.data['message'] ?? e.message;
         throw message;
      } else {
         throw e.toString();
      }
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
    state = const AsyncValue.data(null);
  }
}
