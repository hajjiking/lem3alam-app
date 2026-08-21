import 'package:flutter_test/flutter_test.dart';
import 'package:lem3alam_mobile/src/features/tasks/domain/task.dart';
import 'package:lem3alam_mobile/src/features/tasks/presentation/task_image_support.dart';

void main() {
  test('parses primary image url from task payload', () {
    final task = Task.fromJson({
      'id': 19,
      'title': 'Test task',
      'description': 'Has a photo',
      'category_id': 46,
      'city': 'Fes',
      'budget_min': '100.00',
      'budget_max': '250.00',
      'budget_type': 'fixed',
      'urgency': 'medium',
      'status': 'open',
      'images': ['task_images/example.jpg'],
      'primary_image_url': '/storage/task_images/example.jpg',
    });

    expect(task.primaryImageUrl, '/storage/task_images/example.jpg');
    expect(task.primaryImageSource, '/storage/task_images/example.jpg');
  });

  test('resolves raw storage paths against public base url', () {
    expect(
      resolveTaskImageUrl('task_images/example.jpg'),
      'https://lem3alam.ma/storage/task_images/example.jpg',
    );
  });

  test('preserves storage-prefixed relative paths without duplicating storage segment', () {
    expect(
      resolveTaskImageUrl('/storage/task_images/example.jpg'),
      'https://lem3alam.ma/storage/task_images/example.jpg',
    );
  });

  test('preserves absolute image urls', () {
    expect(
      resolveTaskImageUrl('https://cdn.example.com/tasks/example.jpg'),
      'https://cdn.example.com/tasks/example.jpg',
    );
  });
}
