import 'dart:async';

/// API Helper class with retry logic and error handling
class ApiHelper {
  /// Make an API call with retry logic
  /// 
  /// Parameters:
  /// - apiCall: The function that makes the API call
  /// - maxRetries: Maximum number of retry attempts
  /// - retryDelay: Delay between retries in seconds
  /// - onRetry: Optional callback when retrying
  static Future<T> withRetry<T>({
    required Future<T> Function() apiCall,
    int maxRetries = 3,
    int retryDelay = 2,
    Function(int attempt)? onRetry,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await apiCall();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        if (onRetry != null) {
          onRetry(attempts);
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: retryDelay));
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  /// Make an API call with timeout
  /// 
  /// Parameters:
  /// - apiCall: The function that makes the API call
  /// - timeoutSeconds: Timeout duration in seconds
  static Future<T> withTimeout<T>({
    required Future<T> Function() apiCall,
    int timeoutSeconds = 30,
  }) async {
    return await apiCall().timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () {
        throw TimeoutException('API call timed out');
      },
    );
  }

  /// Make an API call with both retry and timeout
  static Future<T> withRetryAndTimeout<T>({
    required Future<T> Function() apiCall,
    int maxRetries = 3,
    int retryDelay = 2,
    int timeoutSeconds = 30,
    Function(int attempt)? onRetry,
  }) async {
    return await withRetry<T>(
      apiCall: () => withTimeout<T>(
        apiCall: apiCall,
        timeoutSeconds: timeoutSeconds,
      ),
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      onRetry: onRetry,
    );
  }

  /// Handle API errors and return user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Request timed out. Please check your internet connection.';
    } else if (error is Exception) {
      final message = error.toString();
      if (message.contains('SocketException')) {
        return 'No internet connection. Please check your network.';
      } else if (message.contains('401')) {
        return 'Authentication failed. Please check your API key.';
      } else if (message.contains('429')) {
        return 'Rate limit exceeded. Please try again later.';
      } else if (message.contains('500')) {
        return 'Server error. Please try again later.';
      }
      return 'An error occurred: ${error.toString()}';
    }
    return 'An unexpected error occurred.';
  }

  /// Check if an error is retryable
  static bool isRetryableError(dynamic error) {
    if (error is TimeoutException) {
      return true;
    }
    
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
           message.contains('timeout') ||
           message.contains('500') ||
           message.contains('502') ||
           message.contains('503');
  }
}

/// Exception for timeout errors
class TimeoutException implements Exception {
  final String message;
  
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}
