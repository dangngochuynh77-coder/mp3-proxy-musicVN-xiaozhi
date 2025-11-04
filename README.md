# 🎵 Proxy API Nhạc Việt for Xiaozhi Music


**API Proxy chuyển đổi dữ liệu Nhạc Online MP3 sang định dạng Xiaozhi Music**

[Tính năng](#-tính-năng) • [Cài đặt](#-cài-đặt-nhanh) • [Sử dụng](#-sử-dụng) • [API](#-api-endpoints) • [Cấu hình](#️-cấu-hình)

</div>

---

## 📖 Giới thiệu

Đây là phiên bản API Music dành riêng cho **Xiaozhi Music Gốc chạy Server Xiaozhishop**, chạy trên API của [@nvhung9](https://github.com/nvhung9/mp3-api) 🙏

**Xiaozhi Proxy** tạo lớp trung gian (proxy) để chuyển đổi kết quả API từ Zing MP3 sang định dạng tương thích với server Xiaozhi Music chính thức.

### 🎯 Mục đích

- ✅ Tương thích 100% với ESP32 Xiaozhi Music
- ✅ Chuyển đổi tự động định dạng API
- ✅ Dễ dàng deploy với Docker
- ✅ Hỗ trợ tìm kiếm bài hát tiếng Việt
- ✅ Trả về 3 bài hát mỗi lần tìm kiếm
- ✅ Cache thông minh - tự động download trước audio
- ✅ Streaming nhạc chất lượng cao

---

## ✨ Tính năng

- 🎼 **Tìm kiếm bài hát** - Hỗ trợ tìm kiếm tiếng Việt, trả về 3 bài hát
- 🎧 **Pre-download Audio** - Tự động tải trước 3 bài hát vào cache
- 💾 **Smart Cache** - Cache tối đa 10 bài hát, tự động xóa bài cũ
- 🔄 **Format Converter** - Chuyển đổi tự động sang định dạng Xiaozhi
- 🎵 **Proxy Audio & Lyric** - Stream audio và lời bài hát
- 🐳 **Docker Ready** - Deploy 1 dòng lệnh
- ❤️ **Health Check** - Tự động kiểm tra trạng thái và cache

---

## 🚀 Cài đặt nhanh

### Yêu cầu hệ thống

- Docker & Docker Compose
- 1GB RAM trở lên (cache cần ~100-200MB)
- Port 5005 và 5555 khả dụng

### Bước 1: Clone repository

```bash
# Tạo thư mục dự án
mkdir xiaozhi-mp3-svr
cd xiaozhi-mp3-svr

# Save Repo về.
```

### Bước 2: Cấu trúc thư mục

Đảm bảo thư mục có cấu trúc như sau:

```
xiaozhi-mp3-svr/
├── docker-compose.yml
├── README.md
├── mp3-api/
│   ├── package.json
│   └── [mp3-api files từ nvhung9]
└── adapter/
    ├── xiaozhi-adapter.js
    └── package.json
```

### Bước 3: Khởi động services

```bash
# Khởi động tất cả services
docker-compose up -d

# Xem logs real-time
docker-compose logs -f

# Kiểm tra trạng thái
docker-compose ps
```

### Bước 4: Kiểm tra hoạt động

```bash
# Test MP3 API
curl http://localhost:5555/health

# Test Xiaozhi Adapter (kiểm tra cache)
curl http://localhost:5005/health

# Response mẫu:
# {
#   "status": "ok",
#   "cache_size": 0,
#   "cached_songs": []
# }
```

Nếu thấy response `{"status":"ok"}` là thành công! 🎉

---

## 🎮 Sử dụng

### Test tìm kiếm bài hát

```bash
# Tìm kiếm theo tên bài hát ( thay localhost thành IP của bạn )
curl "http://localhost:5005/stream_pcm?song=Sóng+gió"

# Tìm kiếm kèm tên ca sĩ
curl "http://localhost:5005/stream_pcm?song=Nơi+này+có+anh&artist=Sơn+Tùng+MTP"

# Response trả về 3 bài hát:
# {
#   "count": 3,
#   "songs": [
#     {
#       "title": "Sóng Gió",
#       "artist": "Jack, K-ICM",
#       "audio_url": "/proxy_audio?id=ZWAEIUUB",
#       "lyric_url": "/proxy_lyric?id=ZWAEIUUB",
#       "thumbnail": "https://...",
#       "duration": 254
#     },
#     ...
#   ]
# }
```

### Phát nhạc từ cache

```bash
# Sau khi search, audio đã được cache
# ESP32 có thể gọi trực tiếp:
curl "http://localhost:5005/proxy_audio?id=ZWAEIUUB" --output song.mp3

# Lấy lời bài hát
curl "http://localhost:5005/proxy_lyric?id=ZWAEIUUB"
```

---

### 🎧 Proxy Audio - Phát nhạc từ cache

```http
GET /proxy_audio?id={song_id}
```

**Features:**
- ✅ Serve audio từ cache (nếu có)
- ✅ Tự động download nếu chưa có trong cache
- ✅ Response ngay lập tức nếu đã cache
- ✅ Support Content-Length và Accept-Ranges

**Headers:**
```
Content-Type: audio/mpeg
Content-Length: [file_size]
Accept-Ranges: bytes
Cache-Control: public, max-age=86400
```

### 📝 Proxy Lyric - Lời bài hát

```http
GET /proxy_lyric?id={song_id}
```

Trả về lời bài hát dạng LRC format.

**Response:**
```
[00:15.23]Bao lời anh đã nói
[00:18.45]Giờ em không tin nữa
...
```

### ❤️ Health Check

```http
GET /health
```

Kiểm tra trạng thái service và cache.

**Response:**
```json
{
  "status": "ok",
  "cache_size": 6,
  "cached_songs": [
    "ZWAEIUUB",
    "Z7I0OFAQ",
    "Z6EW6OOC",
    "..."
  ]
}
```

---

## ⚙️ Cấu hình

### Biến môi trường

| Biến | Mô tả | Mặc định |
|------|-------|----------|
| `PORT` | Port của Xiaozhi Adapter | 5005 |
| `MP3_API_URL` | URL của MP3 API service | http://mp3-api:5555 |
| `NODE_ENV` | Môi trường chạy | production |

### Cache Configuration

Trong file `xiaozhi-adapter.js`:

```javascript
const CACHE_MAX_SIZE = 10; // Cache tối đa 10 bài hát
```

**Cách hoạt động:**
- Mỗi lần search, tự động download 3 bài hát vào cache
- Cache tối đa 10 bài (có thể tăng lên nếu muốn)
- Tự động xóa bài cũ nhất khi cache đầy (FIFO)
- Mỗi file audio ~3-5MB

### Thay đổi port

Sửa trong `docker-compose.yml`:

```yaml
ports:
  - "8080:5005"  # Đổi port 5005 thành 8080
```

---

## 📊 Cách thức hoạt động

### Luồng xử lý (3 Songs Buffered Version)

```
1. ESP32 gửi: /stream_pcm?song=Sóng+gió

2. Adapter tìm kiếm → Tìm thấy 3 bài phù hợp

3. Pre-download Audio:
   ├─ Bài 1: "Sóng Gió" (Jack) → Download → Cache
   ├─ Bài 2: "Sóng Gió Remix" → Download → Cache
   └─ Bài 3: "Sóng Gió Sinkra" → Download → Cache

4. Trả về JSON với 3 bài hát:
   {
     "count": 3,
     "songs": [...]
   }

5. ESP32 chọn bài → Gọi /proxy_audio?id=XXX

6. Adapter serve ngay từ cache (đã download sẵn) ✅
```

### Ưu điểm của cách này

- ⚡ **Phát nhạc ngay lập tức** - Không phải đợi download
- 🎯 **Tối ưu cho ESP32** - Buffer 3 bài, không cần xử lý phức tạp
- 💾 **Tiết kiệm băng thông** - Cache giảm request đến Zing MP3
- 🔄 **Smart caching** - Tự động quản lý cache

---

## 🔧 Quản lý Docker

### Các lệnh thường dùng

```bash
# Khởi động
docker-compose up -d

# Dừng services
docker-compose stop

# Xóa containers
docker-compose down

# Xem logs
docker-compose logs -f

# Xem logs của adapter (để thấy cache)
docker-compose logs -f xiaozhi-adapter

# Restart service
docker-compose restart xiaozhi-adapter

# Rebuild containers
docker-compose up -d --build

# Xem trạng thái
docker-compose ps
```

### Xem logs real-time

```bash
# Logs của adapter sẽ hiển thị:
docker-compose logs -f xiaozhi-adapter

# Output mẫu:
# 🔍 Searching: "Sóng gió" by ""
# ✅ Found 3 songs
# 📥 Processing: Sóng Gió (ID: ZWAEIUUB)
# ⬇️ Pre-downloading audio for ZWAEIUUB...
# ✅ Downloaded 4523156 bytes
# ...
# ✅ Returning 3 songs
```

### Update code

```bash
# Pull code mới
git pull origin main

# Restart services
docker-compose down
docker-compose up -d --build
```

---

## 🐛 Xử lý sự cố

### Service không khởi động

```bash
# Kiểm tra logs chi tiết
docker-compose logs

# Kiểm tra port đã được sử dụng chưa
netstat -tulpn | grep 5005
netstat -tulpn | grep 5555

# Stop service đang dùng port
sudo kill -9 $(lsof -t -i:5005)
```

### Không tìm được bài hát

- Kiểm tra kết nối internet
- Kiểm tra MP3 API có hoạt động: `curl http://localhost:5555/health`
- Xem logs: `docker-compose logs -f mp3-api`
- Thử search trực tiếp trên MP3 API: `curl "http://localhost:5555/api/search?q=son+tung"`

### Cache không hoạt động

```bash
# Kiểm tra cache status
curl http://localhost:5005/health

# Response sẽ hiển thị:
# {
#   "status": "ok",
#   "cache_size": 6,
#   "cached_songs": ["ZWAEIUUB", "Z7I0OFAQ", ...]
# }

# Xem logs để thấy quá trình cache
docker-compose logs -f xiaozhi-adapter
```

### ESP32 không kết nối được

- Kiểm tra IP server đúng chưa (dùng `ip a` hoặc `ifconfig`)
- Kiểm tra firewall có block port 5005 không
- Thử truy cập từ máy khác trong mạng: `curl http://[SERVER_IP]:5005/health`
- Test trực tiếp: `curl "http://[SERVER_IP]:5005/stream_pcm?song=test"`

### Download audio bị lỗi

```bash
# Xem logs chi tiết
docker-compose logs -f xiaozhi-adapter

# Lỗi thường gặp:
# ❌ Failed to pre-download XXX: timeout
# → Tăng timeout trong xiaozhi-adapter.js

# ❌ Failed to pre-download XXX: 403 Forbidden
# → API Zing MP3 có thể đang block, chờ một lúc rồi thử lại
```

---

## 🎯 Tips & Tricks

### Tăng cache size

Sửa trong `adapter/xiaozhi-adapter.js`:

```javascript
const CACHE_MAX_SIZE = 20; // Tăng lên 20 bài
```

Sau đó rebuild:
```bash
docker-compose up -d --build
```

### Giảm số bài hát trả về

Nếu muốn chỉ trả về 1 bài thay vì 3:

```javascript
// Trong xiaozhi-adapter.js, dòng ~45
const topSongs = songs.slice(0, 1); // Đổi từ 3 thành 1
```

### Monitoring cache

```bash
# Script để monitor cache real-time
watch -n 5 'curl -s http://localhost:5005/health | jq'
```

---

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón! 

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

---

## 📝 License

Dự án này được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

---

## 🙏 Credits

- **MP3 API** by [@nvhung9](https://github.com/nvhung9/mp3-api) - API gốc lấy dữ liệu từ Zing MP3
- **Xiaozhi Music** - Thiết bị phát nhạc ESP32
- **Community Contributors** - Cảm ơn tất cả những người đóng góp

---

## 🔗 Links hữu ích

- [nvhung9/mp3-api](https://github.com/nvhung9/mp3-api) - Original MP3 API
- [Docker Documentation](https://docs.docker.com/)
- [Express.js Documentation](https://expressjs.com/)

---

## 📧 Liên hệ

Nếu có vấn đề hoặc câu hỏi đừng hỏi, vì mình nhờ AI làm cả nên ko rành ạ =))

---

<div align="center">

**⭐ Nếu thấy hữu ích, đừng quên cho project một star nhé! ⭐**

Made with ❤️ for Xiaozhi Music Community

</div>