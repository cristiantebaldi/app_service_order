class ServiceOrder {
  int id;
  String responsible;
  String task;
  String status;
  bool active;
  bool excluded;
  DateTime startPrevison;
  DateTime endPrevison;
  DateTime createdDate;
  DateTime updatedDate;

  ServiceOrder({
    required this.id,
    required this.responsible,
    required this.task,
    required this.status,
    required this.active,
    required this.excluded,
    required this.startPrevison,
    required this.endPrevison,
    required this.createdDate,
    required this.updatedDate,
  });
}