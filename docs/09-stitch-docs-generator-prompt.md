# 09. Prompt Tạo Bộ Tài Liệu Stitch Cho Mọi Project

Copy prompt dưới đây để yêu cầu AI tạo folder `docs/stitch` cho bất kỳ project nào. Mục tiêu là tạo các file Markdown nhỏ theo batch để upload cho Stitch generate UI frontend mà không bị đọc thiếu nội dung.

```text
Hãy tạo một bộ tài liệu Markdown để tôi dùng với Stitch nhằm generate UI frontend.

Mục tiêu:
- Tạo folder: docs/stitch
- Tạo các file Markdown theo từng batch nhỏ để Stitch không bị quá tải khi đọc.
- Tất cả nội dung dùng tiếng Việt có dấu.
- Trình bày ưu tiên heading + bullet, hạn chế bảng Markdown dài vì Stitch có thể đọc không hết.
- Mỗi file phải đủ rõ để upload riêng cho Stitch.
- File 00-master-prompt.md là context chung.
- Các file còn lại là từng batch UI.
- Không chỉnh code frontend, chỉ tạo tài liệu Markdown.

Trước khi tạo file, hãy quét project hiện tại để xác định đầy đủ màn hình UI.

Nguồn cần quét:
1. Docs hiện có nếu có:
   - docs/01-project-overview.md
   - docs/02-phase-plan.md
   - docs/03-role-flows.md
   - docs/04-module-breakdown.md
   - docs/05-task-board.md
   - docs/06-acceptance-checklist.md
   - docs/07-role-business-responsibilities.md
   - README.md
   - docs/README.md

2. Frontend routes:
   - frontend/src/App.*
   - frontend/src/routes
   - frontend/src/router
   - frontend/src/main.*
   - bất kỳ file router nào nếu có

3. Frontend UI files:
   - frontend/src/pages
   - frontend/src/components
   - frontend/src/features
   - frontend/src/layouts
   - frontend/src/modules
   - frontend/src/views

4. Nếu project không dùng thư mục frontend, hãy tìm các thư mục tương đương như:
   - src/pages
   - src/components
   - src/features
   - app
   - pages
   - components
   - modules
   - views

Đảm bảo không bỏ sót màn hình UI nào. Hãy gom screen từ tất cả nguồn:
- routes trong App/router
- files trong pages
- components có vai trò màn hình lớn
- features theo role hoặc module
- docs phase/module/role/acceptance
- các flow nghiệp vụ chính

Ngoài page chính, cũng phải liệt kê:
- modal
- drawer/sheet
- detail panel
- form create/edit
- table/list view
- dashboard cards
- filters/sort/search
- empty/loading/error states
- success/disabled states
- timeline/tracking
- unauthorized page
- not found page
- role-specific workspace
- shared layout/components

Với mỗi màn hình hoặc component lớn, hãy ghi:
- Tên màn hình
- Route nếu có
- File/component hiện có nếu tìm thấy
- Role sử dụng màn hình đó
- Trạng thái:
  - Đã có
  - Đã có một phần
  - Cần bổ sung
  - Cần tạo mới
  - Cần kiểm tra
- Stitch cần làm gì:
  - polish UI
  - bổ sung state
  - tạo modal/panel
  - tạo màn hình mới
  - cập nhật responsive
  - thêm loading/empty/error state
  - thêm badge/timeline/table/filter nếu cần

Quy ước trạng thái:
- Đã có: đã có route/page/component tương ứng trong project.
- Đã có một phần: đã có một phần UI hoặc component, nhưng còn thiếu detail, state hoặc flow.
- Cần bổ sung: cần thêm modal, panel, section, state hoặc component để hoàn thiện flow.
- Cần tạo mới: chưa thấy page/component riêng trong project.
- Cần kiểm tra: không chắc đã có hay chưa, cần team xác nhận.

Hãy tạo các file sau:

1. docs/stitch/00-master-prompt.md

Nội dung cần có:
- Context tổng quan dự án.
- Loại app: web app hay mobile app.
- Style guide UI.
- Role người dùng.
- Business flow chính.
- Status/enum quan trọng.
- Quy ước trạng thái màn hình.
- Cách Stitch xử lý từng trạng thái.
- Yêu cầu responsive.
- Yêu cầu loading, empty, error, success, disabled state.
- Component dùng chung:
  - button
  - input
  - select
  - checkbox
  - table
  - modal
  - badge
  - tabs
  - sidebar
  - timeline
  - card
  - search
  - filter
  - pagination

2. docs/stitch/01-customer-storefront.md

Nội dung:
- Các màn hình public/customer/storefront.
- Ví dụ nếu phù hợp với project:
  - Trang chủ
  - Danh sách sản phẩm/danh sách item
  - Tìm kiếm
  - Filter/sort
  - Chi tiết sản phẩm/item
  - Giỏ hàng/cart nếu có
  - Checkout nếu có
  - Thanh toán nếu có
  - Đơn hàng của tôi nếu có
  - Tracking nếu có
  - Profile
  - Address management
  - Customer chat/support
- Với mỗi màn hình ghi route/file hiện có nếu tìm thấy.

3. docs/stitch/02-auth-public.md

Nội dung:
- Login
- Register
- Forgot password
- Reset password
- OTP nếu có
- Guest chat nếu có
- Unauthorized page
- Not found page
- Auth layout
- Auth loading/error/success states

4. docs/stitch/03-admin-dashboard.md

Nội dung:
- Admin dashboard overview
- Report/revenue/statistics dashboard
- Quản lý user/role
- Quản lý catalog/master data
- Quản lý product/item/content
- Quản lý order/request/task nếu có
- Quản lý chat/support nếu có
- Settings/account menu
- Nếu project có dashboard hoặc manager component sẵn, ghi rõ file hiện có.

5. docs/stitch/04-staff-workflow.md

Nội dung:
- Các màn hình dành cho staff vận hành.
- Ví dụ:
  - Staff dashboard
  - Danh sách công việc/đơn cần xử lý
  - Detail screen
  - Action screen
  - Assignment screen
  - Timeline/status screen
  - Confirmation modal
- Nếu topic không có staff thì ghi “Không áp dụng” hoặc đổi thành role vận hành phù hợp.

6. docs/stitch/05-special-role-workflow.md

Nội dung:
- Role đặc thù của dự án.
- Với ecommerce có thể là Delivery/Shipper.
- Với education có thể là Teacher/Student.
- Với healthcare có thể là Doctor/Nurse/Patient.
- Với booking có thể là Provider/Operator.
- Với moderation có thể là Moderator.
- Tạo workflow riêng cho role này nếu có.
- Nếu không có role đặc thù thì ghi “Không áp dụng”.

7. docs/stitch/06-shared-components.md

Nội dung:
- Layouts
- Header
- Sidebar
- Footer
- Navigation
- Search
- Cards
- Tables
- Filters
- Sort
- Pagination
- Empty state
- Loading state
- Error state
- Success state
- Disabled state
- Modal
- Drawer/sheet
- Status badge
- Timeline
- Form components
- Detail panel
- Mobile responsive behavior

8. docs/stitch/07-screen-inventory-summary.md

Nội dung:
- Danh sách tất cả màn hình UI tìm được trong project.
- Gom theo role/module.
- Mỗi mục gồm:
  - Tên màn hình
  - Route nếu có
  - File hiện có nếu có
  - Trạng thái
  - Batch tương ứng
- File này dùng làm bảng kiểm cuối cùng để đảm bảo không sót màn hình.

9. docs/stitch/README.md

Nội dung:
- Hướng dẫn cách upload file cho Stitch.
- Giải thích cách dùng:
  - Luôn upload 00-master-prompt.md + một file batch.
  - Không upload tất cả file cùng lúc nếu Stitch đọc không hết.
- Thứ tự đề xuất:
  1. 00 + 01
  2. 00 + 02
  3. 00 + 03
  4. 00 + 04
  5. 00 + 05
  6. 00 + 06
  7. 00 + 07 để kiểm tra tổng thể
- Prompt mẫu để gửi Stitch.

Prompt mẫu trong README:

“Tôi đã upload 2 file: 00-master-prompt.md và [tên file batch]. Hãy đọc kỹ cả hai file. Chỉ xử lý đúng nội dung trong file batch này. Với màn hình Đã có thì polish, Đã có một phần thì bổ sung phần còn thiếu, Cần bổ sung thì tạo thêm component/section/modal/panel, Cần tạo mới thì thiết kế màn hình mới hoàn chỉnh. Thiết kế UI web responsive theo context trong master prompt. Text UI dùng tiếng Việt có dấu.”

Yêu cầu chất lượng cho các file:
- Không dùng bảng Markdown dài.
- Ưu tiên heading + bullet.
- Mỗi batch nên đủ ngắn để Stitch đọc hết.
- Nếu một batch quá dài, hãy tách thêm file phụ như:
  - 03-admin-dashboard-a.md
  - 03-admin-dashboard-b.md
- Nội dung phải rõ ràng để Stitch biết màn hình nào đã có, màn hình nào thiếu, màn hình nào cần tạo.
- Không tự bịa route nếu không thấy route; nếu cần màn hình nhưng chưa có route, ghi “Route đề xuất”.
- Nếu không chắc một màn hình đã có hay chưa, đánh dấu “Cần kiểm tra” thay vì bỏ qua.

Trước khi kết thúc, hãy tự kiểm tra:
- Có route nào trong App/router chưa được đưa vào batch không?
- Có file nào trong pages chưa được nhắc tới không?
- Có feature/admin hoặc feature/customer nào chưa được nhắc tới không?
- Có flow nào trong docs role/phase/acceptance chưa có màn hình tương ứng không?
- Có modal/drawer/detail panel/form/table/state nào bị bỏ sót không?
- Có shared component quan trọng nào bị bỏ sót không?

Nếu có thiếu sót, hãy thêm vào batch phù hợp hoặc đánh dấu “Cần kiểm tra”.

Sau khi tạo xong:
- In ra danh sách file đã tạo.
- Tóm tắt mỗi file dùng để làm gì.
- Tóm tắt số lượng màn hình:
  - Đã có
  - Đã có một phần
  - Cần bổ sung
  - Cần tạo mới
  - Cần kiểm tra
```
