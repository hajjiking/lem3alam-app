class TaskOffer {
  const TaskOffer(
      {required this.id,
      required this.taskId,
      required this.taskerId,
      required this.taskerName,
      required this.proposal,
      required this.status,
      this.budget,
      this.duration = '',
      this.verified = false});

  final int id;
  final int taskId;
  final int taskerId;
  final String taskerName;
  final String proposal;
  final String status;
  final double? budget;
  final String duration;
  final bool verified;

  factory TaskOffer.fromJson(Map<String, dynamic> json) {
    final tasker = json['tasker'] is Map ? json['tasker'] as Map : const {};
    final budget = double.tryParse('${json['proposed_budget']}');
    return TaskOffer(
      id: int.tryParse('${json['id']}') ?? 0,
      taskId: int.tryParse('${json['task_id']}') ?? 0,
      taskerId: int.tryParse('${json['tasker_id']}') ?? 0,
      taskerName: (tasker['name'] ?? '').toString(),
      proposal: (json['proposal'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      budget: budget != null && budget.isFinite ? budget : null,
      duration: (json['estimated_duration'] ?? '').toString(),
      verified: tasker['is_verified'] == true || tasker['is_verified'] == 1,
    );
  }
}
