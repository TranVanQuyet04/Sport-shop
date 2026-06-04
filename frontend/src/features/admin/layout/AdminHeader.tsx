import { Bell } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";

interface AdminHeaderProps {
  activePrimary: "system" | "chat";
  selectedRoomId: number | null;
}

export function AdminHeader({
  activePrimary,
  selectedRoomId,
}: AdminHeaderProps) {
  return (
    <header className="flex h-16 flex-none items-center justify-between border-b border-black/5 bg-white px-6 shadow-sm">
      <div className="flex items-center gap-2">
        {activePrimary === "chat" && selectedRoomId ? (
          <>
            <Badge
              variant="outline"
              className="text-green-600 border-green-200 bg-green-50"
            >
              Online
            </Badge>
            <span className="font-semibold text-sm">
              Đang chat với khách hàng #{selectedRoomId}
            </span>
          </>
        ) : (
          <span className="text-sm text-muted-foreground">
            Tổng quan hệ thống
          </span>
        )}
      </div>

      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" className="rounded-sm">
          <Bell className="w-5 h-5 text-muted-foreground" />
        </Button>
        <Avatar className="h-8 w-8">
          <AvatarFallback className="bg-slate-900 text-white">
            AD
          </AvatarFallback>
        </Avatar>
      </div>
    </header>
  );
}
