# 🛒 Hệ Thống Quản Lý Đơn Hàng (QLDonHang)

Dự án cá nhân xây dựng cơ sở dữ liệu quản lý đơn hàng thương mại điện tử bằng SQL Server.

---

## 📌 Mô tả bài toán

- **Khách hàng** đặt mua sản phẩm từ nhiều shop, có thể lưu nhiều địa chỉ giao hàng
- **Shop** đăng bán sản phẩm theo danh mục, quản lý tồn kho
- **Shipper** nhận và vận chuyển đơn hàng
- **Hệ thống** tự động quản lý tồn kho, tính tiền, theo dõi trạng thái đơn hàng

---

## 🗂️ Cấu trúc thư mục

```
QLDonHang-SQL/
├── sql/
│   ├── 01_tableData.sql
│   ├── 02_insertData.sql
│   ├── 03_programmability.sql
│   └── 04_businessQueries.sql
└── README.md
```

---

## 🚀 Cách chạy

Yêu cầu: SQL Server 2019+ và SQL Server Management Studio (SSMS)

Chạy lần lượt theo thứ tự:

```
01_tableData.sql → 02_insertData.sql → 03_programmability.sql → 04_businessQueries.sql
```

---

## 🛠️ Công nghệ sử dụng

- **SQL Server 2019+**
- **T-SQL** (Transact-SQL)

---

## ⚙️ Tính năng nổi bật

| Tính năng | Mô tả |
|-----------|-------|
| ✅ Chuẩn hóa 3NF | Thiết kế đầy đủ PK / FK / CHECK constraint |
| ✅ Trigger | Tự động trừ tồn kho, tính tiền khi đặt hàng; chặn sửa đơn đã giao |
| ✅ Stored Procedure | Tạo đơn hàng có Transaction + TRY/CATCH, tìm kiếm, báo cáo |
| ✅ View | Báo cáo doanh thu theo shop, sản phẩm bán chạy, thống kê khách hàng |
| ✅ Index | Tối ưu hiệu năng truy vấn trên các cột hay dùng |
| ✅ Bảo mật | Password được hash bằng SHA2_256, không lưu plain text |
| ✅ Window Function | Dùng RANK() OVER để xếp hạng doanh thu |
| ✅ CTE | Common Table Expression cho các truy vấn phức tạp |


## 📂 Chi tiết từng file

### `01_tableData.sql` — Cấu trúc database
- Tạo 10 bảng với đầy đủ quan hệ
- CHECK constraint: giá > 0, số lượng > 0, discount trong [0,1]
- Thêm cột `status` cho Orders, `isActive` / `createdAt` cho Account
- 5 INDEX tăng hiệu năng

### `02_insertData.sql` — Dữ liệu mẫu
- 10 Shop, 10 Category, 50 Product
- 15 Customer, 22 Address, 15 Shipper
- 14 Orders, 28 Order_Detail
- Account tự sinh từ Customer/Shop/Shipper với password đã hash

### `03_programmability.sql` — Logic nghiệp vụ
- **3 Trigger**: trừ/hoàn kho, tính tiền, chặn sửa đơn đã giao
- **4 View**: OrderSummary, RevenueByShop, TopSellingProducts, CustomerStats
- **5 Stored Procedure**: CreateOrder, UpdateOrderStatus, GetOrderHistory, RevenueReport, SearchProduct

### `04_businessQueries.sql` — Truy vấn nghiệp vụ
- Top 5 sản phẩm bán chạy
- Doanh thu theo shop, theo tháng
- Khách hàng VIP, hiệu suất shipper
- Window Function RANK(), CTE

---

## 👤 Tác giả

**Nguyễn Đức Hiếu**
- GitHub: [github.com/DucHieu004](https://github.com/DucHieu004)
- Email: nguyenduchieu21052004@gmail.com
