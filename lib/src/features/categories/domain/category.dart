/// A task category (per profile). Carries a shape (icon), not a color — the
/// badge is tinted by the task's priority. Pure model.
library;

import 'package:flutter/material.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconKey,
  });

  final String id;
  final String name;

  /// Key into [kCategoryIcons]. Falls back to [kFallbackCategoryIcon] if
  /// unknown (e.g. a future icon not in this build).
  final String iconKey;

  IconData get icon => kCategoryIcons[iconKey] ?? kFallbackCategoryIcon;
}

/// Icon shown for a task that has no category (a discreet dot).
const IconData kUncategorizedIcon = Icons.circle;

/// Fallback when a stored iconKey isn't recognized.
const IconData kFallbackCategoryIcon = Icons.label_outline;

/// Curated set of category icons. Keys are stable identifiers stored in the DB;
/// the const IconData values keep icon tree-shaking working.
const Map<String, IconData> kCategoryIcons = {
  'work': Icons.work_outline,
  'home': Icons.home_outlined,
  'health': Icons.favorite_outline,
  'shopping': Icons.shopping_bag_outlined,
  'sport': Icons.fitness_center,
  'money': Icons.savings_outlined,
  'music': Icons.music_note_outlined,
  'study': Icons.school_outlined,
  'travel': Icons.flight_outlined,
  'food': Icons.restaurant_outlined,
  'idea': Icons.lightbulb_outline,
  'call': Icons.call_outlined,
  'pet': Icons.pets,
  'car': Icons.directions_car_outlined,
  'gift': Icons.card_giftcard,
  'star': Icons.star_outline,
  'code': Icons.code,
  'game': Icons.sports_esports_outlined,
  'doc': Icons.description_outlined,
  'clean': Icons.cleaning_services_outlined,
};
