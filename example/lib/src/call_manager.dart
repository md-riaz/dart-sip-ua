import 'package:sip_ua/sip_ua.dart';

/// Helper class to manage multiple active calls
/// 
/// This class helps track and manage multiple simultaneous calls
/// which is needed for attended transfer functionality.
class CallManager {
  final List<Call> _activeCalls = [];

  /// Add a call to the active calls list
  void addCall(Call call) {
    final sessionId = call.session.id;
    if (sessionId == null) {
      print('Warning: Attempting to add call with null session ID');
      return;
    }
    if (!_activeCalls.any((c) => c.session.id == sessionId)) {
      _activeCalls.add(call);
    }
  }

  /// Remove a call from the active calls list
  void removeCall(Call call) {
    final sessionId = call.session.id;
    if (sessionId == null) {
      print('Warning: Attempting to remove call with null session ID');
      return;
    }
    _activeCalls.removeWhere((c) => c.session.id == sessionId);
  }

  /// Get all active calls
  List<Call> get activeCalls => List.unmodifiable(_activeCalls);

  /// Get active calls excluding a specific call
  List<Call> getOtherActiveCalls(Call excludeCall) {
    final excludeSessionId = excludeCall.session.id;
    if (excludeSessionId == null) {
      return _activeCalls.toList();
    }
    return _activeCalls
        .where((c) => c.session.id != excludeSessionId)
        .toList();
  }

  /// Get the number of active calls
  int get activeCallCount => _activeCalls.length;

  /// Clear all calls
  void clear() {
    _activeCalls.clear();
  }
}
