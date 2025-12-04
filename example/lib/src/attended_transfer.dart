import 'package:flutter/foundation.dart';
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
    String? remoteIdentity = targetCall.remote_identity;

    if (fromTag == null || toTag == null || sessionId == null || remoteIdentity == null) {
      throw Exception('Cannot perform attended transfer: missing session information');
    }

    // The session ID has the from_tag appended to it, so we need to remove it
    // Only remove if the sessionId actually ends with the exact fromTag
    String callId = sessionId;
    if (fromTag.isNotEmpty && callId.endsWith(fromTag)) {
      callId = callId.substring(0, callId.length - fromTag.length);
    }

    // Create the replaces info
    final replacesInfo = ReplacesInfo(
      callId: callId,
      fromTag: fromTag,
      toTag: toTag,
    );

    // Perform the REFER with replaces header
    // Note: We call session.refer directly as it already supports options parameter
    final referSubscriber = session.refer(remoteIdentity, {
      'replaces': replacesInfo,
    });
    
    if (referSubscriber != null) {
      // Set up event handlers for the refer
      referSubscriber.on(EventReferTrying(), (EventReferTrying data) {
        // REFER request is being sent
        debugPrint('Attended transfer: REFER request trying');
      });
      referSubscriber.on(EventReferProgress(), (EventReferProgress data) {
        // REFER request is in progress
        debugPrint('Attended transfer: REFER request in progress');
      });
      referSubscriber.on(EventReferAccepted(), (EventReferAccepted data) {
        // REFER was accepted, terminate the session
        debugPrint('Attended transfer: REFER accepted, terminating session');
        session.terminate();
      });
      referSubscriber.on(EventReferFailed(), (EventReferFailed data) {
        // REFER failed
        debugPrint('Attended transfer: REFER failed - ${data.cause}');
      });
    }
  }
}
