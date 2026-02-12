import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/alarm_toggle.dart';
import '../widgets/app_button.dart';
import '../widgets/stop_tile.dart';
import '../services/stop_service.dart';
import '../services/alarm_service.dart';
import '../models/stop_model.dart';
import '../utils/constants.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final AlarmService _alarm = AlarmService.instance;
  bool _modeTimeStop = false;

  @override
  void initState() {
    super.initState();
    _alarm.addListener(_onServiceUpdated);
  }

  void _onServiceUpdated() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _alarm.removeListener(_onServiceUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _alarm.currentIndex;
    final target = _alarm.target;
    final penultimate = _alarm.getPenultimateStop();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kBgGradientStart, kBgGradientEnd],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // LOGO
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimaryColor,
                      boxShadow: [BoxShadow(color: kPrimaryColor.withAlpha(46), blurRadius: 12, offset: const Offset(0,6))],
                    ),
                    child: const Center(
                      child: Text('LS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // STOP + MODE
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STOP', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(target?.name ?? 'Select stop', style: const TextStyle(color: Colors.black87)),
                          if (penultimate != null)
                            Text('Предпоследняя: ${penultimate.name}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    AlarmToggle(value: _modeTimeStop, onChanged: (v) => setState(() => _modeTimeStop = v)),
                  ],
                ),

                const SizedBox(height: 12),

                // STOP LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: _alarm.stops.length,
                    itemBuilder: (context, idx) {
                      final stop = _alarm.stops[idx];
                      return StopTile(
                        stop: stop,
                        selected: _alarm.target == stop,
                        isCurrent: idx == currentIndex,
                        onTap: () {
                          _alarm.setTarget(stop);
                          _alarm.setEnabled(true);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // STATUS + CONTROLS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Текущая: ${_alarm.stops[currentIndex].name}', style: const TextStyle(fontSize: 14)),
                    Row(
                      children: [
                        AppButton.ghost(
                          onPressed: () => _alarm.setEnabled(false),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [Icon(Icons.stop, color: kPrimaryColor), SizedBox(width: 8), Text('STOP')],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppButton.primary(
                          onPressed: () => _alarm.setEnabled(true),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [Icon(Icons.play_arrow), SizedBox(width: 8), Text('START')],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}
