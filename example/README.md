# dart_sip_ua_example

A Flutter example application demonstrating the use of dart-sip-ua library for SIP/VoIP calling.

## Features

This example app demonstrates:
- **SIP Registration**: Connect to a SIP server
- **Audio/Video Calls**: Make and receive voice and video calls
- **Call Controls**: Hold, mute, speaker, DTMF, etc.
- **Blind Transfer**: Transfer a call to another number
- **Attended Transfer**: NEW! Transfer a call to another active call (warm transfer)

## Getting Started

Make sure your flutter is using the `dev` channel.

- `flutter channel dev`
- `./scripts/project_tools.sh create`
- `flutter run`

## For Desktop or Web
- `flutter run -d macos`
- `flutter run -d web|chrome`

## Attended Transfer Feature

The example app now supports attended call transfer (also known as warm transfer or supervised transfer).

### How to Use Attended Transfer:

1. **Start a Call**: Make or receive a call
2. **Put on Hold** (recommended): Tap the "Hold" button to put the first caller on hold
3. **Make Second Call**: Go back to dial pad and call another person
4. **Transfer**: While on the second call, tap "Transfer" button
5. **Choose Transfer Type**: Select "Attended Transfer" from the dialog
6. **Select Call**: Choose which active call to transfer to
7. **Complete**: Both parties will be connected and your calls will end

### Visual Indicators:
- The app bar shows the number of other active calls (e.g., "+1 call")
- A green phone icon appears when multiple calls are active
- The transfer button is always available but options change based on active calls

### Code Example:

```dart
import 'package:sip_ua/sip_ua.dart';
import 'attended_transfer.dart';

// Transfer call1 to call2
call1.attendedTransfer(call2);
```

For more details, see [attended_transfer_example.md](lib/src/attended_transfer_example.md)

## Technical Details

The attended transfer feature uses:
- SIP REFER method with Replaces header (RFC 3515, RFC 3891, RFC 5589)
- Automatic call hold management
- Session tag extraction for proper call correlation

## Requirements

- dart-sip-ua 1.0.0+
- SIP server with REFER/Replaces support
- Account that allows multiple simultaneous calls
