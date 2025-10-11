import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  List<List<dynamic>> seasonalData = [];
  int currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadSeasonalData();
  }

  Future<void> loadSeasonalData() async {
    final rawData =
        await rootBundle.loadString('assets/data/seasonal_diseases.csv');

    List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
    csvTable = csvTable
        .where((row) => row.isNotEmpty && row[0].toString().trim().isNotEmpty)
        .toList();

    int foundIndex = 0;
    String month = DateFormat('MMM').format(DateTime.now());

    for (int i = 1; i < csvTable.length; i++) {
      String months = csvTable[i][1].toString();
      if (months.contains(month)) {
        foundIndex = i - 1;
        break;
      }
    }

    if (foundIndex < 0 || foundIndex >= csvTable.length - 1) {
      foundIndex = 0;
    }

    setState(() {
      seasonalData = csvTable;
      currentIndex = foundIndex;
    });

    // 🟩 Scroll to current season after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentSeason();
    });
  }

  void _scrollToCurrentSeason() {
    final offset = (currentIndex * 240).toDouble();
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF007B7B);
    const accentColor = Color(0xFF00C6A2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌈 Welcome Card
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [accentColor, primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                height: 190,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome, Dr. Sophia 👋',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here’s an overview of today’s hospital activity.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -10,
                right: -10,
                child: Image.asset(
                  'assets/images/girl.png',
                  height: 210,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),

          const SizedBox(height: 60),

          // 📊 Hospital Activity Graph
          Text(
            "Hospital Activity",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: primaryColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 6,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        return Text(
                          days[v.toInt()],
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54),
                      ),
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [accentColor, primaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.25),
                          Colors.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 3.2),
                      FlSpot(2, 2.8),
                      FlSpot(3, 4.5),
                      FlSpot(4, 3.8),
                      FlSpot(5, 5),
                      FlSpot(6, 4.2),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatCard(label: 'Current Patients', value: '128'),
              _StatCard(label: 'Available Beds', value: '32'),
              _StatCard(label: 'Staff On Duty', value: '48'),
            ],
          ),

          const SizedBox(height: 40),

          // 🦠 Prevalent Diseases Section
          Text(
            "Prevalent Diseases (Seasonal Overview)",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: primaryColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 200,
            child: seasonalData.length <= 1
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: seasonalData.length - 1,
                    itemBuilder: (context, index) {
                      if (index + 1 >= seasonalData.length) {
                        return const SizedBox.shrink();
                      }

                      final row = seasonalData[index + 1];
                      bool isCurrent = index == currentIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 240,
                        child: _SeasonCard(
                          season: row[0].toString(),
                          months: row[1].toString(),
                          diseases: row[2].toString(),
                          highlight: isCurrent,
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 30),

          // 👩‍⚕️ Active Appointments
          Text(
            "Active Appointments",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: primaryColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: const [
              _AppointmentCard(
                name: "John Carter",
                condition: "Asthma Follow-up",
                time: "10:30 AM",
                color: accentColor,
              ),
              _AppointmentCard(
                name: "Emily Clark",
                condition: "Diabetes Consultation",
                time: "11:00 AM",
                color: primaryColor,
              ),
              _AppointmentCard(
                name: "Liam Brown",
                condition: "Chest Pain Evaluation",
                time: "11:45 AM",
                color: accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🌿 Season Card (new design with small bars)
class _SeasonCard extends StatelessWidget {
  final String season;
  final String months;
  final String diseases;
  final bool highlight;

  const _SeasonCard({
    required this.season,
    required this.months,
    required this.diseases,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007B7B);
    const accentColor = Color(0xFF00C6A2);
    final diseaseList = diseases.split(',').map((e) => e.trim()).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: highlight
            ? const LinearGradient(
                colors: [accentColor, primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: highlight ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            season,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: highlight ? Colors.white : primaryColor,
            ),
          ),
          Text(
            months,
            style: TextStyle(
              fontSize: 12,
              color: highlight ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          ...diseaseList.take(4).map((disease) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 6,
                    width: (disease.length * 4).clamp(60, 140).toDouble(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: highlight
                          ? Colors.white.withOpacity(0.8)
                          : primaryColor.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    disease,
                    style: TextStyle(
                      fontSize: 11,
                      color: highlight ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// 📊 Stat Card
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007B7B);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FFFE),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 👩‍⚕️ Appointment Card
class _AppointmentCard extends StatelessWidget {
  final String name;
  final String condition;
  final String time;
  final Color color;

  const _AppointmentCard({
    required this.name,
    required this.condition,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text(condition,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
