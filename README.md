# 💊 Anne İçin Akıllı İlaç Hatırlatıcı Sistemi - Komple Yönetim Rehberi

## 📋 **SİSTEM HAKKINDA**

Bu sistem, annenizin şeker hastalığı ilaçlarını düzenli almasını sağlamak için geliştirilmiş tamamen otomatik bir WhatsApp hatırlatma sistemidir. Gerçek ilaç isimleri, dozları ve alma zamanları ile özelleştirilmiştir.

### **🏥 İlaç Programı:**
1. **Diamicron 60mg** - Aç karnına (10:15)
2. **Dropia-MET 15mg** - Tok karnına, sabah (11:45)
3. **Linatin 5mg + Jaglif 10mg** - Tok karnına, öğle (14:00)
4. **Dropia-MET 15mg** - Tok karnına, akşam (20:00)

### **⏰ Günlük Rutin:**
- 🛏️ **10:00** - Uyanma
- 🍳 **11:00** - Kahvaltı
- 🍽️ **13:30** - Öğle yemeği
- 🌆 **19:30** - Akşam yemeği

---

## 🎯 **SİSTEM ÖZELLİKLERİ**

### ✅ **Tam Otomatik Çalışma:**
- 4 farklı zamanda otomatik mesaj gönderimi
- Sunucu yeniden başlatılsa bile çalışmaya devam eder
- Hiçbir müdahale gerektirmez (7/24 aktif)
- Cron job'lar ile zamanlanmış görevler

### ✅ **Kişiselleştirilmiş Mesajlar:**
- Her ilaç için özel mesaj içeriği
- Aç/tok karın uyarıları
- Dozaj ve zaman bilgileri
- Sevgi dolu, samimi ifadeler
- Türkçe emoji ve özel karakterler

### ✅ **Güvenlik ve İzleme:**
- Twilio credentials güvenli şekilde saklanıyor
- Tüm gönderilen mesajlar log'lanıyor
- Mesaj başarı/hata durumları takip ediliyor
- Sistem sağlığı sürekli izleniyor

### ✅ **Kolay Yönetim:**
- Tek komutla tüm sistemi yönetebilirsiniz
- Detaylı yardım menüleri
- Test ve debug araçları
- Otomatik yedekleme sistemi

---

## 🛠️ **KOMPLE YÖNETİM REHBERİ**

### **1. 📊 SİSTEM DURUMU VE İZLEME**

#### **Sistem Durumunu Kontrol Etme:**
```bash
./manage.sh status
```
**Ne görürsünüz:**
- ✅/❌ Cron servisi durumu
- ✅/❌ Zamanlanmış görevlerin sayısı
- ✅/❌ Python environment durumu
- ✅/❌ Konfigürasyon dosyası varlığı
- ✅/❌ Twilio credentials durumu
- 📅 Bir sonraki hatırlatma zamanları
- 📱 Son gönderilen mesaj tarihi

#### **İlaç Programlarını Görüntüleme:**
```bash
./manage.sh schedules
```
**Ne görürsünüz:**
- Tüm ilaç programları listesi
- Her program için saat bilgisi
- Aktif/devre dışı durumu
- Mesaj önizlemesi
- Alıcı bilgileri

#### **Mesaj Loglarını İnceleme:**
```bash
./manage.sh logs
```
**Ne görürsünüz:**
- Son 10 gönderilen mesaj
- Gönderim tarihi ve saati
- Twilio mesaj SID'leri
- Mesaj içeriği önizlemesi
- Alıcı telefon numarası

### **2. 🧪 TEST VE DEBUG İŞLEMLERİ**

#### **Genel Test Mesajı:**
```bash
./manage.sh test
```
Bu komut basit bir test mesajı gönderir.

#### **Belirli İlaç Testleri:**
```bash
# Temel testler (kolay hatırlanabilir)
./manage.sh test-sabah      # Diamicron 60mg testi
./manage.sh test-ogle       # Öğle ilaçları testi  
./manage.sh test-aksam      # Dropia-MET akşam testi

# Detaylı testler (spesifik ilaçlar)
./manage.sh test-diamicron       # Diamicron 60mg
./manage.sh test-dropia-sabah    # Dropia-MET sabah dozu
./manage.sh test-dropia-aksam    # Dropia-MET akşam dozu
./manage.sh test-ogle-ilaclar    # Linatin + Jaglif
```

#### **Manuel İlaç Gönderimi:**
```bash
# Python scripti ile doğrudan gönderim
source twilio_env/bin/activate
python medication_reminder.py                    # Mevcut saate göre otomatik
python medication_reminder.py test               # Test mesajı
python medication_reminder.py sabah              # Diamicron
python medication_reminder.py öğle               # Öğle ilaçları
python medication_reminder.py akşam              # Dropia-MET akşam
python medication_reminder.py diamicron          # Diamicron (alternatif)
python medication_reminder.py dropia-sabah       # Dropia-MET sabah
python medication_reminder.py dropia-aksam       # Dropia-MET akşam
```

### **3. ⚙️ KONFIGÜRASYON YÖNETİMİ**

#### **İlaç Zamanları ve Mesajları Düzenleme:**
```bash
./manage.sh config
```
Bu komut `medication_config.json` dosyasını nano editörü ile açar.

**Düzenleyebileceğiniz alanlar:**
```json
{
  "medication_schedules": [
    {
      "name": "Diamicron 60mg (Aç Karnına)",
      "time": "10:15",              // ← Saati değiştirebilirsiniz
      "message": "...",             // ← Mesajı özelleştirebilirsiniz
      "medication": "Diamicron 60mg",
      "instructions": "Aç karnına, kahvaltıdan önce",
      "enabled": true               // ← true/false ile aktif/pasif
    }
  ],
  "recipient_info": {
    "name": "Anne",                 // ← İsmi değiştirebilirsiniz
    "phone": "+905xxxxxxxxx"        // ← Telefon numarasını değiştirebilirsiniz
  },
  "daily_routine": {
    "wake_up": "10:00",            // ← Uyanma saati
    "breakfast": "11:00",          // ← Kahvaltı saati
    "lunch": "13:30",              // ← Öğle yemeği saati
    "dinner": "19:30"              // ← Akşam yemeği saati
  }
}
```

#### **Konfigürasyon Yedekleme:**
```bash
./manage.sh backup
```
Bu komut mevcut ayarları tarih-saat damgalı bir yedek dosyasına kaydeder.

### **4. 🔧 SİSTEM KONTROLÜ**

#### **Hatırlatmaları Etkinleştirme/Devre Dışı Bırakma:**
```bash
./manage.sh enable       # Hatırlatmaları etkinleştir
./manage.sh disable      # Hatırlatmaları geçici olarak durdur
```

#### **Sistemleri Yeniden Başlatma:**
```bash
./manage.sh restart      # Cron servisini yeniden başlat
./manage.sh install      # Tüm sistemi yeniden kur
```

#### **Manuel Cron İşlemleri:**
```bash
crontab -l              # Aktif cron job'ları görüntüle
crontab -e              # Cron job'ları manuel düzenle
systemctl status cron   # Cron servis durumunu kontrol et
systemctl start cron    # Cron servisini başlat
systemctl stop cron     # Cron servisini durdur
```

### **5. 📈 RAPORLAMA VE İSTATİSTİKLER**

#### **Günlük Rapor:**
```bash
./manage.sh report
```
**İçerik:**
- Sistem durumu özeti
- Son mesaj logları
- Aktif programlar
- Genel sistem sağlığı

#### **İstatistikler:**
```bash
./manage.sh stats
```
**İçerik:**
- Toplam gönderilen mesaj sayısı
- Bu ayın mesaj sayısı
- Son 7 günün mesaj sayısı
- İlk ve son mesaj tarihleri

---

## 📁 **DOSYA YAPISI VE AÇIKLAMALARI**

```
/root/hatirlatici/
├── 🔧 Çalıştırılabilir Dosyalar
│   ├── medication_reminder.py      # Ana Python scripti
│   ├── manage.sh                   # Sistem yönetim scripti
│   ├── setup_cron_jobs.sh          # Cron kurulum scripti
│   └── update_medication_cron.sh   # Cron güncelleme scripti
│
├── ⚙️ Konfigürasyon Dosyaları
│   ├── medication_config.json      # İlaç programları ve mesajlar
│   ├── .env                        # Twilio credentials (GİZLİ)
│   └── .gitignore                  # Git ignore kuralları
│
├── 📊 Log ve Veri Dosyaları
│   ├── message_log.json            # Gönderilen mesaj logları
│   ├── cron.log                    # Cron çalışma logları
│   └── medication_config_backup_*  # Otomatik yedek dosyaları
│
├── 🐍 Python Environment
│   └── twilio_env/                 # Virtual environment
│       ├── bin/                    # Python çalıştırılabilir dosyalar
│       ├── lib/                    # Yüklü Python paketleri
│       └── ...
│
└── 📚 Dokümantasyon
    ├── README.md                   # Bu dosya
    ├── MEDICATION_SCHEDULE.md      # Detaylı ilaç programı
    └── twilio_whatsapp_setup.md    # Twilio kurulum rehberi
```

### **Dosya Açıklamaları:**

#### **🔧 medication_reminder.py**
- Ana Python scripti
- Mesaj gönderme işlevini yönetir
- Konfigürasyon dosyasını okur
- Log dosyasına kayıt yapar
- Komut satırı argümanlarını işler

#### **🔧 manage.sh**
- Sistem yönetimi için ana script
- Tüm sistem operasyonlarını kolaylaştırır
- Kullanıcı dostu arayüz sunar
- Hata kontrolü ve yardım menüleri içerir

#### **⚙️ medication_config.json**
- Tüm ilaç programları bu dosyada tanımlı
- Mesaj içerikleri ve zamanlamaları
- Alıcı bilgileri ve günlük rutin
- JSON formatında, okunabilir yapıda

#### **🔐 .env**
- Twilio Account SID, Auth Token
- WhatsApp sandbox numarası
- Alıcı telefon numarası
- Bu dosya asla paylaşılmamalı!

---

## 🔐 **GÜVENLİK YÖNETİMİ**

### **Twilio Credentials Güvenliği:**
```bash
# .env dosyası izinlerini kontrol et
ls -la .env
# Çıktı: -rw------- 1 root root ... .env (sadece owner okuyabilir)

# Eğer izinler yanlışsa düzelt
chmod 600 .env
```

### **Yedekleme Güvenliği:**
```bash
# Hassas dosyaları yedekle
cp .env .env.backup
cp medication_config.json medication_config.backup

# Git'e hassas dosyaların gitmemesini kontrol et
cat .gitignore
# İçinde olmalı: .env, *.backup, twilio_env/
```

### **Log Güvenliği:**
```bash
# Log dosyalarının boyutunu kontrol et
ls -lh message_log.json

# Büyükse temizle (sadece son 100 kayıt tutulur otomatik)
# Manuel temizleme:
echo "[]" > message_log.json
```

---

## 🆘 **SORUN GİDERME REHBERİ**

### **Problem 1: Mesaj Gönderilmiyor**

#### **Kontrol Adımları:**
```bash
# 1. Sistem durumunu kontrol et
./manage.sh status

# 2. Test mesajı gönder
./manage.sh test

# 3. Cron job'ları kontrol et
crontab -l

# 4. Cron servisini kontrol et
systemctl status cron

# 5. Python environment'ı kontrol et
source twilio_env/bin/activate
python --version
pip list | grep twilio
```

#### **Olası Çözümler:**
```bash
# Cron servisini yeniden başlat
sudo systemctl restart cron

# Sistemi yeniden kur
./setup_cron_jobs.sh

# Twilio paketini yeniden yükle
source twilio_env/bin/activate
pip install --upgrade twilio
```

### **Problem 2: Twilio Authentication Hatası**

#### **Hata Mesajları:**
- "Authentication Error - invalid username"
- "HTTP 401 error"
- "Unable to create record"

#### **Çözüm Adımları:**
```bash
# 1. .env dosyasını kontrol et
cat .env

# 2. Twilio Console'dan yeni credentials al
# https://console.twilio.com/

# 3. .env dosyasını güncelle
nano .env

# 4. Test mesajı gönder
./manage.sh test
```

### **Problem 3: WhatsApp Sandbox Hatası**

#### **Hata Mesajları:**
- "Twilio could not find a Channel"
- "From address not found"

#### **Çözüm:**
```bash
# 1. Twilio WhatsApp Sandbox'ı kontrol et
# https://console.twilio.com/us1/develop/sms/try-it-out/whatsapp-learn

# 2. Sandbox numarasını .env'de güncelle
nano .env
# TWILIO_WHATSAPP_NUMBER="+14155238886" (örnek)

# 3. Test mesajı gönder
./manage.sh test
```

### **Problem 4: Sistem Çok Yavaş**

#### **Optimizasyon:**
```bash
# 1. Log dosyalarını temizle
echo "[]" > message_log.json

# 2. Eski yedek dosyaları sil
rm medication_config_backup_*.json

# 3. Cron log'larını temizle
> cron.log

# 4. Virtual environment'ı yeniden oluştur
rm -rf twilio_env
python3 -m venv twilio_env
source twilio_env/bin/activate
pip install twilio python-dotenv
```

### **Problem 5: Konfigürasyon Bozuldu**

#### **Kurtarma:**
```bash
# 1. Yedek dosyasından kurtar
cp medication_config_backup_*.json medication_config.json

# 2. Eğer yedek yoksa, varsayılan oluştur
./manage.sh install

# 3. Konfigürasyonu yeniden düzenle
./manage.sh config
```

---

## 🔄 **ADVANCED YÖNETİM**

### **Cron Job'ları Manuel Düzenleme:**
```bash
# Cron job'ları düzenle
crontab -e

# Mevcut format:
# Dakika Saat Gün Ay HaftaGünü Komut
# 15 10 * * * cd /root/hatirlatici && source twilio_env/bin/activate && python medication_reminder.py

# Örnek değişiklikler:
# Sabah 09:30'a çekmek için: 30 9 * * *
# Sadece hafta içi çalışması için: 15 10 * * 1-5
# Ayın ilk 15 günü için: 15 10 1-15 * *
```

### **Mesaj İçeriklerini Programatik Değiştirme:**
```bash
# Python ile konfigürasyon düzenleme
source twilio_env/bin/activate
python3 -c "
import json
with open('medication_config.json', 'r', encoding='utf-8') as f:
    config = json.load(f)

# Mesaj değiştirme örneği
config['medication_schedules'][0]['message'] = 'Yeni mesaj içeriği!'

with open('medication_config.json', 'w', encoding='utf-8') as f:
    json.dump(config, f, ensure_ascii=False, indent=2)
print('Konfigürasyon güncellendi!')
"
```

### **Toplu Test İşlemleri:**
```bash
# Tüm ilaçları sırayla test et
for test_type in sabah ogle aksam; do
    echo "Testing $test_type..."
    ./manage.sh test-$test_type
    sleep 5  # 5 saniye bekle
done
```

### **Sistem İzleme Scripti:**
```bash
# Sürekli izleme scripti oluştur
cat > monitor.sh << 'EOF'
#!/bin/bash
while true; do
    clear
    echo "=== HATIRLACITI SİSTEM İZLEME ==="
    date
    echo ""
    ./manage.sh status
    echo ""
    echo "Son 3 mesaj:"
    tail -10 message_log.json | head -3
    echo ""
    echo "Bir sonraki kontrol 30 saniye sonra..."
    sleep 30
done
EOF

chmod +x monitor.sh
# Çalıştır: ./monitor.sh
```

---

## 📱 **MESAJ ÖRNEKLERİ VE ÖZELLEŞTİRME**

### **Mevcut Mesaj Formatları:**

#### **🌅 Diamicron (10:15 - Aç Karnına):**
```
🌅 Günaydın canım annem! Diamicron 60mg ilacını alma zamanı geldi. 
Bu ilacı aç karnına, kahvaltıdan önce alman gerekiyor. 
Şimdi al, sonra 30 dakika sonra kahvaltını yapabilirsin. 
Seni çok seviyorum! 💊❤️
```

#### **🍳 Dropia-MET Sabah (11:45 - Tok Karnına):**
```
🍳 Kahvaltıdan sonra Dropia-MET 15mg ilacını alma zamanı canım annem! 
Bu ilacı tok karnına alman gerekiyor. Kahvaltını yaptığın için şimdi tam zamanı. 
Unutma, akşam da bir tane daha alacaksın. 💊🥰
```

#### **🍽️ Öğle İlaçları (14:00 - Tok Karnına):**
```
🍽️ Öğle yemeğinden sonra ilaç zamanı canım annem! 
Şimdi 2 ilacını alman gerekiyor:

💊 Linatin 5mg
💊 Jaglif 10mg

İkisini de öğle yemeğinden sonra tok karnına al. 
Sağlığın için çok önemli! Seni seviyorum 💕
```

#### **🌆 Dropia-MET Akşam (20:00 - Tok Karnına):**
```
🌆 Akşam yemeğinden sonra Dropia-MET 15mg zamanı canım annem! 
Bu ilacın ikinci dozunu tok karnına alman gerekiyor. 
Akşam yemeğini yediğin için şimdi tam zamanı. 
Bu gece güzel rüyalar görmen için sağlığın önemli! 💊🌙❤️
```

### **Mesaj Özelleştirme İpuçları:**

#### **Kullanabileceğiniz Emoji'ler:**
- 💊 🏥 ⏰ 🌅 🌞 🌆 🌙
- ❤️ 💕 🥰 😘 🤗 👩‍⚕️
- 🍳 🍽️ 🥛 🍎 🥗 🍞
- ✅ ⚠️ 📱 💬 🔔 📞

#### **Kişisel Dokunuşlar:**
- Anne için özel lakaplar: "canım annem", "tatlım", "sevgilim"
- Motivasyon cümleleri: "sağlığın çok önemli", "kendine iyi bak"
- Hatırlatmalar: "unutma", "tam zamanı", "çok önemli"
- Duygusal bağ: "seni seviyorum", "seni çok seviyorum", "kendine iyi bak"

---

## 🚀 **SİSTEM OPTİMİZASYONU**

### **Performans İyileştirmeleri:**

#### **1. Log Dosyası Yönetimi:**
```bash
# Otomatik log temizleme scripti
cat > cleanup_logs.sh << 'EOF'
#!/bin/bash
# 100'den fazla log varsa eski olanları sil
python3 -c "
import json
try:
    with open('message_log.json', 'r') as f:
        logs = json.load(f)
    if len(logs) > 100:
        logs = logs[-100:]  # Son 100'ü tut
        with open('message_log.json', 'w') as f:
            json.dump(logs, f, indent=2)
        print(f'Log temizlendi, {len(logs)} kayıt kaldı')
except:
    print('Log temizleme başarısız')
"
EOF

chmod +x cleanup_logs.sh

# Cron'a ekle (her gün gece yarısı çalışsın)
# crontab -e
# 0 0 * * * cd /root/hatirlatici && ./cleanup_logs.sh
```

#### **2. Otomatik Yedekleme:**
```bash
# Haftalık otomatik yedekleme scripti
cat > weekly_backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="backups/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

cp medication_config.json $BACKUP_DIR/
cp .env $BACKUP_DIR/
cp message_log.json $BACKUP_DIR/
crontab -l > $BACKUP_DIR/crontab_backup.txt

echo "Yedekleme tamamlandı: $BACKUP_DIR"
EOF

chmod +x weekly_backup.sh

# Cron'a ekle (her pazartesi sabah 06:00)
# 0 6 * * 1 cd /root/hatirlatici && ./weekly_backup.sh
```

### **İzleme ve Alertler:**

#### **Sistem Sağlık Kontrolü:**
```bash
cat > health_check.sh << 'EOF'
#!/bin/bash
ERROR_LOG="health_errors.log"

# Cron servisi çalışıyor mu?
if ! systemctl is-active --quiet cron; then
    echo "$(date): HATA - Cron servisi çalışmıyor!" >> $ERROR_LOG
fi

# Python environment mevcut mu?
if [ ! -d "twilio_env" ]; then
    echo "$(date): HATA - Python environment bulunamadı!" >> $ERROR_LOG
fi

# Konfigürasyon dosyası mevcut mu?
if [ ! -f "medication_config.json" ]; then
    echo "$(date): HATA - Konfigürasyon dosyası bulunamadı!" >> $ERROR_LOG
fi

# .env dosyası mevcut mu?
if [ ! -f ".env" ]; then
    echo "$(date): HATA - .env dosyası bulunamadı!" >> $ERROR_LOG
fi

# Son 24 saatte mesaj gönderildi mi?
LAST_MESSAGE=$(python3 -c "
import json
from datetime import datetime, timedelta
try:
    with open('message_log.json', 'r') as f:
        logs = json.load(f)
    if logs:
        last_time = datetime.strptime(logs[-1]['timestamp'], '%Y-%m-%d %H:%M:%S')
        if datetime.now() - last_time > timedelta(hours=24):
            print('Son 24 saatte mesaj gönderilmemiş!')
except:
    print('Log kontrol edilemedi')
")

if [ -n "$LAST_MESSAGE" ]; then
    echo "$(date): UYARI - $LAST_MESSAGE" >> $ERROR_LOG
fi

# Hata varsa göster
if [ -f "$ERROR_LOG" ] && [ -s "$ERROR_LOG" ]; then
    echo "=== SISTEM SAĞLIK UYARILARI ==="
    tail -10 $ERROR_LOG
fi
EOF

chmod +x health_check.sh

# Günde 2 kez çalıştır
# crontab -e
# 0 9,21 * * * cd /root/hatirlatici && ./health_check.sh
```

---

## 📞 **DESTEK VE İLETİŞİM**

### **Sık Sorulan Sorular:**

#### **S: Sistem çalışıyor mu nasıl anlayabilirim?**
C: `./manage.sh status` komutu ile sistem durumunu kontrol edin. Ayrıca `./manage.sh logs` ile son gönderilen mesajları görebilirsiniz.

#### **S: Mesaj saatlerini nasıl değiştiririm?**
C: `./manage.sh config` komutu ile konfigürasyon dosyasını açın ve `time` alanlarını değiştirin. Değişiklik sonrası sistem otomatik güncellenecektir.

#### **S: Yeni bir ilaç eklemek istiyorum?**
C: `./manage.sh config` ile konfigürasyon dosyasını açın ve `medication_schedules` listesine yeni bir program ekleyin. Sonra `./update_medication_cron.sh` çalıştırın.

#### **S: Sistem durmuş, nasıl yeniden başlatırım?**
C: `./manage.sh restart` komutu ile sistem servislerini yeniden başlatın. Tam kurulum için `./manage.sh install` kullanın.

#### **S: WhatsApp mesajları gelmiyor?**
C: Önce `./manage.sh test` ile test mesajı gönderin. Hata alırsanız Twilio Console'dan credentials'ları kontrol edip `.env` dosyasını güncelleyin.

### **Acil Durum Komutları:**
```bash
# Sistem tamamen çöktü
sudo systemctl restart cron
./manage.sh install
./manage.sh test

# Konfigürasyon bozuldu
cp medication_config_backup_*.json medication_config.json
./manage.sh config

# Python environment bozuldu
rm -rf twilio_env
python3 -m venv twilio_env
source twilio_env/bin/activate
pip install twilio python-dotenv

# Tüm sistemi sıfırla
./setup_cron_jobs.sh
```

---

## 📊 **ÖZET: SİSTEM YÖNETİM CHEAT SHEET**

### **Günlük Kullanım:**
```bash
./manage.sh status    # Durum kontrol
./manage.sh test      # Hızlı test
./manage.sh logs      # Mesaj geçmişi
```

### **Haftalık Bakım:**
```bash
./manage.sh report    # Detaylı rapor
./manage.sh backup    # Ayarları yedekle
./manage.sh stats     # İstatistikleri gör
```

### **Acil Durum:**
```bash
./manage.sh restart   # Servisleri yeniden başlat
./manage.sh install   # Sistemi yeniden kur
crontab -l           # Cron job'ları kontrol et
```

### **Özelleştirme:**
```bash
./manage.sh config    # Ayarları düzenle
nano .env            # Twilio bilgilerini düzenle
```

---

**🎉 Bu sistemle annenizin ilaç alımını tamamen otomatikleştirmiş oldunuz!**

**Son Güncelleme:** 2025-10-04  
**Sistem Durumu:** ✅ Aktif ve Tam Operasyonel  
**İlaç Programı:** ✅ 4 Farklı Zamanda Otomatik Hatırlatma  
**Güvenlik:** ✅ Tam Güvenli ve Korumalı  
**Yönetim:** ✅ Tek Komutla Kontrol