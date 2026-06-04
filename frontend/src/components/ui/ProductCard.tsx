import { Link } from "react-router";
import { Eye, ShoppingBag } from "lucide-react";

const COLOR_MAP: Record<string, string> = {
  bac: "#C0C0C0",
  be: "#D7CCC8",
  cam: "#FF9800",
  den: "#222222",
  do: "#E53935",
  hong: "#E91E63",
  nau: "#795548",
  navy: "#1A237E",
  tim: "#9C27B0",
  trang: "#FFFFFF",
  vang: "#FFC107",
  xam: "#888888",
  xanh: "#2196F3",
  "xanh duong": "#1E88E5",
  "xanh la": "#4CAF50",
};

export interface ColorInfo {
  name: string;
  hex?: string;
  image?: string;
}

interface ProductCardProps {
  name: string;
  image: string;
  originalPrice: string | number;
  salePrice?: string | number;
  brand: string;
  slug?: string;
  breadcrumb?: { label: string; href: string }[];
  colors?: ColorInfo[];
}

const ProductCard = ({
  name,
  image,
  originalPrice,
  salePrice,
  brand,
  slug,
  breadcrumb,
  colors = [],
}: ProductCardProps) => {
  const formatPrice = (price: string | number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(Number(price));
  };

  const displayColors = colors.slice(0, 5);
  const remainingColors = colors.length - 5;
  const hasSale = !!salePrice && Number(salePrice) < Number(originalPrice);
  const colorKey = (name: string) =>
    name
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[đĐ]/g, "d");

  const content = (
    <article className="flex h-full flex-col overflow-hidden rounded-lg bg-white ring-1 ring-black/5 transition duration-300 hover:-translate-y-1 hover:shadow-xl hover:shadow-zinc-950/10">
      <div className="relative aspect-square overflow-hidden bg-zinc-100">
        {hasSale && (
          <span className="absolute left-3 top-3 z-10 rounded-full bg-red-600 px-3 py-1 text-[10px] font-black uppercase tracking-wide text-white shadow-sm">
            Sale
          </span>
        )}
        <img
          src={image || "https://placehold.co/600x600?text=No+Image"}
          alt={name}
          className="h-full w-full object-cover transition duration-500 group-hover:scale-105"
        />
        <div className="absolute inset-x-3 bottom-3 flex translate-y-3 gap-2 opacity-0 transition duration-300 group-hover:translate-y-0 group-hover:opacity-100">
          <span className="inline-flex h-10 flex-1 items-center justify-center gap-2 rounded-sm bg-zinc-950 px-3 text-xs font-black uppercase tracking-wide text-white shadow-lg shadow-black/20">
            <Eye className="h-4 w-4" />
            View
          </span>
          <span className="inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-sm bg-white text-zinc-950 shadow-lg shadow-black/15">
            <ShoppingBag className="h-4 w-4" />
          </span>
        </div>
      </div>

      <div className="flex flex-1 flex-col p-4">
        <p className="mb-1 text-[10px] font-black uppercase tracking-[0.18em] text-zinc-400">
          {brand}
        </p>
        <h3 className="mb-3 line-clamp-2 min-h-10 text-sm font-bold leading-5 text-zinc-900 group-hover:text-red-600">
          {name}
        </h3>

        {displayColors.length > 0 && (
          <div className="mb-3 flex items-center gap-1.5">
            {displayColors.map((color, idx) => {
              const bgColor = color.hex || COLOR_MAP[colorKey(color.name)] || "#ccc";
              return (
                <div
                  key={`${color.name}-${idx}`}
                  className="h-4 w-4 rounded-full border border-black/10 shadow-sm ring-1 ring-white"
                  style={{ backgroundColor: bgColor }}
                  title={color.name}
                />
              );
            })}
            {remainingColors > 0 && (
              <span className="ml-1 text-[10px] font-semibold text-gray-500">
                +{remainingColors}
              </span>
            )}
          </div>
        )}

        <div className="mt-auto flex items-end justify-between gap-2">
          <span className="text-base font-black text-zinc-950">
            {formatPrice(salePrice || originalPrice)}
          </span>
          {hasSale && (
            <span className="text-xs font-medium text-gray-400 line-through">
              {formatPrice(originalPrice)}
            </span>
          )}
        </div>
      </div>
    </article>
  );

  if (slug) {
    return (
      <Link
        to={`/product/${slug}`}
        state={{ breadcrumb }}
        className="group block h-full"
      >
        {content}
      </Link>
    );
  }

  return content;
};

export default ProductCard;
