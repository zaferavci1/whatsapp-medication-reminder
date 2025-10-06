#!/bin/bash

# Hatırlatıcı Cron Job Kurulum Scripti
# Bu script otomatik hatırlatma mesajları için cron job'ları kurar

SCRIPT_DIR="/root/hatirlatici"
PYTHON_ENV="$SCRIPT_DIR/twilio_env/bin/python"
MEDICATION_SCRIPT="$SCRIPT_DIR/medication_reminder.py"

echo "🔧 Hatırlatıcı Cron Job Kurulumu Başlıyor..."
echo "📂 Çalışma dizini: $SCRIPT_DIR"

# Virtual environment ve script'in varlığını kontrol et
if [ ! -f "$PYTHON_ENV" ]; then
    echo "❌ Python virtual environment bulunamadı: $PYTHON_ENV"
    exit 1
fi

if [ ! -f "$MEDICATION_SCRIPT" ]; then
    echo "❌ Medication script bulunamadı: $MEDICATION_SCRIPT"
    exit 1
fi

# Cron job wrapper script oluştur
cat > "$SCRIPT_DIR/run_medication_reminder.sh" << 'EOF'
#!/bin/bash

# Hatırlatıcı Cron Job Wrapper Script
# Bu script cron job'ları için gerekli environment'ı ayarlar

cd /root/hatirlatici
source twilio_env/bin/activate
python medication_reminder.py

# Log dosyasına sonucu kaydet
echo "$(date): Medication reminder executed" >> /root/hatirlatici/cron.log
EOF

chmod +x "$SCRIPT_DIR/run_medication_reminder.sh"

# Mevcut cron job'ları yedekle
echo "💾 Mevcut cron job'ları yedekleniyor..."
crontab -l > "$SCRIPT_DIR/crontab_backup_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null || echo "Mevcut cron job bulunamadı"

# Yeni cron job'ları oluştur
echo "📅 Yeni cron job'ları oluşturuluyor..."

# Temporary cron file oluştur
TEMP_CRON=$(mktemp)

# Mevcut cron job'ları koru (varsa)
crontab -l 2>/dev/null | grep -v "medication_reminder\|hatirlatici" > "$TEMP_CRON"

# Yeni cron job'ları ekle
cat >> "$TEMP_CRON" << EOF

# === ANNEM İÇİN ŞEKER İLACI HATIRLATICILARI ===
# Her gün sabah 08:00'da sabah ilacı hatırlatması
0 8 * * * cd /root/hatirlatici && source twilio_env/bin/activate && python medication_reminder.py >/dev/null 2>&1

# Her gün öğle 12:30'da öğle ilacı hatırlatması  
30 12 * * * cd /root/hatirlatici && source twilio_env/bin/activate && python medication_reminder.py >/dev/null 2>&1

# Her gün akşam 18:00'da akşam ilacı hatırlatması
0 18 * * * cd /root/hatirlatici && source twilio_env/bin/activate && python medication_reminder.py >/dev/null 2>&1

EOF

# Cron job'ları yükle
crontab "$TEMP_CRON"
rm "$TEMP_CRON"

echo "✅ Cron job'ları başarıyla kuruldu!"
echo ""
echo "📋 Kurulmuş Hatırlatmalar:"
echo "   🌅 Sabah 08:00 - Sabah ilacı"
echo "   🌞 Öğle 12:30 - Öğle ilacı"  
echo "   🌆 Akşam 18:00 - Akşam ilacı"
echo ""
echo "📝 Cron servisi kontrolü:"
systemctl is-active cron >/dev/null 2>&1 && echo "   ✅ Cron servisi çalışıyor" || echo "   ⚠️ Cron servisi çalışmıyor!"

echo ""
echo "🎛️ Yönetim Komutları:"
echo "   crontab -l           # Aktif cron job'ları görüntüle"
echo "   crontab -r           # Tüm cron job'ları sil"
echo "   systemctl start cron # Cron servisini başlat"
echo "   tail -f /root/hatirlatici/cron.log # Logları izle"

echo ""
echo "🧪 Test komutu:"
echo "   cd /root/hatirlatici && source twilio_env/bin/activate && python medication_reminder.py test"

echo ""
echo "🎉 Kurulum tamamlandı! Artık otomatik hatırlatmalar çalışacak."
