import 'package:sip_ua/sip_ua.dart';

/// Helper class to manage multiple active calls
/// 
/// This class helps track and manage multiple simultaneous calls
/// which is needed for attended transfer functionality.
class CallManager {
  final List<Call> _activeCalls = [];

  /// Add a call to the active calls list
  void addCall(Call call) {
    if (!_activeCalls.any((c) => c.session.id == call.session.id)) {
      _activeCalls.add(call);
    }
  }

  /// Remove a call from the active calls list
  void removeCall(Call call) {
    _activeCalls.removeWhere((c) => c.session.id == call.session.id);
  }

  /// Get all active calls
  List<Call> get activeCalls => List.unmodifiable(_activeCalls);

  /// Get active calls excluding a specific call
  List<Call> getOtherActiveCalls(Call excludeCall) {
    return _activeCalls
        .where((c) => c.session.id != excludeCall.session.id)
        .toList();
  }

  /// Get the number of active calls
  int get activeCallCount => _activeCalls.length;

  /// Clear all calls
  void clear() {
    _activeCalls.clear();
  }
}
