import 'package:flutter/foundation.dart';
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
          if (kDebugMode) {
            print('Pull to refresh triggered.');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            final headerCard = _buildHeaderCard();
            final connectionCard = _buildConnectionStatusCard();
            final controllerCard = _buildControllerCard();
            final data = controller.eventData;

            if (data.isEmpty && !controller.isConnected.value) {
              return _buildScrollWrapper(
                context,
                Column(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    headerCard,
                    connectionCard,
                    const Text(
                      'Koneksi ke server terputus atau gagal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    _buildReconnectButton(),
                    controllerCard,
                  ],
                ),
              );
            } else if (data.isEmpty && controller.isConnected.value) {
              return _buildScrollWrapper(
                context,
                Column(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    headerCard,
                    const SizedBox(height: 20),
                    connectionCard,
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Terhubung. Menunggu data dari server...',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    controllerCard,
                  ],
                ),
              );
            } else if (data.length < 4) {
              return _buildScrollWrapper(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    headerCard,
                    const SizedBox(height: 20),
                    connectionCard,
                    const SizedBox(height: 24),
                    const Text(
                      'Data sensor belum lengkap. Menunggu data...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.orange),
                    ),
                    const SizedBox(height: 20),
                    controllerCard,
                    if (!controller.isConnected.value) _buildReconnectButton(),
                  ],
                ),
              );
            } else {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    headerCard,
                    const SizedBox(height: 12),
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
                                label: 'pH Air', data: data[1])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                            child: AnimatedStatusCard(
                                label: 'Kekeruhan (NTU)', data: data[2])),
                        const SizedBox(width: 8),
                        Expanded(
                            child: AnimatedStatusCard(
                                label: 'Amonia (ppm)', data: data[3])),
                      ],
                    ),
                    const SizedBox(height: 24),
                    controllerCard,
                    const SizedBox(height: 16),
                    if (!controller.isConnected.value) _buildReconnectButton(),
                  ],
                ),
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
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: child,
          )),
        ),
      );
    });
  }

  Widget _buildHeaderCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
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
        const Text(
          "MONITORING AKUARIUM",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Status Monitoring Akuarium",
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KONTROL PERANGKAT",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Aktifkan atau nonaktifkan fitur akuarium Anda.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            Obx(
              () => _buildToggleRow(
                title: 'Isi Air',
                subtitle: controller.isiAirActive
                    ? 'Sedang Mengisi Air'
                    : 'Pengisian Air Mati',
                value: controller.isiAirActive,
                onChanged: (bool newValue) {
                  controller.setIsiAir(newValue);
                },
                activeColor: Colors.blue.shade600,
                iconData: controller.isiAirActive
                    ? Icons.water_drop_rounded
                    : Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => _buildToggleRow(
                  title: 'Kuras Air',
                  subtitle: controller.kurasAirActive
                      ? 'Sedang Menguras Air'
                      : 'Pengurasan Air Mati',
                  value: controller.kurasAirActive,
                  onChanged: (bool newValue) {
                    controller.setKurasAir(newValue);
                  },
                  activeColor: Colors.teal.shade600,
                  iconData: controller.kurasAirActive
                      ? Icons.waves_rounded
                      : Icons.waves_outlined,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: controller.isConnected.value
          ? Colors.green.shade50
          : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              controller.isConnected.value ? 'TERHUBUNG' : 'TERPUTUS',
              style: TextStyle(
                fontSize: 13,
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
    );
  }

  Widget _buildReconnectButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Hubungkan Ulang'),
        onPressed: controller.reconnectSocket,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
    required IconData iconData,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            iconData,
            color: value ? activeColor : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16)),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ],
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
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late bool _isDanger;

  @override
  void initState() {
    super.initState();
    _isDanger = widget.data.kondisi == 1;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _setupAnimation();

    if (_isDanger) {
      _animationController.repeat(reverse: true);
    }
  }

  void _setupAnimation() {
    _animationController.stop();

    _colorAnimation = ColorTween(
      begin: _isDanger ? Colors.red.shade100 : Colors.green.shade100,
      end: _isDanger ? Colors.red.shade300 : Colors.green.shade50,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.kondisi != oldWidget.data.kondisi) {
      setState(() {
        _isDanger = widget.data.kondisi == 1;
      });
      _setupAnimation();
      if (_isDanger) {
        if (!_animationController.isAnimating) {
          _animationController.repeat(reverse: true);
        }
      } else {
        _animationController.stop();
        _animationController.animateTo(0, duration: Duration.zero);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatNumber(dynamic value) {
    if (value == null) return 'N/A';
    final double? doubleVal = double.tryParse(value.toString());
    if (doubleVal == null) return value.toString();

    if (doubleVal == doubleVal.truncateToDouble()) {
      return doubleVal.toStringAsFixed(0);
    } else {
      String formatted = doubleVal.toStringAsFixed(2);
      if (formatted.endsWith('.00')) {
        return doubleVal.toStringAsFixed(0);
      } else if (formatted.endsWith('0')) {
        return doubleVal.toStringAsFixed(1);
      }
      return formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (widget.label.toLowerCase()) {
      case 'suhu air (°c)':
        iconData = Icons.thermostat_rounded;
        break;
      case 'ph air':
        iconData = Icons.science_outlined;
        break;
      case 'kekeruhan (ntu)':
        iconData = Icons.opacity_rounded;
        break;
      case 'amonia (ppm)':
        iconData = Icons.bubble_chart_outlined;
        break;
      default:
        iconData = Icons.sensors_rounded;
    }

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 110,
          child: Card(
            color: _isDanger ? _colorAnimation.value : Colors.green.shade50,
            elevation: _isDanger ? 4 : 2,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: _isDanger
                  ? BorderSide(color: Colors.red.shade700, width: 1.5)
                  : BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    size: 32,
                    color:
                        _isDanger ? Colors.red.shade700 : Colors.green.shade700,
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
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(_formatNumber(widget.data.nilai),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _isDanger
                                  ? Colors.red.shade900
                                  : Colors.black,
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
