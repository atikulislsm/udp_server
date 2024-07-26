import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UDPServerScreen(),
    );
  }
}

class UDPServerScreen extends StatefulWidget {
  @override
  _UDPServerScreenState createState() => _UDPServerScreenState();
}

class _UDPServerScreenState extends State<UDPServerScreen> {
  RawDatagramSocket? _socket;
  String _message = 'No messages received yet.';
  final TextEditingController _ipController = TextEditingController(text: '0.0.0.0');
  final TextEditingController _portController = TextEditingController(text: '12345');

  void _startUDPServer() async {
    final String ip = _ipController.text;
    final int port = int.tryParse(_portController.text) ?? 12345;

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress(ip), port);
      _socket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = _socket?.receive();
          if (datagram != null) {
            String message = String.fromCharCodes(datagram.data);
            setState(() {
              _message = 'Received: $message';
            });
          }
        }
      });

      setState(() {
        _message = 'UDP server listening on $ip:$port';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to start UDP server: $e';
      });
    }
  }

  void _stopUDPServer() {
    _socket?.close();
    _socket = null;
    setState(() {
      _message = 'UDP server stopped.';
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UDP Server Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'IP Address',
                hintText: 'Enter IP address',
              ),
            ),
            TextField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: 'Port',
                hintText: 'Enter port number',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startUDPServer,
              child: Text('Start UDP Server'),
            ),
            ElevatedButton(
              onPressed: _stopUDPServer,
              child: Text('Stop UDP Server'),
            ),
            SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
