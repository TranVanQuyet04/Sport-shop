import { ArrowRight, Loader2 } from "lucide-react";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router";
import { useBrands } from "@/hooks/useBrandsQuery";

const FavoriteBrands = () => {
  const [timeLeft, setTimeLeft] = useState("");
  const navigate = useNavigate();
  const { data: brandData, isLoading } = useBrands();
  const brands = brandData?.data?.brands || [];

  useEffect(() => {
    const targetDate = new Date("2026-12-25T00:00:00");
    const interval = setInterval(() => {
      const now = new Date();
      const difference = targetDate.getTime() - now.getTime();

      if (difference <= 0) {
        clearInterval(interval);
        setTimeLeft("Event started");
        return;
      }

      const days = Math.floor(difference / (1000 * 60 * 60 * 24));
      const hours = Math.floor((difference / (1000 * 60 * 60)) % 24);
      const minutes = Math.floor((difference / (1000 * 60)) % 60);
      setTimeLeft(`${days}d ${hours}h ${minutes}m`);
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <section className="rounded-sm bg-white p-5 shadow-sm ring-1 ring-black/5 sm:p-8">
      <div className="mb-7 flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <p className="text-xs font-semibold uppercase tracking-[0.24em] text-red-600">
            Featured brands
          </p>
          <h2 className="mt-2 text-2xl font-black tracking-tight text-zinc-950 sm:text-3xl">
            Built for your rotation
          </h2>
        </div>
        <p className="rounded-full bg-red-50 px-4 py-2 text-sm font-semibold text-red-700">
          Deal countdown: {timeLeft || "..."}
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        {isLoading ? (
          <div className="col-span-full flex items-center justify-center gap-2 py-12 text-gray-500">
            <Loader2 className="h-5 w-5 animate-spin" />
            Loading brands...
          </div>
        ) : brands.length === 0 ? (
          <div className="col-span-full py-12 text-center text-gray-500">
            No brands available
          </div>
        ) : (
          brands.slice(0, 4).map((brand) => (
            <div
              key={brand.id}
              className="group relative min-h-[240px] overflow-hidden rounded-sm bg-zinc-950"
            >
              <img
                src={
                  brand.logo ||
                  `https://placehold.co/700x300?text=${brand.brandName}`
                }
                alt={brand.brandName}
                className="absolute inset-0 h-full w-full object-cover opacity-80 transition duration-500 group-hover:scale-105 group-hover:opacity-95"
              />
              <div className="absolute inset-0 bg-linear-to-t from-black/75 via-black/20 to-transparent" />
              <div className="absolute inset-x-0 bottom-0 flex items-end justify-between gap-4 p-5">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-[0.2em] text-white/60">
                    Brand
                  </p>
                  <h3 className="mt-1 text-2xl font-black text-white">
                    {brand.name ?? brand.brandName}
                  </h3>
                </div>
                <button
                  onClick={() => navigate(`/collections?brand=${brand.slug}`)}
                  className="inline-flex h-10 shrink-0 items-center gap-2 rounded-sm bg-white px-4 text-sm font-bold uppercase text-black transition hover:bg-red-500 hover:text-white"
                >
                  Shop
                  <ArrowRight className="h-4 w-4" />
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </section>
  );
};

export default FavoriteBrands;
