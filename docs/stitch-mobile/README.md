# Stitch Mobile Docs

Bộ file này dùng để upload cho Stitch generate UI mobile app cho Sportswear E-Commerce System.

## Cách Upload

Luôn upload:
- `00-mobile-master-prompt.md`
- một file batch mobile

Không upload tất cả file cùng lúc nếu Stitch đọc không hết.

## Thứ Tự Đề Xuất

1. `00-mobile-master-prompt.md` + `01-customer-mobile.md`
2. `00-mobile-master-prompt.md` + `02-auth-public-mobile.md`
3. `00-mobile-master-prompt.md` + `03-admin-mobile.md`
4. `00-mobile-master-prompt.md` + `04-shop-staff-mobile.md`
5. `00-mobile-master-prompt.md` + `05-delivery-staff-mobile.md`
6. `00-mobile-master-prompt.md` + `06-shared-mobile-components.md`
7. `00-mobile-master-prompt.md` + `07-mobile-screen-inventory-summary.md` để kiểm tra cuối.

## Prompt Mẫu Gửi Stitch

```text
Tôi đã upload 2 file:
1. 00-mobile-master-prompt.md
2. [tên file batch mobile]

Hãy đọc kỹ cả hai file. Chỉ xử lý đúng nội dung trong file batch mobile này.

Thiết kế mobile app Android/iOS, không thiết kế website.
Mobile-first, text UI dùng tiếng Việt có dấu.

Với màn hình "Đã có": polish/cải thiện UI mobile.
Với màn hình "Đã có một phần": bổ sung phần còn thiếu.
Với màn hình "Cần chuyển từ web": chuyển layout web sang mobile app.
Với màn hình "Cần bổ sung": tạo thêm bottom sheet/modal/section/state cần thiết.
Với màn hình "Cần tạo mới": thiết kế màn hình mobile mới hoàn chỉnh.

Giữ đúng business flow và role trong 00-mobile-master-prompt.md.

Hãy bắt đầu thiết kế UI mobile cho batch này.
```

