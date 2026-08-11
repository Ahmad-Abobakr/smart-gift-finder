import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
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
  String _interests = 'Technology';
  double _budgetMax = 500;

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
    'Technology, Gaming',
    'Fashion, Beauty',
    'Sports, Fitness',
    'Music, Art',
  ];

  String get _budgetLabel {
    if (_budgetMax <= 50) return 'Under \$50';
    if (_budgetMax <= 100) return 'Under \$100';
    if (_budgetMax <= 250) return 'Under \$250';
    if (_budgetMax <= 500) return 'Under \$500';
    if (_budgetMax <= 1000) return 'Under \$1000';
    return 'No limit';
  }

  void _onSubmit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AIGiftResultsScreen(
          ageRange: _ageRange,
          gender: _gender,
          occasion: _occasion,
          interests: _interests,
          budgetMax: _budgetMax,
        ),
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
            _buildDropdown(
              label: 'Interests',
              value: _interests,
              items: _interestsList,
              onChanged: (v) => setState(() => _interests = v!),
            ),
            const SizedBox(height: 16),
            _buildBudgetSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSubmit,
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
                _budgetLabel,
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
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.primaryColor,
            inactiveTrackColor: AppTheme.borderLight,
            thumbColor: AppTheme.primaryColor,
            overlayColor: AppTheme.primaryColor.withAlpha(30),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: _budgetMax,
            min: 0,
            max: 1000,
            divisions: 20,
            onChanged: (v) => setState(() => _budgetMax = v),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$0', style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
            Text('\$1000',
                style: TextStyle(fontSize: 12, color: AppTheme.textHint)),
          ],
        ),
      ],
    );
  }
}
