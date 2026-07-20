import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/task_entity.dart';

/// Immutable payload emitted when a task form is submitted.
class TaskFormData {
  const TaskFormData({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.status,
  });

  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final TaskStatus status;
}

/// Reusable task form shared by Create (Stage 4) and Edit (Stage 5).
///
/// - [initial] pre-fills the fields (edit mode) or is null (create mode).
/// - [showStatus] adds the status dropdown (edit only).
class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    this.initial,
    required this.showStatus,
    required this.submitting,
    required this.submitLabel,
    required this.onSubmit,
  });

  final TaskEntity? initial;
  final bool showStatus;
  final bool submitting;
  final String submitLabel;
  final ValueChanged<TaskFormData> onSubmit;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late TaskPriority _priority;
  late TaskStatus _status;
  DateTime? _dueDate;
  bool _dueError = false;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _title = TextEditingController(text: t?.title ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _priority = t?.priority ?? TaskPriority.medium;
    _status = t?.status ?? TaskStatus.pending;
    _dueDate = t?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueError = false;
      });
    }
  }

  void _submit() {
    final validForm = _formKey.currentState!.validate();
    final hasDate = _dueDate != null;
    setState(() => _dueError = !hasDate);
    if (!validForm || !hasDate) return;

    widget.onSubmit(
      TaskFormData(
        title: _title.text.trim(),
        description: _description.text.trim(),
        priority: _priority,
        dueDate: _dueDate!,
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => Validators.required(v, 'Title'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Description'),
            minLines: 3,
            maxLines: 5,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => Validators.required(v, 'Description'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TaskPriority>(
            value: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: TaskPriority.values
                .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                .toList(),
            onChanged: (p) => setState(() => _priority = p ?? _priority),
          ),
          if (widget.showStatus) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: TaskStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (s) => setState(() => _status = s ?? _status),
            ),
          ],
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Due date',
                errorText: _dueError ? 'Please pick a due date' : null,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                _dueDate == null ? 'Select a date' : Formatters.date(_dueDate!),
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: widget.submitting ? null : _submit,
            child: widget.submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
