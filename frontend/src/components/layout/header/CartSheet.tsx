import { useEffect } from "react";
import { Link } from "react-router";
import { Minus, PackageSearch, Plus, ShoppingBag } from "lucide-react";
import {
  Sheet as SheetUI,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { useCartStore } from "@/store/useCartStore";
import { formatCurrency } from "@/lib/utils";

const CartSheet = () => {
  const {
    cart,
    fetchCart,
    removeItem,
    updateQuantity,
    isLoading,
    updatingItems,
  } = useCartStore();

  useEffect(() => {
    fetchCart();
  }, [fetchCart]);

  const totalItems = cart?.totalItems || 0;
  const totalPrice = Number(cart?.totalPrice || 0);
  const isUpdating = (itemId: number) => updatingItems.includes(itemId);

  return (
    <SheetUI>
      <SheetTrigger asChild>
        <button className="relative rounded-full p-2 transition-colors hover:bg-gray-100">
          <ShoppingBag className="h-5 w-5 text-gray-700" />
          {totalItems > 0 && (
            <span className="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-xs text-white">
              {totalItems}
            </span>
          )}
        </button>
      </SheetTrigger>

      <SheetContent className="flex h-full w-full flex-col p-0 sm:max-w-md">
        <SheetHeader className="border-b px-6 py-4">
          <SheetTitle className="text-xl font-black">
            Giỏ hàng của tôi ({totalItems})
          </SheetTitle>
        </SheetHeader>

        <div className="soft-scrollbar flex-1 overflow-y-auto px-6 py-4">
          {isLoading && !cart ? (
            <div className="flex justify-center py-10">
              <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-gray-900" />
            </div>
          ) : totalItems === 0 ? (
            <div className="py-10 text-center text-gray-500">
              Giỏ hàng của bạn đang trống
            </div>
          ) : (
            <div className="space-y-6">
              {cart?.items.map((item) => {
                const itemId = item.itemId ?? item.id ?? item.productId;
                return (
                  <div key={itemId} className="flex gap-4">
                    <div className="h-24 w-24 flex-shrink-0 overflow-hidden rounded-lg border border-gray-100">
                      <img
                        src={item?.imageUrl ?? item.product?.mainImageUrl ?? ""}
                        alt={item.product?.name ?? item.productName}
                        className="h-full w-full object-cover"
                      />
                    </div>

                    <div className="flex flex-1 flex-col justify-between">
                      <div>
                        {item.product?.brandName && (
                          <div className="mb-1 text-xs font-black uppercase tracking-wide text-red-600">
                            {item.product.brandName}
                          </div>
                        )}
                        <h3 className="mb-1 line-clamp-2 text-sm font-semibold text-gray-900">
                          {item.product?.name ?? item.productName}
                        </h3>
                        <div className="mb-2 text-sm text-gray-500">
                          {item.color ?? item.variant?.color?.name ?? "N/A"} /{" "}
                          {item.size ?? item.variant?.size?.name ?? "N/A"}
                        </div>
                        <div className="font-black text-gray-900">
                          {formatCurrency(
                            Number(item.variant?.price ?? item.price),
                          )}
                        </div>
                      </div>

                      <div className="mt-2 flex items-center justify-between">
                        <div className="flex h-8 items-center rounded-sm border border-gray-300">
                          <button
                            onClick={() =>
                              updateQuantity(itemId, item.quantity - 1)
                            }
                            className="h-full px-2 hover:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-50"
                            disabled={item.quantity <= 1 || isUpdating(itemId)}
                          >
                            <Minus className="h-3 w-3" />
                          </button>
                          <span className="w-8 text-center text-sm font-medium">
                            {isUpdating(itemId) ? (
                              <span className="inline-block h-3 w-3 animate-spin rounded-full border-2 border-gray-300 border-t-black" />
                            ) : (
                              item.quantity
                            )}
                          </span>
                          <button
                            onClick={() =>
                              updateQuantity(itemId, item.quantity + 1)
                            }
                            className="h-full px-2 hover:bg-gray-100 disabled:cursor-not-allowed disabled:opacity-50"
                            disabled={isUpdating(itemId)}
                          >
                            <Plus className="h-3 w-3" />
                          </button>
                        </div>

                        <button
                          onClick={() => removeItem(itemId)}
                          className="text-sm font-semibold text-red-500 underline hover:text-red-700 disabled:cursor-not-allowed disabled:opacity-50"
                          disabled={isUpdating(itemId)}
                        >
                          Xóa
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {totalItems > 0 && (
          <div className="space-y-4 border-t bg-white p-6">
            <div className="flex items-center justify-between text-base font-medium text-gray-900">
              <p>Tạm tính</p>
              <p className="text-xl font-black">{formatCurrency(totalPrice)}</p>
            </div>
            <div className="space-y-3">
              <Link
                to="/checkout"
                className="block h-12 w-full rounded-sm bg-zinc-950 text-center font-black uppercase leading-[3rem] text-white transition-colors hover:bg-red-600"
              >
                Thanh toán
              </Link>
              <Link
                to="/account/orders"
                className="flex h-11 w-full items-center justify-center gap-2 rounded-sm border border-zinc-200 bg-white text-sm font-bold text-zinc-700 transition hover:border-zinc-950 hover:text-zinc-950"
              >
                <PackageSearch className="h-4 w-4" />
                Theo dõi đơn hàng
              </Link>
            </div>
          </div>
        )}
      </SheetContent>
    </SheetUI>
  );
};

export default CartSheet;
