import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_resolver/providers/schedule_provider.dart';
import '../services/ai_schedule_service.dart';
import '../models/task_model.dart';
import 'task_input_screen.dart';
import 'recommendation_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO: implement build
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final aiService = Provider.of<AiScheduleService>(context);

    final sortedTasks = List<TaskModel>.from(scheduleProvider.tasks);
    sortedTasks.sort((a,b) => a.startTime.hour.compareTo(b.startTime.hour));

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Resolver'), centerTitle: true),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (aiService.currentAnalysis != null)
                Card(
                  color: Colors.green.shade100,
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Recommendation Ready', style: TextStyle(fontWeight: FontWeight.bold)),
                          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
                          const RecommendationScreen())), child: const Text('View Recommendation'))

                        ],
                      )
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: sortedTasks.isEmpty ? const Center(child: Text('No task Added yet')) : ListView.builder(itemCount: sortedTasks.length,
                  itemBuilder: (context, index) {
                    final task = sortedTasks[index];
                    return Card(
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Text(
                          "${task.category} | ${task.startTime.format(context)} - ${task.endTime.format(context)}",
                        ),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () =>
                            scheduleProvider.removeTask(task.id)),
                      ),
                    );
                  },
                ),
              ),

              if (sortedTasks.isNotEmpty)
                ElevatedButton(
                  onPressed: aiService.isLoading ? null : () => aiService.analyzeSchedule(scheduleProvider.tasks),
                  child: aiService.isLoading ? const CircularProgressIndicator() : const Text ("Resolve Conflicts WithAI"),
                ),
            ],
          )
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () =>Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskInputScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}