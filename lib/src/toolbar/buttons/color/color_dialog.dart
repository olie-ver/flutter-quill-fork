import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    as color_picker
    show ColorPicker, colorToHex;

import '../../../document/style.dart';
import '../../../editor_toolbar_shared/color.dart';
import '../../../l10n/extensions/localizations_ext.dart';

enum _PickerType { material, color }

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({
    required this.isBackground,
    required this.onRequestChangeColor,
    required this.isToggledColor,
    required this.selectionStyle,
    super.key,
  });

  final bool isBackground;
  final bool isToggledColor;
  final Function(BuildContext context, Color? color) onRequestChangeColor;
  final Style selectionStyle;

  @override
  State<ColorPickerDialog> createState() => ColorPickerDialogState();
}

class ColorPickerDialogState extends State<ColorPickerDialog> {
  var pickerType = _PickerType.material;
  var selectedColor = Colors.black;

  late final TextEditingController hexController;

  static const _materialShades = <int>[200, 300, 400, 500, 600, 700, 800, 900];

  MaterialColor createMaterialColor(Color color) {
    final List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.toARGB32(), swatch);
  }

  List<List<Color>> get _materialColorColumns {
    final columns = <List<Color>>[
      [
        Colors.white,
        Colors.grey.shade200,
        Colors.grey.shade300,
        Colors.grey.shade400,
        Colors.grey.shade500,
        Colors.grey.shade600,
        Colors.grey.shade700,
        Colors.black,
      ],
    ];

    final families = <ColorSwatch<int>>[
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      createMaterialColor(const Color.fromRGBO(255, 0, 255, 255))
    ];

    for (final family in families) {
      final shades = <Color>[];

      for (final shade in _materialShades) {
        final color = family[shade];
        if (color != null) {
          shades.add(color);
        }
      }

      if (shades.isNotEmpty) {
        columns.add(shades);
      }
    }

    return columns;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isToggledColor) {
      selectedColor = widget.isBackground
          ? hexToColor(widget.selectionStyle.attributes['background']?.value)
          : hexToColor(widget.selectionStyle.attributes['color']?.value);
    }
    hexController = TextEditingController(
      text: color_picker.colorToHex(selectedColor),
    );
  }

  @override
  void dispose() {
    hexController.dispose();
    super.dispose();
  }

  void _selectColor(Color color) {
    setState(() {
      selectedColor = color;
      hexController.text = color_picker.colorToHex(color);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.loc.selectColor),
      actions: [
        TextButton(
          onPressed: () {
            widget.onRequestChangeColor(context, selectedColor);
            Navigator.of(context).pop();
          },
          child: Text(context.loc.ok),
        ),
      ],
      backgroundColor: Theme.of(context).canvasColor,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => pickerType = _PickerType.material);
                  },
                  child: Text(context.loc.material),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => pickerType = _PickerType.color);
                  },
                  child: Text(context.loc.color),
                ),
                TextButton(
                  onPressed: () {
                    widget.onRequestChangeColor(context, null);
                    Navigator.of(context).pop();
                  },
                  child: Text(context.loc.clear),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (pickerType == _PickerType.material)
              SizedBox(
                width: 260,
                height: 260,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final column in _materialColorColumns)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            children: [
                              for (final color in column)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: Tooltip(
                                      message: color_picker.colorToHex(color),
                                      child: InkWell(
                                        // onTap: () => _selectColor(color), //When this is tapped it should select the color and then close the dialog
                                        onTap: () {
                                          _selectColor(color);
                                          widget.onRequestChangeColor(context, selectedColor);
                                          Navigator.of(context).pop();
                                        },
                                        customBorder: const CircleBorder(),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: color.toARGB32() ==
                                                      selectedColor.toARGB32()
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                  : Colors.black26,
                                              width: color.toARGB32() ==
                                                      selectedColor.toARGB32()
                                                  ? 2.5
                                                  : 0.8,
                                            ),
                                          ),
                                          child: color.toARGB32() ==
                                                  selectedColor.toARGB32()
                                              ? Icon(
                                                  Icons.check,
                                                  size: 15,
                                                  color: color.computeLuminance() > 0.5
                                                      ? Colors.black
                                                      : Colors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (pickerType == _PickerType.color)
              color_picker.ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    selectedColor = color;
                    hexController.text = color_picker.colorToHex(color);
                  });
                },
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 60,
                  child: TextFormField(
                    controller: hexController,
                    onChanged: (value) {
                      setState(() => selectedColor = hexToColor(value));
                    },
                    decoration: InputDecoration(
                      labelText: context.loc.hex,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

