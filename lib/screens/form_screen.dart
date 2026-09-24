import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/life_stage.dart';
import '../models/month_names.dart';
import '../models/person.dart';
import '../providers/people_provider.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_chrome.dart';
import 'profile_screen.dart';

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
      text: p?.bDay != null ? p!.bDay.toString() : '',
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

    _nameController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
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

  String get _initials {
    final words = _nameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
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
    if (widget.person == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen(person: person)),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _delete() {
    if (widget.person == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Person'),
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
              // Pop any profile/form routes above the shell so the deleted
              // person's profile is not left on the navigation stack.
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.nunito(color: ctx.tokens.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isEditing = widget.person != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppTopRow(),
            _header(tokens, isEditing),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: _avatarPreview(tokens)),
                      const SizedBox(height: 22),
                      _microLabel(tokens, 'Name'),
                      const SizedBox(height: 8),
                      _nameField(tokens),
                      const SizedBox(height: 18),
                      _microLabel(tokens, 'Life stage'),
                      const SizedBox(height: 8),
                      _stageSelector(tokens),
                      const SizedBox(height: 18),
                      _microLabel(tokens, 'Birthday'),
                      const SizedBox(height: 8),
                      _birthdayRow(tokens),
                      const SizedBox(height: 18),
                      ..._stageSpecificFields(tokens),
                      const SizedBox(height: 18),
                      _microLabel(tokens, 'Location'),
                      const SizedBox(height: 8),
                      _field(
                        key: const Key('field-location'),
                        controller: _locationController,
                        hint: 'City',
                      ),
                      const SizedBox(height: 18),
                      _microLabel(
                        tokens,
                        'Interests',
                        suffix: '· comma-separated',
                      ),
                      const SizedBox(height: 8),
                      _field(
                        key: const Key('field-interests'),
                        controller: _interestsController,
                        hint: 'e.g. Hiking, Piano, Anime',
                      ),
                      const SizedBox(height: 18),
                      _microLabel(
                        tokens,
                        'Dietary',
                        suffix: '· comma-separated',
                      ),
                      const SizedBox(height: 8),
                      _field(
                        key: const Key('field-dietary'),
                        controller: _dietaryController,
                        hint: 'e.g. Vegetarian, No nuts',
                      ),
                      const SizedBox(height: 18),
                      _microLabel(tokens, 'How I know them'),
                      const SizedBox(height: 8),
                      _field(
                        key: const Key('field-howknow'),
                        controller: _howKnowController,
                        hint: 'e.g. College friend',
                      ),
                      const SizedBox(height: 18),
                      _microLabel(tokens, 'Notes & preferences'),
                      const SizedBox(height: 8),
                      _field(
                        key: const Key('field-notes'),
                        controller: _notesController,
                        hint: 'Anything you want to remember',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 28),
                      if (isEditing) _deleteButton(tokens),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(DesignTokens tokens, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 12, 4),
      child: Row(
        children: [
          InkWell(
            key: const Key('form-cancel'),
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                'Cancel',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: tokens.muted,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              isEditing ? 'Edit person' : 'Add person',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: tokens.text,
              ),
            ),
          ),
          InkWell(
            key: const Key('form-save'),
            onTap: _save,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Text(
                'Save',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: tokens.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPreview(DesignTokens tokens) {
    return CircleAvatar(
      key: const Key('form-avatar'),
      radius: 38,
      backgroundColor: _stage.avatarBg,
      child: Text(
        _initials,
        style: GoogleFonts.nunito(
          color: _stage.avatarColor,
          fontWeight: FontWeight.w900,
          fontSize: 26,
        ),
      ),
    );
  }

  Widget _microLabel(DesignTokens tokens, String label, {String? suffix}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: tokens.faint,
          ),
        ),
        if (suffix != null)
          Text(
            ' $suffix',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: tokens.faint2,
            ),
          ),
      ],
    );
  }

  Widget _field({
    required Key key,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) {
    final tokens = context.tokens;
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: tokens.text,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: tokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        hintStyle: GoogleFonts.nunito(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: tokens.faint2,
        ),
        errorStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: tokens.danger,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: tokens.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: tokens.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: tokens.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: tokens.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: tokens.danger),
        ),
      ),
    );
  }

  Widget _nameField(DesignTokens tokens) {
    return TextFormField(
      key: const Key('field-name'),
      controller: _nameController,
      validator: (val) =>
          val == null || val.trim().isEmpty ? 'Name is required' : null,
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: tokens.text,
      ),
      decoration: InputDecoration(
        hintText: 'Full name',
        filled: true,
        fillColor: tokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        hintStyle: GoogleFonts.nunito(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: tokens.faint2,
        ),
        errorStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: tokens.danger,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: tokens.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: tokens.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: tokens.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: tokens.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: tokens.danger),
        ),
      ),
    );
  }

  Widget _stageSelector(DesignTokens tokens) {
    return Row(
      children: LifeStage.values.map((stage) {
        final isActive = _stage == stage;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: stage == LifeStage.values.last ? 0 : 6,
            ),
            child: InkWell(
              key: Key('stage-segment-${stage.serialized}'),
              onTap: () => setState(() => _stage = stage),
              borderRadius: BorderRadius.circular(11),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? stage.avatarBg : tokens.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isActive ? stage.avatarBg : tokens.chipBorder,
                  ),
                ),
                child: Center(
                  child: Text(
                    stage.label,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white : tokens.chipText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _birthdayRow(DesignTokens tokens) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 14,
          child: DropdownButtonFormField<int>(
            key: const Key('field-birthday-month'),
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
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tokens.text,
            ),
            dropdownColor: tokens.surface,
            decoration: InputDecoration(
              filled: true,
              fillColor: tokens.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: tokens.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: tokens.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide(color: tokens.accent),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 10,
          child: _field(
            key: const Key('field-birthday-day'),
            controller: _bDayController,
            hint: 'Day',
            keyboardType: TextInputType.number,
            validator: _validateDay,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 12,
          child: _field(
            key: const Key('field-birthday-year'),
            controller: _bYearController,
            hint: 'Year',
            keyboardType: TextInputType.number,
            validator: _validateYear,
          ),
        ),
      ],
    );
  }

  String? _validateDay(String? val) {
    final text = val?.trim() ?? '';
    if (text.isEmpty) return 'Day is required';
    final day = int.tryParse(text);
    if (day == null) return 'Day must be a number';
    final yearText = _bYearController.text.trim();
    final year = yearText.isEmpty ? null : int.tryParse(yearText);
    if (day < 1 || day > _daysInMonth(_bMonth, year)) {
      return 'Invalid day for this month';
    }
    return null;
  }

  String? _validateYear(String? val) {
    final text = val?.trim() ?? '';
    if (text.isEmpty) return null;
    final year = int.tryParse(text);
    if (year == null) return 'Year must be a number';
    final today = Provider.of<PeopleProvider>(context, listen: false).today;
    if (year > today.year) return 'Year can\'t be in the future';
    return null;
  }

  static int _daysInMonth(int month, int? year) {
    if (month == 2) {
      // Without a year, allow Feb 29 (the person may be a leap-day baby).
      if (year == null) return 29;
      return _isLeapYear(year) ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  static bool _isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  List<Widget> _stageSpecificFields(DesignTokens tokens) {
    switch (_stage) {
      case LifeStage.college:
        return [
          _microLabel(tokens, 'Year in school'),
          const SizedBox(height: 8),
          _field(
            key: const Key('field-year'),
            controller: _yearController,
            hint: 'e.g. Junior',
          ),
          const SizedBox(height: 14),
          _microLabel(tokens, 'Major'),
          const SizedBox(height: 8),
          _field(
            key: const Key('field-major'),
            controller: _majorController,
            hint: 'e.g. Psychology',
          ),
          const SizedBox(height: 14),
          _microLabel(tokens, 'College'),
          const SizedBox(height: 8),
          _field(
            key: const Key('field-college'),
            controller: _schoolController,
            hint: 'e.g. UCLA',
          ),
        ];
      case LifeStage.teens:
      case LifeStage.kids:
        return [
          _microLabel(tokens, 'Grade'),
          const SizedBox(height: 8),
          _field(
            key: const Key('field-grade'),
            controller: _gradeController,
            hint: 'e.g. 10th grade',
          ),
          const SizedBox(height: 14),
          _microLabel(tokens, 'School'),
          const SizedBox(height: 8),
          _field(
            key: const Key('field-school'),
            controller: _schoolController,
            hint: 'e.g. Lincoln HS',
          ),
        ];
      case LifeStage.working:
        return [
          _microLabel(tokens, 'Occupation'),
          const SizedBox(height: 8),
          _field(
            key: const Key('field-occupation'),
            controller: _occupationController,
            hint: 'e.g. Nurse',
          ),
        ];
    }
  }

  Widget _deleteButton(DesignTokens tokens) {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        key: const Key('delete-person'),
        onTap: _delete,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            'Delete person',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: tokens.danger,
            ),
          ),
        ),
      ),
    );
  }
}
