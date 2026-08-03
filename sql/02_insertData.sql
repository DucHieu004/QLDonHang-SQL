-- ============================================================
-- FILE 02: CHÈN DỮ LIỆU MẪU
-- Project: Quản lý Đơn Hàng (QLDonHang)
-- ============================================================

USE QLDonHang
GO

-- ============================================================
-- SHOP
-- ============================================================
INSERT INTO Shop (shopID, [name], phone, [address], email) VALUES
('S001', N'Cửa hàng Minh Anh',         '0987654321', N'Hà Nội',      'minhanh@gmail.com'),
('S002', N'Shop Thời Trang Lan Chi',    '0978123456', N'Hồ Chí Minh', 'lanchi@gmail.com'),
('S003', N'Shop Điện Tử Hoàng Long',   '0967345678', N'Đà Nẵng',     'hoanglong@gmail.com'),
('S004', N'Cửa hàng Gia Dụng Hòa Bình','0956234567', N'Hải Phòng',   'hoabinh@gmail.com'),
('S005', N'Shop Mỹ Phẩm Ngọc Linh',    '0945123456', N'Cần Thơ',     'ngoclinh@gmail.com'),
('S006', N'Shop Thể Thao Anh Tuấn',    '0934567890', N'Huế',         'anhtuan@gmail.com'),
('S007', N'Cửa hàng Sách Tri Thức',    '0923456789', N'Nha Trang',   'trithuc@gmail.com'),
('S008', N'Shop Nội Thất Phú Gia',     '0912345678', N'Bình Dương',  'phugia@gmail.com'),
('S009', N'Shop Phụ Kiện Công Nghệ',   '0901234567', N'Quảng Ninh',  'phukien@gmail.com'),
('S010', N'Shop Đồ Chơi Trẻ Em',       '0998765432', N'Bắc Ninh',    'dochoi@gmail.com');
GO

-- ============================================================
-- CATEGORY
-- ============================================================
INSERT INTO Category (catgID, [name]) VALUES
('C001', N'Điện tử'),
('C002', N'Thời trang'),
('C003', N'Gia dụng'),
('C004', N'Mỹ phẩm'),
('C005', N'Thể thao'),
('C006', N'Sách'),
('C007', N'Nội thất'),
('C008', N'Đồ chơi'),
('C009', N'Phụ kiện công nghệ'),
('C010', N'Thực phẩm');
GO

-- ============================================================
-- PRODUCT (unitPrice NULL = chưa cập nhật giá)
-- ============================================================
INSERT INTO Product (productID, shopID, catgID, [name], unitPrice, unitInStock, quantityPerUnit, discontinued) VALUES
-- Điện tử
('P001','S001','C001',N'Laptop Dell Inspiron',  15000000, 10, N'1 cái', 0),
('P002','S001','C001',N'iPhone 13',             20000000,  5, N'1 cái', 0),
('P003','S002','C001',N'Tai nghe Bluetooth',      500000,  0, N'1 cái', 0),
('P004','S002','C001',N'Chuột Logitech',            NULL, 20, N'1 cái', 0),
('P005','S003','C001',N'Bàn phím cơ',            1200000, 15, N'1 cái', 1),
-- Thời trang
('P006','S003','C002',N'Áo thun nam',             200000, 50, N'1 cái', 0),
('P007','S003','C002',N'Quần jeans nữ',           400000,  0, N'1 cái', 0),
('P008','S004','C002',N'Áo khoác hoodie',           NULL, 30, N'1 cái', 0),
('P009','S004','C002',N'Váy dự tiệc',             800000, 10, N'1 cái', 1),
('P010','S005','C002',N'Áo sơ mi trắng',          300000, 25, N'1 cái', 0),
-- Gia dụng
('P011','S005','C003',N'Nồi cơm điện',            700000, 12, N'1 cái', 0),
('P012','S006','C003',N'Quạt điện',               500000,  0, N'1 cái', 0),
('P013','S006','C003',N'Ấm siêu tốc',               NULL, 18, N'1 cái', 0),
('P014','S007','C003',N'Máy xay sinh tố',         900000,  7, N'1 cái', 1),
('P015','S007','C003',N'Lò vi sóng',             1500000,  6, N'1 cái', 0),
-- Mỹ phẩm
('P016','S008','C004',N'Son môi',                 250000, 40, N'1 thỏi', 0),
('P017','S008','C004',N'Kem dưỡng da',            350000,  0, N'1 hộp',  0),
('P018','S009','C004',N'Sữa rửa mặt',               NULL, 60, N'1 tuýp', 0),
('P019','S009','C004',N'Nước hoa',               1200000,  8, N'1 chai', 1),
('P020','S010','C004',N'Kem chống nắng',          300000, 20, N'1 tuýp', 0),
-- Thể thao
('P021','S010','C005',N'Bóng đá',                 200000, 30, N'1 quả', 0),
('P022','S001','C005',N'Giày thể thao',           800000,  0, N'1 đôi', 0),
('P023','S001','C005',N'Áo thể thao',               NULL, 25, N'1 cái', 0),
('P024','S002','C005',N'Vợt cầu lông',            500000, 10, N'1 cái', 1),
('P025','S002','C005',N'Dây nhảy',                100000, 50, N'1 cái', 0),
-- Sách
('P026','S003','C006',N'Sách lập trình C++',      150000, 20, N'1 cuốn', 0),
('P027','S003','C006',N'Sách IELTS',              200000,  0, N'1 cuốn', 0),
('P028','S004','C006',N'Truyện tranh',               NULL, 40, N'1 cuốn', 0),
('P029','S004','C006',N'Sách kinh tế',            250000, 10, N'1 cuốn', 1),
('P030','S005','C006',N'Sách kỹ năng',            180000, 15, N'1 cuốn', 0),
-- Nội thất
('P031','S005','C007',N'Bàn học',                1200000,  5, N'1 cái', 0),
('P032','S006','C007',N'Ghế văn phòng',           900000,  0, N'1 cái', 0),
('P033','S006','C007',N'Tủ quần áo',                NULL,  3, N'1 cái', 0),
('P034','S007','C007',N'Giường ngủ',             3000000,  2, N'1 cái', 1),
('P035','S007','C007',N'Kệ sách',                 700000,  8, N'1 cái', 0),
-- Đồ chơi
('P036','S008','C008',N'Xe đồ chơi',              150000, 25, N'1 cái',  0),
('P037','S008','C008',N'Búp bê',                  200000,  0, N'1 cái',  0),
('P038','S009','C008',N'Lego',                       NULL, 30, N'1 hộp',  0),
('P039','S009','C008',N'Robot điều khiển',        800000,  6, N'1 cái',  1),
('P040','S010','C008',N'Xếp hình',                120000, 40, N'1 hộp',  0),
-- Phụ kiện công nghệ
('P041','S010','C009',N'Sạc dự phòng',            300000, 20, N'1 cái', 0),
('P042','S001','C009',N'Cáp sạc',                 100000,  0, N'1 cái', 0),
('P043','S001','C009',N'Ốp lưng',                    NULL, 50, N'1 cái', 0),
('P044','S002','C009',N'Kính cường lực',            80000,100, N'1 cái', 1),
('P045','S002','C009',N'Tai nghe có dây',          150000, 35, N'1 cái', 0),
-- Thực phẩm
('P046','S003','C010',N'Bánh mì',                   20000,100, N'1 ổ',    0),
('P047','S003','C010',N'Sữa tươi',                  30000,  0, N'1 hộp',  0),
('P048','S004','C010',N'Mì gói',                     NULL,200, N'1 thùng', 0),
('P049','S004','C010',N'Nước ngọt',                 10000,150, N'1 lon',  1),
('P050','S005','C010',N'Cafe',                      50000, 60, N'1 gói',  0);
GO

-- ============================================================
-- SHIPPER
-- ============================================================
INSERT INTO Shipper (shipperID, [name], phone, companyName) VALUES
('SH001', N'Nguyễn Văn A',  '0981111111', N'Giao Hàng Nhanh'),
('SH002', N'Trần Thị B',    '0982222222', N'Giao Hàng Nhanh'),
('SH003', N'Lê Văn C',      '0983333333', N'Giao Hàng Tiết Kiệm'),
('SH004', N'Phạm Thị D',    '0984444444', N'Giao Hàng Tiết Kiệm'),
('SH005', N'Hoàng Văn E',   '0985555555', N'Viettel Post'),
('SH006', N'Đỗ Thị F',      '0986666666', N'VNPost'),
('SH007', N'Nguyễn Văn G',  '0987777777', N'J&T Express'),
('SH008', N'Trần Thị H',    '0988888888', N'J&T Express'),
('SH009', N'Lê Văn I',      '0989999999', N'Ninja Van'),
('SH010', N'Phạm Thị K',    '0971111111', N'Grab Express'),
('SH011', N'Hoàng Văn L',   '0972222222', N'Grab Express'),
('SH012', N'Đỗ Thị M',      '0973333333', N'Shopee Express'),
('SH013', N'Nguyễn Văn N',  '0974444444', N'Lalamove'),
('SH014', N'Trần Thị O',    '0975555555', N'Best Express'),
('SH015', N'Lê Văn P',      '0976666666', N'Best Express');
GO

-- ============================================================
-- CUSTOMER
-- ============================================================
INSERT INTO Customer (customerID, [name], phone, gender, birthdate) VALUES
('CU001', N'Nguyễn Văn An',    '0901111111', 1, '2000-01-15'),
('CU002', N'Trần Thị Bình',    '0902222222', 0, '1999-03-20'),
('CU003', N'Lê Văn Cường',     '0903333333', 1, '2001-07-10'),
('CU004', N'Phạm Thị Dung',    '0904444444', 0, '1998-12-05'),
('CU005', N'Hoàng Văn Em',     '0905555555', 1, '2002-05-25'),
('CU006', N'Đỗ Thị Phương',    '0906666666', 0, '2000-09-18'),
('CU007', N'Nguyễn Văn Giang', '0907777777', 1, '1997-11-30'),
('CU008', N'Trần Thị Hạnh',    '0908888888', 0, '2001-02-14'),
('CU009', N'Lê Văn Ích',       '0909999999', 1, '1999-08-22'),
('CU010', N'Phạm Thị Kim',     '0911111111', 0, '2003-06-01'),
('CU011', N'Hoàng Văn Long',   '0912222222', 1, '1996-04-12'),
('CU012', N'Đỗ Thị Mai',       '0913333333', 0, '2002-10-09'),
('CU013', N'Nguyễn Văn Nam',   '0914444444', 1, '2000-03-03'),
('CU014', N'Trần Thị Oanh',    '0915555555', 0, '1998-07-27'),
('CU015', N'Lê Văn Phúc',      '0916666666', 1, '2001-01-01');
GO

-- ============================================================
-- ADDRESS_CUSTOMER
-- ============================================================
INSERT INTO Address_Customer (addressID, customerID, address) VALUES
('A001','CU001', N'Hà Nội'),
('A002','CU001', N'Hà Nội - Cầu Giấy'),
('A003','CU001', N'Hà Nội - Hoàng Mai'),
('A004','CU002', N'Hồ Chí Minh'),
('A005','CU003', N'Đà Nẵng'),
('A006','CU003', N'Đà Nẵng - Hải Châu'),
('A007','CU004', N'Hải Phòng'),
('A008','CU005', N'Cần Thơ'),
('A009','CU005', N'Cần Thơ - Ninh Kiều'),
('A010','CU005', N'Cần Thơ - Bình Thủy'),
('A011','CU006', N'Huế'),
('A012','CU007', N'Nghệ An'),
('A013','CU008', N'Quảng Ninh'),
('A014','CU009', N'Bắc Ninh'),
('A015','CU010', N'Hà Nam'),
('A016','CU010', N'Hà Nam - Phủ Lý'),
('A017','CU011', N'Thanh Hóa'),
('A018','CU012', N'Bình Dương'),
('A019','CU012', N'Bình Dương - Thủ Dầu Một'),
('A020','CU013', N'Đồng Nai'),
('A021','CU014', N'Nam Định'),
('A022','CU015', N'Thái Bình');
GO

-- ============================================================
-- METHOD_PAYMENT
-- ============================================================
INSERT INTO Method_Payment (payID, paymentMethod) VALUES
('PM01', N'Tiền mặt'),
('PM02', N'Chuyển khoản'),
('PM03', N'Ví điện tử');
GO

-- ============================================================
-- PAYMENT (amount = 0, sẽ được trigger tự cập nhật)
-- ============================================================
INSERT INTO Payment (paymentID, amount, paymentDate, payID) VALUES
('PAY01', 0, '2026-03-01', 'PM01'),
('PAY02', 0, '2026-03-02', 'PM02'),
('PAY03', 0, '2026-03-03', 'PM03'),
('PAY04', 0, '2026-03-04', 'PM01'),
('PAY05', 0, '2026-03-05', 'PM02'),
('PAY06', 0, '2026-03-06', 'PM03'),
('PAY07', 0, '2026-03-07', 'PM01'),
('PAY08', 0, '2026-03-08', 'PM02'),
('PAY09', 0, '2026-03-09', 'PM03'),
('PAY10', 0, '2026-03-10', 'PM01'),
('PAY11', 0, '2026-03-11', 'PM02'),
('PAY12', 0, '2026-03-12', 'PM03'),
('PAY13', 0, '2026-03-13', 'PM01'),
('PAY14', 0, '2026-03-14', 'PM02');
GO

-- ============================================================
-- ORDERS
-- ============================================================
INSERT INTO Orders (orderID, customerID, shipperID, orderDate, shippedDate, freight, addressID, paymentID, [status]) VALUES
('O001','CU001','SH001','2026-03-01','2026-03-03',30000,'A001','PAY01',N'Đã giao'),
('O002','CU002','SH002','2026-03-02','2026-03-04',25000,'A004','PAY02',N'Đã giao'),
('O003','CU003','SH003','2026-03-03', NULL,        20000,'A005','PAY03',N'Đang giao'),
('O004','CU004','SH004','2026-03-04','2026-03-06',35000,'A007','PAY04',N'Đã giao'),
('O005','CU005','SH005','2026-03-05','2026-03-07',30000,'A008','PAY05',N'Đã giao'),
('O006','CU006','SH006','2026-03-06', NULL,        15000,'A011','PAY06',N'Đang giao'),
('O007','CU007','SH007','2026-03-07','2026-03-09',20000,'A012','PAY07',N'Đã giao'),
('O008','CU008','SH008','2026-03-08','2026-03-10',25000,'A013','PAY08',N'Đã giao'),
('O009','CU009','SH009','2026-03-09', NULL,        30000,'A014','PAY09',N'Chờ xác nhận'),
('O010','CU010','SH010','2026-03-10','2026-03-12',20000,'A015','PAY10',N'Đã giao'),
('O011','CU011','SH011','2026-03-11','2026-03-13',35000,'A017','PAY11',N'Đã giao'),
('O012','CU012','SH012','2026-03-12', NULL,        18000,'A018','PAY12',N'Đang giao'),
('O013','CU013','SH013','2026-03-13','2026-03-15',22000,'A020','PAY13',N'Đã giao'),
('O014','CU014','SH014','2026-03-14','2026-03-16',27000,'A021','PAY14',N'Đã giao');
GO

-- ============================================================
-- ORDER_DETAIL
-- ============================================================
INSERT INTO Order_Detail (orderID, productID, unitPrice, quantity, discount) VALUES
('O001','P001',15000000,1,0),
('O001','P003',  500000,2,0.1),
('O002','P002',20000000,1,0),
('O002','P007',  400000,1,0),
('O003','P011',  700000,1,0),
('O003','P012',  500000,2,0),
('O004','P016',  250000,2,0),
('O004','P017',  350000,1,0.05),
('O005','P021',  200000,2,0),
('O005','P022',  800000,1,0),
('O006','P026',  150000,3,0),
('O006','P027',  200000,1,0),
('O007','P031', 1200000,1,0),
('O007','P032',  900000,1,0),
('O008','P036',  150000,4,0),
('O008','P037',  200000,2,0),
('O009','P041',  300000,2,0),
('O009','P042',  100000,3,0),
('O010','P046',   20000,10,0),
('O010','P047',   30000,5,0),
('O011','P002',20000000,1,0),
('O011','P003',  500000,1,0),
('O012','P018',  400000,2,0),
('O012','P020',  300000,1,0),
('O013','P035',  700000,2,0),
('O013','P034', 3000000,1,0),
('O014','P045',  150000,3,0),
('O014','P043',  120000,2,0);
GO

-- ============================================================
-- ACCOUNT (tạo từ dữ liệu hiện có)
-- ============================================================
INSERT INTO Account (username, [password], role, customerID)
SELECT customerID, CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', '123'), 2), 'CUSTOMER', customerID
FROM Customer;

INSERT INTO Account (username, [password], role, shopID)
SELECT shopID, CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', '123'), 2), 'SHOP', shopID
FROM Shop;

INSERT INTO Account (username, [password], role, shipperID)
SELECT shipperID, CONVERT(VARCHAR(255), HASHBYTES('SHA2_256', '123'), 2), 'SHIPPER', shipperID
FROM Shipper;
GO

PRINT N'✅ Chèn dữ liệu mẫu thành công!';
GO
