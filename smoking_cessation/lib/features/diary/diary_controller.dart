// ========================================
// DOSYA: diary_controller.dart
// NE İŞE YARAR: Günlük kayıtları ve takvim
// durumlarını yöneten denetleyicidir.
// NASIL ÇALIŞIR: Tarih bazlı kayıt haritası
// tutar ve JSON olarak kaydeder.
// SOLID: SRP - Sadece günlük kayıt yönetimi.
// DIP - StorageService soyutuna bağımlıdır.
// ========================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/daily_log.dart';
import '../../services/storage_service.dart';

// Günlük sigara içmeme kayıtlarını, takvim
// verilerini ve kesintisiz gün serisini
// yönetir.
class DiaryController extends ChangeNotifier {
  final StorageService _storage;
  final Map<String, DailyLog> _logs = {};

  DiaryController(this._storage);

  Map<String, DailyLog> get logs => Map.unmodifiable(_logs);
  List<DailyLog> get allLogs => _logs.values.toList();

  // Depodaki tüm geçmiş kayıtları okuyarak
  // uygulama açılışında takvim haritasını
  // doldurur.
  Future<void> init() async {
    try {
      final jsonStr = await _storage.readString('logs');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        _logs.clear();
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final log = DailyLog.fromJson(item);
            if (log.date.isNotEmpty) {
              _logs[log.date] = log;
            }
          }
        }
      }
    } catch (_) {
      _logs.clear();
    }
    notifyListeners();
  }

  // Tarih anahtarı (yyyy-MM-dd) verilen günün
  // mevcut kaydını döner; kayıt yoksa null döner.
  DailyLog? getLog(String dateKey) => _logs[dateKey];

  // Belirli bir günün sigarasız geçirilip
  // geçirilmediğini takvim renklendirmesi için
  // döner.
  bool isSmokeFreeDay(String dateKey) {
    final log = _logs[dateKey];
    return log != null && log.smokeFree;
  }

  // Kullanıcının ana ekrandan tek dokunuşla
  // bugünü
  // içmedim olarak işaretlemesini sağlar.
  Future<void> setSmokeFreeToday(bool smokeFree) async {
    final todayKey = DateKey.format(DateTime.now());
    final existing = _logs[todayKey];
    final updated = existing != null
        ? existing.copyWith(smokeFree: smokeFree)
        : DailyLog(date: todayKey, smokeFree: smokeFree);
    await saveLog(updated);
  }

  // Yeni bir günlük kaydı ekler veya mevcut olanı
  // güncelleyip diske kalıcı olarak yazar.
  Future<void> saveLog(DailyLog log) async {
    _logs[log.date] = log;
    await _persist();
    notifyListeners();
  }

  // Kullanıcının sildiği gün kaydını haritadan
  // çıkartarak yerel depolamayı günceller.
  Future<void> deleteLog(String dateKey) async {
    _logs.remove(dateKey);
    await _persist();
    notifyListeners();
  }

  // Veri sıfırlama talebinde tüm günlük kayıt
  // geçmişini bellekten ve diskten temizler.
  Future<void> clearAll() async {
    _logs.clear();
    await _storage.remove('logs');
    notifyListeners();
  }

  // Bugünden geriye doğru giderek zincirin
  // kırılmadığı kesintisiz gün serisini hesaplar.
  int get currentStreak {
    int streak = 0;
    var checkDate = DateTime.now();

    while (true) {
      final key = DateKey.format(checkDate);
      final log = _logs[key];
      if (log != null && log.smokeFree) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (streak == 0 && DateKey.isToday(key)) {
          checkDate =
              checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    return streak;
  }

  // Bellekteki tüm kayıtları JSON dizisine
  // çevirip
  // SharedPreferences içine metin olarak
  // kaydeder.
  Future<void> _persist() async {
    final list = _logs.values.map((l) => l.toJson()).toList();
    final jsonStr = jsonEncode(list);
    await _storage.writeString('logs', jsonStr);
  }
}
