## Models in Dart

In Dart, models are classes that represent the structure of data in your application. They are typically used to define the properties and behavior of objects, making it easier to work with structured data.

### Key Features of Models:
1. **Properties**: Models define the fields (variables) that hold data.
2. **Constructors**: They provide a way to create instances of the model with specific values.
3. **Methods**: Models can include functions to manipulate or retrieve data.
4. **Serialization**: Models often include methods to convert data to and from formats like JSON.

### Example:
Here’s a simple Dart model for a `User`:

```dart
class User {
  final String name;
  final int age;

  // Constructor
  User({required this.name, required this.age});

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }

  // Factory method to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      age: json['age'],
    );
  }
}