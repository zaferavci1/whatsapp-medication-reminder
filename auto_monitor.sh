#!/bin/bash

# Otomatik Sistem İzleme ve Uyarı Scripti

LOG_FILE="auto_monitor.log"
ALERT_FILE="system_alerts.txt"
HEALTH_DIR="health_reports"

# Klasör oluştur
mkdir -p $HEALTH_DIR

echo "🤖 Otomatik sistem izleme başlatıldı: $(date)" >> $LOG_FILE

# Sistem sağlık kontrolü
check_system_health() {
    local timestamp=$(date +"%Y%m%d_%H%M")
    local report_file="$HEALTH_DIR/auto_health_$timestamp.txt"
    
    echo "🏥 OTOMATİK SAĞLIK RAPORU - $(date)" > $report_file
    echo "================================================" >> $report_file
    
    # Kritik servisleri kontrol et
    local errors=0
    
    # Cron servisi
    if ! systemctl is-active --quiet cron; then
        echo "❌ CRITICAL: Cron servisi çalışmıyor!" >> $report_file
        echo "$(date): KRITIK - Cron servisi durmuş!" >> $ALERT_FILE
        errors=$((errors + 1))
    else
        echo "✅ Cron servisi: Çalışıyor" >> $report_file
    fi
    
    # Cron job'lar
    local cron_count=$(crontab -l 2>/dev/null | grep -c "medication_reminder")
    if [ "$cron_count" -eq 0 ]; then
        echo "❌ CRITICAL: Hiç ilaç zamanlaması bulunamadı!" >> $report_file
        echo "$(date): KRITIK - Cron job'ları bulunamadı!" >> $ALERT_FILE
        errors=$((errors + 1))
    else
        echo "✅ İlaç zamanlamaları: $cron_count adet aktif" >> $report_file
    fi
    
    # Python environment
    if [ ! -d "twilio_env" ]; then
        echo "❌ CRITICAL: Python environment bulunamadı!" >> $report_file
        echo "$(date): KRITIK - Python environment eksik!" >> $ALERT_FILE
        errors=$((errors + 1))
    else
        echo "✅ Python environment: Mevcut" >> $report_file
    fi
    
    # .env dosyası
    if [ ! -f ".env" ]; then
        echo "❌ CRITICAL: Twilio ayarları bulunamadı!" >> $report_file
        echo "$(date): KRITIK - .env dosyası eksik!" >> $ALERT_FILE
        errors=$((errors + 1))
    else
        echo "✅ Twilio ayarları: Mevcut" >> $report_file
    fi
    
    # Son mesaj kontrolü (son 25 saatte mesaj var mı?)
    if [ -f "message_log.json" ]; then
        local last_message_hours=$(python3 -c "
import json
from datetime import datetime
try:
    with open('message_log.json', 'r') as f:
        logs = json.load(f)
    if logs:
        last_time = datetime.strptime(logs[-1]['timestamp'], '%Y-%m-%d %H:%M:%S')
        hours_ago = (datetime.now() - last_time).total_seconds() / 3600
        print(int(hours_ago))
    else:
        print(999)
except:
    print(999)
" 2>/dev/null || echo "999")
        
        if [ "$last_message_hours" -gt 25 ]; then
            echo "⚠️ WARNING: Son mesaj $last_message_hours saat önce gönderildi!" >> $report_file
            echo "$(date): UYARI - Son mesaj $last_message_hours saat önce!" >> $ALERT_FILE
        else
            echo "✅ Son mesaj: $last_message_hours saat önce" >> $report_file
        fi
    fi
    
    # Disk alanı kontrolü
    local disk_usage=$(df . | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        echo "⚠️ WARNING: Disk kullanımı %$disk_usage!" >> $report_file
        echo "$(date): UYARI - Disk doldu (%$disk_usage)!" >> $ALERT_FILE
    else
        echo "✅ Disk kullanımı: %$disk_usage" >> $report_file
    fi
    
    echo "📊 Toplam hata: $errors" >> $report_file
    echo "📅 Kontrol zamanı: $(date)" >> $report_file
    
    # Hata varsa log'a yaz
    if [ "$errors" -gt 0 ]; then
        echo "$(date): $errors adet kritik hata tespit edildi!" >> $LOG_FILE
    else
        echo "$(date): Sistem sağlıklı - $report_file" >> $LOG_FILE
    fi
    
    return $errors
}

# Hızlı test
quick_test() {
    echo "🧪 Hızlı test başlatılıyor..." >> $LOG_FILE
    
    if source twilio_env/bin/activate && python medication_reminder.py test >/dev/null 2>&1; then
        echo "✅ Test başarılı: $(date)" >> $LOG_FILE
        return 0
    else
        echo "❌ Test başarısız: $(date)" >> $ALERT_FILE
        echo "❌ Test başarısız: $(date)" >> $LOG_FILE
        return 1
    fi
}

# Ana kontrol fonksiyonu
main_check() {
    echo "🔍 Sistem kontrolü başlatılıyor: $(date)" >> $LOG_FILE
    
    # Sağlık kontrolü
    check_system_health
    local health_status=$?
    
    # Test çalıştır
    quick_test
    local test_status=$?
    
    # Özet oluştur
    if [ "$health_status" -eq 0 ] && [ "$test_status" -eq 0 ]; then
        echo "🎉 SİSTEM TAM SAĞLIKLI: $(date)" >> $LOG_FILE
        echo "✅ Sistem çalışıyor" > system_status_current.txt
    else
        echo "⚠️ SİSTEM SORUNLU: $(date)" >> $LOG_FILE
        echo "❌ Sistem sorunlu - Kontrol gerekli" > system_status_current.txt
    fi
}

# Script çalıştırma
echo "🚀 Otomatik izleme başlatıldı"
main_check

# Son durum özeti
echo ""
echo "📊 SİSTEM DURUMU ÖZETİ:"
echo "======================="
if [ -f "system_status_current.txt" ]; then
    cat system_status_current.txt
fi

echo ""
echo "📁 OLUŞTURULAN DOSYALAR:"
echo "========================"
echo "📋 Ana log: $LOG_FILE"
echo "🚨 Uyarılar: $ALERT_FILE"
echo "📊 Raporlar: $HEALTH_DIR/"
echo "📍 Mevcut durum: system_status_current.txt"

echo ""
echo "🔄 UZAKTAN KONTROL:"
echo "=================="
echo "ssh root@$(curl -s ifconfig.me) 'cd /root/hatirlatici && cat system_status_current.txt'"
echo "ssh root@$(curl -s ifconfig.me) 'cd /root/hatirlatici && tail -5 auto_monitor.log'"
