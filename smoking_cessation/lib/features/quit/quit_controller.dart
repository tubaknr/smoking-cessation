// ========================================
// DOSYA: quit_controller.dart
// NE İŞE YARAR: Profil verilerini ve canlı
// sayacı yöneten durum denetleyicisidir.
// NASIL ÇALIŞIR: ChangeNotifier ile verileri
// dinleyicilere duyurur, Timer ile akar.
// SOLID: SRP - Bırakma verisi durumunu yönetir.
// DIP - Yalnızca soyut depo arayüzüne bağlıdır.
// ========================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/user_profile.dart';
import '../../services/quit_calculator.dart';
import '../../services/storage_service.dart';

// Kullanıcı profilini, canlı sayacı ve biriken
// tasarruf verilerini yöneten ana durum
// sınıfıdır.
class QuitController extends ChangeNotifier {
  final StorageService _storage;
  Timer? _ticker;

  UserProfile? _profile;
  DateTime _now = DateTime.now();

  QuitController(this._storage);

  UserProfile? get profile => _profile;
  DateTime get now => _now;

  // Kullanıcının daha önce geçerli bir profil
  // oluşturup oluşturmadığını denetler.
  bool get isOnboarded => _profile != null && _profile!.isValid;

  // Bırakma anından günümüze kadar geçen canlı
  // süreyi QuitCalculator aracılığıyla hesaplar.
  Duration get elapsedDuration {
    if (_profile == null) return Duration.zero;
    return QuitCalculator.elapsedDuration(
      _profile!.quitDateTime,
      _now,
    );
  }

  // Geçen süreyi dal ve tasarruf hesaplarında
  // kullanılmak üzere ondalıklı gün cinsine
  // çevirir.
  double get elapsedDays =>
      QuitCalculator.elapsedDaysDecimal(elapsedDuration);

  // Sigara içilmeyerek kurtarılan toplam dal
  // sayısını
  // aşağı yuvarlanmış tam sayı olarak döndürür.
  int get unsmokedCigarettes {
    if (_profile == null) return 0;
    return QuitCalculator.unsmokedCigarettes(
      elapsedDays,
      _profile!.cigarettesPerDay,
    );
  }

  // Paket fiyatı ve adedine göre tek bir sigara
  // dalının TL bazındaki maliyetini döner.
  double get singleCigarettePrice {
    if (_profile == null) return 0.0;
    return QuitCalculator.pricePerCigarette(
      _profile!.packPrice,
      _profile!.cigarettesPerPack,
    );
  }

  // Kurtarılan dal sayısı ile birim fiyatı
  // çarparak
  // kullanıcının toplam parasal tasarrufunu
  // bulur.
  double get moneySaved => QuitCalculator.moneySaved(
        unsmokedCigarettes,
        singleCigarettePrice,
      );

  // Dal başına 11 dakika üzerinden kullanıcının
  // yeniden kazandığı toplam biyolojik yaşam
  // süresidir.
  Duration get lifeRegained =>
      QuitCalculator.lifeRegained(unsmokedCigarettes);

  // Depodan kayıtlı profili okur, saniyelik
  // zamanlayıcıyı başlatır ve dinleyicileri
  // uyarır.
  Future<void> init() async {
    await _loadProfile();
    _startTicker();
    notifyListeners();
  }

  // Cihaz diskinde kayıtlı profil JSON metnini
  // çözerek UserProfile nesnesine dönüştürür.
  Future<void> _loadProfile() async {
    try {
      final jsonStr = await _storage.readString('profile');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(map);
      }
    } catch (_) {
      _profile = null;
    }
  }

  // Saniyede bir tetiklenen periyodik zamanlayıcı
  // kurarak canlı sayacın ekranda akmasını
  // sağlar.
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  // Güncellenen profil verisini diske yazar ve
  // arayüzü günceller.
  Future<void> saveProfile(UserProfile newProfile) async {
    _profile = newProfile;
    final jsonStr = jsonEncode(newProfile.toJson());
    await _storage.writeString('profile', jsonStr);
    notifyListeners();
  }

  // Kullanıcı profilini sıfırlayarak
  // uygulamayı ilk kurulum haline döndürür.
  Future<void> clearAll() async {
    _profile = null;
    await _storage.remove('profile');
    notifyListeners();
  }

  // Bellek sızıntılarını önlemek amacıyla
  // controller
  // yok edilirken çalışan zamanlayıcıyı durdurur.
  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
