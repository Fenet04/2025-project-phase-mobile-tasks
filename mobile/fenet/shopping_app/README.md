# Task 7: Flutter eCommerce App with Navigation

This is a simple eCommerce mobile app built with Flutter as part of Task 7 for the 2025 mobile project. The goal of this task is to demonstrate proper use of navigation and routing in a flutter app.

## Current Functionality
while the app does not fully implement backend features like adding, updating, or deleting actual data, it includes:
- A **Home Page** that shows a list of products.
- A **Details Page** that shows product details and size options when you click on a product.
-An **Add/Update Page** with a form UI for adding or updating a product.
-A **Search Page** with filtering by name, category, and price.

## Naviagtion Features Implemented
- ✅ **Screen Navigation**: You can navigate between Home, Search, Add/Update, and Details pages.
- ✅ **Named Routes**: Implemented using `onGenerateRoute` in `main.dart`.
- ✅ **Passing Data**: Product data is passed from Home to Details and Add/Update Screens 
- ✅ **Navigation Animations**: slide animation added for page transitions.
- ✅ **Back Navigation**: All pages handle the back button correctlyto go back to the home page.

##How to run the app
1. Clone the repository:
```bash
git clone https://github.com/Fenet04/2025-project-phase-mobile-tasks.git
cd 2025-project-phase-mobile-tasks/mobile/fenet/shopping_app
```
2. Switch to the branch for task 7
```bash
git checkout fenet/task_7
```
3. Run the app
```bash
flutter pub get
flutter run
```
