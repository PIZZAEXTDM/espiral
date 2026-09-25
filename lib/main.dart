// main.dart - Sistema de Conteo Tortillas & Cervecería Espiral v4
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Espiral - Conteo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const EspiralHomePage(),
    );
  }
}

// ============================================
// MODELOS
// ============================================
class Tortilla {
  final int id;
  final String nombre;
  final double precio;
  int cantidad;
  Tortilla({
    required this.id,
    required this.nombre,
    required this.precio,
    this.cantidad = 0,
  });
}

class Cerveza {
  final int id;
  final String nombre;
  final double precioSix;
  final double precioCaja12;
  final double precioCaja24;
  // 🔥 Contadores independientes por tipo
  int cantidadSix;
  int cantidadCaja12;
  int cantidadCaja24;
  int cantidadMixta;
  Cerveza({
    required this.id,
    required this.nombre,
    required this.precioSix,
    required this.precioCaja12,
    required this.precioCaja24,
    this.cantidadSix = 0,
    this.cantidadCaja12 = 0,
    this.cantidadCaja24 = 0,
    this.cantidadMixta = 0,
  });
}

List<Tortilla> getTortillasBase() => [
      Tortilla(id: 1, nombre: 'BURRITO GIGANTES 10 PZ', precio: 40),
      Tortilla(id: 4, nombre: 'GUERAS 475GR 19 PZ', precio: 23),
      Tortilla(id: 5, nombre: 'GUERAS 1KG 40 PZ', precio: 40),
      Tortilla(id: 6, nombre: 'CAMPESINAS 1KG 30 PZ', precio: 39),
      Tortilla(id: 7, nombre: 'CLASICAS 500GR 15 PZ', precio: 23),
      Tortilla(id: 8, nombre: 'CAMPESINAS MANTEQUILLA 1KG 30 PZ', precio: 26),
      Tortilla(id: 9, nombre: 'INTEGRALES 500GR 15 PZ', precio: 26),
    ];

List<Cerveza> getCervezasBase() => [
      Cerveza(
          id: 1,
          nombre: 'COFFE STOUT',
          precioSix: 300,
          precioCaja12: 600,
          precioCaja24: 1200),
      Cerveza(
          id: 2,
          nombre: 'AMERICA PALE ALE',
          precioSix: 270,
          precioCaja12: 540,
          precioCaja24: 1080),
      Cerveza(
          id: 3,
          nombre: 'MEXICAN LAGER',
          precioSix: 240,
          precioCaja12: 480,
          precioCaja24: 960),
      Cerveza(
          id: 4,
          nombre: 'ENGLISH BROWN ALE',
          precioSix: 270,
          precioCaja12: 540,
          precioCaja24: 1080),
      Cerveza(
          id: 5,
          nombre: 'OKTOBERFEST',
          precioSix: 300,
          precioCaja12: 600,
          precioCaja24: 1200),
      Cerveza(
          id: 6,
          nombre: 'PAN DE MUERTO DUBBEL',
          precioSix: 300,
          precioCaja12: 600,
          precioCaja24: 1200),
      Cerveza(
          id: 7,
          nombre: 'CANDY CORN BROWN ALE',
          precioSix: 300,
          precioCaja12: 600,
          precioCaja24: 1200),
    ];

// ============================================
// CONFIG
// ============================================
class AppConfig {
  String language;
  String color;
  int transparency;
  String deviceMode;
  double buttonScale;
  bool scrollSnap;
  bool darkColorMode;

  AppConfig({
    this.language = 'es',
    this.color = 'arcoiris',
    this.transparency = 30,
    this.deviceMode = 'escritorio',
    this.buttonScale = 1.0,
    this.scrollSnap = true,
    this.darkColorMode = false,
  });

  factory AppConfig.fromJson(Map<String, dynamic> j) => AppConfig(
        language: j['language'] ?? 'es',
        color: j['color'] ?? 'arcoiris',
        transparency: j['transparency'] ?? 30,
        deviceMode: j['device_mode'] ?? 'escritorio',
        buttonScale: (j['button_scale'] as num?)?.toDouble() ?? 1.0,
        scrollSnap: j['scroll_snap'] ?? true,
        darkColorMode: j['dark_color_mode'] ?? false,
      );
}

// ============================================
// TRADUCCIONES
// ============================================
const Map<String, Map<String, String>> translations = {
  'es': {
    'tortillas': 'Tortillas',
    'cervezas': 'Cervecería Espiral',
    'voucher_t': 'VOUCHER TORTILLAS',
    'voucher_c': 'VOUCHER CERVEZAS',
    'no_products': 'No hay productos',
    'total': 'Total',
    'clean': 'Limpiar',
    'settings': 'Configuración',
    'language': 'Idioma',
    'color_theme': 'Tema de color',
    'device_mode': 'Modo visualización',
    'escritorio': 'Escritorio',
    'movil': 'Móvil',
    'transparency': 'Transparencia',
    'button_size': 'Tamaño interfaz',
    'scroll_snap': 'Carrusel',
    'dark_color_mode': 'Modo oscuro',
    'arcoiris': 'Arcoíris',
    'negro': 'Negro',
    'rojo': 'Rojo',
    'verde': 'Verde',
    'amarillo': 'Amarillo',
    'naranja': 'Naranja',
    'azul': 'Azul',
    'whatsapp': 'WhatsApp',
    'photo': 'Foto',
    'six': 'SIX',
    'caja12': 'CAJA 12',
    'caja24': 'CAJA 24',
    'mixta': 'MIXTA',
    'mixto_global': 'MIXTO (Todas)',
    'oktoberfest': 'OKTOBERFEST',
    'apply': 'Aplicar',
    'discount': 'Descuento',
    'unit_price': 'c/u',
    'share': 'Compartir',
    'on': 'ON',
    'off': 'OFF',
    'voucher_title': 'VOUCHER',
    'date': 'Fecha',
    'time': 'Hora',
  },
  'en': {
    'tortillas': 'Tortillas',
    'cervezas': 'Espiral Brewery',
    'voucher_t': 'TORTILLAS VOUCHER',
    'voucher_c': 'BEER VOUCHER',
    'no_products': 'No products',
    'total': 'Total',
    'clean': 'Clear',
    'settings': 'Settings',
    'language': 'Language',
    'color_theme': 'Color theme',
    'device_mode': 'Display mode',
    'escritorio': 'Desktop',
    'movil': 'Mobile',
    'transparency': 'Transparency',
    'button_size': 'UI size',
    'scroll_snap': 'Carousel',
    'dark_color_mode': 'Dark mode',
    'arcoiris': 'Rainbow',
    'negro': 'Black',
    'rojo': 'Red',
    'verde': 'Green',
    'amarillo': 'Yellow',
    'naranja': 'Orange',
    'azul': 'Blue',
    'whatsapp': 'WhatsApp',
    'photo': 'Photo',
    'six': 'SIX',
    'caja12': 'BOX 12',
    'caja24': 'BOX 24',
    'mixta': 'MIXED',
    'mixto_global': 'MIXED (All)',
    'oktoberfest': 'OKTOBERFEST',
    'apply': 'Apply',
    'discount': 'Discount',
    'unit_price': 'each',
    'share': 'Share',
    'on': 'ON',
    'off': 'OFF',
    'voucher_title': 'VOUCHER',
    'date': 'Date',
    'time': 'Time',
  },
  'ja': {
    'tortillas': 'トルティーヤ',
    'cervezas': 'エスピラル醸造所',
    'voucher_t': 'トルティーヤ伝票',
    'voucher_c': 'ビール伝票',
    'no_products': '商品なし',
    'total': '合計',
    'clean': 'クリア',
    'settings': '設定',
    'language': '言語',
    'color_theme': 'カラーテーマ',
    'device_mode': '表示モード',
    'escritorio': 'デスクトップ',
    'movil': 'モバイル',
    'transparency': '透明度',
    'button_size': 'UIサイズ',
    'scroll_snap': 'カルーセル',
    'dark_color_mode': 'ダークモード',
    'arcoiris': '虹',
    'negro': '黒',
    'rojo': '赤',
    'verde': '緑',
    'amarillo': '黄',
    'naranja': 'オレンジ',
    'azul': '青',
    'whatsapp': 'WhatsApp',
    'photo': '写真',
    'six': '6本',
    'caja12': '12本箱',
    'caja24': '24本箱',
    'mixta': 'ミックス',
    'mixto_global': 'ミックス',
    'oktoberfest': 'オクトーバーフェスト',
    'apply': '適用',
    'discount': '割引',
    'unit_price': '各',
    'share': '共有',
    'on': 'ON',
    'off': 'OFF',
    'voucher_title': '伝票',
    'date': '日付',
    'time': '時間',
  },
  'zh': {
    'tortillas': '玉米饼',
    'cervezas': '螺旋酿酒厂',
    'voucher_t': '玉米饼凭证',
    'voucher_c': '啤酒凭证',
    'no_products': '没有产品',
    'total': '总计',
    'clean': '清除',
    'settings': '设置',
    'language': '语言',
    'color_theme': '颜色主题',
    'device_mode': '显示模式',
    'escritorio': '桌面',
    'movil': '移动',
    'transparency': '透明度',
    'button_size': '界面大小',
    'scroll_snap': '轮播',
    'dark_color_mode': '深色模式',
    'arcoiris': '彩虹',
    'negro': '黑色',
    'rojo': '红色',
    'verde': '绿色',
    'amarillo': '黄色',
    'naranja': '橙色',
    'azul': '蓝色',
    'whatsapp': 'WhatsApp',
    'photo': '照片',
    'six': '6瓶装',
    'caja12': '12瓶箱',
    'caja24': '24瓶箱',
    'mixta': '混合',
    'mixto_global': '混合',
    'oktoberfest': '十月节',
    'apply': '应用',
    'discount': '折扣',
    'unit_price': '每个',
    'share': '分享',
    'on': 'ON',
    'off': 'OFF',
    'voucher_title': '凭证',
    'date': '日期',
    'time': '时间',
  },
};

// ============================================
// HOME PAGE
// ============================================
class EspiralHomePage extends StatefulWidget {
  const EspiralHomePage({super.key});
  @override
  State<EspiralHomePage> createState() => _EspiralHomePageState();
}

class _EspiralHomePageState extends State<EspiralHomePage>
    with SingleTickerProviderStateMixin {
  late List<Tortilla> tortillas;
  late List<Cerveza> cervezas;
  late List<String> cervezaTypes;
  late Map<int, List<Map<String, int>>> mixtaSelections;
  late Map<int, String> mixtaTypeSelections;
  late Map<int, Map<String, dynamic>> mixtaDescuento;

  int _tabIndex = 0;
  bool _configOpen = false;
  bool _loading = true;

  late AnimationController _rainbowController;
  late Animation<double> _rainbowAnimation;

  AppConfig _config = AppConfig();
  int _transparencyPreview = 30;
  double _buttonScalePreview = 1.0;
  Timer? _transparencyDebounce;
  Timer? _scaleDebounce;

  final PageController _tortillasPage = PageController();
  final PageController _cervezasPage = PageController();

  // GlobalKey para capturar el PNG del voucher
  final GlobalKey _voucherRepaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
    _rainbowAnimation =
        Tween<double>(begin: 0, end: 1).animate(_rainbowController);
    _initData();
    _loadConfig();
  }

  @override
  void dispose() {
    _rainbowController.dispose();
    _transparencyDebounce?.cancel();
    _scaleDebounce?.cancel();
    _tortillasPage.dispose();
    _cervezasPage.dispose();
    super.dispose();
  }

  void _initData() {
    tortillas = getTortillasBase();
    cervezas = getCervezasBase();
    cervezaTypes = List<String>.filled(cervezas.length, 'six');
    mixtaSelections = {};
    mixtaTypeSelections = {};
    mixtaDescuento = {};
    for (int i = 0; i < cervezas.length; i++) {
      mixtaSelections[i] =
          cervezas.map((c) => {'id': c.id, 'cantidad': 0}).toList();
      mixtaTypeSelections[i] = 'six';
      mixtaDescuento[i] = {'activo': false, 'pct': 0};
    }
    mixtaSelections[-1] =
        cervezas.map((c) => {'id': c.id, 'cantidad': 0}).toList();
    mixtaTypeSelections[-1] = 'six';
    mixtaDescuento[-1] = {'activo': false, 'pct': 0};

    mixtaSelections[-2] =
        cervezas.map((c) => {'id': c.id, 'cantidad': 0}).toList();
    mixtaTypeSelections[-2] = 'six';
    mixtaDescuento[-2] = {'activo': false, 'pct': 0};
  }

  // ============================================
  // CONFIG
  // ============================================
  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('espiral_config_v4');
    if (raw != null) {
      try {
        final map = <String, dynamic>{};
        for (final p in raw.split(';')) {
          final kv = p.split('=');
          if (kv.length != 2) continue;
          final k = kv[0].trim();
          final v = kv[1].trim();
          if (v == 'true' || v == 'false') {
            map[k] = v == 'true';
          } else if (double.tryParse(v) != null && v.contains('.')) {
            map[k] = double.parse(v);
          } else if (int.tryParse(v) != null) {
            map[k] = int.parse(v);
          } else {
            map[k] = v;
          }
        }
        _config = AppConfig.fromJson(map);
      } catch (_) {
        _config = AppConfig();
      }
    }
    _transparencyPreview = _config.transparency;
    _buttonScalePreview = _config.buttonScale;
    setState(() => _loading = false);
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final c = _config;
    final s = 'language=${c.language};'
        'color=${c.color};'
        'transparency=${c.transparency};'
        'device_mode=${c.deviceMode};'
        'button_scale=${c.buttonScale};'
        'scroll_snap=${c.scrollSnap};'
        'dark_color_mode=${c.darkColorMode}';
    await prefs.setString('espiral_config_v4', s);
  }

  String t(String key) => translations[_config.language]?[key] ?? key;
  bool get _isDesktop => _config.deviceMode == 'escritorio';
  double get _scale => _config.buttonScale;

  // ============================================
  // CÁLCULOS
  // ============================================
  double get totalTortillas {
    double s = 0;
    for (final t in tortillas) {
      s += t.cantidad * t.precio;
    }
    return s;
  }

  /// Total de una cerveza sumando SUS contadores independientes
  double _totalCerveza(Cerveza c) {
    return c.cantidadSix * c.precioSix +
        c.cantidadCaja12 * c.precioCaja12 +
        c.cantidadCaja24 * c.precioCaja24;
  }

  double get totalCervezas {
    double total = 0;
    for (final c in cervezas) {
      total += _totalCerveza(c);
    }
    // Mixto global y Oktoberfest (solo si tienen unidades)
    if (_mixtaTotalUnidades(-1) > 0) {
      total += _calcMixtaTotal(-1)['neto'] as double;
    }
    if (_mixtaTotalUnidades(-2) > 0) {
      total += _calcMixtaTotal(-2)['neto'] as double;
    }
    return total;
  }

  int _mixtaTotalUnidades(int idx) {
    final sel = mixtaSelections[idx] ?? [];
    return sel.fold<int>(0, (s, e) => s + (e['cantidad'] ?? 0));
  }

  Map<String, dynamic> _calcMixtaTotal(int idx) {
    final sel = mixtaSelections[idx] ?? [];
    double bruto = 0;
    for (final s in sel) {
      final id = s['id'];
      final cantidad = s['cantidad'] ?? 0;
      final cer = cervezas.firstWhere((c) => c.id == id,
          orElse: () => cervezas.first);
      bruto += cantidad * (cer.precioSix / 6);
    }
    final d = mixtaDescuento[idx] ?? {'activo': false, 'pct': 0};
    final activo = d['activo'] == true;
    final pct = (d['pct'] as num?)?.toDouble() ?? 0;
    final neto = (activo && pct > 0) ? bruto * (1 - pct / 100) : bruto;
    return {
      'bruto': bruto,
      'neto': neto,
      'descPct': pct,
      'descActivo': activo,
    };
  }

  List<String> get voucherTortillas {
    final items = <String>[];
    for (final t in tortillas) {
      if (t.cantidad > 0) {
        final nombreLimpio = t.nombre
            .replaceAll(RegExp(r'\s*\d+\s*PZ\s*', caseSensitive: false), '')
            .trim();
        items.add('${t.cantidad} x $nombreLimpio');
      }
    }
    return items;
  }

  /// 🔥 Voucher de cervezas respetando contadores independientes
  List<String> get voucherCervezas {
    final items = <String>[];
    for (int i = 0; i < cervezas.length; i++) {
      final c = cervezas[i];
      // SIX
      if (c.cantidadSix > 0) {
        items.add('${c.cantidadSix} SIX (6) de ${c.nombre}');
      }
      // CAJA 12
      if (c.cantidadCaja12 > 0) {
        items.add('${c.cantidadCaja12} CAJA 12 de ${c.nombre}');
      }
      // CAJA 24
      if (c.cantidadCaja24 > 0) {
        items.add('${c.cantidadCaja24} CAJA 24 de ${c.nombre}');
      }
      // MIXTA
      if (c.cantidadMixta > 0) {
        final det = (mixtaSelections[i] ?? [])
            .where((s) => (s['cantidad'] ?? 0) > 0)
            .map((s) =>
                '${s['cantidad']} x ${cervezas.firstWhere((c2) => c2.id == s['id']).nombre}')
            .join(', ');
        final m = _calcMixtaTotal(i);
        final descTxt = (m['descActivo'] == true &&
                (m['descPct'] as double) > 0)
            ? ' (Desc ${m['descPct']}%: \$${(m['neto'] as double).round()})'
            : '';
        items.add('${c.nombre} - MIXTA: $det$descTxt');
      }
    }
    if (_mixtaTotalUnidades(-1) > 0) {
      final det = (mixtaSelections[-1] ?? [])
          .where((s) => (s['cantidad'] ?? 0) > 0)
          .map((s) =>
              '${s['cantidad']} x ${cervezas.firstWhere((c) => c.id == s['id']).nombre}')
          .join(', ');
      final m = _calcMixtaTotal(-1);
      final descTxt = (m['descActivo'] == true &&
              (m['descPct'] as double) > 0)
          ? ' (Desc ${m['descPct']}%: \$${(m['neto'] as double).round()})'
          : '';
      items.add('MIXTO: $det$descTxt');
    }
    if (_mixtaTotalUnidades(-2) > 0) {
      final det = (mixtaSelections[-2] ?? [])
          .where((s) => (s['cantidad'] ?? 0) > 0)
          .map((s) =>
              '${s['cantidad']} x ${cervezas.firstWhere((c) => c.id == s['id']).nombre}')
          .join(', ');
      final o = _calcMixtaTotal(-2);
      final descTxt = (o['descActivo'] == true &&
              (o['descPct'] as double) > 0)
          ? ' (Desc ${o['descPct']}%: \$${(o['neto'] as double).round()})'
          : '';
      items.add('OKTOBERFEST: $det$descTxt');
    }
    return items;
  }

  // ============================================
  // ACCIONES
  // ============================================
  Future<void> _launchWhatsApp(String mensaje) async {
    final url = Uri.parse(
        'https://wa.me/527461114091?text=${Uri.encodeComponent(mensaje)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showToast(String msg, {bool error = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 2000),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
    );
  }

  void _resetTortillas() {
    setState(() {
      for (final t in tortillas) {
        t.cantidad = 0;
      }
    });
    _showToast('🧹 Carrito limpiado');
  }

  void _resetCervezas() {
    setState(() {
      for (final c in cervezas) {
        c.cantidadSix = 0;
        c.cantidadCaja12 = 0;
        c.cantidadCaja24 = 0;
        c.cantidadMixta = 0;
      }
      for (final key in [-1, -2]) {
        final sel = mixtaSelections[key];
        if (sel != null) {
          for (final s in sel) {
            s['cantidad'] = 0;
          }
        }
      }
    });
    _showToast('🧹 Carrito limpiado');
  }

  // ============================================
  // VOUCHER DE TEXTO (para WhatsApp y Share)
  // ============================================
  String _buildVoucherTexto() {
    final isTortillas = _tabIndex == 0;
    final items = isTortillas ? voucherTortillas : voucherCervezas;
    final total = isTortillas ? totalTortillas : totalCervezas;

    final now = DateTime.now();
    final fecha =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final hora =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final tipo = isTortillas ? t('voucher_t') : t('voucher_c');

    final sb = StringBuffer();
    sb.writeln('=== $tipo ===');
    sb.writeln('${t('date')}: $fecha  ${t('time')}: $hora');
    sb.writeln('------------------------');
    if (items.isEmpty) {
      sb.writeln(t('no_products'));
    } else {
      for (final it in items) {
        sb.writeln('• $it');
      }
    }
    sb.writeln('------------------------');
    sb.writeln('${t('total')}: \$${total.toStringAsFixed(2)} MXN');
    sb.writeln('=======================');
    sb.writeln('ESPIRAL - Tortillas & Cervecería');
    return sb.toString();
  }

  /// Genera PNG del voucher (widget oculto offscreen)
  Future<void> _compartirVoucherPng() async {
    final items = _tabIndex == 0 ? voucherTortillas : voucherCervezas;
    if (items.isEmpty) {
      _showToast('No hay productos', error: true);
      return;
    }

    try {
      final boundary = _voucherRepaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        _showToast('No se pudo capturar', error: true);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showToast('Error al generar PNG', error: true);
        return;
      }
      final bytes = byteData.buffer.asUint8List();

      final now = DateTime.now();
      final fechaArchivo = now
          .toIso8601String()
          .replaceAll(':', '-')
          .substring(0, 19);
      final isTortillas = _tabIndex == 0;
      final nombre =
          'voucher_${isTortillas ? "tortillas" : "cervezas"}_$fechaArchivo.png';

      await Share.shareXFiles(
        [
          XFile.fromData(Uint8List.fromList(bytes),
              name: nombre, mimeType: 'image/png')
        ],
        subject: t('voucher_title'),
        text: _buildVoucherTexto(),
      );
      _showToast('📸 Voucher PNG compartido');
    } catch (e) {
      _showToast('Error: $e', error: true);
    }
  }

  // ============================================
  // BUILD
  // ============================================
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: _buildRainbowBackground()),
          if (_config.color != 'arcoiris')
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: _overlayColor(),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildTabs(),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      _buildTortillasTab(),
                      _buildCervezasTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Panel de configuración
          _buildConfigPanel(),
          // 🔥 Voucher PNG oculto (offscreen) listo para capturar
          Positioned(
            left: -10000,
            top: 0,
            child: RepaintBoundary(
              key: _voucherRepaintKey,
              child: _buildVoucherWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Color _overlayColor() {
    final alpha = (_config.transparency / 100).clamp(0.0, 1.0);
    switch (_config.color) {
      case 'negro':
        return Colors.black.withOpacity(alpha);
      case 'rojo':
        return const Color(0xFFFF0000).withOpacity(alpha);
      case 'verde':
        return const Color(0xFF00FF00).withOpacity(alpha);
      case 'amarillo':
        return const Color(0xFFFFFF00).withOpacity(alpha);
      case 'naranja':
        return const Color(0xFFFFA500).withOpacity(alpha);
      case 'azul':
        return const Color(0xFF0000FF).withOpacity(alpha);
      default:
        return Colors.white.withOpacity(alpha);
    }
  }

  List<Color> _rainbowColors() => const [
        Color(0xFFFF2400),
        Color(0xFFE81D1D),
        Color(0xFFE8B71D),
        Color(0xFFE3E81D),
        Color(0xFF1DE840),
        Color(0xFF1DDDE8),
        Color(0xFF2B1DE8),
        Color(0xFFDD00F3),
        Color(0xFFFF2400),
      ];

  Widget _buildRainbowBackground() {
    if (_config.color != 'arcoiris') {
      return Container(color: const Color(0xFF1a1a2e));
    }
    return AnimatedBuilder(
      animation: _rainbowAnimation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                -1 + 2 * _rainbowAnimation.value,
                -1 + 2 * _rainbowAnimation.value,
              ),
              end: Alignment(
                1 - 2 * _rainbowAnimation.value,
                1 - 2 * _rainbowAnimation.value,
              ),
              colors: _rainbowColors(),
              stops: List.generate(
                _rainbowColors().length,
                (i) => i / (_rainbowColors().length - 1),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================
  // WIDGET DEL VOUCHER (para capturar PNG)
  // ============================================
  Widget _buildVoucherWidget() {
    final isTortillas = _tabIndex == 0;
    final items = isTortillas ? voucherTortillas : voucherCervezas;
    final total = isTortillas ? totalTortillas : totalCervezas;
    final now = DateTime.now();
    final fecha =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final hora =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final tipo = isTortillas ? t('voucher_t') : t('voucher_c');

    // Colores oscuros para no lastimar la vista
    const bgColor = Color(0xFF2C241A);
    const textColor = Color(0xFFFFEFCF);
    const accentColor = Color(0xFFFFD08A);
    const borderColor = Color(0xFF9E6A42);

    return Container(
      width: 500,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Center(
            child: Text(
              '=== $tipo ===',
              style: const TextStyle(
                color: accentColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${t('date')}: $fecha   ${t('time')}: $hora',
              style: const TextStyle(
                color: textColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 2, color: borderColor),
          const SizedBox(height: 14),
          // Items
          if (items.isEmpty)
            Text(
              t('no_products'),
              style: const TextStyle(color: textColor, fontSize: 14),
            )
          else
            ...items.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '• $s',
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Container(height: 2, color: borderColor),
          const SizedBox(height: 12),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)} MXN',
                style: const TextStyle(
                  color: accentColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 2, color: borderColor),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'ESPIRAL - Tortillas & Cervecería',
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TOP BAR
  // ============================================
  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * _scale,
        vertical: 10 * _scale,
      ),
      margin: EdgeInsets.symmetric(horizontal: 8 * _scale, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🌮 TORTILLAS DE HARINA 🍺 CERVECERÍA ESPIRAL',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14 * _scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(
                    color: Colors.black38,
                    offset: Offset(2, 4),
                    blurRadius: 12),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionBtn(
                  icon: _config.darkColorMode
                      ? Icons.wb_sunny
                      : Icons.nightlight_round,
                  label: _config.darkColorMode ? '☀️' : '🌙',
                  onTap: () {
                    setState(
                        () => _config.darkColorMode = !_config.darkColorMode);
                    _saveConfig();
                  },
                ),
                _actionBtn(
                  icon: Icons.settings,
                  label: '⚙️ BD',
                  onTap: () => setState(() => _configOpen = !_configOpen),
                ),
                _actionBtn(
                  icon: Icons.receipt_long,
                  label: '📸 PHOTO',
                  onTap: _compartirVoucherPng,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD9B382),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          padding: EdgeInsets.symmetric(
            horizontal: 12 * _scale,
            vertical: 8 * _scale,
          ),
          minimumSize: Size.zero,
          textStyle: TextStyle(
              fontSize: 11 * _scale, fontWeight: FontWeight.bold),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14 * _scale),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  // ============================================
  // TABS
  // ============================================
  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _tabBtn(0, '🌮 ${t('tortillas')}'),
          _tabBtn(1, '🍺 ${t('cervezas')}'),
        ],
      ),
    );
  }

  Widget _tabBtn(int idx, String label) {
    final active = _tabIndex == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 12 * _scale),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFFD9B382), Color(0xFFC9A06A)],
                  )
                : null,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13 * _scale,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // TAB TORTILLAS
  // ============================================
  Widget _buildTortillasTab() {
    return Column(
      children: [
        Expanded(
          child: _config.scrollSnap
              ? PageView.builder(
                  controller: _tortillasPage,
                  itemCount: tortillas.length,
                  itemBuilder: (context, i) => SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: _tortillaCard(i),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: tortillas.length,
                  itemBuilder: (context, i) => _tortillaCard(i),
                ),
        ),
        _buildVoucherCard('tortillas'),
      ],
    );
  }

  double get _cardMaxWidth => _isDesktop ? 1400 : double.infinity;
  double get _cardHorizontalMargin => _isDesktop ? 20 : 6;

  Widget _tortillaCard(int i) {
    final t = tortillas[i];
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _cardMaxWidth),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: _cardHorizontalMargin,
            vertical: 6,
          ),
          padding: EdgeInsets.all(16 * _scale),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * _scale,
                        color: _textColor(),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * _scale,
                      vertical: 5 * _scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9B382),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      '\$${t.precio.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14 * _scale,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _quantitySelector(
                cantidad: t.cantidad,
                onDec: () {
                  if (t.cantidad > 0) {
                    setState(() => t.cantidad--);
                  }
                },
                onInc: () {
                  setState(() => t.cantidad++);
                },
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '\$${(t.cantidad * t.precio).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB45F2A),
                    fontSize: 16 * _scale,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // TAB CERVEZAS
  // ============================================
  Widget _buildCervezasTab() {
    final totalItems = cervezas.length + 2;
    return Column(
      children: [
        Expanded(
          child: _config.scrollSnap
              ? PageView.builder(
                  controller: _cervezasPage,
                  itemCount: totalItems,
                  itemBuilder: (context, i) => SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: i < cervezas.length
                        ? _cervezaCard(i)
                        : i == cervezas.length
                            ? _mixtoGlobalCard()
                            : _oktoberfestCard(),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: totalItems,
                  itemBuilder: (context, i) => i < cervezas.length
                      ? _cervezaCard(i)
                      : i == cervezas.length
                          ? _mixtoGlobalCard()
                          : _oktoberfestCard(),
                ),
        ),
        _buildVoucherCard('cervezas'),
      ],
    );
  }

  /// 🔥 Card de cerveza con 3 selectores INDEPENDIENTES (SIX/12/24)
  Widget _cervezaCard(int i) {
    final c = cervezas[i];

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _cardMaxWidth),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: _cardHorizontalMargin,
            vertical: 6,
          ),
          padding: EdgeInsets.all(16 * _scale),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * _scale,
                  color: _textColor(),
                ),
              ),
              const SizedBox(height: 12),

              // SIX
              _tipoRow(
                label: '🍺 ${t('six')} (6)',
                precio: c.precioSix,
                cantidad: c.cantidadSix,
                onDec: () {
                  if (c.cantidadSix > 0) {
                    setState(() => c.cantidadSix--);
                  }
                },
                onInc: () => setState(() => c.cantidadSix++),
                subtotal: c.cantidadSix * c.precioSix,
              ),
              const SizedBox(height: 6),

              // CAJA 12
              _tipoRow(
                label: '📦 ${t('caja12')}',
                precio: c.precioCaja12,
                cantidad: c.cantidadCaja12,
                onDec: () {
                  if (c.cantidadCaja12 > 0) {
                    setState(() => c.cantidadCaja12--);
                  }
                },
                onInc: () => setState(() => c.cantidadCaja12++),
                subtotal: c.cantidadCaja12 * c.precioCaja12,
              ),
              const SizedBox(height: 6),

              // CAJA 24
              _tipoRow(
                label: '📦 ${t('caja24')}',
                precio: c.precioCaja24,
                cantidad: c.cantidadCaja24,
                onDec: () {
                  if (c.cantidadCaja24 > 0) {
                    setState(() => c.cantidadCaja24--);
                  }
                },
                onInc: () => setState(() => c.cantidadCaja24++),
                subtotal: c.cantidadCaja24 * c.precioCaja24,
              ),

              // MIXTA (solo si está activa)
              if (c.cantidadMixta > 0 || (mixtaSelections[i] ?? [])
                  .any((s) => (s['cantidad'] ?? 0) > 0)) ...[
                const SizedBox(height: 8),
                _mixtaPanel(i, cervezas),
              ],

              const SizedBox(height: 10),
              Container(height: 1, color: Colors.black.withOpacity(0.1)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '💰 ${t('total')}:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14 * _scale,
                      color: _textColor(),
                    ),
                  ),
                  Text(
                    '\$${_totalCerveza(c).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB45F2A),
                      fontSize: 18 * _scale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 Fila de tipo: label + precio + [ - cantidad + ] + subtotal
  Widget _tipoRow({
    required String label,
    required double precio,
    required int cantidad,
    required VoidCallback onDec,
    required VoidCallback onInc,
    required double subtotal,
  }) {
    final activo = cantidad > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: 10 * _scale,
        vertical: 8 * _scale,
      ),
      decoration: BoxDecoration(
        color: activo
            ? const Color(0xFF11998E).withOpacity(0.12)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: activo
              ? const Color(0xFF11998E)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Label + precio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13 * _scale,
                    color: _textColor(),
                  ),
                ),
                Text(
                  '\$${precio.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 11 * _scale,
                    color: _textColor().withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Contador
          _miniCircleBtn(Icons.remove, onDec),
          SizedBox(
            width: 36 * _scale,
            child: Center(
              child: Text(
                '$cantidad',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * _scale,
                  color: _textColor(),
                ),
              ),
            ),
          ),
          _miniCircleBtn(Icons.add, onInc),
          const SizedBox(width: 8),
          // Subtotal
          SizedBox(
            width: 70 * _scale,
            child: Text(
              '\$${subtotal.toStringAsFixed(0)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14 * _scale,
                color: activo
                    ? const Color(0xFF11998E)
                    : _textColor().withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCircleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 32 * _scale,
          height: 32 * _scale,
          decoration: const BoxDecoration(
            color: Color(0xFFC29A6B),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18 * _scale),
        ),
      ),
    );
  }

  // ============================================
  // PANEL MIXTA
  // ============================================
  Widget _mixtaPanel(int idx, List<Cerveza> disponibles) {
    final max = mixtaTypeSelections[idx] == 'six'
        ? 6
        : mixtaTypeSelections[idx] == 'caja12'
            ? 12
            : 24;
    final sel = mixtaSelections[idx] ?? [];
    final total = sel.fold<int>(0, (s, e) => s + (e['cantidad'] ?? 0));
    final d = mixtaDescuento[idx] ?? {'activo': false, 'pct': 0};

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(10 * _scale),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFFD9B382), width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: mixtaTypeSelections[idx],
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                      value: 'six',
                      child: Text('🍺 SIX (Máx 6)',
                          style: TextStyle(fontSize: 13 * _scale))),
                  DropdownMenuItem(
                      value: 'caja12',
                      child: Text('📦 CAJA 12 (Máx 12)',
                          style: TextStyle(fontSize: 13 * _scale))),
                  DropdownMenuItem(
                      value: 'caja24',
                      child: Text('📦 CAJA 24 (Máx 24)',
                          style: TextStyle(fontSize: 13 * _scale))),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => mixtaTypeSelections[idx] = v);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * _scale,
              vertical: 4 * _scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFD9B382),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              'Total: $total / $max',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12 * _scale,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: d['activo'] == true,
                onChanged: (v) => setState(() {
                  mixtaDescuento[idx] ??= {'activo': false, 'pct': 0};
                  mixtaDescuento[idx]!['activo'] = v ?? false;
                }),
              ),
              Text(t('discount'),
                  style:
                      TextStyle(fontSize: 12 * _scale, color: _textColor())),
              const SizedBox(width: 8),
              SizedBox(
                width: 60 * _scale,
                child: TextFormField(
                  initialValue: (d['pct'] ?? 0).toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final n = double.tryParse(v) ?? 0;
                    mixtaDescuento[idx]!['pct'] = n;
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  ),
                  style: TextStyle(fontSize: 12 * _scale),
                ),
              ),
              const SizedBox(width: 4),
              Text('%', style: TextStyle(fontSize: 12 * _scale)),
            ],
          ),
          const SizedBox(height: 4),
          ...disponibles.map((cer) {
            final item = sel.firstWhere((s) => s['id'] == cer.id,
                orElse: () => {'id': cer.id, 'cantidad': 0});
            final qty = item['cantidad'] ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '🍺 ${cer.nombre}',
                      style: TextStyle(
                          fontSize: 11 * _scale, color: _textColor()),
                    ),
                  ),
                  SizedBox(
                    width: 55 * _scale,
                    child: TextFormField(
                      initialValue: qty.toString(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onChanged: (v) {
                        var n = int.tryParse(v) ?? 0;
                        if (n > max) n = max;
                        setState(() {
                          item['cantidad'] = n;
                        });
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      ),
                      style: TextStyle(fontSize: 12 * _scale),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                      '\$${(cer.precioSix / 6).toStringAsFixed(2)} ${t('unit_price')}',
                      style: TextStyle(
                          fontSize: 10 * _scale, color: _textColor())),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final t2 =
                    sel.fold<int>(0, (s, e) => s + (e['cantidad'] ?? 0));
                if (t2 == 0) {
                  _showToast('Selecciona al menos una unidad', error: true);
                  return;
                }
                setState(() {
                  if (idx >= 0) {
                    cervezas[idx].cantidadMixta = t2;
                  }
                });
                _showToast('✅ Mixta aplicada: $t2 unidades');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC29A6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                padding: EdgeInsets.symmetric(vertical: 8 * _scale),
              ),
              child: Text('✅ ${t('apply')}',
                  style: TextStyle(fontSize: 12 * _scale)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // MIXTO GLOBAL
  // ============================================
  Widget _mixtoGlobalCard() {
    final idx = -1;
    final sel = mixtaSelections[idx] ?? [];
    final total = sel.fold<int>(0, (s, e) => s + (e['cantidad'] ?? 0));

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _cardMaxWidth),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: _cardHorizontalMargin,
            vertical: 6,
          ),
          padding: EdgeInsets.all(16 * _scale),
          decoration: _cardDecoration(borderLeft: const Color(0xFF9C27B0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔄 ${t('mixto_global')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * _scale,
                  color: _textColor(),
                ),
              ),
              _mixtaPanel(idx, cervezas),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Unidades: $total — \$${(_calcMixtaTotal(idx)['neto'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                    fontSize: 14 * _scale,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // OKTOBERFEST
  // ============================================
  Widget _oktoberfestCard() {
    final idx = -2;
    final okto = cervezas
        .where((c) => [
              'OKTOBERFEST',
              'PAN DE MUERTO DUBBEL',
              'CANDY CORN BROWN ALE'
            ].contains(c.nombre))
        .toList();
    final sel = mixtaSelections[idx] ?? [];
    final total = sel.fold<int>(0, (s, e) => s + (e['cantidad'] ?? 0));

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _cardMaxWidth),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: _cardHorizontalMargin,
            vertical: 6,
          ),
          padding: EdgeInsets.all(16 * _scale),
          decoration: _cardDecoration(borderLeft: const Color(0xFFFF9800)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎃 ${t('oktoberfest')} (3)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * _scale,
                  color: _textColor(),
                ),
              ),
              _mixtaPanel(idx, okto),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Unidades: $total — \$${(_calcMixtaTotal(idx)['neto'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF9800),
                    fontSize: 14 * _scale,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // HELPERS DISEÑO
  // ============================================
  Color _textColor() => _config.darkColorMode
      ? const Color(0xFFF5CF9B)
      : const Color(0xFF4A2C1A);

  BoxDecoration _cardDecoration({Color? borderLeft}) {
    final bg = _config.darkColorMode ? const Color(0xFF2D322E) : Colors.white;
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      border: Border(
        left: BorderSide(color: borderLeft ?? Colors.transparent, width: 4),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _quantitySelector({
    required int cantidad,
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6 * _scale),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _circleBtn(Icons.remove, onDec),
          SizedBox(
            width: 50 * _scale,
            child: Center(
              child: Text(
                '$cantidad',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18 * _scale,
                  color: _textColor(),
                ),
              ),
            ),
          ),
          _circleBtn(Icons.add, onInc),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 40 * _scale,
          height: 40 * _scale,
          decoration: const BoxDecoration(
            color: Color(0xFFC29A6B),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22 * _scale),
        ),
      ),
    );
  }

  // ============================================
  // VOUCHER CARD
  // ============================================
  Widget _buildVoucherCard(String type) {
    final isTortillas = type == 'tortillas';
    final items = isTortillas ? voucherTortillas : voucherCervezas;
    final total = isTortillas ? totalTortillas : totalCervezas;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: EdgeInsets.all(10 * _scale),
      decoration: BoxDecoration(
        color: const Color(0xFF2C241A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isTortillas
                      ? '🌮 ${t('voucher_t')}'
                      : '🍺 ${t('voucher_c')}',
                  style: TextStyle(
                    color: const Color(0xFFFFEFCF),
                    fontWeight: FontWeight.bold,
                    fontSize: 12 * _scale,
                  ),
                ),
              ),
              GestureDetector(
                onTap: isTortillas ? _resetTortillas : _resetCervezas,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * _scale,
                    vertical: 4 * _scale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9E6A42),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    '🧹 ${t('clean')}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10 * _scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            constraints: BoxConstraints(maxHeight: 90 * _scale),
            child: SingleChildScrollView(
              child: items.isEmpty
                  ? Text(t('no_products'),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11 * _scale,
                      ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items
                          .map((s) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 1),
                                child: Text(
                                  '📦 $s',
                                  style: TextStyle(
                                    color: const Color(0xFFFFEFCF),
                                    fontSize: 11 * _scale,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6 * _scale),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${t('total')}:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12 * _scale,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: const Color(0xFFFFD08A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15 * _scale,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: items.isEmpty
                    ? null
                    : () {
                        final msg = items.join('\n');
                        _launchWhatsApp(
                            'Pedido de ${isTortillas ? "tortillas" : "cervezas"}\n\n$msg\n\nTOTAL: \$${total.toStringAsFixed(0)}');
                      },
                icon: const Icon(Icons.message, size: 14),
                label: Text('📲 ${t('whatsapp')}',
                    style: TextStyle(fontSize: 10 * _scale)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  padding: EdgeInsets.symmetric(
                      horizontal: 10 * _scale, vertical: 4 * _scale),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _compartirVoucherPng,
                icon: const Icon(Icons.image, size: 14),
                label: Text('📸 PNG',
                    style: TextStyle(fontSize: 10 * _scale)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  padding: EdgeInsets.symmetric(
                      horizontal: 10 * _scale, vertical: 4 * _scale),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // CONFIG PANEL
  // ============================================
  Widget _buildConfigPanel() {
    final media = MediaQuery.of(context);
    final panelWidth = media.size.width < 768 ? media.size.width : 420.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      right: _configOpen ? 0 : -panelWidth - 20,
      width: panelWidth,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF14141E).withOpacity(0.94),
            border: Border(
              left: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 50,
                offset: const Offset(-10, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(22 * _scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t('settings'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () => setState(() => _configOpen = false),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  _configLabel(Icons.language, t('language')),
                  const SizedBox(height: 8),
                  _buildButtonGrid(
                    items: [
                      _BtnItem('es', 'Español'),
                      _BtnItem('en', 'English'),
                      _BtnItem('ja', '日本語'),
                      _BtnItem('zh', '中文'),
                    ],
                    selected: _config.language,
                    columns: 2,
                    onSelected: (v) {
                      setState(() => _config.language = v);
                      _saveConfig();
                    },
                  ),
                  const SizedBox(height: 20),

                  _configLabel(Icons.palette, t('color_theme')),
                  const SizedBox(height: 8),
                  _buildButtonGrid(
                    items: [
                      _BtnItem('arcoiris', t('arcoiris'),
                          icon: Icons.gradient),
                      _BtnItem('negro', t('negro'), colorDot: Colors.black),
                      _BtnItem('rojo', t('rojo'),
                          colorDot: const Color(0xFFFF4444)),
                      _BtnItem('verde', t('verde'),
                          colorDot: const Color(0xFF44FF44)),
                      _BtnItem('amarillo', t('amarillo'),
                          colorDot: const Color(0xFFFFFF44)),
                      _BtnItem('naranja', t('naranja'),
                          colorDot: const Color(0xFFFFAA44)),
                      _BtnItem('azul', t('azul'),
                          colorDot: const Color(0xFF4444FF)),
                    ],
                    selected: _config.color,
                    columns: 3,
                    onSelected: (v) {
                      setState(() => _config.color = v);
                      _saveConfig();
                    },
                  ),
                  const SizedBox(height: 20),

                  _configLabel(Icons.devices, t('device_mode')),
                  const SizedBox(height: 8),
                  _buildButtonGrid(
                    items: [
                      _BtnItem('escritorio', t('escritorio'), icon: Icons.tv),
                      _BtnItem('movil', t('movil'), icon: Icons.smartphone),
                    ],
                    selected: _config.deviceMode,
                    columns: 2,
                    onSelected: (v) {
                      setState(() => _config.deviceMode = v);
                      _saveConfig();
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _configLabel(Icons.aspect_ratio, t('button_size')),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '${(_buttonScalePreview * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white24,
                    ),
                    child: Slider(
                      value: _buttonScalePreview,
                      min: 0.6,
                      max: 1.5,
                      divisions: 18,
                      onChanged: (v) {
                        setState(() => _buttonScalePreview = v);
                        _scaleDebounce?.cancel();
                        _scaleDebounce =
                            Timer(const Duration(milliseconds: 400), () {
                          _config.buttonScale = _buttonScalePreview;
                          _saveConfig();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12 * _scale, vertical: 4 * _scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.view_carousel,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t('scroll_snap'),
                            style: TextStyle(
                                color: Colors.white, fontSize: 14 * _scale),
                          ),
                        ),
                        Switch(
                          value: _config.scrollSnap,
                          onChanged: (v) {
                            setState(() => _config.scrollSnap = v);
                            _saveConfig();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12 * _scale, vertical: 4 * _scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.dark_mode,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t('dark_color_mode'),
                            style: TextStyle(
                                color: Colors.white, fontSize: 14 * _scale),
                          ),
                        ),
                        Switch(
                          value: _config.darkColorMode,
                          onChanged: (v) {
                            setState(() => _config.darkColorMode = v);
                            _saveConfig();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _configLabel(Icons.water_drop, t('transparency')),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '$_transparencyPreview%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white24,
                    ),
                    child: Slider(
                      value: _transparencyPreview.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (v) {
                        setState(() => _transparencyPreview = v.round());
                        _transparencyDebounce?.cancel();
                        _transparencyDebounce =
                            Timer(const Duration(milliseconds: 400), () {
                          _config.transparency = _transparencyPreview;
                          _saveConfig();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _configLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14 * _scale,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonGrid({
    required List<_BtnItem> items,
    required String selected,
    required int columns,
    required ValueChanged<String> onSelected,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.4,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final isSelected = item.value == selected;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => onSelected(item.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.icon != null)
                    Icon(item.icon, color: Colors.white, size: 14)
                  else if (item.colorDot != null)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item.colorDot,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  if (item.icon != null || item.colorDot != null)
                    const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BtnItem {
  final String value;
  final String label;
  final IconData? icon;
  final Color? colorDot;
  const _BtnItem(this.value, this.label, {this.icon, this.colorDot});
}