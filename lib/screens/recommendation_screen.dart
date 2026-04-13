import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_schedule_service.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AiScheduleService>(context);
    final analysis = aiService.currentAnalysis;

    if (analysis == null) return const Scaffold(body: Center(child: Text('No Data')));

    return Scaffold(
      appBar: AppBar(
          title: const Text('AI Schedule Recommendation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSection(context, 'Detected Conflicts', analysis.conflicts, Colors.red.shade100, Icons.warning_amber_rounded),
            const SizedBox(height: 16),
            _buildSection(context, 'Ranked Tasks', analysis.rankedTasks, Colors.blue.shade100, Icons.format_list_numbered),
            const SizedBox(height: 16),
            _buildSection(context, 'Recommended Schedule', analysis.recommendedSchedule, Colors.green.shade100, Icons.calendar_today),
            const SizedBox(height: 16),
            _buildSection(context, 'Explanation', analysis.explanation, Colors.orange.shade100, Icons.lightbulb_outline),
          ],
        ),
      ),
    );
  }
  Widget _buildSection(BuildContext context, String title, String content, Color bgColor, IconData icon) {
    return Card(
      color: bgColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}