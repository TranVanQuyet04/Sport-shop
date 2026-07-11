param(
  [string]$ApiBase = "http://localhost:8080/api",
  [string]$Email = "demo.an@sport.vn",
  [string]$Password = "Demo@1234",
  [string]$AdminEmail = "admin@e.com",
  [string]$AdminPassword = "quyet"
)

$ErrorActionPreference = "Stop"

function Assert-True {
  param([bool]$Condition, [string]$Message)
  if (-not $Condition) {
    throw $Message
  }
}

function Has-Property {
  param([object]$Object, [string]$Name)
  return $null -ne $Object.PSObject.Properties[$Name]
}

function Require-Properties {
  param([object]$Object, [string[]]$Names, [string]$Label)
  foreach ($name in $Names) {
    Assert-True (Has-Property $Object $name) "$Label missing field: $name"
  }
}

function Get-ListPayload {
  param([object]$Value, [string]$NestedName = "")

  if ($NestedName -and (Has-Property $Value $NestedName)) {
    return @($Value.$NestedName)
  }

  if ((Has-Property $Value "data") -and $NestedName -and (Has-Property $Value.data $NestedName)) {
    return @($Value.data.$NestedName)
  }

  if ((Has-Property $Value "data") -and $Value.data -is [array]) {
    return @($Value.data)
  }

  return @($Value)
}

Write-Host "1. Checking public products..."
$products = Invoke-RestMethod -Method Get -Uri "$ApiBase/products"
Assert-True (@($products).Count -gt 0) "GET /products returned no products"
Require-Properties @($products)[0] @("id", "productName", "categoryName", "brandName", "sportName", "price", "image_url") "Product summary"

$navigation = Invoke-RestMethod -Method Get -Uri "$ApiBase/navigation/main"
foreach ($category in @($navigation)) {
  Require-Properties $category @("id", "categoryName", "children") "Navigation category"
  foreach ($child in @($category.children)) {
    Require-Properties $child @("id", "categoryName", "children") "Navigation child category"
  }
}

$publicBrands = Invoke-RestMethod -Method Get -Uri "$ApiBase/products/brands"
Assert-True (@($publicBrands).Count -gt 0) "GET /products/brands returned no brands"
Require-Properties @($publicBrands)[0] @("id", "brandName", "brandBanner", "slug", "logo", "description", "active") "Public brand"

$publicCategories = Invoke-RestMethod -Method Get -Uri "$ApiBase/products/categories"
Assert-True (@($publicCategories).Count -gt 0) "GET /products/categories returned no categories"
Require-Properties @($publicCategories)[0] @("id", "categoryName", "description", "parentId") "Public category"

$filteredByCategory = Invoke-RestMethod -Method Get -Uri "$ApiBase/products?categoryId=$(@($publicCategories)[0].id)"
foreach ($product in @($filteredByCategory)) {
  Require-Properties $product @("id", "productName", "categoryName", "brandName", "sportName", "price", "image_url") "Filtered product by category"
}

$filteredByBrand = Invoke-RestMethod -Method Get -Uri "$ApiBase/products?brandId=$(@($publicBrands)[0].id)"
foreach ($product in @($filteredByBrand)) {
  Require-Properties $product @("id", "productName", "categoryName", "brandName", "sportName", "price", "image_url") "Filtered product by brand"
}

$detail = $null
$variant = $null
$fallbackDetail = $null
$fallbackVariant = $null
foreach ($product in @($products)) {
  $candidate = Invoke-RestMethod -Method Get -Uri "$ApiBase/products/$($product.id)"
  Require-Properties $candidate @("id", "productName", "description", "categoryName", "brandName", "sportName", "variants") "Product detail"

  foreach ($item in @($candidate.variants)) {
    Require-Properties $item @("id", "sku", "size", "color", "price", "stockQuantity", "imageUrls") "Variant"
    if ($null -eq $fallbackVariant) {
      $fallbackDetail = $candidate
      $fallbackVariant = $item
    }
    if (($item.stockQuantity -as [int]) -gt 0) {
      $detail = $candidate
      $variant = $item
      break
    }
  }

  if ($null -ne $variant) {
    break
  }
}

if ($null -eq $variant) {
  Assert-True ($null -ne $fallbackVariant) "No product variant found for add-to-cart test"
  $detail = $fallbackDetail
  $variant = $fallbackVariant
  Write-Host "   No in-stock variant found; selected variant will get temporary stock."
}
Write-Host "   Selected product #$($detail.id), variant #$($variant.id)"

Write-Host "1b. Checking admin catalog endpoints..."
$adminLoginBody = @{
  email = $AdminEmail
  password = $AdminPassword
} | ConvertTo-Json
$adminLogin = Invoke-RestMethod -Method Post -Uri "$ApiBase/auth/login" -ContentType "application/json" -Body $adminLoginBody
Require-Properties $adminLogin @("accessToken", "refreshToken", "role", "user") "Admin login response"
Assert-True ([string]::IsNullOrWhiteSpace($adminLogin.accessToken) -eq $false) "Admin login did not return accessToken"
$adminHeaders = @{ Authorization = "Bearer $($adminLogin.accessToken)" }

$adminProducts = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/products" -Headers $adminHeaders
Assert-True (@($adminProducts).Count -gt 0) "GET /admin/products returned no products"
Require-Properties @($adminProducts)[0] @("id", "productName", "categoryName", "brandName", "sportName", "price", "image_url") "Admin product summary"
$adminProductDetail = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/products/$(@($adminProducts)[0].id)" -Headers $adminHeaders
Require-Properties $adminProductDetail @("id", "productName", "description", "categoryName", "brandName", "sportName", "variants") "Admin product detail"

$startDate = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddT00:00:00")
$endDate = (Get-Date).ToString("yyyy-MM-ddT23:59:59")
$dashboardReport = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/reports/dashboard?startDate=$startDate&endDate=$endDate" -Headers $adminHeaders
Require-Properties $dashboardReport @("totalRevenue", "totalOrders", "newUsers", "pendingOrders", "dailyRevenues") "Dashboard report"
foreach ($dailyRevenue in @($dashboardReport.dailyRevenues)) {
  Require-Properties $dailyRevenue @("dayOfWeek", "dateStr", "revenueCurrent", "revenuePrevious", "ordersCount") "Daily revenue"
}

$adminCategories = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/categories" -Headers $adminHeaders
Assert-True (@($adminCategories).Count -gt 0) "GET /admin/categories returned no categories"
Require-Properties @($adminCategories)[0] @("id", "categoryName", "description", "parentId") "Admin category"

$brandResponse = Invoke-RestMethod -Method Get -Uri "$ApiBase/brands" -Headers $adminHeaders
$adminBrands = Get-ListPayload $brandResponse "brands"
Assert-True (@($adminBrands).Count -gt 0) "GET /brands returned no brands"
Require-Properties @($adminBrands)[0] @("id", "brandName", "slug", "logo", "description", "isActive") "Admin brand"

$adminSports = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/sports" -Headers $adminHeaders
Assert-True (@($adminSports).Count -gt 0) "GET /admin/sports returned no sports"
Require-Properties @($adminSports)[0] @("id", "sportName", "description") "Admin sport"

$collections = Invoke-RestMethod -Method Get -Uri "$ApiBase/collections"
if (@($collections).Count -gt 0) {
  Require-Properties @($collections)[0] @("id", "name", "slug", "description", "imageUrl", "type", "isActive", "startDate", "endDate", "variants") "Collection"
  foreach ($collectionVariant in @(@($collections)[0].variants)) {
    Require-Properties $collectionVariant @("id", "sku", "size", "color", "price", "stockQuantity", "imageUrls") "Collection variant"
  }
} else {
  Write-Host "   No collections found; skipped collection field assertion."
}

$adminUsers = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/users" -Headers $adminHeaders
Assert-True (@($adminUsers).Count -gt 0) "GET /admin/users returned no users"
Require-Properties @($adminUsers)[0] @("id", "fullName", "email", "phoneNumber", "role", "roleName", "roleDisplayName", "status") "Admin user"
$shipperUser = @($adminUsers) | Where-Object { $_.role -eq "SHIPPER" -or $_.roleName -eq "SHIPPER" } | Select-Object -First 1
Assert-True ($null -ne $shipperUser) "No SHIPPER user found for staff operations mapping test"

$adminRoles = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/roles" -Headers $adminHeaders
Assert-True (@($adminRoles).Count -gt 0) "GET /admin/roles returned no roles"
Require-Properties @($adminRoles)[0] @("roleId", "roleName", "roleCode", "roleDescription") "Admin role"

$settings = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/settings" -Headers $adminHeaders
foreach ($setting in @($settings)) {
  Require-Properties $setting @("key", "value", "description") "System setting"
}
$tempSettingKey = "harness.mobile.mapping.$(Get-Date -Format 'yyyyMMddHHmmss')"
try {
  $createSettingBody = @{
    value = "created"
    description = "Harness temporary setting"
  } | ConvertTo-Json
  $createdSetting = Invoke-RestMethod -Method Post -Uri "$ApiBase/admin/settings?key=$tempSettingKey" -Headers $adminHeaders -ContentType "application/json" -Body $createSettingBody
  Require-Properties $createdSetting @("key", "value", "description") "Created system setting"
  Assert-True ($createdSetting.key -eq $tempSettingKey) "Created setting key mismatch"
  Assert-True ($createdSetting.value -eq "created") "Created setting value mismatch"

  $updateTempSettingBody = @{
    value = "updated"
    description = "Harness temporary setting updated"
  } | ConvertTo-Json
  $updatedTempSetting = Invoke-RestMethod -Method Put -Uri "$ApiBase/admin/settings/$tempSettingKey" -Headers $adminHeaders -ContentType "application/json" -Body $updateTempSettingBody
  Require-Properties $updatedTempSetting @("key", "value", "description") "Updated temporary system setting"
  Assert-True ($updatedTempSetting.value -eq "updated") "Temporary setting was not updated"

  $readTempSetting = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/settings/$tempSettingKey" -Headers $adminHeaders
  Require-Properties $readTempSetting @("key", "value", "description") "Read temporary system setting"
} finally {
  try {
    Invoke-RestMethod -Method Delete -Uri "$ApiBase/admin/settings/$tempSettingKey" -Headers $adminHeaders | Out-Null
  } catch {
    Write-Warning "Could not delete temp setting ${tempSettingKey}: $($_.Exception.Message)"
  }
}

$notificationSetting = @($settings) | Where-Object { $_.key -eq "notifications.enabled" } | Select-Object -First 1
$originalNotificationValue = if ($notificationSetting) { $notificationSetting.value } else { "true" }
$temporaryNotificationValue = if ($originalNotificationValue -eq "true") { "false" } else { "true" }
try {
  $settingBody = @{
    value = $temporaryNotificationValue
    description = "Harness notification toggle mapping test"
  } | ConvertTo-Json
  $updatedSetting = Invoke-RestMethod -Method Put -Uri "$ApiBase/admin/settings/notifications.enabled" -Headers $adminHeaders -ContentType "application/json" -Body $settingBody
  Require-Properties $updatedSetting @("key", "value", "description") "Updated system setting"
  Assert-True ($updatedSetting.key -eq "notifications.enabled") "System setting key mismatch"
  Assert-True ($updatedSetting.value -eq $temporaryNotificationValue) "System setting value was not updated"
} finally {
  $restoreSettingBody = @{
    value = $originalNotificationValue
    description = "Bật hoặc tắt thông báo hệ thống cho quản trị viên."
  } | ConvertTo-Json
  $restoreSettingBody = @{ value = $originalNotificationValue; description = "Admin notification setting" } | ConvertTo-Json
  Invoke-RestMethod -Method Put -Uri "$ApiBase/admin/settings/notifications.enabled" -Headers $adminHeaders -ContentType "application/json" -Body $restoreSettingBody | Out-Null
}

$assignments = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/order-assignments" -Headers $adminHeaders
if (@($assignments).Count -gt 0) {
  $assignment = @($assignments)[0]
  Require-Properties $assignment @("id", "orderId", "staffId", "staffName", "staffRole", "assignedById", "assignedAt", "note") "Order assignment"

  $deliveryReports = Invoke-RestMethod -Method Get -Uri "$ApiBase/orders/$($assignment.orderId)/delivery-reports" -Headers $adminHeaders
  foreach ($report in @($deliveryReports)) {
    Require-Properties $report @("id", "orderId", "reportedById", "reportedByName", "status", "reason", "note", "evidenceImageUrl", "createdAt") "Delivery report"
    Assert-True (($report.status -eq "FAILED") -or ($report.status -eq "RETURNED")) "Delivery report status should be FAILED or RETURNED"
  }
} else {
  Write-Host "   No order assignments found; skipped assignment/report field assertion."
}

$workShiftId = $null
$leaveRequestId = $null
try {
  $shiftDate = (Get-Date).AddDays(3).ToString("yyyy-MM-dd")
  $workShiftBody = @{
    userId = [int64]$shipperUser.id
    shiftDate = $shiftDate
    shiftCode = "HARNESS_AM"
    note = "Harness work shift mapping test"
  } | ConvertTo-Json
  $workShift = Invoke-RestMethod -Method Post -Uri "$ApiBase/admin/work-shifts" -Headers $adminHeaders -ContentType "application/json" -Body $workShiftBody
  $workShiftId = $workShift.id
  Require-Properties $workShift @("id", "userId", "fullName", "roleName", "shiftDate", "shiftCode", "note", "createdAt") "Work shift"
  Assert-True ("$($workShift.userId)" -eq "$($shipperUser.id)") "Work shift userId mismatch"
  Assert-True ($workShift.shiftCode -eq "HARNESS_AM") "Work shift shiftCode mismatch"

  $updateWorkShiftBody = @{
    userId = [int64]$shipperUser.id
    shiftDate = $shiftDate
    shiftCode = "HARNESS_PM"
    note = "Harness work shift update mapping test"
  } | ConvertTo-Json
  $updatedWorkShift = Invoke-RestMethod -Method Put -Uri "$ApiBase/admin/work-shifts/$workShiftId" -Headers $adminHeaders -ContentType "application/json" -Body $updateWorkShiftBody
  Require-Properties $updatedWorkShift @("id", "userId", "fullName", "roleName", "shiftDate", "shiftCode", "note", "createdAt") "Updated work shift"
  Assert-True ($updatedWorkShift.shiftCode -eq "HARNESS_PM") "Work shift update shiftCode mismatch"
  Assert-True ($updatedWorkShift.note -eq "Harness work shift update mapping test") "Work shift update note mismatch"

  $listedShifts = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/work-shifts?userId=$($shipperUser.id)&startDate=$shiftDate&endDate=$shiftDate" -Headers $adminHeaders
  $listedShift = @($listedShifts) | Where-Object { "$($_.id)" -eq "$workShiftId" } | Select-Object -First 1
  Assert-True ($null -ne $listedShift) "Created work shift was not found in filtered list"

  $leaveDate = (Get-Date).AddDays(10).ToString("yyyy-MM-dd")
  $leaveBody = @{
    userId = [int64]$shipperUser.id
    startDate = $leaveDate
    days = 1
    reason = "Harness leave mapping test"
  } | ConvertTo-Json
  $leaveRequest = Invoke-RestMethod -Method Post -Uri "$ApiBase/user/leave-requests" -Headers $adminHeaders -ContentType "application/json" -Body $leaveBody
  $leaveRequestId = $leaveRequest.id
  Require-Properties $leaveRequest @("id", "userId", "fullName", "roleName", "startDate", "days", "reason", "status", "createdAt", "decidedAt", "decidedById") "Leave request"
  Assert-True ($leaveRequest.status -eq "PENDING") "New leave request should be PENDING"

  $updateLeaveBody = @{
    userId = [int64]$shipperUser.id
    startDate = $leaveDate
    days = 2
    reason = "Harness leave update mapping test"
  } | ConvertTo-Json
  $updatedLeaveRequest = Invoke-RestMethod -Method Put -Uri "$ApiBase/admin/leave-requests/$leaveRequestId" -Headers $adminHeaders -ContentType "application/json" -Body $updateLeaveBody
  Require-Properties $updatedLeaveRequest @("id", "userId", "fullName", "roleName", "startDate", "days", "reason", "status", "createdAt", "decidedAt", "decidedById") "Updated leave request"
  Assert-True ([int]$updatedLeaveRequest.days -eq 2) "Leave request update days mismatch"
  Assert-True ($updatedLeaveRequest.reason -eq "Harness leave update mapping test") "Leave request update reason mismatch"

  $decisionBody = @{ status = "APPROVED" } | ConvertTo-Json
  $decidedLeave = Invoke-RestMethod -Method Patch -Uri "$ApiBase/admin/leave-requests/$leaveRequestId/decision" -Headers $adminHeaders -ContentType "application/json" -Body $decisionBody
  Require-Properties $decidedLeave @("id", "userId", "fullName", "roleName", "startDate", "days", "reason", "status", "createdAt", "decidedAt", "decidedById") "Decided leave request"
  Assert-True ($decidedLeave.status -eq "APPROVED") "Leave decision status mismatch"
} finally {
  if ($leaveRequestId) {
    try {
      Invoke-RestMethod -Method Delete -Uri "$ApiBase/admin/leave-requests/$leaveRequestId" -Headers $adminHeaders | Out-Null
    } catch {
      Write-Warning "Could not delete temp leave request #${leaveRequestId}: $($_.Exception.Message)"
    }
  }
  if ($workShiftId) {
    try {
      Invoke-RestMethod -Method Delete -Uri "$ApiBase/admin/work-shifts/$workShiftId" -Headers $adminHeaders | Out-Null
    } catch {
      Write-Warning "Could not delete temp work shift #${workShiftId}: $($_.Exception.Message)"
    }
  }
}

Write-Host "PASS: Admin Catalog endpoints expose fields used by the mobile UI."

Write-Host "1c. Checking chat room and message endpoints..."
$chatCustomerName = "Harness Chat $(Get-Date -Format 'yyyyMMddHHmmss')"
$chatRoomBody = @{ customerName = $chatCustomerName } | ConvertTo-Json
$chatRoom = Invoke-RestMethod -Method Post -Uri "$ApiBase/chat/rooms" -ContentType "application/json" -Body $chatRoomBody
Require-Properties $chatRoom @("id", "customerName", "adminName", "lastMessageAt", "hasUnread", "type") "Created chat room"
Assert-True ($chatRoom.customerName -eq $chatCustomerName) "Chat room customerName mismatch"

$myRooms = Invoke-RestMethod -Method Get -Uri "$ApiBase/chat/rooms/me?customerName=$([uri]::EscapeDataString($chatCustomerName))"
$myRoom = @($myRooms) | Where-Object { "$($_.id)" -eq "$($chatRoom.id)" } | Select-Object -First 1
Assert-True ($null -ne $myRoom) "Created chat room was not found in GET /chat/rooms/me"

$customerMessageBody = @{
  content = "Harness customer support message"
  sender = "CUSTOMER"
} | ConvertTo-Json
$messagesAfterCustomer = Invoke-RestMethod -Method Post -Uri "$ApiBase/chat/rooms/$($chatRoom.id)/messages" -ContentType "application/json" -Body $customerMessageBody
Assert-True (@($messagesAfterCustomer).Count -gt 0) "Sending customer chat message returned no messages"
$customerMessage = @($messagesAfterCustomer) | Where-Object { $_.sender -eq "CUSTOMER" -and $_.content -eq "Harness customer support message" } | Select-Object -First 1
Assert-True ($null -ne $customerMessage) "Customer chat message was not found in response"
Require-Properties $customerMessage @("id", "content", "sender", "sentAt", "type", "fileUrl") "Customer chat message"

$adminMessageBody = @{
  content = "Harness admin support reply"
  sender = "ADMIN"
} | ConvertTo-Json
$messagesAfterAdmin = Invoke-RestMethod -Method Post -Uri "$ApiBase/chat/rooms/$($chatRoom.id)/messages" -ContentType "application/json" -Body $adminMessageBody
$adminMessage = @($messagesAfterAdmin) | Where-Object { $_.sender -eq "ADMIN" -and $_.content -eq "Harness admin support reply" } | Select-Object -First 1
Assert-True ($null -ne $adminMessage) "Admin chat message was not found in response"
Require-Properties $adminMessage @("id", "content", "sender", "sentAt", "type", "fileUrl") "Admin chat message"

$roomMessages = Invoke-RestMethod -Method Get -Uri "$ApiBase/chat/rooms/$($chatRoom.id)/messages"
Assert-True (@($roomMessages).Count -ge 2) "GET /chat/rooms/{id}/messages should return both seeded messages"

$adminRooms = Invoke-RestMethod -Method Get -Uri "$ApiBase/chat/rooms/admin/me" -Headers $adminHeaders
$adminRoom = @($adminRooms) | Where-Object { "$($_.id)" -eq "$($chatRoom.id)" } | Select-Object -First 1
Assert-True ($null -ne $adminRoom) "Created chat room was not found in admin room list"
Require-Properties $adminRoom @("id", "customerName", "adminName", "lastMessageAt", "hasUnread", "type") "Admin chat room"
Write-Host "PASS: Chat room and message fields map correctly."

Write-Host "2. Logging in test customer..."
$loginBody = @{
  email = $Email
  password = $Password
} | ConvertTo-Json

$login = Invoke-RestMethod -Method Post -Uri "$ApiBase/auth/login" -ContentType "application/json" -Body $loginBody
Require-Properties $login @("accessToken", "refreshToken", "role", "user") "Login response"
Assert-True ([string]::IsNullOrWhiteSpace($login.accessToken) -eq $false) "Login did not return accessToken"

$headers = @{ Authorization = "Bearer $($login.accessToken)" }

Write-Host "2b. Validating refresh and forgot-password auth endpoints..."
$refreshBody = @{ refreshToken = $login.refreshToken } | ConvertTo-Json
$refreshedSession = Invoke-RestMethod -Method Post -Uri "$ApiBase/auth/refresh" -ContentType "application/json" -Body $refreshBody
Require-Properties $refreshedSession @("accessToken", "refreshToken", "role", "user") "Refresh response"
Assert-True ([string]::IsNullOrWhiteSpace($refreshedSession.accessToken) -eq $false) "Refresh did not return accessToken"
Assert-True ($refreshedSession.role -eq $login.role) "Refresh role mismatch"

$forgotBody = @{ email = $Email } | ConvertTo-Json
$forgotResponse = Invoke-RestMethod -Method Post -Uri "$ApiBase/auth/forgot-password" -ContentType "application/json" -Body $forgotBody
Assert-True ([string]::IsNullOrWhiteSpace($forgotResponse) -eq $false) "Forgot password endpoint returned an empty response"

Write-Host "2c. Validating register, change-password, and logout with temp user rollback..."
$tempUserEmail = "harness.user.$(Get-Date -Format 'yyyyMMddHHmmss')@sport.vn"
$tempUserPassword = "Harness123"
$tempUserNewPassword = "Harness124"
$tempUserPhone = "09$((Get-Date -Format 'HHmmssff'))"
$tempUserId = $null
try {
  $registerBody = @{
    fullName = "Harness Temp User"
    email = $tempUserEmail
    phoneNumber = $tempUserPhone
    password = $tempUserPassword
    confirmPassword = $tempUserPassword
  } | ConvertTo-Json
  $registeredUser = Invoke-RestMethod -Method Post -Uri "$ApiBase/auth/register" -ContentType "application/json" -Body $registerBody
  Require-Properties $registeredUser @("id", "email", "fullName", "phoneNumber", "status", "role", "roleName", "roleDisplayName") "Registered user"
  $tempUserId = $registeredUser.id
  Assert-True ($registeredUser.email -eq $tempUserEmail) "Registered user email mismatch"

  $tempLoginBody = @{
    email = $tempUserEmail
    password = $tempUserPassword
  } | ConvertTo-Json
  $tempLogin = Invoke-RestMethod -Method Post -Uri "$ApiBase/auth/login" -ContentType "application/json" -Body $tempLoginBody
  Require-Properties $tempLogin @("accessToken", "refreshToken", "role", "user") "Temp login response"
  $tempHeaders = @{ Authorization = "Bearer $($tempLogin.accessToken)" }

  $changePasswordBody = @{
    oldPassword = $tempUserPassword
    newPassword = $tempUserNewPassword
    confirmPassword = $tempUserNewPassword
  } | ConvertTo-Json
  $changePasswordResponse = Invoke-RestMethod -Method Put -Uri "$ApiBase/auth/change-pass" -Headers $tempHeaders -ContentType "application/json" -Body $changePasswordBody
  Assert-True ([string]::IsNullOrWhiteSpace($changePasswordResponse) -eq $false) "Change password returned an empty response"

  $changedLoginBody = @{
    email = $tempUserEmail
    password = $tempUserNewPassword
  } | ConvertTo-Json
  $changedLogin = Invoke-RestMethod -Method Post -Uri "$ApiBase/auth/login" -ContentType "application/json" -Body $changedLoginBody
  Require-Properties $changedLogin @("accessToken", "refreshToken", "role", "user") "Changed-password login response"
  $changedHeaders = @{ Authorization = "Bearer $($changedLogin.accessToken)" }
  $logoutResponse = Invoke-RestMethod -Method Post -Uri "$ApiBase/auth/logout" -Headers $changedHeaders
  Assert-True ([string]::IsNullOrWhiteSpace($logoutResponse) -eq $false) "Logout returned an empty response"
} finally {
  if ($tempUserId) {
    try {
      Invoke-RestMethod -Method Delete -Uri "$ApiBase/admin/users/$tempUserId" -Headers $adminHeaders | Out-Null
    } catch {
      Write-Warning "Could not delete temp auth user #${tempUserId}: $($_.Exception.Message)"
    }
  }
}

Write-Host "3. Validating profile fields and update endpoint..."
$profile = Invoke-RestMethod -Method Get -Uri "$ApiBase/user/profile/me" -Headers $headers
Require-Properties $profile @("id", "fullName", "email", "phoneNumber", "role", "roleName", "roleDisplayName", "status") "Profile"
Assert-True ([string]::IsNullOrWhiteSpace($profile.email) -eq $false) "Profile email should not be empty"
$originalProfileName = $profile.fullName
$originalProfilePhone = $profile.phoneNumber

if (
  [string]::IsNullOrWhiteSpace($originalProfilePhone) -eq $false -and
  [string]::IsNullOrWhiteSpace($originalProfileName) -eq $false -and
  $originalProfileName -cmatch '^[\x00-\x7F]+$'
) {
  $temporaryProfileName = "$originalProfileName Harness"
  try {
    $profileUpdateBody = @{
      fullName = $temporaryProfileName
      phoneNumber = $originalProfilePhone
    } | ConvertTo-Json
    $updatedProfile = Invoke-RestMethod -Method Put -Uri "$ApiBase/user/profile/me" -Headers $headers -ContentType "application/json; charset=utf-8" -Body $profileUpdateBody
    Require-Properties $updatedProfile @("id", "fullName", "email", "phoneNumber", "role", "roleName", "roleDisplayName", "status") "Updated profile"
    Assert-True ($updatedProfile.fullName -eq $temporaryProfileName) "Profile fullName was not updated"
    Assert-True ($updatedProfile.phoneNumber -eq $originalProfilePhone) "Profile phoneNumber changed unexpectedly"
  } finally {
    try {
      $restoreProfileBody = @{
        fullName = $originalProfileName
        phoneNumber = $originalProfilePhone
      } | ConvertTo-Json
      Invoke-RestMethod -Method Put -Uri "$ApiBase/user/profile/me" -Headers $headers -ContentType "application/json; charset=utf-8" -Body $restoreProfileBody | Out-Null
    } catch {
      Write-Warning "Could not restore profile name after PUT test: $($_.Exception.Message)"
    }
  }
} else {
  Write-Host "   Skipped profile PUT rollback test because current profile data is not safe for an automatic restore."
}

Write-Host "4. Validating address CRUD endpoints with rollback..."
$addressListBefore = Invoke-RestMethod -Method Get -Uri "$ApiBase/user/addresses" -Headers $headers
$previousDefaultAddress = @($addressListBefore) | Where-Object { $_.isDefault -eq $true } | Select-Object -First 1
$tempAddressId = $null
try {
  $createAddressBody = @{
    recipientName = "Harness Address"
    phoneNumber = "0900000000"
    city = "Ho Chi Minh"
    district = "District 1"
    ward = "Ben Nghe"
    street = "1 Harness Street"
    isDefault = $false
  } | ConvertTo-Json
  $tempAddress = Invoke-RestMethod -Method Post -Uri "$ApiBase/user/addresses" -Headers $headers -ContentType "application/json" -Body $createAddressBody
  $tempAddressId = $tempAddress.id
  Require-Properties $tempAddress @("id", "recipientName", "phoneNumber", "city", "district", "ward", "street", "isDefault", "fullAddress") "Created address"
  Assert-True ($tempAddress.recipientName -eq "Harness Address") "Address recipientName mismatch after create"
  Assert-True ($tempAddress.fullAddress -like "*Harness Street*") "Address fullAddress should include street"

  $updateAddressBody = @{
    recipientName = "Harness Address Updated"
    phoneNumber = "0900000000"
    city = "Ho Chi Minh"
    district = "District 3"
    ward = "Ward 7"
    street = "2 Harness Street"
    isDefault = $false
  } | ConvertTo-Json
  $updatedAddress = Invoke-RestMethod -Method Put -Uri "$ApiBase/user/addresses/$tempAddressId" -Headers $headers -ContentType "application/json" -Body $updateAddressBody
  Require-Properties $updatedAddress @("id", "recipientName", "phoneNumber", "city", "district", "ward", "street", "isDefault", "fullAddress") "Updated address"
  Assert-True ($updatedAddress.recipientName -eq "Harness Address Updated") "Address recipientName mismatch after update"
  Assert-True ($updatedAddress.district -eq "District 3") "Address district mismatch after update"

  Invoke-RestMethod -Method Patch -Uri "$ApiBase/user/addresses/$tempAddressId/default" -Headers $headers | Out-Null
  $addressListAfterDefault = Invoke-RestMethod -Method Get -Uri "$ApiBase/user/addresses" -Headers $headers
  $defaultAddress = @($addressListAfterDefault) | Where-Object { $_.isDefault -eq $true } | Select-Object -First 1
  Assert-True ("$($defaultAddress.id)" -eq "$tempAddressId") "Set default address endpoint did not mark the temp address as default"
} finally {
  if ($previousDefaultAddress -and "$($previousDefaultAddress.id)" -ne "$tempAddressId") {
    try {
      Invoke-RestMethod -Method Patch -Uri "$ApiBase/user/addresses/$($previousDefaultAddress.id)/default" -Headers $headers | Out-Null
    } catch {
      Write-Warning "Could not restore previous default address #$($previousDefaultAddress.id): $($_.Exception.Message)"
    }
  }
  if ($tempAddressId) {
    try {
      Invoke-RestMethod -Method Delete -Uri "$ApiBase/user/addresses/$tempAddressId" -Headers $headers | Out-Null
    } catch {
      Write-Warning "Could not delete temp address #${tempAddressId}: $($_.Exception.Message)"
    }
  }
}

Write-Host "PASS: Profile and Address fields map correctly with rollback completed."

Write-Host "5. Reading cart before mutation..."
$beforeCart = Invoke-RestMethod -Method Get -Uri "$ApiBase/cart" -Headers $headers
Require-Properties $beforeCart @("id", "totalPrice", "totalItems", "items") "Cart response"

$beforeItem = @($beforeCart.items) | Where-Object { "$($_.variantId)" -eq "$($variant.id)" } | Select-Object -First 1
$beforeQuantity = if ($beforeItem) { [int]$beforeItem.quantity } else { 0 }
$originalStock = [int]$variant.stockQuantity
$temporaryStockApplied = $false

if ($originalStock -le $beforeQuantity) {
  Write-Host "   Variant stock is $originalStock and cart already has $beforeQuantity; raising stock temporarily..."
  $targetStock = $beforeQuantity + 1
  Invoke-RestMethod -Method Patch -Uri "$ApiBase/admin/products/variants/$($variant.id)/stock?quantity=$targetStock" -Headers $adminHeaders | Out-Null
  $temporaryStockApplied = $true
}

try {
  Write-Host "6. Adding selected variant to cart..."
  $addBody = @{
    variantId = [int64]$variant.id
    quantity = 1
  } | ConvertTo-Json

  $afterAdd = Invoke-RestMethod -Method Post -Uri "$ApiBase/cart/add" -Headers $headers -ContentType "application/json" -Body $addBody
  Require-Properties $afterAdd @("id", "totalPrice", "totalItems", "items") "Cart after add"

  $addedItem = @($afterAdd.items) | Where-Object { "$($_.variantId)" -eq "$($variant.id)" } | Select-Object -First 1
  Assert-True ($null -ne $addedItem) "Added variant was not found in cart response"
  Require-Properties $addedItem @("id", "variantId", "productName", "size", "color", "price", "quantity", "subTotal", "imageUrl", "maxStock") "Cart item"

  Assert-True ($addedItem.productName -eq $detail.productName) "Cart item productName does not match product detail"
  Assert-True ($addedItem.size -eq $variant.size) "Cart item size does not match variant"
  Assert-True ($addedItem.color -eq $variant.color) "Cart item color does not match variant"
  Assert-True ([int]$addedItem.price -eq [int]$variant.price) "Cart item price does not match variant"
  Assert-True ([int]$addedItem.maxStock -ge ($beforeQuantity + 1)) "Cart item maxStock is less than expected safe stock"
  Assert-True ([int]$addedItem.quantity -eq ($beforeQuantity + 1)) "Cart item quantity did not increase by one"
  Assert-True ([int]$addedItem.subTotal -eq ([int]$addedItem.price * [int]$addedItem.quantity)) "Cart item subTotal is not price * quantity"

  Write-Host "7. Rolling cart back to previous state..."
  if ($beforeQuantity -eq 0) {
    Invoke-RestMethod -Method Delete -Uri "$ApiBase/cart/items/$($addedItem.id)" -Headers $headers | Out-Null
  } else {
    Invoke-RestMethod -Method Put -Uri "$ApiBase/cart/items/$($addedItem.id)?quantity=$beforeQuantity" -Headers $headers | Out-Null
  }

  $rollbackCart = Invoke-RestMethod -Method Get -Uri "$ApiBase/cart" -Headers $headers
  $rollbackItem = @($rollbackCart.items) | Where-Object { "$($_.variantId)" -eq "$($variant.id)" } | Select-Object -First 1
  if ($beforeQuantity -eq 0) {
    Assert-True ($null -eq $rollbackItem) "Rollback failed: newly added item still exists"
  } else {
    Assert-True ([int]$rollbackItem.quantity -eq $beforeQuantity) "Rollback failed: item quantity was not restored"
  }
} finally {
  if ($temporaryStockApplied) {
    Write-Host "8. Restoring variant stock to $originalStock..."
    Invoke-RestMethod -Method Patch -Uri "$ApiBase/admin/products/variants/$($variant.id)/stock?quantity=$originalStock" -Headers $adminHeaders | Out-Null
  }
}

Write-Host ""
Write-Host "PASS: Backend fields map correctly for Product Detail -> Cart flow."

Write-Host ""
Write-Host "9. Running Checkout API mapping test with rollback..."

$createdAddressId = $null
$createdOrderId = $null
$createdAssignmentId = $null
$createdDeliveryReportId = $null
$checkoutOriginalStock = $originalStock
$checkoutAdminHeaders = $adminHeaders

try {
  $addresses = Invoke-RestMethod -Method Get -Uri "$ApiBase/user/addresses" -Headers $headers
  $address = @($addresses) | Select-Object -First 1

  if ($null -eq $address) {
    $addressBody = @{
      recipientName = "Harness Tester"
      phoneNumber = "0900000000"
      city = "Ho Chi Minh"
      district = "District 1"
      ward = "Ben Nghe"
      street = "1 Test Street"
      isDefault = $true
    } | ConvertTo-Json
    $address = Invoke-RestMethod -Method Post -Uri "$ApiBase/user/addresses" -Headers $headers -ContentType "application/json" -Body $addressBody
    $createdAddressId = $address.id
  }
  Require-Properties $address @("id", "recipientName", "phoneNumber", "city", "district", "ward", "street", "isDefault") "Address"

  Invoke-RestMethod -Method Patch -Uri "$ApiBase/admin/products/variants/$($variant.id)/stock?quantity=1" -Headers $checkoutAdminHeaders | Out-Null

  $cartBeforeCheckout = Invoke-RestMethod -Method Get -Uri "$ApiBase/cart" -Headers $headers
  foreach ($existing in @($cartBeforeCheckout.items)) {
    Invoke-RestMethod -Method Delete -Uri "$ApiBase/cart/items/$($existing.id)" -Headers $headers | Out-Null
  }

  $checkoutAddBody = @{
    variantId = [int64]$variant.id
    quantity = 1
  } | ConvertTo-Json
  $cartForCheckout = Invoke-RestMethod -Method Post -Uri "$ApiBase/cart/add" -Headers $headers -ContentType "application/json" -Body $checkoutAddBody
  Assert-True (@($cartForCheckout.items).Count -eq 1) "Checkout setup cart should contain exactly one item"

  $checkoutNote = "Harness checkout mapping test"
  $checkoutBody = @{
    addressId = [int64]$address.id
    paymentMethod = "COD"
    note = $checkoutNote
  } | ConvertTo-Json

  $order = Invoke-RestMethod -Method Post -Uri "$ApiBase/orders/checkout" -Headers $headers -ContentType "application/json" -Body $checkoutBody
  $createdOrderId = $order.id
  Require-Properties $order @("id", "orderDate", "status", "deliveryStatus", "totalAmount", "paymentMethod", "recipientName", "phoneNumber", "shippingAddress", "note", "items") "Order"
  Assert-True ($order.status -eq "PENDING") "Checkout order status should be PENDING"
  Assert-True ($order.deliveryStatus -eq "WAITING_PICKUP") "PENDING order deliveryStatus should be WAITING_PICKUP"
  Assert-True ($order.paymentMethod -eq "COD") "Checkout order paymentMethod should be COD"
  Assert-True ($order.recipientName -eq $address.recipientName) "Order recipientName should snapshot selected address"
  Assert-True ($order.phoneNumber -eq $address.phoneNumber) "Order phoneNumber should snapshot selected address"
  Assert-True ($order.note -eq $checkoutNote) "Order note should match checkout request"
  Assert-True (@($order.items).Count -eq 1) "Order should contain exactly one item"

  $orderItem = @($order.items)[0]
  Require-Properties $orderItem @("id", "variantId", "productName", "size", "color", "price", "quantity", "subTotal", "variantImage") "Order item"
  Assert-True ("$($orderItem.variantId)" -eq "$($variant.id)") "Order item variantId mismatch"
  Assert-True ($orderItem.productName -eq $detail.productName) "Order item productName mismatch"
  Assert-True ([int]$orderItem.subTotal -eq ([int]$orderItem.price * [int]$orderItem.quantity)) "Order item subTotal mismatch"
  Assert-True ([int]$order.totalAmount -eq [int]$orderItem.subTotal) "Order totalAmount should match UI checkout total"

  Write-Host "10. Validating payment URL response..."
  $payment = Invoke-RestMethod -Method Get -Uri "$ApiBase/payment/create_payment/$createdOrderId" -Headers $headers
  Require-Properties $payment @("status", "message", "paymentUrl") "Payment response"
  Assert-True ($payment.status -eq "OK") "Payment response status should be OK"
  Assert-True ([string]::IsNullOrWhiteSpace($payment.paymentUrl) -eq $false) "Payment response paymentUrl should not be empty"

  $cartAfterCheckout = Invoke-RestMethod -Method Get -Uri "$ApiBase/cart" -Headers $headers
  Assert-True (@($cartAfterCheckout.items).Count -eq 0) "Cart should be empty after checkout"

  Write-Host "11. Validating my orders list and detail endpoints..."
  $myOrders = Invoke-RestMethod -Method Get -Uri "$ApiBase/orders" -Headers $headers
  Assert-True (@($myOrders).Count -gt 0) "GET /orders returned no orders after checkout"
  $listedOrder = @($myOrders) | Where-Object { "$($_.id)" -eq "$createdOrderId" } | Select-Object -First 1
  Assert-True ($null -ne $listedOrder) "Created order was not found in GET /orders"
  Require-Properties $listedOrder @("id", "orderDate", "status", "deliveryStatus", "totalAmount", "paymentMethod", "recipientName", "phoneNumber", "shippingAddress", "note", "items") "Listed order"

  $orderDetail = Invoke-RestMethod -Method Get -Uri "$ApiBase/orders/$createdOrderId" -Headers $headers
  Require-Properties $orderDetail @("id", "orderDate", "status", "deliveryStatus", "totalAmount", "paymentMethod", "recipientName", "phoneNumber", "shippingAddress", "note", "items") "Order detail"
  Assert-True ("$($orderDetail.id)" -eq "$createdOrderId") "GET /orders/{id} returned the wrong order"
  Assert-True ($orderDetail.status -eq $order.status) "Order detail status mismatch"
  Assert-True ($orderDetail.deliveryStatus -eq $order.deliveryStatus) "Order detail deliveryStatus mismatch"
  Assert-True ([int]$orderDetail.totalAmount -eq [int]$order.totalAmount) "Order detail totalAmount mismatch"
  Assert-True (@($orderDetail.items).Count -eq 1) "Order detail should contain one item"
  $detailItem = @($orderDetail.items)[0]
  Require-Properties $detailItem @("id", "variantId", "productName", "size", "color", "price", "quantity", "subTotal", "variantImage") "Order detail item"
  Assert-True ("$($detailItem.variantId)" -eq "$($variant.id)") "Order detail item variantId mismatch"

  Write-Host "12. Validating delivery assignment and report CRUD with rollback..."
  $assignmentBody = @{
    orderId = [int64]$createdOrderId
    staffId = [int64]$shipperUser.id
    note = "Harness delivery assignment mapping test"
  } | ConvertTo-Json
  $createdAssignment = Invoke-RestMethod -Method Post -Uri "$ApiBase/admin/order-assignments" -Headers $checkoutAdminHeaders -ContentType "application/json" -Body $assignmentBody
  $createdAssignmentId = $createdAssignment.id
  Require-Properties $createdAssignment @("id", "orderId", "staffId", "staffName", "staffRole", "assignedById", "assignedAt", "note") "Created order assignment"
  Assert-True ("$($createdAssignment.orderId)" -eq "$createdOrderId") "Created assignment orderId mismatch"
  Assert-True ("$($createdAssignment.staffId)" -eq "$($shipperUser.id)") "Created assignment staffId mismatch"

  $updateAssignmentBody = @{
    orderId = [int64]$createdOrderId
    staffId = [int64]$shipperUser.id
    note = "Harness delivery assignment update mapping test"
  } | ConvertTo-Json
  $updatedAssignment = Invoke-RestMethod -Method Put -Uri "$ApiBase/admin/order-assignments/$createdAssignmentId" -Headers $checkoutAdminHeaders -ContentType "application/json" -Body $updateAssignmentBody
  Require-Properties $updatedAssignment @("id", "orderId", "staffId", "staffName", "staffRole", "assignedById", "assignedAt", "note") "Updated order assignment"
  Assert-True ($updatedAssignment.note -eq "Harness delivery assignment update mapping test") "Updated assignment note mismatch"

  $assignmentByOrder = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/order-assignments/orders/$createdOrderId" -Headers $checkoutAdminHeaders
  Require-Properties $assignmentByOrder @("id", "orderId", "staffId", "staffName", "staffRole", "assignedById", "assignedAt", "note") "Assignment by order"
  Assert-True ("$($assignmentByOrder.id)" -eq "$createdAssignmentId") "Assignment by order returned wrong assignment"

  $reportBody = @{
    status = "FAILED"
    reason = "Harness delivery report mapping test"
    note = "Created by mobile backend mapping harness"
    evidenceImageUrl = ""
  } | ConvertTo-Json
  $createdReport = Invoke-RestMethod -Method Post -Uri "$ApiBase/orders/$createdOrderId/delivery-reports" -Headers $checkoutAdminHeaders -ContentType "application/json" -Body $reportBody
  $createdDeliveryReportId = $createdReport.id
  Require-Properties $createdReport @("id", "orderId", "reportedById", "reportedByName", "status", "reason", "note", "evidenceImageUrl", "createdAt") "Created delivery report"
  Assert-True ($createdReport.status -eq "FAILED") "Created delivery report status mismatch"

  $allDeliveryReports = Invoke-RestMethod -Method Get -Uri "$ApiBase/admin/delivery-reports" -Headers $checkoutAdminHeaders
  $listedDeliveryReport = @($allDeliveryReports) | Where-Object { "$($_.id)" -eq "$createdDeliveryReportId" } | Select-Object -First 1
  Assert-True ($null -ne $listedDeliveryReport) "Created delivery report was not found in admin report list"

  $orderDeliveryReports = Invoke-RestMethod -Method Get -Uri "$ApiBase/orders/$createdOrderId/delivery-reports" -Headers $checkoutAdminHeaders
  $orderDeliveryReport = @($orderDeliveryReports) | Where-Object { "$($_.id)" -eq "$createdDeliveryReportId" } | Select-Object -First 1
  Assert-True ($null -ne $orderDeliveryReport) "Created delivery report was not found in order report list"

  $updateReportBody = @{
    status = "RETURNED"
    reason = "Harness delivery report update mapping test"
    note = "Updated by mobile backend mapping harness"
    evidenceImageUrl = ""
  } | ConvertTo-Json
  $updatedReport = Invoke-RestMethod -Method Put -Uri "$ApiBase/admin/delivery-reports/$createdDeliveryReportId" -Headers $checkoutAdminHeaders -ContentType "application/json" -Body $updateReportBody
  Require-Properties $updatedReport @("id", "orderId", "reportedById", "reportedByName", "status", "reason", "note", "evidenceImageUrl", "createdAt") "Updated delivery report"
  Assert-True ($updatedReport.status -eq "RETURNED") "Updated delivery report status mismatch"
  Assert-True ($updatedReport.reason -eq "Harness delivery report update mapping test") "Updated delivery report reason mismatch"

  Invoke-RestMethod -Method Delete -Uri "$ApiBase/admin/delivery-reports/$createdDeliveryReportId" -Headers $checkoutAdminHeaders | Out-Null
  $createdDeliveryReportId = $null

  Invoke-RestMethod -Method Delete -Uri "$ApiBase/admin/order-assignments/$createdAssignmentId" -Headers $checkoutAdminHeaders | Out-Null
  $createdAssignmentId = $null

  Write-Host "   Checkout order #$createdOrderId validated."
} finally {
  if ($createdDeliveryReportId) {
    try {
      Invoke-RestMethod -Method Delete -Uri "$ApiBase/admin/delivery-reports/$createdDeliveryReportId" -Headers $checkoutAdminHeaders | Out-Null
    } catch {
      Write-Warning "Could not delete test delivery report #${createdDeliveryReportId}: $($_.Exception.Message)"
    }
  }
  if ($createdAssignmentId) {
    try {
      Invoke-RestMethod -Method Delete -Uri "$ApiBase/admin/order-assignments/$createdAssignmentId" -Headers $checkoutAdminHeaders | Out-Null
    } catch {
      Write-Warning "Could not delete test assignment #${createdAssignmentId}: $($_.Exception.Message)"
    }
  }
  if ($createdOrderId) {
    try {
      Invoke-RestMethod -Method Delete -Uri "$ApiBase/orders/admin/$createdOrderId" -Headers $checkoutAdminHeaders | Out-Null
    } catch {
      Write-Warning "Could not delete test order #${createdOrderId}: $($_.Exception.Message)"
    }
  }
  if ($createdAddressId) {
    try {
      Invoke-RestMethod -Method Delete -Uri "$ApiBase/user/addresses/$createdAddressId" -Headers $headers | Out-Null
    } catch {
      Write-Warning "Could not delete test address #${createdAddressId}: $($_.Exception.Message)"
    }
  }
  Invoke-RestMethod -Method Patch -Uri "$ApiBase/admin/products/variants/$($variant.id)/stock?quantity=$checkoutOriginalStock" -Headers $checkoutAdminHeaders | Out-Null
}

Write-Host ""
Write-Host "PASS: Checkout request/response fields map correctly and rollback completed."
