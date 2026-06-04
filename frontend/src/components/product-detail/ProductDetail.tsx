import type { useProductDetail } from "@/hooks/useProductDetail";
import ProductGallery from "./ProductGallery";
import ProductInfo from "./ProductInfo";
import ProductTabs from "./ProductTabs";

type ProductDetailProps = ReturnType<typeof useProductDetail>;

const ProductDetail = (props: ProductDetailProps) => {
  const { product, currentVariant } = props;

  if (!product) {
    return (
      <div className="grid min-h-[60vh] place-items-center">
        <div className="h-10 w-10 animate-spin rounded-full border-2 border-zinc-300 border-t-zinc-950" />
      </div>
    );
  }

  // Use images from current variant, or fallback to first variant's images
  const images =
    currentVariant?.imageUrls || product.variants[0]?.imageUrls || [];

  return (
    <div className="py-10">
      <div className="mb-8 rounded-sm bg-white p-4 ring-1 ring-black/5 sm:p-6 lg:p-8">
        <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
          <ProductGallery
            key={currentVariant?.id || product.variants[0]?.id}
            images={images}
            productName={product.name}
          />
          <ProductInfo {...props} />
        </div>
      </div>

      <ProductTabs product={product} />
    </div>
  );
};

export default ProductDetail;
