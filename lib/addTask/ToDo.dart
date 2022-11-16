
class Todo {
  int id;
  String title;
  String description;
  String time;
  String category;
  String days;
  String date1;
  String date2;
  bool isCompleted;

  Todo({required this.id, required this.title, required this.description, required this.time, required this.days, required this.date1, required this.date2, required this.category, required this.isCompleted}) {
    id = this.id;
    title = this.title;
    description = this.description;
    time = this.time;
    category = this.category;
    days = this.days;
    date1 = this.date1;
    date2 = this.date2;
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
      "date1": date1,
      "date2": date2,
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
        date1: jsonData['date1'],
        date2: jsonData['date2'],
        isCompleted: jsonData['isCompleted']);
  }
}