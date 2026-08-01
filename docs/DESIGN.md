---
name: Tabletop Tactile
colors:
  surface: '#fcf9f4'
  surface-dim: '#dcdad5'
  surface-bright: '#fcf9f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3ee'
  surface-container: '#f0ede8'
  surface-container-high: '#ebe8e3'
  surface-container-highest: '#e5e2dd'
  on-surface: '#1c1c19'
  on-surface-variant: '#45464e'
  inverse-surface: '#31302d'
  inverse-on-surface: '#f3f0eb'
  outline: '#75777e'
  outline-variant: '#c6c6ce'
  surface-tint: '#525e7f'
  primary: '#182442'
  on-primary: '#ffffff'
  primary-container: '#2e3a59'
  on-primary-container: '#98a4c9'
  inverse-primary: '#bac6ec'
  secondary: '#30685a'
  on-secondary: '#ffffff'
  secondary-container: '#b2ebda'
  on-secondary-container: '#356c5f'
  tertiary: '#3c1e00'
  on-tertiary: '#ffffff'
  tertiary-container: '#593105'
  on-tertiary-container: '#d39965'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2ff'
  primary-fixed-dim: '#bac6ec'
  on-primary-fixed: '#0d1a38'
  on-primary-fixed-variant: '#3a4666'
  secondary-fixed: '#b5eedd'
  secondary-fixed-dim: '#99d2c1'
  on-secondary-fixed: '#00201a'
  on-secondary-fixed-variant: '#145043'
  tertiary-fixed: '#ffdcc1'
  tertiary-fixed-dim: '#f8ba83'
  on-tertiary-fixed: '#2e1500'
  on-tertiary-fixed-variant: '#673d11'
  background: '#fcf9f4'
  on-background: '#1c1c19'
  surface-variant: '#e5e2dd'
typography:
  headline-lg:
    fontFamily: Bricolage Grotesque
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Bricolage Grotesque
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 38px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Bricolage Grotesque
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  score-display:
    fontFamily: Bricolage Grotesque
    fontSize: 56px
    fontWeight: '800'
    lineHeight: 56px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 26px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 48px
  gutter: 12px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style
The design system is centered on the tactile joy of physical board gaming, translated into a high-performance digital tool. The brand personality is **premium, focused, and inviting**, bridging the gap between a utilitarian scorekeeper and a luxury gaming accessory.

The aesthetic follows a **Material 3 (M3) base** but elevates it with **sophisticated organic shapes** and a color palette inspired by natural game components—linens, wooden meeples, and clay tokens. The UI evokes an emotional response of "calm control" during the heat of competition. By utilizing large touch targets and high-contrast logic, the system ensures that the digital interface never distracts from the physical game on the table.

## Colors
The palette uses a "Natural Component" logic to ensure readability under various lighting conditions common to game nights.

- **Primary (Deep Indigo - #2E3A59):** Used for authoritative elements, active states, and deep backgrounds. Provides the high-contrast anchor for text.
- **Secondary (Mint - #7FB7A7):** Represents progression, "player ready" states, and positive score adjustments.
- **Tertiary (Warm Amber - #D99E6A):** Used for highlighting special achievements, "MVP" players, or warnings.
- **Neutral (Soft Clay - #F5F2ED):** The "board" color. It replaces pure white to reduce eye strain and provide a premium, paper-like feel.

Success/Error states should utilize the Secondary (Mint) and a soft muted Red (#C96D6D) respectively, maintaining the desaturated, organic vibe of the system.

## Typography
The typography strategy pairs **Bricolage Grotesque** for expressive, personality-driven headings and score displays with **Plus Jakarta Sans** for high-speed legibility.

- **Headlines:** Use the playful, slightly eccentric character of Bricolage Grotesque to mimic the thematic branding of modern board games. 
- **Scores:** Massive "score-display" tokens are used for the primary point tallies, ensuring they can be read from across the table.
- **Body & Labels:** Plus Jakarta Sans provides a clean, open counter-form that remains legible even when condensed into tight score matrices or history logs.

## Layout & Spacing
This design system utilizes a **fluid grid with safe-area focus**, optimized for rapid one-handed entry. 

- **Mobile (Default):** A 4-column grid with 16px margins. Score entry inputs should span at least 2 columns to facilitate large thumb-tap targets.
- **Tablet/Desktop:** A 12-column grid. For score history, use a "Sheet" layout where player names are pinned to the left column and rounds scroll horizontally.
- **Rhythm:** All spacing is derived from a 4px baseline. Components use "md" (16px) for internal padding to maintain a spacious, premium feel that avoids the "data-heavy" look of spreadsheets.

## Elevation & Depth
In alignment with Material 3, elevation is primarily communicated through **Tonal Layers** rather than heavy shadows.

- **Level 0 (Surface):** The Neutral (Soft Clay) background.
- **Level 1 (Cards):** Slightly lighter than the surface or uses a subtle 2% Primary (Indigo) tint to separate player cards from the board.
- **Level 2 (Active/Modals):** Uses a soft, ambient shadow (10% opacity Primary color, 12px blur, 4px Y-offset) to indicate the highest priority interactive element (e.g., the active player's score input).
- **Interactive States:** Buttons and chips use "pressed" states that visually sink (lower elevation) to mimic the feeling of pushing a physical button or tile.

## Shapes
Shapes are exceptionally rounded to reflect the "friendly" nature of gaming components. 

- **Cards:** Use `rounded-xl` (1.5rem / 24px) to create a soft, friendly container for player data.
- **Buttons/Inputs:** Use `rounded-lg` (1rem / 16px) for a modern, accessible feel.
- **Progress Indicators:** Linear bars and selection chips should use full "pill" rounding to contrast against the more structural card layouts.

## Components
Consistent styling across the application relies on "High-Affordance" interactive elements.

- **Score Entry Buttons:** Large, circular or pill-shaped buttons with `+` and `-` symbols. The Primary color is used for incrementing, while a ghost-style border version is used for decrementing.
- **Player Cards:** High-contrast containers with a thick colored border (Secondary or Tertiary) at the top to denote player colors. Includes a large-scale `score-display` font.
- **History Lists:** Alternating row colors using subtle shifts in the Neutral palette to maintain horizontal scanning accuracy.
- **Selection Chips:** Used for game modifiers or round numbers. Active state uses the Primary color with a white label; inactive uses a thin Indigo border.
- **Input Fields:** Large, centered text with a "bottom-heavy" underline that glows in the Secondary (Mint) color when focused, mimicking M3's emphasis on active states.
- **Tally Component:** A custom component for games requiring many small increments, featuring a "swipe to add" gesture area.
