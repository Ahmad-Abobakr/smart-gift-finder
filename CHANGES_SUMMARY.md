# New Files Added

## 1. `lib/presentation/widgets/favorable_product_card.dart` (NEW FILE)

**Purpose**: Centralizes all favorite/cart/buy-now functionality for product cards across the app.

**Why created**: Before this file, favorite buttons, cart buttons, and buy-now buttons were either broken (creating isolated BlocProviders that were always empty), missing entirely, or inconsistently wired across different screens (Home, Categories, AI Results, Search).

**What it contains**:

### `FavoritableProductCard` class
A `StatelessWidget` that:
- Takes a `Product` as input
- Uses `BlocBuilder<FavoritesBloc, FavoritesState>` to watch favorite state in real-time
- Checks if the product is in the user's favorites list (via `favorites.any((p) => p.id == product.id)`)
- Renders `ProductCard` with the correct `isFavorite` flag
- When the heart icon is tapped, dispatches either `AddFavorite(product)` or `RemoveFavorite(product.id)` to the app-level `FavoritesBloc`

### `openProductDetails` helper function
The key glue that connects everything. When you tap any product anywhere in the app, this function:
- Shows a `showModalBottomSheet` with `ProductDetailsView` (product detail screen)
- Passes three callbacks wired into the detail view:
  - **`onFavoriteToggle`** — dispatches AddFavorite/RemoveFavorite to app-level `FavoritesBloc`
  - **`onAddToCart`** — dispatches `AddToCart(product)` to app-level `CartBloc` + shows snackbar
  - **`onBuyNow`** — dispatches `AddToCart(product)` + navigates to CartScreen
- This is why all buttons work consistently across Home, Categories, AI Results, and Search

**How it's used**:

In `home_screen.dart`, `categories_screen.dart`, `ai_gift_results_screen.dart`:

```dart
// Simple favorite-enabled product card:
FavoritableProductCard(product: product)

// For product details with full callback wiring (favorite, cart, buy-now):
onTap: () => openProductDetails(
  context,
  product: product,
)
```

**The problem it solved**: Every screen that showed product cards (Home, Categories, AI Results) previously had its own broken or inconsistent version of favorite/cart/buy-now buttons. Now there's one centralized component that properly connects to the app-level `FavoritesBloc` and `CartBloc` via the shared blocs set up in `main.dart`.

---

## 2. `lib/data/data_sources/remote/ai_gift_data_source.dart` (NEW FILE)

**Purpose**: Connects to Gemini AI via Firebase AI Logic to generate personalized gift recommendations.

**What it contains**:
- **Classes**: `AIGiftResponse` (holds `suggestions` list + `summary` string) and `AIGiftSuggestion` (holds `productId` + `reason` string)
- **Main method**: `getRecommendations()` which:
  1. Gets the Gemini model: `gemini-3.6-flash`
  2. Builds a catalog of 100 products from the API (title, price, category, brand, description)
  3. Sends a system prompt telling Gemini to be a "smart gift recommendation assistant"
  4. Sends the prompt with user preferences (ageRange, gender, occasion, interests, budgetMax)
  5. Parses the JSON response back into `AIGiftResponse`

**How it's used**:
```dart
final response = await AIGiftDataSource().getRecommendations(
  catalog: productEntities,
  ageRange: '25-30',
  gender: 'Female',
  occasion: 'Birthday',
  interests: 'Technology, Gaming',
  budgetMax: 500.0,
);
// response.suggestions -> List<AIGiftSuggestion>
// response.summary -> String explanation
```

---

## 3. `lib/presentation/ai_gift/bloc/ai_gift_bloc.dart` (NEW FILE)

**Purpose**: BLoC that orchestrates AI gift recommendation flow.

**What it does**:
1. Receives `SubmitAIPreferences` event with user's form data
2. Fetches 100 products from `ApiDataSource` to build catalog
3. Calls `AIGiftDataSource.getRecommendations()` with catalog + preferences
4. Matches AI-suggested product IDs back to actual `Product` entities
5. Emits `AIGiftLoaded` state with matched products, reasons, and summary

---

## 4. `lib/presentation/ai_gift/bloc/ai_gift_event.dart` (NEW FILE)

**Purpose**: Defines events for the AI Gift BLoC.

**Events**:
- `SubmitAIPreferences` — carries ageRange, gender, occasion, interests, budgetMax
- `ResetAIGift` — resets to initial state

---

## 5. `lib/presentation/ai_gift/bloc/ai_gift_state.dart` (NEW FILE)

**Purpose**: Defines states for the AI Gift BLoC.

**States**:
- `AIGiftInitial` — before any request
- `AIGiftLoading` — fetching products + calling AI
- `AIGiftLoaded` — contains `products` (List<Product>), `reasons` (List<String>), `summary` (String)
- `AIGiftError` — contains error message

---

## 6. `lib/presentation/ai_gift/ai_gift_form_screen.dart` (NEW FILE)

**Purpose**: Form screen where users enter gift preferences.

**What it contains**:
- Dropdowns for: Age Range, Gender, Occasion
- **Multiple-select interests chips** (using FilterChip allowing multi-selection)
- Budget text field (allows any amount, 0 = no limit)
- Form submission handler that navigates to `AIGiftResultsScreen` passing all values

---

## 7. `lib/presentation/ai_gift/ai_gift_results_screen.dart` (NEW FILE)

**Purpose**: Displays AI-recommended products with explanations.

**Key features**:
- Creates `AIGiftBloc` and immediately submits user preferences
- Shows loading spinner while AI generates recommendations
- Displays AI summary in a gradient banner
- Lists matched products in cards with:
  - AI suggestion badge
  - **Reason text** explaining why Gemini chose each product
  - Heart icon (wired via `FavoritableProductCard` + `openProductDetails`)
  - "AI Suggestion" label
  - Price and rating

---

## 8. `lib/core/services/ai_service.dart` (NEW FILE - CLEAN ARCHITECTURE)

**Purpose**: Service layer that connects directly to Gemini via Firebase AI Logic, following clean architecture patterns.

**What it contains**:
- `AiService` class with `GenerativeModel` setup using `gemini-3.6-flash`
- `getGiftRecommendations()` — structured request (ageRange, gender, occasion, interests, budgetMax)
- `getGiftRecommendationsFromPrompt()` — free-form chat-style prompt support (as specified in TASKS.md for Abobakr's chat feature)
- `AiRecommendationResult` / `AiSuggestion` classes for parsed responses
- System instruction in Arabic directing Gemini to respond in Arabic

**How it's used**:
```dart
final service = AiService();
final result = await service.getGiftRecommendations(
  catalog: catalogJson,
  ageRange: '25-30',
  gender: 'Any',
  occasion: 'Birthday',
  interests: 'Technology',
  budgetMax: 500.0,
);
```

---

## 9. `lib/domain/usecases/get_ai_recommendations.dart` (NEW FILE - CLEAN ARCHITECTURE)

**Purpose**: Domain-layer use case that wraps AiService and handles product matching.

**What it does**:
1. Takes `List<Product>` catalog + user preferences as input
2. Converts Product entities to JSON format for the AI prompt
3. Calls `AiService.getGiftRecommendations()`
4. Returns `AiRecommendationResult` with suggestions + summary

**How it's used** (from bloc):
```dart
final useCase = GetAiRecommendations(aiService: AiService());
final result = await useCase(
  catalog: productEntities,
  ageRange: '25-30',
  gender: 'Female',
  occasion: 'Birthday',
  interests: 'Technology',
  budgetMax: 500.0,
);
```

---

## 10. `lib/data/models/chat_message_model.dart` (NEW FILE - CLEAN ARCHITECTURE)

**Purpose**: Model for chat-style AI conversation messages (as specified in TASKS.md Task 2).

**What it contains**:
- `ChatMessage` class with: `id`, `content`, `isUser` (bool), `timestamp`
- `copyWith` method for immutable updates

**How it's used**:
```dart
final message = ChatMessage(
  id: '1',
  content: 'Looking for a tech gift under $100',
  isUser: true,
  timestamp: DateTime.now(),
);
```

---

## 11. `lib/presentation/ai_gift/ai_gift_form_screen.dart` (UPDATED)

**Purpose**: Form screen where users enter gift preferences for AI recommendations.

**Changes made**:
- Replaced single-select Interests dropdown with **FilterChip** widgets allowing **multiple interest selection**
  - Users can now tap multiple interests (e.g., "Technology" + "Gaming" + "Travel")
  - Chips show selected state with primary color background + white text
  - Selected chips can be deselected by tapping again
  - Selected interests joined with ", " passed to AI
- Replaced slider budget input with **clean numerical text field** inside styled container
- Added visual budget badge that updates in real-time as user types
- Improved form layout with consistent spacing and styling
- Added helpful text hint: "Enter 0 for no budget limit"
- Submit button disabled when budget is invalid (≤ 0)

---

## 11. `lib/presentation/ai_gift/ai_gift_results_screen.dart` (UPDATED)

**Purpose**: Displays AI-recommended products with explanations.

**Changes made**:
- Enhanced AI summary banner with better typography and spacing
- Improved product card layout:
  - Larger product thumbnails (96x96)
  - Clearer "AI Suggestion" badge styling
  - Improved reason text display with better line height and full text (no truncation)
  - More prominent price display
- Added decorative divider lines between product info sections
- Enhanced error state with retry button
- Full Arabic summary and reasons now displayed without truncation

---

## 8. `lib/presentation/main_screen.dart` (NEW FILE)

**Purpose**: Bottom navigation bar with 4 screens (Home, Categories, AI Gift Finder, Profile).

**What it does**:
- Hosts a `BottomNavigationBar` with 4 tabs
- Uses an `IndexedStack` to preserve state between tabs
- In `initState`, dispatches `LoadCart()` and `LoadFavorites()` to the app-level blocs so data is ready when navigating

---

## 9. `lib/data/user_model.dart` (NEW FILE)

**Purpose**: Simple user data model (separate from auth user model).

---

## 10. CI/CD / Release Support

### `.github/workflows/release.yml` (NEW FILE)

**Purpose**: Automated APK build and release publishing via GitHub Actions.

**What it does**:
1. Triggers on every git tag (e.g., `v1.0.0`) pushed to the repo
2. Checks out the code and sets up Flutter
3. Builds the APK (`flutter build apk --release`)
4. Uploads the APK as a GitHub Release artifact
5. Anyone with the repo link can download the APK from the "Releases" tab

**How it's used**:
```bash
# After pushing the workflow file, tag a release:
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions automatically builds and publishes the APK
# Download link appears at: https://github.com/<username>/<repo>/releases
```

**File contents**:
```yaml
name: Build APK Release
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
      - uses: softprops/action-gh-release@v1
        with:
          files: app-release
```
