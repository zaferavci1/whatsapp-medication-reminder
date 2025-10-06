#!/bin/bash

# Güncellenmiş İlaç Zamanlaması Cron Job Kurulumu
echo "💊 Gerçek ilaç zamanlaması için cron job'ları güncelleniyor..."

# Mevcut hatırlatıcı cron job'larını temizle
crontab -l 2>/dev/null | grep -v "medication_reminder\|hatirlatici" > temp_cron_clean.txt

# Yeni ilaç zamanlamaları ekle
cat >> temp_cron_clean.txt << 'EOF'

# === ANNEM İÇİN GERÇEK İLAÇ HATIRLATICILARI ===
# Diamicron 60mg - Her sabah 10:15 (aç karnına)
15 10 * * * cd /root/hatirlatici && source twilio_env/bin/activate && python medication_reminder.py >/dev/null 2>&1

# Dropia-MET 15mg (Sabah) - Her gün 11:45 (tok karnına, kahvaltıdan sonra)
45 11 * * * cd /root/hatirlatici && source twilio_env/bin/activate && python medication_reminder.py >/dev/null 2>&1

# Linatin 5mg + Jaglif 10mg - Her gün 14:00 (tok karnına, öğleden sonra)
0 14 * * * cd /root/hatirlatici && source twilio_env/bin/activate && python medication_reminder.py >/dev/null 2>&1

# Dropia-MET 15mg (Akşam) - Her gün 20:00 (tok karnına, akşam yemeğinden sonra)
0 20 * * * cd /root/hatirlatici && source twilio_env/bin/activate && python medication_reminder.py >/dev/null 2>&1

EOF

# Yeni cron job'ları yükle
crontab temp_cron_clean.txt
rm temp_cron_clean.txt

echo "✅ İlaç zamanlamaları güncellendi!"
echo ""
echo "📋 Yeni Hatırlatma Zamanları:"
echo "   💊 10:15 - Diamicron 60mg (aç karnına)"
echo "   💊 11:45 - Dropia-MET 15mg (tok karnına, sabah)"
echo "   💊 14:00 - Linatin 5mg + Jaglif 10mg (tok karnına)"
echo "   💊 20:00 - Dropia-MET 15mg (tok karnına, akşam)"
echo ""
echo "🕒 Günlük Rutin:"
echo "   🛏️  10:00 - Uyanma"
echo "   🍳 11:00 - Kahvaltı"
echo "   🍽️  13:30 - Öğle yemeği"
echo "   🌆 19:30 - Akşam yemeği"
