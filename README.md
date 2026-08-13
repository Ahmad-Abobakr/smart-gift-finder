# Smart Gift Finder

An AI-powered Flutter app that recommends the perfect gift based on the recipient's interests, age, gender, occasion, and budget.

## Architecture Overview

This app follows **Clean Architecture** with three distinct layers:

### 📁 Data Layer (lowest)
- Raw data fetching, API calls, JSON parsing
- `lib/core/services/ai_service.dart` — Gemini AI connector (model setup, Arabic system prompt, prompt building, JSON response parsing)
- `lib/data/data_sources/remote/api_data_source.dart` — DummyJSON API (products, categories, search)
- `lib/data/repositories/` — Repository implementations
- `lib/data/models/` — Data models (ProductModel)

### 📁 Domain Layer (center)
- Business rules, use cases, product matching — independent of Flutter/Firebase
- `lib/domain/entities/product.dart` — Shared Product entity (used across all features)
- `lib/domain/repositories/` — Repository interfaces
- `lib/domain/usecases/` — Use cases (e.g., `GetAiRecommendations`: converts catalog → JSON, calls AI, matches IDs back to Product entities)

### 📁 Presentation Layer (highest)
- Widgets, BLoC/Cubit, user interactions, navigation
- `lib/presentation/main_screen.dart` — Bottom navigation bar with 4 tabs (Home, Categories, AI Gift Finder, Profile) using `IndexedStack` to preserve tab state
- `lib/presentation/ai_gift/` — AI Gift Finder feature:
  - `ai_gift_form_screen.dart` — User preference form (age range, gender, occasion, multi-select interests, budget)
  - `ai_gift_results_screen.dart` — Shows AI recommendations with reasons, prices, ratings, favorite buttons
  - `ai_gift_event.dart`, `ai_gift_state.dart`, `ai_gift_bloc.dart` — BLoC state management
  - `favoritable_product_card.dart` — Centralized product card with favorite/cart/buy-now buttons wired to app-level blocs
- `lib/presentation/home/`, `categories/`, `search/` — Product browsing features
- `lib/presentation/favorites/`, `cart/` — Favorites and cart management (Firebase + SharedPreferences)
- UI widgets: `rating_stars.dart`, `price_tag.dart`, `product_details_screen.dart`

## How the AI Gift Feature Works

User flow:

1. **Main screen** → tap **"AI Gift Finder"** tab → sees preference form
2. User selects: age range, gender, occasion, interests (multiple), budget
3. Taps **"Get AI Recommendations"** → `AIGiftBloc` fires `SubmitAIPreferences`
4. Bloc fetches 100 products from DummyJSON API → calls `GetAiRecommendations` use case
5. Use case converts products to JSON → calls Gemini AI (`gemini-3.6-flash`) with Arabic system prompt
6. AI returns suggestions (`productId` + `reason`) + summary
7. Use case matches AI IDs back to real `Product` entities
8. Bloc emits `AIGiftLoaded` with matched products + reasons + summary
9. Results screen renders: gradient banner, product cards with "AI Suggestion" badges, reason text, price/rating, heart icon (adds to favorites via `FavoritesBloc`)

**Key AI files and their single responsibilities:**

| File | One job |
|------|---------|
| `lib/core/services/ai_service.dart` | Talk to Gemini: model setup, Arabic system prompt, prompt building, parse JSON |
| `lib/domain/usecases/get_ai_recommendations.dart` | Match AI suggestions to real Product entities; no Gemini knowledge |
| `lib/presentation/ai_gift/bloc/ai_gift_bloc.dart` | Orchestrate: fetch catalog → use case → emit state |
| `lib/presentation/ai_gift/ai_gift_form_screen.dart` | Collect user preferences |
| `lib/presentation/ai_gift/ai_gift_results_screen.dart` | Display AI recommendations |

## What Changed (Recent Refactor)

- **Removed duplicate AI code**: `ai_gift_data_source.dart` was a near-exact copy of `ai_service.dart` — deleted.
- **Moved product matching** into the domain use case (`get_ai_recommendations.dart`) where it belongs.
- **Fixed broken imports** in the use case (they resolved outside `lib/` and the code was never compilable).
- **Consolidated to Clean Architecture**: one Gemini connector, one use case, one bloc — each with a single responsibility.
- **Shared `GiftPreferences` model** (`lib/core/models/gift_preferences.dart`): the form/event/bloc/use case/service all pass ONE preferences object instead of 5 loose fields.
- **One result type**: `AiGiftRecommendationResult` is the single output of the use case, and `AIGiftLoaded` state just wraps it (no duplicated `products/reasons/summary` fields).
- **Removed dead `ResetAIGift` event** and made the error "Try Again" re-submit in place.
- **AI result card** (`_AIProductCard`) now owns its favorite wiring (same pattern as `FavoritableProductCard`) and reuses the shared `RatingStars` + `PriceTag` widgets instead of hand-rolling them.

## Getting Started

```sh
flutter pub get
flutter run
```

## Available Scripts

| Script | What it does |
|--------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter analyze` | Run static analysis (0 issues after refactor) |
| `flutter test` | Run tests (none currently) |
| `flutter build apk --release` | Build release APK |
| `git tag v1.0.0 && git push origin v1.0.0` | Trigger GitHub Actions release build (`.github/workflows/release.yml`) |

## Project Structure (Key Folders)

```
lib/
├── main.dart                                      # App entry, Firebase init, Bloc providers
├── core/                                          # Shared: theme, constants, services
│   └── services/ai_service.dart                   # Gemini AI connector (ONLY)
├── data/                                          # Data sources, repositories, models
├── domain/                                        # Entities, repositories, use cases
└── presentation/                                  # UI, BLoC, screens, widgets
    ├── ai_gift/                                   # AI Gift Finder feature
    │   ├── bloc/                                  # BLoC + events + states
    │   ├── form_screen.dart                       # Preference form
    │   └── results_screen.dart                    # Recommendations display
├── main_screen.dart                               # Bottom navigation + IndexedStack
└── widgets/                                       # Shared widgets (product card, price tag, etc.)
```

## Notes

- **Firebase required**: `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) + Firebase Web config in `main.dart`
- **AI requires**: Firebase AI Logic API key + `FirebaseAppCheck` (activated in `main.dart` with ReCaptcha)
- **Colors**: Use `AppTheme` from `lib/core/theme/app_theme.dart` — shared across all features
- **Product entity** is shared: `lib/domain/entities/product.dart` + `lib/data/models/product_model.dart` (DummyJSON mapping)
- **Bottom navigation** uses `IndexedStack` to preserve state (cart, favorites) when switching tabs