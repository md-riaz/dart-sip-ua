import 'dart:io';
import 'dart:typed_data';

class SIPUAUdpSocketImpl {
  SIPUAUdpSocketImpl(this.messageDelay, this.host, this.port);
  final int messageDelay;
  final String host;
  final String port;
  RawDatagramSocket? _socket;

  void Function()? onOpen;
  void Function(dynamic data)? onData;
  void Function(int? code, String? reason)? onClose;

  void bind() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    onOpen?.call();
    _socket?.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket?.receive();
        if (datagram != null) {
          onData?.call(datagram.data);
        }
      }
    });
  }

  void send(dynamic data, String targetHost, int targetPort) {
    if (_socket != null) {
      _socket!.send(data is String ? Uint8List.fromList(data.codeUnits) : data,
          InternetAddress(targetHost), targetPort);
    }
  }

  void close() {
    _socket?.close();
    onClose?.call(0, 'closed');
  }
}
