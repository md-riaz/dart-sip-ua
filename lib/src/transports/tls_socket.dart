import 'dart:async';
import 'dart:io';

import 'package:sip_ua/src/logger.dart';

import 'socket_interface.dart';

class SIPUATlsSocket implements SIPUASocketInterface {
  @override
  void Function()? get onconnect => _onconnect;
  @override
  set onconnect(void Function()? callback) {
    _onconnect = callback;
  }

  @override
  void Function(SIPUASocketInterface, bool, int?, String?)? get ondisconnect =>
      _ondisconnect;
  @override
  set ondisconnect(
      void Function(SIPUASocketInterface, bool, int?, String?)? callback) {
    _ondisconnect = callback;
  }

  void Function()? _onconnect;
  void Function(SIPUASocketInterface, bool, int?, String?)? _ondisconnect;
  @override
  String get url => 'tls://$_host:$_port';

  @override
  String get via_transport => 'TLS';
  @override
  set via_transport(String value) {
    _via_transport = value.toUpperCase();
  }

  @override
  int get weight => 0;

  @override
  void Function()? onconnectCallback;

  @override
  void Function(SIPUASocketInterface, bool, int?, String?)?
      ondisconnectCallback;

  @override
  void Function(dynamic)? ondata;
  @override
  String get sip_uri => 'sip:$_host:$_port';

  final _onconnectController = StreamController<void>();

  final _ondisconnectController = StreamController<void>();

  Stream<dynamic> get onDataStream => _ondataController.stream;
  final _ondataController = StreamController<dynamic>();
  SIPUATlsSocket(this._host, this._port, {this.messageDelay = 0});

  final String _host;
  final String _port;
  final int messageDelay;
  SecureSocket? _socket;
  String _via_transport = 'TLS';
  bool _connected = false;
  bool _connecting = false;
  StreamController<dynamic>? _messageController;

  @override
  void connect() async {
    logger.d('TLS connecting $_host:$_port');
    if (_connected) {
      logger.w('Already connected');
      return;
    }

    if (_connecting) {
      logger.w('Already connecting');
      return;
    }
    _connecting = true;

    try {
      _socket = await SecureSocket.connect(_host, int.parse(_port),
          onBadCertificate: (X509Certificate cert) => true);
      _messageController = StreamController<dynamic>();
      _connected = true;
      _connecting = false;

      _socket!.listen((List<int> data) {
        String message = String.fromCharCodes(data);
        if (message.trim().isNotEmpty) {
          if (messageDelay > 0) {
            Future<void>.delayed(Duration(milliseconds: messageDelay),
                () => _messageController?.add(message));
          } else {
            _messageController?.add(message);
          }
        }
      }, onDone: () {
        logger.d('TLS connection closed');
        close();
      }, onError: (dynamic error) {
        logger.e('TLS connection error: $error');
        close();
      });
    } catch (e) {
      logger.e('TLS connection failed: $e');
      _connecting = false;
      close();
    }
  }

  @override
  void disconnect() {
    close();
  }

  @override
  bool isConnected() {
    return _connected;
  }

  @override
  bool isConnecting() {
    return _connecting;
  }

  @override
  Stream<dynamic>? get onMessage => _messageController?.stream;

  @override
  bool send(dynamic data) {
    if (_socket != null && _connected) {
      _socket!.write(data);
      return true;
    }
    return false;
  }

  void close() {
    _connected = false;
    _connecting = false;
    _socket?.destroy();
    _socket = null;
    _messageController?.close();
    _messageController = null;
  }
}
