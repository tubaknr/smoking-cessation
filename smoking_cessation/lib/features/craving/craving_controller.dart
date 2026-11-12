// ========================================
// DOSYA: craving_controller.dart
// NE İŞE YARAR: 5 dakikalık kriz geri sayımı,
// 4-7-8 nefes fazları ve sesi yönetir.
// NASIL ÇALIŞIR: Timer ile 19 saniyelik
// döngüde fazları ve geri sayımı belirler.
// SOLID: SRP - Kriz anı egzersizi durumunu
// tutar.
// ========================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Parasempatik sinir sistemini yatıştıran
// 4-7-8 nefes döngüsünün evrelerini tanımlar.
enum BreathingPhase {
  inhale,
  hold,
  exhale,
}

// Ani sigara krizlerinde 5 dakikalık geri
// sayımı
// ve ritmik nefes animasyonunu yöneten
// denetleyicidir.
class CravingController extends ChangeNotifier {
  static const int totalSessionSeconds = 300;

  static const List<String> quotes = [
    'Bu istek sadece geçici bir dalga. Birazdan dinecek.',
    'Derin bir nefes al. Ciğerlerin kendini yeniliyor.',
    'Sigara stresi azaltmaz, yeni bir kriz yaratır.',
    'Bugün gösterdiğin irade, yarınki özgürlüğündür.',
    'Zor anlar geçer, bu istekten daha güçlüsün.',
    'Zihnindeki nikotin sesini duy ama teslim olma.',
    'Her temiz dakika, bedenine en büyük hediyedir.',
    'Bir sigara hiçbir şeyi çözmez, temiz kal.',
    'Bir yudum soğuk su iç ve nefesine odaklan.',
    'Kendine olan sözünü hatırla, sen kazanacaksın.',
    'Duman geçti, hayat başladı. İradene güven.',
    'Şu anki his, vücudunun iyileşme kanıtıdır.',
  ];

  final Random _random = Random();
  Timer? _timer;
  int _remainingSeconds = totalSessionSeconds;
  bool _isActive = false;
  bool _isSuccess = false;
  bool _isNatureSoundPlaying = false;
  String _currentQuote = '';

  CravingController() {
    _pickRandomQuote();
  }

  int get remainingSeconds => _remainingSeconds;
  bool get isActive => _isActive;
  bool get isSuccess => _isSuccess;
  bool get isNatureSoundPlaying => _isNatureSoundPlaying;
  String get currentQuote => _currentQuote;

  // On dokuz saniyelik nefes döngüsünün hangi
  // saniyesinde olunduğunu modüler hesapla döner.
  int get cycleSecond =>
      (totalSessionSeconds - _remainingSeconds) % 19;

  // Anlık saniyeye karşılık gelen nefes fazını
  // (Nefes Al, Tut veya Nefes Ver) belirler.
  BreathingPhase get currentPhase {
    if (cycleSecond < 4) return BreathingPhase.inhale;
    if (cycleSecond < 11) return BreathingPhase.hold;
    return BreathingPhase.exhale;
  }

  // Ekranda kullanıcıya gösterilecek olan
  // aktif nefes evresi Türkçe başlık metnidir.
  String get phaseTitle {
    switch (currentPhase) {
      case BreathingPhase.inhale:
        return 'Nefes Al';
      case BreathingPhase.hold:
        return 'Tut';
      case BreathingPhase.exhale:
        return 'Nefes Ver';
    }
  }

  // İçinde bulunulan nefes evresinin bitmesine
  // kalan saniyeyi geri sayım kutusu için
  // hesaplar.
  int get phaseCountdown {
    final sec = cycleSecond;
    if (sec < 4) return 4 - sec;
    if (sec < 11) return 11 - sec;
    return 19 - sec;
  }

  // Nefes dairesinin ekranda pürüzsüzce büyüyüp
  // küçülmesi için sıfır ile bir arası oran
  // üretir.
  double get phaseProgress {
    final sec = cycleSecond;
    if (sec < 4) {
      return sec / 4.0;
    } else if (sec < 11) {
      return 1.0;
    } else {
      return (19 - sec) / 8.0;
    }
  }

  // Rahatlatıcı doğa sesi oynatma durumunu açıp
  // kapatır ve platform ses köprüsünü günceller.
  void toggleNatureSound() {
    _isNatureSoundPlaying = !_isNatureSoundPlaying;
    _syncWebAudio();
    notifyListeners();
  }

  // Web ve mobil ortamlarda ses komutunu sistem
  // açıklamasıyla senkronize eder, hataları
  // yutar.
  void _syncWebAudio() {
    try {
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: _isNatureSoundPlaying
              ? 'cmd:nature:play'
              : 'cmd:nature:stop',
        ),
      );
    } catch (_) {}
  }

  // Beş dakikalık kriz seansını sıfırlar,
  // rastgele
  // bir motivasyon sözü seçer ve sayacı başlatır.
  void startSession() {
    _remainingSeconds = totalSessionSeconds;
    _isActive = true;
    _isSuccess = false;
    _pickRandomQuote();
    _startTimer();
    notifyListeners();
  }

  // Saniyede bir kalan süreyi düşüren ve süre
  // dolduğunda seansı başarıyla tamamlayan
  // motordur.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 1) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _remainingSeconds = 0;
        completeSession();
      }
    });
  }

  // Kullanıcı beş dakikayı tamamladığında veya
  // krizi
  // yendim butonuna bastığında başarı bayrağını
  // açar.
  void completeSession() {
    _timer?.cancel();
    _isActive = false;
    _isSuccess = true;
    if (_isNatureSoundPlaying) {
      _isNatureSoundPlaying = false;
      _syncWebAudio();
    }
    notifyListeners();
  }

  // Kullanıcı sayfadan çıktığında veya iptal
  // ettiğinde
  // sayacı ve çalan doğa sesini güvenle durdurur.
  void stopSession() {
    _timer?.cancel();
    _isActive = false;
    if (_isNatureSoundPlaying) {
      _isNatureSoundPlaying = false;
      _syncWebAudio();
    }
    notifyListeners();
  }

  // Kullanıcı "Yeni Söz" butonuna bastığında
  // listeden
  // farklı bir psikolojik telkin sözü çeker.
  void nextQuote() {
    _pickRandomQuote();
    notifyListeners();
  }

  void _pickRandomQuote() {
    final index = _random.nextInt(quotes.length);
    _currentQuote = quotes[index];
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isNatureSoundPlaying) {
      _isNatureSoundPlaying = false;
      _syncWebAudio();
    }
    super.dispose();
  }
}
