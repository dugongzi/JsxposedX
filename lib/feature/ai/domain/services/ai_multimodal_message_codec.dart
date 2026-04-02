import 'dart:convert';
import 'dart:typed_data';

import 'package:JsxposedX/core/utils/file_picker_util.dart';

enum AiMultimodalAttachmentKind {
  image,
  text,
}

class AiMultimodalAttachmentData {
  const AiMultimodalAttachmentData({
    required this.kind,
    required this.fileName,
    required this.mimeType,
    required this.size,
    this.dataBase64,
    this.textContent,
  });

  final AiMultimodalAttachmentKind kind;
  final String fileName;
  final String mimeType;
  final int size;
  final String? dataBase64;
  final String? textContent;

  Uint8List? get imageBytes {
    if (kind != AiMultimodalAttachmentKind.image || dataBase64 == null) {
      return null;
    }
    try {
      return base64Decode(dataBase64!);
    } catch (_) {
      return null;
    }
  }

  bool get isImage => kind == AiMultimodalAttachmentKind.image;

  bool get isTextFile => kind == AiMultimodalAttachmentKind.text;

  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    }
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    }
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class AiMultimodalParsedMessage {
  const AiMultimodalParsedMessage({
    required this.text,
    required this.attachments,
  });

  final String text;
  final List<AiMultimodalAttachmentData> attachments;

  bool get hasText => text.trim().isNotEmpty;

  bool get hasAttachments => attachments.isNotEmpty;
}

class AiMultimodalMessageCodec {
  AiMultimodalMessageCodec._();

  static const String _prefix = '[ai_multimodal_v1]';
  static const int _maxImageBytes = 4 * 1024 * 1024;
  static const int _maxTextFileBytes = 256 * 1024;

  static const Set<String> _imageExtensions = {
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
    'bmp',
    'heic',
  };

  static const Set<String> _textExtensions = {
    'txt',
    'md',
    'markdown',
    'json',
    'xml',
    'html',
    'htm',
    'js',
    'ts',
    'jsx',
    'tsx',
    'java',
    'kt',
    'kts',
    'dart',
    'py',
    'log',
    'yaml',
    'yml',
    'properties',
    'csv',
    'ini',
    'cfg',
    'conf',
    'sh',
    'smali',
    'gradle',
    'sql',
  };

  static String encodeFromPickedFiles({
    required String text,
    required List<PickedFileData> attachments,
  }) {
    if (attachments.isEmpty) {
      return text;
    }

    final normalizedText = text.trim();
    final payload = _AiMultimodalPayload(
      text: normalizedText,
      attachments: attachments
          .map(_AiMultimodalAttachment.fromPickedFile)
          .toList(growable: false),
    );
    return '$_prefix${jsonEncode(payload.toJson())}';
  }

  static bool isEncoded(String content) {
    return content.startsWith(_prefix);
  }

  static bool hasAttachments(String content) {
    final payload = tryParse(content);
    if (payload == null) {
      return false;
    }
    return payload.attachments.isNotEmpty;
  }

  static bool canEditText(String content) {
    final payload = tryParse(content);
    if (payload == null) {
      return content.trim().isNotEmpty;
    }
    return payload.text.trim().isNotEmpty;
  }

  static String extractEditableText(String content) {
    final payload = tryParse(content);
    if (payload == null) {
      return content;
    }
    return payload.text;
  }

  static String replaceUserText(String content, String nextText) {
    final normalizedText = nextText.trim();
    final payload = tryParse(content);
    if (payload == null) {
      return normalizedText;
    }
    return '$_prefix${jsonEncode(payload.copyWith(text: normalizedText).toJson())}';
  }

  static AiMultimodalParsedMessage? parse(String content) {
    final payload = tryParse(content);
    if (payload == null) {
      return null;
    }
    return AiMultimodalParsedMessage(
      text: payload.text,
      attachments: payload.attachments
          .map((attachment) => attachment.toPublicData())
          .toList(growable: false),
    );
  }

  static bool hasImageAttachments(String content) {
    final payload = tryParse(content);
    if (payload == null) {
      return false;
    }
    return payload.attachments.any(
      (attachment) => attachment.kind == _AiAttachmentKind.image,
    );
  }

  static String toDisplayText(
    String content, {
    required bool isZh,
  }) {
    final payload = tryParse(content);
    if (payload == null) {
      return content;
    }

    final lines = <String>[];
    final text = payload.text.trim();
    if (text.isNotEmpty) {
      lines.add(text);
    }

    final summaries = payload.attachments
        .map((attachment) => attachment.toDisplaySummary(isZh: isZh))
        .toList(growable: false);
    if (summaries.isNotEmpty) {
      lines.add(
        isZh
            ? '附件: ${summaries.join(' | ')}'
            : 'Attachments: ${summaries.join(' | ')}',
      );
    }

    return lines.join('\n\n').trim();
  }

  static String toSemanticText(
    String content, {
    required bool isZh,
  }) {
    final payload = tryParse(content);
    if (payload == null) {
      return content;
    }

    final buffer = StringBuffer();
    final text = payload.text.trim();
    if (text.isNotEmpty) {
      buffer.write(text);
    }

    final summaries = payload.attachments
        .map((attachment) => attachment.toSemanticSummary(isZh: isZh))
        .where((summary) => summary.isNotEmpty)
        .toList(growable: false);
    if (summaries.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.write('\n');
      }
      buffer.write(
        isZh
            ? '附件信息: ${summaries.join('；')}'
            : 'Attachment summary: ${summaries.join('; ')}',
      );
    }

    return buffer.toString().trim();
  }

  static String appendUserText(String content, String suffix) {
    final trimmedSuffix = suffix.trim();
    if (trimmedSuffix.isEmpty) {
      return content;
    }

    final payload = tryParse(content);
    if (payload == null) {
      final base = content.trimRight();
      if (base.isEmpty) {
        return trimmedSuffix;
      }
      return '$base\n\n$trimmedSuffix';
    }

    final currentText = payload.text.trimRight();
    final nextText = currentText.isEmpty
        ? trimmedSuffix
        : '$currentText\n\n$trimmedSuffix';
    return '$_prefix${jsonEncode(payload.copyWith(text: nextText).toJson())}';
  }

  static List<Map<String, dynamic>> toOpenAiContent(
    String content, {
    required bool isZh,
  }) {
    final payload = tryParse(content);
    if (payload == null) {
      return [
        {
          'type': 'text',
          'text': content,
        },
      ];
    }

    final parts = <Map<String, dynamic>>[];
    final text = payload.text.trim();
    if (text.isNotEmpty) {
      parts.add({
        'type': 'text',
        'text': text,
      });
    }

    for (final attachment in payload.attachments) {
      switch (attachment.kind) {
        case _AiAttachmentKind.image:
          parts.add({
            'type': 'image_url',
            'image_url': {
              'url':
                  'data:${attachment.mimeType};base64,${attachment.dataBase64}',
            },
          });
          break;
        case _AiAttachmentKind.text:
          parts.add({
            'type': 'text',
            'text': attachment.toTextBlock(isZh: isZh),
          });
          break;
      }
    }

    if (parts.isEmpty) {
      parts.add({
        'type': 'text',
        'text': '',
      });
    }
    return parts;
  }

  static List<Map<String, dynamic>> toAnthropicContent(
    String content, {
    required bool isZh,
  }) {
    final payload = tryParse(content);
    if (payload == null) {
      return [
        {
          'type': 'text',
          'text': content,
        },
      ];
    }

    final parts = <Map<String, dynamic>>[];
    final text = payload.text.trim();
    if (text.isNotEmpty) {
      parts.add({
        'type': 'text',
        'text': text,
      });
    }

    for (final attachment in payload.attachments) {
      switch (attachment.kind) {
        case _AiAttachmentKind.image:
          parts.add({
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': attachment.mimeType,
              'data': attachment.dataBase64,
            },
          });
          break;
        case _AiAttachmentKind.text:
          parts.add({
            'type': 'text',
            'text': attachment.toTextBlock(isZh: isZh),
          });
          break;
      }
    }

    if (parts.isEmpty) {
      parts.add({
        'type': 'text',
        'text': '',
      });
    }
    return parts;
  }

  static _AiMultimodalPayload? tryParse(String content) {
    if (!isEncoded(content)) {
      return null;
    }

    final rawPayload = content.substring(_prefix.length);
    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return _AiMultimodalPayload.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static String guessMimeType(String fileName, String? extension) {
    final normalizedExtension = (extension ?? _extensionFromName(fileName))
        .toLowerCase();
    return switch (normalizedExtension) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'bmp' => 'image/bmp',
      'heic' => 'image/heic',
      'json' => 'application/json',
      'xml' => 'application/xml',
      'html' || 'htm' => 'text/html',
      'csv' => 'text/csv',
      'md' || 'markdown' => 'text/markdown',
      'yaml' || 'yml' => 'application/yaml',
      'log' => 'text/plain',
      'txt' => 'text/plain',
      _ => 'text/plain',
    };
  }

  static bool isImageExtension(String? extension) {
    return _imageExtensions.contains((extension ?? '').toLowerCase());
  }

  static bool isTextExtension(String? extension) {
    return _textExtensions.contains((extension ?? '').toLowerCase());
  }

  static String _extensionFromName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1);
  }
}

enum _AiAttachmentKind {
  image,
  text,
}

class _AiMultimodalPayload {
  const _AiMultimodalPayload({
    required this.text,
    required this.attachments,
  });

  final String text;
  final List<_AiMultimodalAttachment> attachments;

  _AiMultimodalPayload copyWith({
    String? text,
    List<_AiMultimodalAttachment>? attachments,
  }) {
    return _AiMultimodalPayload(
      text: text ?? this.text,
      attachments: attachments ?? this.attachments,
    );
  }

  factory _AiMultimodalPayload.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'] as List?;
    return _AiMultimodalPayload(
      text: json['text']?.toString() ?? '',
      attachments: rawAttachments
              ?.whereType<Map>()
              .map(
                (item) => _AiMultimodalAttachment.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false) ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'attachments': attachments.map((attachment) => attachment.toJson()).toList(
            growable: false,
          ),
    };
  }
}

class _AiMultimodalAttachment {
  const _AiMultimodalAttachment({
    required this.kind,
    required this.fileName,
    required this.mimeType,
    required this.size,
    this.dataBase64,
    this.textContent,
  });

  final _AiAttachmentKind kind;
  final String fileName;
  final String mimeType;
  final int size;
  final String? dataBase64;
  final String? textContent;

  factory _AiMultimodalAttachment.fromPickedFile(PickedFileData file) {
    final extension = (file.extension ?? '').toLowerCase();
    if (AiMultimodalMessageCodec.isImageExtension(extension)) {
      if (file.size > AiMultimodalMessageCodec._maxImageBytes) {
        throw Exception(
          '图片过大，当前最多支持 4 MB: ${file.fileName}',
        );
      }
      return _AiMultimodalAttachment(
        kind: _AiAttachmentKind.image,
        fileName: file.fileName,
        mimeType: AiMultimodalMessageCodec.guessMimeType(
          file.fileName,
          file.extension,
        ),
        size: file.size,
        dataBase64: base64Encode(file.bytes),
      );
    }

    if (AiMultimodalMessageCodec.isTextExtension(extension)) {
      if (file.size > AiMultimodalMessageCodec._maxTextFileBytes) {
        throw Exception(
          '文本文件过大，当前最多支持 256 KB: ${file.fileName}',
        );
      }
      return _AiMultimodalAttachment(
        kind: _AiAttachmentKind.text,
        fileName: file.fileName,
        mimeType: AiMultimodalMessageCodec.guessMimeType(
          file.fileName,
          file.extension,
        ),
        size: file.size,
        textContent: utf8.decode(file.bytes, allowMalformed: true),
      );
    }

    throw Exception(
      '当前只支持图片和文本类文件: ${file.fileName}',
    );
  }

  factory _AiMultimodalAttachment.fromJson(Map<String, dynamic> json) {
    final kindValue = json['kind']?.toString() ?? 'text';
    return _AiMultimodalAttachment(
      kind: kindValue == 'image'
          ? _AiAttachmentKind.image
          : _AiAttachmentKind.text,
      fileName: json['file_name']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? 'text/plain',
      size: (json['size'] as num?)?.toInt() ?? 0,
      dataBase64: json['data_base64']?.toString(),
      textContent: json['text_content']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.name,
      'file_name': fileName,
      'mime_type': mimeType,
      'size': size,
      if (dataBase64 != null) 'data_base64': dataBase64,
      if (textContent != null) 'text_content': textContent,
    };
  }

  String toDisplaySummary({
    required bool isZh,
  }) {
    final kindLabel = switch (kind) {
      _AiAttachmentKind.image => isZh ? '图片' : 'Image',
      _AiAttachmentKind.text => isZh ? '文本文件' : 'Text file',
    };
    return '$kindLabel $fileName (${_formatSize(size)})';
  }

  String toSemanticSummary({
    required bool isZh,
  }) {
    final kindLabel = switch (kind) {
      _AiAttachmentKind.image => isZh ? '图片' : 'image',
      _AiAttachmentKind.text => isZh ? '文本文件' : 'text file',
    };
    return '$kindLabel $fileName';
  }

  String toTextBlock({
    required bool isZh,
  }) {
    final label = isZh ? '附件文本' : 'Attached file';
    final contentLabel = isZh ? '文件内容' : 'File content';
    final normalizedContent = (textContent ?? '').trim();
    return '[$label: $fileName]\n$contentLabel:\n$normalizedContent';
  }

  AiMultimodalAttachmentData toPublicData() {
    return AiMultimodalAttachmentData(
      kind: kind == _AiAttachmentKind.image
          ? AiMultimodalAttachmentKind.image
          : AiMultimodalAttachmentKind.text,
      fileName: fileName,
      mimeType: mimeType,
      size: size,
      dataBase64: dataBase64,
      textContent: textContent,
    );
  }

  static String _formatSize(int size) {
    if (size < 1024) {
      return '$size B';
    }
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    }
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
