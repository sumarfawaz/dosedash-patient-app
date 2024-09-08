import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AgeRangeSelector extends StatefulWidget {
  final Function(String?) onAgeRangeSelected;

  AgeRangeSelector({required this.onAgeRangeSelected});

  @override
  _AgeRangeSelectorState createState() => _AgeRangeSelectorState();
}

class _AgeRangeSelectorState extends State<AgeRangeSelector> {
  String? selectedAgeRange;

  final List<String> ageRanges = [
    '18-25',
    '26-35',
    '36-45',
    '46-55',
    '56+',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Select Age Range *',
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: DropdownButton<String>(
            // hint: Text(
            //   'Select Age Range',
            //   style: TextStyle(fontSize: 16),
            // ),
            value: selectedAgeRange,
            isExpanded: true,
            dropdownColor: Colors.greenAccent,
            items: ageRanges.map((String range) {
              return DropdownMenuItem<String>(
                value: range,
                child: Text(range),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedAgeRange = newValue;
              });
              widget.onAgeRangeSelected(newValue);
            },
          ),
        ),
      ],
    );
  }
}
