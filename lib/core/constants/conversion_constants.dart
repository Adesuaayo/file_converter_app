/// Conversion-specific constants and type definitions.

/// Supported conversion types enumerated for type safety.
enum ConversionType {
  docxToPdf('DOCX → PDF', 'docx', 'pdf'),
  pdfToTxt('PDF → TXT', 'pdf', 'txt'),
  txtToPdf('TXT → PDF', 'txt', 'pdf'),
  imageToPdf('Image → PDF', 'image', 'pdf'),
  pdfToImage('PDF → Images', 'pdf', 'image');

  const ConversionType(this.label, this.inputType, this.outputType);
  final String label;
  final String inputType;
  final String outputType;
}

/// PDF page size options for output customization
enum PdfPageSize {
  a4('A4', 595.28, 841.89),
  letter('Letter', 612.0, 792.0),
  legal('Legal', 612.0, 1008.0),
  a3('A3', 841.89, 1190.55),
  a5('A5', 420.94, 595.28);

  const PdfPageSize(this.label, this.width, this.height);
  final String label;
  final double width;
  final double height;
}

/// PDF compression levels
enum CompressionLevel {
  low('Low', 'Larger file, better quality', 100),
  medium('Medium', 'Balanced', 75),
  high('High', 'Smaller file, good quality', 50),
  maximum('Maximum', 'Smallest file', 25);

  const CompressionLevel(this.label, this.description, this.quality);
  final String label;
  final String description;
  final int quality;
}

/// Image output quality
enum ImageQuality {
  low('Low', 50),
  medium('Medium', 75),
  high('High', 90),
  original('Original', 100);

  const ImageQuality(this.label, this.quality);
  final String label;
  final int quality;
}

/// Image output format when converting PDF → Images
enum ImageOutputFormat {
  png('PNG', 'png'),
  jpg('JPG', 'jpg');

  const ImageOutputFormat(this.label, this.extension);
  final String label;
  final String extension;
}

/// Conversion status tracking
enum ConversionStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

/// Maps file extensions to their MIME types for auto-detection
class MimeTypes {
  MimeTypes._();

  static const Map<String, String> extensionToMime = {
    'pdf': 'application/pdf',
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'txt': 'text/plain',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
  };

  static String? getMimeType(String extension) {
    return extensionToMime[extension.toLowerCase()];
  }
}
