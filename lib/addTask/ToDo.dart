
class Todo {
  int id;
  String title;
  String description;
  String time;
  String category;
  String days;
  bool isCompleted;

  Todo({required this.id, required this.title, required this.description, required this.time, required this.days, required this.category, required this.isCompleted}) {
    id = this.id;
    title = this.title;
    description = this.description;
    time = this.time;
    category = this.category;
    days = this.days;
    isCompleted = this.isCompleted;
  }

  toJson() {
    return {
      "id": id,
      "description": description,
      "title": title,
      'time': time,
      'category': category,
      "days": days,
      "isCompleted": isCompleted
    };
  }

  fromJson(jsonData) {
    return Todo(
        id: jsonData['id'],
        title: jsonData['title'],
        description: jsonData['description'],
        time: jsonData['time'],
        category: jsonData['category'],
        days: jsonData['days'],
        isCompleted: jsonData['isCompleted']);
  }
}