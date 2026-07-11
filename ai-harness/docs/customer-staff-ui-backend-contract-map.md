# Customer & Staff Mobile UI Backend Contract Map

This map keeps Customer and Delivery Staff UI aligned with the existing Spring Boot backend without changing API shape or business logic.

## Role UI Rules

- Customer: black, white, light gray, bordeaux accent `#7F1D2D`.
- Delivery Staff: operational blue `#2563EB` for active tabs, CTA, progress and status emphasis.
- Empty states must be useful and calm; if backend returns an empty list, keep the action visible and do not imply a UI failure.

## Customer Flow

- Home and search use `GET /api/navigation/main`, `GET /api/products`, `GET /api/products/categories`, `GET /api/products/brands`, and `GET /api/collections`.
- Product detail uses `GET /api/products/{id}` and adds to cart through `POST /api/cart/add`.
- Cart uses `GET /api/cart`, `PUT /api/cart/items/{itemId}`, `DELETE /api/cart/items/{itemId}`, and `DELETE /api/cart/clear`.
- Checkout uses `GET /api/cart`, `GET /api/user/addresses`, and `POST /api/orders/checkout`.
- Address book uses `GET/POST/PUT/DELETE /api/user/addresses` and `PATCH /api/user/addresses/{id}/default`.
- Orders use `GET /api/orders`, detail is derived from the user order list, and customer status updates use `PATCH /api/orders/{id}/orderStatus`.
- Profile uses `GET /api/user/profile/me`, `PUT /api/user/profile/me`, and logout uses `POST /api/auth/logout`.
- Support chat uses `/api/chat/send`, `/api/chat/rooms`, `/api/chat/rooms/me`, and `/api/chat/rooms/{roomId}/messages`.

## Delivery Staff Flow

- Dashboard and assigned orders use `GET /api/orders/admin`.
- Order status detail uses `GET /api/orders/admin/{id}` through the mobile repository lookup.
- Delivery start/completion uses `PATCH /api/orders/{id}/status` with existing status values.
- Account uses `GET /api/user/profile/me` and logout uses `POST /api/auth/logout`.

## Browser Smoke Expectations

- Route must not redirect to login after a successful role login.
- Flutter must mount a visible `flt-glass-pane` or canvas.
- Screenshot should not be visually blank.
- Console must not contain Flutter runtime errors such as `RenderFlex overflow`, `Unexpected null value`, `Assertion failed`, or `There is nothing to pop`.
