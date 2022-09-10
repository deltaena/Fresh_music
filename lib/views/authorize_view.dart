import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthorizeView extends StatelessWidget{
  const AuthorizeView({super.key});

  @override
  Widget build(BuildContext context) {
    return getWebView(context);
  }

  WebView getWebView(BuildContext context){
    return WebView(
      initialUrl: "",
      javascriptMode: JavascriptMode.unrestricted,
      navigationDelegate: (navReq) {
        if (navReq.url.startsWith('https://open.spotify.com/')) {

          Navigator.of(context).pop();
          return NavigationDecision.prevent;
        }

        return NavigationDecision.navigate;
      },
    );
  }
}