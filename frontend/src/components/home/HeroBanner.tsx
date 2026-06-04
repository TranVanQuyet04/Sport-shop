const HeroBanner = () => {
  return (
    <section className="relative min-h-[640px] overflow-hidden bg-zinc-950">
      <img
        src="https://cdn.shopify.com/s/files/1/0456/5070/6581/files/LP_12.12_KV_DESK_NEW_VN.jpg?v=1765186097&width=1440"
        alt="Sportswear collection"
        className="absolute inset-0 h-full w-full object-cover"
      />
      <div className="absolute inset-0 bg-[linear-gradient(90deg,rgba(9,9,11,0.88)_0%,rgba(9,9,11,0.48)_48%,rgba(9,9,11,0.22)_100%)]" />
      <div className="absolute inset-x-0 bottom-0 h-44 bg-linear-to-t from-[#fafaf8] to-transparent" />

      <div className="relative z-10 mx-auto flex min-h-[640px] w-full max-w-[1600px] items-end px-4 pb-16 sm:px-6 md:px-8 lg:px-12 xl:px-16">
        <div className="max-w-3xl text-white">
          <p className="mb-4 inline-flex rounded-full border border-white/20 bg-white/10 px-4 py-2 text-xs font-black uppercase tracking-[0.24em] text-white/80 backdrop-blur">
            New season essentials
          </p>
          <h1 className="max-w-3xl text-5xl font-black leading-[0.95] tracking-tight sm:text-6xl lg:text-7xl">
            Gear up for every move.
          </h1>
          <p className="mt-5 max-w-xl text-base leading-7 text-white/80 sm:text-lg">
            Performance apparel, shoes, and accessories selected for training,
            streetwear, and everyday comfort.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <a
              href="/collections"
              className="inline-flex h-12 items-center justify-center rounded-sm bg-red-600 px-7 text-sm font-black uppercase tracking-wide text-white shadow-lg shadow-red-950/30 transition hover:bg-white hover:text-zinc-950"
            >
              Shop collection
            </a>
            <a
              href="/brands"
              className="inline-flex h-12 items-center justify-center rounded-sm border border-white/60 bg-white/10 px-7 text-sm font-black uppercase tracking-wide text-white backdrop-blur transition hover:bg-white hover:text-zinc-950"
            >
              Explore brands
            </a>
          </div>
          <div className="mt-10 grid max-w-2xl grid-cols-3 gap-3 text-white">
            {[
              ["500+", "Products"],
              ["20+", "Top brands"],
              ["24h", "Fast support"],
            ].map(([value, label]) => (
              <div
                key={label}
                className="border border-white/15 bg-white/10 p-4 backdrop-blur"
              >
                <p className="text-2xl font-black">{value}</p>
                <p className="mt-1 text-xs font-semibold uppercase tracking-[0.18em] text-white/60">
                  {label}
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default HeroBanner;
