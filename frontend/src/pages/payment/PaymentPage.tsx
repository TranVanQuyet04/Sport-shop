import { useParams, useNavigate } from "react-router-dom";
import { useMutation } from "@tanstack/react-query";
import { CheckCircle2, Landmark, Loader2, PackageSearch } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import Container from "@/components/ui/Container";
import { PaymentAPI } from "@/services/payment.api";
import { updateLatestOrder } from "@/utils/orderStorage";

export default function PaymentPage() {
  const { paymentId } = useParams();
  const navigate = useNavigate();

  const confirmMutation = useMutation({
    mutationFn: () => PaymentAPI.confirmTransfer(Number(paymentId)),
    onSuccess: () => {
      toast.success("Đã gửi xác nhận chuyển khoản");
      navigate("/account/orders");
    },
    onError: () => {
      updateLatestOrder({
        status: "PENDING",
      });

      toast.info("Đang dùng dữ liệu demo cho chuyển khoản");
      navigate("/account/orders");
    },
  });

  return (
    <div className="min-h-[70vh] py-10">
      <Container className="max-w-3xl">
        <div className="grid overflow-hidden rounded-lg bg-white shadow-xl shadow-zinc-950/10 ring-1 ring-black/5 md:grid-cols-[1fr_320px]">
          <section className="p-6 sm:p-8">
            <p className="section-kicker">Bank transfer</p>
            <h1 className="mt-2 text-3xl font-black tracking-tight text-zinc-950">
              Thanh toán chuyển khoản
            </h1>
            <p className="mt-3 text-sm leading-6 text-zinc-600">
              Sau khi xác nhận, đơn hàng của bạn sẽ xuất hiện trong trang theo
              dõi đơn hàng với trạng thái mới nhất.
            </p>

            <div className="mt-7 space-y-3 rounded-lg border border-zinc-100 bg-zinc-50 p-5 text-sm">
              <div className="flex items-center gap-3">
                <Landmark className="h-5 w-5 text-red-600" />
                <p className="font-black text-zinc-950">Thông tin nhận tiền</p>
              </div>
              <p>
                <b>Ngân hàng:</b> Vietcombank
              </p>
              <p>
                <b>STK:</b> 0123 456 789
              </p>
              <p>
                <b>Chủ TK:</b> NGUYEN VAN A
              </p>
              <p className="rounded-sm bg-red-50 px-3 py-2 font-bold text-red-600">
                Nội dung chuyển khoản: PAY-{paymentId}
              </p>
            </div>

            <div className="mt-7 flex flex-col gap-3 sm:flex-row">
              <Button
                className="h-11 flex-1 bg-zinc-950 font-black hover:bg-red-600"
                onClick={() => confirmMutation.mutate()}
                disabled={confirmMutation.isPending}
              >
                {confirmMutation.isPending ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <CheckCircle2 className="mr-2 h-4 w-4" />
                )}
                Tôi đã chuyển khoản
              </Button>
              <Button
                variant="outline"
                className="h-11 flex-1 font-bold"
                onClick={() => navigate("/account/orders")}
              >
                <PackageSearch className="mr-2 h-4 w-4" />
                Theo dõi đơn hàng
              </Button>
            </div>
          </section>

          <aside className="flex items-center justify-center border-t bg-zinc-50 p-6 md:border-l md:border-t-0">
            <div className="text-center">
              <div className="mx-auto flex h-52 w-52 items-center justify-center rounded-lg border border-dashed border-zinc-300 bg-white text-sm font-bold text-zinc-400">
                QR BANK
              </div>
              <p className="mt-4 text-xs leading-5 text-zinc-500">
                Quét mã hoặc chuyển khoản thủ công với đúng nội dung thanh toán.
              </p>
            </div>
          </aside>
        </div>
      </Container>
    </div>
  );
}
