import 'package:sip_ua/sip_ua.dart';

/// Helper class to hold replaces information for attended transfer
class ReplacesInfo {
  ReplacesInfo({
    required this.callId,
    required this.fromTag,
    required this.toTag,
  });

  final String callId;
  final String fromTag;
  final String toTag;
}

/// Extension on Call to support attended transfer
extension AttendedTransferExtension on Call {
  /// Performs an attended transfer from this call to another active call.
  /// 
  /// This transfers the current call to [targetCall], connecting the parties
  /// on both calls together while removing the local user from the conversation.
  /// 
  /// Example usage:
  /// ```dart
  /// // User is on call with personA (call1) and personB (call2)
  /// // To connect personA and personB together:
  /// call1.attendedTransfer(call2);
  /// ```
  /// 
  /// The current call should typically be on hold before initiating the transfer.
  /// Both calls will be terminated after the transfer is accepted.
  void attendedTransfer(Call targetCall) {
    // Put this call on hold before transferring
    final holdStatus = session.isOnHold();
    if (holdStatus['local'] == false) {
      hold();
    }

    // Extract call details from the target call
    String? fromTag = targetCall.session.from_tag;
    String? toTag = targetCall.session.to_tag;
    String? sessionId = targetCall.session.id;

    if (fromTag == null || toTag == null || sessionId == null) {
      throw Exception('Cannot perform attended transfer: missing session information');
    }

    // The session ID has the from_tag appended to it, so we need to remove it
    String callId = sessionId;
    if (callId.endsWith(fromTag)) {
      callId = callId.substring(0, callId.length - fromTag.length);
    }

    // Create the replaces info
    final replacesInfo = ReplacesInfo(
      callId: callId,
      fromTag: fromTag,
      toTag: toTag,
    );

    // Perform the REFER with replaces header
    refer(targetCall.remote_identity!, {
      'replaces': replacesInfo,
    });
  }
}
