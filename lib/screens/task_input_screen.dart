import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';

class TaskInputScreen extends StatefulWidget {
  const TaskInputScreen({super.key});
  @override
  State<TaskInputScreen> createState() => _TaskInputScreenState();
}

class _TaskInputScreenState extends State<TaskInputScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _category = 'Class';
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  double _urgency = 3, _importance = 3, _effort = 1.0;
  String _energy = 'Medium';

  final List<String> _cats = ['Class', 'Org Work', 'Study', 'Rest', 'Other'];
  final List<String> _energies = ['Low', 'Medium', 'High'];

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(context: context, initialTime: isStart ? _startTime : _endTime);
    if (picked != null) setState(() => isStart ? _startTime = picked : _endTime = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Provider.of<ScheduleProvider>(context, listen: false).addTask(
        title: _title, category: _category, date: _date,
        startTime: _startTime, endTime: _endTime,
        urgency: _urgency.toInt(), importance: _importance.toInt(),
        estimatedEffortHours: _effort, energyLevel: _energy,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Task Title', border: OutlineInputBorder()),
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: _cats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(true),
                      icon: const Icon(Icons.access_time),
                      label: Text("Start: ${_startTime.format(context)}"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(false),
                      icon: const Icon(Icons.access_time),
                      label: Text("End: ${_endTime.format(context)}"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Urgency (1 = Low, 5 = High)'),
              Slider(value: _urgency, min: 1, max: 5, divisions: 4, label: _urgency.round().toString(), onChanged: (val) => setState(() => _urgency = val)),
              const Text('Importance (1 = Low, 5 = High)'),
              Slider(value: _importance, min: 1, max: 5, divisions: 4, label: _importance.round().toString(), onChanged: (val) => setState(() => _importance = val)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _energy,
                decoration: const InputDecoration(labelText: 'Energy Level', border: OutlineInputBorder()),
                items: _energies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _energy = val!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _submit, child: const Text('Add Task to Timeline')),
            ],
          ),
        ),
      ),
    );
  }
}