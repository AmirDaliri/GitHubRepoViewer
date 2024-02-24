### GitHubRepoViewer

## Features

- Browse GitHub repositories by organization.
- View detailed information about each repository, including description, programming language, stars count, forks count, and more.
- Mark repositories as favorites for easy access.
- Search for repositories within an organization.
- View README files of repositories.
- Integrates Combine framework for reactive programming and handling asynchronous events.
- Implements both async throws and Combine network layers for making network requests with different paradigms.
- Utilizes the MVVM (Model-View-ViewModel) architectural pattern for a clear separation of concerns and easier unit testing.
- Documented with inline comments for better code readability and maintainability.

## Automatic Testing, Archiving, and Building with Xcode Cloud

This project utilizes Xcode Cloud for automatic testing, archiving, and building processes. Xcode Cloud seamlessly integrates with GitHub repositories, allowing for continuous integration and delivery (CI/CD) pipelines. With Xcode Cloud, developers can automate testing workflows, ensure code quality, and streamline the deployment process, leading to faster delivery of high-quality software.

## Unit Tests

The project includes a comprehensive suite of unit tests to ensure the reliability and correctness of its functionalities. Unit tests cover various components, including model classes, view models, network services, and UI components (if applicable). By running unit tests regularly, developers can identify and fix issues early in the development process, leading to more robust and maintainable code.

To run the unit tests locally:

1. Open the project in Xcode.
2. Navigate to the project navigator and select the test target.
3. Press `Cmd + U` or choose `Product > Test` from the Xcode menu to run the tests.

## UI Tests

In addition to unit tests, the project includes a set of UI tests to validate the user interface and interactions. These UI tests cover critical user flows and ensure that the app's UI behaves as expected across different devices and screen sizes.

To run the UI tests locally:

1. Open the project in Xcode.
2. Navigate to the project navigator and select the UI test target.
3. Press `Cmd + U` or choose `Product > Test` from the Xcode menu to run the UI tests.

By including UI tests in the testing suite, developers can verify that changes to the codebase do not inadvertently affect the app's visual appearance or user experience. This helps maintain consistency and reliability in the app's UI components.

## SnapKit for Programmatically Building UI

The project leverages SnapKit, a Swift DSL (Domain Specific Language) for Autolayout, to programmatically build the user interface. SnapKit simplifies the process of creating constraints and layouts, making UI development more intuitive and efficient. By using SnapKit, developers can achieve responsive and adaptive layouts without the need for Interface Builder.

## Core Data for Saving Favorite Items

The app uses Core Data, Apple's framework for object graph and persistence management, to save favorite repositories locally. Core Data provides a robust and efficient way to manage the model layer of the application and enables seamless integration with other iOS frameworks. By leveraging Core Data, the app ensures data consistency, reliability, and scalability for managing favorite items.

Alternatively, **UserDefaults** could be used for saving simple user preferences and settings. UserDefaults is suitable for storing small amounts of data such as user preferences, settings, and small pieces of user-specific data. However, for more complex data models and relationships, Core Data offers a more comprehensive solution with features like data validation, relationship management, and efficient fetching mechanisms.

## Installation

To install and run this application, follow these steps:

1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. Build and run the project on your preferred iOS simulator or device.

### Prerequisites

- Xcode installed on your Mac
- iOS simulator or physical iOS device

## Usage

To use the application:

1. Launch the app on your iOS device or simulator.
2. Navigate through the app's interface using the provided features.
3. Explore the functionality, such as searching for repositories, viewing favorites, etc.
4. Interact with the app according to your needs and preferences.



## Contributing

Contributions are welcome! Here's how you can contribute to this project:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -am 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

Please make sure to update tests as appropriate.

## Acknowledgements

This project utilizes several third-party libraries and tools to enhance its functionality:

- **SnapKit**: Used for programmatically laying out the user interface components, SnapKit simplifies the process of creating constraints and layouts in Swift code. It is integrated into the project as a Swift Package Manager (SPM) dependency.

- **SwiftyMarkdown**: SwiftyMarkdown is employed for rendering Markdown content within the app, allowing for rich text formatting and display of Markdown documents. It is also integrated as a Swift Package Manager (SPM) dependency.

- **Xcode Cloud**: for enabling automatic testing, archiving, and building workflows.


## Contact

For inquiries, feedback, or issues related to this project, please feel free to contact:

- **LinkedIn**: [Amir Daliri](https://www.linkedin.com/in/amirdalirii/)
- **Email**: amir.daliri@icloud.com
