import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tk2me_flutter/providers/connection_provider.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectionProvider>(
      builder: (context, connectionProvider, _) {
        return Tooltip(
          message: connectionProvider.isConnected 
              ? 'Connected to server' 
              : 'Not connected to server',
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: connectionProvider.isConnected 
                  ? Colors.green 
                  : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: connectionProvider.isConnected 
                      ? Colors.green.withOpacity(0.5) 
                      : Colors.red.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
