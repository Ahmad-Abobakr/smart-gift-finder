import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/gift_preferences.dart';
import 'ai_gift_results_screen.dart';

class AIGiftFormScreen extends StatefulWidget {
  const AIGiftFormScreen({super.key});

  @override
  State<AIGiftFormScreen> createState() => _AIGiftFormScreenState();
}

class _AIGiftFormScreenState extends State<AIGiftFormScreen> {
  String _ageRange = '25-30';
  String _gender = 'Male';
  String _occasion = 'Birthday';
  final Set<String> _selectedInterests = {};
  final TextEditingController _budgetController = TextEditingController(text: '500');

  static const _ageRanges = [
    '10-17',
    '18-24',
    '25-30',
    '31-40',
    '41-50',
    '50+',
  ];

  static const _genders = ['Male', 'Female', 'Any'];

  static const _occasions = [
    'Birthday',
    'Graduation',
    'Anniversary',
    'Wedding',
    'Holiday',
    'Just Because',
  ];

  static const _interestsList = [
    'Technology',
    'Gaming',
    'Fashion',
    'Sports',
    'Music',
    'Cooking',
    'Reading',
    'Art',
    'Travel',
    'Fitness',
  ];

  double get _budgetMax {
    final value = double.tryParse(_budgetController.text);
    return value ?? 0;
  }

  void _onSubmit() {
    final preferences = GiftPreferences(
      ageRange: _ageRange,
      gender: _gender,
      occasion: _occasion,
      interests: _selectedInterests.join(', '),
      budgetMax: _budgetMax,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AIGiftResultsScreen(preferences: preferences),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBgColor,
      appBar: AppBar(
        title: const Text('AI Gift Finder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Tell us about the gift',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The more details you share, the better recommendations you get!',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            _buildDropdown(
              label: "Recipient's Age",
              value: _ageRange,
              items: _ageRanges,
              onChanged: (v) => setState(() => _ageRange = v!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Gender',
              value: _gender,
              items: _genders,
              onChanged: (v) => setState(() => _gender = v!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Occasion',
              value: _occasion,
              items: _occasions,
              onChanged: (v) => setState(() => _occasion = v!),
            ),
            const SizedBox(height: 16),
            _buildInterestsSelector(),
            const SizedBox(height: 16),
            _buildBudgetSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _budgetMax <= 0 ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Get AI Recommendations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textHint),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests (select multiple)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interestsList.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInterests.add(interest);
                  } else {
                    _selectedInterests.remove(interest);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : AppTheme.borderLight,
                width: isSelected ? 2 : 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        if (_selectedInterests.isNotEmpty)
          Text(
            '${_selectedInterests.length} interests selected',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budget',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _budgetMax > 0 ? '\$${_budgetMax.toStringAsFixed(0)}' : 'No limit',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter budget (e.g., 500)',
            hintStyle: TextStyle(color: AppTheme.textHint),
            border: InputBorder.none,
            errorText: _budgetMax <= 0 ? 'Please enter a valid budget' : null,
          ),
          onChanged: (v) => setState(() {}),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter 0 for no budget limit',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
