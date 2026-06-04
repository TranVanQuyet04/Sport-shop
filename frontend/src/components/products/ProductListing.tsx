import Breadcrumb from "@/components/ui/Breadcrumb";
import ProductCard from "@/components/ui/ProductCard";
import ProductFiltersComponent from "@/components/products/ProductFilters";
import ProductSort from "@/components/products/ProductSort";
import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationItem,
  PaginationLink,
  PaginationNext,
  PaginationPrevious,
} from "@/components/ui/pagination";
import type {
  ProductFilters,
  ProductsResponse,
} from "@/services/productsApi";

interface ProductListingProps {
  title: string;
  breadcrumbItems: { label: string; href: string }[];
  filters: ProductFilters;
  onFiltersChange: (filters: ProductFilters) => void;
  sortBy: string;
  onSortChange: (sort: string) => void;
  data: ProductsResponse | undefined;
  isLoading: boolean;
  error: unknown;
  onPageChange: (page: number) => void;
  onRefetch: () => void;
}

const ProductListing = ({
  title,
  breadcrumbItems,
  filters,
  onFiltersChange,
  sortBy,
  onSortChange,
  data,
  isLoading,
  error,
  onPageChange,
  onRefetch,
}: ProductListingProps) => {
  const generatePaginationItems = () => {
    if (!data?.pagination) return [];

    const { page, totalPages } = data.pagination;
    const items = [];
    const delta = 2;

    for (
      let i = Math.max(1, page - delta);
      i <= Math.min(totalPages, page + delta);
      i++
    ) {
      items.push(i);
    }

    return items;
  };

  return (
    <div className="py-8">
      <Breadcrumb
        items={breadcrumbItems.map((item, index) =>
          index === breadcrumbItems.length - 1 ? { ...item, href: "" } : item,
        )}
      />

      <section className="mt-5 overflow-hidden rounded-lg bg-zinc-950 p-6 text-white shadow-lg shadow-zinc-950/10 sm:p-8">
        <p className="text-xs font-semibold uppercase tracking-[0.28em] text-white/50">
          Collection
        </p>
        <div className="mt-3 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
          <h1 className="text-3xl font-black tracking-tight sm:text-5xl">
            {title}
          </h1>
          <p className="text-sm font-semibold text-white/70">
            {data?.pagination?.total || 0} products
          </p>
        </div>
      </section>

      <div className="mt-8 flex flex-col gap-6 lg:flex-row">
        <div className="w-full shrink-0 lg:w-72">
          <ProductFiltersComponent
            filters={filters}
            onFiltersChange={onFiltersChange}
          />
        </div>

        <div className="min-w-0 flex-1">
          <ProductSort sortBy={sortBy} onSortChange={onSortChange} />

          {isLoading ? (
            <div className="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-3 xl:grid-cols-4">
              {Array.from({ length: 8 }).map((_, index) => (
                <div
                  key={index}
                  className="aspect-[3/4] animate-pulse rounded-lg bg-white ring-1 ring-black/5"
                />
              ))}
            </div>
          ) : error ? (
            <div className="ui-panel mt-6 rounded-lg p-12 text-center">
              <p className="font-semibold text-red-600">
                Could not load products.
              </p>
              <button
                onClick={onRefetch}
                className="mt-4 rounded-sm bg-zinc-950 px-5 py-2 text-sm font-bold text-white hover:bg-red-600"
              >
                Try again
              </button>
            </div>
          ) : data?.data?.length === 0 ? (
            <div className="ui-panel mt-6 rounded-lg p-12 text-center text-zinc-500">
              No products match your filters.
            </div>
          ) : (
            <div className="mt-6 grid grid-cols-2 gap-4 lg:grid-cols-3 xl:grid-cols-4">
              {data?.data?.map((product, index) => (
                <ProductCard
                  key={product.id || index}
                  name={product.name}
                  slug={product.slug}
                  image={
                    product.mainImageUrl ||
                    "https://placehold.co/600x600?text=No+Image"
                  }
                  originalPrice={product.basePrice}
                  brand={product.brandName || ""}
                  breadcrumb={breadcrumbItems}
                  colors={product.colors}
                />
              ))}
            </div>
          )}

          {data?.pagination && data.pagination.totalPages > 1 && (
            <div className="mt-12 flex justify-center">
              <Pagination>
                <PaginationContent>
                  {data.pagination.page > 1 && (
                    <PaginationItem>
                      <PaginationPrevious
                        href="#"
                        onClick={(event) => {
                          event.preventDefault();
                          onPageChange(data.pagination.page - 1);
                        }}
                      />
                    </PaginationItem>
                  )}

                  {data.pagination.page > 3 && (
                    <>
                      <PaginationItem>
                        <PaginationLink
                          href="#"
                          onClick={(event) => {
                            event.preventDefault();
                            onPageChange(1);
                          }}
                        >
                          1
                        </PaginationLink>
                      </PaginationItem>
                      {data.pagination.page > 4 && (
                        <PaginationItem>
                          <PaginationEllipsis />
                        </PaginationItem>
                      )}
                    </>
                  )}

                  {generatePaginationItems().map((pageNumber) => (
                    <PaginationItem key={pageNumber}>
                      <PaginationLink
                        href="#"
                        isActive={pageNumber === data.pagination.page}
                        onClick={(event) => {
                          event.preventDefault();
                          onPageChange(pageNumber);
                        }}
                      >
                        {pageNumber}
                      </PaginationLink>
                    </PaginationItem>
                  ))}

                  {data.pagination.page < data.pagination.totalPages - 2 && (
                    <>
                      {data.pagination.page <
                        data.pagination.totalPages - 3 && (
                        <PaginationItem>
                          <PaginationEllipsis />
                        </PaginationItem>
                      )}
                      <PaginationItem>
                        <PaginationLink
                          href="#"
                          onClick={(event) => {
                            event.preventDefault();
                            onPageChange(data.pagination.totalPages);
                          }}
                        >
                          {data.pagination.totalPages}
                        </PaginationLink>
                      </PaginationItem>
                    </>
                  )}

                  {data.pagination.page < data.pagination.totalPages && (
                    <PaginationItem>
                      <PaginationNext
                        href="#"
                        onClick={(event) => {
                          event.preventDefault();
                          onPageChange(data.pagination.page + 1);
                        }}
                      />
                    </PaginationItem>
                  )}
                </PaginationContent>
              </Pagination>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ProductListing;
