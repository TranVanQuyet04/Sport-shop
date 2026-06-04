import { Link } from "react-router-dom";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { CheckCircle2, Loader2, Mail } from "lucide-react";
import { useAuthStore } from "@/store/useAuthStore";
import Container from "@/components/ui/Container";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const forgotPasswordSchema = z.object({
  email: z
    .string()
    .nonempty("Vui lòng nhập email")
    .email("Email không hợp lệ"),
});

type ForgotPasswordFormData = z.infer<typeof forgotPasswordSchema>;

const ForgotPasswordPage = () => {
  const { requestPasswordReset, loading } = useAuthStore();

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitSuccessful },
  } = useForm<ForgotPasswordFormData>({
    resolver: zodResolver(forgotPasswordSchema),
  });

  const onSubmit = async (data: ForgotPasswordFormData) => {
    try {
      await requestPasswordReset(data.email);
    } catch {
      // Error handled in store.
    }
  };

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
              Quên mật khẩu
            </h1>
            <p className="mt-2 text-sm leading-6 text-gray-600">
              Nhập email đăng ký. Chúng tôi sẽ gửi link đặt lại mật khẩu đến
              email của bạn.
            </p>
          </div>

          {isSubmitSuccessful ? (
            <div className="space-y-4 text-center">
              <CheckCircle2 className="mx-auto h-10 w-10 text-emerald-500" />
              <p className="text-sm leading-6 text-gray-600">
                Đã gửi link đặt lại mật khẩu. Vui lòng kiểm tra hộp thư email
                của bạn và cả thư mục spam.
              </p>
              <Link to="/login">
                <Button variant="outline" className="w-full">
                  Quay lại đăng nhập
                </Button>
              </Link>
            </div>
          ) : (
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

              <Button
                type="submit"
                className="h-11 w-full bg-zinc-950 font-black hover:bg-red-600"
                size="lg"
                disabled={loading}
              >
                {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {loading ? "Đang gửi..." : "Gửi link đặt lại mật khẩu"}
              </Button>
            </form>
          )}

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

export default ForgotPasswordPage;
