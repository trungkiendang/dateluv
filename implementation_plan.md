# Kế Hoạch Xây Dựng Ứng Dụng Date Luv (Flutter)

Xây dựng ứng dụng **Date Luv** – ứng dụng kỷ niệm tình yêu dành cho các cặp đôi, tương tự "Been Together" trên Google Play. Ứng dụng giúp các cặp đôi theo dõi thời gian bên nhau, lưu giữ kỷ niệm và nhắc nhở các ngày đặc biệt.

---

## Tổng Quan Kiến Trúc

```
DateLuv/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── theme/        # Hệ thống màu sắc, typography, theme
│   │   ├── utils/        # Helper functions (date calculator, etc.)
│   │   ├── constants/    # App constants
│   │   └── extensions/   # Dart extensions
│   ├── data/
│   │   ├── models/       # Data models
│   │   ├── repositories/ # Data access layer
│   │   └── local/        # Hive / shared_preferences
│   ├── features/
│   │   ├── onboarding/   # Màn hình thiết lập ban đầu
│   │   ├── home/         # Màn hình chính (bộ đếm tình yêu)
│   │   ├── diary/        # Nhật ký / Ký ức
│   │   ├── milestones/   # Ngày kỷ niệm & sự kiện
│   │   ├── gallery/      # Album ảnh
│   │   └── settings/     # Cài đặt & hồ sơ
│   └── shared/
│       ├── widgets/      # Widgets dùng chung
│       └── animations/   # Custom animations
└── assets/
    ├── images/
    ├── icons/
    ├── fonts/
    └── animations/      # Lottie files
```

---

## Các Tính Năng Chính

### 1. 💕 Onboarding & Thiết Lập Hồ Sơ
- Màn hình chào mừng với animation lãng mạn (Lottie)
- Nhập tên + ảnh đại diện cho cả hai người
- Chọn ngày bắt đầu yêu nhau
- Chọn màu sắc / theme ưa thích
- Lưu dữ liệu cục bộ (Hive)

### 2. 🏠 Màn Hình Chính – Bộ Đếm Tình Yêu
- Hiển thị **real-time counter**: Năm - Tháng - Ngày - Giờ - Phút - Giây
- Hiển thị ảnh đôi + tên hai người
- Ảnh nền tùy chỉnh (custom background)
- Animation con tim đập nhịp
- Nút quick-add memory
- **Bottom Navigation** với 4 tab chính

### 3. 📖 Nhật Ký / Ký Ức (Diary)
- Tạo bài đăng với: tiêu đề, nội dung, ảnh (nhiều ảnh), cảm xúc (emoji), ngày
- Danh sách bài đăng theo thời gian (dạng card đẹp)
- Tìm kiếm ký ức
- Lọc theo tháng/năm hoặc cảm xúc
- Slide show ảnh kỷ niệm
- Xóa / chỉnh sửa bài đăng

### 4. 🎉 Milestones – Ngày Kỷ Niệm
- Kỷ niệm quan hệ (100 ngày, 200 ngày, 1 năm, v.v.) – tự động tính
- Thêm ngày đặc biệt tùy chỉnh (sinh nhật, ngày đầu gặp, v.v.)
- Countdown đến ngày tiếp theo
- Thông báo nhắc nhở trước 1-7 ngày
- Giao diện lịch hiển thị các mốc quan trọng

### 5. 🖼️ Album Ảnh (Gallery)
- Xem tất cả ảnh từ nhật ký
- Hiển thị dạng grid / masonry
- Full-screen viewer với vuốt ngang
- Chia sẻ ảnh

### 6. ⚙️ Cài Đặt & Cá Nhân Hóa
- Chỉnh sửa thông tin hồ sơ đôi
- Đổi theme (nhiều màu sắc lãng mạn)
- Đổi ảnh nền màn hình chính
- Cài đặt thông báo
- Bảo mật bằng PIN / Touch ID / Face ID (local_auth)
- Sao lưu / khôi phục dữ liệu

---

## Stack Kỹ Thuật

| Thành phần | Package | Mục đích |
|---|---|---|
| **State Management** | `flutter_bloc` / `provider` | Quản lý trạng thái ứng dụng |
| **Local DB** | `hive` + `hive_flutter` | Lưu trữ dữ liệu cục bộ (nhanh) |
| **Image Picker** | `image_picker` | Chọn ảnh từ thư viện |
| **Notifications** | `flutter_local_notifications` | Nhắc nhở ngày kỷ niệm |
| **Animations** | `lottie` | Animation lãng mạn |
| **Auth** | `local_auth` | Bảo mật PIN/Biometrics |
| **Image Display** | `cached_network_image` | Cache ảnh hiệu quả |
| **Routing** | `go_router` | Navigation |
| **Permissions** | `permission_handler` | Xử lý quyền truy cập |
| **Share** | `share_plus` | Chia sẻ ảnh/nội dung |
| **Date Format** | `intl` | Format ngày giờ |
| **Path Provider** | `path_provider` | Lưu file cục bộ |
| **Intro/Slider** | `introduction_screen` | Màn hình onboarding |
| **Masonry Grid** | `flutter_staggered_grid_view` | Gallery hiển thị đẹp |
| **Toast** | `fluttertoast` | Thông báo nhỏ |

---

## Thiết Kế UI/UX

### Bảng Màu (Color Palette)
- **Primary**: `#FF6B9D` – Hồng đậm (tình yêu)
- **Secondary**: `#C04FD6` – Tím hồng
- **Accent**: `#FF9EC8` – Hồng nhạt
- **Background Dark**: `#1A0A14` – Nền tối lãng mạn
- **Background Light**: `#FFF0F5` – Nền sáng nhẹ nhàng
- **Surface**: `#2D1025` – Card tối
- **Text Primary**: `#FFFFFF` / `#1A0A14`

### Typography
- **Font chính**: `Nunito` (Google Fonts) – mềm mại, thân thiện
- **Font phụ**: `Pacifico` – tiêu đề ứng dụng lãng mạn

### Nguyên Tắc Thiết Kế
- **Glassmorphism** cho các card và overlay
- **Smooth animations** khi chuyển màn hình (hero transitions)
- **Gradient background** lãng mạn
- **Neumorphism** nhẹ cho các nút
- Hỗ trợ **Dark Mode** và **Light Mode**

---

## Kế Hoạch Triển Khai theo Phase

### Phase 1 – Nền Tảng (Foundation)
- [ ] Tạo Flutter project mới
- [ ] Cài đặt dependencies
- [ ] Thiết lập theme system (màu sắc, typography)
- [ ] Cấu hình Hive database
- [ ] Thiết lập go_router navigation
- [ ] Tạo base models: `CoupleProfile`, `DiaryEntry`, `Milestone`

### Phase 2 – Core Features
- [ ] **Onboarding screens**: Chào mừng, nhập thông tin đôi, chọn ngày yêu
- [ ] **Home screen**: Bộ đếm real-time, hiển thị ảnh đôi, animation tim
- [ ] **Bottom navigation bar** với 4 tab

### Phase 3 – Diary & Gallery
- [ ] **Diary list screen**: Danh sách ký ức dạng timeline
- [ ] **Create/Edit diary entry**: Form với ảnh multiple, emoji, nội dung
- [ ] **Gallery screen**: Masonry grid tất cả ảnh từ diary
- [ ] **Photo viewer**: Full-screen với swipe

### Phase 4 – Milestones & Notifications
- [ ] **Milestone screen**: Auto-generated milestones + custom events
- [ ] **Add milestone form**: Thêm ngày đặc biệt tùy chỉnh
- [ ] **Local notifications**: Nhắc nhở trước ngày kỷ niệm
- [ ] **Calendar view**: Hiển thị timeline sự kiện

### Phase 5 – Settings & Polishing
- [ ] **Settings screen**: Hồ sơ, theme, thông báo, bảo mật
- [ ] **Security**: PIN lock / Biometrics
- [ ] **Theme switcher**: Light/Dark + nhiều màu accent
- [ ] Polish animations và transitions
- [ ] **App icon & Splash screen**

---

## Cấu Trúc Dữ Liệu (Models)

### CoupleProfile
```dart
class CoupleProfile {
  String person1Name;
  String person2Name;
  String? person1PhotoPath;
  String? person2PhotoPath;
  DateTime startDate;       // Ngày bắt đầu yêu
  String? backgroundImagePath;
  String themeColor;
  bool isDarkMode;
}
```

### DiaryEntry
```dart
class DiaryEntry {
  String id;
  String title;
  String content;
  DateTime date;
  List<String> imagePaths;
  String emoji;             // Cảm xúc
  DateTime createdAt;
}
```

### Milestone
```dart
class Milestone {
  String id;
  String title;
  DateTime date;
  String? description;
  bool isAutoGenerated;     // true = hệ thống tạo (100 ngày, 1 năm)
  String icon;
  bool reminderEnabled;
  int reminderDaysBefore;
}
```

---

## Câu Hỏi Mở Cần Xác Nhận

> [!IMPORTANT]
> **1. Dữ liệu lưu trữ**: Chỉ lưu local (Hive/SQLite) hay cần đồng bộ Cloud (Firebase Firestore)? Firebase mở ra khả năng chia sẻ dữ liệu giữa hai điện thoại của cặp đôi.

> [!IMPORTANT]  
> **2. Tính năng đa thiết bị**: Có muốn hai người trong cặp đôi cùng đăng nhập và chia sẻ nhật ký, kỷ niệm chung không? (Cần Firebase Auth + Firestore)

> [!WARNING]
> **3. Widget màn hình chính**: Có cần tính năng Widget (Android/iOS home screen widget) không? Đây là tính năng phức tạp, cần package `home_widget`.

> [!NOTE]
> **4. Nền tảng hỗ trợ**: Android, iOS, hay cả hai? (Flutter hỗ trợ cross-platform dễ dàng)

> [!NOTE]
> **5. Ngôn ngữ giao diện**: Chỉ Tiếng Việt hay hỗ trợ đa ngôn ngữ (Tiếng Anh, Tiếng Việt)?

---

## Phân Tích Rủi Ro

| Rủi ro | Mức độ | Giải pháp |
|---|---|---|
| Mất dữ liệu nếu xóa app | Cao | Cung cấp tính năng backup/export |
| Ảnh chiếm nhiều bộ nhớ | Trung bình | Nén ảnh khi lưu |
| Thông báo không hoạt động | Trung bình | Test kỹ trên cả Android/iOS |
| Performance với nhiều ảnh | Thấp | Dùng `cached_network_image` + lazy loading |

---

## Kết Quả Kỳ Vọng

Sau khi hoàn thành, ứng dụng **Date Luv** sẽ có:
- ✅ UI/UX đẹp, lãng mạn, hiện đại (Dark mode mặc định)
- ✅ Bộ đếm tình yêu real-time mượt mà
- ✅ Nhật ký kỷ niệm với ảnh phong phú
- ✅ Nhắc nhở ngày đặc biệt tự động
- ✅ Album ảnh đẹp mắt
- ✅ Hoàn toàn offline (dữ liệu local)
- ✅ Bảo mật bằng PIN/Biometrics
