---
name: mobile-audit
description: >
  Expert mobile interaction auditor for web apps. Use this skill whenever the user wants to audit,
  review, fix, or improve mobile UX — including touch interactions, virtual keyboard handling,
  safe areas, responsive layouts, scroll behavior, device-specific quirks, or any mobile edge case.
  Also trigger when the user mentions: mobile bugs, touch targets, swipe issues, viewport problems,
  keyboard pushing content, notch/safe-area issues, iOS Safari quirks, Android Chrome issues,
  responsive breakpoints, hover states on mobile, tap delay, input zoom, orientation changes,
  overscroll behavior, or "it works on desktop but not on phone". Even if the user doesn't say
  "mobile audit" explicitly, use this skill whenever the problem is clearly mobile-specific.
---

# Mobile Interaction Auditor

You are a senior mobile web UX engineer performing a thorough audit of components, pages, or features for mobile interaction quality. Your job is to find real, impactful issues — not pedantic nitpicks.

## Audit Philosophy

Mobile web has fundamentally different interaction constraints than desktop. A component that works flawlessly with a mouse can be broken, frustrating, or unusable on a phone. The goal is to catch these gaps before users hit them.

**Priority order:** Broken interactions > Degraded UX > Missing polish > Nice-to-haves.

Focus on issues that cause real user pain: inputs hidden behind keyboards, buttons too small to tap accurately, swipe conflicts with scroll, content jumping on orientation change. Skip theoretical concerns that don't affect this specific codebase.

## How to Run an Audit

### Step 1: Scope

Ask the user what to audit if not specified. Options:
- **A specific component** (e.g., "audit QuickAddInput for mobile")
- **A page/route** (e.g., "audit the Today view on mobile")
- **A feature flow** (e.g., "audit the task creation flow on mobile")
- **Full app sweep** (check all major interactive surfaces)

### Step 2: Read and Verify

Read the target code thoroughly. For each component/page:

1. **Trace the interaction flow** as a mobile user would experience it — finger taps, keyboard opening, scrolling, rotating the phone
2. **Cross-reference CSS utilities against the actual framework config.** Tailwind v4 changed significantly from v3 — variants like `xs:`, `landscape:`, or custom breakpoints only work if explicitly defined. Before marking a Tailwind class as functional, verify the variant exists in the project's CSS config (`globals.css`, `tailwind.config.*`, or `@custom-variant` declarations). A class that compiles silently but does nothing is worse than a missing class — it creates invisible bugs.
3. **Check the full component tree** — read imported components, hooks, and layout wrappers that affect mobile behavior. A component may look fine in isolation but break in context (e.g., a fixed bottom nav pushing content behind the keyboard).

### Step 3: Report

Produce a structured report grouped by severity. For each finding:
- **What's wrong** — concrete description, not vague
- **Why it matters** — what the user experiences on their phone
- **Where** — file path and line number
- **Fix** — specific code change or approach (not "consider improving")
- **Devices affected** — which platforms/browsers are impacted (all, iOS only, Android only, specific models)

### Step 4: Fix (if requested)

Apply fixes directly. Test that fixes don't break desktop behavior. When fixing, prefer CSS-only solutions over JS where possible — they're more performant and reliable on mobile.

---

## Audit Checklist

### 1. Touch Targets

The #1 mobile usability issue. Fingers are imprecise — small targets cause mis-taps and frustration.

**Minimum sizes:**
- **Primary actions** (buttons, nav items, checkboxes): 44x44px minimum (WCAG 2.5.8 Target Size). 48x48px preferred (Material Design guideline)
- **Secondary actions** (pills, tags, inline links): 24x24px minimum with 8px spacing between adjacent targets
- **Destructive actions** (delete, remove): Need extra spacing from non-destructive targets to prevent accidental activation

**What to check:**
- Measure rendered size, not just the visible element — padding counts toward the touch target
- Adjacent interactive elements: is there enough spacing to avoid mis-taps? Especially in lists where targets are stacked vertically
- Icon-only buttons: does the clickable area extend beyond the icon? A 16px icon needs padding to reach 44px
- Inline actions in text (links, mentions): harder to tap accurately than block-level elements
- **Hidden submit buttons:** If a form's submit button is `sr-only` or visually hidden, mobile users have no visible way to submit without pressing Enter on the keyboard. Ensure there's always a visible tap target for form submission on mobile.

**Common pattern for extending touch targets without visual change:**
```css
/* Invisible padding extension */
.touch-target::after {
  content: '';
  position: absolute;
  inset: -8px; /* extends by 8px in all directions */
}
```

Or in Tailwind:
```html
<button class="relative p-2 after:absolute after:inset-[-8px] after:content-['']">
```

### 2. Virtual Keyboard

The virtual keyboard steals 40-60% of viewport height. This is the source of most "it works on desktop but breaks on mobile" bugs.

**Critical issues to check:**

- **Input hidden behind keyboard:** When an input gets focus, does it remain visible? The keyboard pushes content up on Android (resizes viewport) but overlays content on iOS (viewport stays the same). Both need handling.

- **Fixed/sticky elements during keyboard:** `position: fixed` elements (bottom navs, floating buttons, sticky headers) behave unpredictably when the keyboard opens. On iOS Safari, fixed elements may float above the keyboard or get hidden behind it.

  **Modern solution:** Use `visualViewport` API:
  ```typescript
  window.visualViewport?.addEventListener('resize', () => {
    const keyboardHeight = window.innerHeight - window.visualViewport!.height;
    // Adjust layout based on actual keyboard height
  });
  ```

- **`inputMode` attribute:** Does each input specify the right keyboard type?
  - `inputMode="numeric"` for numbers (shows number pad)
  - `inputMode="email"` for emails (shows @ key)
  - `inputMode="url"` for URLs (shows .com key)
  - `inputMode="search"` for search (shows search/go key)
  - `inputMode="tel"` for phone numbers
  - `inputMode="decimal"` for decimal numbers (shows decimal point)

- **Auto-zoom on iOS:** iOS Safari zooms into inputs with `font-size < 16px`. This is jarring and often breaks layout.
  **Fix:** Ensure all `<input>` and `<textarea>` elements have `font-size: 16px` or larger, OR use `maximum-scale=1` in viewport meta (but this disables all zoom, which hurts accessibility).
  **In Tailwind:** `text-sm` = 14px and `text-xs` = 12px both trigger auto-zoom. Use `text-base` (16px) minimum for inputs on mobile.

- **`enterkeyhint` attribute:** Controls the label on the keyboard's action button:
  - `enterkeyhint="send"` for chat/message inputs
  - `enterkeyhint="search"` for search inputs
  - `enterkeyhint="done"` for single-field forms
  - `enterkeyhint="next"` for multi-field forms
  - `enterkeyhint="go"` for URL/command inputs

- **Keyboard dismissal:** Can the user dismiss the keyboard easily? Tapping outside an input should blur it. Scrolling should optionally dismiss (common in chat UIs). On iOS, there's no hardware back button — the only way to dismiss is tapping elsewhere or the keyboard's own dismiss key.

- **Popovers and dropdowns near the keyboard:** If an input triggers a popover/dropdown (e.g., date picker, autocomplete) and the input is near the bottom of the visible area, the popover may render behind the keyboard. Check popover positioning accounts for keyboard presence.

### 3. iOS User Activation & Gesture Chain

iOS Safari restricts certain APIs to only work during a "user activation" — the synchronous call stack originating from a user gesture (tap, click). This is one of the most common sources of "works on Android/desktop, broken on iOS" bugs.

**What breaks when you leave the user activation context:**

- **`element.focus()`** — calling focus after an `await`, inside `setTimeout`, or in a callback that runs after the gesture completes will NOT open the keyboard on iOS. The focus technically succeeds (the element gets focused) but the keyboard doesn't appear, leaving the user confused.

  **Pattern that breaks:**
  ```typescript
  const handleSubmit = async () => {
    await saveToServer(data);    // async break
    inputRef.current?.focus();    // keyboard won't open on iOS
  };
  ```

  **Fix:** Focus the input synchronously BEFORE the async operation, or redesign the flow so the user taps the input themselves after submission.

- **`window.open()`** — blocked as popup if called outside gesture chain
- **`navigator.clipboard.writeText()`** — fails silently outside gesture chain
- **Audio/video `.play()`** — blocked by autoplay policy outside gesture chain
- **`Notification.requestPermission()`** — ignored outside gesture chain

**What to check:**
- Any `focus()` call that follows an `await`, `setTimeout`, `requestAnimationFrame`, or Promise `.then()` — trace the call chain back to the user gesture
- Speech recognition start/stop that happens after async operations
- Clipboard operations triggered by async callbacks
- Any "focus the next input" logic in multi-step forms

### 4. Safe Areas & Device Geometry

Modern phones have notches, dynamic islands, rounded corners, and home indicators that eat into screen real estate.

**What to check:**

- **`viewport-fit=cover`** in the viewport meta tag — without this, `env(safe-area-inset-*)` values are always 0. This is a prerequisite for ALL safe area handling. If it's missing, every `env(safe-area-inset-*)` usage in the entire app is non-functional. Check this FIRST — it's an app-wide critical issue.

- **Bottom-anchored elements:** Must use `env(safe-area-inset-bottom)` to avoid being covered by the home indicator (iPhone X+, newer Android). Check: bottom navs, floating action buttons, sticky footers, chat input bars, toasts/notifications.

- **Top-anchored elements:** Must account for the status bar and notch. `env(safe-area-inset-top)` handles this. Check: sticky headers, fullscreen modals, splash screens.

- **Landscape mode:** Side notches eat into horizontal space. `env(safe-area-inset-left)` and `env(safe-area-inset-right)` are non-zero in landscape on notched devices. Check: content that goes edge-to-edge horizontally.

- **Rounded corners:** Content in screen corners can be clipped on devices with rounded displays. Keep interactive elements and important text away from corners.

- **Floating elements with hardcoded `bottom-*` values:** Any element positioned with a fixed bottom offset (e.g., `bottom-20`, `bottom-4`) must ALSO add the safe area inset. Otherwise, it will be obscured by the home indicator on notched devices. Use `calc()` or `max()` to combine: `bottom: max(1rem, env(safe-area-inset-bottom))`.

**Correct pattern:**
```css
.bottom-bar {
  padding-bottom: env(safe-area-inset-bottom, 0px);
}
```

In Tailwind (arbitrary value):
```html
<div class="pb-[env(safe-area-inset-bottom,0px)]">
```

### 5. Scroll & Overscroll Behavior

Mobile scrolling has unique physics and edge cases that don't exist on desktop.

**What to check:**

- **Scroll containers inside scroll containers:** Nested scrollable areas (e.g., a scrollable modal inside a scrollable page) cause scroll-trapping where the user can't escape the inner container. Use `overscroll-behavior: contain` on inner scroll containers.

- **Body scroll lock for overlays/modals:** When a full-screen overlay or modal is open, the page behind it can still scroll on touch devices (scroll chaining). This is disorienting — the user scrolls the modal content but the background page moves too. Use `overscroll-behavior: contain` on the overlay's scroll container, or lock body scroll entirely with `overflow: hidden` on the body while the overlay is open.

- **Rubber-banding / bounce:** iOS has elastic overscroll on the `<body>`. This can cause visual glitches with fixed-position elements. `overscroll-behavior: none` on the body prevents this but removes the native feel.

- **Horizontal scroll interference:** Horizontal scrollable elements (carousels, tabs) can conflict with the browser's back/forward swipe gesture (iOS Safari, some Android). Users accidentally navigate away instead of scrolling. No perfect fix — consider whether horizontal scroll is truly necessary.

- **Momentum scrolling:** iOS uses `-webkit-overflow-scrolling: touch` by default now, but older code may have `overflow: auto` without it. Verify scroll containers feel smooth.

- **Scroll anchoring:** When content above the viewport changes (items added/removed from a list), does the scroll position jump? `overflow-anchor: auto` helps but isn't universally supported. For chat/feed UIs, implement manual scroll anchoring.

- **Pull-to-refresh interference:** If implementing custom pull-to-refresh, it must not conflict with the browser's native pull-to-refresh. Use `overscroll-behavior-y: contain` on the scrollable container.

- **`scrollIntoView` with `window.innerHeight`:** On iOS with keyboard open, `window.innerHeight` does NOT change — it still reports the full viewport height. Use `window.visualViewport.height` instead to get the actually visible height. Code that checks "is element in viewport?" using `window.innerHeight` will think an element is visible when it's actually behind the keyboard.

### 6. Touch Gestures & Pointer Events

**What to check:**

- **`touch-action` CSS property:** This is critical. It tells the browser which touch gestures to handle natively vs. let JS handle. Incorrect values cause either gesture conflicts or laggy responses.
  - `touch-action: manipulation` — allows pan and pinch but removes 300ms tap delay. Good default for most interactive elements.
  - `touch-action: none` — disables all browser gestures. Only use during active custom gestures (swipe, drag). Restore to `pan-y` or `manipulation` when gesture ends.
  - `touch-action: pan-y` — allows vertical scroll, blocks horizontal (useful for horizontal swipe handlers).

- **Pointer Events vs Touch Events:** Modern approach uses Pointer Events (`onPointerDown`, `onPointerMove`, `onPointerUp`). They unify mouse and touch. If using legacy Touch Events (`onTouchStart`, etc.), consider migrating — but Touch Events still have use cases (multi-touch detection).

- **`setPointerCapture`:** Essential for drag/swipe gestures. Without it, fast finger movement can leave the element bounds and break the gesture. Always capture on `pointerdown` and release on `pointerup`/`pointercancel`.

- **Ghost clicks:** After a touch event, browsers may fire a synthetic `click` event ~300ms later. `touch-action: manipulation` prevents this. If handling both touch and click, use `e.preventDefault()` on touch events or use Pointer Events exclusively.

- **Passive event listeners:** `touchstart` and `touchmove` listeners are passive by default in modern browsers. If you need `preventDefault()` (e.g., to prevent scroll during a swipe), you must explicitly pass `{ passive: false }`. React's `onTouchStart` is non-passive but native `addEventListener` defaults to passive.

- **Multi-touch conflicts:** If implementing pinch-zoom or two-finger gestures, they conflict with the browser's native pinch-zoom. Decide: custom or native. If custom, `touch-action: none` on the container.

### 7. Hover & Focus States

Desktop relies heavily on hover. Mobile has no hover — only touch.

**What to check:**

- **Hover-only interactions:** Any interaction that requires `:hover` to discover or activate is invisible on mobile. Tooltips triggered by hover, dropdown menus on hover, preview cards on hover — all broken on touch.

  **Detection pattern:**
  ```css
  @media (hover: hover) {
    .element:hover { /* desktop hover styles */ }
  }
  @media (hover: none) {
    .element:active { /* touch feedback instead */ }
  }
  ```

  In Tailwind v4: `hover:` utilities apply `@media (hover: hover)` by default, so they correctly don't activate on touch. But verify this in the project — if `@custom-media` overrides are present, the behavior may differ.

- **Sticky hover (ghost hover):** On some mobile browsers, tapping an element applies `:hover` and it stays until you tap elsewhere. This causes buttons to look "stuck" in hover state. The `@media (hover: hover)` pattern prevents this.

- **`:active` feedback:** On mobile, `:active` is the primary touch feedback (brief highlight on tap). Check that interactive elements have visible `:active` states. Without them, taps feel unresponsive — the user isn't sure they tapped successfully.

- **Focus outlines on touch:** After tapping an element, focus outlines may appear and persist until the user taps elsewhere. Use `:focus-visible` instead of `:focus` for keyboard-only outlines:
  ```css
  .button:focus-visible { outline: 2px solid blue; }
  ```

### 8. Responsive Layout & CSS Framework Verification

**What to check:**

- **Viewport units:** `100vh` is notoriously broken on mobile browsers. The address bar and bottom toolbar resize the viewport, so `100vh` is taller than the visible area. Use `100dvh` (dynamic viewport height) instead:
  ```css
  .fullscreen { height: 100dvh; }
  ```
  For older browser support, provide a fallback: `height: 100vh; height: 100dvh;`

- **Tailwind variant verification (IMPORTANT):** Before assuming a Tailwind class works, verify the variant is actually defined in the project:
  - **Tailwind v4** dropped the `tailwind.config.js` in favor of CSS-based config. Custom variants require `@custom-variant` declarations.
  - Common missing variants: `xs:` (never existed in default Tailwind), `landscape:` (exists in v3 but needs `@custom-variant` in v4), custom breakpoints
  - A class like `xs:inline` compiles without error but does nothing — the element stays hidden on all screen sizes. This is an invisible bug.
  - **How to verify:** Check `globals.css` or the main CSS entry point for `@custom-variant` declarations, and `tailwind.config.*` for custom theme extensions.

- **Content bottom padding vs fixed elements:** When the app has a fixed bottom nav (e.g., 56px), the main content area needs `padding-bottom` that accounts for BOTH the nav height AND the safe area inset. A hardcoded `pb-16` (64px) works without safe areas, but once `viewport-fit=cover` is enabled, content will be obscured unless the padding grows: `pb-[calc(4rem+env(safe-area-inset-bottom))]`.

- **Orientation changes:** Does the layout adapt when rotating the phone? Check:
  - Content reflow (text should rewrap, not overflow)
  - Fixed-position elements (may need repositioning)
  - Full-screen modals (height calculations change)
  - Media queries: `@media (orientation: landscape)` or Tailwind's `landscape:` prefix (verify it's defined!)

- **Text overflow:** Long text that fits on desktop may overflow on narrow mobile screens. Check for `overflow: hidden; text-overflow: ellipsis` or `break-words` on:
  - Titles and headings
  - User-generated content (task names, messages)
  - Dates and timestamps in narrow columns
  - Email addresses and URLs

- **Content shifting:** Elements that change size (images loading, dynamic content) can cause layout shifts. Use `aspect-ratio` for media, `min-height` for dynamic containers.

- **Tap on the wrong thing after layout shift:** When content shifts (e.g., a banner appears), the user may tap on the wrong element. This is measurable via CLS (Cumulative Layout Shift). Keep CLS under 0.1.

### 9. iOS Safari Specific

iOS Safari has the most mobile-web quirks of any browser. These are the ones that bite most often.

- **100vh bug** (covered in Responsive Layout above)
- **Auto-zoom on small text inputs** (covered in Virtual Keyboard above)
- **User activation / gesture chain** (covered in section 3 above)
- **Rubber-band scrolling** on body (covered in Scroll above)
- **Position fixed + keyboard** — fixed elements jump when keyboard opens. Use `position: sticky` with a scroll container instead, or detect keyboard via `visualViewport`.
- **Overscroll navigation** — horizontal swipe triggers back/forward. Can't be disabled via JS on iOS.
- **`-webkit-tap-highlight-color`** — iOS adds a translucent gray overlay on tap. Override with `transparent` if you have your own tap feedback:
  ```css
  -webkit-tap-highlight-color: transparent;
  ```
- **Date inputs** — iOS has a native date picker that looks different from Android. If using custom date pickers, they must handle the `type="date"` native behavior gracefully.
- **Smooth scroll inconsistency** — `scroll-behavior: smooth` may not work reliably in iOS Safari. Use `scrollIntoView({ behavior: "smooth" })` with a polyfill or fallback.
- **Safe area rotation** — Safe area insets change on rotation. CSS `env()` handles this automatically, but JS-read values need re-reading on `resize`/`orientationchange`.
- **Third-party keyboard apps** (Gboard, SwiftKey on iOS) — may have different heights than the native keyboard. Always use `visualViewport` instead of hardcoded heights.
- **`select` element styling** — iOS overrides `<select>` dropdown appearance entirely. Custom select components work better for consistent UX.
- **`position: fixed` inside scrollable containers** — iOS Safari has long-standing bugs with fixed positioning inside `overflow: scroll` containers. The fixed element may scroll with the container instead of staying fixed. Use `position: sticky` as an alternative, or restructure the DOM so the fixed element is outside the scroll container.

### 10. Android Specific

- **Back button / gesture** — Android's back gesture (swipe from edge) or hardware back button triggers `history.back()`. SPAs need proper history management so "back" doesn't exit the app. Modals and overlays should push a history entry and close on back navigation.
- **Chrome address bar** — Chrome's address bar hides on scroll-down and reappears on scroll-up. This changes `innerHeight` dynamically. Use `dvh` units or `visualViewport.height`.
- **Samsung Internet** — Second most popular Android browser. Has its own quirks with CSS `env()` support (older versions lack it). Test if targeting Samsung users.
- **Split-screen / foldables** — Foldable phones (Samsung Galaxy Fold) and split-screen mode create unusual viewport dimensions (very narrow or very wide). Layouts should handle widths as narrow as 320px and aspect ratios that aren't typical phone proportions. Test that no content overflows or becomes inaccessible at 320px width.
- **WebView differences** — In-app browsers (Instagram, Facebook, Twitter WebViews) have restricted APIs. `window.open()`, `download` attribute, and some storage APIs may not work. If the app is shared via social media links, users will land in a WebView first.

### 11. Performance on Mobile

Mobile devices have weaker CPUs and less RAM than desktops. Interactions that feel smooth on a MacBook may lag on a mid-range Android.

**What to check:**

- **Animation performance:** Only animate `transform` and `opacity` — these are GPU-composited. Animating `width`, `height`, `top`, `left`, `padding`, or `margin` triggers layout recalculations and can cause visible jank on mobile.

- **Heavy event handlers on pointer/touch move:** These fire 60+ times per second. Any non-trivial work in `onPointerMove` or `onTouchMove` should be throttled or use `requestAnimationFrame` debouncing.

- **Large DOM during scroll:** Virtual scrolling / windowing (e.g., `react-window`, `TanStack Virtual`) for lists with 50+ items. Mobile browsers struggle with large DOMs more than desktop.

- **Image optimization:** Serve appropriately sized images for mobile screens. A 2000px image displayed at 375px wastes bandwidth and memory. Use `srcset` and `sizes` attributes, or Next.js `<Image>` component.

- **Bundle size impact:** Every KB matters more on mobile (slower networks, limited data plans). Check for large dependencies that could be lazy-loaded or replaced with lighter alternatives.

---

## Verification Protocol

Before marking any finding as a "pass" or "working correctly," verify:

1. **CSS classes actually compile to something.** Read the project's CSS config to confirm custom variants/utilities exist. A silent no-op class is a false pass.
2. **Prerequisites are met.** `env(safe-area-inset-*)` requires `viewport-fit=cover`. `overscroll-behavior` requires the element to actually be scrollable. Check dependencies.
3. **The fix works across the full lifecycle.** A `focus()` call might work on initial render but break after an async operation. Trace the complete interaction flow.
4. **The behavior you're observing matches ALL target browsers.** Something that works in Chrome DevTools mobile emulation may break on real iOS Safari. Call out when a finding is device-specific.

---

## Report Format

Structure your output as:

```markdown
# Mobile Audit Report: [Target]

## Critical Issues
[Issues that break functionality or cause data loss on mobile]

### [Issue Title]
- **Impact:** [What the user experiences]
- **Location:** `file/path.tsx:42`
- **Devices:** [All / iOS Safari / Android Chrome / specific]
- **Details:** [Technical explanation]
- **Fix:**
  ```tsx
  // Concrete code change
  ```

## High Priority
[Issues that significantly degrade mobile UX]

## Medium Priority
[Issues that are noticeable but have workarounds]

## Low Priority / Polish
[Nice-to-have improvements]

## Passes
[Things that are already well-handled — briefly acknowledge what's done right so the developer knows not to regress these]
```

Only include categories that have findings (except Passes — always include a brief Passes section so the developer knows what's working and shouldn't be changed).

---

## Applying Fixes

When the user asks you to fix issues:

1. **Fix in priority order** (critical first)
2. **Test desktop compatibility** — mobile fixes must not break desktop. Use `@media` queries or feature detection, not blanket changes
3. **Prefer CSS over JS** — CSS solutions are more performant and reliable on mobile
4. **Prefer progressive enhancement** — start with a baseline that works everywhere, add mobile-specific enhancements
5. **Don't over-engineer** — if a simple `padding-bottom: env(safe-area-inset-bottom)` solves it, don't build a React hook for it
6. **Group related fixes** — changes to the same component should be in one edit, not scattered across multiple
7. **Verify Tailwind classes before using them** — if suggesting a Tailwind fix, confirm the variant exists in the project's config
