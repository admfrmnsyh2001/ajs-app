import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../create_quotation_provider.dart';

class SummaryStep extends StatelessWidget {
  const SummaryStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateQuotationProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grand Total Highlight Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GRAND TOTAL PENAWARAN',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    CurrencyFormatter.formatRupiah(provider.grandTotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${provider.items.length} Item Pekerjaan',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Calculation Breakdown Settings Form Card
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
                    'Rincian Biaya & Pajak',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Subtotal row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal Item', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      Text(
                        CurrencyFormatter.formatRupiah(provider.subtotal),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Discount Input
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          controller: provider.discountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Diskon (%)',
                            suffixText: '%',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => provider.updateDiscount(val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Potongan Diskon', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            Text(
                              '- ${CurrencyFormatter.formatRupiah(provider.discountAmount)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Tax Checkbox Row (PPN 11%)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: provider.isTaxEnabled ? AppColors.primary.withOpacity(0.05) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: provider.isTaxEnabled ? AppColors.primary.withOpacity(0.3) : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: provider.isTaxEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (val) => provider.toggleTax(val ?? false),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => provider.toggleTax(!provider.isTaxEnabled),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gunakan PPN 11%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Pajak Pertambahan Nilai (PPN 11%)',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Nilai Pajak', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            Text(
                              provider.isTaxEnabled
                                  ? '+ ${CurrencyFormatter.formatRupiah(provider.taxAmount)}'
                                  : 'Rp 0',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: provider.isTaxEnabled ? AppColors.primary : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Additional Notes / Terms Input
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
                    'Catatan / Syarat & Ketentuan (Opsional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: provider.notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Cth: Pembayaran DP 50%, pelunasan setelah pekerjaan selesai 100%.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
