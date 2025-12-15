# 📱 WhatsApp Payment Proof Processor

Aplikasi upload bukti pembayaran berbasis WhatsApp yang berjalan menggunakan **n8n** di Docker Desktop, dengan workflow otomatis dan AI untuk membaca serta memvalidasi bukti pembayaran.

## 🎯 Fitur Utama

- ✅ **Otomatis menerima** bukti pembayaran via WhatsApp
- 🤖 **AI OCR** untuk membaca data pembayaran (nama, nominal, tanggal, metode)
- ✔️ **Validasi otomatis** data pembayaran
- 💾 **Neon DB (PostgreSQL Cloud)** untuk storage yang reliable
- 📲 **Auto-reply** ke pengirim dengan status
- 🔒 **Keamanan** dengan rate limiting dan validasi file
- 🌐 **Bahasa Indonesia** untuk semua komunikasi

## 🏗️ Arsitektur Sistem

```
WhatsApp User
   ↓
WhatsApp Business API (Meta)
   ↓ (Webhook HTTPS)
n8n (Docker Container)
   ↓
AI Agent (OCR + LLM)
   ↓
Google Sheets / Database
   ↓
WhatsApp Auto Reply
```

## 📋 Prerequisites

### 1. Software Requirements
- **Docker Desktop** (Windows/Mac/Linux)
- **ngrok** atau **Cloudflare Tunnel** (untuk HTTPS webhook)
- **Git** (untuk clone repository)

### 2. API Keys & Accounts

#### WhatsApp Business API
1. Buat akun di [Meta for Developers](https://developers.facebook.com/)
2. Buat aplikasi baru → pilih "Business"
3. Tambahkan produk "WhatsApp"
4. Dapatkan:
   - `WHATSAPP_API_TOKEN`
   - `WHATSAPP_PHONE_NUMBER_ID`
   - `WHATSAPP_BUSINESS_ACCOUNT_ID`

#### OpenAI API
1. Daftar di [OpenAI Platform](https://platform.openai.com/)
2. Buat API key di [API Keys](https://platform.openai.com/api-keys)
3. Salin `OPENAI_API_KEY`

#### Google Sheets (Optional)
1. Buat project di [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Google Sheets API
3. Buat OAuth 2.0 credentials
4. Dapatkan `CLIENT_ID` dan `CLIENT_SECRET`

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone <repository-url>
cd wa-n8n-payment
```

### 2. Setup Environment Variables

```bash
# Copy template
cp .env.example .env

# Edit .env dengan text editor favorit Anda
notepad .env  # Windows
```

**Minimal configuration:**
```env
# n8n
N8N_BASIC_AUTH_PASSWORD=your-secure-password
N8N_ENCRYPTION_KEY=your-encryption-key-32-chars

# WhatsApp
WHATSAPP_API_TOKEN=your-token
WHATSAPP_PHONE_NUMBER_ID=your-phone-id
WHATSAPP_BUSINESS_ACCOUNT_ID=your-business-id

# OpenAI
OPENAI_API_KEY=sk-your-key
```

### 3. Generate Encryption Key

```bash
# Windows PowerShell
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | % {[char]$_})

# Linux/Mac
openssl rand -hex 32
```

### 4. Start n8n Container

```bash
docker-compose up -d
```

Cek logs:
```bash
docker-compose logs -f n8n
```

### 5. Access n8n Editor

Buka browser: `http://localhost:5678`

Login dengan:
- Username: `admin` (atau sesuai `.env`)
- Password: sesuai `N8N_BASIC_AUTH_PASSWORD`

### 6. Import Workflow

1. Di n8n editor, klik **"Workflows"** → **"Import from File"**
2. Pilih file `workflows/payment-processor.json`
3. Klik **"Import"**

### 7. Setup Credentials

#### WhatsApp API Auth
1. Klik **"Credentials"** → **"Add Credential"**
2. Pilih **"Header Auth"**
3. Name: `WhatsApp API Auth`
4. Header Name: `Authorization`
5. Header Value: `Bearer YOUR_WHATSAPP_API_TOKEN`

#### OpenAI API
1. Klik **"Credentials"** → **"Add Credential"**
2. Pilih **"OpenAI API"**
3. Name: `OpenAI API`
4. API Key: `YOUR_OPENAI_API_KEY`

#### Google Sheets OAuth2 (Optional)
1. Klik **"Credentials"** → **"Add Credential"**
2. Pilih **"Google Sheets OAuth2 API"**
3. Ikuti OAuth flow

### 8. Setup Public HTTPS URL

**Menggunakan ngrok:**

```bash
# Install ngrok
# Download dari https://ngrok.com/download

# Start tunnel
ngrok http 5678
```

Salin HTTPS URL (contoh: `https://abc123.ngrok.io`)

**Update .env:**
```env
WEBHOOK_URL=https://abc123.ngrok.io
```

Restart container:
```bash
docker-compose restart
```

### 9. Configure WhatsApp Webhook

1. Buka [Meta for Developers](https://developers.facebook.com/)
2. Pilih aplikasi Anda → WhatsApp → Configuration
3. Di **Webhook**, klik **"Edit"**
4. **Callback URL**: `https://your-ngrok-url.ngrok.io/webhook/whatsapp-webhook`
5. **Verify Token**: buat string random (simpan di `.env`)
6. Subscribe to: `messages`
7. Klik **"Verify and Save"**

### 10. Test Workflow

1. Kirim foto bukti transfer ke nomor WhatsApp Business Anda
2. Tunggu balasan otomatis
3. Cek Google Sheets atau database untuk data tersimpan

## 📊 Workflow Details

### Flow Diagram

```
1. WhatsApp Webhook Trigger
   ↓
2. Check Message Type (image/document?)
   ↓
3. Extract Message Data
   ↓
4. Get Media URL from WhatsApp API
   ↓
5. Download Media File
   ↓
6. Validate File (size, type)
   ↓
7. AI OCR Extraction (GPT-4 Vision)
   ↓
8. Validate Extracted Data
   ↓
9. [IF VALID] → Save to Google Sheets → Success Reply
   [IF INVALID] → Save to Failed Log → Error Reply
   ↓
10. Webhook Response (200 OK)
```

### AI Prompt

Workflow menggunakan prompt berikut untuk OCR:

```
Anda adalah asisten pembayaran yang ahli dalam membaca bukti transfer.

Analisis gambar bukti pembayaran ini dan ekstrak informasi berikut dalam format JSON:

{
  "nama_pengirim": "nama lengkap pengirim",
  "nominal": jumlah_dalam_angka,
  "tanggal_transaksi": "YYYY-MM-DD",
  "metode_pembayaran": "nama bank/metode",
  "nomor_referensi": "nomor referensi jika ada",
  "confidence": "high/medium/low"
}
```

### Validation Rules

- ✅ `nominal` > 0
- ✅ `tanggal_transaksi` tidak kosong
- ✅ `nama_pengirim` tidak kosong
- ✅ `confidence` bukan "low"
- ✅ File size ≤ 5MB
- ✅ File type: JPG, PNG, PDF

### Auto-Reply Messages

**✅ Success:**
```
✅ Bukti Pembayaran Diterima

Terima kasih, [Nama] 🙏

Bukti pembayaran Anda sudah kami terima dengan detail:

💰 Nominal: Rp 1.000.000
📅 Tanggal: 2025-12-15
🏦 Metode: BCA
👤 Pengirim: John Doe

📋 Status: Menunggu verifikasi
```

**❌ Error:**
```
❌ Bukti Pembayaran Tidak Dapat Dibaca

Mohon maaf, [Nama]

Bukti pembayaran yang Anda kirim tidak dapat kami proses karena:

1. Nominal tidak valid atau tidak terbaca
2. Kualitas gambar kurang jelas

📸 Saran:
• Pastikan foto jelas dan tidak blur
• Pastikan semua informasi terlihat
• Gunakan pencahayaan yang cukup
• Format: JPG, PNG, atau PDF (max 5MB)
```

## 🗄️ Data Storage

### Google Sheets Structure

**Sheet: "Pembayaran"**
| Timestamp | Nomor WhatsApp | Nama Kontak | Nama Pengirim | Nominal | Tanggal Transaksi | Metode Pembayaran | Nomor Referensi | Status | Confidence | Message ID |
|-----------|----------------|-------------|---------------|---------|-------------------|-------------------|-----------------|--------|------------|------------|

**Sheet: "Gagal Validasi"**
| Timestamp | Nomor WhatsApp | Nama Kontak | Errors | Message ID |
|-----------|----------------|-------------|--------|------------|

### Alternative: PostgreSQL

Uncomment PostgreSQL service di `docker-compose.yml`:

```yaml
postgres:
  image: postgres:15-alpine
  # ... (sudah ada di file)
```

Update `.env`:
```env
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=your-password
```

## 🔐 Security Best Practices

### 1. Environment Variables
- ❌ **JANGAN** commit `.env` ke Git
- ✅ Gunakan `.env.example` sebagai template
- ✅ Simpan credentials di n8n Credentials Manager

### 2. Webhook Security
- ✅ Gunakan HTTPS (wajib untuk WhatsApp)
- ✅ Validasi webhook verify token
- ✅ Rate limiting per user

### 3. File Validation
- ✅ Max file size: 5MB
- ✅ Allowed MIME types: `image/jpeg`, `image/png`, `application/pdf`
- ✅ Scan untuk malware (optional)

### 4. Data Privacy
- ✅ Nomor WhatsApp sebagai User ID
- ✅ Tidak menyimpan data sensitif tambahan
- ✅ Enkripsi data di database (production)

## 🐛 Troubleshooting

### Container tidak start
```bash
# Cek logs
docker-compose logs n8n

# Restart container
docker-compose restart

# Rebuild jika perlu
docker-compose down
docker-compose up -d --build
```

### Webhook tidak menerima pesan
1. ✅ Cek ngrok masih running
2. ✅ Cek URL di Meta Developer Console benar
3. ✅ Cek verify token cocok
4. ✅ Cek subscription "messages" aktif

### AI tidak bisa membaca gambar
1. ✅ Cek `OPENAI_API_KEY` valid
2. ✅ Cek model support vision (`gpt-4o`, `gpt-4o-mini`)
3. ✅ Cek quota OpenAI
4. ✅ Cek kualitas gambar

### Data tidak tersimpan ke Google Sheets
1. ✅ Cek OAuth credentials valid
2. ✅ Cek `GOOGLE_SHEETS_SPREADSHEET_ID` benar
3. ✅ Cek sheet name "Pembayaran" ada
4. ✅ Cek kolom header sesuai

## 📈 Production Deployment

### 1. Use PostgreSQL
```yaml
# Uncomment di docker-compose.yml
postgres:
  image: postgres:15-alpine
```

### 2. Use Reverse Proxy
```yaml
# nginx.conf
server {
    listen 443 ssl;
    server_name n8n.yourdomain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 3. Environment Variables
```env
N8N_PROTOCOL=https
N8N_HOST=n8n.yourdomain.com
WEBHOOK_URL=https://n8n.yourdomain.com
NODE_ENV=production
```

### 4. Backup Strategy
```bash
# Backup n8n data
docker run --rm \
  -v wa-n8n-payment_n8n_data:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/n8n-backup-$(date +%Y%m%d).tar.gz /data

# Backup PostgreSQL
docker exec n8n-postgres pg_dump -U n8n n8n > backup/db-$(date +%Y%m%d).sql
```

## 📚 Resources

- [n8n Documentation](https://docs.n8n.io/)
- [WhatsApp Business API](https://developers.facebook.com/docs/whatsapp)
- [OpenAI API](https://platform.openai.com/docs)
- [Docker Documentation](https://docs.docker.com/)

## 🤝 Support

Jika ada pertanyaan atau issue:
1. Cek [Troubleshooting](#-troubleshooting)
2. Baca [n8n Community](https://community.n8n.io/)
3. Buka issue di repository ini

## 📄 License

MIT License - silakan gunakan untuk project komersial atau personal.

---

**Built with ❤️ using n8n, WhatsApp Business API, and OpenAI**
