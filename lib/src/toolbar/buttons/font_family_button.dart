import 'package:flutter/material.dart';

import '../../common/utils/widgets.dart';
import '../../document/attribute.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../base_button/base_value_button.dart';
import '../simple_toolbar.dart';

class QuillToolbarFontFamilyButton
    extends
        QuillToolbarBaseButton<
          QuillToolbarFontFamilyButtonOptions,
          QuillToolbarFontFamilyButtonExtraOptions
        > {
  QuillToolbarFontFamilyButton({
    required super.controller,
    super.options = const QuillToolbarFontFamilyButtonOptions(),
    super.baseOptions,
    super.key,
  }) : assert(options.items?.isNotEmpty ?? true),
       assert(options.initialValue == null || options.initialValue!.isNotEmpty);

  @override
  QuillToolbarFontFamilyButtonState createState() =>
      QuillToolbarFontFamilyButtonState();
}

class QuillToolbarFontFamilyButtonState
    extends
        QuillToolbarBaseButtonState<
          QuillToolbarFontFamilyButton,
          QuillToolbarFontFamilyButtonOptions,
          QuillToolbarFontFamilyButtonExtraOptions,
          String
        > {
  static const _defaultFontValue = 'sans-serif';

  @override
  String get currentStateValue {
    final attribute =
        controller.getSelectionStyle().attributes[options.attribute.key];
    if (attribute == null) {
      return _getKeyName(_defaultFontValue) ?? _defaultDisplayText;
    }
    return _getKeyName(attribute.value.toString()) ??
        attribute.value.toString();
  }

  String get _defaultDisplayText =>
      options.initialValue ??
      widget.options.defaultDisplayText ??
      context.loc.font;

  Map<String, String> get _items {
    final fontFamilies = options.items ??
        {
          'Sans Serif': 'sans-serif',
          'Serif': 'serif',
          'Monospace': 'monospace',
          'Ibarra Real Nova': 'ibarra-real-nova',
          'SquarePeg': 'square-peg',
          'Nunito': 'nunito',
          'Pacifico': 'pacifico',
          'Roboto Mono': 'roboto-mono',
        };

    // Font family is always defined implicitly or explicitly, so don't offer
    // a Clear command even if a custom item list still contains one.
    return Map.fromEntries(
      fontFamilies.entries.where((entry) {
        return entry.key.toLowerCase() != 'clear' &&
            entry.value.toLowerCase() != 'clear';
      }),
    );
  }

  String? _getKeyName(String value) {
    for (final entry in _items.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  String get defaultTooltip => context.loc.fontFamily;

  @override
  IconData get defaultIconData => Icons.font_download_outlined;

  void _onPressed() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
    afterButtonPressed?.call();
  }

  final _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final childBuilder = this.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarFontFamilyButtonExtraOptions(
          currentValue: currentValue,
          defaultDisplayText: _defaultDisplayText,
          controller: controller,
          context: context,
          onPressed: _onPressed,
        ),
      );
    }

    return UtilityWidgets.maybeWidget(
      enabled: tooltip.isNotEmpty || options.overrideTooltipByFontFamily,
      wrapper: (child) {
        var effectiveTooltip = tooltip;
        if (options.overrideTooltipByFontFamily) {
          effectiveTooltip = effectiveTooltip.isNotEmpty
              ? '$effectiveTooltip: $currentValue'
              : '${context.loc.font}: $currentValue';
        }
        return Tooltip(message: effectiveTooltip, child: child);
      },
      child: MenuAnchor(
        controller: _menuController,
        menuChildren: [
          for (final fontFamily in _items.entries)
            MenuItemButton(
              key: ValueKey(fontFamily.key),
              onPressed: () {
                setState(() {
                  currentValue = fontFamily.key;
                  controller.formatSelection(
                    Attribute.fromKeyValue(
                      Attribute.font.key,
                      fontFamily.value,
                    ),
                  );
                  options.onSelected?.call(fontFamily.value);
                });
              },
              child: Text(
                fontFamily.key,
                style: TextStyle(
                  fontFamily: options.renderFontFamilies
                      ? fontFamily.value
                      : null,
                ),
              ),
            ),
        ],
        child: Builder(
          builder: (context) {
            final isMaterial3 = Theme.of(context).useMaterial3;
            if (!isMaterial3) {
              return RawMaterialButton(
                onPressed: _onPressed,
                child: _buildContent(context),
              );
            }
            return QuillToolbarIconButton(
              isSelected: false,
              iconTheme: iconTheme,
              onPressed: _onPressed,
              icon: _buildContent(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final hasFinalWidth = options.width != null;
    return Padding(
      padding: options.padding ?? const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        mainAxisSize: !hasFinalWidth ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UtilityWidgets.maybeWidget(
            enabled: hasFinalWidth,
            wrapper: (child) => Expanded(child: child),
            child: Text(
              currentValue,
              maxLines: 1,
              overflow: options.labelOverflow,
              style: options.style ?? TextStyle(fontSize: iconSize / 1.15),
            ),
          ),
          Icon(Icons.arrow_drop_down, size: iconSize * iconButtonFactor),
        ],
      ),
    );
  }
}
