-- ============================================================
-- FILE 01: TẠO DATABASE VÀ CÁC BẢNG
-- Project: Quản lý Đơn Hàng (QLDonHang)
-- Author: [Nguyễn Đức Hiếu]
-- Version: 2.0
-- ============================================================

CREATE DATABASE QLDonHang
GO

USE QLDonHang
GO

-- ============================================================
-- BẢNG CUSTOMER
-- ============================================================
CREATE TABLE Customer (
    customerID  VARCHAR(10)  NOT NULL,
    [name]      NVARCHAR(100) NOT NULL,
    phone       NVARCHAR(20) NOT NULL,
    gender      BIT,
    birthdate   DATE,
    CONSTRAINT pk_Customer PRIMARY KEY (customerID),
    CONSTRAINT chk_Customer_phone CHECK (LEN(phone) >= 10)
);
GO

-- ============================================================
-- BẢNG ADDRESS_CUSTOMER
-- ============================================================
CREATE TABLE Address_Customer (
    addressID   VARCHAR(10)   NOT NULL,
    customerID  VARCHAR(10)   NOT NULL,
    address     NVARCHAR(200) NOT NULL,
    CONSTRAINT pk_Address_Customer PRIMARY KEY (addressID),
    CONSTRAINT fk_Address_Customer FOREIGN KEY (customerID)
        REFERENCES Customer(customerID)
);
GO

-- ============================================================
-- BẢNG SHOP
-- ============================================================
CREATE TABLE Shop (
    shopID   VARCHAR(10)   NOT NULL,
    [name]   NVARCHAR(100) NOT NULL,
    phone    NVARCHAR(20)  NOT NULL,
    [address] NVARCHAR(200),
    email    NVARCHAR(100),
    CONSTRAINT pk_Shop PRIMARY KEY (shopID),
    CONSTRAINT chk_Shop_email CHECK (email LIKE '%@%.%')
);
GO

-- ============================================================
-- BẢNG SHIPPER
-- ============================================================
CREATE TABLE Shipper (
    shipperID   VARCHAR(10)   NOT NULL,
    [name]      NVARCHAR(100) NOT NULL,
    phone       NVARCHAR(20)  NOT NULL,
    companyName NVARCHAR(100),
    CONSTRAINT pk_Shipper PRIMARY KEY (shipperID),
    CONSTRAINT chk_Shipper_phone CHECK (LEN(phone) >= 10)
);
GO

-- ============================================================
-- BẢNG CATEGORY
-- ============================================================
CREATE TABLE Category (
    catgID VARCHAR(10)   NOT NULL,
    [name] NVARCHAR(100) NOT NULL,
    CONSTRAINT pk_Category PRIMARY KEY (catgID)
);
GO

-- ============================================================
-- BẢNG PRODUCT
-- ============================================================
CREATE TABLE Product (
    productID       VARCHAR(10)   NOT NULL,
    shopID          VARCHAR(10)   NOT NULL,
    catgID          VARCHAR(10)   NOT NULL,
    [name]          NVARCHAR(100) NOT NULL,
    unitPrice       DECIMAL(18,2),
    unitInStock     INT           DEFAULT 0,
    quantityPerUnit NVARCHAR(50),
    discontinued    BIT           DEFAULT 0,
    CONSTRAINT pk_Product PRIMARY KEY (productID),
    CONSTRAINT fk_Product_Shop     FOREIGN KEY (shopID) REFERENCES Shop(shopID),
    CONSTRAINT fk_Product_Category FOREIGN KEY (catgID) REFERENCES Category(catgID),
    CONSTRAINT chk_Product_unitPrice  CHECK (unitPrice IS NULL OR unitPrice >= 0),
    CONSTRAINT chk_Product_unitInStock CHECK (unitInStock >= 0)
);
GO

-- ============================================================
-- BẢNG METHOD_PAYMENT
-- ============================================================
CREATE TABLE Method_Payment (
    payID          VARCHAR(10)  NOT NULL,
    paymentMethod  NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_Method_Payment PRIMARY KEY (payID)
);
GO

-- ============================================================
-- BẢNG PAYMENT
-- ============================================================
CREATE TABLE Payment (
    paymentID   VARCHAR(10)   NOT NULL,
    amount      DECIMAL(18,2) DEFAULT 0,
    paymentDate DATE,
    payID       VARCHAR(10)   NOT NULL,
    CONSTRAINT pk_Payment PRIMARY KEY (paymentID),
    CONSTRAINT fk_Payment_Method FOREIGN KEY (payID) REFERENCES Method_Payment(payID),
    CONSTRAINT chk_Payment_amount CHECK (amount >= 0)
);
GO

-- ============================================================
-- BẢNG ORDERS
-- ============================================================
CREATE TABLE Orders (
    orderID     VARCHAR(10)   NOT NULL,
    customerID  VARCHAR(10)   NOT NULL,
    shipperID   VARCHAR(10),
    orderDate   DATE          NOT NULL DEFAULT GETDATE(),
    shippedDate DATE,
    freight     DECIMAL(18,2) DEFAULT 0,         -- Sửa typo: frieght → freight
    addressID   VARCHAR(10)   NOT NULL,
    paymentID   VARCHAR(10)   NOT NULL,
    [status]    NVARCHAR(20)  NOT NULL DEFAULT N'Chờ xác nhận',
    CONSTRAINT pk_Orders PRIMARY KEY (orderID),
    CONSTRAINT fk_Order_Customer FOREIGN KEY (customerID) REFERENCES Customer(customerID),
    CONSTRAINT fk_Order_Shipper  FOREIGN KEY (shipperID)  REFERENCES Shipper(shipperID),
    CONSTRAINT fk_Order_Address  FOREIGN KEY (addressID)  REFERENCES Address_Customer(addressID),
    CONSTRAINT fk_Order_Payment  FOREIGN KEY (paymentID)  REFERENCES Payment(paymentID),
    CONSTRAINT chk_Orders_freight CHECK (freight >= 0),
    CONSTRAINT chk_Orders_shippedDate CHECK (shippedDate IS NULL OR shippedDate >= orderDate),
    CONSTRAINT chk_Orders_status CHECK ([status] IN (
        N'Chờ xác nhận', N'Đã xác nhận', N'Đang giao', N'Đã giao', N'Đã hủy'
    ))
);
GO

-- ============================================================
-- BẢNG ORDER_DETAIL
-- ============================================================
CREATE TABLE Order_Detail (
    orderID   VARCHAR(10)   NOT NULL,
    productID VARCHAR(10)   NOT NULL,
    unitPrice DECIMAL(18,2) NOT NULL,   -- Snapshot giá tại thời điểm đặt hàng
    quantity  INT           NOT NULL,
    discount  FLOAT         NOT NULL DEFAULT 0,
    CONSTRAINT pk_OrderDetail PRIMARY KEY (orderID, productID),
    CONSTRAINT fk_OD_Order   FOREIGN KEY (orderID)   REFERENCES Orders(orderID),
    CONSTRAINT fk_OD_Product FOREIGN KEY (productID) REFERENCES Product(productID),
    CONSTRAINT chk_OD_unitPrice CHECK (unitPrice > 0),
    CONSTRAINT chk_OD_quantity  CHECK (quantity > 0),
    CONSTRAINT chk_OD_discount  CHECK (discount BETWEEN 0 AND 1)
);
GO

-- ============================================================
-- BẢNG ACCOUNT
-- ============================================================
CREATE TABLE Account (
    accountID  INT          IDENTITY(1,1) NOT NULL,
    username   VARCHAR(50)  NOT NULL,
    -- Trong thực tế: lưu password đã hash (VD: HASHBYTES('SHA2_256', password))
    -- Ở đây để đơn giản cho mục đích học tập
    [password] VARCHAR(255) NOT NULL,
    role       VARCHAR(20)  NOT NULL,
    customerID VARCHAR(10)  NULL,
    shopID     VARCHAR(10)  NULL,
    shipperID  VARCHAR(10)  NULL,
    isActive   BIT          NOT NULL DEFAULT 1,
    createdAt  DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT pk_Account    PRIMARY KEY (accountID),
    CONSTRAINT uq_Account_username UNIQUE (username),
    CONSTRAINT chk_Account_role CHECK (role IN ('CUSTOMER', 'SHOP', 'SHIPPER')),
    CONSTRAINT fk_Account_Customer FOREIGN KEY (customerID) REFERENCES Customer(customerID),
    CONSTRAINT fk_Account_Shop     FOREIGN KEY (shopID)     REFERENCES Shop(shopID),
    CONSTRAINT fk_Account_Shipper  FOREIGN KEY (shipperID)  REFERENCES Shipper(shipperID)
);
GO

-- ============================================================
-- INDEX để tăng hiệu năng truy vấn thường dùng
-- ============================================================

-- Tìm đơn hàng theo khách hàng
CREATE INDEX idx_Orders_customerID ON Orders(customerID);
-- Tìm đơn hàng theo ngày
CREATE INDEX idx_Orders_orderDate ON Orders(orderDate);
-- Tìm sản phẩm theo shop
CREATE INDEX idx_Product_shopID ON Product(shopID);
-- Tìm sản phẩm theo danh mục
CREATE INDEX idx_Product_catgID ON Product(catgID);
-- Tìm account theo role
CREATE INDEX idx_Account_role ON Account(role);
GO

PRINT N'✅ Tạo database và bảng thành công!';
GO
