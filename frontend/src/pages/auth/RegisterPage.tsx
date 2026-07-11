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
      .nonempty("Vui lÃ²ng nháº­p há» tÃªn")
      .min(2, "Há» tÃªn tá»‘i thiá»ƒu 2 kÃ½ tá»±"),
    email: z
      .string()
      .nonempty("Vui lÃ²ng nháº­p email")
      .email("Email khÃ´ng há»£p lá»‡"),
    password: z
      .string()
      .nonempty("Vui lÃ²ng nháº­p máº­t kháº©u")
      .regex(
        /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/,
        "Máº­t kháº©u tá»‘i thiá»ƒu 8 kÃ½ tá»±, gá»“m chá»¯ vÃ  sá»‘",
      ),
    confirmPassword: z.string().nonempty("Vui lÃ²ng xÃ¡c nháº­n máº­t kháº©u"),
    phoneNumber: z.string().nonempty("Vui lÃ²ng nháº­p sá»‘ Ä‘iá»‡n thoáº¡i"),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: "Máº­t kháº©u xÃ¡c nháº­n khÃ´ng khá»›p",
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
        toast.success("ÄÄƒng kÃ½ thÃ nh cÃ´ng! Vui lÃ²ng Ä‘Äƒng nháº­p.", {
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
              <p className="section-kicker text-red-300">Join StrideX</p>
              <h2 className="mt-3 text-4xl font-black leading-tight tracking-tight">
                Táº¡o tÃ i khoáº£n Ä‘á»ƒ mua sáº¯m nhanh hÆ¡n.
              </h2>
              <p className="mt-4 text-sm leading-7 text-white/75">
                LÆ°u Ä‘á»‹a chá»‰, theo dÃµi Ä‘Æ¡n hÃ ng vÃ  nháº­n Æ°u Ä‘Ã£i cho thÃ nh viÃªn.
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
                StrideX
              </Link>
              <h1 className="mt-7 text-2xl font-black text-gray-900">
                ÄÄƒng kÃ½ tÃ i khoáº£n
              </h1>
              <p className="mt-2 text-sm text-gray-600">
                Táº¡o tÃ i khoáº£n Ä‘á»ƒ mua sáº¯m vÃ  theo dÃµi Ä‘Æ¡n hÃ ng.
              </p>
            </div>

            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5">
              <div className="grid gap-5 sm:grid-cols-2">
                <Field
                  id="full_name"
                  label="Há» vÃ  tÃªn"
                  icon={<User className="h-4 w-4" />}
                  error={form.formState.errors.fullName?.message}
                >
                  <Input
                    id="full_name"
                    placeholder="Nguyá»…n VÄƒn A"
                    className="h-11 pl-10"
                    {...form.register("fullName")}
                  />
                </Field>

                <Field
                  id="phoneNumber"
                  label="Sá»‘ Ä‘iá»‡n thoáº¡i"
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
                  label="Máº­t kháº©u"
                  placeholder="Tá»‘i thiá»ƒu 8 kÃ½ tá»±"
                  showPassword={showPassword}
                  error={form.formState.errors.password?.message}
                  register={form.register("password")}
                />
                <PasswordField
                  id="confirmPassword"
                  label="XÃ¡c nháº­n máº­t kháº©u"
                  placeholder="Nháº­p láº¡i máº­t kháº©u"
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
                {showPassword ? "áº¨n máº­t kháº©u" : "Hiá»‡n máº­t kháº©u"}
              </button>

              <Button
                type="submit"
                className="h-11 w-full bg-zinc-950 font-black hover:bg-red-600"
                size="lg"
                disabled={loading}
              >
                {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {loading ? "Äang Ä‘Äƒng kÃ½..." : "ÄÄƒng kÃ½"}
              </Button>
            </form>

            <p className="mt-6 text-center text-sm text-gray-600">
              ÄÃ£ cÃ³ tÃ i khoáº£n?{" "}
              <Link
                to="/login"
                className="font-bold text-red-600 hover:text-red-700"
              >
                ÄÄƒng nháº­p ngay
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
