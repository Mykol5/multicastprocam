// adjusted

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stream_provider.dart';
import 'streaming_screen.dart';

class StreamerSetupScreen extends StatefulWidget {
  @override
  _StreamerSetupScreenState createState() => _StreamerSetupScreenState();
}

class _StreamerSetupScreenState extends State<StreamerSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomIdController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MultiCast Pro'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cast_connected, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                'Start Streaming',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: _roomIdController,
                decoration: InputDecoration(
                  labelText: 'Room ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a room ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _startStreaming,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Start Broadcasting', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startStreaming() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<StreamProvider>(context, listen: false);
      
      await provider.initializeAsStreamer(
        _roomIdController.text,
        _nameController.text,
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StreamingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
