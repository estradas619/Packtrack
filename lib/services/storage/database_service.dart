import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../data/models/package_model.dart';
import '../../data/models/tracking_event_model.dart';

/// Service for managing the local SQLite database.
///
/// Stores package tracking history and events for offline access
/// and fast retrieval.
class DatabaseService {
  static Database? _database;
  static const String _dbName = 'packtrack.db';
  static const int _dbVersion = 1;

  /// Get or create the database instance.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database with required tables.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables.
  Future<void> _onCreate(Database db, int version) async {
    // Packages table
    await db.execute('''
      CREATE TABLE packages (
        id TEXT PRIMARY KEY,
        tracking_number TEXT NOT NULL,
        carrier TEXT NOT NULL,
        carrier_logo_url TEXT,
        status TEXT NOT NULL,
        order_id TEXT,
        order_name TEXT,
        origin TEXT,
        destination TEXT,
        current_latitude REAL,
        current_longitude REAL,
        destination_latitude REAL,
        destination_longitude REAL,
        estimated_delivery TEXT,
        actual_delivery TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        description TEXT,
        weight REAL,
        dimensions TEXT
      )
    ''');

    // Tracking events table
    await db.execute('''
      CREATE TABLE tracking_events (
        id TEXT PRIMARY KEY,
        package_id TEXT NOT NULL,
        description TEXT NOT NULL,
        location TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE CASCADE
      )
    ''');

    // Search history table
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tracking_number TEXT NOT NULL,
        carrier TEXT NOT NULL,
        searched_at TEXT NOT NULL,
        last_status TEXT
      )
    ''');

    // Create indexes for performance
    await db.execute(
      'CREATE INDEX idx_events_package ON tracking_events(package_id)',
    );
    await db.execute(
      'CREATE INDEX idx_packages_tracking ON packages(tracking_number)',
    );
    await db.execute(
      'CREATE INDEX idx_search_date ON search_history(searched_at DESC)',
    );
  }

  /// Handle database upgrades.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migration logic goes here
  }

  // ─── Package Operations ──────────────────────────────────────────────────

  /// Insert or update a package.
  Future<void> upsertPackage(PackageModel package) async {
    final db = await database;

    await db.insert(
      'packages',
      {
        'id': package.id,
        'tracking_number': package.trackingNumber,
        'carrier': package.carrier,
        'carrier_logo_url': package.carrierLogoUrl,
        'status': package.status.key,
        'order_id': package.orderId,
        'order_name': package.orderName,
        'origin': package.origin,
        'destination': package.destination,
        'current_latitude': package.currentLatitude,
        'current_longitude': package.currentLongitude,
        'destination_latitude': package.destinationLatitude,
        'destination_longitude': package.destinationLongitude,
        'estimated_delivery': package.estimatedDelivery?.toIso8601String(),
        'actual_delivery': package.actualDelivery?.toIso8601String(),
        'created_at': package.createdAt.toIso8601String(),
        'updated_at': package.updatedAt.toIso8601String(),
        'description': package.description,
        'weight': package.weight,
        'dimensions': package.dimensions,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert events
    for (final event in package.events) {
      await upsertEvent(package.id, event);
    }
  }

  /// Get a package by ID.
  Future<PackageModel?> getPackage(String id) async {
    final db = await database;
    final maps = await db.query('packages', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;

    final events = await getEventsForPackage(id);
    return _packageFromMap(maps.first, events);
  }

  /// Get all packages.
  Future<List<PackageModel>> getAllPackages() async {
    final db = await database;
    final maps = await db.query('packages', orderBy: 'updated_at DESC');

    final packages = <PackageModel>[];
    for (final map in maps) {
      final events = await getEventsForPackage(map['id'] as String);
      packages.add(_packageFromMap(map, events));
    }
    return packages;
  }

  /// Delete a package and its events.
  Future<void> deletePackage(String id) async {
    final db = await database;
    await db.delete('tracking_events', where: 'package_id = ?', whereArgs: [id]);
    await db.delete('packages', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Event Operations ────────────────────────────────────────────────────

  /// Insert or update a tracking event.
  Future<void> upsertEvent(String packageId, TrackingEventModel event) async {
    final db = await database;

    await db.insert(
      'tracking_events',
      {
        'id': event.id,
        'package_id': packageId,
        'description': event.description,
        'location': event.location,
        'timestamp': event.timestamp.toIso8601String(),
        'status': event.status,
        'latitude': event.latitude,
        'longitude': event.longitude,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all events for a package.
  Future<List<TrackingEventModel>> getEventsForPackage(String packageId) async {
    final db = await database;
    final maps = await db.query(
      'tracking_events',
      where: 'package_id = ?',
      whereArgs: [packageId],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => TrackingEventModel(
      id: map['id'] as String,
      description: map['description'] as String,
      location: map['location'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      status: map['status'] as String,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    )).toList();
  }

  // ─── Search History Operations ───────────────────────────────────────────

  /// Add a search history entry.
  Future<void> addSearchEntry({
    required String trackingNumber,
    required String carrier,
    String? lastStatus,
  }) async {
    final db = await database;

    // Remove existing entry with same tracking number
    await db.delete(
      'search_history',
      where: 'tracking_number = ?',
      whereArgs: [trackingNumber],
    );

    await db.insert('search_history', {
      'tracking_number': trackingNumber,
      'carrier': carrier,
      'searched_at': DateTime.now().toIso8601String(),
      'last_status': lastStatus,
    });
  }

  /// Get search history.
  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 50}) async {
    final db = await database;
    return db.query(
      'search_history',
      orderBy: 'searched_at DESC',
      limit: limit,
    );
  }

  /// Clear search history.
  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_history');
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  PackageModel _packageFromMap(
    Map<String, dynamic> map,
    List<TrackingEventModel> events,
  ) {
    return PackageModel(
      id: map['id'] as String,
      trackingNumber: map['tracking_number'] as String,
      carrier: map['carrier'] as String,
      carrierLogoUrl: map['carrier_logo_url'] as String?,
      status: PackageStatusExtension.fromString(map['status'] as String),
      orderId: map['order_id'] as String?,
      orderName: map['order_name'] as String?,
      origin: map['origin'] as String?,
      destination: map['destination'] as String?,
      currentLatitude: map['current_latitude'] as double?,
      currentLongitude: map['current_longitude'] as double?,
      destinationLatitude: map['destination_latitude'] as double?,
      destinationLongitude: map['destination_longitude'] as double?,
      estimatedDelivery: map['estimated_delivery'] != null
          ? DateTime.parse(map['estimated_delivery'] as String)
          : null,
      actualDelivery: map['actual_delivery'] != null
          ? DateTime.parse(map['actual_delivery'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      events: events,
      description: map['description'] as String?,
      weight: map['weight'] as double?,
      dimensions: map['dimensions'] as String?,
    );
  }

  /// Close the database.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
