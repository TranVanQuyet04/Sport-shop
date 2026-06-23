# 06. Batch Shared Components Cho Stitch

Upload file này cùng `00-master-prompt.md`.

Mục tiêu: chuẩn hóa các component dùng chung cho customer, admin, shop staff và delivery staff.

## Layout Components Đã Có Cần Polish

### Main customer layout
- File hiện tại: `components/layout/MainLayout.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish layout, spacing, responsive.

### Customer header
- File hiện tại: `Header`, `MainHeader`, `Navbar`
- Trạng thái: Đã có
- Cần Stitch: polish desktop/mobile header.

### Navigation menu
- File hiện tại: `NavigationMenu`
- Trạng thái: Đã có
- Cần Stitch: polish dropdown/menu state.

### Search bar
- File hiện tại: `SearchBar`
- Trạng thái: Đã có
- Cần Stitch: polish search input, suggestion state nếu cần.

### Footer
- File hiện tại: `Footer`
- Trạng thái: Đã có
- Cần Stitch: polish footer links, contact, responsive.

### Admin sidebar
- File hiện tại: `AdminSidebar`
- Trạng thái: Đã có
- Cần Stitch: polish active state, icon style.

### Admin secondary sidebar
- File hiện tại: `AdminSecondarySidebar`
- Trạng thái: Đã có
- Cần Stitch: polish context navigation.

### Admin header
- File hiện tại: `AdminHeader`
- Trạng thái: Đã có
- Cần Stitch: polish header actions, account menu.

## Product Components Đã Có Cần Polish

### Product card
- File hiện tại: `ProductCard`
- Trạng thái: Đã có
- Cần Stitch: polish image, price, color swatches, hover state.

### Filter sidebar
- File hiện tại: `ProductFilters`
- Trạng thái: Đã có
- Cần Stitch: polish checkbox/range/filter groups.

### Sort control
- File hiện tại: `ProductSort`
- Trạng thái: Đã có
- Cần Stitch: polish select/dropdown.

### Pagination
- File hiện tại: `pagination.tsx`
- Trạng thái: Đã có
- Cần Stitch: polish pagination states.

## State Components Cần Bổ Sung

### Empty state
- Trạng thái: Cần bổ sung thống nhất
- Cần Stitch: reusable empty state cho product/order/table/chat.

### Loading state
- Trạng thái: Đã có một phần
- Cần Stitch: chuẩn hóa skeleton/spinner.

### Error state
- Trạng thái: Cần bổ sung thống nhất
- Cần Stitch: reusable error state.

### Auth guard / Unauthorized page
- Trạng thái: Cần bổ sung
- Cần Stitch: page unauthorized riêng.

### Not found page
- Trạng thái: Cần bổ sung
- Cần Stitch: page 404 riêng.

## Status Và Timeline Components

### Status badge components
- Trạng thái: Đã có một phần
- Cần Stitch: badge cho orderStatus và deliveryStatus mới.

### Order timeline component
- Trạng thái: Đã có một phần
- Cần Stitch: update theo orderStatus mới.

### Delivery timeline component
- Trạng thái: Cần tạo mới
- Cần Stitch: timeline riêng cho deliveryStatus.

## Modal Components

### Confirm modal
- Trạng thái: Cần bổ sung
- Cần Stitch: reusable confirmation modal.

### Form modal
- Trạng thái: Cần bổ sung
- Cần Stitch: reusable modal cho add/edit address, failed delivery, returned order.
