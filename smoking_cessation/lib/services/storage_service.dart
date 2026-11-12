// ========================================
// DOSYA: storage_service.dart
// NE İŞE YARAR: Veriyi cihazda yerel anahtar-
// değer olarak saklar ve okur.
// NASIL ÇALIŞIR: SharedPreferences paketini
// soyutlayarak string saklar.
// SOLID: ISP & DIP - Küçük soyut arayüz,
// somut implementasyonlardan ayrılmıştır.
// ========================================

import 'package:shared_preferences/shared_preferences.dart';

// Verilerin yerel olarak saklanması ve okunması
// işlemlerini üst sınıflardan soyutlayan
// sözleşmedir.
abstract class StorageService {
  Future<String?> readString(String key);
  Future<bool> writeString(String key, String value);
  Future<bool> remove(String key);
  Future<bool> clear();
}

// Cihaz diskine veri yazmak ve okumak için
// SharedPreferences kütüphanesini kullanan
// gerçeklemedir.
class SharedPrefsStorageService implements StorageService {
  final SharedPreferences _prefs;

  SharedPrefsStorageService(this._prefs);

  // Belirtilen anahtara karşılık gelen JSON
  // metnini
  // cihaz diskinden okuyarak geriye döndürür.
  @override
  Future<String?> readString(String key) async {
    return _prefs.getString(key);
  }

  // Verilen anahtar altına JSON metnini kalıcı
  // olarak kaydeder ve işlemin sonucunu döner.
  @override
  Future<bool> writeString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  // Belirtilen anahtarı ve altındaki tüm veriyi
  // cihaz depolama alanından bütünüyle temizler.
  @override
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  // Kullanıcı tüm verileri sıfırlamak istediğinde
  // uygulamaya ait tüm yerel anahtarları siler.
  @override
  Future<bool> clear() async {
    return _prefs.clear();
  }
}

// Otomatik birim testlerinde disk bağımlılığını
// ortadan kaldıran bellek içi (RAM) sahte
// depodur.
class InMemoryStorageService implements StorageService {
  final Map<String, String> _data = {};

  // Bellekteki haritadan anahtara karşılık gelen
  // metin değerini gecikmesiz olarak çeker.
  @override
  Future<String?> readString(String key) async {
    return _data[key];
  }

  // Test verisini bellek haritasına yazar ve
  // testlerin hızlıca tamamlanmasını sağlar.
  @override
  Future<bool> writeString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  // Belirtilen anahtarı bellek haritasından
  // çıkartarak silme testlerinin doğrulanmasını
  // sağlar.
  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  // Testler arasında durum izolasyonu sağlamak
  // amacıyla bellek haritasını tamamen boşaltır.
  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }
}
