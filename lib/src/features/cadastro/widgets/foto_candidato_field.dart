import 'package:eleicao/src/functions/image_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Campo de foto do candidato (ou do vice): pré-visualização e botões para
/// escolher um arquivo ou colar um link (inclusive do Google Drive).
///
/// O valor (caminho local, URL ou data URI) fica em [controller].
class FotoCandidatoField extends StatelessWidget {
  const FotoCandidatoField({
    super.key,
    required this.controller,
    required this.titulo,
    this.rotuloArquivo = 'Escolher Arquivo',
  });

  final TextEditingController controller;

  /// Usado no título do diálogo de link (ex.: "Candidato", "Vice").
  final String titulo;
  final String rotuloArquivo;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) => Column(
        children: [
          GestureDetector(
            onTap: escolherArquivo,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(border: Border.all()),
              child: buildCandidatoPreviewImage(value.text),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: escolherArquivo,
                icon: const Icon(Icons.photo_library),
                label: Text(rotuloArquivo),
              ),
              OutlinedButton.icon(
                onPressed: () => informarLink(context),
                icon: const Icon(Icons.link),
                label: const Text('Colar Link / Drive'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> escolherArquivo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path != null) controller.text = path;
  }

  Future<void> informarLink(BuildContext context) async {
    final link = await showDialog<String>(
      context: context,
      builder: (context) => _LinkFotoDialog(
        titulo: titulo,
        inicial: controller.text.startsWith('http') ? controller.text : '',
      ),
    );
    if (link != null && link.trim().isNotEmpty) {
      controller.text = normalizeImageUrl(link.trim());
    }
  }
}

/// Pede a URL da foto; fecha retornando o texto digitado (ou null).
class _LinkFotoDialog extends StatefulWidget {
  const _LinkFotoDialog({required this.titulo, required this.inicial});

  final String titulo;
  final String inicial;

  @override
  State<_LinkFotoDialog> createState() => _LinkFotoDialogState();
}

class _LinkFotoDialogState extends State<_LinkFotoDialog> {
  late final txtLink = TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    txtLink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Link da Foto (${widget.titulo})'),
      content: TextField(
        controller: txtLink,
        decoration: const InputDecoration(
          labelText: 'Cole a URL da imagem ou link do Google Drive',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(txtLink.text),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
