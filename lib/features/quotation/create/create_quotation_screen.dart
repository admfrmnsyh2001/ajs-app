import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/pdf_generator.dart';
import '../../../../data/models/client_model.dart';
import '../../../../data/models/quotation_model.dart';
import 'create_quotation_provider.dart';
import 'widgets/client_step.dart';
import 'widgets/items_step.dart';
import 'widgets/summary_step.dart';

class CreateQuotationScreen extends StatefulWidget {
  final QuotationModel? quotationToEdit;

  const CreateQuotationScreen({super.key, this.quotationToEdit});

  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CreateQuotationProvider>();
      if (widget.quotationToEdit != null) {
        provider.loadQuotationForEdit(widget.quotationToEdit!);
      } else {
        provider.initNewQuotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateQuotationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.quotationToEdit != null ? 'Edit Penawaran' : 'Buat Penawaran Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Step Progress Indicator
                _buildStepHeader(provider),
                const Divider(height: 1),

                // Step Content View
                Expanded(
                  child: IndexedStack(
                    index: provider.currentStep,
                    children: [
                      const ClientStep(),
                      const ItemsStep(),
                      const SummaryStep(),
                      _buildPdfPreviewStep(context, provider),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: provider.isLoading ? null : _buildBottomActions(context, provider),
    );
  }

  Widget _buildStepHeader(CreateQuotationProvider provider) {
    final steps = ['Klien', 'Item', 'Ringkasan', 'Preview'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == provider.currentStep;
          final isCompleted = index < provider.currentStep;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (index < provider.currentStep) {
                  provider.setStep(index);
                }
              },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: isCompleted
                              ? AppColors.statusApproved
                              : (isActive ? AppColors.primary : Colors.grey[300]),
                          child: isCompleted
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isActive ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          steps[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
                            color: isActive ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < steps.length - 1)
                    Container(
                      width: 16,
                      height: 2,
                      color: isCompleted ? AppColors.statusApproved : Colors.grey[300],
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPdfPreviewStep(BuildContext context, CreateQuotationProvider provider) {
    final client = provider.selectedClient ??
        ClientModel(
          name: provider.clientNameController.text.trim().isNotEmpty
              ? provider.clientNameController.text.trim()
              : 'Nama Klien',
          phone: provider.clientPhoneController.text.trim(),
          address: provider.clientAddressController.text.trim(),
          email: provider.clientEmailController.text.trim().isNotEmpty
              ? provider.clientEmailController.text.trim()
              : null,
        );

    final quotation = QuotationModel(
      id: provider.existingQuotationId,
      quotationNumber: provider.quotationNumber,
      client: client,
      items: provider.items,
      discountPercent: provider.discountPercent,
      taxPercent: provider.taxPercent,
      notes: provider.notesController.text.trim().isNotEmpty
          ? provider.notesController.text.trim()
          : null,
    );

    return Container(
      color: Colors.grey[200],
      child: PdfPreview(
        build: (format) => PdfGenerator.generateQuotationPdf(quotation),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        maxPageWidth: 700,
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, CreateQuotationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (provider.currentStep > 0)
            Expanded(
              flex: 4,
              child: OutlinedButton(
                onPressed: () => provider.previousStep(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Kembali'),
              ),
            ),
          if (provider.currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: ElevatedButton(
              onPressed: () => _handleNextOrSave(context, provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                provider.currentStep == 3 ? 'Simpan Penawaran' : 'Lanjut',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextOrSave(BuildContext context, CreateQuotationProvider provider) async {
    if (provider.currentStep == 0) {
      if (provider.clientNameController.text.trim().isEmpty) {
        _showSnackBar(context, 'Silakan isi Nama Klien / Perusahaan');
        return;
      }
      if (provider.clientPhoneController.text.trim().isEmpty) {
        _showSnackBar(context, 'Silakan isi No. Telepon Klien');
        return;
      }
      if (provider.clientAddressController.text.trim().isEmpty) {
        _showSnackBar(context, 'Silakan isi Alamat Klien');
        return;
      }
      provider.nextStep();
    } else if (provider.currentStep == 1) {
      if (provider.items.isEmpty) {
        _showSnackBar(context, 'Tambahkan minimal 1 item pekerjaan');
        return;
      }
      provider.nextStep();
    } else if (provider.currentStep == 2) {
      provider.nextStep();
    } else if (provider.currentStep == 3) {
      final result = await provider.saveQuotation();
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penawaran berhasil disimpan!'),
            backgroundColor: AppColors.statusApproved,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        _showSnackBar(context, 'Gagal menyimpan penawaran. Periksa kelengkapan data.');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
