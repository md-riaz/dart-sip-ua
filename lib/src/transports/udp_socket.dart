import 'socket_interface.dart';
import 'udp_socker_impl.dart';
import '../logger.dart';

class SIPUAUdpSocket extends SIPUASocketInterface {
  SIPUAUdpSocket(String host, String port, {required int messageDelay}) {
    _host = host;
    _port = port;
    _messageDelay = messageDelay;
    _sip_uri = 'sip:$host:$port;transport=UDP';
    _via_transport = 'UDP';
  }

  late final int _messageDelay;
  String? _host;
  String? _port;
  String? _sip_uri;
  late String _via_transport;
  bool _closed = false;

  SIPUAUdpSocketImpl? _udpSocketImpl;

  @override
  void connect() {
    _udpSocketImpl = SIPUAUdpSocketImpl(_messageDelay, _host!, _port!);
    _udpSocketImpl!.onOpen = () => _onOpen();
    _udpSocketImpl!.onData = (data) => _onMessage(data);
    _udpSocketImpl!.onClose = (code, reason) => _onClose(true, code, reason);
    _udpSocketImpl!.bind();
  }

  @override
  void disconnect() {
    _udpSocketImpl?.close();
    _closed = true;
    _onClose(true, 0, 'UDP socket closed');
  }

  @override
  bool send(dynamic message) {
    if (_closed) throw 'transport closed';
    _udpSocketImpl?.send(message, _host!, int.parse(_port!));
    return true;
  }

  @override
  String? get sip_uri => _sip_uri;

  @override
  String get via_transport => _via_transport;

  @override
  set via_transport(String value) {
    _via_transport = value.toUpperCase();
  }

  @override
  String? get url => '$_host:$_port';

  @override
  bool isConnected() => !_closed;

  @override
  bool isConnecting() => false;

  @override
  int? get weight => null;

  void _onOpen() => onconnect?.call();
  void _onClose(bool wasClean, int? code, String? reason) =>
      ondisconnect?.call(this, !wasClean, code, reason);
  void _onMessage(dynamic data) => ondata?.call(data);
}
