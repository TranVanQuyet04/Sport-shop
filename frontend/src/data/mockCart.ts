import type { CartResponse, CartItem } from "@/services/cartApi";

const CART_STORAGE_KEY = "StrideX-local-cart";

export interface AddToCartProductInfo {
  productName: string;
  productSlug: string;
  brandName: string;
  mainImageUrl: string;
  variantId: number;
  sku: string;
  price: string | number;
  colorName?: string;
  sizeName?: string;
}

export function getLocalCart(): CartResponse {
  try {
    const raw = localStorage.getItem(CART_STORAGE_KEY);
    if (raw) {
      return JSON.parse(raw) as CartResponse;
    }
  } catch (e) {
    console.warn("Failed to parse local cart", e);
  }
  return {
    id: -1,
    userId: 0,
    totalItems: 0,
    totalPrice: "0",
    items: [],
  };
}

function saveLocalCart(cart: CartResponse): void {
  try {
    localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(cart));
  } catch (e) {
    console.warn("Failed to save local cart", e);
  }
}

export function clearLocalCart(): void {
  try {
    localStorage.removeItem(CART_STORAGE_KEY);
  } catch (e) {
    console.warn("Failed to clear local cart", e);
  }
}

/**
 * ThÃªm sáº£n pháº©m vÃ o giá» local (khi API lá»—i)
 */
export function addToLocalCart(
  variantId: number,
  quantity: number,
  productInfo: AddToCartProductInfo
): CartResponse {
  const cart = getLocalCart();
  const existingIndex = cart.items.findIndex(
    (i) => i.variant?.variantId === variantId
  );

  const newItem: CartItem = {
    itemId: -Date.now(),
    productId: variantId,
    productName: productInfo.productName,
    quantity,
    price: productInfo.price,
    isSelected: true,
    product: {
      name: productInfo.productName,
      slug: productInfo.productSlug,
      brandName: productInfo.brandName,
      mainImageUrl: productInfo.mainImageUrl || "https://placehold.co/100",
    },
    variant: {
      variantId,
      sku: productInfo.sku,
      price: String(productInfo.price),
      stockQuantity: 99,
      color: productInfo.colorName
        ? { name: productInfo.colorName, hexCode: "#000" }
        : null,
      size: productInfo.sizeName ? { name: productInfo.sizeName } : null,
      image: productInfo.mainImageUrl || "https://placehold.co/100",
    },
  };

  if (existingIndex >= 0) {
    cart.items[existingIndex].quantity += quantity;
  } else {
    cart.items.push(newItem);
  }

  cart.totalItems = cart.items.reduce((s, i) => s + i.quantity, 0);
  cart.totalPrice = cart.items
    .reduce((s, i) => s + Number(i.variant?.price ?? i.price) * i.quantity, 0)
    .toFixed(0);

  saveLocalCart(cart);
  return cart;
}

/**
 * Cáº­p nháº­t sá»‘ lÆ°á»£ng item trong giá» local
 */
export function updateLocalCartItem(
  itemId: number,
  quantity: number
): CartResponse | null {
  const cart = getLocalCart();
  const item = cart.items.find((i) => i.itemId === itemId);
  if (!item) return null;

  if (quantity <= 0) {
    cart.items = cart.items.filter((i) => i.itemId !== itemId);
  } else {
    item.quantity = quantity;
  }

  cart.totalItems = cart.items.reduce((s, i) => s + i.quantity, 0);
  cart.totalPrice = cart.items
    .reduce((s, i) => s + Number(i.variant?.price ?? i.price) * i.quantity, 0)
    .toFixed(0);

  saveLocalCart(cart);
  return cart;
}

/**
 * XÃ³a item khá»i giá» local
 */
export function removeLocalCartItem(itemId: number): CartResponse | null {
  return updateLocalCartItem(itemId, 0);
}

/**
 * Kiá»ƒm tra cart cÃ³ pháº£i tá»« local storage khÃ´ng (itemId Ã¢m)
 */
export function isLocalCart(cart: CartResponse | null): boolean {
  return (
    cart !== null &&
    ((cart.id ?? 0) < 0 || cart.items.some((i) => (i.itemId ?? 0) < 0))
  );
}
