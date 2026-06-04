# 06. Acceptance Checklist

## Project Setup

- [ ] Frontend runs locally.
- [ ] Backend runs locally.
- [ ] Database connects successfully.
- [ ] Environment variables documented.
- [ ] README has run instructions.

## Auth

- [ ] Customer can register.
- [ ] Customer can login.
- [ ] Customer can logout.
- [ ] Forgot password flow works or has demo fallback.
- [ ] Reset password flow works or has demo fallback.
- [ ] Admin can access admin dashboard.
- [ ] Customer cannot access admin dashboard.
- [ ] Shipper cannot access product/user management.

## Catalog

- [ ] Admin can create brand.
- [ ] Admin can update brand.
- [ ] Admin can create category.
- [ ] Admin can create sport.
- [ ] Admin can create size/color.
- [ ] Storefront uses catalog data in navigation/filter.

## Product

- [ ] Admin can create product.
- [ ] Admin can edit product.
- [ ] Admin can add images.
- [ ] Admin can add variants.
- [ ] Product listing displays products.
- [ ] Product detail displays product information.
- [ ] Product variant selection works.

## Search & Filter

- [ ] Search by product name works.
- [ ] Filter by brand works.
- [ ] Filter by category works.
- [ ] Filter by sport works.
- [ ] Filter by price works.
- [ ] Filter by color works.
- [ ] Sort works.
- [ ] Pagination works.

## Cart

- [ ] Add to cart works.
- [ ] Cart badge updates.
- [ ] Cart sheet displays items.
- [ ] Increase quantity works.
- [ ] Decrease quantity works.
- [ ] Remove item works.
- [ ] Total price is correct.

## Checkout & Payment

- [ ] Checkout requires login.
- [ ] Customer can select address.
- [ ] Customer can add address during checkout.
- [ ] Customer can choose COD.
- [ ] Customer can choose online payment if implemented.
- [ ] Order is created from cart.
- [ ] Order stores item price snapshot.
- [ ] Order stores shipping address snapshot.
- [ ] Cart clears after successful order.

## Customer Order Tracking

- [ ] Customer can see own orders.
- [ ] Customer cannot see other users' orders.
- [ ] Order card displays status badge.
- [ ] Order card displays tracking timeline.
- [ ] Order detail modal displays tracking timeline.
- [ ] PENDING status displays correctly.
- [ ] PAID status displays correctly.
- [ ] SHIPPING status displays correctly.
- [ ] DELIVERED status displays correctly.
- [ ] COMPLETED status displays correctly.
- [ ] CANCELLED status displays correctly.
- [ ] Customer can confirm received when status is DELIVERED.

## Admin Order Management

- [ ] Admin can see all orders.
- [ ] Admin can open order detail.
- [ ] Admin can update status.
- [ ] Invalid status transitions are blocked.
- [ ] Customer tracking updates after admin changes status.

## Shipper

- [ ] Shipper can login.
- [ ] Shipper sees order module only.
- [ ] Shipper can see delivery orders.
- [ ] Shipper can update DELIVERED.
- [ ] Shipper can update CANCELLED.

## Chat

- [ ] Customer can open chat.
- [ ] Customer can send message.
- [ ] Admin can see chat room.
- [ ] Admin can reply.
- [ ] Message history is preserved.

## Reports

- [ ] Dashboard shows total revenue.
- [ ] Dashboard shows total orders.
- [ ] Dashboard shows pending orders.
- [ ] Dashboard shows total customers.
- [ ] Dashboard shows total products.
- [ ] Dashboard does not crash when data is empty.

## UI/UX

- [ ] Vietnamese text displays correctly.
- [ ] UI is responsive on mobile.
- [ ] Loading states exist.
- [ ] Empty states exist.
- [ ] Error states exist.
- [ ] Buttons have clear labels.
- [ ] Main customer flow is easy to demo.

## Final Demo Flow

- [ ] Admin creates catalog data.
- [ ] Admin creates product.
- [ ] Customer registers/logs in.
- [ ] Customer finds product.
- [ ] Customer adds to cart.
- [ ] Customer checks out.
- [ ] Admin updates order status.
- [ ] Shipper updates delivery status.
- [ ] Customer tracks order.
- [ ] Customer confirms received.
- [ ] Admin dashboard reflects completed order.
