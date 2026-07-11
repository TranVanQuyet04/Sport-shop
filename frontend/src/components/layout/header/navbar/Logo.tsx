import { useNavigate } from "react-router";

const Logo = () => {
  const navigate = useNavigate();

  const handleLogoClick = () => {
    navigate("/");
  };

  return (
    <div
      onClick={handleLogoClick}
      className="flex cursor-pointer items-center gap-2 text-xl font-black tracking-tight text-black"
    >
      <span className="flex h-9 w-9 items-center justify-center rounded-sm bg-zinc-950 text-sm text-white">
        S
      </span>
      <span>StrideX</span>
    </div>
  );
};

export default Logo;
