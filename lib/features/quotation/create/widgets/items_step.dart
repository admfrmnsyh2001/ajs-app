import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../create_quotation_provider.dart';

class ItemsStep extends StatelessWidget {
  const ItemsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreateQuotationProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Input Item Baru / Edit
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.editingItemIndex != null
                            ? 'Edit Item Pekerjaan'
                            : 'Tambah Item Pekerjaan',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (provider.editingItemIndex != null)
                        TextButton(
                          onPressed: () => provider.clearItemForm(),
                          child: const Text('Batal Edit'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.itemDescController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi / Uraian Pekerjaan *',
                      hintText: 'Cth: Pekerjaan Pengecatan Dinding Tembok',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Satuan Field (Preset Dropdown + Manual Input)
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: provider.itemUnitController,
                          decoration: InputDecoration(
                            labelText: 'Satuan *',
                            hintText: 'm², unit...',
                            border: const OutlineInputBorder(),
                            suffixIcon: PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              tooltip: 'Pilih Satuan Standar',
                              onSelected: (unit) {
                                provider.setSelectedUnit(unit);
                              },
                              itemBuilder: (context) => AppStrings.availableUnits.map((unit) {
                                return PopupMenuItem<String>(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Volume / Qty
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: provider.itemQtyController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Volume / Qty *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: provider.itemPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Harga Satuan (Rp) *',
                      hintText: 'Cth: 150000',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.addOrUpdateItem();
                      },
                      icon: Icon(
                        provider.editingItemIndex != null
                            ? Icons.check
                            : Icons.add_circle_outline,
                      ),
                      label: Text(
                        provider.editingItemIndex != null
                            ? 'Simpan Perubahan Item'
                            : 'Tambah ke List Pekerjaan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Items List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Item Pekerjaan (${provider.items.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Subtotal: ${CurrencyFormatter.formatRupiah(provider.subtotal)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (provider.items.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Column(
                children: [
                  Icon(Icons.format_list_bulleted_add, size: 48, color: AppColors.textMuted),
                  SizedBox(height: 8),
                  Text(
                    'Belum ada item pekerjaan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gunakan form di atas untuk menambahkan item.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final item = provider.items[index];
                final isEditing = provider.editingItemIndex == index;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isEditing ? AppColors.primary : AppColors.border,
                      width: isEditing ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  title: Text(
                    item.description,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${CurrencyFormatter.formatNumber(item.qty)} ${item.unit} x ${CurrencyFormatter.formatRupiah(item.unitPrice)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyFormatter.formatRupiah(item.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (val) {
                          if (val == 'edit') {
                            provider.startEditingItem(index);
                          } else if (val == 'delete') {
                            provider.removeItem(index);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Hapus', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
              },
            ),
        ],
      ),
    );
  }
}
