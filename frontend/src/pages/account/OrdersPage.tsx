import { useEffect, useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { useNavigate } from "react-router";
import {
  CheckCircle2,
  CircleDot,
  Clock3,
  Loader2,
  Package,
  PackageCheck,
  Truck,
  XCircle,
} from "lucide-react";
import { toast } from "sonner";
import { OrderAPI, type Order, type OrderItem } from "@/services/orderApi";
import Container from "@/components/ui/Container";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { getLatestOrder } from "@/utils/orderStorage";
import { formatCurrency } from "@/utils/formatCurrency";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";

const STATUS_META = {
  PENDING: {
    label: "Chờ xác nhận",
    description: "Shop đã nhận đơn và đang kiểm tra thông tin.",
    badge: "bg-amber-100 text-amber-800 border-amber-200",
    icon: Clock3,
  },
  PAID: {
    label: "Đã thanh toán",
    description: "Thanh toán thành công, đơn đang chờ bàn giao.",
    badge: "bg-sky-100 text-sky-800 border-sky-200",
    icon: CheckCircle2,
  },
  SHIPPING: {
    label: "Đang giao",
    description: "Đơn hàng đang trên đường đến bạn.",
    badge: "bg-blue-100 text-blue-800 border-blue-200",
    icon: Truck,
  },
  DELIVERED: {
    label: "Đã giao",
    description: "Shipper đã cập nhật giao hàng thành công.",
    badge: "bg-emerald-100 text-emerald-800 border-emerald-200",
    icon: PackageCheck,
  },
  COMPLETED: {
    label: "Hoàn tất",
    description: "Bạn đã xác nhận nhận hàng.",
    badge: "bg-green-100 text-green-800 border-green-200",
    icon: CheckCircle2,
  },
  CANCELLED: {
    label: "Đã hủy",
    description: "Đơn hàng đã bị hủy hoặc giao không thành công.",
    badge: "bg-red-100 text-red-800 border-red-200",
    icon: XCircle,
  },
} as const;

const ACTIVE_FLOW = ["PENDING", "PAID", "SHIPPING", "DELIVERED", "COMPLETED"];
const COD_FLOW = ["PENDING", "SHIPPING", "DELIVERED", "COMPLETED"];

const getOrderId = (order: Order) => order.id ?? order.orderId;

const getOrderTotal = (order: Order) =>
  Number(order.totalAmount ?? order.totalFinalAmount ?? 0);

const getOrderDate = (order: Order) => {
  const rawDate = order.orderDate;
  const date = rawDate ? new Date(rawDate) : null;
  return date && !Number.isNaN(date.getTime())
    ? date.toLocaleString("vi-VN")
    : "Chưa có thời gian";
};

const normalizeStatus = (status?: string) =>
  (status || "PENDING").toUpperCase() as keyof typeof STATUS_META;

const isCodOrder = (order: Order) =>
  (order.paymentMethod || "").toLowerCase() === "cod";

const getTrackingSteps = (order: Order) => {
  const status = normalizeStatus(order.status);
  if (status === "CANCELLED") {
    return ["PENDING", "CANCELLED"];
  }
  return isCodOrder(order) ? COD_FLOW : ACTIVE_FLOW;
};

const StatusBadge = ({ status }: { status: string }) => {
  const key = normalizeStatus(status);
  const meta = STATUS_META[key] ?? STATUS_META.PENDING;

  return (
    <Badge className={`${meta.badge} border font-bold`}>
      {meta.label}
    </Badge>
  );
};

const OrderTracking = ({ order }: { order: Order }) => {
  const currentStatus = normalizeStatus(order.status);
  const steps = getTrackingSteps(order);
  const currentIndex = steps.indexOf(currentStatus);
  const safeCurrentIndex =
    currentStatus === "CANCELLED" ? 1 : Math.max(currentIndex, 0);

  return (
    <div className="rounded-lg border border-zinc-100 bg-zinc-50/80 p-4">
      <div className="mb-4 flex items-start justify-between gap-4">
        <div>
          <p className="text-sm font-black uppercase tracking-[0.16em] text-zinc-500">
            Theo dõi đơn hàng
          </p>
          <p className="mt-1 text-sm text-zinc-600">
            {STATUS_META[currentStatus]?.description ??
              STATUS_META.PENDING.description}
          </p>
        </div>
        <StatusBadge status={currentStatus} />
      </div>

      <div className="grid gap-3 sm:grid-cols-4">
        {steps.map((step, index) => {
          const key = step as keyof typeof STATUS_META;
          const meta = STATUS_META[key];
          const Icon = meta.icon;
          const isDone = index < safeCurrentIndex;
          const isCurrent = index === safeCurrentIndex;
          const isCancelled = key === "CANCELLED";

          return (
            <div key={step} className="relative flex gap-3 sm:block">
              {index < steps.length - 1 && (
                <div
                  className={`absolute left-5 top-10 h-[calc(100%-1rem)] w-px sm:left-[calc(50%+1.25rem)] sm:top-5 sm:h-px sm:w-[calc(100%-2.5rem)] ${
                    isDone ? "bg-red-500" : "bg-zinc-200"
                  }`}
                />
              )}
              <div
                className={`relative z-10 flex h-10 w-10 shrink-0 items-center justify-center rounded-full border-2 sm:mx-auto ${
                  isCancelled
                    ? "border-red-500 bg-red-50 text-red-600"
                    : isDone || isCurrent
                      ? "border-red-600 bg-red-600 text-white"
                      : "border-zinc-200 bg-white text-zinc-400"
                }`}
              >
                {isCurrent && !isCancelled ? (
                  <CircleDot className="h-5 w-5" />
                ) : (
                  <Icon className="h-5 w-5" />
                )}
              </div>
              <div className="min-w-0 sm:mt-3 sm:text-center">
                <p
                  className={`text-sm font-bold ${
                    isDone || isCurrent || isCancelled
                      ? "text-zinc-950"
                      : "text-zinc-400"
                  }`}
                >
                  {meta.label}
                </p>
                <p className="mt-1 text-xs leading-5 text-zinc-500">
                  {meta.description}
                </p>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

const OrdersPage = () => {
  const navigate = useNavigate();
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ["my-orders"],
    queryFn: () => OrderAPI.getOrders(),
    retry: 1,
  });

  const latestOrder = getLatestOrder();

  const orders: Order[] = useMemo(() => {
    if (isError) return latestOrder ? [latestOrder as Order] : [];
    return Array.isArray(data) ? data : [];
  }, [data, isError, latestOrder]);

  useEffect(() => {
    if (!orders || orders.length === 0) return;

    const now = Date.now();
    const sevenDaysMs = 7 * 24 * 60 * 60 * 1000;

    const toCancel = orders.filter((order) => {
      const createdAt = new Date(order.orderDate).getTime();
      if (Number.isNaN(createdAt)) return false;
      const status = normalizeStatus(order.status);
      return (
        now - createdAt > sevenDaysMs &&
        status !== "CANCELLED" &&
        status !== "COMPLETED"
      );
    });

    if (toCancel.length === 0) return;

    (async () => {
      try {
        await Promise.all(
          toCancel.map((order) =>
            OrderAPI.userUpdateOrderStatus(getOrderId(order), "CANCELLED"),
          ),
        );
        await refetch();
      } catch (error) {
        console.error("Auto-cancel orders error:", error);
      }
    })();
  }, [orders, refetch]);

  const handleUserUpdateStatus = async (
    orderId: number,
    status: "COMPLETED" | "CANCELLED",
  ) => {
    try {
      await OrderAPI.userUpdateOrderStatus(orderId, status);
      toast.success(
        status === "COMPLETED"
          ? "Đã xác nhận nhận hàng thành công"
          : "Đã cập nhật đơn hàng chưa nhận được",
      );
      await refetch();
      setSelectedOrder(null);
    } catch (error) {
      console.error("Update order status error:", error);
      toast.error("Cập nhật trạng thái đơn hàng thất bại");
    }
  };

  if (isLoading) {
    return (
      <Container className="flex justify-center py-10">
        <Loader2 className="h-8 w-8 animate-spin text-gray-400" />
      </Container>
    );
  }

  if (orders.length === 0) {
    return (
      <Container className="py-10 text-center">
        <div className="flex flex-col items-center space-y-4">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-gray-100">
            <Package className="h-8 w-8 text-gray-400" />
          </div>
          <h2 className="text-xl font-semibold">Bạn chưa có đơn hàng nào</h2>
          <Button onClick={() => navigate("/collections")}>Mua sắm ngay</Button>
        </div>
      </Container>
    );
  }

  return (
    <div className="min-h-screen py-8">
      <Container>
        <div className="mb-6 flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
          <div>
            <p className="section-kicker">Order tracking</p>
            <h1 className="mt-2 text-3xl font-black tracking-tight text-zinc-950">
              Đơn hàng của tôi
            </h1>
          </div>
          {isError && (
            <span className="rounded-full border border-orange-200 bg-orange-50 px-4 py-2 text-sm font-semibold text-orange-600">
              Hiển thị đơn hàng gần nhất khi offline
            </span>
          )}
        </div>

        <div className="space-y-5">
          {orders.map((order) => {
            const orderId = getOrderId(order);
            const status = normalizeStatus(order.status);

            return (
              <article
                key={orderId}
                className="ui-panel overflow-hidden rounded-lg"
              >
                <div className="flex flex-col gap-3 border-b border-zinc-100 bg-white/70 p-4 sm:flex-row sm:items-center sm:justify-between">
                  <div>
                    <p className="font-black text-zinc-950">
                      Đơn hàng #{orderId}
                    </p>
                    <p className="text-sm text-gray-500">
                      {getOrderDate(order)}
                    </p>
                  </div>
                  <StatusBadge status={status} />
                </div>

                <div className="space-y-5 p-4">
                  <OrderTracking order={order} />

                  <div className="space-y-4">
                    {order.items.map((item: OrderItem, idx: number) => (
                      <div key={idx} className="flex gap-4">
                        <img
                          src={
                            item.variantImage ||
                            item.mainImageUrl ||
                            "/product-placeholder.svg"
                          }
                          className="h-20 w-20 rounded-lg border object-cover"
                          alt={item.productName}
                        />
                        <div className="min-w-0 flex-1">
                          <p className="line-clamp-2 font-semibold text-zinc-950">
                            {item.productName}
                          </p>
                          <p className="text-sm text-gray-500">
                            {item.color ?? item.variantDetails ?? "N/A"} /{" "}
                            {item.size ?? "N/A"} × {item.quantity}
                          </p>
                        </div>
                        <p className="font-bold text-zinc-950">
                          {formatCurrency(Number(item.price) * item.quantity)}
                        </p>
                      </div>
                    ))}
                  </div>

                  <div className="flex flex-col gap-3 border-t border-zinc-100 pt-4 sm:flex-row sm:items-center sm:justify-between">
                    <p className="text-lg font-black text-red-600">
                      Tổng tiền: {formatCurrency(getOrderTotal(order))}
                    </p>
                    <div className="flex flex-wrap gap-2">
                      <Button
                        variant="outline"
                        onClick={() => setSelectedOrder(order)}
                      >
                        Xem chi tiết
                      </Button>
                      {status === "DELIVERED" && (
                        <>
                          <Button
                            onClick={() =>
                              handleUserUpdateStatus(orderId, "COMPLETED")
                            }
                            className="bg-zinc-950 hover:bg-red-600"
                          >
                            Đã nhận hàng
                          </Button>
                          <Button
                            variant="destructive"
                            onClick={() =>
                              handleUserUpdateStatus(orderId, "CANCELLED")
                            }
                          >
                            Chưa nhận hàng
                          </Button>
                        </>
                      )}
                    </div>
                  </div>
                </div>
              </article>
            );
          })}
        </div>

        <Dialog
          open={!!selectedOrder}
          onOpenChange={() => setSelectedOrder(null)}
        >
          <DialogContent className="max-h-[88vh] max-w-3xl overflow-y-auto">
            <DialogHeader>
              <DialogTitle>
                Chi tiết đơn hàng #{selectedOrder ? getOrderId(selectedOrder) : ""}
              </DialogTitle>
            </DialogHeader>
            {selectedOrder && (
              <div className="space-y-6 text-sm">
                <OrderTracking order={selectedOrder} />

                <div className="grid gap-4 rounded-lg border p-4 sm:grid-cols-2">
                  <div>
                    <p className="font-bold">Người nhận hàng</p>
                    <p>Họ và tên: {selectedOrder.recipientName || "N/A"}</p>
                    <p>Số điện thoại: {selectedOrder.phoneNumber || "N/A"}</p>
                  </div>
                  <div>
                    <p className="font-bold">Ghi chú</p>
                    <p>{selectedOrder.note || "Không có ghi chú"}</p>
                  </div>
                </div>

                <div className="rounded-lg border p-4">
                  <p className="mb-1 font-bold">Địa chỉ giao hàng</p>
                  <p>{selectedOrder.shippingAddress || "N/A"}</p>
                </div>

                <div className="flex justify-between rounded-lg border p-4">
                  <div>
                    <p className="font-bold">Phương thức thanh toán</p>
                    <p>{selectedOrder.paymentMethod || "N/A"}</p>
                  </div>
                  <div className="text-right">
                    <p className="font-bold">Trạng thái</p>
                    <StatusBadge status={selectedOrder.status} />
                  </div>
                </div>

                <div className="space-y-3">
                  {selectedOrder.items.map((item, idx) => (
                    <div key={idx} className="flex gap-4 rounded-lg border p-3">
                      <img
                        src={
                          item.variantImage ||
                          item.mainImageUrl ||
                          "/product-placeholder.svg"
                        }
                        className="h-16 w-16 rounded object-cover"
                        alt={item.productName}
                      />
                      <div className="flex-1">
                        <p className="font-semibold">{item.productName}</p>
                        <p className="text-gray-500">
                          {item.color ?? item.variantDetails ?? "N/A"} /{" "}
                          {item.size ?? "N/A"} × {item.quantity}
                        </p>
                      </div>
                      <p className="font-bold">
                        {formatCurrency(Number(item.price) * item.quantity)}
                      </p>
                    </div>
                  ))}
                </div>

                <div className="flex flex-col gap-3 border-t pt-4 sm:flex-row sm:items-center sm:justify-between">
                  <p className="text-lg font-black text-red-600">
                    Tổng tiền: {formatCurrency(getOrderTotal(selectedOrder))}
                  </p>
                  {normalizeStatus(selectedOrder.status) === "DELIVERED" && (
                    <div className="flex flex-wrap gap-2">
                      <Button
                        onClick={() =>
                          handleUserUpdateStatus(
                            getOrderId(selectedOrder),
                            "COMPLETED",
                          )
                        }
                        className="bg-zinc-950 hover:bg-red-600"
                      >
                        Đã nhận hàng
                      </Button>
                      <Button
                        variant="destructive"
                        onClick={() =>
                          handleUserUpdateStatus(
                            getOrderId(selectedOrder),
                            "CANCELLED",
                          )
                        }
                      >
                        Chưa nhận hàng
                      </Button>
                    </div>
                  )}
                </div>
              </div>
            )}
          </DialogContent>
        </Dialog>
      </Container>
    </div>
  );
};

export default OrdersPage;
