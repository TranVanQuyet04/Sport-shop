param([string]$Root = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
$assetDir = Join-Path $Root 'report-assets'
New-Item -ItemType Directory -Force -Path $assetDir | Out-Null

Add-Type -AssemblyName System.Drawing

function New-Diagram {
    param([string]$Path, [string]$Title, [array]$Boxes, [array]$Links)
    $bmp = [Drawing.Bitmap]::new(1800, 1050)
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
    $g.Clear([Drawing.Color]::White)
    $titleFont = [Drawing.Font]::new('Arial', 28, [Drawing.FontStyle]::Bold)
    $font = [Drawing.Font]::new('Arial', 18, [Drawing.FontStyle]::Regular)
    $small = [Drawing.Font]::new('Arial', 14, [Drawing.FontStyle]::Regular)
    $center = [Drawing.StringFormat]::new(); $center.Alignment='Center'; $center.LineAlignment='Center'
    $g.DrawString($Title, $titleFont, [Drawing.Brushes]::MidnightBlue, [Drawing.RectangleF]::new(0,20,1800,60), $center)
    foreach ($link in $Links) {
        $pen=[Drawing.Pen]::new([Drawing.Color]::FromArgb(70,90,120),4); $pen.EndCap='ArrowAnchor'
        $g.DrawLine($pen,$link[0],$link[1],$link[2],$link[3]); $pen.Dispose()
        if($link.Count -gt 4){$g.DrawString($link[4],$small,[Drawing.Brushes]::DimGray,[Drawing.RectangleF]::new($link[5],$link[6],250,40),$center)}
    }
    foreach ($box in $Boxes) {
        $rect=[Drawing.RectangleF]::new($box[0],$box[1],$box[2],$box[3])
        $brush=[Drawing.SolidBrush]::new([Drawing.Color]::FromArgb($box[5],$box[6],$box[7]))
        $pen=[Drawing.Pen]::new([Drawing.Color]::FromArgb(35,65,105),3)
        $g.FillRectangle($brush,$rect); $g.DrawRectangle($pen,$rect.X,$rect.Y,$rect.Width,$rect.Height)
        $g.DrawString($box[4],$font,[Drawing.Brushes]::Black,$rect,$center)
        $brush.Dispose();$pen.Dispose()
    }
    $bmp.Save($Path,[Drawing.Imaging.ImageFormat]::Png)
    $titleFont.Dispose();$font.Dispose();$small.Dispose();$center.Dispose();$g.Dispose();$bmp.Dispose()
}

$arch = Join-Path $assetDir 'architecture.png'
New-Diagram $arch 'SPORTSHOP - MICROSERVICE ARCHITECTURE' @(
 @(80,170,300,130,"Flutter Mobile/Web`nClean Architecture + MVP",220,240,255),
 @(520,130,310,130,"Auth Service :8081`nJWT, User, Address",220,255,235),
 @(920,130,310,130,"Catalog Service :8082`nProduct, Brand, Category",255,242,210),
 @(520,410,310,130,"Order Service :8083`nCart, Order, Payment",255,225,225),
 @(920,410,310,130,"Chat Service :8084`nRoom, Message, Support",235,225,255),
 @(1360,260,300,150,"PostgreSQL`n4 logical databases",225,235,245),
 @(1360,500,300,120,"Redis 7`nToken/cache support",235,245,225),
 @(520,720,710,120,"External services: VNPay / Email / AI provider",245,245,245)
) @(
 @(380,235,520,195,'REST/JSON',405,165),@(380,260,520,470,'REST/JSON',405,390),
 @(830,195,1360,310,'JPA',1100,255),@(1230,195,1360,310,'JPA',1240,210),
 @(830,475,1360,350,'JPA',1100,420),@(1230,475,1360,350,'JPA',1240,480),
 @(675,540,675,720,'HTTPS',690,620),@(1075,540,1075,720,'HTTPS',1085,620),
 @(830,195,1360,555,'Redis',1030,520)
)

$erd = Join-Path $assetDir 'erd.png'
New-Diagram $erd 'CONCEPTUAL ENTITY-RELATIONSHIP DIAGRAM' @(
 @(70,150,270,150,"ROLE`nPK role_id`nrole_code",220,240,255),
 @(430,140,310,190,"USER`nPK user_id`nFK role_id`nemail, status",220,255,235),
 @(850,120,320,190,"USER_ADDRESS`nPK address_id`nFK user_id`nrecipient, is_default",255,242,210),
 @(70,460,270,170,"BRAND / CATEGORY / SPORT`nClassification masters",235,225,255),
 @(430,450,310,190,"PRODUCT`nPK product_id`nFK brand/category/sport`nname, status",255,225,225),
 @(850,440,320,200,"PRODUCT_VARIANT`nPK variant_id`nFK product_id`nSKU, size, color, stock",225,235,245),
 @(1280,120,330,190,"CART / CART_ITEM`nPK cart_id / item_id`nFK user_id, variant_id",235,245,225),
 @(1280,430,330,210,"ORDER / ORDER_ITEM`nPK order_id / item_id`nFK user_id, variant_id`nstatus, total_amount",245,235,220),
 @(850,760,320,150,"ORDER_ASSIGNMENT`nFK order_id, shipper_id`nstatus",230,240,250),
 @(1280,760,330,150,"CHAT_ROOM / MESSAGE`nFK customer_id`nsender, content, sent_at",245,245,245)
) @(
 @(340,225,430,225,'1:N',350,180),@(740,225,850,215,'1:N',745,175),
 @(340,545,430,545,'1:N',350,500),@(740,545,850,540,'1:N',745,500),
 @(740,265,1280,215,'1:1',980,190),@(1170,540,1280,535,'N:1',1180,490),
 @(585,330,1445,430,'1:N',980,350),@(1445,640,1010,760,'1:1',1160,680),
 @(585,330,1445,760,'1:N',990,700)
)

$flow = Join-Path $assetDir 'checkout-flow.png'
New-Diagram $flow 'CHECKOUT AND ORDER TRACKING FLOW' @(
 @(60,210,230,120,"Customer`nselects variant",220,240,255),
 @(350,210,230,120,"Cart API`nvalidates stock",220,255,235),
 @(640,210,230,120,"Checkout API`ncreates order",255,242,210),
 @(930,120,250,120,"COD`nPENDING/CONFIRMED",235,245,225),
 @(930,350,250,120,"VNPay`npayment URL",255,225,225),
 @(1240,210,250,120,"Shipper`nSHIPPING",235,225,255),
 @(1550,210,200,120,"Customer`nCOMPLETED",225,235,245),
 @(640,600,540,130,"Failure branches`nOOS -> reject | Payment cancelled -> PENDING`nDelivery failed -> CANCELLED",245,245,245)
) @(
 @(290,270,350,270,'POST /cart/add',270,220),@(580,270,640,270,'POST /checkout',555,220),
 @(870,260,930,180,'COD',875,150),@(870,290,930,410,'VNPay',865,350),
 @(1180,180,1240,260,'assign',1165,205),@(1180,410,1240,280,'paid',1170,350),
 @(1490,270,1550,270,'delivered',1475,220),@(1055,470,910,600,'failure',940,520)
)

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$doc = $word.Documents.Add()
$sel = $word.Selection
$wdPageBreak=7; $wdAlignCenter=1; $wdAlignJustify=3; $wdCollapseEnd=0

function Set-Normal { $sel.Style='Normal'; $sel.Font.Name='Times New Roman'; $sel.Font.Size=12; $sel.ParagraphFormat.Alignment=$wdAlignJustify; $sel.ParagraphFormat.SpaceAfter=6; $sel.ParagraphFormat.LineSpacingRule=1 }
function Add-P([string]$Text){ Set-Normal; $sel.TypeText($Text); $sel.TypeParagraph() }
function Add-H([string]$Text,[int]$Level=1){ $sel.Style="Heading $Level"; $sel.Font.Name='Times New Roman'; $sel.TypeText($Text); $sel.TypeParagraph() }
function Add-Bullets([array]$Items){ foreach($x in $Items){Set-Normal;$sel.Range.ListFormat.ApplyBulletDefault();$sel.TypeText($x);$sel.TypeParagraph()};$sel.Range.ListFormat.RemoveNumbers() }
function Add-Table([array]$Headers,[array]$Rows){
 $range=$sel.Range; $table=$doc.Tables.Add($range,$Rows.Count+1,$Headers.Count); $table.Style='Table Grid'; $table.Rows.Item(1).Range.Bold=1
 for($c=0;$c -lt $Headers.Count;$c++){$table.Cell(1,$c+1).Range.Text=$Headers[$c]}
 for($r=0;$r -lt $Rows.Count;$r++){for($c=0;$c -lt $Headers.Count;$c++){$table.Cell($r+2,$c+1).Range.Text=[string]$Rows[$r][$c]}}
 $table.Range.Font.Name='Times New Roman';$table.Range.Font.Size=10;$sel.SetRange($table.Range.End,$table.Range.End);$sel.TypeParagraph()
}
function Add-Figure([string]$Path,[string]$Caption,[string]$Explanation){
 $sel.ParagraphFormat.Alignment=$wdAlignCenter; $shape=$sel.InlineShapes.AddPicture($Path,$false,$true); $shape.LockAspectRatio=-1; if($shape.Width -gt 480){$shape.Width=480}; $sel.TypeParagraph()
 $sel.Font.Name='Times New Roman';$sel.Font.Size=11;$sel.Font.Italic=1;$sel.TypeText($Caption);$sel.TypeParagraph();$sel.Font.Italic=0; Add-P("Giải thích: $Explanation")
}

$sel.ParagraphFormat.Alignment=$wdAlignCenter;$sel.Font.Name='Times New Roman';$sel.Font.Bold=1;$sel.Font.Size=16;$sel.TypeText('TRƯỜNG / KHOA: ........................................................');$sel.TypeParagraph();$sel.TypeParagraph()
$sel.Font.Size=24;$sel.TypeText('SOFTWARE ARCHITECTURE DESIGN REPORT');$sel.TypeParagraph();$sel.Font.Size=20;$sel.TypeText('SPORTSHOP – HỆ THỐNG THƯƠNG MẠI ĐIỆN TỬ ĐỒ THỂ THAO');$sel.TypeParagraph();$sel.TypeParagraph()
$sel.Font.Size=14;$sel.Font.Bold=0;$sel.TypeText('Báo cáo Project – Mẫu Report số 7');$sel.TypeParagraph();$sel.TypeParagraph();$sel.TypeText('Nhóm thực hiện: Team 6');$sel.TypeParagraph();$sel.TypeText('Giảng viên: ........................................................');$sel.TypeParagraph();$sel.TypeText('Học kỳ: 2026');$sel.TypeParagraph();$sel.TypeParagraph();$sel.TypeText('TP. Hồ Chí Minh, tháng 07 năm 2026');$sel.InsertBreak($wdPageBreak)

Add-H 'MỤC LỤC' 1; $tocRange=$sel.Range; $doc.TablesOfContents.Add($tocRange,$true,1,3) | Out-Null; $sel.SetRange($tocRange.End,$tocRange.End);$sel.InsertBreak($wdPageBreak)
Add-H 'DANH MỤC HÌNH VÀ BẢNG' 1
Add-P 'Hình 1. Luồng checkout và theo dõi đơn hàng.'; Add-P 'Hình 2. Mô hình ERD khái niệm.'; Add-P 'Hình 3. Kiến trúc tổng thể hệ thống SportShop.'
Add-P 'Bảng 1. Tác nhân và quyền chính; Bảng 2. Yêu cầu chức năng; Bảng 3. Yêu cầu phi chức năng; Bảng 4. Từ điển dữ liệu; Bảng 5. Danh mục API; Bảng 6. Kết quả kiểm thử.'

Add-H '1. GIỚI THIỆU ĐỀ TÀI' 1
Add-H '1.1. Bối cảnh và vấn đề' 2
Add-P 'Sự phát triển của thương mại điện tử làm thay đổi cách khách hàng tìm kiếm và mua sắm quần áo, giày và phụ kiện thể thao. Các cửa hàng vừa và nhỏ thường bán hàng qua mạng xã hội nên dữ liệu sản phẩm, tồn kho, đơn hàng và hội thoại chăm sóc khách hàng bị phân tán. Điều này gây khó khăn cho việc kiểm soát tồn kho, theo dõi giao hàng và đo lường doanh thu.'
Add-H '1.2. Giải pháp đề xuất' 2
Add-P 'SportShop là ứng dụng Flutter chạy trên Android và Web, phục vụ Guest, Customer, Admin và Shipper. Ứng dụng kết nối đến bốn dịch vụ Spring Boot qua REST/JSON: xác thực, danh mục sản phẩm, thực hiện đơn hàng và hỗ trợ chat. Dữ liệu được tách thành bốn cơ sở dữ liệu PostgreSQL theo miền nghiệp vụ; Redis hỗ trợ token/cache. Hệ thống hỗ trợ duyệt sản phẩm, giỏ hàng, checkout COD/VNPay, theo dõi đơn, quản trị và giao hàng.'
Add-H '1.3. Mục tiêu và phạm vi' 2
Add-Bullets @('Cung cấp hành trình mua sắm xuyên suốt từ tìm kiếm đến nhận hàng.','Áp dụng JWT và phân quyền theo vai trò.','Tách miền nghiệp vụ thành microservice dễ bảo trì và triển khai độc lập.','Cung cấp công cụ quản trị danh mục, tồn kho, người dùng, đơn hàng và báo cáo.','Hỗ trợ shipper cập nhật quá trình giao hàng và khách hàng theo dõi trạng thái.')
Add-P 'Ngoài phạm vi phiên bản hiện tại: tích hợp hãng vận chuyển thực tế, recommendation engine học máy ở quy mô lớn, đa kho và đối soát tài chính tự động.'
Add-H '1.4. Cơ sở kiểm chứng báo cáo' 2
Add-P 'Nội dung báo cáo được đối chiếu trực tiếp với toàn bộ cây mã nguồn tại thời điểm lập báo cáo: 230 file backend (khoảng 10.490 dòng) và 281 file mobile/cấu hình/tài liệu (khoảng 46.270 dòng). Phạm vi rà soát gồm controller, DTO, entity, repository, service, security, application properties, Maven, Docker, toàn bộ lib/test Flutter, route, presenter, repository, API service, model và tài liệu yêu cầu. Vì vậy báo cáo ưu tiên implementation hiện hành khi tài liệu cũ có khác biệt.'

Add-H '2. PHÂN TÍCH YÊU CẦU' 1
Add-H '2.1. Tác nhân' 2
Add-Table @('Tác nhân','Mô tả','Quyền chính') @(
 @('Guest','Người chưa đăng nhập','Xem/tìm sản phẩm, đăng ký, đăng nhập, mở chat công khai'),
 @('Customer','Khách hàng đã xác thực','Hồ sơ, địa chỉ, giỏ hàng, checkout, thanh toán, theo dõi đơn'),
 @('Admin','Quản trị hệ thống','CRUD catalog, sản phẩm, tồn kho, user, order, báo cáo, chat'),
 @('Shipper','Nhân viên giao hàng','Xem phân công, cập nhật trạng thái và báo cáo giao hàng')
)
Add-H '2.2. Yêu cầu chức năng' 2
Add-Table @('ID','Nhóm','Yêu cầu/tiêu chí chấp nhận') @(
 @('FR-01','Authentication','Đăng ký, đăng nhập, refresh/logout, đổi và khôi phục mật khẩu.'),
 @('FR-02','Catalog','Liệt kê, tìm kiếm, lọc và xem chi tiết sản phẩm/variant.'),
 @('FR-03','Cart','Thêm, đổi số lượng, xóa; không vượt tồn kho.'),
 @('FR-04','Checkout','Chọn địa chỉ, COD/VNPay; tạo order và order item nhất quán.'),
 @('FR-05','Order','Khách xem lịch sử/tracking; admin xử lý; shipper cập nhật giao hàng.'),
 @('FR-06','Administration','Quản lý brand, category, sport, product, stock, user, setting.'),
 @('FR-07','Reporting','Tổng hợp doanh thu, số đơn, khách hàng và sản phẩm theo kỳ.'),
 @('FR-08','Chat','Tạo phòng, gửi/nhận tin nhắn và hỗ trợ khách hàng.')
 ,@('FR-09','Workforce','Quản lý ca làm, đơn nghỉ phép và quyết định duyệt/từ chối.'),
 @('FR-10','Delivery','Phân công đơn, quản lý báo cáo giao hàng và giám sát vận chuyển.'),
 @('FR-11','Configuration','Quản lý system setting theo key/value và mô tả.'),
 @('FR-12','Merchandising','Quản lý collection và liên kết nhiều sản phẩm vào bộ sưu tập.')
)
Add-H '2.3. Yêu cầu phi chức năng' 2
Add-Table @('Thuộc tính','Mục tiêu') @(
 @('Security','JWT, BCrypt, RBAC; token lưu trong FlutterSecureStorage; không log bí mật.'),
 @('Performance','Danh sách sản phẩm mục tiêu dưới 3 giây trên 4G; thao tác giỏ dưới 1,5 giây.'),
 @('Reliability','Transaction cho checkout; lỗi mạng hiển thị thân thiện; không làm ứng dụng crash.'),
 @('Maintainability','Flutter Clean Architecture + MVP; backend Controller-Service-Repository; DTO tách entity.'),
 @('Portability','Android API 24+ và trình duyệt Chromium hiện đại; triển khai bằng Docker Compose.'),
 @('Scalability','Microservice và database-per-service cho phép mở rộng từng miền độc lập.')
)

Add-H '3. THIẾT KẾ HỆ THỐNG' 1
Add-H '3.1. Phân rã chức năng' 2
Add-P 'Client Flutter được tổ chức theo View → Presenter → Repository → Service → ApiClient. Presenter dùng ChangeNotifier để quản lý trạng thái; repository che giấu nguồn dữ liệu; service ánh xạ REST và model. Backend từng dịch vụ dùng Controller → Service → Repository → PostgreSQL, DTO cho request/response và Spring Security tại biên.'
Add-H '3.2. Luồng nghiệp vụ chính' 2
Add-Figure $flow 'Hình 1. Luồng checkout và theo dõi đơn hàng.' 'Khách chọn variant và thêm giỏ. Order Service kiểm tra tồn kho thông qua Catalog Service trước khi tạo đơn. COD đi trực tiếp sang xử lý; VNPay cần hoàn thành thanh toán. Sau phân công, shipper chuyển đơn sang SHIPPING/DELIVERED và khách xác nhận COMPLETED. Các nhánh thất bại giữ hoặc hủy đơn theo quy tắc trạng thái.'

Add-H '4. THIẾT KẾ CƠ SỞ DỮ LIỆU (ERD)' 1
Add-Figure $erd 'Hình 2. ERD khái niệm của SportShop.' 'Role–User và User–Address thuộc Auth DB; Brand/Category/Sport–Product–Variant thuộc Catalog DB; Cart/Order/Assignment thuộc Order DB; Room–Message thuộc Chat DB. Quan hệ giữa các database được giữ bằng định danh logic và gọi API nội bộ thay vì foreign key xuyên dịch vụ.'
Add-H '4.1. Từ điển dữ liệu rút gọn' 2
Add-Table @('Bảng/Entity','Khóa và trường quan trọng','Ý nghĩa') @(
 @('users','user_id, role_id, email, password, status','Tài khoản và trạng thái truy cập.'),
 @('user_addresses','address_id, user_id, recipient, phone, is_default','Địa chỉ nhận hàng của khách.'),
 @('products','product_id, brand/category/sport_id, name, status','Thông tin chung của sản phẩm.'),
 @('product_variants','variant_id, product_id, sku, size, color, price, stock','Đơn vị có thể bán và tồn kho.'),
 @('carts/cart_items','cart_id, user_id; item_id, variant_id, quantity','Giỏ hiện hành của khách.'),
 @('orders/order_items','order_id, user_id, status, total; item_id, variant_id','Ảnh chụp giao dịch tại thời điểm mua.'),
 @('order_assignments','assignment_id, order_id, shipper_id, status','Phân công giao hàng.'),
 @('chat_rooms/messages','room_id; message_id, sender, content, sent_at','Hội thoại hỗ trợ khách hàng.')
 ,@('collections/collection_products','collection_id; product_id','Bộ sưu tập và quan hệ nhiều-nhiều với sản phẩm.'),
 @('work_shifts/leave_requests','shift_id; leave_id, user_id, date, status','Lịch làm việc và quy trình nghỉ phép.'),
 @('delivery_reports','report_id, order_id, shipper_id, status, note','Bằng chứng và kết quả giao hàng.'),
 @('system_settings','setting_key, value, description','Cấu hình vận hành có thể quản trị.'),
 @('refresh/password/blacklist tokens','token_id, jwt_id, expiry, revoked','Vòng đời refresh, reset và access token bị thu hồi.')
)
Add-H '4.2. Quy tắc toàn vẹn' 2
Add-Bullets @('Email và SKU là duy nhất.','Số lượng giỏ và tồn kho không âm; quantity phải lớn hơn 0.','Mỗi khách chỉ có tối đa một địa chỉ mặc định.','Tổng đơn bằng tổng price × quantity tại thời điểm checkout.','Chuyển trạng thái đơn phải theo state machine; thao tác checkout phải có transaction.')

Add-H '5. KIẾN TRÚC HỆ THỐNG' 1
Add-Figure $arch 'Hình 3. Kiến trúc tổng thể SportShop.' 'Flutter định tuyến request theo miền đến cổng 8081–8084. Mỗi dịch vụ sở hữu logic và dữ liệu của mình; Order Service gọi Auth/Catalog khi cần xác minh người dùng hoặc variant. Redis hỗ trợ dữ liệu ngắn hạn. Các tích hợp VNPay, email và AI nằm ngoài biên hệ thống và được gọi qua adapter.'
Add-H '5.1. Lý do lựa chọn microservice' 2
Add-P 'Việc tách Auth, Catalog, Order và Chat theo bounded context giảm coupling, cho phép triển khai và mở rộng riêng. Đổi lại, hệ thống phải quản lý cấu hình nhiều dịch vụ, lỗi mạng nội bộ và tính nhất quán cuối cùng. Trong phạm vi học thuật, REST đồng bộ và Docker Compose giúp cân bằng giữa tính minh họa kiến trúc và khả năng vận hành.'
Add-H '5.2. Bảo mật' 2
Add-P 'Spring Security xác thực JWT và ánh xạ claim roles thành ROLE_*. Các endpoint công khai được permitAll; endpoint nghiệp vụ yêu cầu bearer token. Mật khẩu dùng BCrypt. Flutter không gắn token cũ vào login/register/forgot-password và lưu token bằng secure storage. CORS được giới hạn qua cấu hình môi trường.'

Add-H '6. THIẾT KẾ API' 1
Add-P 'Base URL cục bộ trên Android Emulator lần lượt là http://10.0.2.2:8081/api đến :8084/api; Web dùng localhost. Request/response dùng application/json; endpoint bảo vệ dùng Authorization: Bearer <access_token>. Mã trạng thái chính: 200/201 thành công, 400 dữ liệu sai, 401 chưa xác thực, 403 thiếu quyền, 404 không tồn tại và 409 xung đột nghiệp vụ.'
Add-Table @('Service','Method & Endpoint','Mục đích','Auth') @(
 @('Auth','POST /auth/register; /auth/login','Tạo tài khoản và đăng nhập','Public'),
 @('Auth','GET/PUT /user/profile/me','Xem/cập nhật hồ sơ','User'),
 @('Auth','GET/POST/PUT /user/addresses','Quản lý địa chỉ','User'),
 @('Catalog','GET /products; GET /products/{id}','Danh sách/chi tiết','Public'),
 @('Catalog','POST/PUT /admin/products','Quản trị sản phẩm','Admin'),
 @('Catalog','PATCH /admin/products/variants/{id}/stock','Cập nhật tồn','Admin'),
 @('Order','GET /cart; POST /cart/add','Xem/thêm giỏ','Customer'),
 @('Order','POST /orders/checkout','Tạo đơn từ giỏ','Customer'),
 @('Order','GET /orders/my-orders','Lịch sử đơn','Customer'),
 @('Order','PATCH /orders/{id}/status','Cập nhật trạng thái','Admin/Shipper'),
 @('Order','GET /payment/create_payment/{orderId}','Tạo URL VNPay','Customer'),
 @('Chat','POST /chat/rooms; POST /chat/rooms/{id}/messages','Phòng và tin nhắn','Theo nghiệp vụ'),
 @('Order','GET /admin/reports/dashboard','Báo cáo tổng hợp','Admin')
 ,@('Order','CRUD /admin/order-assignments','Phân công đơn cho shipper','Admin'),
 @('Order','CRUD /admin/delivery-reports','Quản lý báo cáo giao hàng','Admin/Shipper'),
 @('Order','CRUD /admin/work-shifts','Quản lý ca làm việc','Admin'),
 @('Order','CRUD /admin/leave-requests','Nghỉ phép và phê duyệt','User/Admin'),
 @('Auth','GET/PUT/DELETE /admin/settings/{key}','Cấu hình hệ thống','Admin'),
 @('Catalog','CRUD /collections/admin','Quản lý bộ sưu tập','Admin'),
 @('Catalog','POST /admin/products/ai-suggest','Gợi ý phân loại sản phẩm','Admin')
)

Add-H '7. CÁC CHỨC NĂNG CHÍNH' 1
Add-H '7.1. Khách hàng' 2; Add-P 'Đăng ký/đăng nhập; xem và lọc catalog; chọn variant; quản lý giỏ; địa chỉ; checkout COD/VNPay; lịch sử, chi tiết và timeline đơn; xác nhận nhận hàng; chat hỗ trợ.'
Add-H '7.2. Quản trị viên' 2; Add-P 'Dashboard doanh thu; quản lý sản phẩm, variant, tồn kho, brand/category/sport/collection; quản lý user/role/setting; theo dõi và xử lý đơn; phân công shipper; hỗ trợ chat.'
Add-H '7.3. Shipper' 2; Add-P 'Xem danh sách được phân công, chi tiết người nhận và sản phẩm, bắt đầu giao, báo giao thành công/thất bại và tạo báo cáo giao hàng.'
Add-H '7.4. Nhân sự và vận hành' 2; Add-P 'Admin lập và cập nhật ca làm, xem đơn nghỉ phép, phê duyệt hoặc từ chối; nhân viên tạo yêu cầu nghỉ. Module phân công đơn liên kết order với shipper, còn delivery report ghi nhận trạng thái, nội dung báo cáo và quá trình thực hiện.'
Add-H '7.5. Bộ sưu tập, cấu hình và AI hỗ trợ' 2; Add-P 'Admin tạo collection, gắn hoặc gỡ sản phẩm, bật/tắt trạng thái hiển thị; quản lý system setting theo key; sử dụng AI Product Service để gợi ý phân loại trước khi kiểm tra và xác nhận lưu sản phẩm.'

Add-H '8. QUY TRÌNH TRIỂN KHAI' 1
Add-H '8.1. Chuẩn bị' 2
Add-Bullets @('Cài Docker Desktop/Docker Compose, Flutter SDK và Android Studio hoặc Chrome.','Tạo file .env cho từng service từ .env.example; cấu hình PostgreSQL, JWT, Redis, VNPay/email nếu sử dụng.','Khởi tạo bốn database: auth_db, product_catalog_db, order_fulfillment_db, support_chat_db.')
Add-H '8.2. Backend' 2
Add-P 'Từ thư mục backend chạy docker compose up --build -d. Kiểm tra container ở các cổng 8081, 8082, 8083, 8084 và Redis 6379. Có thể compile riêng bằng mvn -q -DskipTests compile trong từng service.'
Add-H '8.3. Mobile/Web' 2
Add-P 'Từ thư mục mobile chạy flutter pub get, sau đó flutter run cho Android hoặc flutter run -d chrome cho Web. Khi triển khai qua gateway, truyền --dart-define=SPORTSHOP_API_URL=<gateway>/api; nếu chạy trực tiếp, ứng dụng tự định tuyến theo cổng từng microservice.'
Add-H '8.4. Kiểm tra sau triển khai' 2
Add-Bullets @('Đăng ký/đăng nhập và refresh token.','Đọc catalog và thêm variant còn hàng vào giỏ.','Checkout COD; kiểm tra đơn và tồn kho.','Phân công shipper, cập nhật SHIPPING → DELIVERED → COMPLETED.','Kiểm tra dashboard và hội thoại chat.')

Add-H '9. KẾT QUẢ ĐẠT ĐƯỢC' 1
Add-P 'Dự án đã hình thành ứng dụng đa vai trò với giao diện Flutter cho Android/Web và backend được tách thành bốn Spring Boot service. Các miền xác thực, catalog, order/payment/delivery và chat có API, model, repository và cấu hình triển khai độc lập. Luồng mua hàng, quản trị và giao hàng được nối từ UI đến database.'
Add-Table @('Hạng mục','Kết quả','Bằng chứng trong mã nguồn') @(
 @('Authentication','Hoàn thành luồng auth, JWT, role, profile/address','auth-service; mobile/service/auth'),
 @('Catalog','Danh sách, chi tiết, CRUD và stock variant','product-catalog-service'),
 @('Commerce','Cart, checkout, order, payment và tracking','order-fulfillment-service'),
 @('Operations','Admin dashboard, assignment, delivery report','mobile/view/admin; delivery_staff'),
 @('Chat','Room/message cho customer và admin','support-chat-service'),
 @('Deployment','Dockerfile từng service và docker-compose','backend/docker-compose.yml'),
 @('Verification','Cả 4 Maven service compile thành công ngày 16/07/2026; có Flutter unit/widget/integration tests và mapping smoke script','backend/*/pom.xml; mobile/test; mobile/integration_test; mobile/tooling')
)
Add-H '9.1. Hạn chế hiện tại' 2
Add-Bullets @('Chưa có service discovery/API gateway và observability tập trung.','Một số tài liệu cũ còn mô tả monolith; báo cáo này phản ánh code microservice hiện tại.','Kiểm thử tải, security penetration test và CI/CD production chưa đầy đủ.','Tích hợp VNPay/email/AI phụ thuộc credential và môi trường ngoài.')

Add-H '10. HƯỚNG PHÁT TRIỂN' 1
Add-Bullets @('Bổ sung API Gateway, service discovery, centralized configuration và rate limiting.','Dùng message broker cho order-payment-inventory và triển khai Saga/outbox.','Thêm OpenTelemetry, Prometheus/Grafana, tracing và alerting.','Xây dựng CI/CD, container registry, migration Flyway và môi trường staging.','Bổ sung recommendation engine, tìm kiếm Elasticsearch và thông báo FCM.','Tăng coverage unit/integration/contract/E2E và kiểm thử hiệu năng, bảo mật.','Triển khai đa kho, tích hợp đơn vị vận chuyển và đối soát VNPay tự động.')

Add-H '11. KẾT LUẬN' 1
Add-P 'SportShop đáp ứng mục tiêu số hóa quy trình bán đồ thể thao và thể hiện đầy đủ các quyết định kiến trúc từ yêu cầu, dữ liệu, API đến triển khai. Kiến trúc Flutter phân lớp kết hợp microservice Spring Boot tạo ranh giới trách nhiệm rõ ràng, phù hợp mở rộng. Các hạn chế về vận hành phân tán là cơ sở cho lộ trình gateway, messaging, observability và CI/CD trong phiên bản tiếp theo.'

Add-H '12. PHỤ LỤC SỬ DỤNG AI' 1
Add-P 'Công cụ AI được sử dụng để hỗ trợ rà soát kiến trúc, chuẩn hóa tài liệu, phát hiện lỗi và đề xuất mã. Nhóm chịu trách nhiệm kiểm tra lại nội dung, chạy build/test và điều chỉnh theo cấu trúc thực tế. Không đưa credential, token hoặc dữ liệu cá nhân thật vào prompt.'
Add-Table @('Nhiệm vụ','Ví dụ prompt','Cách kiểm chứng') @(
 @('Rà soát kiến trúc','Đối chiếu report với code microservice hiện tại','Kiểm tra docker-compose, application và source package.'),
 @('Sửa lỗi API','Phân tích stack trace Spring và request Flutter','Compile Maven, kiểm tra interceptor và endpoint.'),
 @('Hoàn thiện báo cáo','Bổ sung ERD, API, deployment, result','Đối chiếu SRS, schema, controllers và repository.')
)
Add-P 'Tuyên bố trách nhiệm: Toàn bộ nội dung và mã có hỗ trợ bởi AI đã được người thực hiện xem xét, kiểm chứng và điều chỉnh để tương thích với kiến trúc Team 6.'

Add-H '13. PHỤ LỤC ĐỐI CHIẾU MÃ NGUỒN' 1
Add-H '13.1. Thống kê phạm vi rà soát' 2
Add-Table @('Khu vực','Số file','Số dòng xấp xỉ','Thành phần') @(
 @('Auth Service','67','Thuộc tổng 10.490 backend','Auth, user, role, profile, address, setting, JWT/token, email'),
 @('Product Catalog Service','63','Thuộc tổng 10.490 backend','Product, variant, image, brand, category, sport, collection, AI'),
 @('Order Fulfillment Service','67','Thuộc tổng 10.490 backend','Cart, order, payment, assignment, delivery report, shift, leave, report'),
 @('Support Chat Service','31','Thuộc tổng 10.490 backend','Chatbot, room, message và bản đọc catalog phục vụ chat'),
 @('Flutter lib','240','Thuộc tổng 46.270 mobile','Core, model, service, repository, presenter, view/widget'),
 @('Flutter test/integration','11','Thuộc tổng 46.270 mobile','Unit, widget, routing/mapping và integration smoke'),
 @('Mobile config/docs/platform','30','Thuộc tổng 46.270 mobile','Android, pubspec, SRS/BRD/FRD/NFR/API contract')
)
Add-H '13.2. Đối chiếu kiến trúc với thư mục' 2
Add-Table @('Quyết định','Bằng chứng triển khai') @(
 @('Database per service','backend/init-db.sql tạo auth_db, product_catalog_db, order_fulfillment_db, support_chat_db.'),
 @('Independent deployment','Mỗi service có pom.xml, Dockerfile, application-*.properties và application main riêng.'),
 @('REST microservice routing','ApiEndpoints.resolveBaseUrl ánh xạ Auth :8081, Catalog :8082, Order :8083, Chat :8084.'),
 @('Flutter Clean Architecture + MVP','lib/view → presenter → repository → service → core/network; ChangeNotifier và constructor injection.'),
 @('Role-based access','GoRouter guard phía client; Spring Security + @PreAuthorize phía server.'),
 @('Inter-service communication','Order service có AuthServiceClient/CatalogServiceClient; catalog có internal variant endpoint.'),
 @('Container orchestration','backend/docker-compose.yml khai báo 4 service và Redis 7.'),
 @('Build verification','mvn -q -DskipTests compile thành công cho cả bốn service.')
)
Add-H '13.3. Danh sách màn hình triển khai' 2
Add-P 'Router khai báo 51 đường dẫn, bao phủ splash/auth/public, customer catalog/search/detail/gallery/cart/checkout/address/order/tracking/profile/support/chat, admin dashboard/revenue/order/product/variant/category/brand/sport/collection/delivery/chat/user/profile/setting/staff và delivery staff home/assigned order/status/account. Route guard điều hướng theo trạng thái token và role.'

foreach($section in $doc.Sections){$section.Headers.Item(1).Range.Text='SPORTSHOP – SOFTWARE ARCHITECTURE DESIGN REPORT';$section.Headers.Item(1).Range.Font.Name='Times New Roman';$section.Headers.Item(1).Range.Font.Size=9;$section.Footers.Item(1).PageNumbers.Add() | Out-Null}
$doc.TablesOfContents.Item(1).Update()
$doc.Styles.Item('Normal').Font.Name='Times New Roman';$doc.Styles.Item('Normal').Font.Size=12

$docx=Join-Path $Root 'Software Architecture Design_Report 1.01_Completed.docx'
$pdf=Join-Path $Root 'Software Architecture Design_Report 1.01_Completed.pdf'
$doc.SaveAs($docx,12)
$doc.ExportAsFixedFormat($pdf,17)
$pages=$doc.ComputeStatistics(2)
$doc.Close($false);$word.Quit()
[Runtime.InteropServices.Marshal]::ReleaseComObject($sel)|Out-Null
[Runtime.InteropServices.Marshal]::ReleaseComObject($doc)|Out-Null
[Runtime.InteropServices.Marshal]::ReleaseComObject($word)|Out-Null
[GC]::Collect();[GC]::WaitForPendingFinalizers()
Write-Output "DOCX=$docx";Write-Output "PDF=$pdf";Write-Output "PAGES=$pages"
