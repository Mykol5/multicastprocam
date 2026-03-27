import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_platform/universal_platform.dart';
import 'providers/multicast_stream_provider.dart';
import 'mobile/screens/streamer_setup_screen.dart';
import 'web/screens/web_viewer_screen.dart';

void main() {
  runApp(MultiCastProApp());
}

class MultiCastProApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MultiCastStreamProvider(),
      child: MaterialApp(
        title: 'MultiCast Pro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: UniversalPlatform.isWeb 
            ? WebViewerScreen()
            : StreamerSetupScreen(),
      ),
    );
  }
}
