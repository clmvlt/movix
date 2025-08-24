import 'package:flutter/material.dart';
import 'package:movix/Services/globals.dart';

class ModernTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final int? maxLines;
  final bool enabled;

  const ModernTextFieldWidget({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          labelStyle: TextStyle(color: Globals.COLOR_TEXT_DARK.withOpacity(0.7)),
          hintStyle: TextStyle(color: Globals.COLOR_TEXT_DARK.withOpacity(0.5)),
        ),
        style: TextStyle(color: Globals.COLOR_TEXT_DARK),
      ),
    );
  }
}

class ModernDropdownWidget<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const ModernDropdownWidget({
    super.key,
    this.value,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Globals.COLOR_TEXT_DARK.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          labelStyle: TextStyle(color: Globals.COLOR_TEXT_DARK.withOpacity(0.7)),
        ),
        value: value,
        isExpanded: true,
        onChanged: enabled ? onChanged : null,
        items: items.entries.map((entry) {
          return DropdownMenuItem<T>(
            value: entry.key,
            child: Text(
              entry.value,
              style: TextStyle(color: Globals.COLOR_TEXT_DARK),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ModernCheckboxWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String title;
  final String? subtitle;
  final bool enabled;

  const ModernCheckboxWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Globals.COLOR_SURFACE_SECONDARY.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: enabled ? onChanged : null,
        title: Text(
          title,
          style: TextStyle(
            color: Globals.COLOR_TEXT_DARK,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  color: Globals.COLOR_TEXT_GRAY,
                  fontSize: 12,
                ),
              )
            : null,
        activeColor: Globals.COLOR_MOVIX,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}