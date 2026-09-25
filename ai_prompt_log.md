# AI Prompt Log - PayFlow Optimization

## 1. Về Non-SARGable và Index

**Prompt:**
"Trong MySQL, nếu tôi tạo Index cho cột ngày tháng, nhưng trong WHERE tôi viết WHERE YEAR(col) = 2026, tại sao MySQL lại từ chối dùng Index và phải quét toàn bộ bảng?"

**Trả lời tóm tắt:**
- SARGable = Search ARGument able — điều kiện WHERE có thể dùng Index.
- Khi bọc hàm quanh cột (`YEAR(col)`), MySQL không so sánh được trực tiếp giá trị cột với giá trị trong B-Tree.
- Kết quả: mất khả năng tìm kiếm nhị phân → Full Table Scan.
- Cách khắc phục: viết lại thành range `col >= '...' AND col < '...'`.

---

## 2. Về Composite Index và thứ tự cột

**Prompt:**
"Khi tạo Composite Index (transaction_type, created_at), thứ tự cột có quan trọng không? Nên đặt cột nào trước?"

**Trả lời tóm tắt:**
- Thứ tự rất quan trọng — tuân theo nguyên tắc **Leftmost Prefix**.
- Cột có **selectivity cao** và xuất hiện trong **đẳng thức** (`=`) nên đặt trước.
- `transaction_type` có ít giá trị phân biệt nhưng lọc mạnh vì luôn dùng `=`.
- `created_at` dùng cho range (`>=`, `<`) nên đặt sau.
- Index đúng: `(transaction_type, created_at)`.

---

## 3. Về Execution Time trong MySQL

**Prompt:**
"Làm sao xem chi tiết thời gian thực thi của câu SQL trong MySQL thay vì chỉ xem Execution Plan?"

**Trả lời tóm tắt:**
- Bật profiling: `SET profiling = 1;`
- Chạy truy vấn cần đo.
- Xem kết quả: `SHOW PROFILES;`
- Xem chi tiết từng bước: `SHOW PROFILE FOR QUERY <id>;`

---

## 4. Về "Using index condition" vs "Using index"

**Prompt:**
"Cột Extra trong EXPLAIN ghi 'Using index condition' khác gì với 'Using index' (Covering Index)?"

**Trả lời tóm tắt:**
- **Using index condition (ICP)**: MySQL đẩy điều kiện WHERE xuống tầng Storage Engine để lọc sớm, nhưng vẫn phải đọc bảng gốc để lấy cột còn lại.
- **Using index (Covering Index)**: Toàn bộ cột cần thiết đã có trong Index → không cần đọc bảng gốc → nhanh nhất.
- Muốn đạt Covering Index: đưa cột `amount` vào Index → `(transaction_type, created_at, amount)`.

---

## 5. Về rủi ro khi lạm dụng Index

**Prompt:**
"Nếu bảng Transactions bị INSERT/UPDATE/DELETE liên tục, việc tạo thêm nhiều Index gây rủi ro gì?"

**Trả lời tóm tắt:**
- Mỗi Index là một cấu trúc B-Tree riêng phải cập nhật mỗi lần ghi → tăng chi phí I/O.
- Ghi chậm hơn, có thể gây lock contention.
- Tốn dung lượng đĩa.
- Nguyên tắc: chỉ tạo Index cho cột thực sự dùng trong WHERE/JOIN/ORDER BY.
