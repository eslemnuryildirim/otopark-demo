import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🔐 Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  try {
    return FirebaseAuth.instance;
  } catch (e) {
    print('⚠️ Firebase Auth instance alınamadı: $e');
    return null;
  }
});

/// 👤 Current user provider (reactive)
/// 
/// Kullanıcı giriş yaptığında/yaptığında otomatik güncellenir
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  if (auth == null) {
    return Stream.value(null);
  }
  return auth.authStateChanges();
});

/// 🔑 Auth service provider
final authServiceProvider = Provider<AuthService?>((ref) {
  final auth = ref.read(firebaseAuthProvider);
  if (auth == null) {
    return null;
  }
  return AuthService(auth);
});

/// 🔐 Authentication Service
class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  /// 📧 Email/Password ile kayıt ol
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Display name ayarla (opsiyonel)
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Beklenmeyen hata: $e';
    }
  }

  /// 🔑 Email/Password ile giriş yap
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Beklenmeyen hata: $e';
    }
  }

  /// 🚪 Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 🔄 Şifre sıfırlama emaili gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Beklenmeyen hata: $e';
    }
  }

  /// 👤 Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  /// 🔄 Auth exception'ları Türkçe'ye çevir
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalı.';
      case 'email-already-in-use':
        return 'Bu email adresi zaten kullanılıyor.';
      case 'invalid-email':
        return 'Geçersiz email adresi.';
      case 'user-not-found':
        return 'Bu email adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda izin verilmiyor.';
      default:
        return 'Giriş hatası: ${e.message ?? "Bilinmeyen hata"}';
    }
  }
}

