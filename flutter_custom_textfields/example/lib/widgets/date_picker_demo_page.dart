import 'package:flutter/material.dart';
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

class DatePickerDemoPage extends StatefulWidget {
  const DatePickerDemoPage({super.key});

  @override
  State<DatePickerDemoPage> createState() => _DatePickerDemoPageState();
}

class _DatePickerDemoPageState extends State<DatePickerDemoPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? singleDate;
  List<DateTime>? multipleDates;
  List<DateTime>? dateRange;
  DateTime? pastOnlyDate;
  DateTime? futureOnlyDate;
  DateTime? calendarBelowDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Date Picker Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.arrow_back),
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Single Date Selection'),
                SmartDatePickerField(
                  config: DatePickerConfig(
                    selectionMode: DateSelectionMode.single,
                    labelText: null,
                    hintText: 'Choose a date',
                    isRequired: true,
                    onChanged: (value) {
                      setState(() {
                        singleDate = value;
                      });
                      _showSelectedValue('Single Date', value);
                    },
                    validator: (value) {
                      if (value == null) return 'Please select a date';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Multiple Date Selection'),
                SmartDatePickerField(
                  config: DatePickerConfig(
                    selectionMode: DateSelectionMode.multiple,
                    labelText: null,
                    hintText: 'Choose multiple dates',
                    primaryColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        multipleDates = value;
                      });
                      _showSelectedValue('Multiple Dates', value);
                    },
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Date Range Selection'),
                SmartDatePickerField(
                  config: DatePickerConfig(
                    selectionMode: DateSelectionMode.range,
                    labelText: null,
                    hintText: 'Choose date range',
                    primaryColor: Colors.purple,
                    onChanged: (value) {
                      setState(() {
                        dateRange = value;
                      });
                      _showSelectedValue('Date Range', value);
                    },
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Past Dates Only'),
                SmartDatePickerField(
                  config: DatePickerConfig(
                    selectionMode: DateSelectionMode.single,
                    dateRestriction: DateRestriction.pastOnly,
                    labelText: null,
                    hintText: 'Select past date',
                    primaryColor: Colors.orange,
                    onChanged: (value) {
                      setState(() {
                        pastOnlyDate = value;
                      });
                      _showSelectedValue('Past Date', value);
                    },
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Future Dates Only'),
                SmartDatePickerField(
                  config: DatePickerConfig(
                    selectionMode: DateSelectionMode.single,
                    dateRestriction: DateRestriction.futureOnly,
                    labelText: null,
                    hintText: 'Select future date',
                    primaryColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        futureOnlyDate = value;
                      });
                      _showSelectedValue('Future Date', value);
                    },
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Calendar Below Text Field'),
                SmartDatePickerField(
                  config: DatePickerConfig(
                    selectionMode: DateSelectionMode.single,
                    labelText: null,
                    hintText: 'Tap to show calendar',
                    showCalendarBelow: true,
                    isCalendarHidden: true,
                    primaryColor: Colors.teal,
                    onChanged: (value) {
                      setState(() {
                        calendarBelowDate = value;
                      });
                      _showSelectedValue('Calendar Below', value);
                    },
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Custom Styling'),
                SmartDatePickerField(
                  config: DatePickerConfig(
                    selectionMode: DateSelectionMode.single,
                    labelText: null,
                    hintText: 'Beautiful custom styling',
                    primaryColor: Colors.deepPurple,
                    backgroundColor: Colors.deepPurple.withOpacity(0.05),
                    icon: Icons.star,
                    dateFormat: 'EEEE, MMMM d, yyyy',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.deepPurple.withOpacity(0.3),
                      ),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    onChanged: (value) {
                      _showSelectedValue('Custom Styled', value);
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Form Validation Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showSnackBar('Form is valid!');
                      } else {
                        _showSnackBar('Please fix the errors');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Validate Form'),
                  ),
                ),

                const SizedBox(height: 16),

                // Clear All Button
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        singleDate = null;
                        multipleDates = null;
                        dateRange = null;
                        pastOnlyDate = null;
                        futureOnlyDate = null;
                        calendarBelowDate = null;
                      });
                      _showSnackBar('All selections cleared');
                    },
                    child: const Text('Clear All'),
                  ),
                ),

                const SizedBox(height: 32),

                // Selected Values Summary
                _buildSummaryCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Values Summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Single Date',
              singleDate?.toString() ?? 'Not selected',
            ),
            _buildSummaryRow(
              'Multiple Dates',
              multipleDates?.join(', ') ?? 'Not selected',
            ),
            _buildSummaryRow(
              'Date Range',
              dateRange?.join(' - ') ?? 'Not selected',
            ),
            _buildSummaryRow(
              'Past Date',
              pastOnlyDate?.toString() ?? 'Not selected',
            ),
            _buildSummaryRow(
              'Future Date',
              futureOnlyDate?.toString() ?? 'Not selected',
            ),
            _buildSummaryRow(
              'Calendar Below',
              calendarBelowDate?.toString() ?? 'Not selected',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectedValue(String type, dynamic value) {
    String message = '$type: ';
    if (value == null) {
      message += 'Not selected';
    } else if (value is DateTime) {
      message += DateFormatter.formatDate(value, 'dd/MM/yyyy');
    } else if (value is List<DateTime>) {
      message += value
          .map((d) => DateFormatter.formatDate(d, 'dd/MM/yyyy'))
          .join(', ');
    } else {
      message += value.toString();
    }

    print(message);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
