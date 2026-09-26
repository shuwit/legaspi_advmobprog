# legaspi_advmobprog

A new Flutter project for Lab Activity 2.

## Lab Activity 2: Discussion

### How the Model, Services, and Screen Interact
In this application, the architecture is divided into distinct layers to cleanly separate concerns and render data from the API endpoint:
- **Model (`product_model.dart`)**: This layer defines the data structure. It acts as a blueprint, mapping the raw JSON data received from the API into strongly typed Dart objects (`Product`).
- **Service (`product_service.dart`)**: This layer handles the business logic and network communication. It is responsible for making HTTP requests to the API endpoint, receiving the JSON response, and utilizing the Model to parse that data into a list of `Product` objects.
- **Screen (`product_screen.dart`)**: This is the UI layer. It does not handle any data fetching itself; instead, it calls the Service to retrieve the list of products. Using widgets like `FutureBuilder`, it waits for the Service to return the data and then builds the user interface to display the products to the user.

### The New Design Pattern
This activity introduces a modular, layered design pattern that heavily promotes the **Separation of Concerns**. By isolating the network logic (Services), data structures (Models), and the user interface (Screens/Widgets), the codebase becomes much more readable, maintainable, and scalable. 

Additionally, the introduction of the `provider` package (used in `theme_provider.dart`) demonstrates effective state management. It allows global states (like dark/light mode) to be managed and accessed anywhere in the app without passing variables down the widget tree manually, keeping the UI reactive and clean.

## Lab Activity 3: Discussion

### How Cart Model, Services, and Screen Interact
In this lab, the **Cart Model** (`cart.dart`) maps the JSON data returned from the DummyJSON API into structured Dart objects representing carts and their products. The **Cart Service** (`cart_service.dart`) handles the network requests to fetch a cart by User ID and add products to the cart. Finally, the **Cart Screen** (`cart_screen.dart`) awaits the service's response using a `FutureBuilder`. Once the cart data is retrieved, the screen iterates through the cart products to render the UI.
When a user clicks on a cart item, the screen utilizes the `ProductService` to fetch the complete product details and then navigates to the existing `product_details_screen.dart`, effectively reusing the detail screen for cart items.

### The Updated Design Pattern
This activity reinforces the layered architecture pattern (Model-View-Service). A key updated design pattern here is the reuse of existing UI components (`ProductDetailsScreen`) across different features (browsing products vs. viewing a product from the cart). It also demonstrates proper state handling in standard UI components—for instance, changing the main Chat navigation into a `FloatingActionButton` that hides itself dynamically based on the current screen index in the `BottomNavigationBar`.

### Using getById at the Cart Endpoint
To use `getById` (specifically fetching a cart by User ID), the `CartService` makes a GET request to the endpoint `https://dummyjson.com/carts/user/:userId`. The service takes an integer `userId`, interpolates it into the URL string, and waits for a response. If successful, the resulting list of carts is parsed, and the first matching cart is returned and rendered on the screen.

## Lab Activity 4: Discussion

### How the User Model, Services, and Screen Interact
In this activity, authentication and profile rendering follow the same layered approach used in earlier labs, now extended with local persistence:

- **Model (`user.dart`)**: Defines the structure of an authenticated user (id, username, email, first/last name, gender, image, and tokens). `User.fromJson` maps the DummyJSON `/auth/login` response into a typed Dart object so the rest of the app does not work with raw JSON maps.
- **Service (`user_service.dart`)**: Owns authentication and persistence. `loginUser` POSTs credentials to `$host/auth/login`, then `saveUserData` writes the user fields into `SharedPreferences`. Helpers such as `getUserData`, `getUser`, `isLoggedIn`, and `logout` let screens read or clear that saved session without talking to the API again.
- **Screens**:
  - `splash_screen.dart` waits briefly, calls `isLoggedIn()`, and routes either to `/home` (with saved user data) or `/signin`.
  - `signin_screen.dart` validates the form, calls `loginUser`, stores the session, and navigates to `/home`.
  - `profile_screen.dart` loads the `User` from `SharedPreferences` via `getUser()` and renders avatar, name, username, email, gender, and user id, with a logout action that clears prefs and returns to sign-in.

Together, Model → Service → Screen keeps network/storage logic out of the UI while still rendering live API-backed profile data on `profile_screen`.

### Updated Design Pattern
This lab updates the architecture with **persistent authentication** using `shared_preferences`. Instead of always opening on the shop home, the app uses a splash entry point that restores a previous session from local storage. That introduces a simple auth gate pattern: splash decides the first real screen, sign-in creates the session, and profile/home consume the saved user. The Provider-based theme state from earlier labs remains, while session state is handled by the UserService + SharedPreferences combination.

### Using Saved Data to Render Cart by User ID
After login, the user’s `id` is stored locally. On `cart_screen`, the app no longer hardcodes a user id. It calls `UserService.getUserData()`, reads the saved `id`, and passes that value to `CartService.getCartByUserId(userId)`. That means the cart endpoint (`/carts/user/:userId`) is driven by the authenticated user’s saved identity—for example, signing in as `emilys` (id `1`) loads that user’s cart from DummyJSON.

## Long Exam 1: Discussion

### How Models, Services, and Screens Interact
Long Exam 1 builds a Facebook-style app on DummyJSON (`https://dummyjson.com/`) using the same layered pattern:

- **Models**: `user.dart` maps auth/profile data; `post.dart` maps post JSON (including reactions); `comment.dart` maps comment JSON and nested user info.
- **Services**: `UserService` authenticates and persists the session; `PostService` loads the newsfeed (`/posts`) and profile posts (`/posts/user/:userId`); `CommentService` loads and adds comments (`/comments/post/:postId`, `/comments/add`).
- **Screens**: Splash/sign-in gate the app using saved tokens. `NewsfeedScreen` renders all posts. `ProfileScreen` loads the saved user, then renders that user’s posts. `DetailScreen` shows one post with its comments, a clickable like action, and an add-comment form. `SettingsScreen` holds theme preference and Sign Out.

Flow for profile posts: login saves `userId` → Profile calls `getPostsByUserId(savedId)` → `PostCard` widgets render the API result.

### Updated Design Pattern
The exam extends Model–Service–Screen with **persistent authentication** and **feature modules** (posts + comments). Splash restores session state from `SharedPreferences`. Provider still manages theme preference on Settings, while auth/session stays in `UserService`. Reusable widgets such as `PostCard` keep like/comment UI consistent across newsfeed, profile, and detail.

### Posts, Comments, and Likes
Posts on the profile come from the saved user id, not a hardcoded value. Opening a post loads comments for that post id. The like button updates local like state when tapped. Adding a comment sends `body`, `postId`, and the saved `userId` to DummyJSON’s add-comment endpoint, then refreshes the comment list.

## Lab Activity 5: Discussion

### DummyJSON vs Firebase Workflow (Sign In to Sign Up)
This laboratory keeps both authentication paths inside one `UserService`:

- **DummyJSON sign-in**: The UI collects username/password, then `loginUser` sends `POST /auth/login` to DummyJSON. The JSON response is mapped to the `User` model and stored in `SharedPreferences` with `loginType = dummyJson`. Splash later checks for a saved token and routes to home.
- **Firebase sign-up**: The new `signup_screen` collects `fName`, `lName`, `age`, `contactNo`, `username`, `emailAddress`, and `password`. `createAccount` registers the user in Firebase Auth, `updateUsername` sets the display name, and the extra profile fields are saved locally with `loginType = firebase`.
- **Firebase sign-in**: The sign-in screen can switch to Firebase mode and call `signIn(email, password)` through the Firebase Auth SDK. Session state is then based on `FirebaseAuth.currentUser`, with profile details still readable via `getUserData()`.

Both flows end at the same home/profile UI, but profile details and available actions depend on `LoginType`.

### Main Idea of the UserService Implementation
`UserService` is the single auth gateway for the app. Older DummyJSON helpers (`loginUser`, `saveUserData`, `getUserData`, `isLoggedIn`, `logout`) remain, and Firebase methods from the handout are added underneath: `signIn`, `createAccount`, `signOut`, `updateUsername`, `deleteAccount`, and `resetPasswordFromCurrentPassword`. Screens do not talk to HTTP/Firebase directly; they call `UserService`, which decides how to authenticate, persist, update, or clear the session.

### Benefits of Firebase in this Flutter Lab
Firebase Auth provides real account creation, secure password handling, token refresh, and account lifecycle features (update username, change password, delete account) that DummyJSON only simulates. It also prepares the app for production-like auth while still allowing DummyJSON for API-driven demo data (posts/carts). That dual approach makes the laboratory useful for comparing API-token auth versus a managed identity provider.

