# AI Gift Feature — Architecture Guide

### 1. `lib/core/services/ai_service.dart` — The ONLY file that talks to Gemini
- Sets up the Gemini model (`gemini-3.6-flash`), generation config, and JSON response schema
- Holds the Arabic **system instruction** that tells the AI to be a gift assistant
- Builds the structured prompt from user preferences + a product catalog (as JSON)
- Calls Gemini and **parses the raw response** into `AiRecommendationResult` (`suggestions` + `summary`)
- Also defines `AiSuggestion` (`productId` + `reason`) — the raw AI output shape
- Does NOT know about `Product` entities or matching

### 2. `lib/domain/usecases/get_ai_recommendations.dart` — The matching brain
- Takes a `List<Product>` catalog + a `GiftPreferences`
- Converts `Product` entities into JSON maps the AI understands (description truncated to 100 chars)
- Calls `AiService` to get the suggestions
- **Matches the AI-suggested product IDs back to real `Product` entities**
- Returns `AiGiftRecommendationResult` = matched `products` + per-product `reasons` + Arabic `summary`
- Contains NO Gemini/UI logic — pure domain logic, testable on its own

### 3. `lib/presentation/ai_gift/bloc/ai_gift_bloc.dart` — The flow orchestrator
- Listens for `SubmitAIPreferences`
- Fetches the product catalog from `ApiDataSource` (100 products)
- Calls the `GetAiRecommendations` use case
- Emits states: `AIGiftLoading` → `AIGiftLoaded` / `AIGiftError`
- Contains NO AI or matching logic — it just wires the pieces

### 4. `lib/presentation/ai_gift/bloc/ai_gift_event.dart` — The messages
- `SubmitAIPreferences` — carries ONE `GiftPreferences` object (no loose fields)

### 5. `lib/presentation/ai_gift/bloc/ai_gift_state.dart` — The status board
- `AIGiftInitial` / `AIGiftLoading` / `AIGiftLoaded` / `AIGiftError`
- `AIGiftLoaded` wraps the single `AiGiftRecommendationResult` — it does NOT re-declare `products/reasons/summary`

### 6. `lib/core/models/gift_preferences.dart` — The shared preferences object
- One immutable object: `ageRange`, `gender`, `occasion`, `interests`, `budgetMax`
- Passed as ONE unit through: form → results screen → event → bloc → use case → `AiService`
- This is why those 5 fields appear only ONCE in the whole codebase

### 7. `lib/presentation/ai_gift/ai_gift_form_screen.dart` — Collects user preferences
- Dropdowns: age range, gender, occasion
- Multi-select interests (FilterChip)
- Budget field (0 = no limit)
- On submit → builds a `GiftPreferences` and navigates to the results screen with it

### 8. `lib/presentation/ai_gift/ai_gift_results_screen.dart` — Shows the results
- Takes ONE `GiftPreferences`, creates `AIGiftBloc` with the real dependencies (`GetAiRecommendations` + `ApiDataSource`) and fires `SubmitAIPreferences`
- Loading spinner while the AI works
- Gradient banner with the AI's Arabic summary
- One card per recommended product (`_AIProductCard`): image, "AI Suggestion" badge, the **reason** the AI chose it, rating, price, favorite heart — the card handles its own `FavoritesBloc` wiring and reuses the shared `RatingStars` + `PriceTag` widgets
- "Try Again" on error re-submits the same preferences in place (no dead reset, no pop)
- Reads everything from `state.result.*` — one shared result type

---

## How the Pieces Fit Together

```
AIGiftFormScreen — builds a GiftPreferences (age, gender, occasion, interests, budget)
      │  navigates with the ONE preferences object
      ▼
AIGiftResultsScreen
      │  creates AIGiftBloc(GetAiRecommendations(AiService), ApiDataSource)
      │  fires SubmitAIPreferences(preferences)
      ▼
AIGiftBloc  ── fetches 100 products from ApiDataSource ──►  DummyJSON API
      │
      │  calls use case: GetAiRecommendations(catalog, preferences)
      ▼
GetAiRecommendations (domain)  ── catalog → JSON ──►  AiService
      │                                                 │
      │                                                  └──►  Gemini (Firebase AI Logic)
      │                                                 ▲
      │                                           raw JSON response
      │◄────────── suggestions {productId, reason} + summary ──
      │
      │  matches productIds back to Product entities
      ▼
AIGiftLoaded(result)  →  AIGiftResultsScreen renders state.result.products/reasons/summary
```

---

## Why This Structure (and what was removed)

Originally there were **two nearly identical Gemini implementations**:
- `ai_service.dart` (a Gemini connector that was never wired in)
- `ai_gift_data_source.dart` (a copy of the same code that WAS wired in)

...plus a dead `chat_message_model.dart` and a `get_ai_recommendations.dart` use case with broken imports.

**What was removed:**
- `lib/data/data_sources/remote/ai_gift_data_source.dart` — deleted (was a duplicate of `AiService`)
- `lib/data/models/chat_message_model.dart` — deleted (no chat feature exists; it was never used)
- The inline product-matching in the old bloc — moved into the `GetAiRecommendations` use case where it belongs
- `ResetAIGift` event — deleted (was only "used" by a Try Again button that reset then popped; the bloc is disposed on pop so it did nothing)
- The results screen's inline `BlocBuilder<FavoritesBloc>` wrapper — moved into `_AIProductCard` (same pattern as `FavoritableProductCard`)
- Hand-rolled star + price in the AI card — replaced with the shared `RatingStars` and `PriceTag` widgets
- The 5 loose preference fields passed through every layer — replaced by the single `GiftPreferences` object
- The duplicated `products/reasons/summary` fields in `AIGiftLoaded` — replaced by wrapping `AiGiftRecommendationResult`

**What each file now is — one-liner summary:**

| File | One job |
|------|---------|
| `ai_service.dart` | Talk to Gemini, parse its JSON answer |
| `get_ai_recommendations.dart` | Match AI suggestions to real products |
| `ai_gift_bloc.dart` | Orchestrate: fetch catalog → use case → emit state |
| `ai_gift_event.dart` | Define the messages the bloc accepts |
| `ai_gift_state.dart` | Define the statuses the UI reacts to (wraps one result type) |
| `gift_preferences.dart` | The ONE preferences object shared by all layers |
| `ai_gift_form_screen.dart` | Collect the user's preferences into a `GiftPreferences` |
| `ai_gift_results_screen.dart` | Display the AI's recommendations |

### Why no duplicate params/results now

- The 5 preference fields (`ageRange/gender/occasion/interests/budgetMax`) exist **only** in `GiftPreferences`
- The result shape (`products/reasons/summary`) exists **only** in `AiGiftRecommendationResult` — `AIGiftLoaded` just wraps it
- `AiRecommendationResult` (`suggestions`/`summary`) is the raw AI output — different by design (it holds product IDs, not entities)

### Known intentional repetition (not considered a bug)

The favorite-wiring block (`BlocBuilder<FavoritesBloc>` + `favorites.any(...)` + `AddFavorite/RemoveFavorite` dispatch) appears in **two** widgets: `FavoritableProductCard` and `_AIProductCard` in the results screen. They can't share one widget because their layouts differ (grid card vs. horizontal list card with a reason text), so extracting it would mean a generic "favorites-aware" wrapper — a new abstraction for ~8 lines. It follows the repo's established pattern, so it's intentional.

---

## Verification

- `flutter analyze` → **0 issues**
- No dead references remain (`ResetAIGift`, `AIGiftDataSource`, `ChatMessage` all gone — verified by grep)
- Full wiring chain confirmed: form → `GiftPreferences` → results screen → `SubmitAIPreferences` → bloc → use case → `AiService` → Gemini → matched products → `AIGiftLoaded`
