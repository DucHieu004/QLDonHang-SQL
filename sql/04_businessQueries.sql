-- ============================================================
-- FILE 04: TRUY VẤN NGHIỆP VỤ (BUSINESS QUERIES) + TEST DEMO
-- Project: Quản lý Đơn Hàng (QLDonHang)
-- ============================================================

USE QLDonHang
GO

-- ============================================================
-- 1. TOP 5 SẢN PHẨM BÁN CHẠY NHẤT
-- ============================================================
SELECT TOP 5
    productName, categoryName, shopName, totalSold, totalRevenue
FROM vw_TopSellingProducts
ORDER BY totalSold DESC;
GO

-- ============================================================
-- 2. DOANH THU THEO TỪNG SHOP (sắp xếp giảm dần)
-- ============================================================
SELECT * FROM vw_RevenueByShop
ORDER BY totalRevenue DESC;
GO

-- ============================================================
-- 3. TOP 5 KHÁCH HÀNG CHI TIÊU NHIỀU NHẤT (KHÁCH VIP)
-- ============================================================
SELECT TOP 5
    customerName, phone, gender, totalOrders, totalSpent, lastOrderDate
FROM vw_CustomerStats
WHERE totalOrders > 0
ORDER BY totalSpent DESC;
GO

-- ============================================================
-- 4. DOANH THU THEO THÁNG
-- ============================================================
EXEC sp_RevenueReport;
GO

-- ============================================================
-- 5. DOANH THU THÁNG 3/2026
-- ============================================================
EXEC sp_RevenueReport @year = 2026, @month = 3;
GO

-- ============================================================
-- 6. SẢN PHẨM SẮP HẾT HÀNG (CẦN NHẬP THÊM) - dưới 5 đơn vị
-- ============================================================
SELECT
    p.productID, p.[name] AS productName, s.[name] AS shopName,
    p.unitInStock, cat.[name] AS categoryName
FROM Product p
JOIN Shop s     ON p.shopID = s.shopID
JOIN Category cat ON p.catgID = cat.catgID
WHERE p.unitInStock <= 5 AND p.discontinued = 0
ORDER BY p.unitInStock ASC;
GO

-- ============================================================
-- 7. SẢN PHẨM CHƯA CẬP NHẬT GIÁ (unitPrice IS NULL)
-- ============================================================
SELECT productID, [name], shopID, catgID
FROM Product
WHERE unitPrice IS NULL;
GO

-- ============================================================
-- 8. SỐ LƯỢNG ĐƠN HÀNG THEO TRẠNG THÁI
-- ============================================================
SELECT [status], COUNT(*) AS totalOrders
FROM Orders
GROUP BY [status]
ORDER BY totalOrders DESC;
GO

-- ============================================================
-- 9. SHIPPER GIAO NHIỀU ĐƠN NHẤT (HIỆU SUẤT SHIPPER)
-- ============================================================
SELECT
    sh.shipperID, sh.[name] AS shipperName, sh.companyName,
    COUNT(o.orderID) AS totalDelivered
FROM Shipper sh
JOIN Orders o ON sh.shipperID = o.shipperID
WHERE o.[status] = N'Đã giao'
GROUP BY sh.shipperID, sh.[name], sh.companyName
ORDER BY totalDelivered DESC;
GO

-- ============================================================
-- 10. KHÁCH HÀNG CHƯA TỪNG ĐẶT HÀNG (dùng LEFT JOIN)
-- ============================================================
SELECT c.customerID, c.[name], c.phone
FROM Customer c
LEFT JOIN Orders o ON c.customerID = o.customerID
WHERE o.orderID IS NULL;
GO

-- ============================================================
-- 11. DOANH THU TRUNG BÌNH MỖI ĐƠN THEO PHƯƠNG THỨC THANH TOÁN
-- ============================================================
SELECT
    pm.paymentMethod,
    COUNT(pay.paymentID) AS totalPayments,
    AVG(pay.amount)      AS avgAmount,
    SUM(pay.amount)      AS totalAmount
FROM Method_Payment pm
JOIN Payment pay ON pm.payID = pay.payID
GROUP BY pm.paymentMethod
ORDER BY totalAmount DESC;
GO

-- ============================================================
-- 12. DÙNG WINDOW FUNCTION: XẾP HẠNG DOANH THU GIỮA CÁC SHOP
-- ============================================================
SELECT
    shopID, shopName, totalRevenue,
    RANK() OVER (ORDER BY totalRevenue DESC) AS revenueRank
FROM vw_RevenueByShop;
GO

-- ============================================================
-- 13. CTE: KHÁCH HÀNG CÓ GIÁ TRỊ ĐƠN HÀNG TRUNG BÌNH > 1 TRIỆU
-- ============================================================
WITH CustomerAvgOrder AS (
    SELECT
        c.customerID, c.[name],
        AVG(pay.amount) AS avgOrderAmount
    FROM Customer c
    JOIN Orders o   ON c.customerID = o.customerID
    JOIN Payment pay ON o.paymentID = pay.paymentID
    GROUP BY c.customerID, c.[name]
)
SELECT * FROM CustomerAvgOrder
WHERE avgOrderAmount > 1000000
ORDER BY avgOrderAmount DESC;
GO

-- ============================================================
-- 14. KIỂM TRA TRIGGER: Thêm đơn hàng mới qua Stored Procedure
-- ============================================================
EXEC sp_CreateOrder
    @orderID    = 'O015',
    @customerID = 'CU001',
    @shipperID  = 'SH001',
    @addressID  = 'A001',
    @paymentID  = 'PAY15',
    @payID      = 'PM02',
    @freight    = 25000;
GO

-- Thêm chi tiết đơn hàng → trigger sẽ tự trừ kho & tính tiền
INSERT INTO Order_Detail (orderID, productID, unitPrice, quantity, discount)
VALUES ('O015', 'P006', 200000, 3, 0);
GO

-- Kiểm tra: tồn kho P006 đã giảm, Payment PAY15 đã có amount
SELECT productID, unitInStock FROM Product WHERE productID = 'P006';
SELECT * FROM Payment WHERE paymentID = 'PAY15';
GO

-- ============================================================
-- 15. KIỂM TRA STORED PROCEDURE: Lịch sử đơn hàng khách CU001
-- ============================================================
EXEC sp_GetOrderHistory @customerID = 'CU001';
GO

-- ============================================================
-- 16. KIỂM TRA STORED PROCEDURE: Tìm sản phẩm điện tử dưới 1 triệu
-- ============================================================
EXEC sp_SearchProduct @catgID = 'C001', @maxPrice = 1000000;
GO

PRINT N'✅ Demo truy vấn nghiệp vụ hoàn tất!';
GO
