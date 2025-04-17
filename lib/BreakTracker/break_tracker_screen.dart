import 'package:flutter/material.dart';

class BreakTrackerTabScreen extends StatefulWidget {
  // final String employeeName;

  BreakTrackerTabScreen({super.key,});

  @override
  State<BreakTrackerTabScreen> createState() => _BreakTrackerTabScreenState();
}

class _BreakTrackerTabScreenState extends State<BreakTrackerTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Current-day break total
  Duration totalBreakDuration = Duration.zero;
  DateTime? breakStartTime;
  String? currentBreakType;

  // Map to store daily totals: Date (year,month,day) -> Duration
  final Map<DateTime, Duration> _dailyBreaks = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isWithinShift(DateTime time) {
    final now = time;
    final shiftStart = DateTime(now.year, now.month, now.day, 19); // 7 PM
    final shiftEnd = DateTime(now.year, now.month, now.day, 4);   // 4 AM next day

    if (now.hour < 4) {
      // after midnight: still previous day's shift
      return now.isBefore(shiftEnd) ||
          now.isAfter(shiftStart.subtract(const Duration(days: 1)));
    } else {
      return now.isAfter(shiftStart);
    }
  }

  void _recordDailyTotal() {
    final todayKey = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    // overwrite or set today's total
    _dailyBreaks[todayKey] = totalBreakDuration;
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
    final dur = now.difference(breakStartTime!);

    if (isWithinShift(breakStartTime!)) {
      setState(() {
        totalBreakDuration += dur;
        // update daily record immediately
        _recordDailyTotal();
      });
    }

    setState(() {
      breakStartTime = null;
      currentBreakType = null;
    });
  }

  Duration getMonthlyTotal() {
    final now = DateTime.now();
    Duration sum = Duration.zero;
    _dailyBreaks.forEach((date, dur) {
      if (date.year == now.year && date.month == now.month) {
        sum += dur;
      }
    });
    return sum;
  }

  String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h.toString().padLeft(2,'0')}h ${m.toString().padLeft(2,'0')}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Employee"),
            Tab(text: "Quick Break"),
            Tab(text: "Meal Break"),
            Tab(text: "Total Today"),
            Tab(text: "Monthly"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Employee Info
          Center(
            child: Text(
              "👤 Employee",
              style: const TextStyle(fontSize: 22),
            ),
          ),

          // 2. Quick Break
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
                ],
              ],
            ),
          ),

          // 3. Meal Break
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
                ],
              ],
            ),
          ),

          // 4. Total Today
          Center(
            child: Text(
              "🕓 Total Break Today:\n${formatDuration(totalBreakDuration)}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.blue),
            ),
          ),

          // 5. Monthly Summary
          Center(
            child: Text(
              "${DateTime.now().month}/${DateTime.now().year} Break Total:\n${formatDuration(getMonthlyTotal())}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
