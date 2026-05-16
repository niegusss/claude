# Example: Restaurant Table Availability MVP

> **This is an illustrative reference, not a starter template.** Replace the domain with your own. The structure (Overview → Problem → Users → Flows → Features → Schema → Requirements → Constraints) is the part to copy.

---

# Project Brief: Table Availability Visualization

## Overview

A mobile-first web app that shows real-time table availability across local restaurants. Guests browse a list of nearby venues, see how many tables are currently free, and tap into a restaurant to view the live floor map. Restaurant owners use a one-tap interface to flip tables between Free, Occupied, and Reserved. The MVP is built with React + Vite + Supabase and targets six weeks to launch.

## Problem Statement

Restaurant guests in cities often arrive at a chosen restaurant only to find no tables available, especially during peak hours. They lose 20-40 minutes of an evening wandering between venues that all "look" busy from the outside. Restaurant owners simultaneously lose foot traffic from guests who assume they're full and walk past.

Current solutions and why they fall short:
- **Phone calls** — time-consuming, often unanswered during the busy hours that matter most
- **Reservation apps** (OpenTable, Resy) — require commitment, don't surface walk-in availability
- **Social media** — never real-time, requires constant manual updates by staff
- **Just walking in** — wastes the guest's trip and the host's time on a no-result interaction

The cost of this problem:
- Guests: wasted trips, frustration, settling for less-preferred options
- Restaurants: lost walk-in revenue, no visibility into demand patterns

## Target Users

### Guest (end user)

- Demographics: urban diners, age 25-55, smartphone users
- Behavior: spontaneous dining decisions, value convenience over commitment
- Goal: quickly find a nearby restaurant with available tables
- Technical comfort: moderate — expects mobile-friendly web apps to "just work"

### Restaurant owner / manager

- Demographics: restaurant owners or shift managers, age 30-60
- Behavior: busy during service, need single-tap updates
- Goal: attract more walk-in customers by broadcasting availability
- Technical comfort: low to moderate — needs an obvious, hard-to-misuse interface

## User Flows

### Guest Flow

#### 1. Restaurant Discovery
- Opens the app in a mobile browser (no install)
- Lands on a list of nearby restaurants, sorted by availability and distance
- Each card shows: name, logo, cuisine, distance, **number of free tables** (prominent)
- Pulls to refresh

#### 2. Restaurant Detail
- Taps a card
- Sees: header (name, logo, rating), info (address, hours, price range, cuisine), photo gallery, menu preview
- Sees an interactive table map with color-coded status:
  - Green = available
  - Red = occupied
  - Gray = reserved / blocked
- Summary: "5 of 12 tables available"

#### 3. Promotional Features
- Optional "Get Discount" button surfaces a promo code in a dialog
- "Give Feedback" links to a Google Form

### Restaurant Owner Flow

#### 1. Registration
- Visits the registration page
- Submits: restaurant name, address, contact email, password
- Receives confirmation email; account status `pending`

#### 2. Account Activation
- Admin reviews and changes status to `active`
- Owner receives activation email and can log in

#### 3. Dashboard
- Sees three sections: Restaurant Profile, Table Management, Statistics

#### 4. Profile Management
- Edits: name, description, address, phone
- Sets opening hours per day of week
- Uploads up to 6 photos (drag-drop)
- Uploads menu (PDF or images)
- Sets price range and cuisine type

#### 5. Table Management (primary daily task)
- Sees an interactive table map matching the physical layout
- Each table: number, seat count, current status
- **One tap** to toggle Free ↔ Occupied
- Long-press to mark Reserved (temporary block)
- Updates propagate to guest views in under one second via Supabase Realtime

#### 6. Statistics
- Profile views (daily, weekly, monthly)
- Current availability snapshot
- Peak hours chart (when guests view the profile)

## Feature Specifications

### Frontend

#### F1: Restaurant List View
- Responsive grid of cards (shadcn/ui `Card`)
- Card: logo (80x80), name, cuisine badge, availability count
- Pull-to-refresh on mobile
- Skeleton loading state (shadcn/ui `Skeleton`)

#### F2: Restaurant Detail View
- Sticky header with back button
- Tabbed sections: Info, Photos, Menu, Tables (shadcn/ui `Tabs`)
- Photos: swipeable gallery
- Menu: zoomable images or PDF viewer

#### F3: Interactive Table Map (guest)
- SVG-based room visualization
- Tables positioned per the owner's layout
- Color-coded status with a legend
- Tap a table for details
- "Last updated" timestamp

#### F4: Promotional Dialog
- Modal overlay with code (shadcn/ui `Dialog`)
- Copy-to-clipboard button

### Backend / admin

#### F5: Authentication
- Email + password registration and login
- Password reset
- Session management
- Role-based: guest, owner, admin

#### F6: Restaurant Profile CRUD
- Create on registration, read for display, update all fields, soft-delete (deactivate)

#### F7: Table Management System
- Table layout (position, number, seats)
- Real-time status via Supabase Realtime
- Status history log (for analytics)

#### F8: Layout Editor (tablet-optimized)
- Drag-and-drop table positioning on a grid canvas
- Supports 30+ tables
- Save/load layouts
- Table properties: number (1-99), seats (1-12)

#### F9: Statistics Engine
- Track profile views (timestamp + source)
- Calculate availability metrics
- Hourly/daily aggregates
- Surface in owner dashboard

## Database Schema (Supabase / PostgreSQL)

- `restaurants` — id, name, description, address, phone, email, opening_hours (JSONB), price_range, cuisine_type, logo_url, status, created_at
- `restaurant_photos` — id, restaurant_id, url, order, created_at
- `tables` — id, restaurant_id, table_number, seats, position_x, position_y, status, updated_at
- `users` — id, email, role, restaurant_id (for owners), status, created_at
- `page_views` — id, restaurant_id, timestamp, source

Row Level Security on every table. Owners can only mutate rows tied to their `restaurant_id`. Public read on `restaurants`, `restaurant_photos`, `tables`.

## Technical Requirements

### Performance
- Initial page load under 3 seconds on 3G
- Table status updates: under 500 ms guest-to-guest latency
- 100 concurrent viewers per restaurant supported

### Compatibility
- Browsers: Chrome, Safari, Firefox, Edge (last 2 versions)
- Devices: iOS 14+, Android 10+, desktop
- Responsive breakpoints: 375, 768, 1024, 1440

### Security
- HTTPS everywhere
- Supabase RLS on every table
- Input validation and sanitization on every form
- Rate limiting on auth endpoints

### Accessibility
- WCAG 2.1 AA target
- Keyboard navigation throughout
- Screen reader support on critical flows (browse, table map summary)

## Constraints & Considerations

### MVP Scope Boundaries

**Included:**
- Restaurant discovery and viewing
- Real-time table availability display
- Owner profile management
- Single-tap table status updates
- Basic statistics

**Not in MVP (future versions):**
- Reservation system
- Payment processing
- Reviews and ratings
- Push notifications
- Multi-language
- Advanced analytics with cohorts

### Timeline

- MVP target: 6 weeks
- Phase 1 (Weeks 1-2): setup, auth, basic CRUD
- Phase 2 (Weeks 3-4): table management, real-time features
- Phase 3 (Weeks 5-6): polish, testing, deployment

### Dependencies

- Supabase project (free tier sufficient for MVP)
- Vercel account for frontend deployment
- Domain name (optional for MVP)
