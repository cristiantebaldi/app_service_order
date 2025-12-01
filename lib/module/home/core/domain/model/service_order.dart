class ServiceOrder {
  int ?id;
  String responsible;
  String task;
  String description;
  String status;
  int active;
  int excluded;
  DateTime startPrevison;
  DateTime endPrevison;
  DateTime ?createdDate;
  DateTime updatedDate;

  ServiceOrder({
    this.id,
    required this.responsible,
    required this.task,
    required this.description,
    required this.status,
    required this.active,
    required this.excluded,
    required this.startPrevison,
    required this.endPrevison,
    this.createdDate,
    required this.updatedDate,
  });

  factory ServiceOrder.fromMap(Map<String, dynamic> m) {
    parseInt(dynamic v) => v is int ? v : int.tryParse('$v');
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      final int value = v is int ? v : int.tryParse('$v') ?? 0;
      if (value == 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return ServiceOrder(
      id: parseInt(m['id']),
      responsible: (m['responsible'] ?? '') as String,
      task: (m['task'] ?? '') as String,
      description: (m['description'] ?? '') as String,
      status: (m['status'] ?? '') as String,
      active: m['active'],
      excluded: m['excluded'],
      startPrevison: parseDate(m['start_prevision']) ?? DateTime.now(),
      endPrevison: parseDate(m['end_prevision']) ?? DateTime.now(),
      createdDate: parseDate(m['created_date']),
      updatedDate: parseDate(m['updated_date']) ?? DateTime.now(),
    );
  }
}