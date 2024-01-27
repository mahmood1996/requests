# Requests

## A packages that wrap dio and throws common exceptions instead of DioException.

```dart
final response = await Request.get(dio: Dio(), path: ...).execute();
```