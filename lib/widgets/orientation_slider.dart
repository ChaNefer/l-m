import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/more_about/more_about_view_model.dart';

class OrientationSlider extends StatefulWidget {
  final ValueChanged<double>? onChanged;
  final double initialValue;

  const OrientationSlider(
      {Key? key, this.onChanged, required this.initialValue})
      : super(key: key);

  @override
  _OrientationSliderState createState() => _OrientationSliderState();
}

class _OrientationSliderState extends State<OrientationSlider> {
  double _value = 0.0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
            value: _value,
            onChanged: (newValue) {
              setState(() {
                _value = newValue;
              });
              widget.onChanged?.call(newValue);
              MoreAboutViewModel viewModel =
                  Provider.of<MoreAboutViewModel>(context, listen: false);
              viewModel.setOrientation(newValue);
            },
            min: 0.0,
            max: 100.0,
            divisions: 100,
            label: _getOrientationLabel(_value),
            activeColor: Theme.of(context).colorScheme.secondary,
            inactiveColor: Colors.grey),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bi'),
            Text('Homo'),
          ],
        ),
      ],
    );
  }

  String _getOrientationLabel(double value) {
    if (value < 50) {
      return 'Biseksualna';
    } else if (value >= 25 && value < 75) {
      return 'Biseksualna z większym naciskiem w stronę kobiet';
    } else {
      return 'Zdeklarowana lesbijka';
    }
  }
}
