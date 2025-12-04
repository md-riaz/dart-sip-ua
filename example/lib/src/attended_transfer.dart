import 'package:flutter/foundation.dart';
import 'package:sip_ua/sip_ua.dart';

/// Helper class to hold replaces information for attended transfer
/// 
/// Field names use snake_case to match the expected format in
/// lib/src/rtc_session/refer_subscriber.dart which accesses:
/// - options['replaces'].call_id
/// - options['replaces'].to_tag
/// - options['replaces'].from_tag
class ReplacesInfo {
  ReplacesInfo({
    required this.call_id,
    required this.from_tag,
    required this.to_tag,
  });

  final String call_id;
  final String from_tag;
  final String to_tag;
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

    // Extract the call ID from the session ID
    // Session ID format in dart-sip-ua: call-id + from_tag
    // Example: "abc123def456" + "tag-789" = "abc123def456tag-789"
    // 
    // For the SIP REFER Replaces header, we need just the call-id part.
    // This is defined in RTCSession (rtc_session.dart:344):
    //   _id = _request.call_id + _from_tag;
    //
    // We safely extract the call-id by removing the from_tag suffix
    String callId = sessionId;
    if (fromTag.isNotEmpty && callId.endsWith(fromTag)) {
      // Verify we're not removing the entire callId (sanity check)
      if (callId.length > fromTag.length) {
        callId = callId.substring(0, callId.length - fromTag.length);
      } else {
        // This should never happen with proper session setup
        debugPrint('Warning: Session ID format unexpected (ID: $sessionId, fromTag: $fromTag), using as-is');
      }
    }

    // Create the replaces info with snake_case field names
    // to match what refer_subscriber.dart expects
    final replacesInfo = ReplacesInfo(
      call_id: callId,
      from_tag: fromTag,
      to_tag: toTag,
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
