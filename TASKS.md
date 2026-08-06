# Smart Gift Finder - تقسيم المهام

## المشروع
تطبيق ذكي للهدايا يعمل بالذكاء الاصطناعي، يساعد المستخدمين على اكتشاف الهدية المثالية بناءً على اهتمامات المستلم وعمره وميزانيته.

---

## فكرة التقسيم

كل عضو يبني **وحدة مستقلة كاملة** (feature) من الألف إلى الياء:

- طبقة البيانات الخاصة به (Data Source + Models)
- طبقة المنطق الخاصة به (Repository + Use Case + Bloc)
- واجهة المستخدم الخاصة به (Screens + Widgets)

لا أحد ينتظر أحداً، كل مهمة قابلة للتشغيل والاختبار بمفردها (تشغّل شاشتك مؤقتاً كـ `home` في `main.dart`).

**الملفات المشتركة الجاهزة (Shared - مبنية مسبقاً، استخدمها بدون تعديل):**
1. `AppTheme` في `lib/core/theme/app_theme.dart`
2. `Product` entity في `lib/domain/entities/product.dart` + `ProductModel` في `lib/data/models/product_model.dart` (يتعامل مع DummyJSON)
3. شاشة تفاصيل المنتج `showProductDetails()` + `ProductDetailsView` في `lib/presentation/widgets/product_details_screen.dart`
4. `RatingStars` في `lib/presentation/widgets/rating_stars.dart` + `PriceTag` في `lib/presentation/widgets/price_tag.dart`

عند الربط النهائي سنقوم بـ:
1. بناء `app_router.dart` لربط كل الشاشات
2. الربط في `main.dart`

---

## هيكل المشروع

```
lib/
├── main.dart
├── core/
│   ├── theme/app_theme.dart          ✅ تم الإنشاء (مشترك)
│   ├── constants/
│   ├── network/
│   ├── services/
│   ├── errors/
│   ├── routes/
│   └── utils/
├── data/
│   ├── models/
│   │   └── product_model.dart         ✅ تم الإنشاء (مشترك)
│   ├── data_sources/remote/
│   ├── data_sources/local/
│   └── repositories/
├── domain/
│   ├── entities/
│   │   └── product.dart               ✅ تم الإنشاء (مشترك)
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── auth/bloc/
    ├── home/bloc/
    ├── categories/bloc/
    ├── search/bloc/
    ├── ai_gift_finder/bloc/
    ├── favorites/bloc/
    ├── cart/bloc/
    ├── profile/bloc/
    └── widgets/
        ├── product_details_screen.dart  ✅ تم الإنشاء (مشترك)
        ├── rating_stars.dart            ✅ تم الإنشاء (مشترك)
        └── price_tag.dart               ✅ تم الإنشاء (مشترك)
```

---

## المهام

### المهمة ١ - أدهم (وحدة المصادقة Authentication)

وحدة مستقلة كاملة: تسجيل الدخول، إنشاء حساب، إعادة تعيين كلمة المرور.

**الملفات المطلوبة:**

| الملف | المسار |
|---|---|
| `auth_data_source.dart` | `lib/data/data_sources/remote/` |
| `user_model.dart` | `lib/data/models/` |
| `user.dart` | `lib/domain/entities/` |
| `auth_repository.dart` | `lib/domain/repositories/` |
| `auth_repository_impl.dart` | `lib/data/repositories/` |
| `auth_bloc.dart` | `lib/presentation/auth/bloc/` |
| `auth_event.dart` | `lib/presentation/auth/bloc/` |
| `auth_state.dart` | `lib/presentation/auth/bloc/` |
| `login_screen.dart` | `lib/presentation/auth/` |
| `register_screen.dart` | `lib/presentation/auth/` |
| `forgot_password_screen.dart` | `lib/presentation/auth/` |

**التفاصيل:**

**auth_data_source.dart:**
- تغليف `Firebase Auth`: `signIn`, `signUp`, `signOut`, `resetPassword`
- إرجاع `UserModel` بعد تسجيل الدخول أو التسجيل

**user_model.dart + user.dart:**
- الخصائص: id, email, displayName, photoUrl
- `UserModel` مع `fromJson` و `toJson`

**auth_repository.dart + auth_repository_impl.dart:**
- واجهة مجردة + تنفيذها باستخدام `AuthDataSource`

**auth_bloc.dart:**
- الأحداث: `LoginRequested`, `RegisterRequested`, `ForgotPasswordRequested`, `LogoutRequested`
- الحالات: `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthError`

**login_screen.dart:**
- حقل البريد الإلكتروني، حقل كلمة المرور، زر تسجيل الدخول، رابط للتسجيل

**register_screen.dart:**
- حقل الاسم، البريد الإلكتروني، كلمة المرور، زر التسجيل

**forgot_password_screen.dart:**
- حقل البريد الإلكتروني، زر الإرسال

**الاختبار:** اجعل `LoginScreen` شاشة البداية مؤقتاً، وتسجيل الدخول بكلمة مرور حقيقية من Firebase.

---

### المهمة ٢ - أبو بكر (وحدة الذكاء الاصطناعي AI Gift Finder)

وحدة مستقلة كاملة: محادثة مع الذكاء الاصطناعي للحصول على توصيات هدايا.

**الملفات المطلوبة:**

| الملف | المسار |
|---|---|
| `ai_service.dart` | `lib/core/services/` |
| `chat_message_model.dart` | `lib/data/models/` |
| `get_ai_recommendations.dart` | `lib/domain/usecases/` |
| `ai_gift_finder_bloc.dart` | `lib/presentation/ai_gift_finder/bloc/` |
| `ai_gift_finder_event.dart` | `lib/presentation/ai_gift_finder/bloc/` |
| `ai_gift_finder_state.dart` | `lib/presentation/ai_gift_finder/bloc/` |
| `ai_gift_finder_screen.dart` | `lib/presentation/ai_gift_finder/` |
| `ai_chat_bubble.dart` | `lib/presentation/widgets/` |

**التفاصيل:**

**ai_service.dart:**
- إعداد `Firebase AI` (Gemini) للاتصال بالنموذج
- دالة `getGiftRecommendations` تأخذ: العمر، الجنس، المناسبة، الاهتمامات، الميزانية
- دالة `getGiftRecommendationsFromPrompt` تأخذ نص حر من المستخدم
- تحليل الاستجابة واستخراج المنتجات المقترحة مع سبب التوصية لكل منتج

**chat_message_model.dart:**
- الخصائص: id, content, isUser, timestamp

**get_ai_recommendations.dart:**
- Use Case يستخدم `AiService` ويعيد قائمة توصيات

**ai_gift_finder_bloc.dart:**
- الأحداث: `SendRecommendationRequest`, `LoadChatHistory`
- الحالات: `AiInitial`, `AiLoading`, `AiLoaded(messages)`, `AiError`

**ai_gift_finder_screen.dart:**
- واجهة شات (Chat UI)
- حقل إدخال النص في الأسفل مع زر الإرسال
- بانر في الأعلى "أخبرنا عن الهدية" مع حقول: الفئة العمرية، الجنس، المناسبة، الاهتمامات، الميزانية (Slider)
- زر "احصل على توصيات AI"

**ai_chat_bubble.dart:**
- فقاعة رسالة الشات
- للمستخدم: خلفية بنفسجية، نص أبيض، على اليمين
- للـ AI: خلفية بيضاء، نص رمادي، على اليسار
- تحتوي على: اسم المنتج + السبب + السعر + التقييم

**الاختبار:** شغّل الشاشة مع رسالة تجريبية ثابتة (Mock) قبل ربط Gemini.

---

### المهمة ٣ - إبراهيم (وحدة الرئيسية والملف الشخصي)

وحدة مستقلة كاملة: الصفحة الرئيسية (المنتجات + الفئات + البحث) والملف الشخصي.

**الملفات المطلوبة:**

| الملف | المسار |
|---|---|
| `api_data_source.dart` | `lib/data/data_sources/remote/` |
| `product_repository.dart` | `lib/domain/repositories/` |
| `product_repository_impl.dart` | `lib/data/repositories/` |
| `home_bloc.dart` | `lib/presentation/home/bloc/` |
| `home_event.dart` | `lib/presentation/home/bloc/` |
| `home_state.dart` | `lib/presentation/home/bloc/` |
| `home_screen.dart` | `lib/presentation/home/` |
| `product_card.dart` | `lib/presentation/widgets/` |
| `category_card.dart` | `lib/presentation/widgets/` |
| `profile_bloc.dart` | `lib/presentation/profile/bloc/` |
| `profile_event.dart` | `lib/presentation/profile/bloc/` |
| `profile_state.dart` | `lib/presentation/profile/bloc/` |
| `profile_screen.dart` | `lib/presentation/profile/` |

**التفاصيل:**

**api_data_source.dart:**
- استخدام Dio للاتصال بـ DummyJSON API
- `getProducts()` مع pagination
- `getCategories()`
- `searchProducts(query)`
- تحويل الرد إلى `ProductModel` المشترك (جاهز) ثم `toEntity()`

**product_repository.dart + product_repository_impl.dart:**
- واجهة مجردة + تنفيذها باستخدام `ApiDataSource`
- يستخدم كائن `Product` المشترك من `lib/domain/entities/product.dart` (لا تنشئ نسخة أخرى)

**home_bloc.dart:**
- الأحداث: `LoadHomeData`, `SearchProducts`
- الحالات: `HomeLoading`, `HomeLoaded`, `HomeError`

**home_screen.dart:**
- شريط البحث في الأعلى (بحث فوري في DummyJSON)
- بانر "دع الذكاء الاصطناعي يساعدك" بنمط التدرج اللوني
- شبكة الفئات (Birthdays, Electronics, Fashion, Books, Home)
- قائمة المنتجات المقترحة باستخدام `ProductCard`

**product_card.dart:**
- بطاقة منتج: صورة + اسم + سعر + أيقونة قلب
- استخدام `AppTheme`

**category_card.dart:**
- بطاقة فئة: أيقونة + اسم الفئة + عدد العناصر

**profile_bloc.dart:**
- الأحداث: `LoadProfile`, `Logout`
- الحالات: `ProfileLoading`, `ProfileLoaded`, `ProfileError`

**profile_screen.dart:**
- عرض بيانات المستخدم من `FirebaseAuth.instance.currentUser` مباشرة (name, email, photo)
- إحصائيات: عدد المفضلة، عدد مشترياتي (قيم ثابتة مؤقتاً)
- إعدادات الحساب
- زر تسجيل الخروج

**الاختبار:** شغّل `HomeScreen` كشاشة البداية واعرض المنتجات الحقيقية من DummyJSON.

---

### المهمة ٤ - أميرة (وحدة الفئات والبحث)

وحدة مستقلة كاملة: استعراض الفئات، والبحث عن هدية مع فلتر الميزانية. (شاشة تفاصيل المنتج أصبحت **مشتركة جاهزة** في `lib/presentation/widgets/product_details_screen.dart` — تستدعيها فقط بـ `showProductDetails(...)`).

**الملفات المطلوبة:**

| الملف | المسار |
|---|---|
| `api_data_source.dart` | `lib/data/data_sources/remote/` |
| `categories_bloc.dart` | `lib/presentation/categories/bloc/` |
| `categories_event.dart` | `lib/presentation/categories/bloc/` |
| `categories_state.dart` | `lib/presentation/categories/bloc/` |
| `categories_screen.dart` | `lib/presentation/categories/` |
| `search_bloc.dart` | `lib/presentation/search/bloc/` |
| `search_event.dart` | `lib/presentation/search/bloc/` |
| `search_state.dart` | `lib/presentation/search/bloc/` |
| `search_screen.dart` | `lib/presentation/search/` |

**التفاصيل:**

**api_data_source.dart:**
- استخدام Dio للاتصال بـ DummyJSON API
- `getCategories()`
- `getProductsByCategory(category)`
- `searchProducts(query)`
- `getProductById(id)` - جلب منتج واحد (اختياري، للتحديث عند الحاجة)
- تحويل الرد إلى `ProductModel` المشترك (جاهز) ثم `toEntity()`

**categories_bloc.dart:**
- الأحداث: `LoadCategories`, `SelectCategory`
- الحالات: `CategoriesLoading`, `CategoriesLoaded`, `CategoriesError`

**categories_screen.dart:**
- شريط بحث في الأعلى
- قائمة الفئات كبطاقات: Electronics (120 items), Fashion (85 items), Toys & Games (95 items), Books (60 items), Home & Living (70 items), Beauty (40 items)
- كل فئة لها أيقونة وعدد العناصر
- النقر على فئة يعرض منتجاتها
- النقر على منتج يفتح `showProductDetails(...)` (مشتركة جاهزة)

**search_bloc.dart:**
- الأحداث: `SearchRequested`
- الحالات: `SearchInitial`, `SearchLoading`, `SearchLoaded(results)`, `SearchError`

**search_screen.dart:**
- حقل بحث + نتائج كبطاقات منتجات
- زر "فلترة حسب الميزانية" (Budget Filter)
- النقر على منتج يفتح `showProductDetails(...)` (مشتركة جاهزة)

**الاختبار:** شغّل `CategoriesScreen` أو `SearchScreen` كشاشة البداية مع بيانات حقيقية من DummyJSON.

---

### المهمة ٥ - أحمد (وحدة المفضلة والسلة)

وحدة مستقلة كاملة: إدارة المفضلة والسلة مع حفظ محلي ودائم.

**الملفات المطلوبة:**

| الملف | المسار |
|---|---|
| `local_data_source.dart` | `lib/data/data_sources/local/` |
| `firebase_data_source.dart` | `lib/data/data_sources/remote/` |
| `favorites_bloc.dart` | `lib/presentation/favorites/bloc/` |
| `favorites_event.dart` | `lib/presentation/favorites/bloc/` |
| `favorites_state.dart` | `lib/presentation/favorites/bloc/` |
| `favorites_screen.dart` | `lib/presentation/favorites/` |
| `cart_bloc.dart` | `lib/presentation/cart/bloc/` |
| `cart_event.dart` | `lib/presentation/cart/bloc/` |
| `cart_state.dart` | `lib/presentation/cart/bloc/` |
| `cart_screen.dart` | `lib/presentation/cart/` |

**التفاصيل:**

**local_data_source.dart:**
- استخدام SharedPreferences
- حفظ وجلب المفضلة والسلة كـ cache للعمل بدون إنترنت

**firebase_data_source.dart:**
- حفظ وجلب المفضلة والسلة من Firebase Firestore

**favorites_bloc.dart:**
- الأحداث: `LoadFavorites`, `AddFavorite`, `RemoveFavorite`
- الحالات: `FavoritesLoading`, `FavoritesLoaded(favorites)`, `FavoritesError`
- الحفظ في SharedPreferences + Firestore

**favorites_screen.dart:**
- قائمة المنتجات المفضلة
- كل منتج: صورة + اسم + سعر + أيقونة قلب ممتلئة (بنفسجية)
- إمكانية الحذف بسحب للجانب

**cart_bloc.dart:**
- الأحداث: `LoadCart`, `AddToCart`, `RemoveFromCart`, `UpdateQuantity`, `ClearCart`
- الحالات: `CartLoading`, `CartLoaded(items, totalPrice)`, `CartError`
- الحفظ في SharedPreferences + Firestore

**cart_screen.dart:**
- قائمة المنتجات في السلة مع الكمية
- كل منتج: صورة + اسم + سعر + أزرار + و -
- المجموع الكلي في الأسفل
- زر "إتمام الشراء"

**الاختبار:** شغّل `FavoritesScreen` أو `CartScreen` كشاشة البداية مع منتجات تجريبية مؤقتة (Mock Data) قبل الربط.

---

## ملاحظات عامة

1. **الألوان**: استخدم `AppTheme` في `lib/core/theme/app_theme.dart` (مشترك جاهز)
2. **كل وحدة مستقلة**: بياناتها + منطقها + شاشاتها، لا تنتظر أحداً
3. **المشترك الجاهز**: `Product` entity/model + `showProductDetails()` + `RatingStars` + `PriceTag` — استخدمها دون إنشاء نسخ
4. **الاختبار المبكر**: اجعل شاشتك شاشة البداية مؤقتاً في `main.dart` لتشغيلها واختبارها
5. **DummyJSON API**: `https://dummyjson.com/products` للمنتجات
6. **Firebase Auth**: للمصادقة (وحدة أدهم) ولعرض بيانات المستخدم (وحدة إبراهيم)
7. **Firebase Firestore**: لتخزين المفضلة والسلة (وحدة أحمد)
8. **Supabase**: يمكن استخدامه كبديل أو مكمل لـ Firestore
9. **Gemini AI**: لتوصيات الهدايا الذكية (وحدة أبو بكر)

## مرحلة الربط النهائي (بعد انتهاء الجميع)

1. بناء `app_router.dart` لربط كل الشاشات
2. ربط كل الوحدات في `main.dart`
3. اختبار تكاملي شامل
