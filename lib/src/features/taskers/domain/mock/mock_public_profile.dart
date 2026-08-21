import 'package:flutter/material.dart';

import '../public_profile_model.dart';

const String _u = 'https://images.unsplash.com/photo-';

Map<String, dynamic> _availJson({int startOffset = 0}) {
  final today = DateTime.now();
  final avail = <DateTime>[
    DateTime(today.year, today.month, today.day + startOffset),
    DateTime(today.year, today.month, today.day + startOffset + 1),
    DateTime(today.year, today.month, today.day + startOffset + 2),
    DateTime(today.year, today.month, today.day + startOffset + 4),
    DateTime(today.year, today.month, today.day + startOffset + 5),
    DateTime(today.year, today.month, today.day + startOffset + 7),
    DateTime(today.year, today.month, today.day + startOffset + 9),
  ];
  final unavail = <DateTime>[
    DateTime(today.year, today.month, today.day + startOffset + 3),
    DateTime(today.year, today.month, today.day + startOffset + 6),
  ];
  return {
    'availability_dates': avail.map((d) => d.toIso8601String()).toList(),
    'unavailable_dates': unavail.map((d) => d.toIso8601String()).toList(),
  };
}

Map<String, dynamic> mockPublicProfileJson({int? id}) {
  final rid = id ?? 142;
  switch (rid) {
    case 142:
      return _electricianProfile(id: rid);
    case 143:
      return _plumberProfile(id: rid);
    case 144:
      return _painterProfile(id: rid);
    case 145:
      return _carpenterProfile(id: rid);
    case 146:
      return _cleanerProfile(id: rid);
    default:
      return _genericHandymanProfile(id: rid);
  }
}

Map<String, dynamic> _electricianProfile({required int id}) {
  final av = _availJson();
  return <String, dynamic>{
    'id': id,
    'name': 'Youssef Benali',
    'profession': 'Electrician',
    'profile_image_url':
        '${_u}1547425260-76bcadfb4f2c?auto=format&fit=crop&w=600&q=80',
    'rating': 4.9,
    'review_count': 128,
    'is_verified': true,
    'is_online': true,
    'is_top_rated': true,
    'available_today': true,
    'years_experience': 5,
    'city': 'Casablanca',
    'country': 'Morocco',
    'distance_km': 2.4,
    'bio':
        'Licensed electrician with 5+ years of experience providing safe, efficient electrical solutions for homes and offices across Casablanca. Specializing in clean installation, troubleshooting, and emergency repairs.',
    'features': ['Clean Work', 'Affordable', 'On Time', 'Certified'],
    'phone': '+212 600-000142',
    'response_minutes': 24,
    'jobs_completed': 246,
    'completion_rate': 0.98,
    'services': [
      {
        'icon': 'bolt',
        'name': 'Electrical Installation',
        'starting_price': 120,
        'currency': 'MAD',
        'estimated_duration': '90 minutes',
        'color': '#2563EB',
      },
      {
        'icon': 'repair',
        'name': 'Electrical Repair',
        'starting_price': 80,
        'currency': 'MAD',
        'estimated_duration': '60 minutes',
        'color': '#F59E0B',
      },
      {
        'icon': 'handyman',
        'name': 'Wiring & Rewiring',
        'starting_price': 150,
        'currency': 'MAD',
        'estimated_duration': '120 minutes',
        'color': '#10B981',
      },
      {
        'icon': 'ac_unit',
        'name': 'Smart Home Setup',
        'starting_price': 200,
        'currency': 'MAD',
        'estimated_duration': '150 minutes',
        'color': '#7C3AED',
      },
    ],
    'reviews': [
      {
        'reviewer_name': 'Sara El Amrani',
        'reviewer_avatar':
            '${_u}1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
        'rating': 5.0,
        'comment':
            'Excellent work! Youssef installed 8 new outlets and a new lighting panel in my apartment. Everything was clean, professional, and finished on time. Highly recommend!',
        'date_label': '3 days ago',
        'verified_customer': true,
        'task_title': 'Install new electrical panel',
      },
      {
        'reviewer_name': 'Ahmed Bennani',
        'reviewer_avatar':
            '${_u}1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
        'rating': 4.5,
        'comment':
            'Very responsive and polite. Fixed the short-circuit issue within an hour. Price was exactly as quoted.',
        'date_label': '1 week ago',
        'verified_customer': true,
        'task_title': 'Emergency short-circuit fix',
      },
      {
        'reviewer_name': 'Imane Chraïbi',
        'reviewer_avatar':
            '${_u}1438761681033-6461ffad8d80?auto=format&fit=crop&w=300&q=80',
        'rating': 5.0,
        'comment':
            'Professional from first contact to final check. Cleaned up after the job and provided a detailed invoice.',
        'date_label': '2 weeks ago',
        'verified_customer': true,
        'task_title': 'Full apartment rewiring',
      },
      {
        'reviewer_name': 'Khalid Haddad',
        'reviewer_avatar': '',
        'rating': 5.0,
        'comment':
            'Booked last-minute after an outage. Arrived in 35 minutes and solved it. Absolute life saver.',
        'date_label': '3 weeks ago',
        'verified_customer': true,
        'task_title': 'Emergency outage repair',
      },
    ],
    'portfolio': [
      {
        'title': 'Modern Kitchen Lighting',
        'image_path':
            '${_u}1556911220-bff31c812dba?auto=format&fit=crop&w=900&q=80',
        'description':
            'Complete recessed lighting installation with smart dimmers.',
        'category': 'Installation',
        'tags': ['lighting', 'smart-home', 'kitchen'],
        'is_featured': true,
      },
      {
        'title': 'Villa Entrance Wiring',
        'image_path':
            '${_u}1558618666-fcd25c85cd64?auto=format&fit=crop&w=900&q=80',
        'description':
            'Full rewiring of outdoor lighting + security camera circuit.',
        'category': 'Rewiring',
        'tags': ['villa', 'outdoor'],
      },
      {
        'title': 'Office Panel Upgrade',
        'image_path':
            '${_u}1504328345606-18bbc8c9d7d1?auto=format&fit=crop&w=900&q=80',
        'description': '420v 3-phase distribution panel for a 30-person office.',
        'category': 'Commercial',
        'tags': ['commercial', 'panel'],
        'is_featured': true,
      },
      {
        'title': 'Studio Apartment Fit-out',
        'image_path':
            '${_u}1522444195799-478538b28823?auto=format&fit=crop&w=900&q=80',
        'description': 'Complete electrical fit-out for a 65m² studio.',
        'category': 'Installation',
        'tags': ['apartment'],
      },
    ],
    ...av,
  };
}

Map<String, dynamic> _plumberProfile({required int id}) {
  final av = _availJson(startOffset: 1);
  return <String, dynamic>{
    'id': id,
    'name': 'Othman El Idrissi',
    'profession': 'Plumber',
    'profile_image_url':
        '${_u}1560250093-56162ab1224e?auto=format&fit=crop&w=600&q=80',
    'rating': 4.8,
    'review_count': 214,
    'is_verified': true,
    'is_online': true,
    'is_top_rated': true,
    'available_today': true,
    'years_experience': 8,
    'city': 'Rabat',
    'country': 'Morocco',
    'distance_km': 3.7,
    'bio':
        'Master plumber with 8+ years of residential and commercial plumbing experience. Emergency leaks, bathroom renovations, water heater installs — done right the first time.',
    'features': ['No Leak Guarantee', '24/7 Emergency', 'Neat Finish', 'Licensed'],
    'phone': '+212 600-000143',
    'response_minutes': 18,
    'jobs_completed': 392,
    'completion_rate': 0.99,
    'services': [
      {
        'icon': 'water_drop',
        'name': 'Leak Detection & Repair',
        'starting_price': 90,
        'currency': 'MAD',
        'estimated_duration': '60 minutes',
        'color': '#0EA5E9',
      },
      {
        'icon': 'plumbing',
        'name': 'Bathroom Installation',
        'starting_price': 350,
        'currency': 'MAD',
        'estimated_duration': '240 minutes',
        'color': '#2563EB',
      },
      {
        'icon': 'handyman',
        'name': 'Drain Cleaning',
        'starting_price': 110,
        'currency': 'MAD',
        'estimated_duration': '45 minutes',
        'color': '#F59E0B',
      },
      {
        'icon': 'ac_unit',
        'name': 'Water Heater Service',
        'starting_price': 160,
        'currency': 'MAD',
        'estimated_duration': '90 minutes',
        'color': '#EF4444',
      },
    ],
    'reviews': [
      {
        'reviewer_name': 'Hajar Tazi',
        'reviewer_avatar':
            '${_u}1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        'rating': 5.0,
        'comment':
            'Came in on a Sunday for a severe pipe burst. Super quick diagnosis, no mess left. Price was transparent. Thank you Othman!',
        'date_label': '2 days ago',
        'verified_customer': true,
        'task_title': 'Burst pipe repair',
      },
      {
        'reviewer_name': 'Reda Alaoui',
        'reviewer_avatar':
            '${_u}1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80',
        'rating': 5.0,
        'comment':
            'Full bathroom renovation. Tiling removed, new shower + vanity installed in less than a day.',
        'date_label': '5 days ago',
        'verified_customer': true,
        'task_title': 'Bathroom renovation',
      },
    ],
    'portfolio': [
      {
        'title': 'Villa Master Bathroom',
        'image_path':
            '${_u}1552349510-ea5982d7c415?auto=format&fit=crop&w=900&q=80',
        'description':
            'Full plumbing renovation: walk-in shower, dual vanity, heated floor.',
        'category': 'Renovation',
        'tags': ['bathroom', 'villa'],
        'is_featured': true,
      },
      {
        'title': 'Commercial Kitchen',
        'image_path':
            '${_u}1504384308090-c894fdcc538d?auto=format&fit=crop&w=900&q=80',
        'description': 'Triple-sink + grease trap installation for a 60-seat restaurant.',
        'category': 'Commercial',
        'tags': ['restaurant'],
      },
      {
        'title': 'Apartment Piping',
        'image_path':
            '${_u}1523217585305-4fcaad2836d4?auto=format&fit=crop&w=900&q=80',
        'description': 'Full PEX repiping of a 120m² apartment.',
        'category': 'Repiping',
        'tags': ['apartment'],
      },
    ],
    ...av,
  };
}

Map<String, dynamic> _painterProfile({required int id}) {
  final av = _availJson(startOffset: 2);
  return <String, dynamic>{
    'id': id,
    'name': 'Hicham Mansouri',
    'profession': 'Painter',
    'profile_image_url':
        '${_u}1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
    'rating': 4.7,
    'review_count': 87,
    'is_verified': true,
    'is_online': false,
    'is_top_rated': true,
    'available_today': false,
    'years_experience': 6,
    'city': 'Marrakech',
    'country': 'Morocco',
    'distance_km': 5.1,
    'bio':
        'Detail-oriented interior/exterior painter with a background in traditional riad decoration. From modern apartments to historic homes — smooth finish, zero drips.',
    'features': ['Eco-Friendly Paint', 'Color Consulting', 'Warranty', 'Spotless Prep'],
    'phone': '+212 600-000144',
    'response_minutes': 40,
    'jobs_completed': 158,
    'completion_rate': 0.96,
    'services': [
      {
        'icon': 'format_paint',
        'name': 'Interior Painting',
        'starting_price': 25,
        'currency': 'MAD/m²',
        'estimated_duration': 'per room',
        'color': '#F59E0B',
      },
      {
        'icon': 'paint',
        'name': 'Exterior Painting',
        'starting_price': 35,
        'currency': 'MAD/m²',
        'estimated_duration': '1-3 days',
        'color': '#10B981',
      },
      {
        'icon': 'handyman',
        'name': 'Texture & Decorative',
        'starting_price': 80,
        'currency': 'MAD',
        'estimated_duration': '90 minutes',
        'color': '#2563EB',
      },
    ],
    'reviews': [
      {
        'reviewer_name': 'Nadia Cherradi',
        'reviewer_avatar':
            '${_u}1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
        'rating': 5.0,
        'comment':
            'Repainted 3 bedrooms + living. Lines are perfectly crisp, no splatter, cleaned up every day. Dream experience!',
        'date_label': '1 week ago',
        'verified_customer': true,
        'task_title': 'Apartment repaint',
      },
    ],
    'portfolio': [
      {
        'title': 'Medina Riad Courtyard',
        'image_path':
            '${_u}1600607990338-69a611c58a4d?auto=format&fit=crop&w=900&q=80',
        'description':
            'Traditional zellij-inspired decorative paint for a riad in the medina.',
        'category': 'Historic',
        'tags': ['riad', 'marrakech'],
        'is_featured': true,
      },
      {
        'title': 'Penthouse Interior',
        'image_path':
            '${_u}1560448204-e02f11c3d0e2?auto=format&fit=crop&w=900&q=80',
        'description': 'Matte finish + accent wall in a 220m² penthouse.',
        'category': 'Interior',
        'tags': ['penthouse'],
      },
    ],
    ...av,
  };
}

Map<String, dynamic> _carpenterProfile({required int id}) {
  final av = _availJson(startOffset: 1);
  return <String, dynamic>{
    'id': id,
    'name': 'Karim Fassi',
    'profession': 'Carpenter',
    'profile_image_url':
        '${_u}1472099645785-5658abf4ff4e?auto=format&fit=crop&w=600&q=80',
    'rating': 4.9,
    'review_count': 163,
    'is_verified': true,
    'is_online': true,
    'is_top_rated': true,
    'available_today': true,
    'years_experience': 12,
    'city': 'Fez',
    'country': 'Morocco',
    'distance_km': 4.2,
    'bio':
        'Third-generation master carpenter specializing in bespoke cedar furniture, built-in kitchens, and Moroccan-style doors. On-site measurements, design, and install.',
    'features': ['Custom Design', 'Premium Wood', 'Free Quote', 'On-Site Install'],
    'phone': '+212 600-000145',
    'response_minutes': 36,
    'jobs_completed': 284,
    'completion_rate': 0.97,
    'services': [
      {
        'icon': 'carpenter',
        'name': 'Custom Furniture',
        'starting_price': 450,
        'currency': 'MAD',
        'estimated_duration': '2-5 days',
        'color': '#92400E',
      },
      {
        'icon': 'handyman',
        'name': 'Kitchen Cabinets',
        'starting_price': 1200,
        'currency': 'MAD',
        'estimated_duration': '3-7 days',
        'color': '#B45309',
      },
      {
        'icon': 'build_circle',
        'name': 'Door & Window Fitting',
        'starting_price': 180,
        'currency': 'MAD',
        'estimated_duration': '120 minutes',
        'color': '#7C2D12',
      },
    ],
    'reviews': [
      {
        'reviewer_name': 'Soukaina Ouali',
        'reviewer_avatar':
            '${_u}1541539849691-08e6ea153d0b?auto=format&fit=crop&w=300&q=80',
        'rating': 5.0,
        'comment':
            'Custom cedar bookshelf for our lounge. He drew 3 options, installed in a day, the joinery is flawless.',
        'date_label': '4 days ago',
        'verified_customer': true,
        'task_title': 'Bespoke bookshelf',
      },
    ],
    'portfolio': [
      {
        'title': 'Hand-Carved Cedar Door',
        'image_path':
            '${_u}1515485068-b1126526981e?auto=format&fit=crop&w=900&q=80',
        'description':
            'Traditional geometric carving on a 2.4m entrance cedar door.',
        'category': 'Joinery',
        'tags': ['door', 'cedar'],
        'is_featured': true,
      },
    ],
    ...av,
  };
}

Map<String, dynamic> _cleanerProfile({required int id}) {
  final av = _availJson(startOffset: 0);
  return <String, dynamic>{
    'id': id,
    'name': 'Amina Sahraoui',
    'profession': 'House Cleaner',
    'profile_image_url':
        '${_u}1580471607379-4620f6a8f065?auto=format&fit=crop&w=600&q=80',
    'rating': 5.0,
    'review_count': 302,
    'is_verified': true,
    'is_online': true,
    'is_top_rated': true,
    'available_today': true,
    'years_experience': 4,
    'city': 'Tanger',
    'country': 'Morocco',
    'distance_km': 1.8,
    'bio':
        'Professional deep & move-in cleaning for apartments and villas. Eco-friendly products, trusted references, and a team for large homes.',
    'features': ['Eco Products', 'Ironing Included', 'Weekly Slots', '5★ Rated'],
    'phone': '+212 600-000146',
    'response_minutes': 12,
    'jobs_completed': 420,
    'completion_rate': 1.00,
    'services': [
      {
        'icon': 'cleaning_services',
        'name': 'Regular Cleaning',
        'starting_price': 90,
        'currency': 'MAD',
        'estimated_duration': '120 minutes',
        'color': '#10B981',
      },
      {
        'icon': 'cleaning',
        'name': 'Deep Cleaning',
        'starting_price': 180,
        'currency': 'MAD',
        'estimated_duration': '240 minutes',
        'color': '#0EA5E9',
      },
      {
        'icon': 'local_shipping',
        'name': 'Move-in / Move-out',
        'starting_price': 260,
        'currency': 'MAD',
        'estimated_duration': '360 minutes',
        'color': '#7C3AED',
      },
    ],
    'reviews': [
      {
        'reviewer_name': 'Leila Abou',
        'reviewer_avatar':
            '${_u}1489424571943-080820474c03?auto=format&fit=crop&w=300&q=80',
        'rating': 5.0,
        'comment':
            'She brings her own products, cleans hard-to-reach areas, and the apartment smells amazing every time. We booked weekly!',
        'date_label': '5 days ago',
        'verified_customer': true,
        'task_title': 'Weekly cleaning',
      },
    ],
    'portfolio': [
      {
        'title': 'Post-Renovation Clean',
        'image_path':
            '${_u}1527515039833-aef1d56c0aa3?auto=format&fit=crop&w=900&q=80',
        'description':
            'Dust and paint removal after a 4-month renovation. 180m² apartment.',
        'category': 'Deep Clean',
        'tags': ['renovation'],
        'is_featured': true,
      },
    ],
    ...av,
  };
}

Map<String, dynamic> _genericHandymanProfile({required int id}) {
  final av = _availJson(startOffset: id % 3);
  final rating = 4.3 + ((id * 7) % 7) * 0.1;
  final jobs = 80 + ((id * 13) % 300);
  final years = 1 + (id % 10);
  final cities = const ['Casablanca', 'Rabat', 'Marrakech', 'Fez', 'Tanger', 'Agadir'];
  final city = cities[id % cities.length];
  final names = const [
    'Mehdi Bouazza',
    'Fatima Zahrae',
    'Anas Jabri',
    'Salma Kabbaj',
    'Zakaria Moutawakil',
    'Loubna Amrani',
    'Badr Dahmani',
    'Meryem Bahi',
  ];
  final profs = const [
    'Handyman',
    'HVAC Technician',
    'Mover',
    'Assembler',
    'General Repairs',
  ];
  final name = names[id % names.length];
  final profession = profs[id % profs.length];
  final avatarSeed = 1000 + (id % 120);
  return <String, dynamic>{
    'id': id,
    'name': name,
    'profession': profession,
    'profile_image_url':
        '${_u}1500$avatarSeed-00dcc994a43e?auto=format&fit=crop&w=600&q=80',
    'rating': double.parse(rating.toStringAsFixed(1)),
    'review_count': 30 + ((id * 11) % 200),
    'is_verified': (id % 3) != 0,
    'is_online': (id % 2) == 0,
    'is_top_rated': rating >= 4.7,
    'available_today': (id % 4) != 0,
    'years_experience': years,
    'city': city,
    'country': 'Morocco',
    'distance_km': double.parse(((id % 9) * 0.6 + 0.8).toStringAsFixed(1)),
    'bio':
        'Trusted local $profession serving $city and surrounding areas. $years years of hands-on experience with homes, apartments, and small businesses.',
    'features': const ['Flexible Hours', 'Fair Pricing', 'Free Quote', 'Insured'],
    'phone': '+212 60${(100000 + id % 899999)}',
    'response_minutes': 12 + (id * 5) % 60,
    'jobs_completed': jobs,
    'completion_rate': double.parse(((92 + (id % 8)) / 100).toStringAsFixed(2)),
    'services': [
      {
        'icon': 'handyman',
        'name': 'General Repairs',
        'starting_price': 70 + ((id * 3) % 80),
        'currency': 'MAD',
        'estimated_duration': '60 minutes',
        'color': '#2563EB',
      },
      {
        'icon': 'build_circle',
        'name': 'Furniture Assembly',
        'starting_price': 45 + ((id * 2) % 50),
        'currency': 'MAD',
        'estimated_duration': '45 minutes',
        'color': '#10B981',
      },
      {
        'icon': 'local_shipping',
        'name': 'Small Moving Help',
        'starting_price': 200 + ((id * 7) % 200),
        'currency': 'MAD',
        'estimated_duration': '180 minutes',
        'color': '#F59E0B',
      },
    ],
    'reviews': [
      {
        'reviewer_name': 'Mohamed Ait Said',
        'reviewer_avatar':
            '${_u}1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        'rating': 5.0,
        'comment':
            'Reliable and quick. Assembled my IKEA wardrobe perfectly in under 2 hours!',
        'date_label': '6 days ago',
        'verified_customer': true,
        'task_title': 'Furniture assembly',
      },
      {
        'reviewer_name': 'Hanane Berrada',
        'reviewer_avatar': '',
        'rating': 4.5,
        'comment': 'Good work, arrived on time, clean finish. Would book again.',
        'date_label': '2 weeks ago',
        'verified_customer': true,
        'task_title': 'General repairs',
      },
    ],
    'portfolio': [
      {
        'title': 'Apartment Maintenance',
        'image_path':
            '${_u}1503387784169-1477578fe97e?auto=format&fit=crop&w=900&q=80',
        'description':
            'Wall patching, shelf hanging, and small plumbing jobs for a 100m² apartment.',
        'category': 'Maintenance',
        'tags': ['apartment'],
        'is_featured': true,
      },
      {
        'title': 'Moving Help',
        'image_path':
            '${_u}1536833561599-478c6fa2fbf6?auto=format&fit=crop&w=900&q=80',
        'description': '2-person team, 3-hour move within the city.',
        'category': 'Moving',
        'tags': ['movers'],
      },
    ],
    ...av,
  };
}

PublicProfileModel mockPublicProfile({int? id}) =>
    PublicProfileModel.fromJson(mockPublicProfileJson(id: id));

PublicProfileModel mockPublicProfileById(int id) =>
    PublicProfileModel.fromJson(mockPublicProfileJson(id: id));

class MockPublicProfileProvider extends ChangeNotifier {
  PublicProfileModel? _model;
  bool _loading = true;
  Object? _error;

  PublicProfileModel? get model => _model;
  bool get loading => _loading;
  Object? get error => _error;

  Future<void> load(int id, {bool force = false}) async {
    if (_model?.id == id && _model != null && !force) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      _model = mockPublicProfileById(id);
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
