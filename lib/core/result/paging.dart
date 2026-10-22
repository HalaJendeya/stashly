/// One page of a cursor-paginated list.
class Paged<T> {
  const Paged({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    this.total,
  });

  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  /// Total matches; the API only sends it on the first page.
  final int? total;
}

/// A value to send in a partial update; `FieldUpdate(null)` clears the field
/// while an absent `FieldUpdate` leaves it unchanged.
class FieldUpdate<T> {
  const FieldUpdate(this.value);

  final T? value;
}
