class MeasurementFieldSpec {
  final String label;
  final String hint;
  final bool required;

  const MeasurementFieldSpec({
    required this.label,
    this.hint = '',
    this.required = true,
  });
}

class StylingOptionSpec {
  final String label;
  final bool needsText;
  final String textHint;

  const StylingOptionSpec(
    this.label, {
    this.needsText = false,
    this.textHint = '',
  });
}

class StylingSectionSpec {
  final String title;
  final List<StylingOptionSpec> options;
  final bool required;
  final String helper;

  const StylingSectionSpec({
    required this.title,
    required this.options,
    this.required = true,
    this.helper = '',
  });
}

class TailorProductSpec {
  final String key;
  final String name;
  final String department;
  final String description;
  final List<String> componentKeys;
  final List<String> sizeOptions;
  final String sizeLabel;
  final List<MeasurementFieldSpec> measurementFields;
  final List<StylingSectionSpec> stylingSections;

  const TailorProductSpec({
    required this.key,
    required this.name,
    required this.department,
    required this.description,
    this.componentKeys = const [],
    this.sizeOptions = const [],
    this.sizeLabel = 'Size',
    this.measurementFields = const [],
    this.stylingSections = const [],
  });

  bool get isComposite => componentKeys.isNotEmpty;
  bool get needsMeasurements => measurementFields.isNotEmpty;
  bool get needsStyling => stylingSections.any((section) => section.required);
}

class PackageAllocation {
  final String productKey;
  final int quantity;

  const PackageAllocation({required this.productKey, required this.quantity});
}

class WardrobePackageSpec {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String priceLabel;
  final List<PackageAllocation> allocations;

  const WardrobePackageSpec({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.priceLabel,
    required this.allocations,
  });
}

class MeasurementEntry {
  final String body;
  final String finished;
  final String remarks;

  const MeasurementEntry({
    this.body = '',
    this.finished = '',
    this.remarks = '',
  });

  MeasurementEntry copyWith({String? body, String? finished, String? remarks}) {
    return MeasurementEntry(
      body: body ?? this.body,
      finished: finished ?? this.finished,
      remarks: remarks ?? this.remarks,
    );
  }

  bool get hasValue => body.trim().isNotEmpty || finished.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'body': body,
        'finished': finished,
        'remarks': remarks,
      };
}

class TailorOrderItem {
  final String id;
  final String productKey;
  final String productName;
  final Map<String, String> sizes;
  final Map<String, MeasurementEntry> measurements;
  final Map<String, String> stylingSelections;
  final Map<String, String> stylingNotes;
  final String notes;
  final DateTime createdAt;

  const TailorOrderItem({
    required this.id,
    required this.productKey,
    required this.productName,
    required this.sizes,
    required this.measurements,
    required this.stylingSelections,
    required this.stylingNotes,
    required this.notes,
    required this.createdAt,
  });

  factory TailorOrderItem.empty(TailorProductSpec product) {
    final measurements = <String, MeasurementEntry>{};
    final sizes = <String, String>{};

    for (final component in TailorCatalog.componentsFor(product.key)) {
      sizes[component.key] = '';
      for (final field in component.measurementFields) {
        measurements[TailorCatalog.measurementKey(component.key, field.label)] =
            const MeasurementEntry();
      }
    }

    return TailorOrderItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      productKey: product.key,
      productName: product.name,
      sizes: sizes,
      measurements: measurements,
      stylingSelections: const {},
      stylingNotes: const {},
      notes: '',
      createdAt: DateTime.now(),
    );
  }

  TailorOrderItem copyWith({
    Map<String, String>? sizes,
    Map<String, MeasurementEntry>? measurements,
    Map<String, String>? stylingSelections,
    Map<String, String>? stylingNotes,
    String? notes,
  }) {
    return TailorOrderItem(
      id: id,
      productKey: productKey,
      productName: productName,
      sizes: sizes ?? this.sizes,
      measurements: measurements ?? this.measurements,
      stylingSelections: stylingSelections ?? this.stylingSelections,
      stylingNotes: stylingNotes ?? this.stylingNotes,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

class DepartmentPrintForm {
  final TailorOrderItem item;
  final TailorProductSpec component;
  final TailorProductSpec parent;

  const DepartmentPrintForm({
    required this.item,
    required this.component,
    required this.parent,
  });

  String get title => parent.isComposite
      ? '${parent.name} - ${component.name}'
      : parent.name;

  String get department => component.department;
}

class TailorCatalog {
  static const shirtKey = 'shirt';
  static const coatKey = 'coat';
  static const pantKey = 'pant';
  static const waistcoatKey = 'waistcoat';
  static const kameezKey = 'kameez';
  static const shalwarKey = 'shalwar';
  static const tieKey = 'tie';
  static const pocketSquareKey = 'pocket_square';
  static const twoPieceSuitKey = 'two_piece_suit';
  static const threePieceSuitKey = 'three_piece_suit';
  static const blazerKey = 'blazer';
  static const trouserKey = 'trouser';
  static const shalwarKameezKey = 'shalwar_kameez';

  static String measurementKey(String componentKey, String fieldLabel) =>
      '$componentKey::$fieldLabel';

  static String styleKey(String componentKey, String sectionTitle) =>
      '$componentKey::$sectionTitle';

  static final List<String> shirtSizeOptions = _quarterPairs(
    start: 12,
    end: 18,
    finishedOffset: 7,
  );

  static final List<String> waistSizeOptions = _halfPairs(
    start: 24,
    end: 46,
    finishedOffset: 24,
  );

  static final List<String> chestSizeOptions = _halfPairs(
    start: 30,
    end: 52,
    finishedOffset: 15,
  );

  static final List<TailorProductSpec> productSpecs = [
    TailorProductSpec(
      key: shirtKey,
      name: 'Shirt',
      department: 'Shirt Department',
      description: 'Separate shirt measurements and shirt-only styling.',
      sizeLabel: 'Neck size / finished collar',
      sizeOptions: shirtSizeOptions,
      measurementFields: [
        MeasurementFieldSpec(label: 'Chest'),
        MeasurementFieldSpec(label: 'Waist'),
        MeasurementFieldSpec(label: 'Hip'),
        MeasurementFieldSpec(label: 'Yoke'),
        MeasurementFieldSpec(label: 'Length'),
        MeasurementFieldSpec(label: 'Sleeve'),
        MeasurementFieldSpec(label: 'Neck'),
        MeasurementFieldSpec(label: 'Wrist'),
      ],
      stylingSections: shirtStyling,
    ),
    TailorProductSpec(
      key: coatKey,
      name: 'Coat',
      department: 'Coat Department',
      description: 'Coat, blazer and suit jacket measurements.',
      sizeLabel: 'Chest size / finished coat',
      sizeOptions: chestSizeOptions,
      measurementFields: [
        MeasurementFieldSpec(label: 'Chest'),
        MeasurementFieldSpec(label: 'Waist'),
        MeasurementFieldSpec(label: 'Hip'),
        MeasurementFieldSpec(label: 'Yoke'),
        MeasurementFieldSpec(label: 'Length'),
        MeasurementFieldSpec(label: 'Sleeve'),
        MeasurementFieldSpec(label: 'Neck'),
        MeasurementFieldSpec(label: 'Wrist'),
        MeasurementFieldSpec(label: 'Half Back'),
        MeasurementFieldSpec(label: 'Cross Back'),
        MeasurementFieldSpec(label: 'Left Shoulder'),
        MeasurementFieldSpec(label: 'Right Shoulder'),
      ],
      stylingSections: coatStyling,
    ),
    TailorProductSpec(
      key: pantKey,
      name: 'Pant / Trouser',
      department: 'Pant Department',
      description: 'Pant and trouser measurements.',
      sizeLabel: 'Waist size / finished waist',
      sizeOptions: waistSizeOptions,
      measurementFields: [
        MeasurementFieldSpec(label: 'Length'),
        MeasurementFieldSpec(label: 'Waist'),
        MeasurementFieldSpec(label: 'Knee'),
        MeasurementFieldSpec(label: 'Thigh'),
        MeasurementFieldSpec(label: 'Bottom'),
        MeasurementFieldSpec(label: 'Inseam'),
        MeasurementFieldSpec(label: 'Outseam'),
      ],
      stylingSections: pantStyling,
    ),
    TailorProductSpec(
      key: waistcoatKey,
      name: 'Waistcoat',
      department: 'Waistcoat Department',
      description: 'Waistcoat measurements and waistcoat styling.',
      sizeLabel: 'Chest size / finished waistcoat',
      sizeOptions: chestSizeOptions,
      measurementFields: [
        MeasurementFieldSpec(label: 'Chest'),
        MeasurementFieldSpec(label: 'Waist'),
        MeasurementFieldSpec(label: 'Hip'),
        MeasurementFieldSpec(label: 'Yoke'),
        MeasurementFieldSpec(label: 'Length'),
        MeasurementFieldSpec(label: 'Neck'),
      ],
      stylingSections: waistcoatStyling,
    ),
    TailorProductSpec(
      key: kameezKey,
      name: 'Kameez',
      department: 'Kameez Department',
      description: 'Kameez body and finished measurements.',
      sizeLabel: 'Neck size / finished neck',
      sizeOptions: shirtSizeOptions,
      measurementFields: [
        MeasurementFieldSpec(label: 'Chest'),
        MeasurementFieldSpec(label: 'Waist'),
        MeasurementFieldSpec(label: 'Hip'),
        MeasurementFieldSpec(label: 'Yoke'),
        MeasurementFieldSpec(label: 'K-Length'),
        MeasurementFieldSpec(label: 'Sleeve'),
        MeasurementFieldSpec(label: 'Neck'),
        MeasurementFieldSpec(label: 'Bicep'),
        MeasurementFieldSpec(label: 'Forearm'),
        MeasurementFieldSpec(label: 'Wrist'),
      ],
      stylingSections: kameezStyling,
    ),
    TailorProductSpec(
      key: shalwarKey,
      name: 'Shalwar',
      department: 'Shalwar Department',
      description: 'Shalwar measurements and pocket/tail styling.',
      sizeLabel: 'Waist size / finished belt',
      sizeOptions: waistSizeOptions,
      measurementFields: [
        MeasurementFieldSpec(label: 'Length'),
        MeasurementFieldSpec(label: 'Waist'),
        MeasurementFieldSpec(label: 'Hip'),
        MeasurementFieldSpec(label: 'Thigh'),
        MeasurementFieldSpec(label: 'Knee'),
        MeasurementFieldSpec(label: 'Bottom'),
        MeasurementFieldSpec(label: 'Inseam'),
        MeasurementFieldSpec(label: 'Outseam'),
      ],
      stylingSections: shalwarStyling,
    ),
    TailorProductSpec(
      key: tieKey,
      name: 'Tie',
      department: 'Accessories Department',
      description: 'Tie selection details for the package.',
      sizeLabel: 'Tie length / width',
      sizeOptions: ['Regular 58 in', 'Long 62 in', 'Slim 2.5 in', 'Classic 3.25 in'],
      stylingSections: accessoryTieStyling,
    ),
    TailorProductSpec(
      key: pocketSquareKey,
      name: 'Pocket Square',
      department: 'Accessories Department',
      description: 'Pocket square style and fabric details.',
      sizeLabel: 'Pocket square size',
      sizeOptions: ['10 x 10 in', '12 x 12 in', '13 x 13 in', '16 x 16 in'],
      stylingSections: accessoryPocketSquareStyling,
    ),
    TailorProductSpec(
      key: twoPieceSuitKey,
      name: 'Two-Piece Suit',
      department: 'Suit Department',
      description: 'Creates separate coat and pant department forms.',
      componentKeys: [coatKey, pantKey],
    ),
    TailorProductSpec(
      key: threePieceSuitKey,
      name: 'Three-Piece Suit',
      department: 'Suit Department',
      description: 'Creates separate coat, pant and waistcoat forms.',
      componentKeys: [coatKey, pantKey, waistcoatKey],
    ),
    TailorProductSpec(
      key: blazerKey,
      name: 'Blazer',
      department: 'Coat Department',
      description: 'Blazer package item using coat department measurements.',
      componentKeys: [coatKey],
    ),
    TailorProductSpec(
      key: trouserKey,
      name: 'Trouser',
      department: 'Pant Department',
      description: 'Trouser package item using pant department measurements.',
      componentKeys: [pantKey],
    ),
    TailorProductSpec(
      key: shalwarKameezKey,
      name: 'Shalwar Kameez',
      department: 'Traditional Department',
      description: 'Creates separate kameez and shalwar department forms.',
      componentKeys: [kameezKey, shalwarKey],
    ),
  ];

  static const WardrobePackageSpec premiumPackage = WardrobePackageSpec(
    id: 'premium_wardrobe',
    name: 'Premium Strategic Wardrobe',
    subtitle: 'Final complete wardrobe roadmap',
    description:
        'A complete wardrobe package for a customer building a life or career wardrobe. Pricing and outfit combinations can be attached later.',
    priceLabel: 'Pricing later',
    allocations: [
      PackageAllocation(productKey: twoPieceSuitKey, quantity: 4),
      PackageAllocation(productKey: shirtKey, quantity: 28),
      PackageAllocation(productKey: blazerKey, quantity: 4),
      PackageAllocation(productKey: trouserKey, quantity: 4),
      PackageAllocation(productKey: shalwarKameezKey, quantity: 4),
      PackageAllocation(productKey: waistcoatKey, quantity: 4),
      PackageAllocation(productKey: tieKey, quantity: 16),
      PackageAllocation(productKey: pocketSquareKey, quantity: 16),
    ],
  );

  static const WardrobePackageSpec introductoryPackage = WardrobePackageSpec(
    id: 'introductory_wardrobe',
    name: 'Introductory',
    subtitle: 'Starter wardrobe',
    description: 'For the professional building his first complete strategic wardrobe',
    priceLabel: 'PKR 150,000',
    allocations: [
      PackageAllocation(productKey: twoPieceSuitKey, quantity: 1),
      PackageAllocation(productKey: shirtKey, quantity: 7),
      PackageAllocation(productKey: blazerKey, quantity: 1),
      PackageAllocation(productKey: trouserKey, quantity: 1),
      PackageAllocation(productKey: shalwarKameezKey, quantity: 1),
      PackageAllocation(productKey: waistcoatKey, quantity: 1),
      PackageAllocation(productKey: tieKey, quantity: 4),
      PackageAllocation(productKey: pocketSquareKey, quantity: 4),
    ],
  );

  static const WardrobePackageSpec deluxePackage = WardrobePackageSpec(
    id: 'deluxe_wardrobe',
    name: 'Deluxe',
    subtitle: 'Complete coverage',
    description: 'For the professional who needs complete coverage across every occasion',
    priceLabel: 'PKR 300,000',
    allocations: [
      PackageAllocation(productKey: twoPieceSuitKey, quantity: 2),
      PackageAllocation(productKey: shirtKey, quantity: 14),
      PackageAllocation(productKey: blazerKey, quantity: 2),
      PackageAllocation(productKey: trouserKey, quantity: 2),
      PackageAllocation(productKey: shalwarKameezKey, quantity: 2),
      PackageAllocation(productKey: waistcoatKey, quantity: 2),
      PackageAllocation(productKey: tieKey, quantity: 8),
      PackageAllocation(productKey: pocketSquareKey, quantity: 8),
    ],
  );

  static Map<String, WardrobePackageSpec> wardrobePackagesMap() {
    return {
      introductoryPackage.id: introductoryPackage,
      deluxePackage.id: deluxePackage,
      premiumPackage.id: premiumPackage,
    };
  }

  static TailorProductSpec productByKey(String key) {
    return productSpecs.firstWhere((product) => product.key == key);
  }

  static List<TailorProductSpec> componentsFor(String productKey) {
    final product = productByKey(productKey);
    if (!product.isComposite) return [product];
    return product.componentKeys.map(productByKey).toList();
  }

  static List<TailorProductSpec> packageProducts() {
    return premiumPackage.allocations
        .map((allocation) => productByKey(allocation.productKey))
        .toList();
  }

  static List<TailorProductSpec> productsForPackage(WardrobePackageSpec pkg) {
    return pkg.allocations.map((allocation) => productByKey(allocation.productKey)).toList();
  }

  static List<String> sizeSuggestions(String componentKey, String query) {
    final product = productByKey(componentKey);
    final normalized = query.trim().toLowerCase();
    final options = [...product.sizeOptions];
    if (normalized.isEmpty) return options.take(8).toList();

    final starts = <String>[];
    final contains = <String>[];
    for (final option in options) {
      final lower = option.toLowerCase();
      if (lower.startsWith(normalized)) {
        starts.add(option);
      } else if (lower.contains(normalized)) {
        contains.add(option);
      }
    }
    return [...starts, ...contains].take(8).toList();
  }

  static bool isItemComplete(TailorOrderItem item) {
    for (final component in componentsFor(item.productKey)) {
      if ((item.sizes[component.key] ?? '').trim().isEmpty) return false;

      for (final field in component.measurementFields) {
        if (!field.required) continue;
        final entry = item.measurements[measurementKey(component.key, field.label)];
        if (entry == null || !entry.hasValue) return false;
      }

      for (final section in component.stylingSections) {
        if (!section.required) continue;
        final selected = item.stylingSelections[styleKey(component.key, section.title)];
        if (selected == null || selected.trim().isEmpty) return false;
      }
    }
    return true;
  }

  static List<String> missingRequirements(TailorOrderItem item) {
    final missing = <String>[];
    for (final component in componentsFor(item.productKey)) {
      if ((item.sizes[component.key] ?? '').trim().isEmpty) {
        missing.add('${component.name}: size');
      }

      final missingMeasurements = component.measurementFields.where((field) {
        if (!field.required) return false;
        final entry = item.measurements[measurementKey(component.key, field.label)];
        return entry == null || !entry.hasValue;
      }).map((field) => field.label).toList();

      if (missingMeasurements.isNotEmpty) {
        missing.add('${component.name}: ${missingMeasurements.join(', ')}');
      }

      final missingStyles = component.stylingSections.where((section) {
        if (!section.required) return false;
        final selected = item.stylingSelections[styleKey(component.key, section.title)];
        return selected == null || selected.trim().isEmpty;
      }).map((section) => section.title).toList();

      if (missingStyles.isNotEmpty) {
        missing.add('${component.name} styling: ${missingStyles.join(', ')}');
      }
    }
    return missing;
  }

  static const List<StylingSectionSpec> shirtStyling = [
    StylingSectionSpec(
      title: 'Collar',
      options: [
        StylingOptionSpec('Medium Spread'),
        StylingOptionSpec('Wide Spread'),
        StylingOptionSpec('Button Down'),
        StylingOptionSpec('Hidden Button Down'),
        StylingOptionSpec('Seven Spread'),
        StylingOptionSpec('Tab Collar'),
        StylingOptionSpec('Wing Collar'),
      ],
    ),
    StylingSectionSpec(
      title: 'Cuff',
      options: [
        StylingOptionSpec('Angle French'),
        StylingOptionSpec('Square French'),
        StylingOptionSpec('One Button Round'),
        StylingOptionSpec('One Button Square'),
        StylingOptionSpec('Convertible Cuff'),
        StylingOptionSpec('Two Button Round'),
        StylingOptionSpec('Two Button Square'),
      ],
    ),
    StylingSectionSpec(
      title: 'Front Placket',
      options: [
        StylingOptionSpec('Fly Front'),
        StylingOptionSpec('Spot Front'),
        StylingOptionSpec('Tab Front'),
      ],
    ),
    StylingSectionSpec(
      title: 'Back',
      options: [
        StylingOptionSpec('Two Back Pleats'),
        StylingOptionSpec('Box Pleat Back'),
        StylingOptionSpec('Inverted Back Pleat'),
        StylingOptionSpec('Smooth'),
        StylingOptionSpec('Box Pleat Locker Loop'),
      ],
    ),
    StylingSectionSpec(
      title: 'Pocket',
      options: [
        StylingOptionSpec('Angular'),
        StylingOptionSpec('Regular'),
        StylingOptionSpec('Round'),
        StylingOptionSpec('Square'),
        StylingOptionSpec('No Pocket'),
      ],
    ),
    StylingSectionSpec(
      title: 'Yoke',
      options: [
        StylingOptionSpec('Split'),
        StylingOptionSpec('Plain'),
        StylingOptionSpec('Western'),
      ],
    ),
    StylingSectionSpec(
      title: 'Monogram',
      required: false,
      helper: 'Optional initials or text can be added in notes.',
      options: [
        StylingOptionSpec('Script', needsText: true, textHint: 'Monogram text'),
        StylingOptionSpec('Block', needsText: true, textHint: 'Monogram text'),
        StylingOptionSpec('No Monogram'),
      ],
    ),
  ];

  static const List<StylingSectionSpec> coatStyling = [
    StylingSectionSpec(
      title: 'Lapel',
      options: [
        StylingOptionSpec('Notch Lapel'),
        StylingOptionSpec('Peak Lapel'),
        StylingOptionSpec('Shawl Lapel'),
      ],
    ),
    StylingSectionSpec(
      title: 'Back Chawk',
      options: [
        StylingOptionSpec('Side Chawk'),
        StylingOptionSpec('Center Chawk'),
        StylingOptionSpec('No Chawk'),
      ],
    ),
    StylingSectionSpec(
      title: 'Pocket',
      options: [
        StylingOptionSpec('Ticket Pocket'),
        StylingOptionSpec('Regular Pocket'),
        StylingOptionSpec('Flap Pocket'),
        StylingOptionSpec('No Ticket Pocket'),
      ],
    ),
    StylingSectionSpec(
      title: 'Button Style',
      options: [
        StylingOptionSpec('One Button Coat'),
        StylingOptionSpec('Two Button Coat'),
        StylingOptionSpec('Single Breast'),
        StylingOptionSpec('Double Breast'),
      ],
    ),
    StylingSectionSpec(
      title: 'Suit Type',
      options: [
        StylingOptionSpec('Regular Suit'),
        StylingOptionSpec('VIP Suit'),
        StylingOptionSpec('Prince Coat'),
        StylingOptionSpec('Tuxedo'),
      ],
    ),
  ];

  static const List<StylingSectionSpec> pantStyling = [
    StylingSectionSpec(
      title: 'Front',
      options: [
        StylingOptionSpec('Front without Pleat'),
        StylingOptionSpec('Front Single Pleat'),
        StylingOptionSpec('Front Double Pleat'),
      ],
    ),
    StylingSectionSpec(
      title: 'Pocket',
      options: [
        StylingOptionSpec('Cross Pocket'),
        StylingOptionSpec('Back One Pocket'),
        StylingOptionSpec('Back Two Pocket'),
        StylingOptionSpec('No Back Pocket'),
      ],
    ),
    StylingSectionSpec(
      title: 'Finish',
      options: [
        StylingOptionSpec('Adjustable Belt'),
        StylingOptionSpec('Knee Silk'),
        StylingOptionSpec('Heel Guard'),
        StylingOptionSpec('Standard Finish'),
      ],
    ),
  ];

  static const List<StylingSectionSpec> waistcoatStyling = [
    StylingSectionSpec(
      title: 'Western Waistcoat',
      options: [
        StylingOptionSpec('V Neck 5 Button S-Breast'),
        StylingOptionSpec('V Neck 4 Button S-Breast'),
        StylingOptionSpec('U Neck 5 Button S-Breast'),
        StylingOptionSpec('U Neck 4 Button S-Breast'),
        StylingOptionSpec('V Neck 5 Button D-Breast'),
        StylingOptionSpec('V Neck 4 Button D-Breast'),
        StylingOptionSpec('U Neck 5 Button D-Breast'),
        StylingOptionSpec('U Neck 4 Button D-Breast'),
      ],
    ),
    StylingSectionSpec(
      title: 'Awami Waistcoat',
      required: false,
      options: [
        StylingOptionSpec('Ban'),
        StylingOptionSpec('V Neck'),
        StylingOptionSpec('Round Neck'),
        StylingOptionSpec('Not Applicable'),
      ],
    ),
  ];

  static const List<StylingSectionSpec> kameezStyling = [
    StylingSectionSpec(
      title: 'Neck / Ban',
      options: [
        StylingOptionSpec('Half Ban Round'),
        StylingOptionSpec('Half Ban Square'),
        StylingOptionSpec('Collar'),
        StylingOptionSpec('No Collar'),
      ],
    ),
    StylingSectionSpec(
      title: 'Front',
      options: [
        StylingOptionSpec('Front Patti'),
        StylingOptionSpec('Plain Front'),
        StylingOptionSpec('Hidden Button Front'),
      ],
    ),
    StylingSectionSpec(
      title: 'Pockets',
      options: [
        StylingOptionSpec('Front Pocket Single'),
        StylingOptionSpec('Front Pocket Double'),
        StylingOptionSpec('Side Pocket Single'),
        StylingOptionSpec('Side Pocket Double'),
        StylingOptionSpec('No Pocket'),
      ],
    ),
    StylingSectionSpec(
      title: 'Tail',
      options: [
        StylingOptionSpec('Round Tail'),
        StylingOptionSpec('Straight Tail'),
        StylingOptionSpec('Chakoti Chawk'),
      ],
    ),
  ];

  static const List<StylingSectionSpec> shalwarStyling = [
    StylingSectionSpec(
      title: 'Pockets',
      options: [
        StylingOptionSpec('Side Pocket Single'),
        StylingOptionSpec('Side Pocket Double'),
        StylingOptionSpec('No Pocket'),
      ],
    ),
    StylingSectionSpec(
      title: 'Bottom Finish',
      options: [
        StylingOptionSpec('Straight Bottom'),
        StylingOptionSpec('Cuffed Bottom'),
        StylingOptionSpec('Traditional Bottom'),
      ],
    ),
  ];

  static const List<StylingSectionSpec> accessoryTieStyling = [
    StylingSectionSpec(
      title: 'Tie Fabric',
      options: [
        StylingOptionSpec('Silk'),
        StylingOptionSpec('Jacquard'),
        StylingOptionSpec('Wool'),
        StylingOptionSpec('Textured'),
      ],
    ),
    StylingSectionSpec(
      title: 'Tie Pattern',
      options: [
        StylingOptionSpec('Solid'),
        StylingOptionSpec('Stripe'),
        StylingOptionSpec('Dots'),
        StylingOptionSpec('Paisley'),
      ],
    ),
  ];

  static const List<StylingSectionSpec> accessoryPocketSquareStyling = [
    StylingSectionSpec(
      title: 'Pocket Square Fabric',
      options: [
        StylingOptionSpec('Silk'),
        StylingOptionSpec('Linen'),
        StylingOptionSpec('Cotton'),
        StylingOptionSpec('Wool'),
      ],
    ),
    StylingSectionSpec(
      title: 'Pocket Square Pattern',
      options: [
        StylingOptionSpec('Solid'),
        StylingOptionSpec('Bordered'),
        StylingOptionSpec('Paisley'),
        StylingOptionSpec('Printed'),
      ],
    ),
  ];
}

String _formatMeasurementValue(double value) {
  final whole = value.truncateToDouble();
  if ((value - whole).abs() < 0.001) return whole.toStringAsFixed(0);
  final decimal = value - whole;
  if ((decimal - 0.25).abs() < 0.001) return '${whole.toStringAsFixed(0)}¼';
  if ((decimal - 0.5).abs() < 0.001) return '${whole.toStringAsFixed(0)}½';
  if ((decimal - 0.75).abs() < 0.001) return '${whole.toStringAsFixed(0)}¾';
  return value.toStringAsFixed(2);
}

List<String> _halfPairs({
  required int start,
  required int end,
  required int finishedOffset,
}) {
  final values = <String>[];
  for (double value = start.toDouble(); value <= end; value += 0.5) {
    values.add(
      '${_formatMeasurementValue(value)} → ${_formatMeasurementValue(value + finishedOffset)}',
    );
  }
  return values;
}

List<String> _quarterPairs({
  required int start,
  required int end,
  required int finishedOffset,
}) {
  final values = <String>[];
  for (double value = start.toDouble(); value <= end; value += 0.25) {
    values.add(
      '${_formatMeasurementValue(value)} → ${_formatMeasurementValue(value + finishedOffset)}',
    );
  }
  return values;
}
