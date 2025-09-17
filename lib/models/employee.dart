class Employee {
  final String name;
  final String status; // "online", "offline", "paused"
  final String lastActive; // could be DateTime but here using String for simplicity
  final String avatar; // image url

  Employee({
    required this.name,
    required this.status,
    required this.lastActive,
    required this.avatar,
  });
}
