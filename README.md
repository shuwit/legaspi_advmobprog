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
