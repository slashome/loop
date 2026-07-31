import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../application/categories_providers.dart';
import '../domain/category.dart';

/// Chip row to pick a category: "None", each existing category (icon + name),
/// and a "+" to create one inline. Shared by the task and recurrence editors.
class CategorySelector extends ConsumerWidget {
  const CategorySelector({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cats = ref.watch(categoriesProvider).value ?? const <Category>[];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ChoiceChip(
          label: Text(l.categoryNone),
          selected: selectedId == null,
          onSelected: (_) => onChanged(null),
        ),
        for (final c in cats)
          ChoiceChip(
            avatar: Icon(c.icon, size: 18),
            label: Text(c.name),
            selected: selectedId == c.id,
            onSelected: (_) => onChanged(c.id),
          ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: Text(l.categoryNewTitle),
          onPressed: () => _createDialog(context, ref),
        ),
      ],
    );
  }

  Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _NewCategoryDialog(),
    );
    if (result == null) return;
    final id =
        await ref.read(categoryRepositoryProvider).create(result.$1, result.$2);
    onChanged(id);
  }
}

/// Dialog to name a new category and pick its icon from the curated set.
class _NewCategoryDialog extends StatefulWidget {
  const _NewCategoryDialog();

  @override
  State<_NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<_NewCategoryDialog> {
  final _name = TextEditingController();
  String _iconKey = kCategoryIcons.keys.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.categoryNewTitle),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(hintText: l.categoryNameHint),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GridView.count(
                crossAxisCount: 5,
                children: [
                  for (final e in kCategoryIcons.entries)
                    IconButton(
                      icon: Icon(e.value),
                      color: _iconKey == e.key ? AppColors.blue : null,
                      isSelected: _iconKey == e.key,
                      style: IconButton.styleFrom(
                        backgroundColor: _iconKey == e.key
                            ? AppColors.blue.withValues(alpha: 0.12)
                            : null,
                      ),
                      onPressed: () => setState(() => _iconKey = e.key),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        TextButton(
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop((name, _iconKey));
          },
          child: Text(l.commonOk),
        ),
      ],
    );
  }
}
