import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../providers/multicast_stream_provider.dart';

class WebViewerScreen extends StatefulWidget {
  @override
  _WebViewerScreenState createState() => _WebViewerScreenState();
}

class _WebViewerScreenState extends State<WebViewerScreen> {
  final TextEditingController _roomIdController = TextEditingController();
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MultiCastStreamProvider>(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.purple.shade900],
          ),
        ),
        child: !_isConnected
            ? _buildConnectionScreen(provider)
            : _buildViewerScreen(provider),
      ),
    );
  }
  
  Widget _buildConnectionScreen(MultiCastStreamProvider provider) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(40),
        margin: EdgeInsets.all(20),
        constraints: BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tv, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'MultiCast Pro Viewer',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _roomIdController,
              decoration: InputDecoration(
                labelText: 'Room ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: Icon(Icons.meeting_room),
              ),
              onSubmitted: (_) => _connectToRoom(provider),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _connectToRoom(provider),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.blue,
              ),
              child: Text('Join Room', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildViewerScreen(MultiCastStreamProvider provider) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          color: Colors.black.withOpacity(0.3),
          child: Row(
            children: [
              Icon(Icons.tv, color: Colors.white),
              SizedBox(width: 10),
              Text('MultiCast Pro', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                child: Text('LIVE', style: TextStyle(color: Colors.white)),
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  setState(() => _isConnected = false);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                  child: provider.remoteStream != null
                      ? RTCVideoView(
                          provider.remoteStream!,
                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                        )
                      : Center(child: Text('Waiting for stream...', style: TextStyle(color: Colors.white))),
                ),
              ),
              Container(
                width: 280,
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.people, color: Colors.blue.shade700),
                          SizedBox(width: 10),
                          Text('Streamers', style: TextStyle(fontWeight: FontWeight.bold)),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(20)),
                            child: Text('${provider.streamers.length}', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: provider.streamers.length,
                        itemBuilder: (context, index) {
                          final streamer = provider.streamers[index];
                          final isActive = provider.activeStreamerId == streamer['streamerId'];
                          return GestureDetector(
                            onTap: () => provider.switchStreamer(streamer['streamerId']),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.blue.shade50 : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isActive ? Colors.blue : Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                        streamer['streamerName'][0].toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(child: Text(streamer['streamerName'])),
                                  if (isActive) Icon(Icons.play_circle, color: Colors.blue),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _connectToRoom(MultiCastStreamProvider provider) async {
    if (_roomIdController.text.isNotEmpty) {
      await provider.initializeAsViewer(_roomIdController.text);
      setState(() => _isConnected = true);
    }
  }
}
