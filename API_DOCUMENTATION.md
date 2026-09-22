# Logicore / Hamza RMB Logistics & Mobile API Documentation

> **Live API Base URL:** `https://hamza-rmb.onrender.com/api/v1`  
> **Swagger UI:** `https://hamza-rmb.onrender.com/api-docs/`  
> **Local Dev Base URL:** `http://localhost:5000/api/v1`  
> **OpenAPI Specification Version:** `3.0.0`

---

## 1. Global Overview & Authentication

### Security Scheme
- **Type:** HTTP Bearer Authentication (`bearerAuth`)
- **Header:** `Authorization: Bearer <JWT_TOKEN>`
- **Obtained via:** `/auth/login`, `/auth/register`, or `/auth/setup-super-admin`

### Standard Response Schemas

#### Success Response Envelope (`ApiResponse`)
```json
{
  "status": "success",
  "message": "Operation completed successfully",
  "data": {}
}
```

#### Error Response Envelope (`ErrorResponse`)
```json
{
  "status": "error",
  "message": "Invalid parameter or unauthorized access"
}
```

---

## 2. Public Metadata & Pricing

### `GET /banners`
* **Summary:** Fetch active sliding promotional banners for mobile app home screen.
* **Auth:** Public (No token required)
* **Response (200 OK):**
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

### `GET /banners/admin`
* **Summary:** Admin list all banners (including active and inactive).
* **Auth:** `Bearer Token` (Admin)
* **Response (200 OK):** Array of all banner objects.

---

### `GET /settings`
* **Summary:** Global system metadata, live exchange rates, freight pricing, and company escrow details.
* **Auth:** Public (No token required)
* **Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "cnyExchangeRate": 215,
    "usdExchangeRate": 1550,
    "airFreightRatePerKg": 12500,
    "seaFreightRatePerCbm": 450000,
    "seaFreightRatePerKg": 3500,
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

### `GET /delivery/vehicles`
* **Summary:** Fetch active doorstep delivery vehicle fleet and per-kilometer rates.
* **Auth:** Public (No token required)
* **Response (200 OK):**
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

## 3. Authentication & User Profile

### `POST /auth/setup-super-admin`
* **Summary:** One-time initial Super Admin setup endpoint. Permanently locks itself (returns 403 Forbidden) once created.
* **Auth:** Public
* **Request Body:**
```json
{
  "firstName": "Hamza",
  "lastName": "Admin",
  "email": "admin@hamzarmb.com",
  "password": "SecurePassword123!",
  "phone": "+2348012345678"
}
```
* **Responses:**
  * `201 Created`: Super Admin onboarded successfully & token issued.
  * `403 Forbidden`: Initialization locked: Super Admin already exists.

---

### `POST /auth/register`
* **Summary:** Register a new customer account.
* **Auth:** Public
* **Request Body:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "password": "Password123!",
  "phone": "+2348012345678"
}
```
* **Responses:**
  * `201 Created`: Registration successful.
  * `400 Bad Request`: Validation or duplicate email error.

---

### `POST /auth/login`
* **Summary:** Authenticate customer or staff member.
* **Auth:** Public
* **Request Body:**
```json
{
  "email": "admin@hamzarmb.com",
  "password": "admin123"
}
```
* **Responses:**
  * `200 OK`: Login successful (returns auth token & user object).
  * `401 Unauthorized`: Invalid credentials.

---

### `POST /auth/verify-otp`
* **Summary:** Verify email registration OTP code.
* **Auth:** `Bearer Token`
* **Request Body:**
```json
{
  "otp": "123456"
}
```
* **Response (200 OK):** OTP verified successfully.

---

### `POST /auth/resend-otp`
* **Summary:** Resend email registration OTP code.
* **Auth:** `Bearer Token`
* **Response (200 OK):** New OTP dispatched to email.

---

### `GET /auth/me`
* **Summary:** Get current authenticated user profile.
* **Auth:** `Bearer Token`
* **Response (200 OK):**
```json
{
  "status": "success",
  "data": {
    "id": "usr-1002",
    "customerId": "HZ-20260816-9012",
    "firstName": "Hamza",
    "lastName": "RMB",
    "email": "admin@hamzarmb.com",
    "phone": "+2348099999999",
    "role": "super_admin",
    "isVerified": true
  }
}
```

---

## 4. Shipments & Warehouse

### `POST /shipments/pre-alert`
* **Summary:** Submit customer package pre-alert before arrival at China hub.
* **Auth:** `Bearer Token`
* **Request Body:**
```json
{
  "trackingNumber": "SF10928374",
  "courierName": "SF Express",
  "declaredValueUsd": 150,
  "itemDescription": "Designer Handbags"
}
```
* **Response (201 Created):** Pre-alert created.

---

### `GET /shipments/packages`
* **Summary:** List user packages (or warehouse packages for staff).
* **Auth:** `Bearer Token`
* **Response (200 OK):**
```json
{
  "status": "success",
  "data": [
    {
      "id": "pkg-10029",
      "trackingNumber": "SF10928374",
      "customerId": "HZ-20260816-9012",
      "customerName": "Hamza RMB",
      "courierName": "SF Express",
      "declaredValueUsd": 150,
      "weightKg": 4.5,
      "cbm": 0.024,
      "status": "received_cn",
      "photos": [
        "https://res.cloudinary.com/.../img1.jpg"
      ],
      "receivedDate": "2026-08-16T10:00:00.000Z"
    }
  ]
}
```

---

### `POST /shipments/packages/scan`
* **Summary:** Scan package at warehouse intake (China Hub) to record dimensions/weight.
* **Auth:** `Bearer Token` (Warehouse Staff)
* **Request Body:**
```json
{
  "packageId": "pkg-10029",
  "weightKg": 4.5,
  "cbm": 0.024,
  "length": 30,
  "width": 20,
  "height": 40,
  "photos": [
    "https://res.cloudinary.com/.../pkg.jpg"
  ]
}
```
* **Response (200 OK):** Package intake status updated to `received_cn`.

---

### `POST /shipments/consolidations`
* **Summary:** Create package consolidation request to bundle items into one shipment.
* **Auth:** `Bearer Token`
* **Request Body:**
```json
{
  "packageIds": [
    "pkg-1",
    "pkg-2"
  ],
  "shippingMethod": "air",
  "destinationWarehouse": "lagos",
  "paymentMethod": "wallet"
}
```
* **Response (201 Created):**
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
* **Summary:** List consolidation shipments.
* **Auth:** `Bearer Token`
* **Response (200 OK):** Array of consolidation objects.

---

### `POST /shipments/batches`
* **Summary:** Build Master Shipping Batch (Air / Sea) from consolidated parcels.
* **Auth:** `Bearer Token` (Admin / Warehouse Staff)
* **Request Body:**
```json
{
  "masterTrackingId": "HZ-BATCH-AIR-20260816-102",
  "carrierName": "Ethiopian Cargo",
  "flightVoyageNo": "ET-3801",
  "shippingType": "air",
  "consolidationIds": [
    "con-5001",
    "con-5002"
  ]
}
```
* **Response (201 Created):** Master batch created.

---

### `GET /shipments/batches`
* **Summary:** List master batches.
* **Auth:** `Bearer Token`
* **Response (200 OK):** List of master batch objects.

---

### `GET /shipments/tracking/{id}`
* **Summary:** Public track-and-trace by tracking number, consolidation ID, or master batch ID.
* **Auth:** Public (No token required)
* **Path Parameters:**
  * `id` (string, required): e.g. `HZ-CN-90812` or `SF10928374`
* **Response (200 OK):** Detailed shipment status timeline and events.

---

## 5. Buy-For-Me Procurement

### `POST /procurements/request`
* **Summary:** Submit a 1688 / Taobao Buy-For-Me procurement request.
* **Auth:** `Bearer Token`
* **Request Body:**
```json
{
  "productUrl": "https://detail.1688.com/offer/67123912.html",
  "quantity": 50,
  "specifications": "Size XL, Black",
  "notes": "Please confirm stock"
}
```
* **Response (201 Created):**
```json
{
  "status": "success",
  "data": {
    "id": "proc-881",
    "customerId": "HZ-20260816-9012",
    "productUrl": "https://detail.1688.com/offer/67123912.html",
    "quantity": 50,
    "specifications": "Size XL, Black",
    "status": "pending_quote"
  }
}
```

---

### `GET /procurements/requests`
* **Summary:** List procurement requests.
* **Auth:** `Bearer Token`
* **Response (200 OK):** List of procurement request records.

---

### `POST /procurements/requests/{id}/quote`
* **Summary:** Admin issue quote for procurement request.
* **Auth:** `Bearer Token` (Admin)
* **Path Parameters:**
  * `id` (string, required): Procurement request ID
* **Request Body:**
```json
{
  "productCostRmb": 1200,
  "serviceFeeRmb": 100,
  "supplierName": "Foshan Factory Direct",
  "exchangeRateUsed": 215
}
```
* **Response (200 OK):** Quote issued and pricing in RMB/Naira calculated.

---

### `POST /procurements/requests/{id}/approve`
* **Summary:** Customer approves procurement quote and automatically deducts funds from wallet.
* **Auth:** `Bearer Token`
* **Path Parameters:**
  * `id` (string, required): Procurement request ID
* **Response (200 OK):** Procurement request approved and paid.

---

### `PATCH /procurements/requests/{id}/status`
* **Summary:** Admin update procurement request status.
* **Auth:** `Bearer Token` (Admin)
* **Path Parameters:**
  * `id` (string, required): Procurement request ID
* **Request Body:**
```json
{
  "status": "purchased"
}
```
* **Response (200 OK):** Status updated.

---

## 6. RMB Currency Exchange

### `GET /exchanges/rate`
* **Summary:** Get current active RMB exchange rates.
* **Auth:** Public (No token required)
* **Response (200 OK):**
```json
{
  "buyRate": 213,
  "sellRate": 217,
  "platformRate": 215
}
```

---

### `PATCH /exchanges/rate`
* **Summary:** Admin update active RMB exchange rates.
* **Auth:** `Bearer Token` (Admin)
* **Request Body:**
```json
{
  "buyRate": 213,
  "sellRate": 217,
  "platformRate": 215
}
```
* **Response (200 OK):** Exchange rates updated.

---

### `POST /exchanges/request`
* **Summary:** Submit RMB currency exchange request to transfer funds to a Chinese recipient.
* **Auth:** `Bearer Token`
* **Request Body:**
```json
{
  "amountNaira": 500000,
  "rmbDestType": "alipay",
  "rmbDestAccount": "supplier@alipay.cn",
  "rmbDestName": "Guangzhou Trading Co"
}
```
* **Response (201 Created):**
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
    "rmbDestType": "alipay",
    "rmbDestAccount": "supplier@alipay.cn",
    "rmbDestName": "Guangzhou Trading Co"
  }
}
```

---

### `GET /exchanges/requests`
* **Summary:** List currency exchange requests.
* **Auth:** `Bearer Token`
* **Response (200 OK):** List of exchange requests.

---

### `POST /exchanges/requests/{id}/verify-naira`
* **Summary:** Admin verify Naira escrow payment deposit.
* **Auth:** `Bearer Token` (Admin / Finance)
* **Path Parameters:**
  * `id` (string, required): Exchange request ID
* **Response (200 OK):** Naira escrow payment confirmed.

---

### `POST /exchanges/requests/{id}/release-rmb`
* **Summary:** Admin mark RMB released to the supplier's Chinese account.
* **Auth:** `Bearer Token` (Admin / Finance)
* **Path Parameters:**
  * `id` (string, required): Exchange request ID
* **Response (200 OK):** Exchange request completed.

---

## 7. Wallet & Billing

### `GET /wallet`
* **Summary:** Get customer wallet balance and details.
* **Auth:** `Bearer Token`
* **Response (200 OK):**
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

### `POST /wallet/topup`
* **Summary:** Top up wallet balance.
* **Auth:** `Bearer Token`
* **Request Body:**
```json
{
  "amount": 100000,
  "paymentMethod": "card",
  "reference": "PAY-891234"
}
```
* **Response (200 OK):** Wallet credited successfully.

---

### `GET /wallet/transactions`
* **Summary:** List wallet transaction history ledger.
* **Auth:** `Bearer Token`
* **Response (200 OK):** Transaction ledger entries array.

---

## 8. Local Delivery & Doorstep Dispatch (Nigeria)

### `POST /delivery/request`
* **Summary:** Request doorstep delivery in Nigeria for arrived consignments.
* **Auth:** `Bearer Token`
* **Request Body:**
```json
{
  "consolidationId": "CON-10021",
  "deliveryAddress": "12 Lekki Phase 1, Lagos",
  "recipientName": "Bayo Adebayo",
  "recipientPhone": "+2348011112222"
}
```
* **Response (201 Created):** Delivery request created with 4-digit pickup PIN for handoff.

---

### `GET /delivery/deliveries`
* **Summary:** List local deliveries.
* **Auth:** `Bearer Token`
* **Response (200 OK):** List of local delivery jobs.

---

### `PATCH /delivery/deliveries/{id}/dispatch`
* **Summary:** Dispatch delivery task to driver.
* **Auth:** `Bearer Token` (Admin / Dispatcher)
* **Path Parameters:**
  * `id` (string, required): Delivery ID
* **Request Body:**
```json
{
  "driverName": "Musa Driver",
  "driverPhone": "+2348033334444"
}
```
* **Response (200 OK):** Delivery assigned to driver.

---

### `POST /delivery/deliveries/{id}/verify-pin`
* **Summary:** Driver verify 4-digit customer pickup PIN upon delivery handoff.
* **Auth:** `Bearer Token`
* **Path Parameters:**
  * `id` (string, required): Delivery ID
* **Request Body:**
```json
{
  "pickupPin": "4891"
}
```
* **Response (200 OK):** PIN verified & delivery marked completed.

---

## 9. Staff & System Administration

### `GET /admin/stats`
* **Summary:** Get admin dashboard system overview metrics & KPIs.
* **Auth:** `Bearer Token` (Admin)
* **Response (200 OK):** Dashboard stats object.

---

### `GET /admin/users`
* **Summary:** List all system users and staff accounts.
* **Auth:** `Bearer Token` (Admin)
* **Response (200 OK):** List of `User` objects.

---

### `POST /admin/staff`
* **Summary:** Super Admin onboard new staff member.
* **Auth:** `Bearer Token` (Super Admin)
* **Request Body:**
```json
{
  "firstName": "Jane",
  "lastName": "Doe",
  "email": "jane.doe@logicore.com",
  "phone": "+2348012345678",
  "role": "warehouse_cn",
  "password": "Logistics2026!"
}
```
* **Response (201 Created):** Staff account onboarded successfully.

---

### `PATCH /admin/users/{id}`
* **Summary:** Update user profile, status, or role permissions.
* **Auth:** `Bearer Token` (Admin)
* **Path Parameters:**
  * `id` (string, required): User ID
* **Request Body:**
```json
{
  "role": "finance",
  "isVerified": true
}
```
* **Response (200 OK):** User updated.

---

### `DELETE /admin/users/{id}`
* **Summary:** Super Admin remove staff member account.
* **Auth:** `Bearer Token` (Super Admin)
* **Path Parameters:**
  * `id` (string, required): User ID
* **Response (200 OK):** User account removed.

---

### `GET /admin/activity-logs`
* **Summary:** Fetch system audit trail & activity logs.
* **Auth:** `Bearer Token` (Admin)
* **Query Parameters:**
  * `module` (string, optional): Filter by module (`warehouse`, `staff`, `finance`, etc.)
  * `search` (string, optional): Search query (e.g. `Hamza`)
* **Response (200 OK):** List of `ActivityLog` objects.

---

## 10. Support Tickets

### `POST /support/tickets`
* **Summary:** Create support ticket.
* **Auth:** `Bearer Token`
* **Request Body:**
```json
{
  "subject": "Delay on package SF10928",
  "category": "shipping",
  "description": "Package has been at China hub for 3 days"
}
```
* **Response (201 Created):** Support ticket created.

---

### `GET /support/tickets`
* **Summary:** List support tickets.
* **Auth:** `Bearer Token`
* **Response (200 OK):** List of tickets.

---

### `GET /support/tickets/{id}`
* **Summary:** Get ticket details with thread messages.
* **Auth:** `Bearer Token`
* **Path Parameters:**
  * `id` (string, required): Ticket ID
* **Response (200 OK):** Ticket object with messages array.

---

### `POST /support/tickets/{id}/messages`
* **Summary:** Reply to support ticket thread.
* **Auth:** `Bearer Token`
* **Path Parameters:**
  * `id` (string, required): Ticket ID
* **Request Body:**
```json
{
  "message": "Your package is scheduled for departure tomorrow morning."
}
```
* **Response (201 Created):** Reply message sent.

---

## 11. Media Uploads

### `POST /upload`
* **Summary:** Upload image file to Cloudinary storage.
* **Auth:** `Bearer Token`
* **Content-Type:** `multipart/form-data`
* **Form Data:**
  * `file` (binary file, required)
* **Response (200 OK):** Returns Cloudinary image URL.
