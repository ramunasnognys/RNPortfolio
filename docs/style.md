# Style Guide

## Brand Colors

- Primary: #1DB954 (Green for CTAs and important actions)
- Background: #121212 (Dark mode background)
- Text Colors:
  - Primary: #FFFFFF
  - Secondary: #B3B3B3
  - Muted: #727272

## Typography

### Fonts
- Primary: Inter, system-ui, -apple-system, sans-serif
- Weights:
  - Regular: 400
  - Medium: 500
  - Semi-bold: 600
  - Bold: 700

### Text Sizes
- Hero Title: 2.5rem (40px)
- Heading 1: 2rem (32px)
- Heading 2: 1.5rem (24px)
- Body: 1rem (16px)
- Small: 0.875rem (14px)

## Layout

### Container
- Max-width: 1200px
- Padding: 2rem (32px)
- Mobile padding: 1rem (16px)

### Grid
- Card grid: repeat(auto-fit, minmax(300px, 1fr))
- Gap: 1.5rem (24px)

### Spacing
- Small: 0.5rem (8px)
- Medium: 1rem (16px)
- Large: 2rem (32px)
- XLarge: 4rem (64px)

## Components

### Cards
- Background: #1E1E1E
- Border-radius: 12px
- Padding: 1.5rem
- Hover effect: slight scale (1.02) and shadow
- Tags:
  - Background: #2A2A2A
  - Border-radius: 16px
  - Padding: 4px 12px

### Navigation
- Height: 64px
- Fixed position
- Backdrop-filter: blur(10px)
- Background: rgba(18, 18, 18, 0.8)

### Buttons
Primary:
- Background: #1DB954
- Hover: #1ed760
- Border-radius: 24px
- Padding: 12px 24px
- Font-weight: 600

Secondary:
- Background: #2A2A2A
- Hover: #333333
- Border-radius: 24px
- Padding: 12px 24px

### Profile Image
- Size: 96px x 96px
- Border-radius: 50%
- Border: 2px solid #1DB954

### Social Links
- Icon size: 24px
- Spacing: 1rem
- Color: #FFFFFF
- Hover: #1DB954

## Responsive Design

### Breakpoints
- Mobile: 320px - 767px
- Tablet: 768px - 1023px
- Desktop: 1024px+

### Mobile Adaptations
- Single column layout
- Reduced padding and margins (multiply by 0.75)
- Smaller text sizes (multiply by 0.9)
- Full-width cards
- Hamburger menu for navigation

## Animation

### Transitions
- Duration: 200ms
- Timing: ease-in-out
- Properties:
  - transform
  - opacity
  - background-color

### Hover Effects
- Cards: transform: scale(1.02)
- Buttons: background-color shift
- Links: color shift
- Images: slight opacity reduction (0.9)

## Icons
- Style: Rounded, filled
- Size: 24px (default)
- Color: Inherits from text
- Recommended set: Phosphor Icons

## Dark Mode
- Already optimized for dark mode
- Light mode optional with following inversions:
  - Background: #FFFFFF
  - Text: #121212
  - Cards: #F5F5F5
  - Secondary bg: #EEEEEE