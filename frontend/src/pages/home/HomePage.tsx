import HeroBanner from "@/components/home/HeroBanner";
import FavoriteBrands from "@/components/home/FavoriteBrands";
import ProductsByBrand from "@/components/home/ProductsByBrand";
import Container from "@/components/ui/Container";

const HomePage = () => {
  return (
    <div className="bg-[#f7f7f5]">
      <HeroBanner />
      <Container className="space-y-16 py-14">
        <FavoriteBrands />
        <ProductsByBrand />
      </Container>
    </div>
  );
};

export default HomePage;
