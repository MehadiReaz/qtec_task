[Download File](https://drive.google.com/file/d/1vw2m9APjjteLhy8gWMSCheFwO2xeYpxB/view?usp=sharing)

A clean architecture Flutter application that demonstrates a product listing page with advanced features:

Product list with responsive grid layout
Search functionality with real-time results
Sorting options (Price high to low, Price low to high, Rating)
Infinite scroll pagination
Wishlist toggle functionality
Loading state management with shimmer effects


Features
Product Listing

Responsive grid layout with product cards
Each product displays image, title, price, and rating
Add/remove products to wishlist with a single tap
Pull-to-refresh functionality

Search

Real-time search with debounce functionality
Shows total number of search results
Empty state handling when no products match the search query

Sorting

Price - High to Low
Price - Low to High
Rating - High to Low
Sort button appears only during search

Pagination

Infinite scroll implementation
Loading indicator at the bottom when fetching more products
Optimized to prevent excessive API calls

Architecture
This project implements Clean Architecture principles with three main layers:
Domain Layer

Entities: Core business objects (ProductEntity, ProductListEntity)
Use Cases: Application-specific business rules
Repository Interfaces: Abstract definition of data operations

Data Layer

Repository Implementations: Concrete implementations of domain repositories
Data Sources: Remote and local data providers
Models: Data mapping between domain and data layers

Presentation Layer

BLoC: State management using flutter_bloc
UI: Widgets and screens to display data
Event/State: Clear separation of user interactions and UI states

State Management
The app uses BLoC pattern with the following states:

ProductsInitial: Initial state before any data is loaded
ProductsLoading: State during initial data load
ProductsRefreshing: State during pull-to-refresh
ProductsLoaded: State when products are successfully loaded
ProductsEmpty: State when no products match the search criteria
ProductLoadFailed: State when an error occurs

| **Product Search** | **Product List** |
|:-------------------:|:-----------------:|
| ![Screenshot_1745786956](https://github.com/user-attachments/assets/db817c64-3d20-4067-8f55-d4aa40fadfe7) | ![Screenshot_1745786984](https://github.com/user-attachments/assets/ff2cfe41-b26d-4d8a-a78a-ec3d658416f9) |




