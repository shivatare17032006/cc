# Campus Canteen Backend

## Setup
1. Copy `.env.example` to `.env`.
2. Update `MONGODB_URI` and `JWT_SECRET`.
3. Install dependencies:
   npm install
4. Run server:
   npm run dev

## API
- `GET /api/health`

### Auth
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me` (Bearer token)

### Menu
- `GET /api/menu`
- `POST /api/menu`

### Cart (Bearer token)
- `GET /api/cart`
- `POST /api/cart/items`
- `PATCH /api/cart/items/:menuItemId`
- `DELETE /api/cart/items/:menuItemId`
- `DELETE /api/cart`

### Orders (Bearer token)
- `POST /api/orders` (places order from cart)
- `GET /api/orders`

## Quick test flow
1. Register user via `/api/auth/register`
2. Save returned token
3. Create menu item via `/api/menu`
4. Add item to cart via `/api/cart/items` with `Authorization: Bearer <token>`
5. Place order via `/api/orders`

## Mobile testing on same Wi-Fi
Start the backend on your PC, then use your PC's LAN IP from the phone, not `localhost`.
For example, if your PC IP is `192.168.1.10`, the API base URL is:
`http://192.168.1.10:5000/api`

Build and run on a phone with:

`flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000/api`

Run on phone

If the phone is an iPhone, HTTP is allowed by the app now, but you still need the correct LAN IP.

Run on PC web
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5000/api

Build APK for phone
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.10:5000/api