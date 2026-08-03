-- ============================================================
-- FILE 03: TRIGGER, VIEW, STORED PROCEDURE
-- Project: Quản lý Đơn Hàng (QLDonHang)
-- ============================================================

USE QLDonHang
GO

-- ============================================================
-- TRIGGER 1: Tự động trừ tồn kho khi thêm Order_Detail
-- ============================================================
CREATE OR ALTER TRIGGER trg_AfterInsert_OrderDetail
ON Order_Detail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra còn đủ hàng không
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Product p ON i.productID = p.productID
        WHERE p.unitInStock < i.quantity
    )
    BEGIN
        RAISERROR(N'Sản phẩm không đủ số lượng trong kho!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Trừ tồn kho
    UPDATE p
    SET p.unitInStock = p.unitInStock - i.quantity
    FROM Product p
    INNER JOIN inserted i ON p.productID = i.productID;

    -- Cập nhật tổng tiền Payment
    UPDATE pay
    SET pay.amount = (
        SELECT SUM(od.unitPrice * od.quantity * (1 - od.discount))
        FROM Order_Detail od
        JOIN Orders o ON od.orderID = o.orderID
        WHERE o.paymentID = pay.paymentID
    )
    FROM Payment pay
    JOIN Orders o ON pay.paymentID = o.paymentID
    JOIN inserted i ON o.orderID = i.orderID;
END;
GO

-- ============================================================
-- TRIGGER 2: Hoàn lại tồn kho khi xóa Order_Detail
-- ============================================================
CREATE OR ALTER TRIGGER trg_AfterDelete_OrderDetail
ON Order_Detail
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Hoàn lại tồn kho
    UPDATE p
    SET p.unitInStock = p.unitInStock + d.quantity
    FROM Product p
    INNER JOIN deleted d ON p.productID = d.productID;

    -- Cập nhật lại tổng tiền Payment
    UPDATE pay
    SET pay.amount = ISNULL((
        SELECT SUM(od.unitPrice * od.quantity * (1 - od.discount))
        FROM Order_Detail od
        JOIN Orders o ON od.orderID = o.orderID
        WHERE o.paymentID = pay.paymentID
    ), 0)
    FROM Payment pay
    JOIN Orders o ON pay.paymentID = o.paymentID
    JOIN deleted d ON o.orderID = d.orderID;
END;
GO

-- ============================================================
-- TRIGGER 3: Không cho phép cập nhật đơn hàng đã giao
-- ============================================================
CREATE OR ALTER TRIGGER trg_PreventUpdate_DeliveredOrder
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM deleted
        WHERE [status] = N'Đã giao'
    )
    BEGIN
        RAISERROR(N'Không thể chỉnh sửa đơn hàng đã giao!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- ============================================================
-- VIEW 1: Tổng quan đơn hàng (kết hợp nhiều bảng)
-- ============================================================
CREATE OR ALTER VIEW vw_OrderSummary
AS
SELECT
    o.orderID,
    o.orderDate,
    o.shippedDate,
    o.[status],
    c.[name]          AS customerName,
    c.phone           AS customerPhone,
    ac.address        AS deliveryAddress,
    sh.[name]         AS shipperName,
    sh.companyName    AS shippingCompany,
    o.freight,
    pm.paymentMethod,
    pay.amount        AS totalAmount,
    pay.amount + o.freight AS grandTotal
FROM Orders o
JOIN Customer         c   ON o.customerID = c.customerID
JOIN Address_Customer ac  ON o.addressID  = ac.addressID
LEFT JOIN Shipper     sh  ON o.shipperID  = sh.shipperID
JOIN Payment          pay ON o.paymentID  = pay.paymentID
JOIN Method_Payment   pm  ON pay.payID    = pm.payID;
GO

-- ============================================================
-- VIEW 2: Doanh thu theo từng Shop
-- ============================================================
CREATE OR ALTER VIEW vw_RevenueByShop
AS
SELECT
    s.shopID,
    s.[name]          AS shopName,
    s.email,
    COUNT(DISTINCT o.orderID)                               AS totalOrders,
    SUM(od.quantity)                                        AS totalItemsSold,
    SUM(od.unitPrice * od.quantity * (1 - od.discount))     AS totalRevenue
FROM Shop s
JOIN Product      p  ON s.shopID    = p.shopID
JOIN Order_Detail od ON p.productID = od.productID
JOIN Orders       o  ON od.orderID  = o.orderID
WHERE o.[status] != N'Đã hủy'
GROUP BY s.shopID, s.[name], s.email;
GO

-- ============================================================
-- VIEW 3: Sản phẩm bán chạy
-- ============================================================
CREATE OR ALTER VIEW vw_TopSellingProducts
AS
SELECT
    p.productID,
    p.[name]           AS productName,
    cat.[name]         AS categoryName,
    s.[name]           AS shopName,
    p.unitPrice,
    p.unitInStock,
    SUM(od.quantity)   AS totalSold,
    SUM(od.unitPrice * od.quantity * (1 - od.discount)) AS totalRevenue
FROM Product      p
JOIN Category     cat ON p.catgID    = cat.catgID
JOIN Shop         s   ON p.shopID    = s.shopID
JOIN Order_Detail od  ON p.productID = od.productID
JOIN Orders       o   ON od.orderID  = o.orderID
WHERE o.[status] != N'Đã hủy'
GROUP BY p.productID, p.[name], cat.[name], s.[name], p.unitPrice, p.unitInStock;
GO

-- ============================================================
-- VIEW 4: Khách hàng VIP (chi tiêu nhiều nhất)
-- ============================================================
CREATE OR ALTER VIEW vw_CustomerStats
AS
SELECT
    c.customerID,
    c.[name]        AS customerName,
    c.phone,
    CASE WHEN c.gender = 1 THEN N'Nam' ELSE N'Nữ' END AS gender,
    DATEDIFF(YEAR, c.birthdate, GETDATE())              AS age,
    COUNT(o.orderID)                                    AS totalOrders,
    SUM(pay.amount)                                     AS totalSpent,
    MAX(o.orderDate)                                    AS lastOrderDate
FROM Customer c
LEFT JOIN Orders  o   ON c.customerID = o.customerID
LEFT JOIN Payment pay ON o.paymentID  = pay.paymentID
WHERE o.[status] IS NULL OR o.[status] != N'Đã hủy'
GROUP BY c.customerID, c.[name], c.phone, c.gender, c.birthdate;
GO

-- ============================================================
-- STORED PROCEDURE 1: Tạo đơn hàng mới (có Transaction)
-- ============================================================
CREATE OR ALTER PROCEDURE sp_CreateOrder
    @orderID    VARCHAR(10),
    @customerID VARCHAR(10),
    @shipperID  VARCHAR(10),
    @addressID  VARCHAR(10),
    @paymentID  VARCHAR(10),
    @payID      VARCHAR(10),
    @freight    DECIMAL(18,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Kiểm tra khách hàng tồn tại
        IF NOT EXISTS (SELECT 1 FROM Customer WHERE customerID = @customerID)
        BEGIN
            RAISERROR(N'Khách hàng không tồn tại!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Kiểm tra địa chỉ thuộc khách hàng
        IF NOT EXISTS (
            SELECT 1 FROM Address_Customer
            WHERE addressID = @addressID AND customerID = @customerID
        )
        BEGIN
            RAISERROR(N'Địa chỉ không thuộc khách hàng này!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Tạo Payment trước
        INSERT INTO Payment (paymentID, amount, paymentDate, payID)
        VALUES (@paymentID, 0, GETDATE(), @payID);

        -- Tạo đơn hàng
        INSERT INTO Orders (orderID, customerID, shipperID, orderDate, freight, addressID, paymentID, [status])
        VALUES (@orderID, @customerID, @shipperID, GETDATE(), @freight, @addressID, @paymentID, N'Chờ xác nhận');

        COMMIT TRANSACTION;

        SELECT orderID, customerID, orderDate, [status]
        FROM Orders WHERE orderID = @orderID;

        PRINT N'✅ Tạo đơn hàng ' + @orderID + N' thành công!';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @msg NVARCHAR(500) = ERROR_MESSAGE();
        RAISERROR(@msg, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- STORED PROCEDURE 2: Cập nhật trạng thái đơn hàng
-- ============================================================
CREATE OR ALTER PROCEDURE sp_UpdateOrderStatus
    @orderID   VARCHAR(10),
    @newStatus NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Orders WHERE orderID = @orderID)
        BEGIN
            RAISERROR(N'Đơn hàng không tồn tại!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @currentStatus NVARCHAR(20);
        SELECT @currentStatus = [status] FROM Orders WHERE orderID = @orderID;

        IF @currentStatus = N'Đã giao'
        BEGIN
            RAISERROR(N'Không thể thay đổi trạng thái đơn hàng đã giao!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @currentStatus = N'Đã hủy'
        BEGIN
            RAISERROR(N'Không thể thay đổi trạng thái đơn hàng đã hủy!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE Orders
        SET [status] = @newStatus,
            shippedDate = CASE WHEN @newStatus = N'Đã giao' THEN GETDATE() ELSE shippedDate END
        WHERE orderID = @orderID;

        COMMIT TRANSACTION;
        PRINT N'✅ Cập nhật trạng thái đơn ' + @orderID + N' → ' + @newStatus;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @msg NVARCHAR(500) = ERROR_MESSAGE();
        RAISERROR(@msg, 16, 1);
    END CATCH
END;
GO

-- ============================================================
-- STORED PROCEDURE 3: Xem lịch sử đơn hàng của khách hàng
-- ============================================================
CREATE OR ALTER PROCEDURE sp_GetOrderHistory
    @customerID VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Customer WHERE customerID = @customerID)
    BEGIN
        RAISERROR(N'Khách hàng không tồn tại!', 16, 1);
        RETURN;
    END

    SELECT
        o.orderID,
        o.orderDate,
        o.shippedDate,
        o.[status],
        sh.[name]       AS shipperName,
        sh.companyName,
        ac.address      AS deliveryAddress,
        pay.amount      AS totalAmount,
        pm.paymentMethod,
        o.freight,
        pay.amount + o.freight AS grandTotal
    FROM Orders o
    JOIN Address_Customer ac ON o.addressID = ac.addressID
    LEFT JOIN Shipper     sh ON o.shipperID = sh.shipperID
    JOIN Payment         pay ON o.paymentID = pay.paymentID
    JOIN Method_Payment   pm ON pay.payID   = pm.payID
    WHERE o.customerID = @customerID
    ORDER BY o.orderDate DESC;
END;
GO

-- ============================================================
-- STORED PROCEDURE 4: Thống kê doanh thu theo tháng/năm
-- ============================================================
CREATE OR ALTER PROCEDURE sp_RevenueReport
    @year  INT = NULL,
    @month INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        YEAR(o.orderDate)   AS [year],
        MONTH(o.orderDate)  AS [month],
        COUNT(o.orderID)    AS totalOrders,
        SUM(pay.amount)     AS totalRevenue,
        AVG(pay.amount)     AS avgOrderValue,
        MAX(pay.amount)     AS maxOrderValue
    FROM Orders o
    JOIN Payment pay ON o.paymentID = pay.paymentID
    WHERE o.[status] = N'Đã giao'
        AND (@year  IS NULL OR YEAR(o.orderDate)  = @year)
        AND (@month IS NULL OR MONTH(o.orderDate) = @month)
    GROUP BY YEAR(o.orderDate), MONTH(o.orderDate)
    ORDER BY [year] DESC, [month] DESC;
END;
GO

-- ============================================================
-- STORED PROCEDURE 5: Tìm kiếm sản phẩm
-- ============================================================
CREATE OR ALTER PROCEDURE sp_SearchProduct
    @keyword  NVARCHAR(100) = NULL,
    @catgID   VARCHAR(10)   = NULL,
    @shopID   VARCHAR(10)   = NULL,
    @minPrice DECIMAL(18,2) = NULL,
    @maxPrice DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.productID,
        p.[name]        AS productName,
        cat.[name]      AS categoryName,
        s.[name]        AS shopName,
        p.unitPrice,
        p.unitInStock,
        p.discontinued
    FROM Product p
    JOIN Category cat ON p.catgID = cat.catgID
    JOIN Shop     s   ON p.shopID = s.shopID
    WHERE p.discontinued = 0
        AND (@keyword  IS NULL OR p.[name] LIKE N'%' + @keyword + N'%')
        AND (@catgID   IS NULL OR p.catgID = @catgID)
        AND (@shopID   IS NULL OR p.shopID = @shopID)
        AND (@minPrice IS NULL OR p.unitPrice >= @minPrice)
        AND (@maxPrice IS NULL OR p.unitPrice <= @maxPrice)
    ORDER BY p.unitPrice ASC;
END;
GO

PRINT N'✅ Tạo Trigger, View, Stored Procedure thành công!';
GO
