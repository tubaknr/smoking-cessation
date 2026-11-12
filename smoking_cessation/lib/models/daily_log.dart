// ========================================
// DOSYA: daily_log.dart
// NE İŞE YARAR: Günlük sigara içmeme kaydını
// ve tarih formatlayıcısını tanımlar.
// NASIL ÇALIŞIR: Gün, durum, kriz seviyesi ve
// not bilgilerini JSON uyumlu saklar.
// SOLID: SRP - Sadece günlük kayıt verisi
// ve tarih anahtarı yardımcısını barındırır.
// ========================================

// Kullanıcının belirli bir gün sigara içip
// içmediğini,
// hissettiği kriz şiddetini ve kısa notunu
// tutar.
class DailyLog {
  final String date;
  final bool smokeFree;
  final int? cravingLevel;
  final String? note;

  const DailyLog({
    required this.date,
    required this.smokeFree,
    this.cravingLevel,
    this.note,
  });

  // Günlük kaydı cihaz hafızasına yazabilmek
  // için standart bir JSON haritasına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'smokeFree': smokeFree,
      'cravingLevel': cravingLevel,
      'note': note,
    };
  }

  // Depodan okunan JSON verisini modele çevirir;
  // girilen notun 200 karakter sınırını aşmasını
  // önler.
  factory DailyLog.fromJson(Map<String, dynamic> json) {
    final rawLevel = (json['cravingLevel'] as num?)?.toInt();
    final clampedLevel = rawLevel?.clamp(1, 5);

    final rawNote = json['note'] as String?;
    final isLong = (rawNote?.length ?? 0) > 200;
    final truncatedNote =
        isLong ? rawNote!.substring(0, 200) : rawNote;

    return DailyLog(
      date: json['date'] as String? ?? '',
      smokeFree: json['smokeFree'] as bool? ?? true,
      cravingLevel: clampedLevel,
      note: truncatedNote,
    );
  }

  // Mevcut kaydı değiştirmeden sadece belirtilen
  // alanları güncelleyerek yeni bir kopya
  // oluşturur.
  DailyLog copyWith({
    String? date,
    bool? smokeFree,
    int? cravingLevel,
    String? note,
  }) {
    return DailyLog(
      date: date ?? this.date,
      smokeFree: smokeFree ?? this.smokeFree,
      cravingLevel: cravingLevel ?? this.cravingLevel,
      note: note ?? this.note,
    );
  }
}

// Tarih nesnelerini harici kütüphane
// kullanmadan
// standart metin formatına çeviren yardımcı
// sınıftır.
class DateKey {
  DateKey._();

  // DateTime nesnesini yyyy-MM-dd biçiminde
  // iki basamaklı standart bir metin anahtarına
  // çevirir.
  static String format(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // Standart tarih metnini parçalayarak
  // üzerinde işlem yapılabilecek DateTime nesnesi
  // üretir.
  static DateTime parse(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return DateTime.now();
    final y = int.tryParse(parts[0]) ?? 2026;
    final m = int.tryParse(parts[1]) ?? 1;
    final d = int.tryParse(parts[2]) ?? 1;
    return DateTime(y, m, d);
  }

  // Verilen tarihin bugüne ait olup olmadığını
  // güncel sistem tarihiyle karşılaştırarak
  // döner.
  static bool isToday(String dateStr) {
    return dateStr == format(DateTime.now());
  }

  // Kullanıcının gelecekteki bir güne kayıt
  // girmesini engellemek için ileri tarih
  // kontrolü yapar.
  static bool isFuture(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    return target.isAfter(today);
  }
}
