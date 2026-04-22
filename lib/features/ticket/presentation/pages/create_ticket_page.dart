import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/ticket_model.dart';
import '../../data/services/ticket_service.dart';
import 'ticket_detail_page.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final TicketService service = TicketService();

  XFile? selectedImage;
  final ImagePicker picker = ImagePicker();

  void pickImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    setState(() => selectedImage = image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() => selectedImage = image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Buat Tiket'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // INPUT JUDUL
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
              ),
            ),

            const SizedBox(height: 16),

            // INPUT DESKRIPSI
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
              ),
            ),

            const SizedBox(height: 16),

            // BUTTON UPLOAD
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.upload),
                label: const Text('Upload Gambar'),
              ),
            ),

            // PREVIEW
            if (selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(selectedImage!.path),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImage = null;
                          });
                        },
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // BUTTON SIMPAN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty ||
                      descController.text.trim().isEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => const AlertDialog(
                        title: Text('Error'),
                        content: Text('Semua field harus diisi!'),
                      ),
                    );
                    return;
                  }

                  final newTicket = TicketModel(
                    title: titleController.text,
                    desc: descController.text,
                    status: 'Diproses',
                    comments: [],
                    imagePath: selectedImage?.path,
                  );

                  await service.createTicket(newTicket);

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AlertDialog(
                      title: const Text('Berhasil'),
                      content:
                      const Text('Tiket berhasil dibuat'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context, newTicket);
                          },
                          child: const Text('OK'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketDetailPage(
                                  ticket: newTicket,
                                  role: 'user',
                                ),
                              ),
                            );
                          },
                          child: const Text('Lihat'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Simpan Tiket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}