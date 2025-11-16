# 1. Chọn Image nền tảng
FROM node:18-alpine

# 2. Tạo và đặt thư mục làm việc
WORKDIR /app

# 3. Sao chép tệp quản lý thư viện
COPY package*.json ./

# 4. Cài đặt thư viện (dependencies)
RUN npm ci --only=production

# 5. Sao chép toàn bộ mã nguồn
COPY . .

# 6. Mở cổng (Port) - THAY SỐ 3000 NẾU CẦN
EXPOSE 5005

# 7. Lệnh khởi động
CMD ["npm", "start"]
