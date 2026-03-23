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
      version: 3,
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
        }
        if (oldVersion < 3) {
          // Recreate seed data for demo accounts
          await _seed(db);
        }
      },
    );
  }

  Future<void> _seed(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Check if demo user exists to avoid duplicate inserts
    final existingDemo = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['demo'],
      limit: 1,
    );
    
    if (existingDemo.isNotEmpty) {
      return; // Demo data already exists
    }
    
    const cats = [
      'Điện thoại',
      'Laptop',
      'Máy tính bảng',
      'Tai nghe',
      'Ghế',
      'Đồng hồ',
      'Chuột & Bàn phím',
      'Loa Bluetooth',
      'Sạc dự phòng',
      'Camera',
      'Linh kiện',
    ];

    for (final c in cats) {
      await db.insert('categories', {'name': c, 'created_at': now});
    }

    final products = <Map<String, Object?>>[
      {
        'name': 'ĐỒNG HỒ LOA BLUTOOTH N69 LED RGB TRẮNG',
        'description': '''Thông số sản phẩm
        NHÀ SẢN XUẤT KHUYẾN CÁO KHÔNG ĐƯỢC SẠC SẢN PHẨM TRỰC TIẾP VÀO CỦ SẠC
        Đồng hồ Loa Bluetooth Kiêm Đế sạc không dây có đồng hồ báo thức N69
        Hiệu Ứng đèn led RGB
        Màu sắc : đen - trắng
        Đèn LED / Đế sạc 15w / Loa Bluetooth / Đồng hồ
        Kiểm soát ứng dụng : HappyLighting
        Chủ đề màu sắc có thể thay đổi để phù hợp với nhạc đang phát (mục cấu hình)
        Sạc không dây cho tất cả các loại điện thoại có thiết bị không dây QI
        Bluetooth 5.0
        Độ sáng: 2800 - 6500K
        Kích thước: 225x230x82mm
        Loa Bluetooth N69 RGB sạc không dây đủ dòng ( dành cho đt có hỗ trợ sạc không dây)
        Bảo hành : 6 tháng chính hãng''',
        'image_url': 'https://lacdau.com/media/product/250-3525-8.jpg',
        'category': 'Đồng hồ',
        'price': 490000,
        'is_featured': 1,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
      {
        'name': 'MÀN HÌNH TFT GEEKMAGIC MINI WEATHER STATION ĐEN',
        'description': '''Tên sản phẩm: Đồng hồ thời tiết mini WiFi 2025
Kích thước màn hình: 1.54 inch TFT IPS
Độ phân giải: 240x240
Kết nối: WiFi 2.4GHz
Cổng sạc: Type-C
Nguồn điện: 5V/1A
Trọng lượng: Khoảng 20g
Chất liệu vỏ: Nhựa ABS
Màu sắc: Đa dạng (tùy chọn)
Kích thước sản phẩm: 45 x 35 x 40 mm
Chức năng chính: Hiển thị thời gian, ngày tháng, nhiệt độ, độ ẩm, dự báo thời tiết, ảnh động GIF tùy chỉnh​
Hiển thị thời tiết và thông tin môi trường: Cập nhật thời tiết theo thời gian thực, bao gồm nhiệt độ, độ ẩm, áp suất không khí, tốc độ và hướng gió.
Ảnh động tùy chỉnh: Hỗ trợ hiển thị ảnh động GIF do người dùng tải lên, tạo sự sinh động cho màn hình.
Chức năng đồng hồ: Hiển thị giờ, phút, giây với giao diện dễ nhìn.
Thiết kế nhỏ gọn: Kích thước nhỏ, dễ dàng đặt trên bàn làm việc, kệ sách hoặc mang theo khi di chuyển.
Kết nối WiFi: Đồng bộ dữ liệu thời tiết và thời gian thông qua kết nối WiFi.
Cập nhật phần mềm: Hỗ trợ cập nhật firmware qua OTA, giúp thiết bị luôn được nâng cấp với các tính năng mới.
Quý khách tuyệt đối không sạc sản phẩm với củ sạc điện thoại, chỉ sạc với cổng USB trên máy tính để đảm bảo không gây cháy nổ sản phẩm
Bảo hành : 3 tháng''',
        'image_url': 'https://lacdau.com/media/product/250-6460-6.png',
        'category': 'Đồng hồ',
        'price': 250000,
        'is_featured': 1,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
      {
        'name': 'THANH LED RGB MINI NHÁY THEO NHẠC D1 20CM TRẮNG',
        'description': '''Thông số sản phẩm
Với 32 hạt đèn màu sắc, chế độ hiển thị, màu sắc, đỉnh, độ sáng, tốc độ, độ nhạy đều có thể được điều chỉnh tùy ý để đáp ứng các nhu cầu khác nhau.
Chức năng Nâng cao và Mạnh mẽ Thuật toán AGC đảm bảo các hiệu ứng hiển thị tốt nhất khi tín hiệu đầu vào thay đổi.
Với kích thước nhỏ gọn, thiết kế độc đáo nhờ sự kết hợp acrylic+decal mờ tạo nên vẻ đẹp thẩm mĩ.
Đây là 1 sản phẩm mới mẻ để decor góc giải trí của mình khi thưởng thức âm nhạc.
Dễ dàng thiết lập chỉ với cáp Micro-USB để sử dụng.
Kích thước: 181*22.5*18.5 (mm)
Toàn bộ màn hình hiển thị được bao phủ bởi một lớp phim bảo vệ, vui lòng tháo nó ra trước khi sử dụng.
Được cấp nguồn bởi DC 5V (Micro-USB), vượt quá 5V sẽ dẫn đến hư hỏng.
Dòng điện phải lớn hơn hoặc bằng 1A để đảm bảo hiệu suất tốt nhất.
Chế độ hiển thị: 8
Kết hợp màu hiển thị: trên 60
Các mục có thể điều chỉnh: độ nhạy / tốc độ / độ sáng / màu sắc / chế độ, v.v.
Điện áp làm việc: DC 5V (≥1A)
Công suất tiêu thụ: 5W
Bảo Hành : 3 Tháng Chính Hãng''',
        'image_url': 'https://lacdau.com/media/product/250-2845-2424-4.jpg',
        'category': 'Linh kiện',
        'price': 90000,
        'is_featured': 0,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
      {
        'name': 'GHẾ CÔNG THÁI HỌC ERGONOMIC WARRIOR HERO WEC501 XÁM',
        'description': '''Thông số sản phẩm
Lưng lưới và mâm ngồi từ Foam nguyên chất.
Bệ đỡ cánh bướm (butterfly mechanism).
Tựa đầu 3D và kê tay 3D.
Trục thủy lực Class 4 bền bỉ.
Lưng ghế có thể điều chỉnh theo nguyên lý công thái học.
Chân kim loại được thiết kế chịu lực.
Tải trọng tối đa 100kg.
Chiều cao tối đa 180cm
Bảo hành : 12 tháng chính hãng''',
        'image_url': 'https://lacdau.com/media/product/250-4576-2.jpg',
        'category': 'Ghế',
        'price': 2500000,
        'is_featured': 0,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
      {
        'name':
            'BỘ KEYCAP PUDDING SIDE TRANSPARENT GENGAR (PBT/OEM PROFILE/122 PHÍM)',
        'description': '''Thông số sản phẩm
Keycap pudding side transparent
Chất liệu : 4 cạnh transparent nhựa PC - mặt in nhựa PBT
Profile : OEM profile
Số lượng phím : 122 phím
Loại phím thích hợp : 61/64/75/82/84/87/96/98/100/104/108 phím
Kích thước nút space : 6.25U
Kích thước nút nhỏ : 1U
Kích thước hộp : 360*155*25mm
Trọng lượng : 420''',
        'image_url':
            'https://lacdau.com/media/product/250-5780-untitled-1_upscayl_2x_realesrgan-x4plus.png',
        'category': 'Chuột & Bàn phím',
        'price': 250000,
        'is_featured': 0,
        'is_favorite': 0,
        'is_active': 1,
        'created_at': now,
      },
      {
        'name': 'ĐỆM KÊ CỔ TAY DI CHUỘT 3D MÈO XÁM',
        'description':
            '''Tấm lót chuột bảo vệ cổ tay thoải mái chất lượng cao là chuột theo dõi và tấm lót chuột này sẽ giúp Chuột của bạn theo dõi và nhấp chuột chính xác, Đối tác tuyệt vời dành cho Chuột.
Thoải mái
Bọt nhớ, Hỗ trợ độ lỏng hỗ trợ thoải mái và tự nhiên.
Loại: Gối tay chơi game
Kích thước : 12.5*6CM
''',
        'image_url': 'https://lacdau.com/media/product/250-4866-4.jpg',
        'category': 'Linh kiện',
        'price': 45000,
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
      'name': 'Thế Hoàng (Admin)',
      'role': 'admin',
      'address': '',
      'created_at': now,
    });
    await db.insert('users', {
      'email': 'user@example.com',
      'password': '123456',
      'name': 'Nguyễn Văn A',
      'role': 'user',
      'address': 'Hà Nội',
      'created_at': now,
    });
    await db.insert('users', {
      'email': 'customer1@gmail.com',
      'password': 'pass123',
      'name': 'Trần Thị B',
      'role': 'user',
      'address': 'TP Hồ Chí Minh',
      'created_at': now,
    });
    await db.insert('users', {
      'email': 'customer2@gmail.com',
      'password': 'password',
      'name': 'Lê Văn C',
      'role': 'user',
      'address': 'Đà Nẵng',
      'created_at': now,
    });
    await db.insert('users', {
      'email': 'admin2@store.com',
      'password': 'admin123',
      'name': 'Quản trị viên 2',
      'role': 'admin',
      'address': '',
      'created_at': now,
    });
    await db.insert('users', {
      'email': 'test@test.com',
      'password': '123456',
      'name': 'Nguyễn Test',
      'role': 'user',
      'address': 'Hải Phòng',
      'created_at': now,
    });
  }
}
