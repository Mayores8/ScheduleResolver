import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;


  final String _apiKey = '';

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (tasks.isEmpty) {
      _errorMessage = "No tasks provided.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final localConflicts = _detectConflicts(tasks);

      if (_apiKey.isEmpty) {
        _currentAnalysis = ScheduleAnalysis(
          conflicts: localConflicts.isEmpty
              ? "No conflicts detected ✅"
              : localConflicts.join('\n'),
          rankedTasks: "AI ranking unavailable (no API key)",
          recommendedSchedule: "AI suggestions unavailable",
          explanation: "Add your API key to enable AI features.",
        );
        return;
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final taskJson = jsonEncode(tasks.map((t) => t.toJson()).toList());

      final prompt = '''
        
      you are an expert student scheduling assistant. the user has provided the following tasks for their day in JSON format:
      $taskJson
        
      Your job is to analyze these tasks, identify any overlaps or conflicts in their start and end times, and suggest a better balanced schedule,
      consider their urgency, importance, and required energy level.
        
      Please Provide exactly 4 sections of markdown text:
      1. ### Detected Conflicts
      List any scheduling conflicts or state that there are none.
      2. ### Ranked tasks
      Rank Which tasks need attention first based on urgency, importance, and energy, provide a brief reason for each.
      3. ### Recommended Schedule
      Provide a revised daily timeline view adjusting the task times to resolve conflicts and balance the students workload, study time and rest.
      4. ### Explanation
      Explain why this recommendation was made in simple language that a student would easily understand.
        
      Ensure the markdown is well-formatted and easy to read. Do not include extra text outside of these headers.
      ''';

      final response = await model
          .generateContent([
        Content.text(prompt)
      ])
          .timeout(const Duration(seconds: 20));

      // 🔍 DEBUG OUTPUT
      print("========== GEMINI RAW RESPONSE ==========");
      print(response.text);
      print("=========================================");

      final text = response.text?.trim() ?? '';

      if (text.isEmpty || !text.contains('###')) {
        _currentAnalysis = ScheduleAnalysis(
          conflicts: localConflicts.isEmpty
              ? "No conflicts detected ✅"
              : localConflicts.join('\n'),
          rankedTasks: "AI failed to rank tasks",
          recommendedSchedule: "AI failed to generate schedule",
          explanation: "The AI response was empty or malformed.",
        );
      } else {
        _currentAnalysis = _parseResponse(text, localConflicts);
      }

    } catch (e) {
      _errorMessage = 'AI Error: $e';

      final localConflicts = _detectConflicts(tasks);

      _currentAnalysis = ScheduleAnalysis(
        conflicts: localConflicts.isEmpty
            ? "No conflicts detected ✅"
            : localConflicts.join('\n'),
        rankedTasks: "AI unavailable",
        recommendedSchedule: "AI unavailable",
        explanation: "Using fallback logic due to error.",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> _detectConflicts(List<TaskModel> tasks) {
    List<String> conflicts = [];

    for (int i = 0; i < tasks.length; i++) {
      for (int j = i + 1; j < tasks.length; j++) {
        final a = tasks[i];
        final b = tasks[j];

        if (_isOverlapping(a, b)) {
          conflicts.add("${a.title} overlaps with ${b.title}");
        }
      }
    }

    return conflicts;
  }

  bool _isOverlapping(TaskModel a, TaskModel b) {
    return a.startTime.isBefore(b.endTime) &&
        b.startTime.isBefore(a.endTime);
  }

  ScheduleAnalysis _parseResponse(String text, List<String> fallbackConflicts) {
    String conflicts = "";
    String rankedTasks = "";
    String recommendedSchedule = "";
    String explanation = "";

    final regex = RegExp(r'###\s*(.*?)\n([\s\S]*?)(?=###|$)');
    final matches = regex.allMatches(text);

    for (final match in matches) {
      final title = match.group(1)?.toLowerCase() ?? '';
      final content = match.group(2)?.trim() ?? '';

      if (title.contains('conflict')) {
        conflicts = content;
      } else if (title.contains('rank')) {
        rankedTasks = content;
      } else if (title.contains('recommended')) {
        recommendedSchedule = content;
      } else if (title.contains('explanation')) {
        explanation = content;
      }
    }

    if (conflicts.isEmpty) {
      conflicts = fallbackConflicts.isEmpty
          ? "No conflicts detected ✅"
          : fallbackConflicts.join('\n');
    }

    return ScheduleAnalysis(
      conflicts: conflicts,
      rankedTasks: rankedTasks.isEmpty ? "Not provided" : rankedTasks,
      recommendedSchedule:
      recommendedSchedule.isEmpty ? "Not provided" : recommendedSchedule,
      explanation: explanation.isEmpty ? "Not provided" : explanation,
    );
  }
}