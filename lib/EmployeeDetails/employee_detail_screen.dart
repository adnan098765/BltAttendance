import 'package:flutter/material.dart';

class BreakTrackerTabScreen extends StatefulWidget {
  final String employeeName;

   BreakTrackerTabScreen({super.key, required this.employeeName});

  @override
  State<BreakTrackerTabScreen> createState() => _BreakTrackerTabScreenState();
}

class _BreakTrackerTabScreenState extends State<BreakTrackerTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String employeeName = "Adnan";
  Duration totalBreakDuration = Duration.zero;
  DateTime? breakStartTime;
  String? currentBreakType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isWithinShift(DateTime time) {
    final now = time;
    final start = DateTime(now.year, now.month, now.day, 19); // 7 PM
    final end = DateTime(now.year, now.month, now.month, 4); // 4 AM

    if (now.hour < 4) {
      return now.isBefore(end) ||
          now.isAfter(start.subtract(const Duration(days: 1)));
    } else {
      return now.isAfter(start);
    }
  }

  void startBreak(String type) {
    if (!isWithinShift(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Break allowed only between 7 PM to 4 AM')),
      );
      return;
    }

    setState(() {
      currentBreakType = type;
      breakStartTime = DateTime.now();
    });
  }

  void endBreak() {
    if (breakStartTime == null) return;

    final now = DateTime.now();
    final breakDuration = now.difference(breakStartTime!);

    if (isWithinShift(breakStartTime!)) {
      setState(() {
        totalBreakDuration += breakDuration;
      });
    }

    setState(() {
      breakStartTime = null;
      currentBreakType = null;
    });
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes % 60;
    final hours = duration.inHours;
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // title: const Text('Break Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Employee"),
            Tab(text: "Quick Break"),
            Tab(text: "Meal Break"),
            Tab(text: "Total"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Text("👤 Employee: ${widget.employeeName}",
                style: const TextStyle(fontSize: 22)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (breakStartTime == null) ...[
                  ElevatedButton(
                    onPressed: () => startBreak("QB"),
                    child: const Text("Start Quick Break"),
                  ),
                ] else if (currentBreakType == "QB") ...[
                  const Text("Quick Break in progress",
                      style: TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: endBreak,
                    child: const Text("End Break"),
                  ),
                ] else ...[
                  const Text("Another break is active"),
                ]
              ],
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (breakStartTime == null) ...[
                  ElevatedButton(
                    onPressed: () => startBreak("MB"),
                    child: const Text("Start Meal Break"),
                  ),
                ] else if (currentBreakType == "MB") ...[
                  const Text("Meal Break in progress",
                      style: TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: endBreak,
                    child: const Text("End Break"),
                  ),
                ] else ...[
                  const Text("Another break is active"),
                ]
              ],
            ),
          ),

          /// ⏱ Total Break Time Tab
          Center(
            child: Text("🕓 Total Break Today:\n${formatDuration(totalBreakDuration)}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
