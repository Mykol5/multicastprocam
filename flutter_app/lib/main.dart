import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:permission_handler/permission_handler.dart';
import 'providers/multicast_stream_provider.dart';
import 'mobile/screens/streamer_setup_screen.dart';
import 'web/screens/web_viewer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request permissions on mobile
  if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
    await _requestPermissions();
  }
  
  runApp(MultiCastProApp());
}

Future<void> _requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ].request();
  
  print('Camera: ${statuses[Permission.camera]}');
  print('Microphone: ${statuses[Permission.microphone]}');
  print('Storage: ${statuses[Permission.storage]}');
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
        home: _getHomeScreen(),
      ),
    );
  }
  
  Widget _getHomeScreen() {
    // Web and Desktop act as viewers
    if (UniversalPlatform.isWeb || 
        UniversalPlatform.isWindows || 
        UniversalPlatform.isMacOS || 
        UniversalPlatform.isLinux) {
      return WebViewerScreen();
    }
    // Mobile acts as streamer
    return StreamerSetupScreen();
  }
}







// // main dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:universal_platform/universal_platform.dart';
// import 'providers/multicast_stream_provider.dart';
// import 'mobile/screens/streamer_setup_screen.dart';
// import 'web/screens/web_viewer_screen.dart';

// // Desktop will use the viewer mode (like web)
// void main() {
//   runApp(MultiCastProApp());
// }

// class MultiCastProApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => MultiCastStreamProvider(),
//       child: MaterialApp(
//         title: 'MultiCast Pro',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           useMaterial3: true,
//         ),
//         home: _getHomeScreen(),
//       ),
//     );
//   }
  
//   Widget _getHomeScreen() {
//     // Web and Desktop (Windows/macOS/Linux) act as viewers
//     if (UniversalPlatform.isWeb || 
//         UniversalPlatform.isWindows || 
//         UniversalPlatform.isMacOS || 
//         UniversalPlatform.isLinux) {
//       return WebViewerScreen();
//     }
//     // Mobile acts as streamer
//     return StreamerSetupScreen();
//   }
// }
