import 'dart:async';

import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';

const noConnectionWidgetKey = Key('no-connection-overlay');

/// A widget that shows a full-screen overlay when there's no internet connection.
/// This widget listens to the connectivity stream and displays a "Not Connected"
/// message with a large icon when the device is offline.
class ConnectivityOverlay extends StatefulWidget {
  const ConnectivityOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityOverlay> createState() => _ConnectivityOverlayState();
}

class _ConnectivityOverlayState extends State<ConnectivityOverlay> {
  late StreamSubscription<bool> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _isConnected = ConnectivityService.instance.hasConnection;
    _connectivitySubscription = ConnectivityService.instance.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [widget.child, if (!_isConnected) _buildNoConnectionOverlay(context)],
      ),
    );
  }

  Widget _buildNoConnectionOverlay(BuildContext context) {
    return Material(
      key: noConnectionWidgetKey,
      color: Colors.black.withValues(alpha: 0.8),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 120, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(height: 24),
              Text(
                'No Internet Connection',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Please check your internet connection and try again',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reconnecting...',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
