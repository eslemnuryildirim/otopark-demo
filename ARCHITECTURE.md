# 🏗️ Proje Mimarisi - Junior Developer Rehberi

> **"Neden bu şekilde yapıldı?"** sorularına cevaplar bulacağınız kapsamlı mimari rehber.

---

## 📚 İçindekiler

1. [Proje Yapısı Genel Bakış](#-proje-yapısı-genel-bakış)
2. [Mimari Yaklaşım (Clean Architecture)](#-mimari-yaklaşım)
3. [Klasör Yapısı Detayı](#-klasör-yapısı-detayı)
4. [State Management (Riverpod)](#-state-management-riverpod)
5. [Veritabanı Mimarisi (Hybrid DB)](#-veritabanı-mimarisi)
6. [Veri Akışı (Data Flow)](#-veri-akışı)
7. [Özellik Bazlı Organizasyon](#-özellik-bazlı-organizasyon)
8. [Önemli Kavramlar](#-önemli-kavramlar)
9. [Yeni Özellik Ekleme Rehberi](#-yeni-özellik-ekleme-rehberi)
10. [Sık Yapılan Hatalar](#-sık-yapılan-hatalar)

---

## 🗂️ Proje Yapısı Genel Bakış

```
otopark_demo/
├── lib/
│   ├── main.dart                 # 🚀 Uygulama başlangıç noktası
│   ├── app/                      # 📱 Uygulama seviyesi kod
│   ├── core/                     # 🔧 Paylaşılan araçlar
│   └── features/                 # 🎯 Özellikler (modüler)
├── test/                         # 🧪 Test dosyaları
├── android/                      # 🤖 Android yapılandırması
├── ios/                          # 🍎 iOS yapılandırması
├── pubspec.yaml                  # 📦 Bağımlılıklar
└── README.md                     # 📖 Kullanım kılavuzu
```

### **❓ Neden bu yapı?**

Bu yapı **"Feature-First"** (Özellik Öncelikli) yaklaşımını takip eder:

✅ **Modüler:** Her özellik kendi klasöründe → Kolay bakım  
✅ **Ölçeklenebilir:** Yeni özellik eklemek basit  
✅ **Okunabilir:** Hangi kod neyi yapıyor anlaşılır  
✅ **Test Edilebilir:** Her modül bağımsız test edilebilir  

---

## 🧱 Mimari Yaklaşım

### **Clean Architecture (Temiz Mimari) Nedir?**

Clean Architecture, kodun **katmanlara** ayrılması prensibidir. Her katman sadece **kendinden alt katmanları** bilir.

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │  ← UI (Widgets, Pages)
│  (Kullanıcı arayüzü, butonlar, ekranlar) │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          PROVIDERS LAYER                │  ← State Management
│   (Riverpod providers, state notifiers) │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│          DOMAIN LAYER                   │  ← İş Mantığı (Business Logic)
│  (Entities, Use Cases, State Machine)   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           DATA LAYER                    │  ← Veritabanı Erişimi
│       (Repositories, Data Sources)      │
└──────────────┬──────────────────────────┘
               │
      ┌────────▼────────┐
      │  HIVE (Local)   │  FIREBASE (Cloud)
      └─────────────────┘
```

### **❓ Neden Clean Architecture?**

**Senaryo:** Yarın Hive yerine SQLite kullanmak istiyorsun.

❌ **Kötü Kod:** Tüm UI kodunda `Hive.box` çağrıları var → Her yeri değiştirmen lazım (100+ dosya)  
✅ **Clean Architecture:** Sadece `Repository` sınıfını değiştirirsin (1 dosya)

**Avantajlar:**
- 🔄 **Kolay Değişim:** Veritabanı/API değişimi kolay
- 🧪 **Test Edilebilir:** Her katman bağımsız test edilebilir
- 👥 **Takım Çalışması:** Farklı kişiler farklı katmanlarda çalışabilir
- 📖 **Okunabilir:** Sorumluluklar net

---

## 📁 Klasör Yapısı Detayı

### **1️⃣ `lib/main.dart` - Uygulama Başlangıcı**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase başlat
  await FirebaseInit.initialize();
  
  // 2. Hive başlat (TypeAdapter'lar kaydet, box'ları aç)
  await initHive();
  
  // 3. Sync servisini başlat (internet durumu dinle)
  await SyncService.initialize();
  
  // 4. Cleanup servisi (veri tutarlılığı kontrolü)
  await CleanupService.cleanupAll();
  
  // 5. Uygulamayı başlat
  runApp(const ProviderScope(child: MyApp()));
}
```

**❓ Neden bu sıralama önemli?**

- Firebase **önce** başlatılmalı çünkü Firestore kullanacağız
- Hive **sonra** açılmalı çünkü TypeAdapter'lar kaydedilmeli
- Cleanup **en son** çünkü box'lar açık olmalı

---

### **2️⃣ `lib/app/` - Uygulama Seviyesi**

```
app/
├── app.dart           # MaterialApp + Tema
├── router.dart        # Go Router yapılandırması (URL routing)
└── shell_page.dart    # Bottom Navigation (Kroki, Araçlar, İşlemler, Sayaçlar)
```

#### **`router.dart` - Navigation Neden Böyle?**

```dart
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/kroki',
    routes: [
      ShellRoute(  // ← ShellRoute = Alt navigasyon her sayfada görünür
        builder: (context, state, child) => ShellPage(child: child),
        routes: [
          GoRoute(path: '/kroki', ...),
          GoRoute(path: '/vehicles', ...),
          GoRoute(path: '/operations', ...),
          GoRoute(path: '/counters', ...),
        ],
      ),
    ],
  );
});
```

**❓ Neden ShellRoute?**

ShellRoute kullanmazsak, her sayfada `BottomNavigationBar` tekrar tekrar render edilir → **Gereksiz yük**

ShellRoute ile:
- ✅ Bottom navigation **bir kere** oluşturulur
- ✅ Sayfa değişimlerinde sadece `child` değişir
- ✅ Performans artışı

---

### **3️⃣ `lib/core/` - Paylaşılan Kod**

```
core/
├── db/
│   ├── hive_init.dart           # 📦 Hive başlatma + TypeAdapter kayıt
│   ├── firebase_init.dart       # 🔥 Firebase başlatma
│   ├── sync_service.dart        # 🔄 Hive ↔ Firebase senkronizasyon
│   ├── cleanup_service.dart     # 🧹 Veri tutarlılığı kontrolü
│   └── duration_adapter.dart    # ⏱️ Duration için Hive adapter
└── utils/
    ├── formatters.dart          # 📅 Tarih/saat formatları
    ├── validators.dart          # ✅ Form validation
    └── ocr_helper.dart          # 📸 OCR (görüntüden metin okuma)
```

#### **`sync_service.dart` - Hybrid DB Neden?**

**Senaryo:** Kullanıcı metro'da (internet yok) → Araç ekler

❌ **Sadece Firebase:** İnternet yokken uygulama çalışmaz  
❌ **Sadece Hive:** Veriler cihazda kaybolabilir, multi-device yok  
✅ **Hybrid (Hive + Firebase):** 
  - İnternet yokken Hive'a kaydet → Uygulama çalışır
  - İnternet gelince Firebase'e gönder → Yedek + Multi-device

```dart
// Yazma işlemi
await _vehicleBox.put(vehicle.id, vehicle);  // 1. Hive'a kaydet (hızlı)
await SyncService.setData(...);               // 2. Firebase'e kaydet (yavaş ama güvenli)
```

**Avantajları:**
- ⚡ **Çok hızlı:** Hive'dan okuma ~5ms
- 📴 **Offline çalışır:** İnternet yokken de kullanılabilir
- ☁️ **Yedekleme:** Firebase'de güvenli
- 📱 **Multi-device:** Farklı cihazlarda senkronize

---

### **4️⃣ `lib/features/` - Özellikler (Modüler)**

Her özellik **kendi klasöründe** ve **aynı yapıda**:

```
features/
├── vehicles/           # 🚗 Araç Yönetimi
├── operations/         # 📊 İşlem Geçmişi
├── counters/          # 🔢 Sayaçlar
├── park_slots/        # 🅿️ Park Yerleri
└── kroki/             # 🗺️ Otopark Haritası
```

#### **Her özellik içinde aynı yapı:**

```
vehicles/
├── data/
│   └── vehicle_repository.dart       # 📦 Veritabanı işlemleri
├── domain/
│   ├── vehicle.dart                  # 📄 Veri modeli (Entity)
│   ├── vehicle_status.dart           # 🎯 Enum + Extension
│   ├── vehicle_state_machine.dart    # 🤖 Durum geçişleri
│   └── usecases/
│       └── change_vehicle_status_usecase.dart  # 💼 İş mantığı
├── presentation/
│   ├── vehicles_page.dart            # 📱 Liste ekranı
│   ├── vehicle_detail_page.dart      # 📱 Detay ekranı
│   └── add_vehicle_sheet.dart        # 📱 Ekleme formu
└── providers/
    ├── vehicle_providers.dart        # 🔌 Riverpod providers
    └── park_timer_provider.dart      # ⏱️ Gerçek zamanlı timer
```

---

## 🧩 Her Katmanın Görevi

### **📦 Data Layer (Veritabanı Katmanı)**

**Sorumluluk:** Veritabanı ile konuşmak (CRUD işlemleri)

```dart
// vehicle_repository.dart
abstract class VehicleRepository {
  Future<List<Vehicle>> getVehicles();
  Future<void> addVehicle(Vehicle vehicle);
  Future<void> updateVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String id);
}

class HybridVehicleRepository implements VehicleRepository {
  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    // 1. Hive'a kaydet
    await _vehicleBox.put(vehicle.id, vehicle);
    
    // 2. Firebase'e kaydet
    await SyncService.setData(
      collection: 'vehicles',
      docId: vehicle.id,
      data: vehicle.toJson(),
    );
  }
}
```

**❓ Neden Abstract Class?**

```dart
// Test yaparken
class MockVehicleRepository implements VehicleRepository {
  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    // Gerçek veritabanı yok, sadece listeye ekle
    _mockList.add(vehicle);
  }
}
```

Abstract class sayesinde:
- ✅ Test'te mock kullanabilirsin
- ✅ Hive → SQLite geçiş kolay
- ✅ Kod temiz ve anlaşılır

---

### **🎯 Domain Layer (İş Mantığı Katmanı)**

**Sorumluluk:** İş kurallarını yönetmek

#### **1. Entity (Veri Modeli)**

```dart
// vehicle.dart
@HiveType(typeId: 0)
class Vehicle {
  @HiveField(0) final String id;
  @HiveField(1) final String plate;
  @HiveField(2) final String? brand;
  @HiveField(3) final VehicleStatus status;
  
  // copyWith metodu (immutable yapı için)
  Vehicle copyWith({String? plate, VehicleStatus? status}) { ... }
  
  // JSON dönüşümü (Firebase için)
  Map<String, dynamic> toJson() { ... }
  factory Vehicle.fromJson(Map<String, dynamic> json) { ... }
}
```

**❓ Neden @HiveField?**

Hive, field'ları **index** ile saklar (boyut küçük, hızlı):
```
// Veritabanında:
{0: "v123", 1: "34ABC123", 3: 0}  // ← Çok küçük!

// JSON ile:
{"id":"v123", "plate":"34ABC123", "status":"parked"}  // ← Büyük
```

**❓ Neden copyWith?**

Dart'ta **immutability** (değişmezlik) önemli:

```dart
// ❌ Mutable (değişebilir) - Tehlikeli!
vehicle.status = VehicleStatus.inWash;

// ✅ Immutable (değişmez) - Güvenli!
final updatedVehicle = vehicle.copyWith(status: VehicleStatus.inWash);
```

Avantajları:
- 🔒 Thread-safe (eşzamanlılık sorunları yok)
- 🐛 Bug'ları bulmak kolay
- 🔄 State management daha güvenli

---

#### **2. Enum + Extension (Durum)**

```dart
// vehicle_status.dart
enum VehicleStatus {
  parked,
  inMaintenance,
  inWash,
  inDeliveryQueue,
  delivered,
  exited,
}

extension VehicleStatusExtension on VehicleStatus {
  String get displayName {
    switch (this) {
      case VehicleStatus.parked: return 'Parkta';
      case VehicleStatus.inMaintenance: return 'Bakımda';
      // ...
    }
  }
  
  Color get color { ... }
  IconData get icon { ... }
}
```

**❓ Neden Extension?**

Enum'a method ekleyemezsin, ama extension ile ekleyebilirsin:

```dart
// Kullanımı:
Text(vehicle.status.displayName);  // "Parkta"
Icon(vehicle.status.icon, color: vehicle.status.color);
```

Avantajları:
- ✅ DRY (Don't Repeat Yourself)
- ✅ Değişiklik tek yerden
- ✅ Tip güvenli

---

#### **3. Use Case (İş Mantığı)**

```dart
// change_vehicle_status_usecase.dart
class ChangeVehicleStatusUseCase {
  ChangeVehicleStatusResult execute({
    required Vehicle vehicle,
    required VehicleStatus newStatus,
    String? targetSlotId,
  }) {
    // 1. İş kuralı: Geçiş kontrolü
    if (!VehicleStateMachine.canTransition(vehicle.status, newStatus)) {
      return ChangeVehicleStatusResult(
        success: false,
        error: 'Bu geçiş yapılamaz!',
      );
    }
    
    // 2. İş kuralı: Slot kontrolü
    if (VehicleStateMachine.requiresSlot(newStatus) && targetSlotId == null) {
      return ChangeVehicleStatusResult(
        success: false,
        error: 'Park için slot seçmelisiniz!',
      );
    }
    
    // 3. Aracı güncelle
    final updatedVehicle = vehicle.copyWith(
      status: newStatus,
      currentParkSlotId: newStatus == VehicleStatus.parked ? targetSlotId : null,
    );
    
    // 4. Operation oluştur
    final operation = Operation(...);
    
    // 5. Sayaç güncellemelerini hesapla
    final counterUpdates = _calculateCounterUpdates(vehicle.status, newStatus);
    
    return ChangeVehicleStatusResult(
      success: true,
      updatedVehicle: updatedVehicle,
      operation: operation,
      counterUpdates: counterUpdates,
    );
  }
}
```

**❓ Neden Use Case?**

İş mantığı **bir yerde** toplanmalı:

```dart
// ❌ İş mantığı UI'da (Kötü!)
void _onButtonPressed() {
  if (vehicle.status == VehicleStatus.parked && newStatus == VehicleStatus.inWash) {
    // Sayaçları güncelle
    counters.totalWash++;
    counters.activePark--;
    counters.activeWash++;
    
    // Slotu boşalt
    slot.isOccupied = false;
    
    // Aracı güncelle
    vehicle.status = VehicleStatus.inWash;
    
    // ...30 satır daha kod
  }
}

// ✅ İş mantığı Use Case'de (İyi!)
void _onButtonPressed() {
  final result = changeVehicleStatusUseCase.execute(
    vehicle: vehicle,
    newStatus: VehicleStatus.inWash,
  );
  
  if (result.success) {
    // Repository'ye kaydet
  }
}
```

Avantajları:
- ✅ Test edilebilir
- ✅ Yeniden kullanılabilir
- ✅ UI temiz kalır
- ✅ İş kuralları merkezi

---

### **🔌 Providers Layer (State Management)**

**Sorumluluk:** UI ile Domain arasında köprü

```dart
// vehicle_providers.dart

// Repository provider
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final repository = HybridVehicleRepository();
  repository.init();
  return repository;
});

// Vehicles provider (AsyncNotifier)
final vehiclesProvider = AsyncNotifierProvider<VehiclesNotifier, List<Vehicle>>(
  VehiclesNotifier.new,
);

class VehiclesNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    // İlk yükleme
    return ref.watch(vehicleRepositoryProvider).getVehicles();
  }
  
  Future<void> addVehicle(Vehicle vehicle) async {
    state = const AsyncValue.loading();  // ← Loading göster
    
    await ref.read(vehicleRepositoryProvider).addVehicle(vehicle);
    
    state = AsyncValue.data(  // ← Başarılı
      await ref.read(vehicleRepositoryProvider).getVehicles(),
    );
  }
  
  Future<String?> changeVehicleStatus({
    required Vehicle vehicle,
    required VehicleStatus newStatus,
    String? targetSlotId,
  }) async {
    // UseCase kullan
    final useCase = ChangeVehicleStatusUseCase();
    final result = useCase.execute(...);
    
    if (!result.success) {
      return result.error;
    }
    
    // 1. Aracı güncelle
    await ref.read(vehicleRepositoryProvider).updateVehicle(result.updatedVehicle!);
    
    // 2. Operation ekle
    await ref.read(operationsProvider.notifier).addOperation(result.operation!);
    
    // 3. Sayaçları güncelle
    await ref.read(countersProvider.notifier).applyUpdates(result.counterUpdates!);
    
    // 4. Slot'ları güncelle
    if (result.fromSlotId != null) {
      await ref.read(slotsProvider.notifier).vacateSlot(result.fromSlotId!);
    }
    
    // 5. UI'ı yenile
    state = AsyncValue.data(
      await ref.read(vehicleRepositoryProvider).getVehicles(),
    );
    
    return null; // Başarılı
  }
}
```

**❓ Neden AsyncNotifier?**

```dart
// UI'da kullanımı
final vehiclesAsync = ref.watch(vehiclesProvider);

vehiclesAsync.when(
  data: (vehicles) => ListView.builder(...),  // ← Veri geldi
  loading: () => CircularProgressIndicator(),  // ← Yükleniyor
  error: (err, stack) => Text('Hata: $err'),  // ← Hata
);
```

Avantajları:
- ✅ Loading/error durumları otomatik
- ✅ Reactive (veri değişince UI güncellenir)
- ✅ Global state (her yerden erişilebilir)

---

### **📱 Presentation Layer (UI Katmanı)**

**Sorumluluk:** Kullanıcı arayüzü

```dart
// vehicles_page.dart
class VehiclesPage extends ConsumerStatefulWidget { ... }

class _VehiclesPageState extends ConsumerState<VehiclesPage> {
  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);  // ← Provider'ı dinle
    
    return Scaffold(
      appBar: AppBar(title: Text('Araçlar')),
      body: vehiclesAsync.when(
        data: (vehicles) => ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return ListTile(
              title: Text(vehicle.plate),
              subtitle: Text(vehicle.status.displayName),
              trailing: PopupMenuButton(
                onSelected: (newStatus) {
                  // Provider'ı çağır
                  ref.read(vehiclesProvider.notifier).changeVehicleStatus(
                    vehicle: vehicle,
                    newStatus: newStatus,
                  );
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: VehicleStatus.inWash, ...),
                  PopupMenuItem(value: VehicleStatus.inMaintenance, ...),
                ],
              ),
            );
          },
        ),
        loading: () => CircularProgressIndicator(),
        error: (err, stack) => Text('Hata: $err'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleSheet(),
      ),
    );
  }
}
```

**❓ ConsumerWidget vs ConsumerStatefulWidget?**

```dart
// ❌ Stateless ama Provider kullanan
class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    // Provider'a erişemezsin!
  }
}

// ✅ ConsumerWidget (Stateless + Provider)
class MyWidget extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(myProvider);  // ← Erişebilirsin!
  }
}

// ✅ ConsumerStatefulWidget (Stateful + Provider)
class MyWidget extends ConsumerStatefulWidget { ... }
```

---

## 🔄 Veri Akışı (Data Flow)

### **Okuma İşlemi (Read)**

```
┌─────────┐     watch      ┌──────────────┐     read      ┌────────────┐     get      ┌──────┐
│   UI    │ ───────────► │   Provider   │ ───────────► │ Repository │ ─────────► │ Hive │
└─────────┘               └──────────────┘               └────────────┘             └──────┘
   Widget                  vehiclesProvider              VehicleRepository          Box<Vehicle>
```

**Adım Adım:**

1. **UI:** `ref.watch(vehiclesProvider)` çağrısı yapar
2. **Provider:** `VehiclesNotifier.build()` tetiklenir
3. **Repository:** `getVehicles()` metodu çağrılır
4. **Hive:** `_vehicleBox.values.toList()` döner
5. **Provider:** Veriyi `AsyncValue.data(list)` olarak wrap eder
6. **UI:** `when(data: (list) => ...)` içindeki kod çalışır

---

### **Yazma İşlemi (Write)**

```
┌─────────┐    call    ┌──────────────┐   execute   ┌──────────┐    apply    ┌────────────┐   put    ┌──────┐
│   UI    │ ────────► │   Provider   │ ─────────► │ UseCase  │ ─────────► │ Repository │ ──────► │ Hive │
└─────────┘            └──────────────┘             └──────────┘             └────────────┘          └──────┘
  Button                  .notifier                ChangeVehicle             updateVehicle           .put()
                     .changeVehicleStatus          StatusUseCase
                                                        │
                                                        ▼
                                                   ┌──────────┐
                                                   │  Sync    │
                                                   │ Service  │ ────► Firebase
                                                   └──────────┘
```

**Adım Adım:**

1. **UI:** Kullanıcı buton'a basar
2. **Provider:** `changeVehicleStatus()` çağrılır
3. **UseCase:** İş kuralları kontrol edilir
4. **Repository:** `updateVehicle()` çağrılır
5. **Hive:** `_vehicleBox.put()` ile kaydet
6. **SyncService:** Firebase'e gönder
7. **Provider:** `state` güncelle
8. **UI:** Otomatik rebuild

---

## 🎯 Özellik Bazlı Organizasyon

### **Yeni Özellik Ekleme: "Araç Fotoğrafları"**

#### **Adım 1: Domain Layer**

```dart
// 1. features/vehicle_photos/domain/vehicle_photo.dart
@HiveType(typeId: 6)
class VehiclePhoto {
  @HiveField(0) final String id;
  @HiveField(1) final String vehicleId;
  @HiveField(2) final String imagePath;
  @HiveField(3) final DateTime takenAt;
}
```

#### **Adım 2: Data Layer**

```dart
// 2. features/vehicle_photos/data/photo_repository.dart
abstract class PhotoRepository {
  Future<List<VehiclePhoto>> getPhotos(String vehicleId);
  Future<void> addPhoto(VehiclePhoto photo);
  Future<void> deletePhoto(String id);
}

class HivePhotoRepository implements PhotoRepository {
  Box<VehiclePhoto> get _photoBox => Hive.box<VehiclePhoto>('vehicle_photos');
  
  @override
  Future<List<VehiclePhoto>> getPhotos(String vehicleId) async {
    return _photoBox.values.where((p) => p.vehicleId == vehicleId).toList();
  }
  
  @override
  Future<void> addPhoto(VehiclePhoto photo) async {
    await _photoBox.put(photo.id, photo);
  }
}
```

#### **Adım 3: Providers Layer**

```dart
// 3. features/vehicle_photos/providers/photo_providers.dart
final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return HivePhotoRepository();
});

final photosProvider = StreamProvider.family<List<VehiclePhoto>, String>((ref, vehicleId) {
  return ref.watch(photoRepositoryProvider).getPhotos(vehicleId).asStream();
});

final photosNotifierProvider = Provider((ref) => PhotosNotifier(ref));

class PhotosNotifier {
  final Ref ref;
  PhotosNotifier(this.ref);
  
  Future<void> addPhoto(String vehicleId, XFile file) async {
    // Fotoğrafı kaydet
    final photo = VehiclePhoto(
      id: Uuid().v4(),
      vehicleId: vehicleId,
      imagePath: file.path,
      takenAt: DateTime.now(),
    );
    
    await ref.read(photoRepositoryProvider).addPhoto(photo);
    
    // Provider'ı yenile
    ref.invalidate(photosProvider(vehicleId));
  }
}
```

#### **Adım 4: Presentation Layer**

```dart
// 4. features/vehicle_photos/presentation/photos_page.dart
class VehiclePhotosPage extends ConsumerWidget {
  final String vehicleId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosProvider(vehicleId));
    
    return Scaffold(
      appBar: AppBar(title: Text('Fotoğraflar')),
      body: photosAsync.when(
        data: (photos) => GridView.builder(
          itemCount: photos.length,
          itemBuilder: (context, index) {
            return Image.file(File(photos[index].imagePath));
          },
        ),
        loading: () => CircularProgressIndicator(),
        error: (err, stack) => Text('Hata: $err'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final picker = ImagePicker();
          final file = await picker.pickImage(source: ImageSource.camera);
          if (file != null) {
            await ref.read(photosNotifierProvider).addPhoto(vehicleId, file);
          }
        },
      ),
    );
  }
}
```

#### **Adım 5: Hive Init**

```dart
// 5. core/db/hive_init.dart
Future<void> initHive() async {
  await Hive.initFlutter();
  
  // TypeAdapter'ları kaydet
  Hive.registerAdapter(VehiclePhotoAdapter());  // ← Yeni adapter
  
  // Box'ları aç
  await Hive.openBox<VehiclePhoto>('vehicle_photos');  // ← Yeni box
}
```

---

## 💡 Önemli Kavramlar

### **1. Immutability (Değişmezlik)**

```dart
// ❌ Mutable
class Vehicle {
  String plate;
  VehicleStatus status;
}

vehicle.status = VehicleStatus.inWash;  // ← Tehlikeli!

// ✅ Immutable
class Vehicle {
  final String plate;
  final VehicleStatus status;
  
  Vehicle copyWith({VehicleStatus? status}) => Vehicle(
    plate: this.plate,
    status: status ?? this.status,
  );
}

final updated = vehicle.copyWith(status: VehicleStatus.inWash);  // ← Güvenli!
```

**Neden?**
- Thread-safe
- State management güvenli
- Bug'ları bulmak kolay

---

### **2. Dependency Injection (Riverpod)**

```dart
// ❌ Hard-coded dependency
class VehiclesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repository = HiveVehicleRepository();  // ← Kötü!
    final vehicles = repository.getVehicles();
  }
}

// ✅ Dependency Injection (Riverpod)
class VehiclesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);  // ← İyi!
  }
}
```

**Avantajları:**
- Test'te mock kullanabilirsin
- Bağımlılıklar merkezi
- Loose coupling (gevşek bağlılık)

---

### **3. Repository Pattern**

```dart
// Repository = Veritabanı ile konuşan tek yer

// ❌ UI'da veritabanı kodu
class VehiclesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Vehicle>('vehicles');
    final vehicles = box.values.toList();  // ← Kötü!
  }
}

// ✅ Repository kullan
class VehiclesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);  // ← İyi!
  }
}
```

**Avantajları:**
- Hive → SQLite geçiş kolay
- Test edilebilir
- UI temiz

---

### **4. Use Case Pattern**

```dart
// Use Case = İş mantığının olduğu yer

// ❌ İş mantığı UI'da
void _onStatusChange(VehicleStatus newStatus) {
  if (vehicle.status == VehicleStatus.parked && newStatus == VehicleStatus.inWash) {
    // 50 satır iş mantığı...
  }
}

// ✅ Use Case kullan
void _onStatusChange(VehicleStatus newStatus) {
  final result = changeVehicleStatusUseCase.execute(
    vehicle: vehicle,
    newStatus: newStatus,
  );
  
  if (result.success) {
    // Kaydet
  } else {
    // Hata göster
  }
}
```

---

## 🚫 Sık Yapılan Hatalar

### **❌ 1. Provider'ı build() içinde okumak**

```dart
// ❌ Yanlış
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        final data = ref.watch(myProvider);  // ← watch build() içinde olmalı!
      },
    );
  }
}

// ✅ Doğru
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(myProvider);  // ← Build içinde
    
    return ElevatedButton(
      onPressed: () {
        ref.read(myProvider.notifier).doSomething();  // ← Action için read
      },
    );
  }
}
```

---

### **❌ 2. Hive TypeAdapter'ını kaydetmemek**

```dart
// ❌ Hata verir: "Cannot write unknown type"
await Hive.openBox<Vehicle>('vehicles');  // ← Adapter kayıtlı değil!

// ✅ Önce adapter kaydet
Hive.registerAdapter(VehicleAdapter());
await Hive.openBox<Vehicle>('vehicles');
```

---

### **❌ 3. Async/Await unutmak**

```dart
// ❌ Yanlış
void addVehicle() {
  repository.addVehicle(vehicle);  // ← await yok!
  print('Eklendi!');  // ← Henüz eklenmedi!
}

// ✅ Doğru
Future<void> addVehicle() async {
  await repository.addVehicle(vehicle);
  print('Eklendi!');  // ← Şimdi doğru
}
```

---

### **❌ 4. Context.mounted kontrolü yapmamak**

```dart
// ❌ Yanlış
Future<void> loadData() async {
  await Future.delayed(Duration(seconds: 2));
  Navigator.pop(context);  // ← Widget dispose olmuş olabilir!
}

// ✅ Doğru
Future<void> loadData() async {
  await Future.delayed(Duration(seconds: 2));
  if (context.mounted) {
    Navigator.pop(context);
  }
}
```

---

## 🎓 Öğrenme Yol Haritası

### **Junior Developer (0-1 yıl)**

1. ✅ Dart Temelleri (async/await, Future, Stream)
2. ✅ Flutter Widget'ları (StatelessWidget, StatefulWidget)
3. ✅ Riverpod Temelleri (Provider, ConsumerWidget)
4. ✅ Hive CRUD işlemleri
5. ✅ Clean Architecture kavramları

**Pratik:** Basit TODO uygulaması yap

---

### **Mid-Level Developer (1-3 yıl)**

1. ✅ Advanced Riverpod (AsyncNotifier, StreamProvider)
2. ✅ UseCase Pattern
3. ✅ Repository Pattern
4. ✅ State Machine
5. ✅ Firebase entegrasyonu
6. ✅ Testing (Unit, Widget, Integration)

**Pratik:** Bu proje gibi CRUD uygulaması

---

### **Senior Developer (3+ yıl)**

1. ✅ Architecture Design (Clean, Hexagonal, MVVM)
2. ✅ Performance Optimization
3. ✅ Custom Widgets
4. ✅ CI/CD
5. ✅ Code Review Skills
6. ✅ Mentoring

**Pratik:** Kompleks e-commerce/fintech uygulaması

---

## 📚 Kaynaklar

### **Resmi Dokümantasyon**

- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [Hive Docs](https://docs.hivedb.dev/)
- [Firebase Flutter](https://firebase.flutter.dev/)

### **Önerilen Kurslar**

- **YouTube:** Reso Coder - Flutter Clean Architecture
- **Udemy:** Flutter & Dart - The Complete Guide
- **Medium:** Flutter Community Makaleleri

### **Kitaplar**

- "Clean Architecture" - Robert C. Martin
- "Design Patterns" - Gang of Four
- "Effective Dart" - Dart Team

---

## 🤝 Katkıda Bulunma

Bu proje açık kaynaklıdır. Sorularınız veya önerileriniz için:

1. Issue açın
2. Pull request gönderin
3. Tartışmaya katılın

---

## 📞 İletişim

Sorularınız için:
- 📧 Email: eslemyldrrm@gmail.com
- 💼 LinkedIn: Eslem Nur Yıldırım
- 🐙 GitHub: eslemnuryildirim

---

<div align="center">

**🎉 Başarılar! Kodlamaya devam! 🚀**

Made with ❤️ by eslemnuryildirim

</div>

