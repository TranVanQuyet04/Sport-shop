import { LayoutDashboard, MessageSquare, LogOut } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { Badge } from "@/components/ui/badge";
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { useAuthStore } from "@/store/useAuthStore";

interface AdminSidebarProps {
  activePrimary: "system" | "chat";
  setActivePrimary: (value: "system" | "chat") => void;
  unreadCount: number;
  onLogout: () => void;
}

export function AdminSidebar({
  activePrimary,
  setActivePrimary,
  unreadCount,
  onLogout,
}: AdminSidebarProps) {
  const { user } = useAuthStore();
  const roleName = user?.roleName;
  const isShipper = roleName === "Người giao hàng";
  return (
    <aside className="z-20 flex w-[76px] flex-none flex-col items-center gap-6 bg-zinc-950 py-6 text-slate-50 shadow-2xl shadow-black/20">
      <div className="flex h-11 w-11 items-center justify-center rounded-sm bg-white text-lg font-black text-zinc-950 shadow-lg">
        S
      </div>

      <Separator className="w-10 bg-white/10" />

      {/* Nút Quản Lý */}
      <Tooltip delayDuration={0}>
        <TooltipTrigger asChild>
          <Button
            variant={activePrimary === "system" ? "secondary" : "ghost"}
            size="icon"
            className={`h-12 w-12 rounded-sm transition-all ${
              activePrimary === "system"
                ? "bg-white text-zinc-950 hover:bg-white"
                : "text-slate-400 hover:bg-white/10 hover:text-white"
            }`}
            onClick={() => setActivePrimary("system")}
          >
            <LayoutDashboard className="w-6 h-6" />
          </Button>
        </TooltipTrigger>
        <TooltipContent side="right">Quản lý hệ thống</TooltipContent>
      </Tooltip>

      {/* Nút Chat (kèm Badge) - chỉ Quản Trị Viên */}
      {!isShipper && (
        <Tooltip delayDuration={0}>
          <TooltipTrigger asChild>
            <div className="relative">
              <Button
                variant={activePrimary === "chat" ? "secondary" : "ghost"}
                size="icon"
                className={`h-12 w-12 rounded-sm transition-all ${
                  activePrimary === "chat"
                    ? "bg-white text-zinc-950 hover:bg-white"
                    : "text-slate-400 hover:bg-white/10 hover:text-white"
                }`}
                onClick={() => setActivePrimary("chat")}
              >
                <MessageSquare className="w-6 h-6" />
              </Button>
              {/* Badge thông báo đỏ chót */}
              {unreadCount > 0 && (
                <Badge
                  variant="destructive"
                  className="absolute -top-1 -right-1 h-5 w-5 flex items-center justify-center p-0 rounded-full border-2 border-slate-950"
                >
                  {unreadCount}
                </Badge>
              )}
            </div>
          </TooltipTrigger>
          <TooltipContent side="right">Tin nhắn khách hàng</TooltipContent>
        </Tooltip>
      )}

      <div className="mt-auto flex flex-col gap-4">
        <Button
          variant="ghost"
          size="icon"
          className="h-12 w-12 rounded-sm text-slate-400 hover:bg-white/10 hover:text-red-400"
          onClick={onLogout}
        >
          <LogOut className="w-6 h-6" />
        </Button>
      </div>
    </aside>
  );
}
