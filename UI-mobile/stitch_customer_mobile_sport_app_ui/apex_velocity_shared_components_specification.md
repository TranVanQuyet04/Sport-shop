# Apex Velocity Shared Mobile Components System

## 1. Navigation & Headers
### Bottom Navigation
- **Customer:** Home, Search, Cart, Orders, Profile.
- **Admin/Staff:** Dashboard, Catalog, Orders, Staff, Settings.
- **Design:** `bg-surface-container-lowest`, `text-secondary` for active, `text-on-surface-variant` for inactive. Rounded top corners (12px), subtle shadow.

### Top App Bar
- **Small (Default):** Centered/Left title, `arrow_back` leading, optional trailing icons (`notifications`, `shopping_cart`).
- **Large:** For main landing pages with bold titles.

## 2. Search & Filtering
### Search Bar
- **States:** Default (gray container), Focus (active border), Recent searches (list with history icon), No-result (illustration + helper text).

### Bottom Sheets (Filter/Sort)
- **Filters:** Brand, Category, Sport, Price range, Color swatches. Sticky "Apply" button.
- **Sort:** Radio list (Newest, Price L-H, Price H-L, Popular).

## 3. Core Cards
### Product Card
- Vertical layout, aspect ratio 1:1 for images, bold price, brand name in secondary text, color swatches indicator.

### Order Card
- Summary view: Order code, Date, Total, dual status badges (Order + Delivery), "Chi tiết" CTA.

### Delivery & Staff Cards
- **Delivery Card:** Address-focused, quick action "Cập nhật".
- **Staff Card:** Avatar, name, role badge, status dot (Online/Offline), workload count.

## 4. Status & Feedback
### Status Badges
- **Order:** 
  - PENDING: `bg-surface-container-high`
  - CONFIRMED: `bg-primary-container`
  - PACKING: `bg-secondary-container`
  - SHIPPED: `bg-tertiary-container`
  - COMPLETED: `bg-success-container`
  - CANCELLED: `bg-error-container`
- **Delivery:** Sequential colors from gray to green/red for FAILED.

### Feedback States
- **Empty State:** Centered icon, title, descriptive text, primary CTA.
- **Loading State:** Skeleton screens for cards and lists.
- **Error State:** 403/404 graphics, clear explanation, "Thử lại" or "Về trang chủ" CTA.
- **Success State:** Large checkmark animation/icon, confirmation text, secondary actions.

## 5. Overlays
### Confirmation Bottom Sheet
- Destructive actions (Logout, Cancel) in red, standard confirmations in primary color.
- Consistent padding and "handle" bar at the top.

### Toast / Snackbar
- Success (Green), Error (Red), Warning (Amber), Info (Blue). Floating at the bottom above navigation.
