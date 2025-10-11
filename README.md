# 🚗 Otopark Yönetim Sistemi

> **Modern, Hızlı ve Offline Çalışabilen Otopark Yönetim Uygulaması**

Araç takibi, park yeri yönetimi, işlem geçmişi ve sayaç özelliklerine sahip profesyonel otopark yönetim sistemi.

---

## 📋 İçindekiler

- [✨ Özellikler](#-özellikler)
- [🏗️ Mimari](#️-mimari)
- [🚀 Kurulum](#-kurulum)
- [📱 Kullanım](#-kullanım)
- [🔧 Teknik Detaylar](#-teknik-detaylar)
- [📚 Kod Yapısı](#-kod-yapısı)
- [🎓 Junior Developer'lar İçin](#-junior-developerlar-için)
- [🐛 Sorun Giderme](#-sorun-giderme)
- [📞 İletişim](#-i̇letişim)

---

## ✨ Özellikler

### 🚘 Araç Yönetimi
- ✅ **Şase Numarası ile Kayıt** - OCR ile fotoğraftan otomatik okuma
- ✅ **Durum Takibi** - Parkta, Bakımda, Yıkamada, Teslim Edildi
- ✅ **Gerçek Zamanlı Park Süresi** - Anlık süre gösterimi
- ✅ **Hızlı Arama** - Şase, marka, model ile arama

### 🗺️ Otopark Krokisi
- ✅ **Görsel Park Haritası** - 78 park yeri (6 sıra x 13 araç)
- ✅ **6 Servis Alanı** - Yıkama, Bakım, Cila, Detay Temizlik
- ✅ **Renkli Durum Gösterimi** - Boş (yeşil), Dolu (kırmızı)
- ✅ **Dokunmatik Kontrol** - Tıkla ve araç ekle/çıkar

### 📊 İşlem Geçmişi
- ✅ **Tüm Hareketler** - Park, bakım, yıkama, çıkış kayıtları
- ✅ **Filtreleme** - Tarih, tür, şase numarasına göre
- ✅ **CSV Export** - Excel'e aktarma (yakında)

### 🔢 Sayaçlar
- ✅ **Toplam Sayaçlar** - Tüm zamanların toplamı
- ✅ **Aktif Sayaçlar** - Şu anda kaç araç nerede
- ✅ **Gerçek Zamanlı** - Anlık güncelleme

### 🔥 Firebase + Hive (Hybrid DB)
- ✅ **Offline Çalışma** - İnternet olmadan tam özellikli
- ✅ **Otomatik Yedekleme** - Cloud'da güvenli saklama
- ✅ **Multi-Device Sync** - Birden fazla cihazda kullanım
- ✅ **Çok Hızlı** - Lokal veritabanı (Hive) sayesinde

### 📸 Gelişmiş OCR
- ✅ **Google ML Kit** - Yüksek doğruluklu metin tanıma
- ✅ **Görüntü İyileştirme** - Kontrast, gri tonlama
- ✅ **Akıllı Filtreleme** - Şase formatına uygun olanları seçer

---

## 🏗️ Mimari

### **Clean Architecture + Hybrid Database**

```
┌─────────────────────────────────────────────────┐
│                   UI Layer                       │
│    (Riverpod Providers + Flutter Widgets)       │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────┐
│              Domain Layer                        │
│     (Entities, Use Cases, State Machine)        │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────┐
│               Data Layer                         │
│           (Hybrid Repository)                    │
└───────┬───────────────────────────┬─────────────┘
        │                           │
┌───────▼────────┐         ┌────────▼─────────┐
│  Hive (Local)  │         │ Firebase (Cloud) │
│   - Fast       │         │   - Backup       │
│   - Offline    │◄────────┤   - Multi-device │
└────────────────┘  Sync   └──────────────────┘
```

### **Hybrid Database Nasıl Çalışır?**

#### 📝 Yazma İşlemi (Örn: Araç Ekleme)
```
User tıklar "Kaydet"
    ↓
[1] Hive'a kaydet (~10ms) ⚡ Çok hızlı!
    ↓
    UI anında güncellenir ✅
    ↓
[2] Firebase'e kaydet (~500ms) ☁️ Arka planda
    ↓
    Yedek oluşturuldu ✅
```

#### 📖 Okuma İşlemi (Örn: Araç Listesi)
```
User açar "Araçlar" sayfasını
    ↓
Hive'dan oku (~5ms) ⚡ Anında!
    ↓
Liste gösterilir ✅
```

#### 🔄 Senkronizasyon (İlk Açılış)
```
Uygulama açılır
    ↓
Firebase'den tüm veriyi çek
    ↓
Hive'a kaydet
    ↓
Artık offline çalışabilir ✅
```

---

## 🚀 Kurulum

### **Gereksinimler**
- Flutter SDK: `>=3.22.0`
- Dart: `>=3.0.0`
- Android: minSdk 21 (Android 5.0+)
- iOS: 12.0+

### **1. Projeyi Klonla**
```bash
git clone https://github.com/yourname/otopark-demo.git
cd otopark-demo
```

### **2. Bağımlılıkları Yükle**
```bash
flutter pub get
```

### **3. Firebase Kurulumu**

#### a) Firebase Projesi Oluştur
1. [Firebase Console](https://console.firebase.google.com/) → Yeni Proje
2. Proje adı: `otopark-mobile`
3. Analytics: İsteğe bağlı

#### b) Android Uygulaması Ekle
1. Android ikonu tıkla
2. **Package name:** `com.example.otopark_demo`
3. **App nickname:** Otopark Demo
4. **"Register app"** tıkla

#### c) google-services.json İndir
1. **"Download google-services.json"** tıkla
2. İndirilen dosyayı kopyala:
   ```bash
   # Windows
   copy google-services.json android\app\
   
   # macOS/Linux
   cp google-services.json android/app/
   ```

#### d) Firestore'u Aktifleştir
1. Firebase Console → **Build** → **Firestore Database**
2. **"Create database"** tıkla
3. **Test mode** seç (şimdilik güvenli)
4. Location: **eur3 (Europe)** seç
5. **"Enable"** tıkla

### **4. Hive Code Generation**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### **5. Uygulamayı Çalıştır**
```bash
# İlk çalıştırmada eski verileri temizle
flutter run --uninstall-first

# Normal çalıştırma
flutter run
```

---

## 📱 Kullanım

### **🗺️ Kroki Sayfası**

#### **Boş Slot'a Araç Ekle**
1. Kroki haritasında **yeşil (boş)** bir slot'a tıklayın
2. İki seçenek çıkar:
   - **"Yeni Araç Ekle"** → Yeni kayıt oluştur
   - Mevcut araç listesi → Var olan aracı seç
3. Yeni araç için:
   - **Şase:** Kamera ikonuna tıkla → Fotoğraf çek → OCR otomatik okur
   - Marka, Model, Renk gir (opsiyonel)
   - **"Kaydet ve Ata"** tıkla
4. Slot **kırmızı** olur (dolu)

#### **Dolu Slot'tan Araç Çıkar**
1. **Kırmızı (dolu)** slot'a tıkla
2. Araç detayları gösterilir
3. **"Aracı Çıkar"** tıkla
4. Slot **yeşil** olur (boş)

#### **Servis Alanları**
- **Mavi:** Boş servis alanı
- **Turuncu:** Dolu servis alanı
- Tıklayarak araç atama/çıkarma yapabilirsiniz

---

### **🚘 Araçlar Sayfası**

#### **Yeni Araç Ekle**
1. Sağ alt köşe **"+"** butonuna tıkla
2. **Şase Numarası:**
   - Manuel gir **VEYA**
   - 📷 Kamera ikonu → Fotoğraf çek → OCR
3. Marka, Model, Renk (opsiyonel)
4. **"Kaydet"** tıkla

#### **Araç Arama**
1. Üstteki arama çubuğuna yaz
2. Şase, marka veya model ile arama yapabilirsiniz
3. Sonuçlar anında filtrelenir

#### **Araç Detayları**
1. Listeden bir araç seçin
2. Detaylar sayfası açılır:
   - Şase, marka, model, renk
   - **Mevcut durum** (Parkta, Bakımda, vb.)
   - **Park süresi** (eğer park edilmişse)
   - **İşlem geçmişi**

#### **Araç Durumu Değiştir**
1. Araç detaylarında **⋮ (üç nokta)** menü
2. Yeni durum seç:
   - **Bakıma Al** → Araç bakımda
   - **Yıkamaya Al** → Araç yıkamada
   - **Teslimat Alanına Taşı** → Teslim için hazır
   - **Teslim Et** → Araç teslim edildi
   - **Çıkış Yap** → Araç otoparktan çıktı

---

### **📊 İşlemler Sayfası**

#### **Tüm İşlemleri Görüntüle**
- Otomatik olarak en yeni işlem üstte
- Her işlemde:
  - 📅 Tarih ve saat
  - 🚗 Şase numarası
  - 📝 İşlem türü (Park, Bakım, Çıkış, vb.)
  - 📍 Konum bilgisi (varsa)

#### **Filtreleme**
1. Üstteki **filtre ikonu** tıkla
2. Filtre seçenekleri:
   - **Tarih aralığı:** Başlangıç - Bitiş
   - **İşlem türü:** Park, Bakım, Yıkama, vb.
   - **Şase:** Belirli bir araç için

#### **CSV Export** (Yakında)
- Excel'e aktarma özelliği eklenecek

---

### **🔢 Sayaçlar Sayfası**

#### **Toplam Sayaçlar**
- **Toplam Park Edilen Araç:** Tüm zamanların toplamı
- **Toplam Bakım İşlemi:** Kaç kez bakıma alındı
- **Toplam Yıkama İşlemi:** Kaç kez yıkandı
- **Toplam Teslim Edilen:** Kaç araç teslim edildi

#### **Aktif Sayaçlar** (Şu Anda)
- **Parkta:** Kaç araç park alanında
- **Bakımda:** Kaç araç bakım alanında
- **Yıkamada:** Kaç araç yıkama alanında

---

## 🔧 Teknik Detaylar

### **State Management**
- **Riverpod 2.6.1** - Reactive state management
- **AsyncNotifierProvider** - Asenkron veri yönetimi
- **StreamProvider** - Gerçek zamanlı güncellemeler

### **Veritabanı**
- **Hive 2.2.3** - Lokal NoSQL database
- **Firebase Firestore 5.6.12** - Cloud database
- **Hybrid Pattern** - İki veritabanı birlikte

### **Routing**
- **go_router 14.8.1** - Declarative routing
- **ShellRoute** - Bottom navigation yapısı

### **OCR (Görüntü İşleme)**
- **google_mlkit_text_recognition 0.13.1** - ML Kit OCR
- **image 4.0.17** - Görüntü ön işleme
- **image_picker 1.0.4** - Kamera/galeri erişimi

### **Utilities**
- **uuid 4.5.1** - Benzersiz ID oluşturma
- **intl 0.19.0** - Tarih/saat formatlama
- **connectivity_plus 6.1.5** - İnternet durumu kontrolü

---

## 📚 Kod Yapısı

```
lib/
├── main.dart                      # Uygulama giriş noktası
├── app/
│   ├── app.dart                   # MaterialApp + tema
│   ├── router.dart                # Go Router yapılandırması
│   └── shell_page.dart            # Bottom navigation
│
├── core/                          # Paylaşılan kod
│   ├── db/
│   │   ├── hive_init.dart         # Hive başlatma
│   │   ├── firebase_init.dart     # Firebase başlatma
│   │   ├── sync_service.dart      # 🔥 Firebase senkronizasyon
│   │   └── cleanup_service.dart   # 🧹 Veri tutarlılığı
│   └── utils/
│       ├── formatters.dart        # Tarih/saat formatları
│       ├── validators.dart        # Form doğrulama
│       └── ocr_helper.dart        # 📸 OCR yardımcıları
│
└── features/                      # Özellikler (modüler)
    │
    ├── kroki/                     # 🗺️ Otopark Haritası
    │   └── presentation/
    │       └── kroki_page_new.dart
    │
    ├── vehicles/                  # 🚘 Araç Yönetimi
    │   ├── data/
    │   │   └── vehicle_repository.dart  # 🔄 Hybrid DB
    │   ├── domain/
    │   │   ├── vehicle.dart             # Araç modeli
    │   │   ├── vehicle_status.dart      # Durum enum
    │   │   └── usecases/
    │   │       └── change_vehicle_status_usecase.dart
    │   ├── presentation/
    │   │   ├── vehicles_page.dart       # Liste sayfası
    │   │   ├── vehicle_detail_page.dart # Detay sayfası
    │   │   └── add_vehicle_sheet.dart   # Ekleme formu
    │   └── providers/
    │       └── vehicle_providers.dart    # Riverpod providers
    │
    ├── park_slots/                # 🅿️ Park Yerleri
    │   ├── data/
    │   │   └── slot_repository.dart
    │   ├── domain/
    │   │   └── park_slot.dart
    │   ├── presentation/
    │   │   └── park_slots_page.dart
    │   └── providers/
    │       └── slot_providers.dart
    │
    ├── operations/                # 📊 İşlem Geçmişi
    │   ├── data/
    │   │   └── operation_repository.dart
    │   ├── domain/
    │   │   ├── operation.dart
    │   │   └── operation_type.dart
    │   ├── presentation/
    │   │   └── operations_page.dart
    │   └── providers/
    │       └── operation_providers.dart
    │
    └── counters/                  # 🔢 Sayaçlar
        ├── data/
        │   └── counter_repository.dart
        ├── domain/
        │   └── counters.dart
        ├── presentation/
        │   └── counters_page.dart
        └── providers/
            └── counter_providers.dart
```

---

## 🎓 Junior Developer'lar İçin

### **🤔 Sıkça Sorulan Sorular**

#### **Q: Riverpod nedir? Neden kullanıyoruz?**
**A:** State management kütüphanesi. Provider'ın gelişmiş hali.

```dart
// Eski yöntem (setState)
class MyPage extends StatefulWidget {
  // Karmaşık, her widget için yeniden yazmak gerekir
}

// Riverpod ile
final vehiclesProvider = AsyncNotifierProvider<...>(...);

// Kullanımı:
ref.watch(vehiclesProvider); // Otomatik güncellenir!
```

**Avantajları:**
- ✅ Global state (her yerden erişilebilir)
- ✅ Otomatik UI güncellemesi
- ✅ Kolay test edilebilir
- ✅ Dependency injection

---

#### **Q: Hive vs Firebase hangisi daha iyi?**
**A:** İkisi farklı amaçlar için. Beraber kullanıyoruz!

| Özellik | Hive | Firebase |
|---------|------|----------|
| Hız | ⚡⚡⚡ Çok hızlı | 🐢 Yavaş |
| Offline | ✅ Evet | ❌ Hayır |
| Yedek | ❌ Yok | ✅ Otomatik |
| Multi-device | ❌ Hayır | ✅ Evet |
| Maliyet | 🆓 Bedava | 💰 Ücretli (kotası var) |

**Çözüm:** Hive + Firebase = En iyisi! 🎯

---

#### **Q: async/await nedir?**
**A:** Asenkron programlama için kullanılır.

```dart
// ❌ YANLIŞ - Senkron (beklemez)
void getData() {
  var data = database.get(); // Bu hemen çalışmaz!
  print(data); // null olur!
}

// ✅ DOĞRU - Asenkron (bekler)
Future<void> getData() async {
  var data = await database.get(); // Bekle, bitsin
  print(data); // Doğru veri!
}
```

**await:** "Bekle bu iş bitsin"
**async:** "Bu fonksiyon bekleyebilir"

---

#### **Q: Repository Pattern nedir?**
**A:** Veritabanı kodunu UI'dan ayırma yöntemi.

```dart
// ❌ YANLIŞ - UI'da veritabanı kodu
class MyPage extends StatelessWidget {
  void save() {
    Hive.box('cars').put('car1', car); // Karışık!
  }
}

// ✅ DOĞRU - Repository kullan
class MyPage extends StatelessWidget {
  void save() {
    repository.addVehicle(car); // Temiz!
  }
}
```

**Avantajları:**
- ✅ Kolay test (mock repository)
- ✅ Temiz kod
- ✅ Değiştirmesi kolay (Hive → SQLite geçiş)

---

### **📖 Kod Okuma Rehberi**

#### **Adım 1: main.dart'tan başla**
```dart
void main() async {
  await FirebaseInit.initialize();  // 1. Firebase başlat
  await initHive();                 // 2. Hive başlat
  await SyncService.initialize();   // 3. Sync servis başlat
  runApp(...);                      // 4. Uygulamayı başlat
}
```

#### **Adım 2: router.dart'a bak**
```dart
// Hangi sayfa hangi URL'de?
'/kroki' → KrokiPageNew()
'/vehicles' → VehiclesPage()
'/operations' → OperationsPage()
'/counters' → CountersPage()
```

#### **Adım 3: Bir özelliği takip et**

**Örnek: Araç Ekleme**

1. **UI:** `add_vehicle_sheet.dart`
   ```dart
   ElevatedButton(
     onPressed: _addVehicle, // ← Buradan başla
   )
   ```

2. **Provider:** `vehicle_providers.dart`
   ```dart
   Future<void> addVehicle(Vehicle vehicle) async {
     await repository.addVehicle(vehicle); // ← Repository'ye git
   }
   ```

3. **Repository:** `vehicle_repository.dart`
   ```dart
   Future<void> addVehicle(Vehicle vehicle) async {
     await _vehicleBox.put(...);  // Hive'a kaydet
     await SyncService.setData(...); // Firebase'e kaydet
   }
   ```

4. **Sync Service:** `sync_service.dart`
   ```dart
   static Future<void> setData(...) async {
     await _firestore.collection(...).doc(...).set(...);
   }
   ```

---

## 🐛 Sorun Giderme

### **Hata: "Hive box already open"**
**Çözüm:**
```bash
flutter run --uninstall-first
```

### **Hata: "google-services.json not found"**
**Çözüm:**
1. Firebase Console'dan `google-services.json` indir
2. `android/app/` klasörüne kopyala
3. Uygulamayı tekrar derle

### **Hata: "Type 'String' is not a subtype of 'VehicleStatus'"**
**Çözüm:** Eski veri var, temizle:
```bash
flutter clean
flutter pub get
flutter run --uninstall-first
```

### **OCR çalışmıyor / Fotoğraf çekemiyor**
**Çözüm:**
1. **Android:** `AndroidManifest.xml`'de kamera izni var mı kontrol et
2. **iOS:** `Info.plist`'de kamera izni var mı kontrol et
3. Gerçek cihazda test et (emulator'da OCR yavaş)

### **Uygulama donuyor**
**Neden:** Görüntü işleme ağır olabilir
**Çözüm:** Kod optimize edildi, en son versiyonu kullanın

### **Firebase'e kaydetmiyor**
**Kontrol Et:**
1. İnternet bağlantısı var mı?
2. Firestore aktif mi? (Firebase Console'dan kontrol et)
3. Console'da hata var mı? (`print` loglarına bak)

---


---

## 🎯 Gelecek Özellikler (Roadmap)

- [ ] 📊 CSV/Excel export (İşlemler)
- [ ] 📈 Grafik ve raporlama
- [ ] 🔔 Bildirimler (Araç X saati aştı)
- [ ] 👥 Kullanıcı yönetimi (Admin/Personel)
- [ ] 📱 iOS versiyonu
- [ ] 🌐 Web versiyonu
- [ ] 🔍 Gelişmiş filtreleme
- [ ] ⏪ Undo/Redo (10 dk geri alma)
- [ ] 🎨 Tema seçimi (Dark mode)
- [ ] 🌍 Çoklu dil desteği

---

<div align="center">

**⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın! ⭐**

Made with ❤️ and ☕ by eslemnuryildirim

</div>
