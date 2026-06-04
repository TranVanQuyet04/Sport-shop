import { useState } from "react";
import { Link, useNavigate, useSearchParams } from "react-router-dom";
import { useForm, type UseFormRegisterReturn } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Eye, EyeOff, Loader2, Lock, ShieldAlert } from "lucide-react";
import { useAuthStore } from "@/store/useAuthStore";
import Container from "@/components/ui/Container";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const resetPasswordSchema = z
  .object({
    newPassword: z
      .string()
      .nonempty("Vui lòng nhập mật khẩu mới")
      .min(6, "Mật khẩu tối thiểu 6 ký tự"),
    confirmPassword: z.string().nonempty("Vui lòng xác nhận mật khẩu"),
  })
  .refine((data) => data.newPassword === data.confirmPassword, {
    message: "Mật khẩu xác nhận không khớp",
    path: ["confirmPassword"],
  });

type ResetPasswordFormData = z.infer<typeof resetPasswordSchema>;

const ResetPasswordPage = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const token = searchParams.get("token");
  const { resetPassword, loading } = useAuthStore();
  const [showPassword, setShowPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ResetPasswordFormData>({
    resolver: zodResolver(resetPasswordSchema),
  });

  const onSubmit = async (data: ResetPasswordFormData) => {
    if (!token) return;

    try {
      const result = await resetPassword(
        token,
        data.newPassword,
        data.confirmPassword,
      );
      if (result?.success === true) {
        navigate("/login", { replace: true });
      }
    } catch {
      // Error handled in store.
    }
  };

  if (!token) {
    return (
      <div className="flex min-h-[68vh] items-center justify-center py-12">
        <Container className="w-full max-w-md">
          <div className="rounded-lg bg-white p-8 text-center shadow-xl shadow-zinc-950/10 ring-1 ring-black/5">
            <ShieldAlert className="mx-auto h-10 w-10 text-red-500" />
            <h1 className="mt-5 text-xl font-black text-gray-900">
              Link không hợp lệ
            </h1>
            <p className="mt-2 text-sm leading-6 text-gray-600">
              Link đặt lại mật khẩu không hợp lệ hoặc đã hết hạn. Vui lòng yêu
              cầu gửi lại.
            </p>
            <Link to="/forgot-password" className="mt-6 block">
              <Button className="bg-zinc-950 font-black hover:bg-red-600">
                Quên mật khẩu
              </Button>
            </Link>
          </div>
        </Container>
      </div>
    );
  }

  return (
    <div className="flex min-h-[68vh] items-center justify-center py-12">
      <Container className="w-full max-w-md">
        <div className="rounded-lg bg-white p-8 shadow-xl shadow-zinc-950/10 ring-1 ring-black/5">
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
              Đặt lại mật khẩu
            </h1>
            <p className="mt-2 text-sm text-gray-600">
              Nhập mật khẩu mới cho tài khoản của bạn.
            </p>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
            <PasswordInput
              id="newPassword"
              label="Mật khẩu mới"
              placeholder="Tối thiểu 6 ký tự"
              showPassword={showPassword}
              error={errors.newPassword?.message}
              register={register("newPassword")}
            />

            <PasswordInput
              id="confirmPassword"
              label="Xác nhận mật khẩu mới"
              placeholder="Nhập lại mật khẩu mới"
              showPassword={showPassword}
              error={errors.confirmPassword?.message}
              register={register("confirmPassword")}
            />

            <button
              type="button"
              onClick={() => setShowPassword((value) => !value)}
              className="inline-flex items-center gap-2 text-sm font-semibold text-zinc-600 hover:text-zinc-950"
            >
              {showPassword ? (
                <EyeOff className="h-4 w-4" />
              ) : (
                <Eye className="h-4 w-4" />
              )}
              {showPassword ? "Ẩn mật khẩu" : "Hiện mật khẩu"}
            </button>

            <Button
              type="submit"
              className="h-11 w-full bg-zinc-950 font-black hover:bg-red-600"
              size="lg"
              disabled={loading}
            >
              {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              {loading ? "Đang xử lý..." : "Đặt lại mật khẩu"}
            </Button>
          </form>

          <p className="mt-6 text-center">
            <Link
              to="/login"
              className="text-sm font-semibold text-red-600 hover:text-red-700"
            >
              ← Quay lại đăng nhập
            </Link>
          </p>
        </div>
      </Container>
    </div>
  );
};

const PasswordInput = ({
  id,
  label,
  placeholder,
  showPassword,
  error,
  register,
}: {
  id: string;
  label: string;
  placeholder: string;
  showPassword: boolean;
  error?: string;
  register: UseFormRegisterReturn;
}) => (
  <div>
    <Label htmlFor={id}>{label}</Label>
    <div className="relative mt-1.5">
      <Lock className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-400" />
      <Input
        id={id}
        type={showPassword ? "text" : "password"}
        placeholder={placeholder}
        className="h-11 pl-10"
        {...register}
      />
    </div>
    {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
  </div>
);

export default ResetPasswordPage;
