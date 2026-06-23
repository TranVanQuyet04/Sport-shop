# 06. Batch Shared Mobile Components

Upload file này cùng `00-mobile-master-prompt.md`.

Mục tiêu: chuẩn hóa component mobile dùng chung cho Customer, Admin, Shop Staff, Delivery Staff.

## Navigation

### Bottom navigation
- Trạng thái: Cần tạo mới
- Cần Stitch: Home, Search, Cart, Orders, Profile cho customer.

### Top app bar
- Trạng thái: Cần tạo mới
- Cần Stitch: title, back button, action buttons.

## Storefront Components

### Search bar
- Trạng thái: Cần chuyển từ web
- Cần Stitch: mobile search input, suggestion state.

### Product card
- Web hiện có: `ProductCard`
- Trạng thái: Cần chuyển từ web
- Cần Stitch: image, name, price, brand, color swatches.

### Category shortcut
- Trạng thái: Cần tạo mới
- Cần Stitch: horizontal category icons.

### Brand card
- Trạng thái: Cần chuyển từ web
- Cần Stitch: brand image/logo card.

### Filter bottom sheet
- Trạng thái: Cần chuyển từ web
- Cần Stitch: filter groups mobile.

### Sort bottom sheet
- Trạng thái: Cần chuyển từ web
- Cần Stitch: sort options mobile.

## Cards And Lists

### Order card
- Trạng thái: Cần bổ sung
- Cần Stitch: order summary, status badge, total, date.

### Delivery card
- Trạng thái: Cần tạo mới
- Cần Stitch: delivery address, deliveryStatus, quick action.

### Staff card
- Trạng thái: Cần tạo mới
- Cần Stitch: staff info, role, status, workload.

## Status And Timeline

### Status badge
- Trạng thái: Đã có một phần
- Cần Stitch: badge cho orderStatus và deliveryStatus.

### Order timeline
- Trạng thái: Đã có một phần
- Cần Stitch: timeline orderStatus.

### Delivery timeline
- Trạng thái: Cần tạo mới
- Cần Stitch: timeline deliveryStatus.

## States

### Empty state
- Trạng thái: Cần bổ sung thống nhất
- Cần Stitch: reusable empty state.

### Loading state
- Trạng thái: Đã có một phần
- Cần Stitch: skeleton/spinner mobile.

### Error state
- Trạng thái: Cần bổ sung thống nhất
- Cần Stitch: reusable error state.

### Success state
- Trạng thái: Cần bổ sung
- Cần Stitch: success confirmation.

## Bottom Sheets And Forms

### Confirmation bottom sheet
- Trạng thái: Cần bổ sung
- Cần Stitch: confirm received, confirm order, handover.

### Form bottom sheet
- Trạng thái: Cần bổ sung
- Cần Stitch: add/edit address, failed delivery, returned order.

### Toast/snackbar
- Trạng thái: Cần bổ sung
- Cần Stitch: feedback messages.

