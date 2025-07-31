# eCommerce App 

This project is part of a learning journey being created layer by layer using:
- **Flutter**
- **Test-Driven Development (TDD)**
- **Clean Architecture**

## Previous Tasks

- **Refactored the Domain Layer**:
    - Created the `Product` entity.
    - Added 5 Use Cases (Create, Update, Delete, View All, View Single).
    - Introduced a `ProductRepository` interface to separate business logic from data handling.

## Current Task
In this task, the **Data Layer** was added by creating:
    - A `ProductModel` class
    - Methods for converting data:
        - `fromJson()` -> JSON -> Model
        - `toJson()` -> Model -> JSON
    - A fixture file (`product.json`) and helper to simulate API responses during tests.
    - `Unit tests` to test model serialization and deserialization.

## How to Run Tests
1. Install dependencies:
```bash
flutter pub get
```
2. Run:
```bash
flutter test
```
