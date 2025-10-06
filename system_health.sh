#!/bin/bash

# Sistem Sağlık İzleme ve Raporlama Scripti

REPORT_FILE="health_report_$(date +%Y%m%d_%H%M).txt"
TELEGRAM_LOG="system_status.log"

echo "🏥 HATIRLATİCİ SİSTEM SAĞLIK RAPORU" > $REPORT_FILE
echo "===========================================" >> $REPORT_FILE
echo "📅 Tarih: $(date)" >> $REPORT_FILE
echo "🖥️  Sunucu: $(hostname) ($(curl -s ifconfig.me))" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Sistem Durumu
echo "🔍 SİSTEM DURUMU:" >> $REPORT_FILE
echo "==================" >> $REPORT_FILE

# Cron Servis Durumu
if systemctl is-active --quiet cron; then
    echo "✅ Cron Servisi: ÇALIŞIYOR" >> $REPORT_FILE
else
    echo "❌ Cron Servisi: DURMUŞ!" >> $REPORT_FILE
fi

# Cron Job Sayısı
CRON_COUNT=$(crontab -l 2>/dev/null | grep -c "medication_reminder")
if [ "$CRON_COUNT" -gt 0 ]; then
    echo "✅ Zamanlanmış İlaçlar: $CRON_COUNT adet aktif" >> $REPORT_FILE
else
    echo "❌ Zamanlanmış İlaçlar: BULUNAMADI!" >> $REPORT_FILE
fi

# Python Environment
if [ -d "twilio_env" ]; then
    echo "✅ Python Environment: MEVCUT" >> $REPORT_FILE
else
    echo "❌ Python Environment: BULUNAMADI!" >> $REPORT_FILE
fi

# Konfigürasyon
if [ -f "medication_config.json" ]; then
    MEDICATION_COUNT=$(python3 -c "import json; print(len(json.load(open('medication_config.json'))['medication_schedules']))" 2>/dev/null || echo "0")
    echo "✅ İlaç Programları: $MEDICATION_COUNT adet tanımlı" >> $REPORT_FILE
else
    echo "❌ Konfigürasyon: BULUNAMADI!" >> $REPORT_FILE
fi

# .env Dosyası
if [ -f ".env" ]; then
    echo "✅ Twilio Ayarları: MEVCUT" >> $REPORT_FILE
else
    echo "❌ Twilio Ayarları: BULUNAMADI!" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE

# Son Mesajlar
echo "📱 SON MESAJ AKTİVİTESİ:" >> $REPORT_FILE
echo "========================" >> $REPORT_FILE

if [ -f "message_log.json" ]; then
    # Son 5 mesajı göster
    python3 -c "
import json
from datetime import datetime
try:
    with open('message_log.json', 'r', encoding='utf-8') as f:
        logs = json.load(f)
    
    if logs:
        print(f'📊 Toplam Gönderilen: {len(logs)} mesaj')
        print('📋 Son 5 Mesaj:')
        recent_logs = logs[-5:] if len(logs) >= 5 else logs
        
        for i, log in enumerate(reversed(recent_logs), 1):
            print(f'{i:2d}. {log[\"timestamp\"]} - {log[\"message_preview\"]}')
        
        # Son mesaj ne kadar önce gönderildi
        last_time = datetime.strptime(logs[-1]['timestamp'], '%Y-%m-%d %H:%M:%S')
        time_diff = datetime.now() - last_time
        hours_ago = time_diff.total_seconds() / 3600
        
        if hours_ago < 1:
            print(f'⏰ Son mesaj: {int(hours_ago * 60)} dakika önce')
        elif hours_ago < 24:
            print(f'⏰ Son mesaj: {int(hours_ago)} saat önce')  
        else:
            print(f'⏰ Son mesaj: {int(hours_ago / 24)} gün önce')
            
    else:
        print('❌ Henüz hiç mesaj gönderilmemiş')
        
except Exception as e:
    print(f'❌ Log okuma hatası: {e}')
" >> $REPORT_FILE
else
    echo "❌ Mesaj log dosyası bulunamadı" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE

# Bugünün Mesajları
echo "📅 BUGÜNÜN MESAJLARI:" >> $REPORT_FILE
echo "===================" >> $REPORT_FILE

if [ -f "message_log.json" ]; then
    TODAY=$(date +%Y-%m-%d)
    python3 -c "
import json
today = '$TODAY'
try:
    with open('message_log.json', 'r') as f:
        logs = json.load(f)
    
    today_messages = [log for log in logs if log['timestamp'].startswith(today)]
    
    if today_messages:
        print(f'✅ Bugün gönderilen: {len(today_messages)} mesaj')
        for msg in today_messages:
            time = msg['timestamp'].split(' ')[1]
            print(f'   {time} - {msg[\"message_preview\"]}')
    else:
        print('⚠️  Bugün henüz mesaj gönderilmemiş')
        
except Exception as e:
    print(f'❌ Günlük log kontrolü başarısız: {e}')
" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE

# Sistem Kaynakları
echo "💾 SİSTEM KAYNAKLARI:" >> $REPORT_FILE
echo "====================" >> $REPORT_FILE
echo "🖥️  CPU Kullanımı: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%" >> $REPORT_FILE
echo "💿 Disk Kullanımı: $(df -h . | tail -1 | awk '{print $5}')" >> $REPORT_FILE
echo "⚡ RAM Kullanımı: $(free -h | grep Mem | awk '{print $3"/"$2}')" >> $REPORT_FILE
echo "⏱️  Uptime: $(uptime -p)" >> $REPORT_FILE

echo "" >> $REPORT_FILE

# Sonraki İlaç Zamanları
echo "⏰ SONRAKİ İLAÇ ZAMANLARI:" >> $REPORT_FILE
echo "=========================" >> $REPORT_FILE
echo "🌅 10:15 - Diamicron 60mg (aç karnına)" >> $REPORT_FILE
echo "🍳 11:45 - Dropia-MET 15mg (tok karnına, sabah)" >> $REPORT_FILE  
echo "🍽️  14:00 - Linatin 5mg + Jaglif 10mg (tok karnına)" >> $REPORT_FILE
echo "🌆 20:00 - Dropia-MET 15mg (tok karnına, akşam)" >> $REPORT_FILE

echo "" >> $REPORT_FILE
echo "📞 UZAKTAN ERİŞİM:" >> $REPORT_FILE
echo "=================" >> $REPORT_FILE
echo "SSH: ssh root@$(curl -s ifconfig.me)" >> $REPORT_FILE
echo "Proje: cd /root/hatirlatici" >> $REPORT_FILE
echo "Test: ./manage.sh test" >> $REPORT_FILE

# Raporu ekranda da göster
cat $REPORT_FILE

# Log dosyasına da kaydet
echo "$(date): Health check completed - $REPORT_FILE created" >> $TELEGRAM_LOG

echo ""
echo "📄 Rapor dosyası: $REPORT_FILE"
echo "🔄 Bu scripti uzaktan çalıştırabilirsiniz:"
echo "   ssh root@$(curl -s ifconfig.me) 'cd /root/hatirlatici && ./system_health.sh'"
