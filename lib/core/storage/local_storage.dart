import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/app_errors.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

final localStorageProvider = Provider<LocalStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageImpl(prefs);
});

abstract class LocalStorage {
  Future<void> setString(String key, String value);
  String? getString(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<void> clearCache();
  Future<void> clearSessionAndCache({bool preserveOnboarding = true});
}

class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _prefs;

  LocalStorageImpl(this._prefs);

  @override
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw StorageError('Failed to save data: $e');
    }
  }

  @override
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw StorageError('Failed to read data: $e');
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      throw StorageError('Failed to remove data: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw StorageError('Failed to clear storage: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = _prefs.getKeys().toList();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await _prefs.remove(key);
        }
      }
    } catch (e) {
      throw StorageError('Failed to clear cache: $e');
    }
  }

  @override
  Future<void> clearSessionAndCache({bool preserveOnboarding = true}) async {
    try {
      final keys = _prefs.getKeys().toList();
      for (final key in keys) {
        if (preserveOnboarding && key == 'onboarding_completed') {
          continue;
        }
        await _prefs.remove(key);
      }
    } catch (e) {
      throw StorageError('Failed to clear session and cache: $e');
    }
  }
}

