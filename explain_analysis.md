# Phân tích EXPLAIN - PayFlow

## 1. Truy vấn GỐC (Non-SARGable)

WHERE transaction_type = 'DEPOSIT'
AND created_at >= '2026-06-01 00:00:00'
AND created_at < '2026-07-01 00:00:00'

| Chỉ số | Giá trị | Ý nghĩa |
|--------|---------|---------|
| type | **range** | Duyệt theo khoảng trên B-Tree Index |
| possible_keys | idx_type_date | Index được xét đến |
| key | **idx_type_date** | Index được chọn để dùng |
| rows | **~vài nghìn** | Chỉ đọc đúng khoảng cần thiết |
| Extra | Using index condition | Lọc ngay trên Index |

---

## 3. Kết luận

- `type` giảm từ **ALL → range**.
- `rows` giảm từ **5,000,000 → vài nghìn** (giảm hơn 99%).
- `key` từ **NULL → idx_type_date**.
- Thời gian chạy từ **45 giây → dưới 1 giây**.
- CPU không còn vọt lên 100%, hệ thống không bị khóa bảng.
