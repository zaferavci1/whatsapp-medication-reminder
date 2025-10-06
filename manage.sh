#!/bin/bash

# Hatırlatıcı Sistem Yönetimi ve İzleme Scripti
# Bu script hatırlatıcı sistemini yönetmek için kullanılır

SCRIPT_DIR="/root/hatirlatici"
cd "$SCRIPT_DIR"

show_help() {
    echo "🏥 Anne İçin Şeker İlacı Hatırlatıcı Yönetim Sistemi"
    echo "=================================================="
    echo ""
    echo "📋 Kullanılabilir Komutlar:"
    echo ""
    echo "  📊 İzleme ve Durum:"
    echo "    ./manage.sh status          # Sistem durumunu göster"
    echo "    ./manage.sh logs            # Son mesaj loglarını göster"
    echo "    ./manage.sh schedules       # İlaç programlarını listele"
    echo ""
    echo "  🧪 Test İşlemleri:"
    echo "    ./manage.sh test            # Test mesajı gönder"
    echo "    ./manage.sh test-sabah      # Diamicron 60mg mesajı test et"
    echo "    ./manage.sh test-ogle       # Öğle ilaçları mesajı test et"
    echo "    ./manage.sh test-aksam      # Dropia-MET akşam mesajı test et"
    echo "    ./manage.sh test-diamicron  # Diamicron 60mg mesajı test et"
    echo "    ./manage.sh test-dropia-sabah # Dropia-MET sabah mesajı test et"
    echo ""
    echo "  ⚙️ Konfigürasyon:"
    echo "    ./manage.sh config          # Konfigürasyon dosyasını düzenle"
    echo "    ./manage.sh backup          # Konfigürasyonu yedekle"
    echo "    ./manage.sh restore         # Konfigürasyonu geri yükle"
    echo ""
    echo "  🔧 Sistem Yönetimi:"
    echo "    ./manage.sh enable          # Hatırlatmaları etkinleştir"
    echo "    ./manage.sh disable         # Hatırlatmaları devre dışı bırak"
    echo "    ./manage.sh restart         # Cron servisini yeniden başlat"
    echo "    ./manage.sh install         # Sistemi yeniden kur"
    echo ""
    echo "  📈 Raporlama:"
    echo "    ./manage.sh report          # Günlük rapor oluştur"  
    echo "    ./manage.sh stats           # İstatistikleri göster"
    echo ""
}

show_status() {
    echo "🏥 Hatırlatıcı Sistem Durumu"
    echo "============================"
    echo ""
    
    # Cron servis durumu
    if systemctl is-active cron >/dev/null 2>&1; then
        echo "✅ Cron Servisi: Çalışıyor"
    else
        echo "❌ Cron Servisi: Çalışmıyor"
    fi
    
    # Cron job'lar
    cron_count=$(crontab -l 2>/dev/null | grep -c "medication_reminder")
    if [ "$cron_count" -gt 0 ]; then
        echo "✅ Zamanlanmış Görevler: $cron_count adet aktif"
    else
        echo "❌ Zamanlanmış Görevler: Bulunamadı"
    fi
    
    # Virtual environment
    if [ -d "twilio_env" ]; then
        echo "✅ Python Environment: Hazır"
    else
        echo "❌ Python Environment: Bulunamadı"
    fi
    
    # Konfigürasyon dosyası
    if [ -f "medication_config.json" ]; then
        echo "✅ Konfigürasyon: Mevcut"
    else
        echo "❌ Konfigürasyon: Bulunamadı"
    fi
    
    # Environment variables
    source twilio_env/bin/activate 2>/dev/null
    if [ -n "$(python -c 'import os; print(os.environ.get("TWILIO_ACCOUNT_SID", ""))' 2>/dev/null)" ]; then
        echo "✅ Twilio Credentials: Ayarlanmış"
    else
        echo "❌ Twilio Credentials: Eksik"
    fi
    
    echo ""
    echo "📅 Bir Sonraki Hatırlatmalar:"
    echo "  🌅 Sabah: Her gün 08:00"
    echo "  🌞 Öğle: Her gün 12:30" 
    echo "  🌆 Akşam: Her gün 18:00"
    echo ""
    
    # Son mesaj logları varsa göster
    if [ -f "message_log.json" ]; then
        last_message=$(python -c "import json; logs=json.load(open('message_log.json')); print(logs[-1]['timestamp'] if logs else 'Hiç mesaj gönderilmemiş')" 2>/dev/null)
        echo "📱 Son Mesaj: $last_message"
    fi
}

show_logs() {
    echo "📝 Son Mesaj Logları"
    echo "=================="
    
    if [ -f "message_log.json" ]; then
        python -c "
import json
try:
    with open('message_log.json', 'r', encoding='utf-8') as f:
        logs = json.load(f)
    
    if not logs:
        print('Henüz hiç mesaj gönderilmemiş.')
        exit()
    
    print(f'Toplam {len(logs)} mesaj gönderilmiş.\n')
    
    # Son 10 mesajı göster
    recent_logs = logs[-10:] if len(logs) >= 10 else logs
    
    for i, log in enumerate(reversed(recent_logs), 1):
        print(f'{i:2d}. {log[\"timestamp\"]}')
        print(f'    📧 SID: {log[\"message_sid\"]}')
        print(f'    💬 Mesaj: {log[\"message_preview\"]}')
        print(f'    📱 Alıcı: {log[\"recipient\"]}')
        print()

except Exception as e:
    print(f'Log okuma hatası: {e}')
"
    else
        echo "Henüz log dosyası oluşturulmamış."
    fi
}

send_test_message() {
    local test_type="$1"
    echo "🧪 Test mesajı gönderiliyor..."
    
    source twilio_env/bin/activate
    
    case "$test_type" in
        "sabah"|"diamicron")
            python medication_reminder.py sabah
            ;;
        "ogle"|"ogle-ilaclar")
            python medication_reminder.py öğle
            ;;
        "aksam"|"dropia-aksam")
            python medication_reminder.py akşam
            ;;
        "dropia-sabah")
            python medication_reminder.py dropia-sabah
            ;;
        *)
            python medication_reminder.py test
            ;;
    esac
}

manage_cron() {
    local action="$1"
    
    case "$action" in
        "enable")
            echo "✅ Hatırlatmalar etkinleştiriliyor..."
            systemctl start cron
            echo "Hatırlatmalar etkinleştirildi."
            ;;
        "disable")
            echo "❌ Hatırlatmalar devre dışı bırakılıyor..."
            # Cron job'ları geçici olarak kapat
            crontab -l | sed 's/^/#DISABLED# /' | crontab -
            echo "Hatırlatmalar devre dışı bırakıldı."
            echo "Tekrar etkinleştirmek için: ./manage.sh enable"
            ;;
        "restart")
            echo "🔄 Cron servisi yeniden başlatılıyor..."
            systemctl restart cron
            echo "Cron servisi yeniden başlatıldı."
            ;;
    esac
}

# Ana komut işleyici
case "$1" in
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "schedules")
        source twilio_env/bin/activate && python medication_reminder.py list
        ;;
    "test")
        send_test_message
        ;;
    "test-sabah")
        send_test_message "sabah"
        ;;
    "test-ogle")
        send_test_message "ogle"
        ;;
    "test-aksam")
        send_test_message "aksam"
        ;;
    "test-diamicron")
        send_test_message "diamicron"
        ;;
    "test-dropia-sabah")
        send_test_message "dropia-sabah"
        ;;
    "test-dropia-aksam")
        send_test_message "dropia-aksam"
        ;;
    "test-ogle-ilaclar")
        send_test_message "ogle-ilaclar"
        ;;
    "config")
        nano medication_config.json
        ;;
    "backup")
        cp medication_config.json "medication_config_backup_$(date +%Y%m%d_%H%M%S).json"
        echo "✅ Konfigürasyon yedeklendi."
        ;;
    "enable")
        manage_cron "enable"
        ;;
    "disable")
        manage_cron "disable"
        ;;
    "restart")
        manage_cron "restart"
        ;;
    "install")
        ./setup_cron_jobs.sh
        ;;
    "report")
        echo "📊 Günlük Rapor ($(date +%Y-%m-%d))"
        echo "================================"
        show_status
        echo ""
        show_logs
        ;;
    "stats")
        if [ -f "message_log.json" ]; then
            python -c "
import json
from collections import Counter
from datetime import datetime

with open('message_log.json', 'r') as f:
    logs = json.load(f)

if not logs:
    print('Henüz istatistik yok.')
    exit()

print('📈 Mesaj İstatistikleri')
print('=====================')
print(f'Toplam Mesaj: {len(logs)}')

# Bu ayın mesajları
current_month = datetime.now().strftime('%Y-%m')
monthly_count = sum(1 for log in logs if log['timestamp'].startswith(current_month))
print(f'Bu Ay: {monthly_count} mesaj')

# Bu haftanın mesajları  
from datetime import datetime, timedelta
week_ago = (datetime.now() - timedelta(days=7)).strftime('%Y-%m-%d')
weekly_count = sum(1 for log in logs if log['timestamp'] >= week_ago)
print(f'Son 7 Gün: {weekly_count} mesaj')

print(f'İlk Mesaj: {logs[0][\"timestamp\"]}')
print(f'Son Mesaj: {logs[-1][\"timestamp\"]}')
"
        else
            echo "Henüz istatistik yok."
        fi
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        echo "❌ Geçersiz komut: $1"
        echo "Yardım için: ./manage.sh help"
        exit 1
        ;;
esac
