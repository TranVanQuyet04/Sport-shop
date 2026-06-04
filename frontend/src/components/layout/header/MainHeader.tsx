import { Menu } from "lucide-react";
import NavigationMenu from "./navbar/NavigationMenu";
import Logo from "./navbar/Logo";
import HeaderIcons from "./navbar/HeaderIcons";

const MainHeader = () => {
  return (
    <div className="relative w-full border-b border-black/5 bg-white/90 shadow-sm shadow-zinc-950/5 backdrop-blur-xl">
      <div className="w-full max-w-[1600px] mx-auto px-4 sm:px-6 md:px-8 lg:px-12 xl:px-16">
        <div className="flex h-16 items-center justify-between">
          <Logo />

          {/* Navigation Menu */}
          <div className="hidden lg:block flex-1 mx-8 relative z-10">
            <NavigationMenu />
          </div>

          <div className="flex items-center gap-2">
            <HeaderIcons />
            <button className="inline-flex h-10 w-10 items-center justify-center rounded-sm border border-zinc-200 bg-white text-zinc-900 transition hover:border-zinc-950 hover:bg-zinc-950 hover:text-white lg:hidden">
              <Menu className="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default MainHeader;
