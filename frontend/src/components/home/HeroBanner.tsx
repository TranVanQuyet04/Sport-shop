const HeroBanner = () => {
  return (
    <section className="relative min-h-[620px] overflow-hidden bg-black">
      <img
        src="https://cdn.shopify.com/s/files/1/0456/5070/6581/files/LP_12.12_KV_DESK_NEW_VN.jpg?v=1765186097&width=1440"
        alt="Sportswear collection"
        className="absolute inset-0 h-full w-full object-cover"
      />
      <div className="absolute inset-0 bg-black/45" />
      <div className="absolute inset-x-0 bottom-0 h-40 bg-linear-to-t from-[#f7f7f5] to-transparent" />

      <div className="relative z-10 mx-auto flex min-h-[620px] w-full max-w-[1600px] items-end px-4 pb-16 sm:px-6 md:px-8 lg:px-12 xl:px-16">
        <div className="max-w-2xl text-white">
          <p className="mb-4 text-xs font-semibold uppercase tracking-[0.3em] text-white/75">
            New season essentials
          </p>
          <h1 className="text-5xl font-black leading-none sm:text-6xl lg:text-7xl">
            Gear up for every move.
          </h1>
          <p className="mt-5 max-w-xl text-base leading-7 text-white/80 sm:text-lg">
            Performance apparel, shoes, and accessories selected for training,
            streetwear, and everyday comfort.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <a
              href="/collections"
              className="inline-flex h-12 items-center justify-center rounded-sm bg-white px-7 text-sm font-bold uppercase text-black transition hover:bg-red-500 hover:text-white"
            >
              Shop collection
            </a>
            <a
              href="/brands"
              className="inline-flex h-12 items-center justify-center rounded-sm border border-white/70 px-7 text-sm font-bold uppercase text-white transition hover:bg-white hover:text-black"
            >
              Explore brands
            </a>
          </div>
        </div>
      </div>
    </section>
  );
};

export default HeroBanner;
