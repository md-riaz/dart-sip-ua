/// Attended Transfer Demo
/// 
/// This file demonstrates how to use the attended transfer feature
/// in a dart-sip-ua application.

import 'package:sip_ua/sip_ua.dart';
import 'attended_transfer.dart';
import 'call_manager.dart';

/// Example of how to perform an attended transfer
/// 
/// Scenario: You (User A) are on a call with User B.
/// You want to transfer User B to User C.
/// 
/// Steps:
/// 1. You are on call with User B (call1)
/// 2. Put call1 on hold
/// 3. Call User C (call2)
/// 4. Talk to User C to announce the transfer
/// 5. Transfer call1 to call2
/// 6. User B and User C are now connected, your calls end
void demonstrateAttendedTransfer() {
  // This is pseudocode to show the flow
  
  // Assuming you have a SIPUAHelper instance
  // SIPUAHelper helper = SIPUAHelper();
  
  // And a CallManager to track calls
  CallManager callManager = CallManager();
  
  // Step 1: Receive or make a call with User B
  // Call call1 = ...; // This comes from SIPUAHelper
  // callManager.addCall(call1);
  
  // Step 2: Put User B on hold
  // call1.hold();
  
  // Step 3: Call User C
  // helper.call('sip:userC@example.com', voiceOnly: true);
  // Call call2 = ...; // This comes from the newRTCSession event
  // callManager.addCall(call2);
  
  // Step 4: Talk to User C (both calls are now active)
  // ... user conversation ...
  
  // Step 5: Perform attended transfer
  // This connects User B to User C
  // call1.attendedTransfer(call2);
  
  // Step 6: Both calls will automatically end when transfer is accepted
}

/// Example of checking if attended transfer is possible
bool canPerformAttendedTransfer(CallManager callManager, Call currentCall) {
  // You need at least 2 active calls to perform attended transfer
  final otherCalls = callManager.getOtherActiveCalls(currentCall);
  return otherCalls.isNotEmpty;
}

/// Example of getting available transfer targets
List<Call> getAvailableTransferTargets(CallManager callManager, Call currentCall) {
  // Get all other active calls that can be transfer targets
  return callManager.getOtherActiveCalls(currentCall);
}

/// Example error handling
void performAttendedTransferWithErrorHandling(Call call1, Call call2) {
  try {
    // Attempt the transfer
    call1.attendedTransfer(call2);
    
    print('Attended transfer initiated successfully');
  } catch (e) {
    // Handle errors
    if (e.toString().contains('missing session information')) {
      print('Error: One of the calls is not fully established');
    } else {
      print('Error performing attended transfer: $e');
    }
  }
}

/// Complete usage example with event handling
class AttendedTransferExample {
  final SIPUAHelper helper;
  final CallManager callManager;
  
  AttendedTransferExample({
    required this.helper,
    required this.callManager,
  });
  
  /// Step 1: Start first call
  Future<void> startFirstCall(String target) async {
    await helper.call(target, voiceOnly: true);
    // The call will be added to CallManager in the CallScreen widget
  }
  
  /// Step 2: Handle incoming call or make second call
  void handleSecondCall(Call call) {
    // This is typically handled in the CallScreen widget
    callManager.addCall(call);
  }
  
  /// Step 3: Perform the transfer
  void performTransfer(Call fromCall, Call toCall) {
    // Put the fromCall on hold if not already
    final holdStatus = fromCall.session.isOnHold();
    if (holdStatus['local'] == false) {
      fromCall.hold();
    }
    
    // Perform the attended transfer
    try {
      fromCall.attendedTransfer(toCall);
    } catch (e) {
      print('Transfer failed: $e');
    }
  }
  
  /// Step 4: Clean up after transfer
  void cleanupAfterTransfer(Call call1, Call call2) {
    // Remove both calls from the manager after they end
    callManager.removeCall(call1);
    callManager.removeCall(call2);
  }
}

/// Technical details about attended transfer
/// 
/// The attended transfer uses the SIP REFER method with a Replaces header.
/// 
/// According to RFC 3891 and RFC 5589:
/// 1. The REFER message contains a Replaces header in the Refer-To URI
/// 2. The Replaces header includes:
///    - Call-ID of the call to be replaced
///    - to-tag from the target session
///    - from-tag from the target session
/// 3. When the transfer target receives the REFER, it sends an INVITE
///    with the Replaces header to the third party
/// 4. The third party replaces the existing call with the new one
/// 5. All parties receive BYE messages to end the original calls
/// 
/// Example SIP REFER message structure:
/// ```
/// REFER sip:userC@example.com SIP/2.0
/// Refer-To: <sip:userB@example.com?Replaces=call-id%3Bto-tag%3Dtag1%3Bfrom-tag%3Dtag2>
/// ```
