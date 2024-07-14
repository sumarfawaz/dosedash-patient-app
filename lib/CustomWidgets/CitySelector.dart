import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Cityselector extends StatefulWidget {
  final Function(String?) onCityselector;

  Cityselector({required this.onCityselector});

  @override
  _CitySelector createState() => _CitySelector();
}

class _CitySelector extends State<Cityselector> {
  String? selectedCity;

  final List<String> cities = [
    '1 Colombo Fort',
    '2 Slave Island',
    '3 Colpetty',
    '4 Bambalapitiya',
    '5 Narahenpita',
    '5 Havelock Town',
    '5 Kirulapona North',
    '6 Wellawatta',
    '6 Pamankada',
    '6 Kirulapona South',
    '7 Cinnamon Garden',
    '8 Borella',
    '9 Dematagoda',
    '10	Maradana',
    '11	Pettah',
    '12	Hulftsdorp',
    '13	Bloemendhal',
    '14	Grandpass',
    '15	Mattakkuliya',
    '15	Modara/Mutwal',
    '15	Madampitiya',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: 'Select your Area *',
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
            value: selectedCity,
            isExpanded: true,
            dropdownColor: Colors.greenAccent,
            items: cities.map((String range) {
              return DropdownMenuItem<String>(
                value: range,
                child: Text(range),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedCity = newValue;
              });
              widget.onCityselector(newValue);
            },
          ),
        ),
      ],
    );
  }
}
