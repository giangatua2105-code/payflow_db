-- =========================================================
-- PAYFLOW - TỐI ƯU HÓA TRUY VẤN BÁO CÁO DÒNG TIỀN
-- Tác giả: Database Performance Engineer
-- Mô tả: Tối ưu hóa truy vấn thống kê tổng tiền nạp tháng 6/2026
-- =========================================================

CREATE DATABASE IF NOT EXISTS payflow_db;
USE payflow_db;

-- =========================================================
-- PHẦN 1: BẢNG GỐC (giữ nguyên để tham chiếu)
-- =========================================================
CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(15,2),
    transaction_type VARCHAR(20),   -- 'DEPOSIT', 'WITHDRAW', 'TRANSFER'
    created_at DATETIME
);

-- =========================================================
-- PHẦN 2: TẠO COMPOSITE INDEX
-- Đặt transaction_type trước (cardinality thấp, lọc mạnh)
-- rồi đến created_at (dùng cho range condition)
-- =========================================================
CREATE INDEX idx_type_date
ON Transactions(transaction_type, created_at);

-- =========================================================
-- PHẦN 3: TRUY VẤN GỐC (LỖI - NON-SARGABLE)
-- Dùng hàm YEAR() và MONTH() trên cột created_at
-- khiến MySQL không thể dùng Index → Full Table Scan
-- =========================================================
EXPLAIN
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND YEAR(created_at) = 2026
  AND MONTH(created_at) = 6;

-- =========================================================
-- PHẦN 4: TRUY VẤN ĐÃ TỐI ƯU (SARGABLE)
-- Thay YEAR/MONTH bằng range condition trên created_at
-- → MySQL dùng được B-Tree Index idx_type_date
-- =========================================================
EXPLAIN
SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND created_at >= '2026-06-01 00:00:00'
  AND created_at <  '2026-07-01 00:00:00';

-- =========================================================
-- PHẦN 5: ĐO THỜI GIAN THỰC THI (TÙY CHỌN)
-- =========================================================
SET profiling = 1;

SELECT SUM(amount) AS total_deposit
FROM Transactions
WHERE transaction_type = 'DEPOSIT'
  AND created_at >= '2026-06-01 00:00:00'
  AND created_at <  '2026-07-01 00:00:00';

SHOW PROFILES;