class SharedExpense {
  const SharedExpense({
    required this.id,
    required this.title,
    required this.membersEmail,
  });

  final String id;
  final String title;
  final List<dynamic> membersEmail;
}
