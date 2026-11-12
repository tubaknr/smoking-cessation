// ========================================
// DOSYA: quit_calculator.dart
// NE İŞE YARAR: Süre, tasarruf ve sağlık
// kazanımı formüllerini hesaplar.
// NASIL ÇALIŞIR: Saf fonksiyonlarla girdi
// alır ve hesaplanan sayıları döner.
// SOLID: SRP - Sadece matematiksel ve
// mantıksal hesaplama sorumluluğu vardır.
// ========================================

import '../models/health_milestone.dart';

// Sigara bırakma sürecindeki süre, tasarruf ve
// biyolojik kazanımları hesaplayan saf
// matematik motorudur.
class QuitCalculator {
  QuitCalculator._();

  // Bırakma anından güncel zamana kadar geçen
  // süreyi
  // hesaplar; negatif sürelerde sıfır Duration
  // döner.
  static Duration elapsedDuration(
    DateTime quitDateTime,
    DateTime now,
  ) {
    if (now.isBefore(quitDateTime)) {
      return Duration.zero;
    }
    return now.difference(quitDateTime);
  }

  // Geçen süreyi mikrosaniye hassasiyetinde
  // ondalıklı gün cinsine dönüştürerek çarpan
  // üretir.
  static double elapsedDaysDecimal(Duration elapsed) {
    if (elapsed <= Duration.zero) return 0.0;
    return elapsed.inMicroseconds /
        (24.0 * 3600.0 * 1000000.0);
  }

  // Geçen gün ile günlük tüketimi çarparak
  // içilmeyen
  // dal adedini bulur ve tamamlanmamış dalı aşağı
  // yuvarlar.
  static int unsmokedCigarettes(
    double elapsedDays,
    int cigarettesPerDay,
  ) {
    if (elapsedDays <= 0 || cigarettesPerDay <= 0) return 0;
    return (elapsedDays * cigarettesPerDay).floor();
  }

  // Paket fiyatını paketteki adet sayısına
  // bölerek
  // tek bir sigara dalının birim maliyetini
  // hesaplar.
  static double pricePerCigarette(
    double packPrice,
    int cigarettesPerPack,
  ) {
    if (packPrice <= 0 || cigarettesPerPack <= 0) return 0.0;
    return packPrice / cigarettesPerPack;
  }

  // İçilmeyen sigara adedi ile birim fiyatı
  // çarparak
  // kullanıcının cebinde kalan toplam TL'yi
  // bulur.
  static double moneySaved(
    int unsmokedCount,
    double singlePrice,
  ) {
    if (unsmokedCount <= 0 || singlePrice <= 0) return 0.0;
    return unsmokedCount * singlePrice;
  }

  // Geçen sürenin kilometre taşının başlangıç
  // süresine
  // ulaşıp ulaşmadığını kıyaslayarak tamamlanma
  // döner.
  static bool isMilestoneCompleted(
    Duration elapsed,
    HealthMilestone milestone,
  ) {
    return elapsed >= milestone.startDuration;
  }

  // Kilometre taşının doluluk oranını sıfır ile
  // bir
  // aralığında sınırlayarak ilerleme çubuğuna
  // sunar.
  static double milestoneProgress(
    Duration elapsed,
    HealthMilestone milestone,
  ) {
    if (elapsed <= Duration.zero) return 0.0;
    final totalSec = milestone.endDuration.inSeconds;
    if (totalSec <= 0) return 1.0;
    final ratio = elapsed.inSeconds / totalSec;
    return ratio.clamp(0.0, 1.0);
  }

  // DSÖ istatistiklerine göre içilmeyen her
  // sigara dalı
  // için kullanıcıya 11 dakika kazanılan ömür
  // ekler.
  static Duration lifeRegained(int unsmokedCount) {
    if (unsmokedCount <= 0) return Duration.zero;
    return Duration(minutes: unsmokedCount * 11);
  }
}
