import { Link } from "react-router-dom";
import Container from "@/components/ui/Container";
import { Mail, MapPin, Phone } from "lucide-react";

const shopLinks = [
  { label: "Men", href: "/collections/nam" },
  { label: "Women", href: "/collections/nu" },
  { label: "Kids", href: "/collections/tre-em" },
  { label: "Brands", href: "/brands" },
  { label: "New arrivals", href: "/collections/new-arrivals" },
];

const supportLinks = [
  { label: "Login", href: "/login" },
  { label: "Order guide", href: "/ho-tro/dat-hang" },
  { label: "Returns", href: "/ho-tro/doi-tra" },
  { label: "Payment", href: "/ho-tro/thanh-toan" },
  { label: "FAQ", href: "/ho-tro/faq" },
];

const Footer = () => {
  return (
    <footer className="mt-auto border-t border-white/10 bg-zinc-950 text-zinc-300">
      <Container className="py-12">
        <div className="grid grid-cols-1 gap-10 md:grid-cols-2 lg:grid-cols-4">
          <div>
            <Link to="/" className="inline-flex items-center gap-2 text-white">
              <span className="flex h-10 w-10 items-center justify-center rounded-sm bg-white text-sm font-black text-zinc-950">
                S
              </span>
              <span className="text-xl font-black tracking-tight">
                SPORTSHOP
              </span>
            </Link>
            <p className="mt-5 max-w-sm text-sm leading-7 text-zinc-400">
              Authentic sportswear, footwear, and training essentials for daily
              movement and serious performance.
            </p>
          </div>

          <div>
            <h3 className="mb-4 text-xs font-black uppercase tracking-[0.24em] text-white">
              Shop
            </h3>
            <ul className="space-y-3">
              {shopLinks.map((item) => (
                <li key={item.href}>
                  <Link
                    to={item.href}
                    className="text-sm text-zinc-400 transition hover:text-red-400"
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h3 className="mb-4 text-xs font-black uppercase tracking-[0.24em] text-white">
              Support
            </h3>
            <ul className="space-y-3">
              {supportLinks.map((item) => (
                <li key={item.href}>
                  <Link
                    to={item.href}
                    className="text-sm text-zinc-400 transition hover:text-red-400"
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h3 className="mb-4 text-xs font-black uppercase tracking-[0.24em] text-white">
              Contact
            </h3>
            <ul className="space-y-4 text-sm text-zinc-400">
              <li className="flex items-start gap-3">
                <Mail className="mt-0.5 h-4 w-4 text-red-400" />
                hotro@sportshop.vn
              </li>
              <li className="flex items-start gap-3">
                <Phone className="mt-0.5 h-4 w-4 text-red-400" />
                1900 xxxx
              </li>
              <li className="flex items-start gap-3">
                <MapPin className="mt-0.5 h-4 w-4 text-red-400" />
                District 1, Ho Chi Minh City
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-12 flex flex-col gap-4 border-t border-white/10 pt-7 text-sm text-zinc-500 sm:flex-row sm:items-center sm:justify-between">
          <p>© {new Date().getFullYear()} SPORTSHOP. All rights reserved.</p>
          <div className="flex gap-6">
            <Link to="/chinh-sach/bao-mat" className="hover:text-zinc-300">
              Privacy
            </Link>
            <Link to="/chinh-sach/dieu-khoan" className="hover:text-zinc-300">
              Terms
            </Link>
          </div>
        </div>
      </Container>
    </footer>
  );
};

export default Footer;
