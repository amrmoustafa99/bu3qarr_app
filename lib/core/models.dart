class PropertyModel {
  final String id;
  final String title;
  final String price;
  final String priceUnit;
  final String location;
  final String area;
  final String propertyType;
  final String category; // بيع / إيجار / بدل
  final String timeAgo;
  final String? description;
  final String? adCode;
  final String? floors;
  final String? details;
  final List<String> images;
  final AgencyModel? agency;
  final bool isPersonal;

  const PropertyModel({
    required this.id,
    required this.title,
    required this.price,
    required this.priceUnit,
    required this.location,
    required this.area,
    required this.propertyType,
    required this.category,
    required this.timeAgo,
    required this.images,
    this.description,
    this.adCode,
    this.floors,
    this.details,
    this.agency,
    this.isPersonal = false,
  });
}

class AgencyModel {
  final String name;
  final String logoUrl;
  final int listingsCount;
  final bool isLicensed;
  final String? address;

  const AgencyModel({
    required this.name,
    required this.logoUrl,
    required this.listingsCount,
    required this.isLicensed,
    this.address,
  });
}

// Sample data based on bu3qar app screenshots
final List<PropertyModel> sampleProperties = [
  PropertyModel(
    id: '1',
    title: 'بيت في المطلاع زاوية',
    price: '360,000',
    priceUnit: 'د.ك',
    location: 'المطلاع',
    area: '400',
    propertyType: 'بيت',
    category: 'بيع',
    timeAgo: 'منذ ساعة',
    adCode: '2388',
    floors: '3 أدوار سوبر ديلوكس',
    details: 'زاوية، سكني',
    description:
        'بيت للبيع في منطقة المطلاع زاوية، 3 أدوار سوبر ديلوكس، موقع مميز، مساحة 400 متر مربع. فرصة استثمارية ممتازة في منطقة راقية.',
    images: [
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
    ],
    agency: AgencyModel(
      name: 'شركة البادي العقارية',
      logoUrl: 'https://ui-avatars.com/api/?name=البادي&background=E8500A&color=fff&size=128',
      listingsCount: 45,
      isLicensed: true,
    ),
  ),
  PropertyModel(
    id: '2',
    title: 'شقة للإيجار في الخالدية',
    price: '650',
    priceUnit: 'د.ك',
    location: 'الخالدية',
    area: '180',
    propertyType: 'شقة',
    category: 'إيجار',
    timeAgo: 'منذ 3 ساعات',
    adCode: '2385',
    description: 'شقة للإيجار في الخالدية، 3 غرف وغرفة خادمة، إعلان شخصي عبر بوعقار.',
    images: [
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      'https://images.unsplash.com/photo-1560448075-bb485b067938?w=800',
    ],
    isPersonal: true,
  ),
  PropertyModel(
    id: '3',
    title: 'مجمع سكني في المهبوله على البحر',
    price: 'للبدل',
    priceUnit: '',
    location: 'المهبوله',
    area: '6000',
    propertyType: 'مجمع سكني',
    category: 'بدل',
    timeAgo: 'منذ يوم',
    adCode: '2370',
    details: '3 شوارع',
    description: 'مجمع سكني على البحر في المهبوله، مساحة 6000 متر مربع، 3 شوارع.',
    images: [
      'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
    ],
    agency: AgencyModel(
      name: 'شركة فرست العقارية',
      logoUrl: 'https://ui-avatars.com/api/?name=فرست&background=E8500A&color=fff&size=128',
      listingsCount: 19,
      isLicensed: true,
    ),
  ),
  PropertyModel(
    id: '4',
    title: 'قسيمة زاوية فاخرة في المطلاع',
    price: '600,000',
    priceUnit: 'د.ك',
    location: 'المطلاع',
    area: '400',
    propertyType: 'قسيمة',
    category: 'بيع',
    timeAgo: 'منذ يومين',
    adCode: '2401',
    description: 'قسيمة زاوية فاخرة في المطلاع، مساحة 400 متر مربع، موقع استراتيجي.',
    images: [
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
    ],
    agency: AgencyModel(
      name: 'بلوكات الدولية العقارية',
      logoUrl: 'https://ui-avatars.com/api/?name=بلوكات&background=333&color=fff&size=128',
      listingsCount: 32,
      isLicensed: true,
    ),
  ),
  PropertyModel(
    id: '5',
    title: 'أرض للبيع في المسيله واجهة بحرية',
    price: '2,500,000',
    priceUnit: 'د.ك',
    location: 'المسيله',
    area: '2000',
    propertyType: 'أرض',
    category: 'بيع',
    timeAgo: 'منذ 3 أيام',
    adCode: '2350',
    details: 'بطن وظهر',
    description: 'أرض للبيع في المسيله واجهة بحرية مباشرة، مساحة 2000 متر مربع، بطن وظهر.',
    images: [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=800',
    ],
    agency: AgencyModel(
      name: 'مؤسسة جمال الدعيج العقارية',
      logoUrl: 'https://ui-avatars.com/api/?name=الدعيج&background=E8500A&color=fff&size=128',
      listingsCount: 28,
      isLicensed: true,
      address: 'القبلة، الكويت',
    ),
  ),
  PropertyModel(
    id: '6',
    title: 'فيلا سكنية فاخرة في السالمية',
    price: '450,000',
    priceUnit: 'د.ك',
    location: 'السالمية',
    area: '550',
    propertyType: 'فيلا',
    category: 'بيع',
    timeAgo: 'منذ 5 أيام',
    adCode: '2399',
    description: 'فيلا سكنية فاخرة في السالمية، تشطيب سوبر ديلوكس، موقع مميز.',
    images: [
      'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800',
    ],
    agency: AgencyModel(
      name: 'شركة ستار سكاي العقارية',
      logoUrl: 'https://ui-avatars.com/api/?name=ستار&background=333&color=fff&size=128',
      listingsCount: 67,
      isLicensed: true,
    ),
  ),
];
