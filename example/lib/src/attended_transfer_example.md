# Attended Transfer Feature

This document explains how to use the attended call transfer feature in the dart-sip-ua example app.

## What is Attended Transfer?

Attended transfer (also called warm transfer or supervised transfer) allows you to:
1. Put the current caller on hold
2. Call another person to announce the transfer
3. Transfer the original caller to the new person
4. Both parties are connected while you leave the conversation

This is different from blind transfer where you transfer a call directly to another number without speaking to them first.

## How to Use

### Step 1: Start a Call
Make or receive a call as usual using the dial pad.

### Step 2: Put the Call on Hold (Optional but Recommended)
While on the first call, tap the "Hold" button to put the caller on hold.

### Step 3: Make a Second Call
While the first call is on hold, go back to the dial pad and make a second call to the person you want to transfer the first caller to.

### Step 4: Initiate Attended Transfer
1. While on the second call, tap the "Transfer" button
2. You'll see a dialog with transfer options:
   - **Attended Transfer**: Transfer to one of your active calls
   - **Blind Transfer**: Transfer to a new number without calling them first
3. Choose "Attended Transfer"
4. Select the call you want to transfer to from the list of active calls
5. The transfer will be initiated

### Step 5: Completion
Once the transfer is accepted:
- Both of your calls will end
- The two parties will be connected to each other
- You are removed from the conversation

## Code Example

If you're implementing this in your own app, here's how to use the attended transfer feature programmatically:

```dart
import 'package:sip_ua/sip_ua.dart';
import 'attended_transfer.dart';

// Assuming you have two active calls:
// call1: Current call with Person A
// call2: Call with Person B

// Transfer Person A to Person B:
call1.attendedTransfer(call2);

// This will:
// 1. Put call1 on hold (if not already on hold)
// 2. Send a REFER request with Replaces header to connect the calls
// 3. Both calls will terminate after the transfer is accepted
```

## Technical Details

The attended transfer feature uses the SIP REFER method with the Replaces header as defined in RFC 5589. The implementation:

1. Extracts the `call_id`, `from_tag`, and `to_tag` from the target call's session
2. Constructs a Replaces header with these values
3. Sends a REFER request to transfer the call
4. Both calls are terminated once the transfer is accepted

## Troubleshooting

### "Cannot perform attended transfer: missing session information"
This error occurs when the target call doesn't have complete session information. Make sure:
- Both calls are in the CONFIRMED state
- Both calls have established SIP sessions

### Transfer button not showing attended transfer option
This happens when there are no other active calls. You need at least two active calls to perform an attended transfer.

### Transfer fails with 403 or 501 error
Your SIP server may not support the REFER method or attended transfers. Check with your SIP service provider.

## Requirements

- dart-sip-ua version 1.0.0 or higher
- SIP server that supports REFER method with Replaces header
- Multiple simultaneous calls must be supported by your SIP account

## Related RFCs

- RFC 3515: The Session Initiation Protocol (SIP) Refer Method
- RFC 3891: The Session Initiation Protocol (SIP) "Replaces" Header
- RFC 5589: Session Initiation Protocol (SIP) Call Control - Transfer
