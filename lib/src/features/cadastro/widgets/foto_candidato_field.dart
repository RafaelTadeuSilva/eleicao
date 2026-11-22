import 'package:eleicao/src/features/cadastro/widgets/recorte_foto_dialog.dart';
import 'package:eleicao/src/functions/image_helper.dart';
import 'package:eleicao/src/functions/recorte_foto.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Campo de foto do candidato (ou do vice): pré-visualização e botões para
/// escolher um arquivo, colar um link (inclusive do Google Drive) ou
/// arrastar uma imagem para a moldura (desktop e web).
///
/// Ao escolher a foto, abre o enquadramento (arrastar/zoom na moldura 4:5
/// da urna); o recorte é guardado como data URI JPEG em [controller].
/// "Enquadrar" refaz o recorte da foto atual.
class FotoCandidatoField extends StatefulWidget {
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
  State<FotoCandidatoField> createState() => _FotoCandidatoFieldState();
}

class _FotoCandidatoFieldState extends State<FotoCandidatoField> {
  bool _carregando = false;
  bool _arrastando = false;

  static const _extensoesImagem = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'heic',
    'heif'
  };

  TextEditingController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) => Column(
        children: [
          DropTarget(
            enable: !_carregando,
            onDragEntered: (_) => setState(() => _arrastando = true),
            onDragExited: (_) => setState(() => _arrastando = false),
            onDragDone: (detalhes) {
              setState(() => _arrastando = false);
              soltarArquivos(detalhes.files);
            },
            child: GestureDetector(
              onTap: _carregando ? null : escolherArquivo,
              child: Container(
                height: 200,
                width: 200 * proporcaoFotoCandidato,
                decoration: BoxDecoration(
                  border: _arrastando
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        )
                      : Border.all(),
                ),
                child: _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          buildCandidatoPreviewImage(value.text),
                          if (_arrastando)
                            ColoredBox(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.25),
                              child: const Center(
                                child: Icon(Icons.file_download, size: 48),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _carregando ? null : escolherArquivo,
                icon: const Icon(Icons.photo_library),
                label: Text(widget.rotuloArquivo),
              ),
              OutlinedButton.icon(
                onPressed: _carregando ? null : informarLink,
                icon: const Icon(Icons.link),
                label: const Text('Colar Link / Drive'),
              ),
              if (value.text.trim().isNotEmpty)
                OutlinedButton.icon(
                  onPressed: _carregando ? null : enquadrarAtual,
                  icon: const Icon(Icons.crop),
                  label: const Text('Enquadrar'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _mensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Abre o enquadramento; devolve o data URI do recorte ou null se cancelar.
  Future<String?> _enquadrar(Uint8List bytes) async {
    if (!mounted) return null;
    final recorte = await RecorteFotoDialog.show(context, bytes);
    return recorte == null ? null : jpegDataUri(recorte);
  }

  Future<void> escolherArquivo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null) return;
    final bytes = await carregarBytesFoto(path);
    if (bytes == null) {
      _mensagem('Não foi possível ler o arquivo escolhido.');
      return;
    }
    final foto = await _enquadrar(bytes);
    if (foto != null) controller.text = foto;
  }

  /// Foto arrastada para a moldura: usa o primeiro arquivo de imagem.
  Future<void> soltarArquivos(List<DropItem> arquivos) async {
    final imagem = arquivos.where((f) {
      final nome = f.name.toLowerCase();
      final ponto = nome.lastIndexOf('.');
      return ponto != -1 &&
          _extensoesImagem.contains(nome.substring(ponto + 1));
    }).firstOrNull;
    if (imagem == null) {
      _mensagem('Arraste um arquivo de imagem (JPG, PNG...).');
      return;
    }
    setState(() => _carregando = true);
    Uint8List? bytes;
    try {
      bytes = await imagem.readAsBytes();
    } catch (e) {
      debugPrint('Erro ao ler foto arrastada: $e');
    }
    if (!mounted) return;
    setState(() => _carregando = false);
    if (bytes == null || bytes.isEmpty) {
      _mensagem('Não foi possível ler a imagem arrastada.');
      return;
    }
    final foto = await _enquadrar(bytes);
    if (foto != null) controller.text = foto;
  }

  Future<void> informarLink() async {
    final link = await showDialog<String>(
      context: context,
      builder: (context) => _LinkFotoDialog(
        titulo: widget.titulo,
        inicial: controller.text.startsWith('http') ? controller.text : '',
      ),
    );
    if (link == null || link.trim().isEmpty) return;
    final url = normalizeImageUrl(link.trim());
    controller.text = url;
    // Tenta baixar para enquadrar; se não der, fica o link como está.
    await enquadrarAtual(avisarFalha: false);
  }

  /// Refaz o enquadramento da foto atual (arquivo, link ou já recortada).
  Future<void> enquadrarAtual({bool avisarFalha = true}) async {
    setState(() => _carregando = true);
    final bytes = await carregarBytesFoto(controller.text);
    if (!mounted) return;
    setState(() => _carregando = false);
    if (bytes == null) {
      _mensagem(avisarFalha
          ? 'Não foi possível carregar a foto para enquadrar.'
          : 'Não foi possível baixar a foto para enquadrar; o link foi mantido.');
      return;
    }
    final foto = await _enquadrar(bytes);
    if (foto != null) controller.text = foto;
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
