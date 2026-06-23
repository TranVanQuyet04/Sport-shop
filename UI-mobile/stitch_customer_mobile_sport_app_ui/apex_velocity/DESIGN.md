---
name: Apex Velocity
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f3'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#4c4546'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f1f1f1'
  outline: '#7e7576'
  outline-variant: '#cfc4c5'
  surface-tint: '#5e5e5e'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1b1b1b'
  on-primary-container: '#848484'
  inverse-primary: '#c6c6c6'
  secondary: '#bb0027'
  on-secondary: '#ffffff'
  secondary-container: '#e51a38'
  on-secondary-container: '#fffbff'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#1a1c1c'
  on-tertiary-container: '#838484'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e2e2e2'
  primary-fixed-dim: '#c6c6c6'
  on-primary-fixed: '#1b1b1b'
  on-primary-fixed-variant: '#474747'
  secondary-fixed: '#ffdad8'
  secondary-fixed-dim: '#ffb3b1'
  on-secondary-fixed: '#410007'
  on-secondary-fixed-variant: '#92001d'
  tertiary-fixed: '#e2e2e2'
  tertiary-fixed-dim: '#c6c6c7'
  on-tertiary-fixed: '#1a1c1c'
  on-tertiary-fixed-variant: '#454747'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  title-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-bold:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
  button:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  margin-mobile: 16px
  gutter-mobile: 12px
  touch-target-min: 44px
  section-gap: 32px
---

## Brand & Style

This design system is engineered for a high-performance sportswear e-commerce experience. The brand personality is **powerful, professional, and urgent**, reflecting the discipline of elite athletics. 

The aesthetic follows a **Modern High-Contrast** approach. By utilizing a stark monochromatic base punctuated by an aggressive accent red, the UI directs focus toward product photography and critical actions. The design language avoids unnecessary decoration, favoring structural integrity and clarity. The goal is to evoke a sense of momentum and reliability, ensuring the user feels empowered to make quick, confident performance gear transitions.

## Colors

The palette is rooted in absolute contrast to ensure maximum legibility and impact.

- **Primary Black (#000000):** Used for primary text, iconography, and structural elements to provide a grounded, authoritative feel.
- **Accent Red (#E31837):** Reserved exclusively for high-priority Call to Actions (CTAs), sale indicators, and active states. This color signals energy and urgency.
- **Surface Neutrals (#F5F5F5, #E0E0E0):** These tones define the background layers and secondary containers, preventing visual fatigue from pure white while maintaining a clean, professional canvas.
- **Pure White (#FFFFFF):** Used for card backgrounds and high-contrast text on dark backgrounds to ensure crispness.

## Typography

The typography utilizes **Inter** for its systematic, utilitarian precision and exceptional legibility at small sizes. 

- **Weight Strategy:** Headings utilize Bold and ExtraBold weights to establish a clear visual hierarchy and convey a sense of strength.
- **Localized Nuance:** As the primary language is Vietnamese, line-heights are slightly increased for body text to accommodate diacritics without crowding the vertical rhythm.
- **Case Usage:** Uppercase is applied strategically to labels and secondary buttons to differentiate them from primary narrative text and product titles.

## Layout & Spacing

This design system employs a **Fluid Mobile-First Grid** optimized for **one-handed operation**. 

- **Thumb Zone Optimization:** Interactive elements (Add to Cart, Filters, Navigation) are weighted toward the bottom 60% of the screen.
- **8px Spacing System:** All margins and paddings are multiples of 8px (or 4px for tight clusters) to maintain a rigorous mathematical rhythm.
- **Safe Areas:** A 16px horizontal margin is enforced across all mobile screens to prevent content from touching the device edges.
- **Vertical Rhythm:** Sections are separated by a 32px gap to allow the product photography to breathe, preventing a cluttered "discount store" appearance.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** and **Subtle Ambient Shadows**.

- **Surface Levels:** The primary background uses the neutral gray (#F5F5F5). Elevated components like product cards and bottom sheets use Pure White (#FFFFFF).
- **Shadow Profile:** Shadows are extremely soft (Blur: 12px, Opacity: 4%, Color: #000000) to provide just enough depth to indicate interactivity without sacrificing the clean, modern aesthetic.
- **Interaction Depth:** On press, elements should visually "sink" (shadow removal or slight scale down to 0.98) to provide tactile feedback during the shopping experience.

## Shapes

The shape language balances professional rigor with modern approachability. 

- **Standard Radius:** A 12px (0.75rem) corner radius is the default for buttons and input fields.
- **Large Radius:** Product cards and bottom sheets use a 16px (1rem) radius to soften the high-contrast visuals.
- **Iconography:** Use a consistent 2px stroke weight with slightly rounded joins to match the component radius.

## Components

### Buttons
- **Primary:** Solid Black (#000000) with White text. High-performance, bold.
- **CTA:** Solid Accent Red (#E31837) with White text. Used for "Thanh toán ngay" (Checkout) and "Thêm vào giỏ" (Add to cart).
- **Secondary:** Outlined Black (1.5px stroke) or Ghost styles for "Xem thêm" (See more).

### Input Fields
- **Search:** Background #E0E0E0, 12px radius, icon-prefixed. 
- **Forms:** White background with a 1px #E0E0E0 border. Active state transitions to a 2px Black border.

### Product Cards
- Clean, no-border design. High-quality imagery on a light gray background. Prices are bolded, and "Sale" tags use the Accent Red background with white text.

### Selection Controls
- **Size Chips:** Rectangular with 8px radius. Selected state is solid Black with White text.
- **Touch Targets:** All interactive elements must maintain a minimum hit area of 44x44px, especially critical in the checkout flow to reduce friction.

### Lists
- Clean dividers (1px #E0E0E0) with generous 16px vertical padding for easy tapping in the "Tài khoản" (Account) or "Đơn hàng" (Orders) sections.