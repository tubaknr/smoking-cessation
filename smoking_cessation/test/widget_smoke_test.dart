// ========================================
// DOSYA: widget_smoke_test.dart
// NE İŞE YARAR: Ekran akışları ve arayüzün
// duman (smoke) testlerini koşturur.
// NASIL ÇALIŞIR: flutter_test ile sahte
// servisler üzerinde widget testi yapar.
// SOLID: Arayüz ve bağımlılık testleri.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smoking_cessation/features/craving/craving_controller.dart';
import 'package:smoking_cessation/features/diary/diary_controller.dart';
import 'package:smoking_cessation/features/quit/quit_controller.dart';
import 'package:smoking_cessation/main.dart';
import 'package:smoking_cessation/models/user_profile.dart';
import 'package:smoking_cessation/screens/craving_screen.dart';
import 'package:smoking_cessation/screens/home_shell_screen.dart';
import 'package:smoking_cessation/screens/onboarding_date_screen.dart';
import 'package:smoking_cessation/services/storage_service.dart';

void main() {
  late InMemoryStorageService storage;
  late QuitController quitController;
  late DiaryController diaryController;
  late CravingController cravingController;

  setUp(() async {
    storage = InMemoryStorageService();
    quitController = QuitController(storage);
    diaryController = DiaryController(storage);
    cravingController = CravingController();

    await quitController.init();
    await diaryController.init();
  });

  Widget createTestApp() {
    return AppScope(
      quitController: quitController,
      diaryController: diaryController,
      cravingController: cravingController,
      child: const SmokingCessationApp(),
    );
  }

  testWidgets('Profil yoksa OnboardingDateScreen açılmalı',
      (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingDateScreen), findsOneWidget);
    expect(find.text('Sigarayı ne zaman bıraktın?'), findsOneWidget);
  });

  testWidgets('Profil varsa HomeShellScreen açılmalı ve sekmeler çalışmalı',
      (tester) async {
    final profile = UserProfile(
      quitDateTime: DateTime.now().subtract(const Duration(days: 2)),
      cigarettesPerDay: 20,
      packPrice: 100.0,
      cigarettesPerPack: 20,
    );
    await quitController.saveProfile(profile);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(HomeShellScreen), findsOneWidget);
    expect(find.text('SİGARASIZ TEMİZ HAYAT'), findsOneWidget);

    // Sağlık sekmesine geçiş
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(find.text('Biyolojik İyileşme'), findsOneWidget);

    // Günlük sekmesine geçiş
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Bugün İçmedim'), findsOneWidget);

    // Ayarlar sekmesine geçiş
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('PROFİL BİLGİLERİ'), findsOneWidget);
  });

  testWidgets('Profil kaydedilince QuitController ve sayaç güncellenmeli',
      (tester) async {
    final profile = UserProfile(
      quitDateTime: DateTime.now().subtract(const Duration(days: 1)),
      cigarettesPerDay: 15,
      packPrice: 80.0,
      cigarettesPerPack: 20,
    );
    await quitController.saveProfile(profile);
    expect(quitController.isOnboarded, isTrue);
    expect(quitController.unsmokedCigarettes, greaterThan(0));
    expect(quitController.moneySaved, greaterThan(0));
  });

  testWidgets('Sağlık ekranı dar ve geniş pencerelerde taşma vermemeli',
      (tester) async {
    final profile = UserProfile(
      quitDateTime: DateTime.now().subtract(const Duration(days: 3)),
      cigarettesPerDay: 20,
      packPrice: 100.0,
      cigarettesPerPack: 20,
    );
    await quitController.saveProfile(profile);

    FlutterErrorDetails? errorDetails;
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errorDetails = details;
      originalOnError?.call(details);
    };

    for (final size in [
      const Size(320, 568),
      const Size(360, 640),
      const Size(414, 896),
      const Size(800, 600),
      const Size(1200, 800),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Sayaç sekmesi
      await tester.tap(find.text('Sayaç'));
      await tester.pumpAndSettle();
      expect(find.text('Özgürlük Takibi'), findsOneWidget);

      // Sağlık sekmesi
      await tester.tap(find.text('Sağlık'));
      await tester.pumpAndSettle();
      expect(find.text('Biyolojik İyileşme'), findsOneWidget);
      expect(find.text('AKCİĞER KAPASİTESİ'), findsOneWidget);

      // Günlük sekmesi
      await tester.tap(find.text('Günlük'));
      await tester.pumpAndSettle();
      expect(find.text('Bugün İçmedim'), findsOneWidget);

      // Ayarlar sekmesi
      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();
      expect(find.text('PROFİL BİLGİLERİ'), findsOneWidget);

      // Kriz ekranı kontrolü
      await tester.tap(find.text('Kriz'));
      await tester.pumpAndSettle();
      expect(find.byType(CravingScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      if (errorDetails != null) {
        // ignore: avoid_print
        print('FOUND ERROR: ${errorDetails?.summary} on widget ${errorDetails?.context}');
        break;
      }
    }
    FlutterError.onError = originalOnError;
    expect(errorDetails, isNull);
  });
}
