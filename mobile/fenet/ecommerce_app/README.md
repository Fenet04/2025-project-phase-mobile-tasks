# eCommerce App 

This project is part of a learning journey being created layer by layer using:
- **Flutter**
- **Test-Driven Development (TDD)**
- **Clean Architecture**

## Layers Implemented So Far

### **Domain Layer**
- **Entities**
    - Defined core domain model `Product`.
- **Repositories**
    - Abstract contracts
- **Use Cases**
    -Use cases includ:
        - `CreateProductUsecase`
        - `UpdateProductUsecase`
        - `DeleteProductUsecase`
        - `ViewAllProductUsecase`
        - `ViewProductUsecase`
    - All usecases are tested with unit tests
### **Data Layer**
- **Models**
    - Dart representations of data for serialization and deserialization
- **Data Sources**
    - `LocalDataSource` - handles local storage acess.
    - `RemoteDataSource` - handles API communication.
- **Repositories**
    - Implementations of domain contracts
- All components in the data layer have corresponding unit tests

### **Core**
- **Error Handling**
    - `Failure` with classes like `ServerFailure`, `CacheFailure`
    - `Exception` classes to represent different error types
- **Platform**
    - `NetworkInfo` abstraction to check for internet connectivity.

### **Testing**
- Written tests for:
    - All domain usecases
    - Repository implementations
    - Local and remote data sources
    - Core utilities like network info
- Used `mocktail` for mocking dependencies.
- Included fixtures to test real-world data scenarios

## Work in Progress
This project is still in development. Upcoming layers:
- **Presentation Layer**
    - State management using `Bloc`

## How to Run Tests
1. Install dependencies:
```bash
flutter pub get
```
2. Run:
```bash
flutter test
```
