# Logicore / Hamza RMB Mobile & Customer REST API Documentation

> **Live API Base URL:** `https://hamza-rmb.onrender.com/api/v1`  
> **Swagger UI:** `https://hamza-rmb.onrender.com/api-docs/`  
> **Local Dev Base URL:** `https://hamza-rmb.onrender.com/api/v1`  
> **OpenAPI Specification Version:** `3.0.0`  
> **Scope:** Customer & Mobile App Endpoints (All internal Admin & Staff operations strictly excluded)

---

## Table of Contents

1. [Global Architecture & Authentication](#1-global-architecture--authentication)
2. [Public Metadata, Pricing & Settings](#2-public-metadata-pricing--settings)
3. [Authentication & Customer Profile](#3-authentication--customer-profile)
4. [Shipments, Consolidations & Tracking](#4-shipments-consolidations--tracking)
5. [Buy-For-Me (1688 / Taobao Procurement)](#5-buy-for-me-1688--taobao-procurement)
6. [RMB Currency Exchange & Saved Accounts](#6-rmb-currency-exchange--saved-accounts)
7. [Customer Wallet & Deposits](#7-customer-wallet--deposits)
8. [Doorstep Delivery & Dispatch (Nigeria)](#8-doorstep-delivery--dispatch-nigeria)
9. [Customer Support Tickets](#9-customer-support-tickets)
10. [In-App Notifications](#10-in-app-notifications)
11. [AI Assistant (Aisha Chatbot)](#11-ai-assistant-aisha-chatbot)
12. [Media & File Uploads](#12-media--file-uploads)
13. [Data Models & Schema Reference](#13-data-models--schema-reference)

---

## 1. Global Architecture & Authentication

### Security Scheme

- **Type:** HTTP Bearer Authentication (`bearerAuth`)
- **Header:** `Authorization: Bearer <JWT_TOKEN>`
- **Token Source:** Generated upon login (`POST /auth/login`) or completing registration (`POST /auth/set-password`).

### Standard Response Envelopes

#### Success Envelope (`ApiResponse`)

```json
{
  "status": "success",
  "message": "Operation completed successfully",
  "data": {}
}
```

_(Some endpoints also return top-level `{ "success": true, "data": ... }`.)_

#### Error Envelope (`ErrorResponse`)

```json
{
  "status": "error",
  "message": "Invalid parameter or unauthorized access"
}
```

---

## 2. Public Metadata, Pricing & Settings

### `GET /settings`

- **Summary:** Fetch global system metadata, freight rates, live exchange rates, minimum shipment thresholds, and company escrow details.
- **Auth:** Public (No token required)
- **Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "cnyExchangeRate": 215,
    "usdExchangeRate": 1550,
    "airFreightRatePerKg": 12500,
    "seaFreightRatePerCbm": 450000,
    "seaFreightRatePerKg": 3500,
    "minAirFreightKg": 1,
    "minSeaFreightCbm": 0.1,
    "buyForMeFeePercent": 5,
    "buyForMeFixedFee": 1000,
    "ngnEscrowBankName": "GTBank",
    "ngnEscrowAccountNo": "0123456789",
    "ngnEscrowAccountName": "Hamza RMB Trading Escrow Ltd",
    "companyName": "HAMZA RMB GLOBAL COMPANY LTD",
    "chinaAirCargoAddressCn": "义乌市稠州北路国贸大厦6楼602",
    "nigeriaOfficeAddress": "No. 08 Gwarzo Road Beside Shopwell, Gwale Kano State, Nigeria"
  }
}
```

---

### `GET /banners`

- **Summary:** Fetch active sliding promotional banners for mobile app home screen carousel.
- **Auth:** Public (No token required)
- **Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": "bnr-101",
      "title": "Fast Air Cargo Special",
      "subtitle": "Guangzhou to Lagos in 3-5 days @ ₦12,500/kg",
      "imageUrl": "https://images.unsplash.com/photo-1570710891163",
      "linkUrl": "https://hamzarmb.com/air-cargo",
      "targetScreen": "air_freight",
      "displayOrder": 1,
      "isActive": true
    }
  ]
}
```

---

### `GET /delivery/vehicles`

- **Summary:** Fetch active doorstep delivery vehicle fleet, base pickup fares, and per-kilometer rates.
- **Auth:** Public (No token required)
- **Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": "vh-001",
      "name": "Express Motorbike",
      "type": "motorbike",
      "description": "Fastest for light packages up to 15kg.",
      "baseFare": 1000,
      "perKmRate": 150,
      "maxWeightKg": 15,
      "imageUrl": "https://images.unsplash.com/photo-1558981806-ec527fa84c39",
      "isActive": true
    }
  ]
}
```

---

### `GET /facilities`

- **Summary:** List all origin (China intake hubs) and destination (Nigeria branches/hubs) warehouse facilities.
- **Auth:** Public (No token required)
- **Response (200 OK):**

```json
[
  {
    "id": "fac-101",
    "name": "Guangzhou Main Intake Warehouse",
    "code": "CAN-01",
    "country": "China",
    "city": "Guangzhou",
    "address": "Baiyun District, Logistics Park B",
    "contactName": "Chen Wei",
    "contactPhone": "+8613800138000",
    "type": "warehouse",
    "isActive": true
  }
]
```

---

### `GET /facilities/{id}`

- **Summary:** Get specific warehouse facility location details.
- **Auth:** Public (No token required)
- **Path Parameters:**
  - `id` (string, required): Facility ID (e.g. `fac-101`)
- **Response (200 OK):** Facility object.

---

### `GET /meta/options`

- **Summary:** Get all valid system enums, shipment statuses, ticket categories, priorities, vehicle types, and configuration options.
- **Auth:** Public (No token required)
- **Response (200 OK):** Dictionary of system categories, statuses, vehicle types, and roles.

---

## 3. Authentication & Customer Profile

### Registration Flow (3 Steps via Redis Cache)

#### Step 1: `POST /auth/register`

- **Summary:** Initiate customer account registration. Stores pending data in Redis and dispatches verification OTP to the user's email.
- **Auth:** Public
- **Request Body:**

```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "password": "Password123!",
  "phone": "+2348012345678"
}
```

- **Responses:**
  - `201 Created`: Registration initiated & OTP sent.
  - `400 Bad Request`: Validation failure or email/phone already exists.

---

#### Step 2: `POST /auth/verify-otp`

- **Summary:** Verify email registration 6-digit OTP code against Redis cache.
- **Auth:** Public
- **Request Body:**

```json
{
  "email": "john.doe@example.com",
  "otp": "123456"
}
```

- **Response (200 OK):** OTP verified successfully.

---

#### Step 3: `POST /auth/set-password`

- **Summary:** Set final password, persist user from Redis into the permanent database, and issue customer authentication token.
- **Auth:** Public
- **Request Body:**

```json
{
  "email": "john.doe@example.com",
  "password": "Password123!"
}
```

- **Response (200 OK):** User account created and JWT Bearer token issued.

---

### `POST /auth/resend-otp`

- **Summary:** Resend email registration OTP code.
- **Auth:** Public
- **Request Body:**

```json
{
  "email": "john.doe@example.com"
}
```

- **Response (200 OK):** New OTP dispatched to email.

---

### `POST /auth/check-availability`

- **Summary:** Verify whether an email address or phone number is already registered before onboarding.
- **Auth:** Public
- **Request Body:**

```json
{
  "email": "user@example.com",
  "phone": "+2348012345678"
}
```

- **Response (200 OK):** Availability check result.

---

### `POST /auth/login`

- **Summary:** Authenticate customer with email and password.
- **Auth:** Public
- **Request Body:**

```json
{
  "email": "customer@example.com",
  "password": "Password123!"
}
```

- **Responses:**
  - `200 OK`: Login successful (returns auth token & user profile).
  - `401 Unauthorized`: Invalid credentials.

---

### Password Recovery Flow

#### Step 1: `POST /auth/forgot-password`

- **Summary:** Request password reset OTP code dispatched to user email.
- **Auth:** Public
- **Request Body:**

```json
{
  "email": "user@example.com"
}
```

- **Response (200 OK):** Reset OTP sent to email.

---

#### Step 2: `POST /auth/verify-reset-otp`

- **Summary:** Verify password reset OTP code.
- **Auth:** Public
- **Request Body:**

```json
{
  "email": "user@example.com",
  "otp": "654321"
}
```

- **Response (200 OK):** Reset OTP verified.

---

#### Step 3: `POST /auth/reset-password`

- **Summary:** Set new password using verified OTP token.
- **Auth:** Public
- **Request Body:**

```json
{
  "email": "user@example.com",
  "otp": "654321",
  "newPassword": "NewSecurePassword123!"
}
```

- **Response (200 OK):** Password reset successful.

---

### Customer Profile Management

#### `GET /auth/me`

- **Summary:** Fetch the currently authenticated customer's profile.
- **Auth:** `Bearer Token`
- **Response (200 OK):**

```json
{
  "status": "success",
  "data": {
    "id": "usr-1002",
    "customerId": "HZ-20260816-9012",
    "firstName": "John",
    "lastName": "Doe",
    "email": "customer@example.com",
    "phone": "+2348099999999",
    "role": "customer",
    "isVerified": true,
    "photo": "https://res.cloudinary.com/demo/image/upload/avatar.jpg"
  }
}
```

---

#### `PATCH /auth/profile`

- **Summary:** Update user profile information or avatar photo.
- **Auth:** `Bearer Token`
- **Content-Type:** `multipart/form-data`
- **Form Data:**
  - `firstName` (string, optional): e.g. `"John"`
  - `lastName` (string, optional): e.g. `"Doe"`
  - `phone` (string, optional): e.g. `"+2348099999999"`
  - `photo` (binary file, optional): Avatar image file
- **Response (200 OK):** Updated user profile.

---

#### `POST /auth/push-token`

- **Summary:** Register customer's device push notification token (FCM or Expo).
- **Auth:** `Bearer Token`
- **Request Body:**

```json
{
  "pushToken": "ExponentPushToken[xxxxxxxxxxxxxx]"
}
```

- **Response (200 OK):** Push token registered.

---

#### `POST /auth/change-password`

- **Summary:** Change account password for the currently logged-in customer.
- **Auth:** `Bearer Token`
- **Request Body:**

```json
{
  "currentPassword": "OldPassword123!",
  "newPassword": "NewSecurePassword123!"
}
```

- **Response (200 OK):** Password changed successfully.

---

#### `POST /auth/logout`

- **Summary:** Invalidate current user session.
- **Auth:** `Bearer Token`
- **Response (200 OK):** Logged out successfully.

---

## 4. Shipments, Consolidations & Tracking

### `POST /shipments/pre-alert`

- **Summary:** Submit package pre-alert before arrival at the China hub.
- **Auth:** `Bearer Token`
- **Request Body:**

```json
{
  "trackingNumber": "SF10928374",
  "courierName": "SF Express",
  "declaredValueUsd": 150,
  "itemDescription": "Designer Handbags",
  "supplierName": "Mister Shop",
  "originCountry": "China",
  "paymentOption": "pay_before_dispatch",
  "estimatedItems": 12,
  "notes": "Fragile items",
  "photos": ["https://res.cloudinary.com/.../img1.jpg"]
}
```

_Note: The API accepts standard OpenAPI fields (`trackingNumber`, `courierName`, `declaredValueUsd`, `itemDescription`) as well as extended pre-alert fields (`chineseTrackingNo`, `supplierName`, `originCountry`, `paymentOption`, `estimatedItems`, `notes`, `photos`)._

- **Response (201 Created):**

```json
{
  "status": "success",
  "data": {
    "id": "764b95dd-0581-4e4a-b2c9-138a8037e52d",
    "trackingId": "HZ-AIR-202609-002",
    "chineseTrackingNo": "SF10928374",
    "customerId": "HZ-20260816-9012",
    "customerName": "John Doe",
    "status": "pre_alerted",
    "description": "Designer Handbags",
    "weightKg": 0,
    "cbm": 0,
    "paymentStatus": "unpaid",
    "preAlertDate": "2026-09-24T12:11:23.041Z",
    "createdAt": "2026-09-24T12:11:23.042Z"
  }
}
```

---

### `GET /shipments/packages`

- **Summary:** List customer's packages received or stored at warehouse hubs.
- **Auth:** `Bearer Token`
- **Response (200 OK):**

```json
{
  "status": "success",
  "data": [
    {
      "id": "pkg-10029",
      "trackingNumber": "SF10928374",
      "customerId": "HZ-20260816-9012",
      "customerName": "John Doe",
      "courierName": "SF Express",
      "declaredValueUsd": 150,
      "weightKg": 4.5,
      "cbm": 0.024,
      "status": "received_cn",
      "photos": ["https://res.cloudinary.com/.../pkg.jpg"],
      "receivedDate": "2026-08-16T10:00:00.000Z"
    }
  ]
}
```

---

### `POST /shipments/consolidate`

- **Summary:** Bundle multiple received warehouse packages into a single consolidated air or sea consignment.
- **Auth:** `Bearer Token`
- **Request Body:**

```json
{
  "packageIds": ["pkg-10029", "pkg-10030"],
  "shippingMethod": "air",
  "destinationWarehouse": "lagos",
  "paymentMethod": "wallet"
}
```

- **Field Options:**
  - `shippingMethod`: `"air" | "sea" | "express"`
  - `paymentMethod`: `"wallet" | "cash_on_delivery"`
- **Response (201 Created):**

```json
{
  "status": "success",
  "data": {
    "id": "con-5001",
    "consolidationId": "CON-10021",
    "customerId": "HZ-20260816-9012",
    "shippingMethod": "air",
    "destinationWarehouse": "lagos",
    "paymentMethod": "wallet",
    "totalWeightKg": 12.5,
    "totalCbm": 0.08,
    "shippingFee": 125,
    "status": "ready_to_batch"
  }
}
```

---

### `GET /shipments/consolidations`

- **Summary:** List all customer's consolidated shipments.
- **Auth:** `Bearer Token`
- **Response (200 OK):** Array of consolidation objects.

---

### `GET /shipments/tracking/{id}`

- **Summary:** Public track-and-trace lookup by tracking number, consolidation ID, or master batch ID.
- **Auth:** Public (No token required)
- **Path Parameters:**
  - `id` (string, required): e.g. `HZ-CN-90812`, `SF10928374`, or `CON-10021`
- **Response (200 OK):**

```json
{
  "trackingNumber": "HZ-CN-90812",
  "status": "shipping_exported",
  "timeline": [
    {
      "status": "pre_alerted",
      "timestamp": "2026-08-14T09:00:00.000Z",
      "description": "Pre-alert submitted by sender"
    },
    {
      "status": "received_cn",
      "timestamp": "2026-08-16T10:00:00.000Z",
      "description": "Intake scanned at Guangzhou hub"
    },
    {
      "status": "in_transit",
      "timestamp": "2026-08-18T14:30:00.000Z",
      "description": "Departed Guangzhou on flight ET-3801"
    }
  ]
}
```

---

## 5. Buy-For-Me (1688 / Taobao Procurement)

### `POST /procurements/request`

- **Summary:** Submit a 1688 / Taobao item link for Hamza RMB procurement team to purchase on your behalf.
- **Auth:** `Bearer Token`
- **Request Body:**

```json
{
  "productUrl": "https://detail.1688.com/offer/67123912.html",
  "quantity": 50,
  "specifications": "Size XL, Black",
  "notes": "Please confirm available factory stock"
}
```

- **Response (201 Created):**

```json
{
  "status": "success",
  "data": {
    "id": "proc-881",
    "customerId": "HZ-20260816-9012",
    "productUrl": "https://detail.1688.com/offer/67123912.html",
    "quantity": 50,
    "specifications": "Size XL, Black",
    "status": "submitted"
  }
}
```

---

### `GET /procurements/requests`

- **Summary:** List customer's procurement requests, quotations, and statuses (`submitted`, `quoted`, `approved`, `purchased`, `received_at_wh`).
- **Auth:** `Bearer Token`
- **Response (200 OK):**

```json
{
  "status": "success",
  "data": [
    {
      "id": "proc-881",
      "customerId": "HZ-20260816-9012",
      "productUrl": "https://detail.1688.com/offer/67123912.html",
      "quantity": 50,
      "specifications": "Size XL, Black",
      "productCostRmb": 1200,
      "serviceFeeRmb": 100,
      "totalCostRmb": 1300,
      "exchangeRateUsed": 215,
      "totalCostNaira": 279500,
      "status": "quoted"
    }
  ]
}
```

---

### `POST /procurements/requests/{id}/approve`

- **Summary:** Customer approves the quote issued by the procurement team. Automatically deducts `totalCostNaira` from customer's NGN wallet.
- **Auth:** `Bearer Token`
- **Path Parameters:**
  - `id` (string, required): Procurement request ID
- **Response (200 OK):** Procurement request approved and paid.

---

## 6. RMB Currency Exchange & Saved Accounts

### `GET /exchanges/rate`

- **Summary:** Get current active RMB/NGN live exchange rates.
- **Auth:** Public (No token required)
- **Response (200 OK):**

```json
{
  "buyRate": 213,
  "sellRate": 217,
  "platformRate": 215
}
```

---

### Saved Beneficiary Accounts

#### `GET /exchanges/saved-accounts`

- **Summary:** List customer's saved Chinese recipient accounts (Alipay, WeChat Pay, Chinese Bank).
- **Auth:** `Bearer Token`
- **Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": "cfcfb2d4-f950-44f8-bec4-8d57fb9815dd",
      "userId": "usr-1002",
      "label": "Yiwu Supplier",
      "platform": "alipay",
      "accountType": "alipay",
      "accountNumber": "supplier@alipay.cn",
      "accountName": "Guangzhou Trading Co",
      "barcodeUrl": "https://res.cloudinary.com/.../alipay_qr.jpg",
      "isDefault": true,
      "createdAt": "2026-09-24T12:38:36.711Z"
    }
  ]
}
```

---

#### `POST /exchanges/saved-accounts`

- **Summary:** Save a new Chinese beneficiary account for recurring RMB transfers.
- **Auth:** `Bearer Token`
- **Request Body:**

```json
{
  "accountType": "alipay",
  "accountNumber": "supplier@alipay.cn",
  "accountName": "Guangzhou Trading Co",
  "bankName": "Bank of China",
  "label": "Yiwu Supplier",
  "barcodeUrl": "https://res.cloudinary.com/.../alipay_qr.jpg",
  "isDefault": true
}
```

_Note: Both `accountType` and `platform` (`"alipay" | "wechat_pay" | "chinese_bank"`) are supported by the backend._

- **Response (201 Created):** Beneficiary account saved successfully.

---

#### `PATCH /exchanges/saved-accounts/{id}/default`

- **Summary:** Mark a saved RMB receiving account as the customer's default choice.
- **Auth:** `Bearer Token`
- **Path Parameters:**
  - `id` (string, required): Saved account ID
- **Response (200 OK):** Default account updated.

---

#### `DELETE /exchanges/saved-accounts/{id}`

- **Summary:** Remove a saved RMB recipient account.
- **Auth:** `Bearer Token`
- **Path Parameters:**
  - `id` (string, required): Saved account ID
- **Response (200 OK):** Account deleted.

---

### Exchange Requests

#### `POST /exchanges/request` (or `POST /exchanges`)

- **Summary:** Submit a new RMB currency exchange transfer request.
- **Auth:** `Bearer Token`
- **Request Body:**

```json
{
  "amountNaira": 500000,
  "direction": "ngn_to_rmb",
  "rmbDestType": "alipay",
  "rmbDestAccount": "supplier@alipay.cn",
  "rmbDestName": "Guangzhou Trading Co",
  "receivingBarcodeUrl": "https://res.cloudinary.com/.../barcode.jpg",
  "nairaReceiptUrl": "https://res.cloudinary.com/.../deposit_receipt.jpg",
  "saveAccount": false
}
```

- **Response (201 Created):**

```json
{
  "status": "success",
  "data": {
    "id": "exg-302",
    "customerId": "HZ-20260816-9012",
    "amountNaira": 500000,
    "amountRmb": 2325.58,
    "exchangeRate": 215,
    "platformFee": 5000,
    "totalNaira": 505000,
    "status": "pending",
    "escrowBankName": "GTBank",
    "escrowAccountNo": "0123456789",
    "escrowAccountName": "Hamza RMB Trading Escrow Ltd",
    "rmbDestType": "alipay",
    "rmbDestAccount": "supplier@alipay.cn",
    "rmbDestName": "Guangzhou Trading Co"
  }
}
```

---

#### `GET /exchanges/requests`

- **Summary:** List customer's currency exchange orders and processing statuses.
- **Auth:** `Bearer Token`
- **Response (200 OK):** Array of exchange request objects.

---

#### `POST /exchanges/{id}/receipt`

- **Summary:** Upload bank transfer receipt proof for an exchange order paid via bank escrow transfer.
- **Auth:** `Bearer Token`
- **Path Parameters:**
  - `id` (string, required): Exchange request ID
- **Content-Type:** `multipart/form-data`
- **Form Data:**
  - `receipt` (binary file, required): Proof of bank payment
- **Response (200 OK):** Receipt uploaded successfully.

---

## 7. Customer Wallet & Deposits

### `GET /wallet`

- **Summary:** Fetch customer's current NGN wallet balance.
- **Auth:** `Bearer Token`
- **Response (200 OK):**

```json
{
  "status": "success",
  "data": {
    "id": "wlt-1002",
    "userId": "usr-1002",
    "balance": 150000,
    "availableBalance": 150000,
    "currency": "NGN"
  }
}
```

---

### `GET /wallet/transactions`

- **Summary:** List customer's wallet transaction ledger history (credits, debits, orders, top-ups).
- **Auth:** `Bearer Token`
- **Response (200 OK):** Array of wallet transaction entries.

---

### `POST /wallet/deposit`

- **Summary:** Submit proof of manual bank transfer to fund the customer's Naira wallet.
- **Auth:** `Bearer Token`
- **Content-Type:** `multipart/form-data`
- **Form Data:**
  - `amount` (number, required): Transfer amount in NGN (e.g. `250000`)
  - `paymentMethod` (string, optional): Default `"bank_transfer"`
  - `notes` (string, optional): Bank transfer session/reference ID (e.g. `"GTB Ref: 9912048"`)
  - `senderName` (string, optional): Account sender name
  - `sessionId` (string, optional): Bank session reference ID
  - `receipt` (binary file, required): Screenshot/PDF receipt of the transaction
- **Response (201 Created):**

```json
{
  "status": "success",
  "data": {
    "id": "dep-101",
    "userId": "usr-1002",
    "amount": 250000,
    "paymentMethod": "bank_transfer",
    "receiptUrl": "https://res.cloudinary.com/demo/image/upload/receipt.jpg",
    "status": "pending",
    "notes": "GTB Ref: 9912048",
    "createdAt": "2026-09-24T12:06:35.528Z"
  }
}
```

---

### `GET /wallet/deposits`

- **Summary:** List customer's submitted wallet deposit requests and verification statuses (`pending`, `approved`, `rejected`).
- **Auth:** `Bearer Token`
- **Response (200 OK):** Array of customer `WalletDeposit` objects.

---

## 8. Doorstep Delivery & Dispatch (Nigeria)

### `POST /delivery/request`

- **Summary:** Book doorstep delivery in Nigeria for arrived consignments or packages. Generates a secure 4-digit pickup PIN for handoff.
- **Auth:** `Bearer Token`
- **Request Body:**

```json
{
  "consolidationId": "CON-10021",
  "deliveryAddress": "12 Lekki Phase 1, Lagos",
  "recipientName": "Bayo Adebayo",
  "recipientPhone": "+2348011112222"
}
```

- **Response (201 Created):**

```json
{
  "status": "success",
  "data": {
    "id": "del-801",
    "consolidationId": "CON-10021",
    "deliveryAddress": "12 Lekki Phase 1, Lagos",
    "recipientName": "Bayo Adebayo",
    "recipientPhone": "+2348011112222",
    "pickupPin": "4891",
    "status": "requested",
    "createdAt": "2026-09-24T14:00:00.000Z"
  }
}
```

---

### `GET /delivery/deliveries`

- **Summary:** List customer's local delivery requests and dispatch tracking statuses.
- **Auth:** `Bearer Token`
- **Response (200 OK):** Array of customer delivery tasks.

---

## 9. Customer Support Tickets

### `POST /support/tickets`

- **Summary:** Open a support ticket regarding shipments, exchanges, payments, or procurement.
- **Auth:** `Bearer Token`
- **Request Body:**

```json
{
  "subject": "Delay on package SF10928",
  "category": "shipment",
  "description": "Package has been at China hub for 3 days",
  "message": "Package has been at China hub for 3 days",
  "referenceId": "PKG-10029",
  "imageUrl": "https://res.cloudinary.com/demo/image/upload/sample.jpg",
  "attachments": ["https://res.cloudinary.com/demo/image/upload/sample.jpg"]
}
```

- **Category Enum:** `"shipment" | "payment" | "exchange" | "procurement" | "delivery" | "account" | "other"`
- **Response (201 Created):**

```json
{
  "status": "success",
  "data": {
    "id": "tkt-801",
    "ticketNumber": "TCK-20260816-102",
    "userId": "usr-1002",
    "subject": "Delay on package SF10928",
    "category": "shipment",
    "status": "open",
    "priority": "medium",
    "description": "Package has been at China hub for 3 days",
    "createdAt": "2026-09-24T12:00:00.000Z"
  }
}
```

---

### `GET /support/tickets`

- **Summary:** List all customer's support tickets.
- **Auth:** `Bearer Token`
- **Response (200 OK):** Array of support tickets.

---

### `GET /support/tickets/{id}`

- **Summary:** Get ticket details including the threaded message history between the customer and support team.
- **Auth:** `Bearer Token`
- **Path Parameters:**
  - `id` (string, required): Ticket ID
- **Response (200 OK):** Support ticket object with messages array.

---

### `POST /support/tickets/{id}/reply`

- **Summary:** Post a reply message to an open support ticket thread.
- **Auth:** `Bearer Token`
- **Path Parameters:**
  - `id` (string, required): Ticket ID
- **Request Body:**

```json
{
  "message": "Here is the updated supplier packing list."
}
```

- **Response (201 Created):** Reply message appended to ticket thread.

---

## 10. In-App Notifications

### `GET /notifications`

- **Summary:** Fetch user's in-app notification feed (shipment status updates, exchange confirmations, wallet credits).
- **Auth:** `Bearer Token`
- **Response (200 OK):**

```json
[
  {
    "id": "ntf-901",
    "userId": "usr-1002",
    "title": "Package Received in Guangzhou",
    "message": "Package SF10928374 has arrived at China intake hub.",
    "type": "shipment_update",
    "isRead": false,
    "createdAt": "2026-09-24T10:15:00.000Z"
  }
]
```

---

### `PATCH /notifications/read-all`

- **Summary:** Mark all unread customer notifications as read.
- **Auth:** `Bearer Token`
- **Response (200 OK):**

```json
{
  "status": "success",
  "message": "All notifications marked as read"
}
```

---

### `PATCH /notifications/{id}/read`

- **Summary:** Mark a specific notification as read.
- **Auth:** `Bearer Token`
- **Path Parameters:**
  - `id` (string, required): Notification ID (e.g. `ntf-901`)
- **Response (200 OK):** Notification marked read.

---

## 11. AI Assistant (Aisha Chatbot)

### `POST /chat/chat`

- **Summary:** Real-time conversational AI support assistant Aisha. Answering customer inquiries about freight pricing, procedures, and addresses.
- **Auth:** Public (No token required)
- **Request Body:**

```json
{
  "message": "What is your air cargo rate per kg to Lagos?"
}
```

- **Response (200 OK):**

```json
{
  "success": true,
  "response": "Our Air Freight rate is currently ₦12,500/kg with a minimum threshold of 1.0kg. Packages arrive in Lagos within 3 to 5 business days."
}
```

---

## 12. Media & File Uploads

### `POST /upload`

- **Summary:** Upload image, barcode, receipt, or document file directly to Cloudinary storage. Returns public CDN URL.
- **Auth:** `Bearer Token`
- **Content-Type:** `multipart/form-data`
- **Form Data:**
  - `file` (binary file, required)
- **Response (200 OK):**

```json
{
  "success": true,
  "url": "https://res.cloudinary.com/dmkovtnqj/image/upload/v1790253511/logicore/uploads/image_1790253510845.jpg"
}
```

---

## 13. Data Models & Schema Reference

### `User`

```json
{
  "id": "usr-1002",
  "customerId": "HZ-20260816-9012",
  "firstName": "John",
  "lastName": "Doe",
  "email": "customer@example.com",
  "phone": "+2348099999999",
  "role": "customer",
  "isVerified": true,
  "photo": "https://res.cloudinary.com/demo/image/upload/avatar.jpg"
}
```

### `Package`

```json
{
  "id": "pkg-10029",
  "trackingNumber": "SF10928374",
  "customerId": "HZ-20260816-9012",
  "customerName": "John Doe",
  "courierName": "SF Express",
  "declaredValueUsd": 150,
  "weightKg": 4.5,
  "cbm": 0.024,
  "status": "received_cn",
  "photos": ["https://res.cloudinary.com/.../img1.jpg"],
  "receivedDate": "2026-08-16T10:00:00.000Z"
}
```

### `Consolidation`

```json
{
  "id": "con-5001",
  "consolidationId": "CON-10021",
  "customerId": "HZ-20260816-9012",
  "shippingMethod": "air",
  "destinationWarehouse": "lagos",
  "paymentMethod": "wallet",
  "totalWeightKg": 12.5,
  "totalCbm": 0.08,
  "shippingFee": 125,
  "status": "ready_to_batch"
}
```

### `ProcurementRequest`

```json
{
  "id": "proc-881",
  "customerId": "HZ-20260816-9012",
  "productUrl": "https://detail.1688.com/offer/67123912.html",
  "quantity": 50,
  "specifications": "Size XL, Black",
  "productCostRmb": 1200,
  "serviceFeeRmb": 100,
  "totalCostRmb": 1300,
  "exchangeRateUsed": 215,
  "totalCostNaira": 279500,
  "status": "quoted"
}
```

### `ExchangeRequest`

```json
{
  "id": "exg-302",
  "customerId": "HZ-20260816-9012",
  "amountNaira": 500000,
  "amountRmb": 2325.58,
  "exchangeRate": 215,
  "platformFee": 5000,
  "totalNaira": 505000,
  "status": "pending",
  "rmbDestType": "alipay",
  "rmbDestAccount": "supplier@alipay.cn",
  "rmbDestName": "Guangzhou Trading Co"
}
```

### `SavedExchangeAccount`

```json
{
  "id": "acc-401",
  "userId": "usr-1002",
  "accountType": "alipay",
  "accountNumber": "supplier@alipay.cn",
  "accountName": "Guangzhou Trading Co",
  "bankName": "Bank of China",
  "isDefault": true
}
```

### `Wallet` & `WalletDeposit`

```json
{
  "wallet": {
    "id": "wlt-1002",
    "userId": "usr-1002",
    "balance": 150000,
    "availableBalance": 150000,
    "currency": "NGN"
  },
  "deposit": {
    "id": "dep-101",
    "userId": "usr-1002",
    "amount": 250000,
    "paymentMethod": "bank_transfer",
    "receiptUrl": "https://res.cloudinary.com/demo/image/upload/receipt.jpg",
    "status": "pending",
    "notes": "GTB Deposit Ref 88219",
    "createdAt": "2026-09-24T12:00:00.000Z"
  }
}
```
