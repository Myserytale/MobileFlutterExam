import 'dart:async';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';

class WebSocketService {
  String get url {
    if (Platform.isAndroid) {
      return 'ws://10.0.2.2:2622';
    }
    return 'ws://localhost:2622';
  }
  
  WebSocketChannel? _channel;
  final Logger logger = Logger();
  
  // Use a broadcast stream controller so we control error handling
  final StreamController<dynamic> _streamController = StreamController<dynamic>.broadcast();
  
  Stream<dynamic> get stream => _streamController.stream;
  
  bool _isConnecting = false;
  bool _isConnected = false;

  /// Try to connect. This is safe to call - errors are caught.
  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;
    _isConnecting = true;
    
    try {
      final uri = Uri.parse(url);
      _channel = WebSocketChannel.connect(uri);
      
      // Wait for the connection to be ready (with timeout)
      await _channel!.ready.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timed out');
        },
      );
      
      _isConnected = true;
      logger.i('Connected to WebSocket');
      
      // Forward messages to our controlled stream
      _channel!.stream.listen(
        (data) {
          _streamController.add(data);
        },
        onError: (error) {
          logger.w('WebSocket stream error: $error');
          _isConnected = false;
          // Don't add error to our stream - just log it
        },
        onDone: () {
          logger.i('WebSocket closed');
          _isConnected = false;
        },
      );
    } catch (e) {
      logger.w('WebSocket connection failed: $e');
      _isConnected = false;
      _channel = null;
    } finally {
      _isConnecting = false;
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      _isConnected = false;
    }
  }
  
  void dispose() {
    disconnect();
    _streamController.close();
  }
}
