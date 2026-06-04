import { Link, useNavigate } from "react-router";
import {
  LayoutDashboard,
  LogOut,
  PackageSearch,
  ShieldCheck,
  User,
  UserCircle,
} from "lucide-react";
import { toast } from "sonner";
import { useAuthStore } from "@/store/useAuthStore";
import { Button } from "../ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

const ADMIN_ROLES = ["Quản Trị Viên", "Người giao hàng"];

const AuthDialog = () => {
  const { user, logout } = useAuthStore();
  const navigate = useNavigate();
  const isAdminRole = user?.roleName && ADMIN_ROLES.includes(user.roleName);

  const handleLogout = async () => {
    try {
      await logout();
    } catch (error) {
      console.error("Logout error:", error);
      toast.error("Đăng xuất thất bại, vui lòng thử lại");
    }
  };

  if (!user) {
    return (
      <Link to="/login">
        <Button variant="header" className="cursor-pointer">
          <User className="h-5 w-5 text-gray-700" />
        </Button>
      </Link>
    );
  }

  return (
    <DropdownMenu modal={false}>
      <DropdownMenuTrigger asChild>
        <Button
          variant="header"
          className="relative cursor-pointer hover:bg-red-50"
          aria-label="Tài khoản"
        >
          <User className="h-5 w-5 text-gray-700" />
          <span className="absolute -right-0.5 -top-0.5 h-2.5 w-2.5 rounded-full bg-emerald-500 ring-2 ring-white" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent className="mr-10 mt-3.5 w-64 rounded-lg p-2">
        <DropdownMenuLabel>
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-zinc-950 text-sm font-black text-white">
              {(user.fullName || user.full_name || user.email || "U")
                .charAt(0)
                .toUpperCase()}
            </div>
            <div className="min-w-0">
              <p className="truncate font-black">
                {user.fullName || user.full_name || "Tài khoản của tôi"}
              </p>
              <p className="truncate text-xs font-normal text-zinc-500">
                {user.email}
              </p>
            </div>
          </div>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />

        {isAdminRole ? (
          <DropdownMenuItem
            onClick={() => navigate("/admin")}
            className="cursor-pointer rounded-md"
          >
            <LayoutDashboard className="mr-2 h-4 w-4" />
            <span>Dashboard quản trị</span>
          </DropdownMenuItem>
        ) : (
          <>
            <DropdownMenuItem
              onClick={() => navigate("/account/profile")}
              className="cursor-pointer rounded-md"
            >
              <UserCircle className="mr-2 h-4 w-4" />
              <span>Hồ sơ cá nhân</span>
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={() => navigate("/account/orders")}
              className="cursor-pointer rounded-md"
            >
              <PackageSearch className="mr-2 h-4 w-4" />
              <span>Theo dõi đơn hàng</span>
            </DropdownMenuItem>
          </>
        )}

        <DropdownMenuItem
          onClick={() => navigate("/collections")}
          className="cursor-pointer rounded-md"
        >
          <ShieldCheck className="mr-2 h-4 w-4" />
          <span>Tiếp tục mua sắm</span>
        </DropdownMenuItem>

        <DropdownMenuSeparator />
        <DropdownMenuItem
          variant="destructive"
          onClick={handleLogout}
          className="cursor-pointer rounded-md text-red-600 focus:text-red-600"
        >
          <LogOut className="mr-2 h-4 w-4" />
          <span>Đăng xuất</span>
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
};

export default AuthDialog;
