# DateLuv ❤️

**DateLuv** là một ứng dụng di động được xây dựng bằng Flutter, dành riêng cho các cặp đôi để theo dõi hành trình tình yêu, lưu giữ những kỷ niệm đẹp và không bao giờ bỏ lỡ các ngày kỷ niệm quan trọng.

## ✨ Tính năng nổi bật

- **💓 Bộ đếm thời gian bên nhau:** Hiển thị thời gian yêu nhau chính xác đến từng giây với giao diện hiện đại, lãng mạn.
- **📅 Quản lý Kỷ niệm (Milestones):**
  - Tự động sinh ra các mốc kỷ niệm quan trọng (100 ngày, 1 năm, 10 năm... lên đến 100 năm).
  - Tùy chỉnh và thêm các ngày kỷ niệm riêng của hai bạn.
  - Thông báo nhắc nhở trước ngày kỷ niệm.
- **📖 Nhật ký tình yêu:** Lưu lại những khoảnh khắc đáng nhớ với hình ảnh, văn bản và cảm xúc (emoji).
- **📸 Album ảnh (Gallery):** Xem lại toàn bộ ảnh kỷ niệm trong một giao diện lưới đẹp mắt (Masonry Grid).
- **☁️ Đồng bộ đám mây (Cloud Sync):**
  - Kết nối với đối phương qua mã mời (Invite Code).
  - Đồng bộ dữ liệu thời gian thực qua Firebase Firestore.
  - Hỗ trợ sử dụng Offline và tự động đẩy dữ liệu khi có mạng.
- **🎨 Giao diện tùy biến:** Hỗ trợ Chế độ tối (Dark Mode) và thay đổi ảnh nền linh hoạt.
- **📤 Chia sẻ:** Tạo thiệp kỷ niệm và chia sẻ lên mạng xã hội dễ dàng.

## 🚀 Công nghệ sử dụng

- **Framework:** [Flutter](https://flutter.dev/)
- **Quản lý trạng thái:** [Provider](https://pub.dev/packages/provider)
- **Cơ sở dữ liệu cục bộ:** [Hive](https://hivedb.dev/)
- **Backend & Sync:** [Firebase](https://firebase.google.com/) (Auth, Firestore, Storage)
- **Điều hướng:** [GoRouter](https://pub.dev/packages/go_router)
- **Tự động hóa:** [Fastlane](https://fastlane.tools/) (Android)

## 🛠️ Cài đặt & Phát triển

### Yêu cầu hệ thống
- Flutter SDK (v3.0.0+)
- Android Studio / VS Code
- Tài khoản Firebase (để dùng tính năng Sync)

### Các bước cài đặt
1. **Clone dự án:**
   ```bash
   git clone https://github.com/yourusername/dateluv.git
   cd dateluv
   ```

2. **Cài đặt dependencies:**
   ```bash
   flutter pub get
   ```

3. **Cấu hình Firebase:**
   - Tạo project trên [Firebase Console](https://console.firebase.google.com/).
   - Thêm app Android/iOS và tải file `google-services.json` / `GoogleService-Info.plist` vào thư mục tương ứng.
   - Thêm mã SHA-1 (Debug/Release) vào cấu hình Firebase để dùng Google Sign-In.

4. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

## 📦 Phát hành (Release)

Dự án đã được tích hợp **Fastlane** để tự động hóa quy trình lên Google Play Store.

### Android Release
1. Cấu hình file `android/key.properties` với thông tin Keystore của bạn.
2. Lưu Google Service Account JSON tại `android/secrets/google-play-key.json`.
3. Chạy lệnh:
   ```bash
   cd android && bundle exec fastlane release
   ```

## 📝 Giấy phép

Dự án này được phát hành dưới giấy phép MIT. Xem tệp [LICENSE](LICENSE) để biết thêm chi tiết.

---
*Made with ❤️ for couples everywhere.*
