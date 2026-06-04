import { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Eye, EyeOff, Loader2, Lock, Mail } from "lucide-react";
import { useAuthStore } from "@/store/useAuthStore";
import Container from "@/components/ui/Container";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const loginSchema = z.object({
  email: z
    .string()
    .nonempty("Vui lòng nhập email")
    .email("Email không hợp lệ"),
  password: z
    .string()
    .nonempty("Vui lòng nhập mật khẩu")
    .min(6, "Mật khẩu tối thiểu 6 ký tự"),
});

type LoginFormData = z.infer<typeof loginSchema>;

const LoginPage = () => {
  const navigate = useNavigate();
  const { loginWithEmailPassword, user, loading } = useAuthStore();
  const [showPassword, setShowPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    try {
      const result = await loginWithEmailPassword(data.email, data.password);
      if (result.success) {
        navigate("/", { replace: true });
      }
    } catch {
      // Error handled in store.
    }
  };

  useEffect(() => {
    if (user) {
      navigate("/", { replace: true });
    }
  }, [user, navigate]);

  if (user) {
    return null;
  }

  return (
    <div className="flex min-h-[72vh] items-center justify-center py-12">
      <Container className="w-full max-w-5xl">
        <div className="grid overflow-hidden rounded-lg bg-white shadow-xl shadow-zinc-950/10 ring-1 ring-black/5 lg:grid-cols-[1fr_440px]">
          <div className="relative hidden min-h-[560px] overflow-hidden bg-zinc-950 p-10 text-white lg:block">
            <img
              src="https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=1200&q=80"
              alt="Training gear"
              className="absolute inset-0 h-full w-full object-cover opacity-65"
            />
            <div className="absolute inset-0 bg-linear-to-t from-zinc-950 via-zinc-950/55 to-zinc-950/10" />
            <div className="relative z-10 flex h-full flex-col justify-end">
              <p className="section-kicker text-red-300">Member access</p>
              <h2 className="mt-3 max-w-md text-4xl font-black leading-tight tracking-tight">
                Quản lý đơn hàng và ưu đãi nhanh hơn.
              </h2>
              <p className="mt-4 max-w-md text-sm leading-7 text-white/75">
                Đăng nhập để theo dõi giỏ hàng, địa chỉ nhận hàng và lịch sử
                mua sắm của bạn.
              </p>
            </div>
          </div>

          <div className="p-6 sm:p-8 lg:p-10">
            <div className="mb-8 text-center">
              <Link
                to="/"
                className="inline-flex items-center gap-2 text-2xl font-black tracking-tight text-gray-900 transition-colors hover:text-red-600"
              >
                <span className="flex h-10 w-10 items-center justify-center rounded-sm bg-zinc-950 text-sm font-black text-white">
                  S
                </span>
                SPORTSHOP
              </Link>
              <h1 className="mt-7 text-2xl font-black text-gray-900">
                Đăng nhập
              </h1>
              <p className="mt-2 text-sm text-gray-600">
                Chào mừng bạn trở lại. Vui lòng đăng nhập tài khoản.
              </p>
            </div>

            <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
              <div>
                <Label htmlFor="email">Email</Label>
                <div className="relative mt-1.5">
                  <Mail className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-400" />
                  <Input
                    id="email"
                    type="email"
                    placeholder="email@example.com"
                    className="h-11 pl-10"
                    {...register("email")}
                  />
                </div>
                {errors.email && (
                  <p className="mt-1 text-sm text-red-500">
                    {errors.email.message}
                  </p>
                )}
              </div>

              <div>
                <div className="flex items-center justify-between">
                  <Label htmlFor="password">Mật khẩu</Label>
                  <Link
                    to="/forgot-password"
                    className="text-sm font-semibold text-red-600 hover:text-red-700"
                  >
                    Quên mật khẩu?
                  </Link>
                </div>
                <div className="relative mt-1.5">
                  <Lock className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-400" />
                  <Input
                    id="password"
                    type={showPassword ? "text" : "password"}
                    placeholder="Nhập mật khẩu"
                    className="h-11 pl-10 pr-11"
                    {...register("password")}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((value) => !value)}
                    className="absolute right-2 top-1/2 inline-flex h-8 w-8 -translate-y-1/2 items-center justify-center rounded-sm text-zinc-500 hover:bg-zinc-100 hover:text-zinc-950"
                    aria-label={showPassword ? "Ẩn mật khẩu" : "Hiện mật khẩu"}
                  >
                    {showPassword ? (
                      <EyeOff className="h-4 w-4" />
                    ) : (
                      <Eye className="h-4 w-4" />
                    )}
                  </button>
                </div>
                {errors.password && (
                  <p className="mt-1 text-sm text-red-500">
                    {errors.password.message}
                  </p>
                )}
              </div>

              <Button
                type="submit"
                className="h-11 w-full bg-zinc-950 font-black hover:bg-red-600"
                size="lg"
                disabled={loading}
              >
                {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {loading ? "Đang đăng nhập..." : "Đăng nhập"}
              </Button>
            </form>

            <p className="mt-4 rounded-sm border border-amber-200 bg-amber-50 p-3 text-xs text-amber-800">
              <strong>Test khi API lỗi:</strong> test@sportshop.vn / Test123!
            </p>

            <p className="mt-6 text-center text-sm text-gray-600">
              Chưa có tài khoản?{" "}
              <Link
                to="/register"
                className="font-bold text-red-600 hover:text-red-700"
              >
                Đăng ký ngay
              </Link>
            </p>
          </div>
        </div>
      </Container>
    </div>
  );
};

export default LoginPage;
