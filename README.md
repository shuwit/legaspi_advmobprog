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
