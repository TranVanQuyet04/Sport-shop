param(
    [string]$Source = (Join-Path $PSScriptRoot '..\Report_Final Project Report_Complete.docx'),
    [string]$Destination = (Join-Path $PSScriptRoot '..\Report_Final Project Report_Mobile_Backend.docx')
)

Add-Type -AssemblyName System.IO.Compression

$sourcePath = [System.IO.Path]::GetFullPath($Source)
$destinationPath = [System.IO.Path]::GetFullPath($Destination)

# Word can keep the source document open. Read it with sharing enabled and write a separate copy.
$input = [System.IO.FileStream]::new(
    $sourcePath,
    [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::Read,
    [System.IO.FileShare]::ReadWrite
)
$output = [System.IO.FileStream]::new(
    $destinationPath,
    [System.IO.FileMode]::Create,
    [System.IO.FileAccess]::Write,
    [System.IO.FileShare]::None
)
try {
    $input.CopyTo($output)
} finally {
    $output.Dispose()
    $input.Dispose()
}

$replacements = [ordered]@{
    'Sportswear E-Commerce Website' = 'Sportswear E-Commerce Mobile Application and Backend System'
    'This initiative focuses on building a dedicated web-based platform for retailing sportswear items online. The application integrates standard e-commerce functions—such as product catalogs, cart management, and payment processing—with advanced capabilities including AI-powered product categorization and a conversational chatbot for personalized product suggestions.' = 'This initiative focuses on building a mobile-first sportswear retail system consisting of a Flutter mobile application and a Spring Boot microservices backend. The mobile application supports product discovery, cart management, checkout, payment, order tracking, administration, and delivery operations, while the backend provides secure REST APIs, domain processing, persistence, caching, and AI-assisted customer support.'
    'Effort Allocation: Requirements & Analysis (15%), Architecture & UI/UX Design (25%), Backend & Frontend Coding (40%), Testing & Bug Fixing (15%), Project Management (5%).' = 'Effort Allocation: Requirements & Analysis (15%), Mobile Architecture & UI/UX Design (25%), Backend & Mobile Frontend Coding (40%), Testing & Bug Fixing (15%), Project Management (5%).'
    'Implementation: developing frontend and backend modules in accordance with the design specifications.' = 'Implementation: developing the Flutter mobile frontend and Spring Boot backend services in accordance with the design specifications.'
    'D03 - Source Code Repository: Internal & external deliverable containing fully commented Spring Boot backend and Flutter frontend codebase hosted on GitHub.' = 'D03 - Source Code Repository: Internal and external deliverable containing the documented Flutter mobile frontend (`/mobile`) and Spring Boot microservices backend (`/backend`) hosted on GitHub.'
    'Frontend UI/UX Implementation (Flutter): Frontend Lead (Accountable/Responsible), Backend Lead (Consulted).' = 'Mobile UI/UX Implementation (Flutter): Mobile Frontend Lead (Accountable/Responsible), Backend Lead (Consulted).'
    'JavaScript/Flutter(frontend user interface)' = 'Dart (Flutter mobile frontend and user interface)'
    'Flutterfor building the frontend user interface' = 'Flutter for building the Android/iOS mobile user interface'
    'The Sportswear E-Commerce Mobile Application and Backend System is a web-based retail platform engineered specifically for sportswear products. It delivers essential shopping capabilities including product catalog management, shopping cart functionality, secure online payment processing, and order lifecycle management. Beyond standard e-commerce features, the platform incorporates intelligent components: an AI-powered product classification module that automatically categorizes items, and a conversational chatbot that provides personalized product recommendations to enhance the customer shopping experience.' = 'The Sportswear E-Commerce Mobile Application and Backend System is a mobile-first retail solution engineered specifically for sportswear products. The Flutter application provides role-based experiences for guests, customers, administrators, and delivery staff, including product discovery, shopping cart, checkout, payment, order tracking, catalog administration, delivery updates, and support chat. The Spring Boot backend enforces authentication, business rules, data persistence, inventory and order processing, reporting, and AI-assisted product classification and recommendations.'
    'The system is realized as a multi-platform application utilizing Flutter (Dart) for both Web and Mobile clients, communicating with the Spring Boot backend through REST APIs.' = 'The system consists of a Flutter (Dart) mobile client for Android and iOS communicating through secured REST APIs with four Spring Boot backend microservices: Auth, Product Catalog, Order Fulfillment, and Support Chat.'
    'The AI Chatbot module acts as a virtual shopping assistant accessible from any page within the website:' = 'The AI Chatbot module acts as a virtual shopping assistant accessible from the support and chat screens in the mobile application:'
    'The deployment architecture comprises a User Device running Flutter Frontend communicating via HTTPS REST API to the Backend Server running Docker containerized Spring Boot Application alongside PostgreSQL and Redis instances.' = 'The deployment architecture comprises an Android or iOS device running the Flutter mobile application, which communicates through HTTPS REST APIs with Docker-containerized Spring Boot microservices backed by PostgreSQL and Redis.'
    'Inside: web UI, Flutter app, Spring Boot services, authentication, catalog, cart, orders, delivery, reporting and chat.' = 'Inside: Flutter mobile frontend, Spring Boot microservices, authentication, catalog, cart, orders, delivery, reporting, and chat.'
    'Frontend Lead: Responsible for UI component testing and cross-browser responsiveness validation.' = 'Mobile Frontend Lead: Responsible for Flutter widget testing, device-size responsiveness, navigation, and Android/iOS workflow validation.'
    'Analysis: The high pass rate confirms that the modular monolithic backend effectively enforces business rules and data consistency. Resolved defects primarily involved edge-case cart synchronization when multiple browser tabs were open and minor UI alignment on mobile screens.' = 'Analysis: The high pass rate confirms that the microservices backend effectively enforces business rules and data consistency. Resolved defects primarily involved edge-case cart synchronization between mobile state and backend inventory, together with minor UI alignment issues across mobile screen sizes.'
    'Source Code Package: `sportswear-ecommerce-v1.0.0.zip` containing Spring Boot microservices (`/backend`), Flutter frontend (`/frontend`), and Flutter mobile application (`/mobile`).' = 'Source Code Package: `sportswear-ecommerce-v1.0.0.zip` containing the Spring Boot microservices (`/backend`) and Flutter mobile frontend (`/mobile`).'
    'Containerization Artifacts: `Dockerfile` (Backend/Frontend) and `docker-compose.yml` orchestrating API, UI, PostgreSQL, and Redis containers.' = 'Containerization Artifacts: backend `Dockerfile` files and `docker-compose.yml` for orchestrating Spring Boot APIs, PostgreSQL, and Redis. The Flutter mobile application is built separately as an Android APK/App Bundle or iOS application package.'
    'Runtime Environments: Java Development Kit (JDK) 17+, Node.js v18.x+, npm v9.x+.' = 'Runtime Environments: Java Development Kit (JDK) 21+, Flutter SDK with Dart 3.12+, and Android Studio/Android SDK or Xcode for mobile builds.'
    'Step 4 (Accessing the Application): Once containers start successfully, run `cd frontend && npm run dev` to launch the App UI at `http://localhost:63198`, run `cd mobile && flutter run` to launch the Flutter Mobile App, and access API documentation on ports 8081 through 8084.' = 'Step 4 (Running the Mobile Application): Once backend services start successfully, run `cd mobile`, `flutter pub get`, and `flutter run` on an Android/iOS emulator or physical device. Configure the mobile API base URLs for the host machine, and access the backend OpenAPI documentation on ports 8081 through 8084.'
    'The Sportswear E-Commerce Mobile Application and Backend System provides two primary interfaces: the public Customer Storefront (enabling product discovery, AI chat assistance, cart operations, checkout) and the secure Administrative Dashboard (enabling catalog management, AI product classification, and order status updates).' = 'The Flutter mobile application provides role-based interfaces: a customer shopping experience for product discovery, AI chat, cart, checkout, and order tracking; an administrative workspace for catalog, user, report, and order management; and a delivery-staff workspace for assigned shipments and delivery status updates.'
    'The StrideX Support Chatbot is integrated directly into the customer storefront via the floating ChatBubble component. It operates on a Hybrid Architecture, combining rule-based local intent resolution with LLM-powered natural language processing via OpenRouter API (ChatBotService).' = 'The StrideX Support Chatbot is integrated into the Flutter mobile support and guest-chat screens. It uses a hybrid architecture that combines rule-based intent resolution in the Spring Boot Support Chat Service with LLM-powered natural-language processing through the configured AI provider.'
    'Step 4 (Interactive Action Markers): AI responses automatically embed dynamic action markers such as [[ACTION:VIEW_PRODUCT]], [[ACTION:ADD_TO_CART]], and [[ACTION:BUY_NOW]]. The frontend ChatBubble automatically parses these markers into interactive, one-click buttons, allowing customers to view specifications or add recommended items directly to their cart without leaving the chat window.' = 'Step 4 (Interactive Action Markers): AI responses may embed action markers such as [[ACTION:VIEW_PRODUCT]], [[ACTION:ADD_TO_CART]], and [[ACTION:BUY_NOW]]. The Flutter mobile chat interface parses these markers into touch-friendly actions so customers can open product details or add recommended items without leaving the conversation flow.'
}

$packageStream = [System.IO.FileStream]::new(
    $destinationPath,
    [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::ReadWrite,
    [System.IO.FileShare]::None
)
$archive = [System.IO.Compression.ZipArchive]::new(
    $packageStream,
    [System.IO.Compression.ZipArchiveMode]::Update,
    $false
)

try {
    $entry = $archive.GetEntry('word/document.xml')
    $reader = [System.IO.StreamReader]::new($entry.Open())
    try {
        $documentXml = [System.Xml.XmlDocument]::new()
        $documentXml.PreserveWhitespace = $true
        $documentXml.LoadXml($reader.ReadToEnd())
    } finally {
        $reader.Dispose()
    }

    $namespaceManager = [System.Xml.XmlNamespaceManager]::new($documentXml.NameTable)
    $namespaceManager.AddNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
    $changed = 0

    foreach ($paragraph in $documentXml.SelectNodes('//w:p', $namespaceManager)) {
        $textNodes = @($paragraph.SelectNodes('.//w:t', $namespaceManager))
        if ($textNodes.Count -eq 0) { continue }

        $originalText = ($textNodes | ForEach-Object { $_.InnerText }) -join ''
        $newText = $originalText

        foreach ($pair in $replacements.GetEnumerator()) {
            if ($newText.Contains($pair.Key)) {
                $newText = $newText.Replace($pair.Key, $pair.Value)
            }
        }

        if ($newText.StartsWith('This initiative focuses on building a dedicated web-based platform')) {
            $newText = 'This initiative focuses on building a mobile-first sportswear retail system consisting of a Flutter mobile application and a Spring Boot microservices backend. The mobile application supports product discovery, cart management, checkout, payment, order tracking, administration, and delivery operations, while the backend provides secure REST APIs, domain processing, persistence, caching, and AI-assisted customer support.'
        }

        if ($newText -ne $originalText) {
            $textNodes[0].InnerText = $newText
            for ($index = 1; $index -lt $textNodes.Count; $index++) {
                $textNodes[$index].InnerText = ''
            }
            $changed++
        }
    }

    $entry.Delete()
    $newEntry = $archive.CreateEntry('word/document.xml', [System.IO.Compression.CompressionLevel]::Optimal)
    $writerSettings = [System.Xml.XmlWriterSettings]::new()
    $writerSettings.Encoding = [System.Text.UTF8Encoding]::new($false)
    $writerSettings.Indent = $false
    $writer = [System.Xml.XmlWriter]::Create($newEntry.Open(), $writerSettings)
    try {
        $documentXml.Save($writer)
    } finally {
        $writer.Dispose()
    }

    Write-Output "Updated paragraphs: $changed"
    Write-Output "Created: $destinationPath"
} finally {
    $archive.Dispose()
    $packageStream.Dispose()
}
