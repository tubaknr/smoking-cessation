// ========================================
// DOSYA: user_profile.dart
// NE İŞE YARAR: Kullanıcının sigara bırakma
// profil verilerini ve parametrelerini modeller.
// NASIL ÇALIŞIR: JSON serileştirme ve
// doğrulama metotlarıyla veri tutar.
// SOLID: SRP - Sadece profil verilerini
// temsil etme görevi vardır.
// ========================================

// Kullanıcının sigarayı bıraktığı anı, günlük
// içtiği dal sayısını ve paket ücretini saklar.
class UserProfile {
  final DateTime quitDateTime;
  final int cigarettesPerDay;
  final double packPrice;
  final int cigarettesPerPack;

  const UserProfile({
    required this.quitDateTime,
    required this.cigarettesPerDay,
    required this.packPrice,
    required this.cigarettesPerPack,
  });

  // Girilen verilerin geçerli olup olmadığını
  // denetler;
  // gelecekteki tarihleri ve sıfır fiyatı kabul
  // etmez.
  bool get isValid {
    final now = DateTime.now();
    final dateValid = !quitDateTime.isAfter(now);
    final countValid =
        cigarettesPerDay >= 1 && cigarettesPerDay <= 100;
    final priceValid = packPrice > 0 && packPrice <= 10000;
    final packValid =
        cigarettesPerPack >= 1 && cigarettesPerPack <= 50;
    return dateValid && countValid && priceValid && packValid;
  }

  // Modeli cihazda metin olarak saklayabilmek
  // için standart bir JSON haritasına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'quitDateTime': quitDateTime.toIso8601String(),
      'cigarettesPerDay': cigarettesPerDay,
      'packPrice': packPrice,
      'cigarettesPerPack': cigarettesPerPack,
    };
  }

  // Cihazdan okunan JSON verisini modele
  // dönüştürür;
  // eksik veya bozuk alanlarda varsayılan değer
  // atar.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawDate = json['quitDateTime']?.toString();
    final parsedDate = rawDate != null
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();

    final count = (json['cigarettesPerDay'] as num?)?.toInt() ?? 20;
    final price = (json['packPrice'] as num?)?.toDouble() ?? 100.0;
    final perPack =
        (json['cigarettesPerPack'] as num?)?.toInt() ?? 20;

    return UserProfile(
      quitDateTime: parsedDate,
      cigarettesPerDay: count.clamp(1, 100),
      packPrice: price > 0 ? price.clamp(1.0, 10000.0) : 100.0,
      cigarettesPerPack: perPack.clamp(1, 50),
    );
  }

  // Nesneyi değiştirmeden sadece güncellenmek
  // istenen alanlarıyla yeni bir kopyasını
  // üretir.
  UserProfile copyWith({
    DateTime? quitDateTime,
    int? cigarettesPerDay,
    double? packPrice,
    int? cigarettesPerPack,
  }) {
    return UserProfile(
      quitDateTime: quitDateTime ?? this.quitDateTime,
      cigarettesPerDay: cigarettesPerDay ?? this.cigarettesPerDay,
      packPrice: packPrice ?? this.packPrice,
      cigarettesPerPack:
          cigarettesPerPack ?? this.cigarettesPerPack,
    );
  }
}
