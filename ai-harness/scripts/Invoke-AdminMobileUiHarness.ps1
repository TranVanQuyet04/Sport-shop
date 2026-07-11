param(
    [int]$MaxAttempts = 1,
    [switch]$ApplySafeFixes,
    [switch]$StrictButtonAudit,
    [switch]$RunMobileChecks
)

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$MobileRoot = Join-Path $Root "mobile"
$AdminViewRoot = Join-Path $MobileRoot "lib\view\admin"
$RouterFile = Join-Path $MobileRoot "lib\app\sportshop_router.dart"
$MapFile = Join-Path $Root "ai-harness\config\mobile-admin-screen-map.json"
$BackendFeatureMapFile = Join-Path $Root "ai-harness\config\backend-feature-map.json"
$CollectionsChatBrdFile = Join-Path $Root "ai-harness\docs\brd-admin-collections-and-chat.md"
$MobileAdminLuxuryBrdFile = Join-Path $Root "ai-harness\docs\brd-mobile-admin-ui-luxury.md"
$StateRoot = Join-Path $Root "ai-harness\state"
$JsonReport = Join-Path $StateRoot "admin-mobile-ui-audit-latest.json"
$MdReport = Join-Path $StateRoot "admin-mobile-ui-audit-latest.md"
$ButtonJsonReport = Join-Path $StateRoot "admin-mobile-button-inventory-latest.json"
$ButtonMdReport = Join-Path $StateRoot "admin-mobile-button-inventory-latest.md"
$LuxuryJsonReport = Join-Path $StateRoot "admin-mobile-luxury-review-latest.json"
$LuxuryMdReport = Join-Path $StateRoot "admin-mobile-luxury-review-latest.md"

if (!(Test-Path $StateRoot)) {
    New-Item -ItemType Directory -Path $StateRoot | Out-Null
}

function Add-Finding {
    param(
        [System.Collections.Generic.List[object]]$Findings,
        [string]$Severity,
        [string]$Code,
        [string]$File,
        [string]$Message,
        [string]$Suggestion
    )

    $Findings.Add([ordered]@{
        severity = $Severity
        code = $Code
        file = $File
        message = $Message
        suggestion = $Suggestion
    }) | Out-Null
}

function Test-ContainsAny {
    param(
        [string]$Content,
        [string[]]$Tokens
    )

    foreach ($token in $Tokens) {
        if ($Content.Contains($token)) {
            return $true
        }
    }
    return $false
}

function Test-HasMojibake {
    param([string]$Content)

    $patterns = @(
        "[\u00C3\u00C2\u00C4\u00C6][\u0080-\u00BF]",
        "\u00E1\u00BA",
        "\u00E1\u00BB",
        "[\u0102\u015F\u0141\u0106\u017B\u2021\u2122\u02DD]"
    )

    foreach ($pattern in $patterns) {
        if ([regex]::IsMatch($Content, $pattern)) {
            return $true
        }
    }
    return $false
}

function Set-FileContentIfChanged {
    param(
        [string]$Path,
        [string]$Content
    )

    $current = Get-Content $Path -Raw -Encoding UTF8
    if ($current -ne $Content) {
        Set-Content -Encoding UTF8 $Path $Content
        return $true
    }
    return $false
}

function Get-LineNumberFromIndex {
    param(
        [string]$Content,
        [int]$Index
    )

    if ($Index -le 0) {
        return 1
    }
    return ([regex]::Matches($Content.Substring(0, $Index), "`n")).Count + 1
}

function Get-FirstRegexGroup {
    param(
        [string]$Content,
        [string]$Pattern
    )

    $match = [regex]::Match($Content, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($match.Success -and $match.Groups.Count -gt 1) {
        return $match.Groups[1].Value.Trim()
    }
    return ""
}

function Get-AdminButtonInventory {
    param(
        [System.Collections.Generic.List[object]]$Findings
    )

    $controls = New-Object "System.Collections.Generic.List[object]"
    $reviews = New-Object "System.Collections.Generic.List[object]"
    $widgetPattern = "(IconButton|TextButton|ElevatedButton|FilledButton|OutlinedButton|FloatingActionButton(?:\.extended)?|InkWell|GestureDetector|ListTile|Switch(?:\.adaptive)?|SwitchListTile|PopupMenuButton|ChoiceChip|AdminEntityMenu|AdminBottomNav|_SettingTile)\s*\("
    $handlerPattern = "(onPressed|onTap|onChanged|onSelected|onAction|onEdit|onDelete|onVariants|onRefresh)\s*:"

    $adminFiles = Get-ChildItem -Path $AdminViewRoot -Filter "*.dart" -File | Sort-Object Name
    foreach ($file in $adminFiles) {
        $relativeFile = $file.FullName.Replace("$Root\", "").Replace("\", "/")
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $matches = [regex]::Matches($content, $widgetPattern)

        foreach ($match in $matches) {
            $start = $match.Index
            $length = [Math]::Min(900, $content.Length - $start)
            $snippet = $content.Substring($start, $length)
            $type = $match.Groups[1].Value
            $line = Get-LineNumberFromIndex $content $start
            $label = Get-FirstRegexGroup $snippet "Text\s*\(\s*'([^']+)'"
            $tooltip = Get-FirstRegexGroup $snippet "tooltip\s*:\s*'([^']+)'"
            $hasTooltip = [regex]::IsMatch($snippet, "tooltip\s*:")
            $route = Get-FirstRegexGroup $snippet "context\.(?:go|push)\s*\(\s*([^,\)]+)"
            $hasHandler = [regex]::IsMatch($snippet, $handlerPattern)
            $hasMojibake = Test-HasMojibake $snippet
            $usesHardcodedAdminRoute = [regex]::IsMatch($snippet, "context\.(?:go|push)\s*\(\s*'/admin")

            $controls.Add([ordered]@{
                file = $relativeFile
                line = $line
                type = $type
                label = $label
                tooltip = $tooltip
                route = $route
                hasHandler = $hasHandler
                hasMojibake = $hasMojibake
                usesHardcodedAdminRoute = $usesHardcodedAdminRoute
            }) | Out-Null

            if ($hasMojibake) {
                Add-Finding $Findings "error" "BUTTON_TEXT_MOJIBAKE" "${relativeFile}:$line" "Interactive control contains mojibake/encoding-broken text." "Repair the visible Vietnamese label/tooltip for this control."
            }

            if (($type -notin @("AdminBottomNav")) -and !$hasHandler) {
                $reviews.Add([ordered]@{
                    severity = "review"
                    code = "BUTTON_HANDLER_REVIEW"
                    file = "${relativeFile}:$line"
                    message = "$type has no obvious interaction handler in the scanned block."
                    suggestion = "Confirm it is intentionally passive/disabled; otherwise wire the existing callback without changing business logic."
                }) | Out-Null
                if ($StrictButtonAudit) {
                    Add-Finding $Findings "warning" "BUTTON_HANDLER_REVIEW" "${relativeFile}:$line" "$type has no obvious interaction handler." "Confirm or wire the existing callback."
                }
            }

            if ($type -eq "IconButton" -and !$hasTooltip) {
                $reviews.Add([ordered]@{
                    severity = "review"
                    code = "ICON_BUTTON_TOOLTIP_REVIEW"
                    file = "${relativeFile}:$line"
                    message = "IconButton has no tooltip in the scanned block."
                    suggestion = "Add a concise tooltip so Admin users understand the action."
                }) | Out-Null
                if ($StrictButtonAudit) {
                    Add-Finding $Findings "warning" "ICON_BUTTON_TOOLTIP_REVIEW" "${relativeFile}:$line" "IconButton has no tooltip." "Add a concise tooltip."
                }
            }

            if ($type -like "FloatingActionButton*" -and $type -ne "FloatingActionButton.extended" -and !$hasTooltip) {
                $reviews.Add([ordered]@{
                    severity = "review"
                    code = "FAB_TOOLTIP_REVIEW"
                    file = "${relativeFile}:$line"
                    message = "Icon-only FloatingActionButton has no obvious tooltip."
                    suggestion = "Add tooltip or use an extended FAB when the action is not obvious."
                }) | Out-Null
            }

            if ($usesHardcodedAdminRoute) {
                $reviews.Add([ordered]@{
                    severity = "review"
                    code = "HARDCODED_ADMIN_ROUTE_REVIEW"
                    file = "${relativeFile}:$line"
                    message = "Control uses a hardcoded /admin route."
                    suggestion = "Prefer AppRoutes when possible; keep dynamic path parameters if that is the existing project pattern."
                }) | Out-Null
            }
        }
    }

    $buttonSummary = [ordered]@{
        generatedAt = (Get-Date).ToString("s")
        area = "mobile-admin"
        totalControls = $controls.Count
        reviewCount = $reviews.Count
        controls = $controls
        reviews = $reviews
    }

    $buttonSummary | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 $ButtonJsonReport

    $buttonLines = New-Object "System.Collections.Generic.List[string]"
    $buttonLines.Add("# Admin Mobile Button Inventory") | Out-Null
    $buttonLines.Add("") | Out-Null
    $buttonLines.Add("- Generated: $($buttonSummary.generatedAt)") | Out-Null
    $buttonLines.Add("- Total interactive controls: $($controls.Count)") | Out-Null
    $buttonLines.Add("- Review notes: $($reviews.Count)") | Out-Null
    $buttonLines.Add("") | Out-Null

    $groupedControls = $controls | Group-Object { $_["file"] }
    foreach ($group in $groupedControls) {
        $buttonLines.Add("## $($group.Name)") | Out-Null
        $buttonLines.Add("") | Out-Null
        foreach ($control in ($group.Group | Sort-Object { $_["line"] })) {
            $name = if ([string]::IsNullOrWhiteSpace($control["label"])) { $control["tooltip"] } else { $control["label"] }
            if ([string]::IsNullOrWhiteSpace($name)) { $name = "(icon/custom)" }
            $routeText = if ([string]::IsNullOrWhiteSpace($control["route"])) { "" } else { " route=$($control["route"])" }
            $controlLine = $control["line"]
            $controlType = $control["type"]
            $buttonLines.Add("- line ${controlLine}: ``${controlType}`` - $name$routeText") | Out-Null
        }
        $buttonLines.Add("") | Out-Null
    }

    if ($reviews.Count -gt 0) {
        $buttonLines.Add("## Review Notes") | Out-Null
        $buttonLines.Add("") | Out-Null
        foreach ($review in $reviews) {
            $reviewCode = $review["code"]
            $reviewFile = $review["file"]
            $reviewMessage = $review["message"]
            $reviewSuggestion = $review["suggestion"]
            $buttonLines.Add("- [$reviewCode] ``$reviewFile``: $reviewMessage $reviewSuggestion") | Out-Null
        }
    }

    $buttonLines | Set-Content -Encoding UTF8 $ButtonMdReport
    return $buttonSummary
}

function Get-AdminLuxuryReview {
    param(
        [object]$Map
    )

    $notes = New-Object "System.Collections.Generic.List[object]"
    $screenReviews = New-Object "System.Collections.Generic.List[object]"
    $adminFiles = Get-ChildItem -Path $AdminViewRoot -Filter "*.dart" -File | Sort-Object Name

    foreach ($file in $adminFiles) {
        $relativeFile = $file.FullName.Replace("$Root\", "").Replace("\", "/")
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $isMapped = $false
        $mappedEntry = $null
        $mvpCheckText = ""
        foreach ($entry in $Map.entryPoints) {
            if ($entry.file -eq $relativeFile) {
                $isMapped = $true
                $mappedEntry = $entry
                $mvpCheckText = ($entry.mvpChecks -join ",")
                break
            }
        }

        $usesAdminDesignSystem = Test-ContainsAny $content @("AdminSurface", "AdminOutlinedSurface", "AdminPageHeader", "AdminIconBadge", "AdminThemeScope", "AdminColors", "AdminDesign")
        $hasPremiumState = Test-ContainsAny $content @("PremiumEmptyState", "AppErrorState", "AdminInlineBanner", "LinearProgressIndicator", "isLoading", "errorMessage")
        $hasBottomNav = Test-ContainsAny $content @("AdminBottomNav(")
        $hasBottomSafePadding = Test-ContainsAny $content @("108", "104", "100", "96", "88", "bottom:")
        $usesPremiumInputs = Test-ContainsAny $content @("OutlineInputBorder", "focusedBorder", "Color(0xFF2563EB)", "prefixIcon")
        $usesPremiumShadows = Test-ContainsAny $content @("boxShadow", "cardShadow", "blurRadius", "AdminDesign.cardShadow")
        $usesRiskyColors = Test-ContainsAny $content @("Colors.orange", "Colors.deepOrange", "Colors.purple", "Colors.brown")
        $hasHardcodedAdminRoute = [regex]::IsMatch($content, "context\.(go|push)\('/admin")
        $hasMojibake = Test-HasMojibake $content

        $score = 0
        if ($usesAdminDesignSystem) { $score += 25 }
        if ($hasPremiumState -or (Test-ContainsAny $mvpCheckText @("settings-menu"))) { $score += 20 }
        if (!$hasBottomNav -or $hasBottomSafePadding) { $score += 15 }
        if ($usesPremiumInputs -or !(Test-ContainsAny $content @("TextField", "TextFormField", "DropdownButtonFormField"))) { $score += 15 }
        if ($usesPremiumShadows) { $score += 15 }
        if (!$usesRiskyColors) { $score += 5 }
        if (!$hasHardcodedAdminRoute) { $score += 5 }

        $screenNotes = New-Object "System.Collections.Generic.List[string]"
        if (!$isMapped) {
            $screenNotes.Add("Admin view is not listed in mobile-admin-screen-map.json.") | Out-Null
        }
        if (!$usesAdminDesignSystem) {
            $screenNotes.Add("Consider aligning with Admin design-system widgets such as AdminSurface/AdminPageHeader/AdminIconBadge.") | Out-Null
        }
        if (!$hasPremiumState -and !(Test-ContainsAny $mvpCheckText @("settings-menu"))) {
            $screenNotes.Add("No obvious loading/error/empty state token was found; verify MVP states.") | Out-Null
        }
        if ($hasBottomNav -and !$hasBottomSafePadding) {
            $screenNotes.Add("Bottom navigation exists without obvious safe bottom padding.") | Out-Null
        }
        if ($usesRiskyColors) {
            $screenNotes.Add("Risky non-brand colors detected; review against StrideX premium palette.") | Out-Null
        }
        if ($hasHardcodedAdminRoute) {
            $screenNotes.Add("Hardcoded /admin route detected; prefer AppRoutes where possible.") | Out-Null
        }
        if ($hasMojibake) {
            $screenNotes.Add("Mojibake/encoding-broken text detected.") | Out-Null
        }

        $screenReviews.Add([ordered]@{
            file = $relativeFile
            mapped = $isMapped
            route = if ($mappedEntry -ne $null) { $mappedEntry.path } else { "" }
            backendModule = if ($mappedEntry -ne $null) { $mappedEntry.backendModule } else { "" }
            luxuryScore = [Math]::Min(100, $score)
            usesAdminDesignSystem = $usesAdminDesignSystem
            hasPremiumState = $hasPremiumState
            hasBottomNav = $hasBottomNav
            hasBottomSafePadding = $hasBottomSafePadding
            usesPremiumInputs = $usesPremiumInputs
            usesPremiumShadows = $usesPremiumShadows
            usesRiskyColors = $usesRiskyColors
            hasHardcodedAdminRoute = $hasHardcodedAdminRoute
            hasMojibake = $hasMojibake
            notes = $screenNotes
        }) | Out-Null

        foreach ($note in $screenNotes) {
            $notes.Add([ordered]@{
                file = $relativeFile
                note = $note
            }) | Out-Null
        }
    }

    $summary = [ordered]@{
        generatedAt = (Get-Date).ToString("s")
        area = "mobile-admin"
        brd = "ai-harness/docs/brd-mobile-admin-ui-luxury.md"
        totalScreens = $screenReviews.Count
        reviewNotes = $notes.Count
        screens = $screenReviews
    }

    $summary | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 $LuxuryJsonReport

    $luxuryLines = New-Object "System.Collections.Generic.List[string]"
    $luxuryLines.Add("# Admin Mobile Luxury UI Review") | Out-Null
    $luxuryLines.Add("") | Out-Null
    $luxuryLines.Add("- Generated: $($summary.generatedAt)") | Out-Null
    $luxuryLines.Add("- BRD: ai-harness/docs/brd-mobile-admin-ui-luxury.md") | Out-Null
    $luxuryLines.Add("- Screens reviewed: $($summary.totalScreens)") | Out-Null
    $luxuryLines.Add("- Review notes: $($summary.reviewNotes)") | Out-Null
    $luxuryLines.Add("") | Out-Null
    foreach ($screen in ($screenReviews | Sort-Object { $_["luxuryScore"] })) {
        $luxuryLines.Add("## $($screen.file)") | Out-Null
        $luxuryLines.Add("") | Out-Null
        $luxuryLines.Add("- Route: $($screen.route)") | Out-Null
        $luxuryLines.Add("- Backend module: $($screen.backendModule)") | Out-Null
        $luxuryLines.Add("- Luxury score: $($screen.luxuryScore)/100") | Out-Null
        if ($screen.notes.Count -eq 0) {
            $luxuryLines.Add("- Notes: none") | Out-Null
        } else {
            foreach ($note in $screen.notes) {
                $luxuryLines.Add("- Note: $note") | Out-Null
            }
        }
        $luxuryLines.Add("") | Out-Null
    }
    $luxuryLines | Set-Content -Encoding UTF8 $LuxuryMdReport

    return $summary
}

function Invoke-SafeFixes {
    param(
        [object[]]$Findings
    )

    $fixed = New-Object "System.Collections.Generic.List[string]"

    foreach ($finding in $Findings) {
        $target = Join-Path $Root $finding.file
        if (!(Test-Path $target)) {
            continue
        }

        if ($finding.code -in @("BOTTOM_PADDING_REVIEW", "CHAT_BOTTOM_PADDING_REVIEW")) {
            $content = Get-Content $target -Raw -Encoding UTF8
            $updated = $content
            $updated = $updated.Replace(
                "padding: const EdgeInsets.all(AppSpacing.lg),",
                "padding: const EdgeInsets.fromLTRB(`r`n        AppSpacing.lg,`r`n        AppSpacing.lg,`r`n        AppSpacing.lg,`r`n        104,`r`n      ),"
            )
            $updated = $updated.Replace(
                "padding: const EdgeInsets.fromLTRB(`r`n              AppSpacing.lg,`r`n              0,`r`n              AppSpacing.lg,`r`n              0,`r`n            ),",
                "padding: const EdgeInsets.fromLTRB(`r`n              AppSpacing.lg,`r`n              0,`r`n              AppSpacing.lg,`r`n              104,`r`n            ),"
            )
            if (Set-FileContentIfChanged $target $updated) {
                $fixed.Add("Applied safe bottom padding fix to $($finding.file).") | Out-Null
            }
        }

        if ($finding.code -eq "SETTINGS_COLLECTIONS_ROUTE_MISSING") {
            $content = Get-Content $target -Raw -Encoding UTF8
            $updated = $content.Replace("context.go(AppRoutes.adminProducts)", "context.go(AppRoutes.adminCollections)")
            if (Set-FileContentIfChanged $target $updated) {
                $fixed.Add("Applied safe Collections route fix in $($finding.file).") | Out-Null
            }
        }

        if ($finding.code -eq "SETTINGS_CHAT_ROUTE_MISSING") {
            $content = Get-Content $target -Raw -Encoding UTF8
            $updated = $content.Replace("context.go(AppRoutes.adminUsers)", "context.go(AppRoutes.adminChatRooms)")
            if (Set-FileContentIfChanged $target $updated) {
                $fixed.Add("Applied safe Chat Rooms route fix in $($finding.file).") | Out-Null
            }
        }
    }

    return $fixed
}

function Invoke-StaticAudit {
    $findings = New-Object "System.Collections.Generic.List[object]"

    if (!(Test-Path $MapFile)) {
        Add-Finding $findings "error" "MAP_MISSING" $MapFile "Mobile Admin screen map is missing." "Create ai-harness/config/mobile-admin-screen-map.json."
        return $findings
    }

    if (!(Test-Path $RouterFile)) {
        Add-Finding $findings "error" "ROUTER_MISSING" $RouterFile "Router file is missing." "Verify mobile app router location."
        return $findings
    }

    if (!(Test-Path $CollectionsChatBrdFile)) {
        Add-Finding $findings "error" "BRD_COLLECTIONS_CHAT_MISSING" "ai-harness/docs/brd-admin-collections-and-chat.md" "BRD for Collections and Chat Rooms is missing." "Restore the BRD so Admin UI audit has product context."
    }

    if (!(Test-Path $MobileAdminLuxuryBrdFile)) {
        Add-Finding $findings "error" "BRD_MOBILE_ADMIN_LUXURY_MISSING" "ai-harness/docs/brd-mobile-admin-ui-luxury.md" "Mobile Admin luxury UI BRD is missing." "Restore the BRD so Admin UI scans follow the StrideX premium design target."
    }

    $supportedBackendModules = @{}
    if (!(Test-Path $BackendFeatureMapFile)) {
        Add-Finding $findings "error" "BACKEND_FEATURE_MAP_MISSING" "ai-harness/config/backend-feature-map.json" "Backend feature map is missing." "Restore this map so Mobile Admin UI only exposes backend-supported modules."
    } else {
        try {
            $backendFeatureMap = Get-Content $BackendFeatureMapFile -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($module in @($backendFeatureMap.adminModules) + @($backendFeatureMap.customerModules)) {
                if ($module.supported -eq $true) {
                    $supportedBackendModules[$module.key] = $true
                }
            }
        } catch {
            Add-Finding $findings "error" "BACKEND_FEATURE_MAP_INVALID" "ai-harness/config/backend-feature-map.json" "Backend feature map is not valid JSON." "Fix JSON syntax before running UI mapping automation."
        }
    }

    $map = Get-Content $MapFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $router = Get-Content $RouterFile -Raw -Encoding UTF8

    foreach ($entry in $map.entryPoints) {
        $screenFile = Join-Path $Root $entry.file
        if (!(Test-Path $screenFile)) {
            Add-Finding $findings "error" "SCREEN_FILE_MISSING" $entry.file "Mapped Admin screen file does not exist." "Update the map or restore the screen file."
            continue
        }

        if (!(Test-ContainsAny $router @($entry.route, $entry.path))) {
            Add-Finding $findings "error" "ROUTE_NOT_REGISTERED" $entry.file "Mapped route is not visible in sportshop_router.dart." "Register the route or correct mobile-admin-screen-map.json."
        }

        if ([string]::IsNullOrWhiteSpace($entry.backendModule)) {
            Add-Finding $findings "error" "BACKEND_MODULE_UNMAPPED" $entry.file "Mapped Admin screen does not declare a backendModule." "Map this screen to a backend-supported module or remove it from Admin UI."
        } elseif ($supportedBackendModules.Count -gt 0 -and !$supportedBackendModules.ContainsKey($entry.backendModule)) {
            Add-Finding $findings "error" "BACKEND_MODULE_UNSUPPORTED" $entry.file "Mapped Admin screen references an unsupported backend module: $($entry.backendModule)." "Hide this UI or add backend support before exposing it."
        }

        $content = Get-Content $screenFile -Raw -Encoding UTF8

        if ($entry.file -like "mobile/lib/view/admin/*" -and (Test-HasMojibake $content)) {
            Add-Finding $findings "error" "UI_TEXT_MOJIBAKE" $entry.file "Admin View contains mojibake/encoding-broken text." "Repair Vietnamese UI strings before shipping this screen."
        }

        if ($entry.file -like "mobile/lib/view/admin/*" -and !(Test-ContainsAny $content @("Scaffold("))) {
            Add-Finding $findings "warning" "ADMIN_SCAFFOLD_MISSING" $entry.file "Admin screen may not define a Scaffold." "Confirm it is wrapped by a parent shell or add a screen Scaffold."
        }

        if ($entry.file -like "mobile/lib/view/admin/*" -and (Test-ContainsAny $content @("AdminBottomNav("))) {
            if (!(Test-ContainsAny $content @("108", "104", "100", "96", "88", "bottom:"))) {
                Add-Finding $findings "warning" "BOTTOM_PADDING_REVIEW" $entry.file "Screen uses AdminBottomNav but no obvious bottom safe padding was found." "Add 88-104px bottom padding to scrollable content."
            }
        }

        if ($entry.file -like "mobile/lib/view/admin/*" -and (Test-ContainsAny $content @("ApiClient", "Dio(", "getJson(", "postJson(", "putJson(", "deleteJson(", "http."))) {
            Add-Finding $findings "error" "DIRECT_API_IN_VIEW" $entry.file "Admin View appears to call API/network directly." "Move API access to Controller/Repository/Service according to mobile architecture."
        }

        if (Test-ContainsAny ($entry.mvpChecks -join ",") @("list-state")) {
            if (!(Test-ContainsAny $content @("AppLoadingState", "LinearProgressIndicator", "isLoading"))) {
                Add-Finding $findings "warning" "LIST_LOADING_STATE_REVIEW" $entry.file "Mapped list screen has no obvious loading state." "Expose a loading state through existing controller/UI state."
            }
            if (!(Test-ContainsAny $content @("PremiumEmptyState", "EmptyState", "isEmpty"))) {
                Add-Finding $findings "warning" "LIST_EMPTY_STATE_REVIEW" $entry.file "Mapped list screen has no obvious empty state." "Add or verify a mobile-friendly empty state."
            }
            if (!(Test-ContainsAny $content @("AppErrorState", "AdminInlineBanner", "errorMessage"))) {
                Add-Finding $findings "warning" "LIST_ERROR_STATE_REVIEW" $entry.file "Mapped list screen has no obvious error state." "Surface controller errorMessage through existing error UI."
            }
        }

        if ($entry.file -like "*admin_collections_page.dart") {
            if (!(Test-ContainsAny $content @("loadCollections", "collections"))) {
                Add-Finding $findings "error" "COLLECTIONS_DATA_FLOW_MISSING" $entry.file "Collections screen does not show the expected controller collection flow." "Use the existing AdminCatalogController collections flow."
            }
            if (!(Test-ContainsAny $content @("createCollection", "_openForm"))) {
                Add-Finding $findings "warning" "COLLECTIONS_CREATE_REVIEW" $entry.file "Collections screen has no obvious create action." "Keep or add the existing create collection dialog/action."
            }
            if (!(Test-ContainsAny $content @("deleteCollection", "_delete"))) {
                Add-Finding $findings "warning" "COLLECTIONS_DELETE_REVIEW" $entry.file "Collections screen has no obvious delete action." "Keep or add the existing delete collection flow."
            }
            if (!(Test-ContainsAny $content @("collection.variants.length", "variants.length"))) {
                Add-Finding $findings "warning" "COLLECTIONS_COUNT_REVIEW" $entry.file "Collection rows do not obviously show variant/product count." "Show available collection count metadata when present."
            }
        }

        if ($entry.file -like "*admin_products_page.dart") {
            if (!(Test-ContainsAny $content @("_ManagementTab.sports", "tab=sport", "sports('"))) {
                Add-Finding $findings "error" "PRODUCT_SPORT_TAB_MISSING" $entry.file "Products screen does not expose the BRD-required Sport management tab." "Add a Sport tab and map ?tab=sport to _ManagementTab.sports."
            }
            if (!(Test-ContainsAny $content @("loadSports", "_visibleSports", "SportModel"))) {
                Add-Finding $findings "error" "PRODUCT_SPORT_DATA_MISSING" $entry.file "Products screen Sport tab does not obviously load/render sports." "Use existing AdminCatalogController.loadSports and sports state."
            }
            if (!(Test-ContainsAny $content @("_SportBlockActionButton", "THEM MON THE THAO MOI", "THÃŠM MÃ”N THá»‚ THAO Má»šI +"))) {
                Add-Finding $findings "error" "PRODUCT_SPORT_BLOCK_ACTION_MISSING" $entry.file "Sport tab does not expose the BRD-required bottom block action." "Replace the traditional Sport FAB with a full-width bottom button for creating sports."
            }
            if ((Test-ContainsAny $content @("shape: BoxShape.circle", "BorderRadius.circular(16)", "BorderRadius.circular(14)")) -and (Test-ContainsAny $content @("_SportLookupItem", "_ProductSportVisual"))) {
                Add-Finding $findings "error" "PRODUCT_SPORT_SHARP_STYLE_MISSING" $entry.file "Product Sport tab still appears to use circular/pastel or over-rounded Sport UI." "Use square 48px leading icon, borderThin, and max 8px radius for Sport cards/actions."
            }
        }

        if ($entry.file -like "*admin_chat_rooms_page.dart") {
            if (!(Test-ContainsAny $content @("loadAdminRooms", "rooms"))) {
                Add-Finding $findings "error" "CHAT_ROOMS_DATA_FLOW_MISSING" $entry.file "Chat Rooms screen does not show the expected controller room flow." "Use existing ChatController.loadAdminRooms and rooms state."
            }
            if (!(Test-ContainsAny $content @("_searchController", "_visibleRooms", "AppTextField", "search"))) {
                Add-Finding $findings "warning" "CHAT_SEARCH_REVIEW" $entry.file "Chat Rooms screen has no obvious search/filter UI." "Keep a visible mobile search input for support rooms."
            }
            if (!(Test-ContainsAny $content @("hasUnread", "unread", "CircleAvatar"))) {
                Add-Finding $findings "warning" "CHAT_UNREAD_REVIEW" $entry.file "Chat Rooms screen has no obvious unread indicator." "Display unread status when the room model provides it."
            }
            if (!(Test-ContainsAny $content @("/admin/chats/", "AppRoutes.adminChatDetail", "AdminChatDetailPage"))) {
                Add-Finding $findings "error" "CHAT_DETAIL_NAVIGATION_MISSING" $entry.file "Chat room rows do not obviously navigate to chat detail." "Navigate each room to the existing admin chat detail route."
            }
            if ((Test-ContainsAny $content @("AdminBottomNav(")) -and (Test-ContainsAny $content @("AbsolutePersistentLayout("))) {
                if (!(Test-ContainsAny $content @("104", "108", "bottom:", "SafeArea"))) {
                    Add-Finding $findings "warning" "CHAT_BOTTOM_PADDING_REVIEW" $entry.file "Chat Rooms uses fixed bottom nav; dynamic list should be verified for bottom safe spacing." "Add explicit bottom padding or verify AbsolutePersistentLayout preserves safe content above nav."
                }
            }
        }

        if ($entry.file -like "*admin_sports_page.dart") {
            if (!(Test-ContainsAny $content @("sports_soccer", "sports_tennis", "directions_run", "pool_outlined"))) {
                Add-Finding $findings "warning" "SPORT_ICON_MAPPING_REVIEW" $entry.file "Sport screen has no obvious dynamic sport icon mapping." "Map icon by sport name for soccer, tennis, running, swimming, and fallback sports."
            }
            if (!(Test-ContainsAny $content @("_PremiumAddButton", "THEM MON THE THAO MOI", "THÃŠM MÃ”N THá»‚ THAO Má»šI +"))) {
                Add-Finding $findings "error" "SPORT_BLOCK_ACTION_MISSING" $entry.file "Sport screen does not expose the Supersports full-width bottom action." "Replace round/pill add actions with a 52px full-width navy block button."
            }
            if (Test-ContainsAny $content @("shape: BoxShape.circle", "BorderRadius.circular(16)", "BorderRadius.circular(14)", "BorderRadius.circular(24)", "BorderRadius.circular(50)")) {
                Add-Finding $findings "error" "SPORT_OVER_ROUNDED_UI" $entry.file "Sport screen still contains circular or over-rounded UI tokens." "Use square icon containers, 8px radius, thin borders, and clean shadow."
            }
            if (Test-ContainsAny $content @("THÃƒÅ M MÃ¡Â»Å¡I", "THEM MOI")) {
                Add-Finding $findings "warning" "APPBAR_EXTRA_ADD_TEXT" $entry.file "Sport AppBar may contain extra Add text." "Keep title as Quan ly mon the thao and move add action to FAB/button."
            }
        }
    }

    $settingsFile = Join-Path $AdminViewRoot "admin_system_settings_page.dart"
    if (Test-Path $settingsFile) {
        $settings = Get-Content $settingsFile -Raw -Encoding UTF8
        if ($settings.Contains("AppRoutes.adminAddProduct") -or $settings.Contains("/admin/products/new")) {
            Add-Finding $findings "error" "SPORT_MENU_WRONG_TARGET" "mobile/lib/view/admin/admin_system_settings_page.dart" "Settings contains a forbidden product form target near Admin navigation." "Sport menu must point to AppRoutes.adminProducts with ?tab=sport."
        }
        if ($settings.Contains("tab=sports") -or !$settings.Contains("AppRoutes.adminProducts") -or !$settings.Contains("tab=sport")) {
            Add-Finding $findings "error" "SETTINGS_SPORT_ROUTE_MISMATCH" "mobile/lib/view/admin/admin_system_settings_page.dart" "Settings Sport menu is not mapped to the BRD product Sport tab." "Point the Mon the thao menu item to AppRoutes.adminProducts with ?tab=sport."
        }
        if ($settings.Contains("Colors.blue") -and $settings.Contains("logout")) {
            Add-Finding $findings "warning" "LOGOUT_COLOR_REVIEW" "mobile/lib/view/admin/admin_system_settings_page.dart" "Logout area may be using blue styling." "Use premium warning style with #DC2626 on pale red."
        }
        if ($settings.Contains("tab=collections") -or !$settings.Contains("AppRoutes.adminCollections")) {
            Add-Finding $findings "error" "SETTINGS_COLLECTIONS_ROUTE_MISSING" "mobile/lib/view/admin/admin_system_settings_page.dart" "Settings does not obviously route Collections to the standalone backend-supported Collections module." "Point the Bo suu tap menu item to AppRoutes.adminCollections."
        }
        if (!($settings.Contains("AppRoutes.adminChatRooms"))) {
            Add-Finding $findings "error" "SETTINGS_CHAT_ROUTE_MISSING" "mobile/lib/view/admin/admin_system_settings_page.dart" "Settings does not obviously route Chat Rooms to AppRoutes.adminChatRooms." "Point the Phong chat menu item to AppRoutes.adminChatRooms."
        }
    }

    Get-AdminButtonInventory $findings | Out-Null
    Get-AdminLuxuryReview $map | Out-Null

    return $findings
}

$attemptReports = @()
$safeFixLog = New-Object "System.Collections.Generic.List[string]"
for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
    $findings = Invoke-StaticAudit
    $attemptReports += [ordered]@{
        attempt = $attempt
        findings = $findings
    }

    if ($findings.Count -eq 0) {
        break
    }

    if ($ApplySafeFixes) {
        $fixes = Invoke-SafeFixes $findings
        foreach ($fix in $fixes) {
            $safeFixLog.Add($fix) | Out-Null
        }
        if ($fixes.Count -eq 0) {
            break
        }
    } else {
        break
    }
}

$summary = [ordered]@{
    generatedAt = (Get-Date).ToString("s")
    area = "mobile-admin"
    attempts = $attemptReports
    safeFixes = $safeFixLog
    status = if (($attemptReports[-1].findings).Count -eq 0) { "pass" } else { "needs-fix" }
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 $JsonReport

$lines = New-Object "System.Collections.Generic.List[string]"
$lines.Add("# Admin Mobile UI Audit") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("- Generated: $($summary.generatedAt)") | Out-Null
$lines.Add("- Status: $($summary.status)") | Out-Null
$lines.Add("- Attempts: $($attemptReports.Count)") | Out-Null
$lines.Add("- Button inventory: $ButtonMdReport") | Out-Null
$lines.Add("- Luxury review: $LuxuryMdReport") | Out-Null
$lines.Add("") | Out-Null

if ($safeFixLog.Count -gt 0) {
    $lines.Add("## Safe fixes applied") | Out-Null
    $lines.Add("") | Out-Null
    foreach ($fix in $safeFixLog) {
        $lines.Add("- $fix") | Out-Null
    }
    $lines.Add("") | Out-Null
}

$latestFindings = $attemptReports[-1].findings
if ($latestFindings.Count -eq 0) {
    $lines.Add("No static MVP findings detected.") | Out-Null
} else {
    foreach ($finding in $latestFindings) {
        $lines.Add("## [$($finding.severity)] $($finding.code)") | Out-Null
        $lines.Add("") | Out-Null
        $lines.Add("- File: ``$($finding.file)``") | Out-Null
        $lines.Add("- Issue: $($finding.message)") | Out-Null
        $lines.Add("- Suggested fix: $($finding.suggestion)") | Out-Null
        $lines.Add("") | Out-Null
    }
}

$lines | Set-Content -Encoding UTF8 $MdReport

if ($RunMobileChecks) {
    Push-Location $MobileRoot
    try {
        dart format lib test
        powershell -ExecutionPolicy Bypass -File .\init.ps1 -Analyze
        powershell -ExecutionPolicy Bypass -File .\init.ps1 -Test
    } finally {
        Pop-Location
    }
}

Write-Host "Admin Mobile UI audit report: $MdReport"
Write-Host "Status: $($summary.status)"

if ($summary.status -ne "pass") {
    exit 1
}
