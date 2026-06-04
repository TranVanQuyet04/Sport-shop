import AuthDialog from "@/components/auth/AuthDialog";
import { Search } from "lucide-react";
import CartSheet from "../CartSheet";

const HeaderIcons = () => {
  return (
    <div className="flex items-center gap-2">
      <button className="hidden h-10 items-center gap-3 rounded-full border border-zinc-200 bg-zinc-50 px-4 text-sm text-zinc-500 transition hover:border-zinc-300 hover:bg-white sm:inline-flex lg:w-56">
        <Search className="h-4 w-4 text-gray-500" />
        <span>Search products</span>
      </button>
      <AuthDialog />
      <CartSheet />
    </div>
  );
};

export default HeaderIcons;
