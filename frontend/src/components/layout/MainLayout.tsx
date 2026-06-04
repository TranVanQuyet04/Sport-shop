import { Outlet } from "react-router";
import Header from "@/components/layout/header/Header";
import AnnouncementBanner from "@/components/layout/header/AnnouncementBanner";
import Footer from "@/components/layout/footer/Footer";

const MainLayout = () => {
  return (
    <div className="min-h-screen flex flex-col bg-[#f7f7f5] overflow-x-hidden w-full text-zinc-950">
      <Header />
      <AnnouncementBanner />
      <main className="flex-1">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
};

export default MainLayout;
