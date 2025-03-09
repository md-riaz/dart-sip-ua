import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dart_sip_ua_example/src/user_state/sip_user.dart';
import 'package:sip_ua/sip_ua.dart';

class SipUserCubit extends Cubit<SipUser?> {
  final SIPUAHelper sipHelper;
  SipUserCubit({required this.sipHelper}) : super(null);

  void register(SipUser user) {
    UaSettings settings = UaSettings();
    settings.port = user.port;
    settings.webSocketSettings.extraHeaders = user.wsExtraHeaders ?? {};
    settings.webSocketSettings.allowBadCertificate = true;
    //settings.webSocketSettings.userAgent = 'Dart/2.8 (dart:io) for OpenSIPS.';
    settings.tcpSocketSettings.allowBadCertificate = true;
    settings.transportType = user.selectedTransport;
    settings.uri = user.sipUri;
    settings.webSocketUrl = user.wsUrl;
    settings.host = user.sipUri?.split('@')[1];
    settings.authorizationUser = user.authUser;
    settings.password = user.password;
    settings.displayName = user.displayName;
    settings.userAgent = 'Dart SIP Client v1.0.0';
    settings.dtmfMode = DtmfMode.RFC2833;
    settings.contact_uri = 'sip:${user.sipUri}';

    // BlocProvider.of<SipBloc>(context).add(SipInitialClientRegister());
    if (Platform.isAndroid) {
      settings.registerParams.extraContactUriParams = <String, String>{
        'pn-provider': 'fcm',
        'pn_type': 'android',
        'pn-param': 'voiceland-dev',
        'pn-prid': 'firebase',
        'pn_device':
            'clvR90vdQGW7dxCaKH150b:APA91bG3dbR8uUZyZF7nrVypJfWHikQ4Pq75pXKOmGl7SpoS-RRY5wajj_0kaqD7QJJ5q9NYkKOb4mCHIUHAa-7PoC8ldFT7nlwUHi2pY07Xja_Rnss79UBKu97cllG20Wxiax4GCXBj'
      };
    }

    emit(user);
    sipHelper.start(settings);
  }
}
