# Context Diagram - Sport Shop System

This diagram models Sport Shop as one system and shows its users and external integrations.

```mermaid
flowchart LR
    guest["Guest"]
    customer["Customer / Member"]
    staff["Shop Staff"]
    shipper["Delivery Staff / Shipper"]
    admin["Administrator"]
    system(("SPORT SHOP SYSTEM<br/>Web + Mobile + Backend API"))
    vnpay["VNPay<br/>Payment Gateway"]
    mail["SMTP<br/>Email Service"]
    gemini["Google Gemini<br/>AI Service"]

    guest -->|"Browse/search products; ask chatbot"| system
    system -->|"Catalog, product details, AI answers"| guest
    customer -->|"Account, cart, address, orders, payments, support"| system
    system -->|"Account, order/payment status, support replies"| customer
    staff -->|"Process orders, assign delivery, manage shifts"| system
    system -->|"Orders, assignments, shifts, operation results"| staff
    shipper -->|"Update delivery status and reports"| system
    system -->|"Assigned orders, recipient and schedule data"| shipper
    admin -->|"Manage users, catalog, inventory, orders, settings"| system
    system -->|"Dashboard, reports, statistics, support chats"| admin
    system -->|"Order data and payment request"| vnpay
    vnpay -->|"Payment URL and transaction callback"| system
    system -->|"OTP, password reset, notification email"| mail
    mail -->|"Email delivery status"| system
    system -->|"Chat question and product prompt"| gemini
    gemini -->|"Chat response and product suggestion"| system

    classDef actor fill:#E8F1FF,stroke:#2563EB,color:#0F172A,stroke-width:1.5px;
    classDef core fill:#111827,stroke:#F59E0B,color:#FFFFFF,stroke-width:3px;
    classDef external fill:#FFF7ED,stroke:#EA580C,color:#431407,stroke-width:1.5px;
    class guest,customer,staff,shipper,admin actor;
    class system core;
    class vnpay,mail,gemini external;
```

## Actors and Data Flows

| Actor / external system | Data sent to Sport Shop | Data received from Sport Shop |
|---|---|---|
| Guest | Search criteria, filters, chatbot questions | Catalog, product details, AI responses |
| Customer | Account, cart, address, order, payment and support data | Authentication, product, order/payment and support results |
| Shop Staff | Order processing, shipper assignment, shift updates | Orders, assignments, shifts and operation results |
| Delivery Staff | Delivery status and delivery reports | Assigned orders, recipient details and schedules |
| Administrator | User, staff, catalog, inventory, order and settings updates | Dashboard, reports, statistics and operational data |
| VNPay | Transaction callback and payment result | Payment request and order information |
| SMTP | Email delivery status | OTP, password reset and notification messages |
| Google Gemini | Generated AI content | Chat questions and product suggestion prompts |

## System Boundary

- Inside: web UI, Flutter app, Spring Boot services, authentication, catalog, cart, orders, delivery, reporting and chat.
- Outside: user roles, VNPay, SMTP and Google Gemini.
- PostgreSQL and Redis are internal infrastructure, so they are not external context actors.
