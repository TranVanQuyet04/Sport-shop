import { Link, useNavigate } from "react-router";
import {
  NavigationMenu as ShadcnNavMenu,
  NavigationMenuContent,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuTrigger,
} from "@/components/ui/navigation-menu";
import { Skeleton } from "@/components/ui/skeleton";
import { useNavigation } from "@/hooks/useNavigationQuery";

const NavigationMenu = () => {
  const navigate = useNavigate();
  const { data: navigationData, isLoading, error } = useNavigation();

  const getLinkHref = (navItem: any, item: any) => {
    const parentName = navItem.categoryName.toLowerCase();
    if (parentName.includes("thương hiệu")) {
      return `/collections?brandId=${item.id}`;
    }
    if (parentName.includes("thể thao")) {
      return `/collections?sportId=${item.id}`;
    }
    return `/collections?categoryId=${item.id}`;
  };

  const getParentHref = (navItem: any) =>
    `/collections?categoryId=${navItem.id}`;

  if (isLoading) {
    return (
      <div className="flex w-full items-center justify-center">
        <div className="flex space-x-4">
          {Array.from({ length: 6 }).map((_, index) => (
            <Skeleton key={index} className="h-8 w-24" />
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex w-full items-center justify-center">
        <p className="text-sm text-red-500">Không thể tải menu navigation</p>
      </div>
    );
  }

  if (!navigationData || !Array.isArray(navigationData)) {
    return null;
  }

  return (
    <div className="flex w-full items-center justify-center">
      <ShadcnNavMenu viewport={true} className="w-full">
        <NavigationMenuList className="flex items-center justify-center space-x-0">
          <NavigationMenuItem>
            <NavigationMenuLink asChild>
              <Link
                to="/collections"
                className="block px-4 py-6 text-base font-bold text-black transition-all duration-200 hover:text-red-500"
              >
                Hàng mới
              </Link>
            </NavigationMenuLink>
          </NavigationMenuItem>

          {navigationData.map((navItem) => (
            <NavigationMenuItem key={navItem.id} className="relative">
              {navItem.children && navItem.children.length > 0 ? (
                <>
                  <NavigationMenuTrigger
                    className="h-auto cursor-pointer rounded-none bg-transparent px-4 py-6 text-base font-bold text-black transition-all duration-200 hover:bg-transparent hover:text-red-500"
                    onClick={() => navigate(getParentHref(navItem))}
                  >
                    {navItem.categoryName}
                  </NavigationMenuTrigger>

                  <NavigationMenuContent>
                    <div className="mx-auto w-screen max-w-6xl overflow-x-auto bg-white px-6 py-6">
                      <div className="grid gap-6 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
                        {navItem.children.map((column: any) => (
                          <div key={column.id} className="space-y-4">
                            <h3 className="break-words border-b border-gray-200 pb-2 text-base font-black uppercase tracking-wider text-black">
                              <NavigationMenuLink asChild>
                                <Link to={getLinkHref(navItem, column)}>
                                  {column.categoryName}
                                </Link>
                              </NavigationMenuLink>
                            </h3>

                            <ul className="space-y-2">
                              {column.children
                                ?.filter(
                                  (item: any) =>
                                    !["Ưu Đãi", "Hàng Mới"].includes(
                                      item.categoryName,
                                    ),
                                )
                                .map((item: any) => (
                                  <li key={item.id}>
                                    <NavigationMenuLink asChild>
                                      <Link
                                        to={getLinkHref(navItem, item)}
                                        className="block break-words text-sm text-gray-600 transition-colors hover:text-red-500"
                                      >
                                        {item.categoryName}
                                      </Link>
                                    </NavigationMenuLink>
                                  </li>
                                ))}
                            </ul>
                          </div>
                        ))}
                      </div>
                    </div>
                  </NavigationMenuContent>
                </>
              ) : (
                <NavigationMenuLink asChild>
                  <Link
                    to={getParentHref(navItem)}
                    className="block px-4 py-6 text-base font-bold text-black transition-all duration-200 hover:text-red-500"
                  >
                    {navItem.categoryName}
                  </Link>
                </NavigationMenuLink>
              )}
            </NavigationMenuItem>
          ))}
        </NavigationMenuList>
      </ShadcnNavMenu>
    </div>
  );
};

export default NavigationMenu;
