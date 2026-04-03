# PBL5 Backend (Spring Boot)

Backend API cho hệ thống phân loại trái cây bằng AI, gồm:
- Xác thực người dùng bằng JWT
- Quản lý hệ thống/máy phân loại
- Nhận ảnh từ thiết bị qua WebSocket
- Gọi AI service qua TCP để phân loại
- Điều khiển thiết bị qua WebSocket
- Thống kê detections và quản lý notifications

## 1) Công nghệ sử dụng

- Java 21
- Spring Boot 4.0.3
- Spring Web MVC
- Spring Security (JWT)
- Spring Data JPA (Hibernate)
- PostgreSQL
- WebSocket
- Maven Wrapper (`mvnw`, `mvnw.cmd`)

## 2) Cấu trúc project

```text
src/main/java/com/ice/pbl5
├─ Config/                  # Security, JWT filter, async, websocket, static resource
├─ Controller/              # REST endpoints
├─ DTO/Request, DTO/Response
├─ Entity/                  # JPA entities
├─ Enum/
├─ Exception/
├─ Mapper/
├─ Repository/
├─ Service/                 # Business logic + AI/WebSocket orchestration
└─ Util/
src/main/resources
└─ application.properties
```

## 3) Luồng xử lý chính

### 3.1 Luồng nhận ảnh và phân loại
1. Thiết bị kết nối `ws://<host>:8080/ws/device`
2. Thiết bị gửi message `type=register` kèm `systemId`
3. Thiết bị gửi message `type=predict` kèm `requestId`, `systemId`, `imageBase64`
4. Backend:
   - Decode ảnh base64
   - Lưu vào `uploads/images/ws/<systemId>/...`
   - Tạo bản ghi detection trạng thái `RECEIVED`
   - Trả ACK WebSocket: `type=accepted`, `status=processing`
5. Async worker:
   - Đọc ảnh từ disk
   - Gửi bytes sang AI service qua TCP (`ai.tcp.host`, `ai.tcp.port`)
   - Nhận kết quả phân loại, cập nhật detection
   - Gửi kết quả về thiết bị qua WebSocket (`type=result`)
   - Ghi lịch sử lệnh (`command_history`)
   - Tạo notification nếu lỗi/độ tin cậy thấp

### 3.2 Luồng điều khiển hệ thống
- API `POST /api/system/control` nhận `action: START | PAUSE | STOP`
- Backend map sang lệnh thiết bị:
  - `START` -> `START_CONVEYOR`
  - `PAUSE` -> `PAUSE_CONVEYOR`
  - `STOP` -> `STOP_CONVEYOR`
- Lệnh được gửi qua WebSocket tới Raspberry Pi (`type=command`)

## 4) Cấu hình

File mặc định: `src/main/resources/application.properties`

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/pbl5
spring.datasource.username=postgres
spring.datasource.password=123456

jwt.secret=...
jwt.expiration=86400000

server.address=0.0.0.0
server.port=8080

app.base-url=http://localhost:8080

ai.tcp.host=127.0.0.1
ai.tcp.port=5000
ai.tcp.connect-timeout-ms=3000
ai.tcp.read-timeout-ms=10000
```

Khuyến nghị:
- Không commit secret/password thật
- Override bằng biến môi trường hoặc profile riêng (`application-dev.properties`)

## 5) Chạy local

### 5.1 Yêu cầu
- JDK 21
- PostgreSQL đang chạy
- Database `pbl5` tồn tại

Ví dụ tạo DB:

```sql
CREATE DATABASE pbl5;
```

### 5.2 Chạy ứng dụng

Windows:

```bash
.\mvnw.cmd spring-boot:run
```

Linux/macOS:

```bash
./mvnw spring-boot:run
```

Ứng dụng chạy tại:
- API: `http://localhost:8080`
- WebSocket device: `ws://localhost:8080/ws/device`

## 6) Authentication và Security

- Public endpoints:
  - `POST /api/auth/register`
  - `POST /api/auth/login`
  - `/ws/**`
- Tất cả endpoint còn lại yêu cầu JWT Bearer token
- Header:

```http
Authorization: Bearer <access_token>
```

Response chuẩn REST dùng `ApiResponse<T>`:

```json
{
  "success": true,
  "message": "....",
  "data": {}
}
```

## 7) API chính

### 7.1 Auth
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`

### 7.2 Systems
- `GET /api/systems`
- `POST /api/systems/register?name=...&description=...&location=...`

### 7.3 System status/control
- `GET /api/system/status?systemId=<uuid>`
- `GET /api/system/devices?systemId=<uuid>`
- `POST /api/system/control?systemId=<uuid>`
  - body:
  ```json
  { "action": "START" }
  ```
- `GET /api/system/control-state?systemId=<uuid>`

### 7.4 Detections
- `GET /api/detections/latest?systemId=<uuid>`
- `GET /api/detections/recent?systemId=<uuid>&limit=10`
- `GET /api/detections/count-by-fruit?systemId=<uuid>&from=<iso>&to=<iso>`
- `GET /api/detections/statistics-summary?systemId=<uuid>&from=<iso>&to=<iso>`
- `GET /api/detections/statistics-daily?systemId=<uuid>&from=<iso>&to=<iso>`
- `GET /api/detections?systemId=<uuid>&page=0&size=10&fruitType=...&status=COMPLETED&from=<iso>&to=<iso>`
- `GET /api/detections/{id}?systemId=<uuid>`

### 7.5 Notifications
- `GET /api/notifications?systemId=<uuid>&level=WARNING&page=0&size=10`
- `PATCH /api/notifications/{id}/read?systemId=<uuid>`
- `PATCH /api/notifications/read-all?systemId=<uuid>`
- `GET /api/notifications/unread-count?systemId=<uuid>`

## 8) WebSocket protocol (`/ws/device`)

### 8.1 Thiết bị -> Backend

Register:

```json
{
  "type": "register",
  "systemId": "11111111-1111-1111-1111-111111111111"
}
```

Predict:

```json
{
  "type": "predict",
  "systemId": "11111111-1111-1111-1111-111111111111",
  "requestId": "req-001",
  "imageBase64": "data:image/jpeg;base64,..."
}
```

### 8.2 Backend -> Thiết bị

Accepted:

```json
{
  "type": "accepted",
  "systemId": "11111111-1111-1111-1111-111111111111",
  "requestId": "req-001",
  "status": "processing"
}
```

Result:

```json
{
  "type": "result",
  "systemId": "11111111-1111-1111-1111-111111111111",
  "requestId": "req-001",
  "fruitType": "APPLE",
  "confidence": 0.92,
  "targetBin": "BIN_1"
}
```

Control command:

```json
{
  "type": "command",
  "systemId": "11111111-1111-1111-1111-111111111111",
  "command": "START_CONVEYOR"
}
```

Error:

```json
{
  "type": "error",
  "systemId": "11111111-1111-1111-1111-111111111111",
  "requestId": "req-001",
  "status": "failed",
  "message": "..."
}
```

## 9) AI TCP protocol

Backend gửi cho AI:
1. `int` 4 byte: kích thước ảnh
2. `byte[]`: dữ liệu ảnh

AI trả về:
- `boolean success`
- Nếu `false`: `UTF errorMessage`
- Nếu `true`: `UTF fruitType` + `double confidence`

## 10) Mô hình dữ liệu (bảng chính)

- `users`
- `systems`
- `detections`
- `command_history`
- `notifications`
- `device_status`
- `system_logs`
- `system_control_history`

## 11) Trạng thái/enum

- `DetectionStatus`: `RECEIVED`, `PROCESSING`, `COMPLETED`, `FAILED`
- `SystemStatus`: `RUNNING`, `PAUSED`, `STOPPED`, `ERROR`, `IDLE`
- `SystemAction`: `START`, `PAUSE`, `STOP`
- `NotificationLevel`: `INFO`, `WARNING`, `ERROR`
- `CommandType`: `SORT`, `START_CONVEYOR`, `PAUSE_CONVEYOR`, `STOP_CONVEYOR`
- `CommandStatus`: `SENT`, `ACK_SUCCESS`, `ACK_FAILED`, `ERROR`
- `DeviceState`: `ONLINE`, `OFFLINE`, `ERROR`
- `UserStatus`: `ACTIVE`, `INACTIVE`

## 12) Testing

Hiện tại có 1 test `contextLoads`.

Khi chạy:

```bash
.\mvnw.cmd test
```

test fail nếu PostgreSQL chưa có database `pbl5` (lỗi thực tế: `FATAL: database "pbl5" does not exist`).
