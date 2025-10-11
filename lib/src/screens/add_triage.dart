import 'package:flutter/material.dart';
import 'forms/form_reason_for_visit.dart';
import 'forms/form_demographics.dart';
import 'forms/form_chief_complaint.dart';
import 'forms/form_vitals.dart';
import 'forms/form_history_illness.dart';
import 'forms/form_past_medical.dart';
import 'forms/form_physical_exam.dart';

class AddTriage extends StatefulWidget {
  const AddTriage({Key? key}) : super(key: key);

  @override
  State<AddTriage> createState() => _AddTriageState();
}

class _AddTriageState extends State<AddTriage> with TickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryColor = const Color(0xFF016969);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F3),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Add Triage",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Reason for Visit"),
            Tab(text: "Demographics"),
            Tab(text: "Chief Complaint"),
            Tab(text: "Vitals"),
            Tab(text: "History of Illness"),
            Tab(text: "Past Medical"),
            Tab(text: "Physical Exam"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FormReasonForVisit(),
          FormDemographics(),
          FormChiefComplaint(),
          FormVitals(),
          FormHistoryIllness(),
          FormPastMedical(),
          FormPhysicalExam(),
        ],
      ),
    );
  }
}
