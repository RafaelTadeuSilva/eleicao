import 'dart:math' as math;

import 'package:eleicao/src/functions/recorte_foto.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// Tela para enquadrar a foto do candidato na moldura da urna (4:5).
/// A moldura é fixa; a pessoa arrasta a imagem e ajusta o zoom.
///
/// A moldura ocupa o espaço que sobra no diálogo (até [alturaMaxima]), então
/// o diálogo cabe em qualquer altura de janela; se a janela mudar de tamanho,
/// o enquadramento escolhido é mantido.
///
/// Devolve a foto recortada em JPEG ou null se cancelar.
class RecorteFotoDialog extends StatefulWidget {
  const RecorteFotoDialog({super.key, required this.bytesOriginais});

  final Uint8List bytesOriginais;

  /// Largura do conteúdo do diálogo.
  static const largura = 300.0;

  /// Altura máxima da moldura na tela.
  static const alturaMaxima = largura / proporcaoFotoCandidato;

  /// Zoom máximo, em relação ao zoom que encaixa a foto na moldura.
  static const zoomMaximo = 6.0;

  static Future<Uint8List?> show(BuildContext context, Uint8List bytes) =>
      showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (_) => RecorteFotoDialog(bytesOriginais: bytes),
      );

  /// Maior moldura 4:5 que cabe em [disponivel].
  static Size areaPara(Size disponivel) {
    final altura = math.max(
      0.0,
      math.min(
        alturaMaxima,
        math.min(disponivel.height, disponivel.width / proporcaoFotoCandidato),
      ),
    );
    return Size(altura * proporcaoFotoCandidato, altura);
  }

  @override
  State<RecorteFotoDialog> createState() => _RecorteFotoDialogState();
}

class _RecorteFotoDialogState extends State<RecorteFotoDialog> {
  final _transformacao = TransformationController();
  FotoPreparada? _foto;
  bool _carregando = true;
  bool _gerando = false;
  String? _erro;

  /// Tamanho atual da moldura (definido no layout).
  Size? _area;

  /// Escala que faz a foto cobrir exatamente a moldura.
  double _escalaMinima = 1;

  @override
  void initState() {
    super.initState();
    _preparar();
  }

  @override
  void dispose() {
    _transformacao.dispose();
    super.dispose();
  }

  Future<void> _preparar() async {
    final foto = await prepararFoto(widget.bytesOriginais);
    if (!mounted) return;
    if (foto == null) {
      setState(() {
        _carregando = false;
        _erro = 'Não foi possível abrir a imagem. Use JPG, PNG, WEBP ou BMP.';
      });
      return;
    }
    setState(() {
      _foto = foto;
      _carregando = false;
      final area = _area;
      if (area != null && !area.isEmpty) {
        _escalaMinima = escalaParaCobrir(area, foto.tamanho);
        _transformacao.value = _matrizCentralizada(area);
      }
    });
  }

  /// Foto inteira encaixada na moldura e centralizada.
  Matrix4 _matrizCentralizada(Size area) {
    final foto = _foto!;
    return matrizRecorte(
      escala: _escalaMinima,
      tx: (area.width - foto.largura * _escalaMinima) / 2,
      ty: (area.height - foto.altura * _escalaMinima) / 2,
      area: area,
      imagem: foto.tamanho,
    );
  }

  void _centralizar() {
    final area = _area;
    if (_foto == null || area == null || area.isEmpty) return;
    _transformacao.value = _matrizCentralizada(area);
  }

  /// Chamado no layout quando a moldura muda de tamanho: recalcula a
  /// escala mantendo a mesma parte da foto dentro da moldura.
  ///
  /// Como roda durante o layout, altera a matriz sem notificar e avisa os
  /// ouvintes (barra de zoom) no quadro seguinte.
  void _ajustarArea(Size nova) {
    final anterior = _area;
    if (anterior == nova) return;
    _area = nova;
    final foto = _foto;
    if (foto == null || nova.isEmpty) return;

    final Matrix4 matriz;
    if (anterior == null || anterior.isEmpty) {
      _escalaMinima = escalaParaCobrir(nova, foto.tamanho);
      matriz = _matrizCentralizada(nova);
    } else {
      final recorte =
          calcularRecorte(_transformacao.value, anterior, foto.tamanho);
      _escalaMinima = escalaParaCobrir(nova, foto.tamanho);
      final escala = math.max(_escalaMinima, nova.width / recorte.width);
      matriz = matrizRecorte(
        escala: escala,
        tx: -recorte.left * escala,
        ty: -recorte.top * escala,
        area: nova,
        imagem: foto.tamanho,
      );
    }
    _transformacao.value.setFrom(matriz);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _transformacao.value = _transformacao.value.clone();
    });
  }

  double get _zoomAtual => escalaDaMatriz(_transformacao.value) / _escalaMinima;

  /// Aplica o zoom da barra mantendo o centro da moldura no mesmo ponto.
  void _aplicarZoom(double zoom) {
    final area = _area;
    if (area == null || area.isEmpty) return;
    final atual = _transformacao.value;
    final escalaAtual = escalaDaMatriz(atual);
    final novaEscala = _escalaMinima * zoom;
    final cx = area.width / 2;
    final cy = area.height / 2;
    // Ponto da imagem que está no centro da moldura
    final px = (cx - atual.storage[12]) / escalaAtual;
    final py = (cy - atual.storage[13]) / escalaAtual;
    _transformacao.value = matrizRecorte(
      escala: novaEscala,
      tx: cx - px * novaEscala,
      ty: cy - py * novaEscala,
      area: area,
      imagem: _foto!.tamanho,
    );
  }

  Future<void> _confirmar() async {
    final foto = _foto;
    final area = _area;
    if (foto == null || area == null || area.isEmpty) return;
    setState(() => _gerando = true);
    try {
      final recorte = calcularRecorte(_transformacao.value, area, foto.tamanho);
      final bytes = await gerarRecorte(foto, recorte);
      if (mounted) Navigator.of(context).pop(bytes);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _gerando = false;
        _erro = 'Erro ao recortar a foto: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
      title: const Text('Enquadrar foto'),
      content: SizedBox(
        width: RecorteFotoDialog.largura,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Arraste a foto e ajuste o zoom. O que está dentro da moldura '
              'é o que aparece na urna.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            // A moldura fica com o espaço que sobra no diálogo.
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final area = RecorteFotoDialog.areaPara(
                    constraints.biggest,
                  );
                  _ajustarArea(area);
                  return Center(
                    heightFactor: 1,
                    child: SizedBox.fromSize(size: area, child: _buildArea()),
                  );
                },
              ),
            ),
            if (_foto != null)
              Row(
                children: [
                  const Icon(Icons.zoom_out, size: 18),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _transformacao,
                      builder: (context, _) => Slider(
                        value: _zoomAtual.clamp(
                          1.0,
                          RecorteFotoDialog.zoomMaximo,
                        ),
                        min: 1,
                        max: RecorteFotoDialog.zoomMaximo,
                        onChanged: _gerando ? null : _aplicarZoom,
                      ),
                    ),
                  ),
                  const Icon(Icons.zoom_in, size: 18),
                  IconButton(
                    tooltip: 'Centralizar',
                    onPressed: _gerando ? null : _centralizar,
                    icon: const Icon(Icons.center_focus_strong),
                  ),
                ],
              ),
            if (_erro != null) ...[
              const SizedBox(height: 8),
              Text(
                _erro!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _gerando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: (_foto == null || _gerando) ? null : _confirmar,
          child: _gerando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Usar este enquadramento'),
        ),
      ],
    );
  }

  Widget _buildArea() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    final foto = _foto;
    if (foto == null) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
      );
    }
    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformacao,
              constrained: false,
              minScale: _escalaMinima,
              maxScale: _escalaMinima * RecorteFotoDialog.zoomMaximo,
              boundaryMargin: EdgeInsets.zero,
              child: SizedBox(
                width: foto.largura.toDouble(),
                height: foto.altura.toDouble(),
                child: Image.memory(
                  foto.bytes,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
          // Guias de terços e borda (não interceptam o arraste)
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _GuiasMoldura()),
            ),
          ),
        ],
      ),
    );
  }
}

/// Borda da moldura e linhas de terços para ajudar a posicionar o rosto.
class _GuiasMoldura extends CustomPainter {
  const _GuiasMoldura();

  @override
  void paint(Canvas canvas, Size size) {
    final guia = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.5);
    for (var i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      final y = size.height * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), guia);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), guia);
    }
    canvas.drawRect(
      (Offset.zero & size).deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _GuiasMoldura oldDelegate) => false;
}
