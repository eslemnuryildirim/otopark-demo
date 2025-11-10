import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:otopark_demo/core/services/ocr_ip_setup.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otopark_demo/features/auth/providers/auth_provider.dart';

class ShellPage extends ConsumerWidget {
  const ShellPage({required this.child, super.key});

  final Widget child;

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authService = ref.read(authServiceProvider);
      if (authService != null) {
        await authService.signOut();
        if (context.mounted) {
          context.go('/login');
        }
      } else {
        // Auth servisi yoksa direkt login'e git
        if (context.mounted) {
          context.go('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth kontrolü - eğer devre dışıysa AppBar'da auth butonları gösterme
    User? user;
    bool authEnabled = false;
    
    try {
      final auth = ref.watch(firebaseAuthProvider);
      if (auth != null) {
        authEnabled = true;
        final authState = ref.watch(authStateProvider);
        user = authState.valueOrNull;
      }
    } catch (e) {
      // Auth devre dışı
      authEnabled = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Otopark Demo'),
        actions: [
          // OCR IP ayarları (sadece iOS cihazda)
          if (Platform.isIOS && !Platform.isMacOS)
            IconButton(
              icon: const Icon(Icons.settings_ethernet),
              tooltip: 'OCR Sunucu Ayarları',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const OcrIpSetupDialog(),
                );
              },
            ),
          if (authEnabled && user != null) ...[
            // Kullanıcı bilgisi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  user.displayName ?? user.email ?? 'Kullanıcı',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            // Logout butonu
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Çıkış Yap',
              onPressed: () => _handleLogout(context, ref),
            ),
          ],
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map_rounded),
            label: 'Kroki',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car_rounded),
            label: 'Araçlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment_rounded),
            label: 'Ekspertiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_toggle_off_rounded),
            activeIcon: Icon(Icons.history_rounded),
            label: 'İşlemler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.numbers_outlined),
            activeIcon: Icon(Icons.numbers_rounded),
            label: 'Sayaçlar',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/kroki')) {
      return 0;
    }
    if (location.startsWith('/vehicles')) {
      return 1;
    }
    if (location.startsWith('/expertiz')) {
      return 2;
    }
    if (location.startsWith('/operations')) {
      return 3;
    }
    if (location.startsWith('/counters')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/kroki');
        break;
      case 1:
        GoRouter.of(context).go('/vehicles');
        break;
      case 2:
        GoRouter.of(context).go('/expertiz');
        break;
      case 3:
        GoRouter.of(context).go('/operations');
        break;
      case 4:
        GoRouter.of(context).go('/counters');
        break;
    }
  }
}
