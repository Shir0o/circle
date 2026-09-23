import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/life_stage.dart';
import '../models/month_names.dart';
import '../models/person.dart';
import '../providers/people_provider.dart';
import '../theme/design_tokens.dart';

class FormScreen extends StatefulWidget {
  final Person? person;

  const FormScreen({super.key, this.person});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  late LifeStage _stage;
  late TextEditingController _nameController;
  late int _bMonth;
  late TextEditingController _bDayController;
  late TextEditingController _bYearController;
  late TextEditingController _yearController;
  late TextEditingController _majorController;
  late TextEditingController _schoolController;
  late TextEditingController _gradeController;
  late TextEditingController _occupationController;
  late TextEditingController _locationController;
  late TextEditingController _interestsController;
  late TextEditingController _dietaryController;
  late TextEditingController _howKnowController;
  late TextEditingController _notesController;

  final months = monthNames;

  @override
  void initState() {
    super.initState();
    final p = widget.person;

    _stage = p?.stage ?? LifeStage.college;
    _nameController = TextEditingController(text: p?.name ?? '');
    _bMonth = p?.bMonth ?? 1;
    _bDayController = TextEditingController(
      text: p?.bDay != null ? p!.bDay.toString() : '1',
    );
    _bYearController = TextEditingController(
      text: p?.bYear != null ? p!.bYear.toString() : '',
    );
    _yearController = TextEditingController(text: p?.year ?? '');
    _majorController = TextEditingController(text: p?.major ?? '');
    _schoolController = TextEditingController(text: p?.school ?? '');
    _gradeController = TextEditingController(text: p?.grade ?? '');
    _occupationController = TextEditingController(text: p?.occupation ?? '');
    _locationController = TextEditingController(text: p?.location ?? '');
    _interestsController = TextEditingController(
      text: (p?.interests ?? []).join(', '),
    );
    _dietaryController = TextEditingController(
      text: (p?.dietary ?? []).join(', '),
    );
    _howKnowController = TextEditingController(text: p?.howKnow ?? '');
    _notesController = TextEditingController(text: p?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bDayController.dispose();
    _bYearController.dispose();
    _yearController.dispose();
    _majorController.dispose();
    _schoolController.dispose();
    _gradeController.dispose();
    _occupationController.dispose();
    _locationController.dispose();
    _interestsController.dispose();
    _dietaryController.dispose();
    _howKnowController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<PeopleProvider>(context, listen: false);

    final id = widget.person?.id ?? DateTime.now().millisecondsSinceEpoch;
    final bDay = int.tryParse(_bDayController.text.trim()) ?? 1;
    final bYear = int.tryParse(_bYearController.text.trim());

    final interests = _interestsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final dietary = _dietaryController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final person = Person(
      id: id,
      name: _nameController.text.trim(),
      stage: _stage,
      bMonth: _bMonth,
      bDay: bDay,
      bYear: bYear,
      year: _yearController.text.trim(),
      major: _majorController.text.trim(),
      school: _schoolController.text.trim(),
      grade: _gradeController.text.trim(),
      occupation: _occupationController.text.trim(),
      location: _locationController.text.trim(),
      interests: interests,
      dietary: dietary,
      howKnow: _howKnowController.text.trim(),
      notes: _notesController.text.trim(),
    );

    provider.savePerson(person);
    Navigator.pop(context);
  }

  void _delete() {
    if (widget.person == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text(
          'Are you sure you want to delete ${widget.person!.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<PeopleProvider>(
                context,
                listen: false,
              );
              provider.deletePerson(widget.person!.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close profile/form screen
            },
            child: Text('Delete', style: TextStyle(color: ctx.tokens.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final isEditing = widget.person != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Person' : 'Add Person'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Life Stage Selector
              Text('Life Stage', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: LifeStage.values.map((stage) {
                  final isActive = _stage == stage;
                  final meta = stage;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => setState(() => _stage = stage),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? meta.avatarBg
                                : (theme.cardTheme.color ??
                                      theme.colorScheme.surface),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? meta.avatarBg
                                  : tokens.chipBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              stage.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isActive
                                    ? Colors.white
                                    : tokens.chipText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Name Field
              Text('Full Name *', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Name is required'
                    : null,
                decoration: const InputDecoration(hintText: 'e.g. Maya Chen'),
              ),

              const SizedBox(height: 20),

              // Birthday Fields
              Text('Birthday', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      initialValue: _bMonth,
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(months[index]),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) setState(() => _bMonth = val);
                      },
                      decoration: const InputDecoration(labelText: 'Month'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _bDayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Day'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _bYearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Year (opt)',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Conditional Fields by Stage
              if (_stage == LifeStage.college) ...[
                Text('College Details', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(
                          hintText: 'Year (e.g. Junior)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _majorController,
                        decoration: const InputDecoration(
                          hintText: 'Major (e.g. Psychology)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _schoolController,
                  decoration: const InputDecoration(
                    hintText: 'School / University (e.g. UCLA)',
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_stage == LifeStage.teens ||
                  _stage == LifeStage.kids) ...[
                Text('School Details', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gradeController,
                        decoration: const InputDecoration(
                          hintText: 'Grade (e.g. 10th grade)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _schoolController,
                        decoration: const InputDecoration(
                          hintText: 'School (e.g. Lincoln HS)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ] else ...[
                Text('Work Details', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _occupationController,
                  decoration: const InputDecoration(
                    hintText: 'Occupation (e.g. Software Engineer)',
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Location
              Text('Location', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'City / Region (e.g. San Francisco)',
                ),
              ),

              const SizedBox(height: 20),

              // Interests
              Text(
                'Interests (comma separated)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _interestsController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Photography, Hiking, Chess',
                ),
              ),

              const SizedBox(height: 20),

              // Dietary
              Text(
                'Dietary Preferences (comma separated)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _dietaryController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Vegetarian, Gluten-free',
                ),
              ),

              const SizedBox(height: 20),

              // Connection
              Text('How you know them', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: _howKnowController,
                decoration: const InputDecoration(
                  hintText: 'e.g. College friend, Old roommate',
                ),
              ),

              const SizedBox(height: 20),

              // Notes
              Text('Notes', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Personal notes or gift ideas...',
                ),
              ),

              const SizedBox(height: 30),

              // Delete Button (if editing)
              if (isEditing)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _delete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: tokens.danger,
                    ),
                    label: Text(
                      'Delete Member',
                      style: TextStyle(color: tokens.danger),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: tokens.danger),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
