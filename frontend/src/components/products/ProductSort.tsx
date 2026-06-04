import { Grid3X3, List } from "lucide-react";

interface ProductSortProps {
  sortBy: string;
  onSortChange: (sortBy: string) => void;
}

const sortOptions = [
  { value: "newest", label: "Newest" },
  { value: "price_asc", label: "Price low to high" },
  { value: "price_desc", label: "Price high to low" },
  { value: "rating", label: "Top rated" },
];

const ProductSort = ({ sortBy, onSortChange }: ProductSortProps) => {
  return (
    <div className="flex flex-col gap-3 rounded-sm bg-white p-3 ring-1 ring-black/5 sm:flex-row sm:items-center sm:justify-between">
      <div className="flex items-center gap-3">
        <span className="text-xs font-black uppercase tracking-[0.2em] text-zinc-400">
          Sort
        </span>
        <select
          value={sortBy}
          onChange={(event) => onSortChange(event.target.value)}
          className="h-10 rounded-sm border border-zinc-200 bg-white px-3 text-sm font-semibold text-zinc-800 outline-none transition hover:border-zinc-400 focus:border-zinc-950"
        >
          {sortOptions.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
      </div>

      <div className="flex items-center gap-2">
        <button className="inline-flex h-10 w-10 items-center justify-center rounded-sm border border-zinc-200 bg-zinc-950 text-white">
          <Grid3X3 className="h-4 w-4" />
        </button>
        <button className="inline-flex h-10 w-10 items-center justify-center rounded-sm border border-zinc-200 bg-white text-zinc-500 transition hover:text-zinc-950">
          <List className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
};

export default ProductSort;
