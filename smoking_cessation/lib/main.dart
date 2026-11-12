// ========================================
// DOSYA: main.dart
// NE İŞE YARAR: Uygulamanın giriş noktasıdır,
// bağımlılıkları başlatır ve MaterialApp kurar.
// NASIL ÇALIŞIR: SharedPreferences ve
// controller
// nesnelerini kurup AppScope ile aktarır.
// SOLID: DIP - Bağımlılıklar burada bağlanır.
// ========================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/craving/craving_controller.dart';
import 'features/diary/diary_controller.dart';
import 'features/quit/quit_controller.dart';
import 'screens/home_shell_screen.dart';
import 'screens/onboarding_date_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

// Bu sınıf durum denetleyicilerini alt widget
// ağacına aktarır. Böylece harici paketlere
// gerek
// kalmadan ekranlar verilere doğrudan
// erişebilir.
class AppScope extends InheritedWidget {
  final QuitController quitController;
  final DiaryController diaryController;
  final CravingController cravingController;

  const AppScope({
    super.key,
    required this.quitController,
    required this.diaryController,
    required this.cravingController,
    required super.child,
  });

  // Widget ağacında yukarı doğru arama yaparak
  // en yakın AppScope örneğini bulur ve döner.
  static AppScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope bulunamadı.');
    return scope!;
  }

  // Controller referansları çalışma süresince
  // değişmediğinden gereksiz yeniden çizimleri
  // önlemek için her zaman false döndürülür.
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      false;
}

// Uygulamanın ana giriş fonksiyonudur. Ekranlar
// çizilmeden önce yerel depolama servisini
// asenkron olarak ayağa kaldırır.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final storage = SharedPrefsStorageService(prefs);

  // İş mantığı denetleyicileri burada oluşturulur
  // ve bağımlı oldukları servisler constructor
  // üzerinden sınıflara enjekte edilir.
  final quitController = QuitController(storage);
  final diaryController = DiaryController(storage);
  final cravingController = CravingController();

  await quitController.init();
  await diaryController.init();

  runApp(
    AppScope(
      quitController: quitController,
      diaryController: diaryController,
      cravingController: cravingController,
      child: const SmokingCessationApp(),
    ),
  );
}

// Uygulamanın kök görsel kabuğudur. Tema
// ayarlarını ve ilk açılış yönlendirmesini
// yapar.
class SmokingCessationApp extends StatelessWidget {
  const SmokingCessationApp({super.key});

  // Kullanıcı profili kayıtlıysa ana sayfayı,
  // ilk kez açılıyorsa başlangıç ekranını
  // gösterir.
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return MaterialApp(
      title: 'Lumina Recovery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: ListenableBuilder(
        listenable: scope.quitController,
        builder: (context, _) {
          if (scope.quitController.isOnboarded) {
            return HomeShellScreen(
              quitController: scope.quitController,
            );
          }
          return OnboardingDateScreen(
            quitController: scope.quitController,
          );
        },
      ),
    );
  }
}
