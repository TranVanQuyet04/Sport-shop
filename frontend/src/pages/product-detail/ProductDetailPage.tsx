import { useParams } from "react-router";
import { useProductDetail } from "@/hooks/useProductDetail";
import ProductDetail from "@/components/product-detail/ProductDetail";
import Container from "@/components/ui/Container";

const ProductDetailPage = () => {
  const { slug } = useParams();
  const productDetail = useProductDetail(slug);

  return (
    <div className="min-h-screen bg-[#f7f7f5]">
      <Container>
        <ProductDetail {...productDetail} />
      </Container>
    </div>
  );
};

export default ProductDetailPage;
