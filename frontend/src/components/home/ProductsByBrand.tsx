import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import ProductCard from "@/components/ui/ProductCard";
import { Loader2 } from "lucide-react";
import { useBrands } from "@/hooks/useBrandsQuery";
import { useProducts } from "@/hooks/useProductsQuery";

const ProductsByBrand = () => {
  const [selectedBrand, setSelectedBrand] = useState<string>("");

  const { data: brandData, isLoading: isLoadingBrands } = useBrands();
  const brands = brandData?.data?.brands || [];

  useEffect(() => {
    if (brands.length > 0 && !selectedBrand) {
      setSelectedBrand(brands[0].slug);
    }
  }, [brands, selectedBrand]);

  const { data: productsData, isLoading: isLoadingProducts } = useProducts({
    filters: { brand: selectedBrand },
    page: 1,
    limit: 20,
    enabled: !!selectedBrand,
  });

  const products = productsData?.data || [];
  const activeBrand =
    brands.find((brand) => brand.slug === selectedBrand)?.name ??
    brands.find((brand) => brand.slug === selectedBrand)?.brandName ??
    "";

  if (isLoadingBrands) {
    return (
      <div className="flex justify-center py-10">
        <Loader2 className="h-8 w-8 animate-spin text-gray-400" />
      </div>
    );
  }

  return (
    <section className="rounded-lg">
      <div className="mb-7 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="section-kicker">
            Popular picks
          </p>
          <h3 className="mt-2 text-2xl font-black tracking-tight text-zinc-950 sm:text-3xl">
            Shop by brand
          </h3>
        </div>
        <a
          href="/collections"
          className="text-sm font-black uppercase tracking-wide text-zinc-700 underline-offset-4 hover:text-red-600 hover:underline"
        >
          View all products
        </a>
      </div>

      <div className="soft-scrollbar mb-8 flex gap-2 overflow-x-auto pb-2">
        {brands.slice(0, 4).map((brand) => (
          <Button
            key={brand.id}
            onClick={() => setSelectedBrand(brand.slug)}
            variant={selectedBrand === brand.slug ? "default" : "outline"}
            className={`h-10 shrink-0 rounded-full px-5 text-xs font-bold uppercase tracking-wide transition-all ${
              selectedBrand === brand.slug
                ? "bg-zinc-950 text-white shadow-sm hover:bg-red-600"
                : "border-zinc-200 bg-white/80 text-zinc-700 hover:border-zinc-950 hover:bg-white"
            }`}
          >
            {brand.name ?? brand.brandName}
          </Button>
        ))}
      </div>

      {isLoadingProducts ? (
        <div className="flex items-center justify-center gap-3 py-20 text-zinc-500">
          <Loader2 className="h-6 w-6 animate-spin" />
          Loading products...
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-2 lg:grid-cols-4 xl:grid-cols-5">
          {products.length > 0 ? (
            products.slice(0, 10).map((product) => (
              <ProductCard
                key={product.id}
                slug={product.slug}
                name={product.name}
                image={product.mainImageUrl || "https://placehold.co/245"}
                originalPrice={product.basePrice}
                colors={product.colors || []}
                brand={activeBrand}
              />
            ))
          ) : (
            <div className="ui-panel col-span-full rounded-lg py-12 text-center text-gray-500">
              No products found for this brand.
            </div>
          )}
        </div>
      )}
    </section>
  );
};

export default ProductsByBrand;
