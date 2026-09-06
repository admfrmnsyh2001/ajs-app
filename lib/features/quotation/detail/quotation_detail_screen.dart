import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../data/models/quotation_model.dart';
import '../../../data/repositories/quotation_repository.dart';

class QuotationDetailScreen extends StatefulWidget {
  final int quotationId;

  const QuotationDetailScreen({super.key, required this.quotationId});

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen> {
  final QuotationRepository _repo = QuotationRepository();
  QuotationModel? _quotation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotationDetail();
  }

  Future<void> _loadQuotationDetail() async {
    setState(() => _isLoading = true);
    final data = await _repo.getQuotation(widget.quotationId);
    setState(() {
      _quotation = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Penawaran'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quotation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Penawaran'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: const Center(child: Text('Penawaran tidak ditemukan.')),
      );
    }

    final q = _quotation!;

    return Scaffold(
      appBar: AppBar(
        title: Text(q.quotationNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () => PdfGenerator.printOrSharePdf(q),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Penawaran',
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.createQuotation,
                arguments: q,
              );
              if (result == true) {
                _loadQuotationDetail();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tujuan Penawaran / Klien',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      q.client.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text('No. Telp: ${q.client.phone}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('Alamat: ${q.client.address}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    if (q.client.email != null && q.client.email!.isNotEmpty)
                      Text('Email: ${q.client.email}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text(
                      'Dibuat pada: ${CurrencyFormatter.formatDate(q.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items Table Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian Pekerjaan (${q.items.length} Item)',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: q.items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = q.items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${index + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${CurrencyFormatter.formatNumber(item.qty)} ${item.unit} x ${CurrencyFormatter.formatRupiah(item.unitPrice)}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatRupiah(item.total),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Calculation Breakdown Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildCalculationRow('Subtotal Pekerjaan', CurrencyFormatter.formatRupiah(q.subtotal)),
                    if (q.discountPercent > 0)
                      _buildCalculationRow(
                        'Diskon (${CurrencyFormatter.formatNumber(q.discountPercent)}%)',
                        '- ${CurrencyFormatter.formatRupiah(q.discountAmount)}',
                        isNegative: true,
                      ),
                    if (q.taxPercent > 0)
                      _buildCalculationRow(
                        'PPN (${CurrencyFormatter.formatNumber(q.taxPercent)}%)',
                        '+ ${CurrencyFormatter.formatRupiah(q.taxAmount)}',
                      ),
                    const Divider(height: 20),
                    _buildCalculationRow(
                      'GRAND TOTAL',
                      CurrencyFormatter.formatRupiah(q.grandTotal),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes Card
            if (q.notes != null && q.notes!.isNotEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Catatan / Ketentuan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(q.notes!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Main Action Buttons (Export PDF & Print)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => PdfGenerator.printOrSharePdf(q),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Cetak / Export PDF Penawaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus Penawaran'),
                      content: const Text('Apakah Anda yakin ingin menghapus dokumen penawaran ini?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && q.id != null) {
                    await _repo.deleteQuotation(q.id!);
                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  }
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Hapus Penawaran', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, {bool isNegative = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal
                  ? AppColors.primary
                  : (isNegative ? Colors.red : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
