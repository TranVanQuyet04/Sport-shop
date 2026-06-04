import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useForm, type UseFormRegisterReturn } from "react-hook-form";
import type { ReactNode } from "react";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Eye, EyeOff, Loader2, Lock, Mail, Phone, User } from "lucide-react";
import { toast } from "sonner";
import { useAuthStore } from "@/store/useAuthStore";
import Container from "@/components/ui/Container";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const registerSchema = z
  .object({
    fullName: z
      .string()
      .nonempty("Vui lòng nhập họ tên")
      .min(2, "Họ tên tối thiểu 2 ký tự"),
    email: z
      .string()
      .nonempty("Vui lòng nhập email")
      .email("Email không hợp lệ"),
    password: z
      .string()
      .nonempty("Vui lòng nhập mật khẩu")
      .regex(
        /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/,
        "Mật khẩu tối thiểu 8 ký tự, gồm chữ và số",
      ),
    confirmPassword: z.string().nonempty("Vui lòng xác nhận mật khẩu"),
    phoneNumber: z.string().nonempty("Vui lòng nhập số điện thoại"),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Mật khẩu xác nhận không khớp",
    path: ["confirmPassword"],
  });

type RegisterFormData = z.infer<typeof registerSchema>;

const RegisterPage = () => {
  const navigate = useNavigate();
  const { registerWithEmail, loading } = useAuthStore();
  const [showPassword, setShowPassword] = useState(false);

  const form = useForm<RegisterFormData>({
    resolver: zodResolver(registerSchema),
  });

  const onSubmit = async (data: RegisterFormData) => {
    try {
      const result = await registerWithEmail(data);
      if (result?.id ?? result?.email) {
        toast.success("Đăng ký thành công! Vui lòng đăng nhập.", {
          duration: 2500,
        });
      }
      setTimeout(() => {
        navigate("/login", { replace: true });
      }, 400);
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <div className="flex min-h-[72vh] items-center justify-center py-12">
      <Container className="w-full max-w-5xl">
        <div className="grid overflow-hidden rounded-lg bg-white shadow-xl shadow-zinc-950/10 ring-1 ring-black/5 lg:grid-cols-[420px_1fr]">
          <div className="relative hidden min-h-[620px] overflow-hidden bg-zinc-950 p-10 text-white lg:block">
            <img
              src="https://images.unsplash.com/photo-1511556532299-8f662fc26c06?auto=format&fit=crop&w=1200&q=80"
              alt="Sports shoes"
              className="absolute inset-0 h-full w-full object-cover opacity-65"
            />
            <div className="absolute inset-0 bg-linear-to-t from-zinc-950 via-zinc-950/55 to-zinc-950/10" />
            <div className="relative z-10 flex h-full flex-col justify-end">
              <p className="section-kicker text-red-300">Join SPORTSHOP</p>
              <h2 className="mt-3 text-4xl font-black leading-tight tracking-tight">
                Tạo tài khoản để mua sắm nhanh hơn.
              </h2>
              <p className="mt-4 text-sm leading-7 text-white/75">
                Lưu địa chỉ, theo dõi đơn hàng và nhận ưu đãi cho thành viên.
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
                Đăng ký tài khoản
              </h1>
              <p className="mt-2 text-sm text-gray-600">
                Tạo tài khoản để mua sắm và theo dõi đơn hàng.
              </p>
            </div>

            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5">
              <div className="grid gap-5 sm:grid-cols-2">
                <Field
                  id="full_name"
                  label="Họ và tên"
                  icon={<User className="h-4 w-4" />}
                  error={form.formState.errors.fullName?.message}
                >
                  <Input
                    id="full_name"
                    placeholder="Nguyễn Văn A"
                    className="h-11 pl-10"
                    {...form.register("fullName")}
                  />
                </Field>

                <Field
                  id="phoneNumber"
                  label="Số điện thoại"
                  icon={<Phone className="h-4 w-4" />}
                  error={form.formState.errors.phoneNumber?.message}
                >
                  <Input
                    id="phoneNumber"
                    type="tel"
                    placeholder="09xxxxxxxx"
                    className="h-11 pl-10"
                    {...form.register("phoneNumber")}
                  />
                </Field>
              </div>

              <Field
                id="email"
                label="Email"
                icon={<Mail className="h-4 w-4" />}
                error={form.formState.errors.email?.message}
              >
                <Input
                  id="email"
                  type="email"
                  placeholder="email@example.com"
                  className="h-11 pl-10"
                  {...form.register("email")}
                />
              </Field>

              <div className="grid gap-5 sm:grid-cols-2">
                <PasswordField
                  id="password"
                  label="Mật khẩu"
                  placeholder="Tối thiểu 8 ký tự"
                  showPassword={showPassword}
                  error={form.formState.errors.password?.message}
                  register={form.register("password")}
                />
                <PasswordField
                  id="confirmPassword"
                  label="Xác nhận mật khẩu"
                  placeholder="Nhập lại mật khẩu"
                  showPassword={showPassword}
                  error={form.formState.errors.confirmPassword?.message}
                  register={form.register("confirmPassword")}
                />
              </div>

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
                {loading ? "Đang đăng ký..." : "Đăng ký"}
              </Button>
            </form>

            <p className="mt-6 text-center text-sm text-gray-600">
              Đã có tài khoản?{" "}
              <Link
                to="/login"
                className="font-bold text-red-600 hover:text-red-700"
              >
                Đăng nhập ngay
              </Link>
            </p>
          </div>
        </div>
      </Container>
    </div>
  );
};

const Field = ({
  id,
  label,
  icon,
  error,
  children,
}: {
  id: string;
  label: string;
  icon: ReactNode;
  error?: string;
  children: ReactNode;
}) => (
  <div>
    <Label htmlFor={id}>{label}</Label>
    <div className="relative mt-1.5">
      <span className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400">
        {icon}
      </span>
      {children}
    </div>
    {error && <p className="mt-1 text-sm text-red-500">{error}</p>}
  </div>
);

const PasswordField = ({
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

export default RegisterPage;
