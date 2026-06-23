# 07. Role Business Responsibilities

## CUSTOMER

- View product listings.
- Search and filter products by brand, category, sport, price, and color.
- View product details.
- Register, login, and logout.
- Manage personal profile.
- Manage shipping addresses.
- Add products to cart.
- Update item quantity or remove items from cart.
- Checkout and create orders.
- Select payment method.
- View own order history.
- View order tracking.
- Confirm received when delivery is successful.
- Chat with shop/admin for support.

## SHOP_STAFF

- View orders that need shop processing.
- View order details.
- Confirm orders: `PENDING -> CONFIRMED`.
- Prepare and pack orders: `CONFIRMED -> PACKING`.
- Handover orders to delivery staff: `PACKING -> SHIPPED`.
- Check customer information, shipping address, and order items.
- Cannot update detailed delivery progress.
- Cannot manage the whole system unless granted admin permission.

## DELIVERY_STAFF / SHIPPER

- View orders handed over for delivery.
- View delivery order details.
- Update delivery status:
  - `WAITING_PICKUP`
  - `PICKED_UP`
  - `IN_TRANSIT`
  - `OUT_FOR_DELIVERY`
  - `DELIVERED`
  - `FAILED`
  - `RETURNED`
- Cannot confirm or pack orders.
- Cannot manage products, users, or the admin dashboard.

## ADMIN

- Manage the whole system.
- Manage users and roles.
- Manage brands.
- Manage categories.
- Manage sports.
- Manage sizes and colors.
- Manage products.
- Manage product variants, inventory, and images.
- View all orders.
- Perform all shop staff order-processing actions.
- Monitor delivery status.
- Manage chat/customer support.
- View admin dashboard reports.
- View total revenue by:
  - Day
  - Week
  - Month
  - Quarter
  - Year
- View total orders, pending/completed orders, total customers, and total products.
- Handle operational exceptions such as cancelling orders, correcting status, and checking process errors.

## GUEST

- View home page.
- View product listings.
- Search and filter products.
- View product details.
- Register an account.
- Login.
- Chat for support if guest chat is allowed.
- Cannot checkout before login.
