class AppStrings {
  static const String appName = 'Penawaran Ku';
  static const String companyDefaultName = 'CV. JASA KONTRAKTOR UTAMA';
  static const String companyDefaultAddress = 'Jl. Raya Industri No. 88, Jakarta';
  static const String companyDefaultPhone = '0812-3456-7890';
  static const String companyDefaultEmail = 'info@jasakontraktor.com';

  // Common units for contractors & service providers
  static const List<String> availableUnits = [
    'm²',
    'm³',
    'meter',
    'unit',
    'ls',
    'pkt',
    'titik',
    'pcs',
    'set',
    'jam',
    'hari'
  ];

  // Quotation Status
  static const String statusDraft = 'draft';
  static const String statusSent = 'sent';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
}
