import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:monitoring_kimia/app/data/response.model.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Monitoring (REALTIME)'),
        centerTitle: false,
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  controller.isConnected.value
                      ? Icons.wifi_tethering_rounded
                      : Icons.wifi_tethering_off_rounded,
                  color: controller.isConnected.value
                      ? Colors.greenAccent.shade700
                      : Colors.redAccent.shade400,
                ),
              )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!controller.isConnected.value) {
            controller.reconnectSocket();
          }
          print('Pull to refresh triggered.');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            final headerCard = _buildHeaderCard();
            final connectionCard = _buildConnectionStatusCard();
            final controllerCard = _buildControllerCard();
            final data = controller.eventData;

            if (data.isEmpty) {
              // Belum ada data
              return _buildScrollWrapper(
                context,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    connectionCard,
                    const SizedBox(height: 20),
                    controller.isConnected.value
                        ? const Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Terhubung. Menunggu data dari server...',
                                  textAlign: TextAlign.center),
                            ],
                          )
                        : Column(
                            children: [
                              const Text(
                                'Koneksi ke server terputus atau gagal.',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 16, color: Colors.red),
                              ),
                              const SizedBox(height: 20),
                              _buildReconnectButton(),
                            ],
                          ),
                  ],
                ),
              );
            } else if (data.isEmpty) {
              return _buildScrollWrapper(
                context,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    headerCard,
                    Expanded(
                      child: Column(
                        children: [
                          connectionCard,
                          const SizedBox(height: 24),
                          const Text(
                            'Belum ada data sensor.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (data.length < 4) {
              return _buildScrollWrapper(
                context,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    headerCard,
                    Expanded(
                      child: Column(
                        children: [
                          connectionCard,
                          const SizedBox(height: 24),
                          const Text(
                            'Data sensor belum lengkap.',
                            style:
                                TextStyle(fontSize: 16, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  headerCard,
                  Column(
                    children: [
                      connectionCard,
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: AnimatedStatusCard(
                                  label: 'Suhu Air (°C)', data: data[0])),
                          const SizedBox(width: 8),
                          Expanded(
                              child: AnimatedStatusCard(
                                  label: 'pH Air (ppm)', data: data[1])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: AnimatedStatusCard(
                                  label: 'Kekeruhan Air (ntu)', data: data[2])),
                          const SizedBox(width: 8),
                          Expanded(
                              child: AnimatedStatusCard(
                                  label: 'Amonia (mg/L)', data: data[3])),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                  controllerCard,
                  if (!controller.isConnected.value) _buildReconnectButton(),
                ],
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildScrollWrapper(BuildContext context, Widget child) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      );
    });
  }

  Widget _buildHeaderCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Selamat Datang",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Text(
          "REALTIME MONITORING",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Smart Devices Monitoring",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildControllerCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CONTROLLER DEVICE",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        Row(
          children: [
            Text(
              "Control your Device",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.settings_remote_rounded), // Contoh ikon
          label: const Text('Kirim Status Akuarium (0,0)'),
          onPressed: () {
            controller.sendTombolAkuariumState();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatusCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          color: controller.isConnected.value
              ? Colors.green.shade50
              : Colors.red.shade50,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  controller.isConnected.value
                      ? Icons.check_circle_outline_rounded
                      : Icons.highlight_off_rounded,
                  color: controller.isConnected.value
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  size: 20, // lebih kecil dari sebelumnya (28)
                ),
                const SizedBox(
                    width: 8), // jarak antar icon dan teks dikecilkan
                Text(
                  controller.isConnected.value ? 'TERHUBUNG' : 'TERPUTUS',
                  style: TextStyle(
                    fontSize: 13, // sebelumnya 16
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: controller.isConnected.value
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReconnectButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Hubungkan Ulang'),
      onPressed: controller.reconnectSocket,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class AnimatedStatusCard extends StatefulWidget {
  final String label;
  final SensorData data;

  const AnimatedStatusCard(
      {super.key, required this.label, required this.data});

  @override
  State<AnimatedStatusCard> createState() => _AnimatedStatusCardState();
}

class _AnimatedStatusCardState extends State<AnimatedStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    bool isDanger = widget.data.kondisi.toString() == '1';

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _colorAnimation = ColorTween(
      begin: isDanger ? Colors.red.shade50 : Colors.green.shade50,
      end: isDanger ? Colors.red.shade100 : Colors.green.shade100,
    ).animate(_controller);

    if (isDanger) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(dynamic value) {
    if (value == null) return 'N/A';

    final doubleVal = double.tryParse(value.toString());
    if (doubleVal == null) return value.toString();

    if (doubleVal == doubleVal.roundToDouble()) {
      return doubleVal.toStringAsFixed(0);
    }

    final str = doubleVal.toStringAsFixed(2);
    if (str.endsWith('0')) {
      return doubleVal.toStringAsFixed(1);
    }

    return str;
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (widget.label.toLowerCase()) {
      case 'suhu air (°c)':
        iconData = Icons.water;
        break;
      case 'ph air (ppm)':
        iconData = Icons.science;
        break;
      case 'kekeruhan air (ntu)':
        iconData = Icons.blur_on;
        break;
      case 'amonia (mg/l)':
        iconData = Icons.bubble_chart;
        break;
      default:
        iconData = Icons.device_thermostat;
    }

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 100,
          child: Card(
            color: _colorAnimation.value,
            elevation: 2,
            margin: const EdgeInsets.all(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    size: 36,
                    color: widget.data.kondisi.toString() == '1'
                        ? Colors.red.shade700
                        : Colors.green.shade800,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(_formatNumber(widget.data.nilai),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.data.kondisi.toString() == '1'
                                  ? Colors.red.shade700
                                  : Colors.green.shade800,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
