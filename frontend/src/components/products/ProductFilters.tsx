import type { ProductFilters as APIProductFilters } from "@/services/productsApi";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Skeleton } from "@/components/ui/skeleton";
import { Filter, Search, X } from "lucide-react";
import { useBrands } from "@/hooks/useBrandsQuery";
import { useState } from "react";

interface ProductFiltersProps {
  filters: APIProductFilters;
  onFiltersChange: (filters: APIProductFilters) => void;
}

const PRICE_RANGES = [
  { id: "p0", label: "All prices", min: undefined, max: undefined },
  { id: "p1", label: "Under 500k", min: 0, max: 500000 },
  { id: "p2", label: "500k - 1m", min: 500000, max: 1000000 },
  { id: "p3", label: "1m - 2m", min: 1000000, max: 2000000 },
  { id: "p4", label: "Over 2m", min: 2000000, max: undefined },
];

const COLORS = [
  { name: "Den", label: "Black", hex: "#222222" },
  { name: "Trang", label: "White", hex: "#FFFFFF" },
  { name: "Xam", label: "Grey", hex: "#888888" },
  { name: "Xanh", label: "Blue", hex: "#2196F3" },
  { name: "Do", label: "Red", hex: "#E53935" },
  { name: "Vang", label: "Yellow", hex: "#FFC107" },
  { name: "Nau", label: "Brown", hex: "#795548" },
  { name: "Hong", label: "Pink", hex: "#E91E63" },
  { name: "Cam", label: "Orange", hex: "#FF9800" },
  { name: "Tim", label: "Purple", hex: "#9C27B0" },
];

const ProductFilters = ({ filters, onFiltersChange }: ProductFiltersProps) => {
  const { data: brandData, isLoading: isLoadingBrands } = useBrands();
  const [searchInput, setSearchInput] = useState(filters.search || "");
  const brands = brandData?.data?.brands || [];

  const hasActiveFilters = !!(
    filters.search ||
    filters.minPrice !== undefined ||
    filters.maxPrice !== undefined ||
    filters.brandId ||
    filters.color
  );

  const handleSearch = () => {
    onFiltersChange({ ...filters, search: searchInput || undefined });
  };

  const clearAllFilters = () => {
    setSearchInput("");
    onFiltersChange({
      search: undefined,
      minPrice: undefined,
      maxPrice: undefined,
      brandId: undefined,
      color: undefined,
    });
  };

  return (
    <aside className="rounded-sm bg-white p-5 ring-1 ring-black/5">
      <div className="mb-5 flex items-center justify-between">
        <h3 className="flex items-center gap-2 text-sm font-black uppercase tracking-[0.18em] text-zinc-950">
          <Filter className="h-4 w-4" />
          Filters
        </h3>
        {hasActiveFilters && (
          <Button
            variant="ghost"
            size="sm"
            onClick={clearAllFilters}
            className="h-8 px-2 text-xs font-bold text-red-600 hover:bg-red-50 hover:text-red-700"
          >
            <X className="mr-1 h-3.5 w-3.5" />
            Clear
          </Button>
        )}
      </div>

      <div className="space-y-7">
        <section>
          <h4 className="mb-3 text-xs font-black uppercase tracking-[0.18em] text-zinc-400">
            Search
          </h4>
          <div className="flex gap-2">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
              <Input
                placeholder="Product name"
                className="h-10 rounded-sm border-zinc-200 pl-9"
                value={searchInput}
                onChange={(event) => setSearchInput(event.target.value)}
                onKeyDown={(event) => {
                  if (event.key === "Enter") handleSearch();
                }}
              />
            </div>
            <Button onClick={handleSearch} size="sm" className="h-10 rounded-sm">
              <Search className="h-4 w-4" />
            </Button>
          </div>
        </section>

        <section>
          <h4 className="mb-3 text-xs font-black uppercase tracking-[0.18em] text-zinc-400">
            Price
          </h4>
          <div className="space-y-2.5">
            {PRICE_RANGES.map((range) => {
              const isSelected =
                filters.minPrice === range.min &&
                filters.maxPrice === range.max;
              return (
                <div key={range.id} className="flex items-center gap-2">
                  <Checkbox
                    id={range.id}
                    checked={isSelected}
                    onCheckedChange={() =>
                      onFiltersChange({
                        ...filters,
                        minPrice: isSelected ? undefined : range.min,
                        maxPrice: isSelected ? undefined : range.max,
                      })
                    }
                  />
                  <Label
                    htmlFor={range.id}
                    className={`cursor-pointer text-sm ${
                      isSelected ? "font-bold text-zinc-950" : "text-zinc-600"
                    }`}
                  >
                    {range.label}
                  </Label>
                </div>
              );
            })}
          </div>
        </section>

        <section>
          <h4 className="mb-3 text-xs font-black uppercase tracking-[0.18em] text-zinc-400">
            Brands
          </h4>
          <div className="max-h-64 space-y-2.5 overflow-y-auto pr-1">
            {isLoadingBrands ? (
              Array.from({ length: 5 }).map((_, index) => (
                <Skeleton key={index} className="h-6 w-full" />
              ))
            ) : brands.length === 0 ? (
              <p className="text-sm text-gray-500">No brands</p>
            ) : (
              brands.map((brand) => {
                const isSelected = filters.brandId === brand.id;
                return (
                  <div key={brand.id} className="flex items-center gap-2">
                    <Checkbox
                      id={`brand-${brand.id}`}
                      checked={isSelected}
                      onCheckedChange={() =>
                        onFiltersChange({
                          ...filters,
                          brandId: isSelected ? undefined : brand.id,
                        })
                      }
                    />
                    <Label
                      htmlFor={`brand-${brand.id}`}
                      className={`cursor-pointer text-sm ${
                        isSelected ? "font-bold text-zinc-950" : "text-zinc-600"
                      }`}
                    >
                      {brand.name ?? brand.brandName}
                    </Label>
                  </div>
                );
              })
            )}
          </div>
        </section>

        <section>
          <h4 className="mb-3 text-xs font-black uppercase tracking-[0.18em] text-zinc-400">
            Colors
          </h4>
          <div className="flex flex-wrap gap-2">
            {COLORS.map((color) => {
              const isSelected = filters.color === color.name;
              return (
                <button
                  key={color.name}
                  type="button"
                  onClick={() =>
                    onFiltersChange({
                      ...filters,
                      color: isSelected ? undefined : color.name,
                    })
                  }
                  className={`h-8 w-8 rounded-full border transition hover:scale-110 ${
                    isSelected
                      ? "border-zinc-950 ring-2 ring-zinc-950 ring-offset-2"
                      : "border-black/10"
                  }`}
                  style={{ backgroundColor: color.hex }}
                  title={color.label}
                />
              );
            })}
          </div>
        </section>
      </div>
    </aside>
  );
};

export default ProductFilters;
