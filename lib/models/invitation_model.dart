class Invitation {
  const Invitation({
    required this.invitationId,
    required this.sharedExpenseId,
    required this.senderUid,
    required this.senderUsername,
    required this.sharedExpenseTitle,
  });

  final String sharedExpenseId;
  final String invitationId;
  final String senderUid;
  final String senderUsername;
  final String sharedExpenseTitle;
  // final List<String> recipientEmail;
}
