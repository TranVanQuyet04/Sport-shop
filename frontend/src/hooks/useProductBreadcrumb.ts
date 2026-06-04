import { useLocation } from "react-router";
import type { BackendProduct } from "@/types/api";

export const useProductBreadcrumb = (product: BackendProduct | null) => {
  const location = useLocation();
  const breadcrumbFromState = location.state?.breadcrumb;

  if (!product) return [];

  if (breadcrumbFromState) {
    return [
      ...breadcrumbFromState,
      { label: product.name || "San pham", href: "" },
    ];
  }

  const items = [{ label: "Trang chu", href: "/" }];
  const primaryCategory =
    product.category_ids?.find((c) => c.is_primary) ||
    product.category_ids?.[0];

  if (primaryCategory) {
    const category =
      "_id" in primaryCategory ? primaryCategory._id : primaryCategory;
    items.push({
      label: category.name || "San pham",
      href: `/collections/${category.slug}`,
    });
  } else {
    items.push({ label: "San pham", href: "/collections" });
  }

  items.push({ label: product.name || "Chi tiet", href: "" });
  return items;
};
