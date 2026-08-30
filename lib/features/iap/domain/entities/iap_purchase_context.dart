class IapPurchaseContext {
  final String beneficiaryPatId;
  final String beneficiaryLabel;
  final bool isFamilyBeneficiary;

  const IapPurchaseContext({
    required this.beneficiaryPatId,
    required this.beneficiaryLabel,
    this.isFamilyBeneficiary = false,
  });
}
