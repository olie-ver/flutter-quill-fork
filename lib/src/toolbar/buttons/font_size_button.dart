import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/utils/font.dart';
import '../../document/attribute.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/base_value_button.dart';
import '../simple_toolbar.dart';

class QuillToolbarFontSizeButton
    extends
        QuillToolbarBaseButton<
          QuillToolbarFontSizeButtonOptions,
          QuillToolbarFontSizeButtonExtraOptions
        > {
  QuillToolbarFontSizeButton({
    required super.controller,
    super.options = const QuillToolbarFontSizeButtonOptions(),
    super.baseOptions,
    super.key,
  }) : assert(options.initialValue == null ||
           options.initialValue!.isNotEmpty);

  @override
  QuillToolbarFontSizeButtonState createState() =>
      QuillToolbarFontSizeButtonState();
}

class QuillToolbarFontSizeButtonState
    extends
        QuillToolbarBaseButtonState<
          QuillToolbarFontSizeButton,
          QuillToolbarFontSizeButtonOptions,
          QuillToolbarFontSizeButtonExtraOptions,
          String
        >
{

  final TextEditingController _sizeTextController = TextEditingController();
  final FocusNode _sizeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _sizeTextController.text = currentStateValue;
    _sizeFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _sizeFocusNode.removeListener(_handleFocusChange);
    _sizeFocusNode.dispose();
    _sizeTextController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_sizeFocusNode.hasFocus) {
      _applySize();
    } else {
      //select the entire text field's contents
    }
  }
  

  String get _defaultDisplayText =>
      options.initialValue ??
      widget.options.defaultDisplayText ??
      '12';

  @override
  String get currentStateValue {
    final attribute =
        controller.getSelectionStyle().attributes[options.attribute.key];
    if (attribute == null) {
      return _defaultDisplayText;
    }

    final value = attribute.value.toString();
    return getFontSize(value).toString();
  }

  @override
  String get defaultTooltip => context.loc.fontSize;

  @override
  IconData get defaultIconData => Icons.format_size_outlined;

  void _applySize() {
    final value = _sizeTextController.text.trim();

    // Accept whole numbers or numbers with at most one decimal place.
    if (!RegExp(r'^\d+(\.\d)?$').hasMatch(value)) {
      _resetSizeField();
      return;
    }

    final parsed = double.tryParse(value);
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      _resetSizeField();
      return;
    }

    // Avoid applying the same size repeatedly.
    if (value == currentStateValue) {
      return;
    }

    final formattedSize = getFontSize(value);

    controller.formatSelection(
      Attribute.fromKeyValue(Attribute.size.key, formattedSize),
    );

    setState(() {
      currentValue = formattedSize.toString();
    });

    options.onSelected?.call(value);
  }

  void _resetSizeField() {
    _sizeTextController.text = currentStateValue;
    _sizeTextController.selection = TextSelection.collapsed(
      offset: _sizeTextController.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder = this.childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarFontSizeButtonExtraOptions(
          controller: controller,
          currentValue: currentValue,
          defaultDisplayText: _defaultDisplayText,
          context: context,
          onPressed: _applySize,
        ),
      );
    }

    // Keep the field synchronized with the selected text's font size,
    // but don't overwrite what the user is currently typing.
    if (!_sizeFocusNode.hasFocus &&
        _sizeTextController.text != currentStateValue) {
      _sizeTextController.text = currentStateValue;
      _sizeTextController.selection = TextSelection.collapsed(
        offset: _sizeTextController.text.length,
      );
    }

    return SizedBox(
      width: options.width ?? 58,
      height: kToolbarHeight,
      child: Padding(
        padding: options.padding ??
            const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: TextField(
            controller: _sizeTextController,
            focusNode: _sizeFocusNode,
            textAlign: TextAlign.center,
            style: options.style ??
                TextStyle(fontSize: iconSize / 1.15),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                // Permit intermediate input such as "14." while typing.
                if (RegExp(r'^\d*\.?\d{0,1}$')
                    .hasMatch(newValue.text)) {
                  return newValue;
                }

                return oldValue;
              }),
            ],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 8,
              ),
              border: InputBorder.none,
            ),
            onSubmitted: (_) {
              _applySize();
              _sizeFocusNode.unfocus();
            },
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';

// import '../../common/utils/font.dart';
// import '../../common/utils/widgets.dart';
// import '../../document/attribute.dart';
// import '../../l10n/extensions/localizations_ext.dart';
// import '../base_button/base_value_button.dart';
// import '../simple_toolbar.dart';

// //TODO: make this take a decimal (rounded to 1 place X.x)

// class QuillToolbarFontSizeButton
//     extends
//         QuillToolbarBaseButton<
//           QuillToolbarFontSizeButtonOptions,
//           QuillToolbarFontSizeButtonExtraOptions
//         > {
//   QuillToolbarFontSizeButton({
//     required super.controller,
//     super.options = const QuillToolbarFontSizeButtonOptions(),

//     /// Shares common options between all buttons, prefer the [options]
//     /// over the [baseOptions].
//     super.baseOptions,
//     super.key,
//   }) : assert(options.items?.isNotEmpty ?? true),
//        assert(
//          options.initialValue == null ||
//              (options.initialValue?.isNotEmpty ?? true),
//        );

//   @override
//   QuillToolbarFontSizeButtonState createState() =>
//       QuillToolbarFontSizeButtonState();
// }

// class QuillToolbarFontSizeButtonState
//     extends
//         QuillToolbarBaseButtonState<
//           QuillToolbarFontSizeButton,
//           QuillToolbarFontSizeButtonOptions,
//           QuillToolbarFontSizeButtonExtraOptions,
//           String
//         > {
//   final _menuController = MenuController();

//   Map<String, String> get _items {
//     final fontSizes =
//         options.items ??
//         {
//           context.loc.small: 'small',
//           context.loc.large: 'large',
//           context.loc.huge: 'huge',
//           context.loc.clear: '0',
//         };
//     return fontSizes;
//   }

//   String? getLabel(String? currentValue) {
//     return switch (currentValue) {
//       'small' => context.loc.small,
//       'large' => context.loc.large,
//       'huge' => context.loc.huge,
//       String() => currentValue,
//       null => null,
//     };
//   }

//   String get _defaultDisplayText {
//     return options.initialValue ??
//         widget.options.defaultDisplayText ??
//         context.loc.fontSize;
//   }

//   @override
//   String get currentStateValue {
//     final attribute = controller
//         .getSelectionStyle()
//         .attributes[options.attribute.key];
//     return attribute == null
//         ? _defaultDisplayText
//         : (_getKeyName(attribute.value) ?? _defaultDisplayText);
//   }

//   String? _getKeyName(dynamic value) {
//     for (final entry in _items.entries) {
//       if (getFontSize(entry.value) == getFontSize(value)) {
//         return entry.key;
//       }
//     }
//     return null;
//   }

//   @override
//   String get defaultTooltip => context.loc.fontSize;

//   @override
//   IconData get defaultIconData => Icons.format_size_outlined;

//   void _onDropdownButtonPressed() {
//     if (_menuController.isOpen) {
//       _menuController.close();
//     } else {
//       _menuController.open();
//     }
//     afterButtonPressed?.call();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final childBuilder = this.childBuilder;
//     if (childBuilder != null) {
//       return childBuilder(
//         options,
//         QuillToolbarFontSizeButtonExtraOptions(
//           controller: controller,
//           currentValue: currentValue,
//           defaultDisplayText: _defaultDisplayText,
//           context: context,
//           onPressed: _onDropdownButtonPressed,
//         ),
//       );
//     }
//     return MenuAnchor(
//       controller: _menuController,
//       menuChildren: _items.entries.map((fontSize) {
//         return MenuItemButton(
//           key: ValueKey(fontSize.key),
//           onPressed: () {
//             final newValue = fontSize.value;

//             final keyName = _getKeyName(newValue);
//             setState(() {
//               if (keyName != context.loc.clear) {
//                 currentValue = keyName ?? _defaultDisplayText;
//               } else {
//                 currentValue = _defaultDisplayText;
//               }
//               if (keyName != null) {
//                 controller.formatSelection(
//                   Attribute.fromKeyValue(
//                     Attribute.size.key,
//                     newValue == '0' ? null : getFontSize(newValue),
//                   ),
//                 );
//                 options.onSelected?.call(newValue);
//               }
//             });
//           },
//           child: Text(
//             fontSize.key.toString(),
//             style: TextStyle(
//               color: fontSize.value == '0' ? options.defaultItemColor : null,
//             ),
//           ),
//         );
//       }).toList(),
//       child: Builder(
//         builder: (context) {
//           final isMaterial3 = Theme.of(context).useMaterial3;
//           if (!isMaterial3) {
//             return RawMaterialButton(
//               onPressed: _onDropdownButtonPressed,
//               child: _buildContent(context),
//             );
//           }
//           return QuillToolbarIconButton(
//             tooltip: tooltip,
//             isSelected: false,
//             iconTheme: iconTheme,
//             onPressed: _onDropdownButtonPressed,
//             icon: _buildContent(context),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildContent(BuildContext context) {
//     final hasFinalWidth = options.width != null;
//     return Padding(
//       padding: options.padding ?? const EdgeInsets.fromLTRB(10, 0, 0, 0),
//       child: Row(
//         mainAxisSize: !hasFinalWidth ? MainAxisSize.min : MainAxisSize.max,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           UtilityWidgets.maybeWidget(
//             enabled: hasFinalWidth,
//             wrapper: (child) => Expanded(child: child),
//             child: Text(
//               getLabel(currentValue) ?? '',
//               overflow: options.labelOverflow,
//               style: options.style ?? TextStyle(fontSize: iconSize / 1.15),
//             ),
//           ),
//           Icon(Icons.arrow_drop_down, size: iconSize * iconButtonFactor),
//         ],
//       ),
//     );
//   }
// }
