# 1. Chọn Image nền tảng
# Sử dụng một image Node.js chính thức, gọn nhẹ (alpine)
# Bạn có thể đổi '18' thành phiên bản Node bạn dùng (ví dụ: 16, 20)
FROM node:18-alpine

# 2. Tạo và đặt thư mục làm việc
# Tất cả các lệnh sau sẽ chạy bên trong thư mục /app
WORKDIR /app

# 3. Sao chép tệp quản lý thư viện
# Chỉ sao chép các tệp này trước để tận dụng cache của Docker
# Dấu * sẽ sao chép cả package.json và package-lock.json
COPY package*.json ./

# 4. Cài đặt thư viện (dependencies)
# 'npm ci' được tối ưu cho production, nó cài đặt chính xác từ package-lock.json
RUN npm ci --only=production

# 5. Sao chép toàn bộ mã nguồn
# Sao chép tất cả các tệp còn lại trong dự án vào thư mục /app
COPY . .

# 6. Mở cổng (Port)
# !!! QUAN TRỌNG: Thay 3000 bằng cổng (port) mà ứng dụng của bạn chạy
# Bạn có thể tìm thấy cổng này trong code (ví dụ: app.listen(3000))
# hoặc trong tệp docker-compose.yml
EXPOSE 5005

# 7. Lệnh khởi động
# Lệnh để chạy ứng dụng của bạn khi container khởi động
# Thường là "npm start" (được định nghĩa trong package.json)
CMD ["npm", "start"]
