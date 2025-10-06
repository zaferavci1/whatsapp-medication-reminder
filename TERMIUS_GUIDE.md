# 📱 TERMIUS İLE UZAKTAN YÖNETİM REHBERİ

## 🔌 **Bağlantı Kurma:**
```
Host: 134.122.90.157
User: root
Port: 22
```

## 🚀 **Her Zaman Çalıştırmanız Gereken İlk Komutlar:**
```bash
# 1. Proje klasörüne git
cd /root/hatirlatici

# 2. Python environment'ı aktifleştir
source twilio_env/bin/activate

# 3. Environment variables'ları temizle (cache sorununu önler)
unset TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN TWILIO_WHATSAPP_NUMBER RECIPIENT_WHATSAPP_NUMBER
```

## 📊 **Sistem Durumu Kontrolleri:**
```bash
# Hızlı durum (5 saniye)
cat system_status_current.txt

# Detaylı sistem raporu (30 saniye)
./system_health.sh

# Son mesajları görüntüle
./manage.sh logs

# İlaç programlarını listele
./manage.sh schedules
```

## 🧪 **Test İşlemleri (Günlük limit yoksa):**
```bash
# Genel test (limit uyarısı alırsanız normal)
./manage.sh test

# Belirli ilaç testleri
./manage.sh test-sabah
./manage.sh test-ogle  
./manage.sh test-aksam
```

## ⚠️ **Günlük Limit Kontrolü:**
```bash
# Bugün kaç mesaj gönderildi?
python -c "
import json
from datetime import datetime
today = datetime.now().strftime('%Y-%m-%d')
with open('message_log.json', 'r') as f:
    logs = json.load(f)
today_count = len([log for log in logs if log['timestamp'].startswith(today)])
print(f'Bugün: {today_count}/9 mesaj')
"
```

## 🔧 **Acil Durum Komutları:**
```bash
# Sistem durmuşsa
sudo systemctl restart cron
./manage.sh restart

# Sistemi tamamen yeniden kur
./manage.sh install

# Cron job'ları kontrol et
crontab -l
```

## 📅 **Yarın Test Senaryosu:**
```bash
# Yarın günlük limit sıfırlandıktan sonra:
cd /root/hatirlatici
source twilio_env/bin/activate
unset TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN
./manage.sh test

# Beklenen çıktı:
# ✅ Mesaj başarıyla gönderildi!
# 📧 Mesaj SID: SMxxxxx...
```

## 🎯 **Başarı Göstergeleri:**
- ✅ SSH bağlantısı kurulabiliyor
- ✅ Environment variables doğru yükleniyor  
- ✅ `system_status_current.txt` = "✅ Sistem çalışıyor"
- ✅ WhatsApp mesajları zamanında geliyor
- ⚠️ Test mesajları limit nedeniyle başarısız (normal)

## 📱 **WhatsApp Mesaj Formatları:**
Şu mesajlar gelmeye devam edecek:
- 🌅 "Günaydın canım annem! Diamicron 60mg..."
- 🍳 "Kahvaltıdan sonra Dropia-MET 15mg..."  
- 🍽️ "Öğle yemeğinden sonra ilaç zamanı..."
- 🌆 "Akşam yemeğinden sonra Dropia-MET 15mg..."
