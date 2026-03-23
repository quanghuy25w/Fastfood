import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'mini_shopp.db');
    return openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            name TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'user',
            address TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            image_url TEXT NOT NULL,
            category TEXT NOT NULL,
            price REAL NOT NULL,
            is_featured INTEGER NOT NULL DEFAULT 0,
            is_favorite INTEGER NOT NULL DEFAULT 0,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL UNIQUE,
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE cart_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cart_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (cart_id) REFERENCES cart (id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
            UNIQUE(cart_id, product_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            total_amount REAL NOT NULL,
            status TEXT NOT NULL,
            payment_status TEXT NOT NULL,
            address TEXT NOT NULL,
            payment_method TEXT NOT NULL,
            store_note TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            product_name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
          )
        ''');

        await _seed(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'user'",
          );
          // Promote demo account to admin for upcoming admin UI.
          await db.update(
            'users',
            {'role': 'admin'},
            where: 'email = ?',
            whereArgs: ['demo'],
          );
        }
      },
    );
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now().toIso8601String();
    const cats = [
      'Phở',
      'Bánh mì',
      'Xôi',
      'Cơm',
      'Cháo',
      'Bún',
      'Mì',
      'Trà',
      'Nước',
      'Tráng miệng',
    ];
    for (final c in cats) {
      await db.insert('categories', {'name': c, 'created_at': now});
    }

    final products = <Map<String, Object?>>[
      {
        'name': 'Phở tái',
        'description': 'Nước trong, thịt mềm',
        'image_url': 'https://cdnv2.tgdd.vn/mwg-static/common/Common/pho-tai-lan.jpg',
        'category': 'Phở',
        'price': 45000.0,
        'is_featured': 1,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
      {
        'name': 'Cơm tấm sườn',
        'description': 'Sườn nướng, bì, chả',
        'image_url':
            'https://nvhphunu.vn/wp-content/uploads/2023/10/com-tam-1.webp',
        'category': 'Cơm',
        'price': 55000.0,
        'is_featured': 1,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
      {
        'name': 'Bún chả',
        'description': 'Hà Nội style',
        'image_url': 'https://www.seriouseats.com/thmb/J0g7JWjk9r6CHESo1CIrD1BfGd0=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/20231204-SEA-VyTran-BunChaHanoi-19-f623913c6ef34a9185bcd6e5680c545f.jpg',
        'category': 'Bún',
        'price': 50000.0,
        'is_featured': 0,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
      {
        'name': 'Nước Cam',
        'description': 'Ly lớn',
        'image_url': 'https://cuonanvu.vn/Upload/Products/160525022601.jpg',
        'category': 'NướcNước',
        'price': 5000.0,
        'is_featured': 0,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
      {
        'name': 'Nước Chanh',
        'description': 'Ép tươi',
        'image_url': 'https://cdnphoto.dantri.com.vn/6Z5XvUASW0fndDoMy3jZXuAWG_o=/thumb_w/960/2020/12/22/limejuice-50420459-1608603803282.jpg',
        'category': 'NướcNước',
        'price': 25000.0,
        'is_featured': 0,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
      {
        'name': 'Chè khúc bạch',
        'description': 'Mát lạnh',
        'image_url': 'https://cdn.mediamart.vn/images/news/huong-dan-cach-lam-che-khuc-bach-thanh-mat-thom-ngon-hap-dan_ada6ac3c.png',
        'category': 'Tráng miệng',
        'price': 20000.0,
        'is_featured': 0,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
    ];
    for (final row in products) {
      await db.insert('products', row);
    }

    await db.insert('users', {
      'email': 'demo',
      'password': 'demo',
      'name': 'The Hoang',
      'role': 'admin',
      'address': '',
      'created_at': now,
    });
    await db.insert('users', {
      'email': 'user',
      'password': '123',
      'name': 'NHOM 9',
      'role': 'user', // Quyền user thường
      'address': 'Hanoi, Vietnam',
      'created_at': now,
    });
  }
}
