#!/usr/bin/env python3
from twilio.rest import Client
import os
import json
import sys
from datetime import datetime
from dotenv import load_dotenv

# .env dosyasından environment variables'ları yükle
load_dotenv()

class MedicationReminder:
    def __init__(self):
        # Twilio credentials
        self.account_sid = os.environ.get('TWILIO_ACCOUNT_SID')
        self.auth_token = os.environ.get('TWILIO_AUTH_TOKEN')
        self.twilio_whatsapp_number = os.environ.get('TWILIO_WHATSAPP_NUMBER')
        
        # Twilio client
        self.client = Client(self.account_sid, self.auth_token)
        
        # Konfigürasyon dosyasını yükle
        self.load_config()
    
    def load_config(self):
        """Konfigürasyon dosyasını yükle"""
        try:
            with open('medication_config.json', 'r', encoding='utf-8') as file:
                self.config = json.load(file)
        except FileNotFoundError:
            print("Hata: medication_config.json dosyası bulunamadı!")
            sys.exit(1)
        except json.JSONDecodeError:
            print("Hata: medication_config.json dosyası geçersiz JSON formatında!")
            sys.exit(1)
    
    def get_current_schedule(self, target_time=None):
        """Belirtilen saat için uygun ilaç programını bul"""
        if target_time is None:
            current_time = datetime.now().strftime("%H:%M")
        else:
            current_time = target_time
            
        for schedule in self.config['medication_schedules']:
            if schedule['enabled'] and schedule['time'] == current_time:
                return schedule
        return None
    
    def send_medication_reminder(self, schedule_name=None, test_message=False):
        """Belirtilen programa göre hatırlatma mesajı gönder"""
        try:
            if test_message:
                # Test mesajı gönder
                message_body = "🧪 Test Mesajı: Hatırlatma sistemi çalışıyor! Bu bir test mesajıdır."
                print("Test mesajı gönderiliyor...")
            elif schedule_name:
                # Belirli bir programa göre mesaj gönder
                schedule = None
                for s in self.config['medication_schedules']:
                    if s['name'] == schedule_name and s['enabled']:
                        schedule = s
                        break
                
                if not schedule:
                    print(f"Hata: '{schedule_name}' programı bulunamadı veya devre dışı!")
                    return False
                    
                message_body = schedule['message']
                print(f"Mesaj gönderiliyor: {schedule['name']} ({schedule['time']})")
            else:
                # Mevcut saate göre otomatik mesaj gönder
                current_time = datetime.now().strftime("%H:%M")
                schedule = self.get_current_schedule(current_time)
                
                if not schedule:
                    print(f"Bu saat ({current_time}) için tanımlanmış ilaç programı bulunamadı.")
                    return False
                    
                message_body = schedule['message']
                print(f"Mesaj gönderiliyor: {schedule['name']} ({schedule['time']})")
            
            # WhatsApp mesajı gönder
            message = self.client.messages.create(
                body=message_body,
                from_=f'whatsapp:{self.twilio_whatsapp_number}',
                to=f"whatsapp:{self.config['recipient_info']['phone']}"
            )
            
            print(f"✅ Mesaj başarıyla gönderildi!")
            print(f"📱 Alıcı: {self.config['recipient_info']['name']} ({self.config['recipient_info']['phone']})")
            print(f"📧 Mesaj SID: {message.sid}")
            print(f"⏰ Gönderim zamanı: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            
            # Log dosyasına kaydet
            self.log_message(message_body, message.sid)
            
            return True
            
        except Exception as e:
            print(f"❌ Hata oluştu: {e}")
            return False
    
    def log_message(self, message_body, message_sid):
        """Gönderilen mesajları log dosyasına kaydet"""
        log_entry = {
            "timestamp": datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            "message_sid": message_sid,
            "message_preview": message_body[:50] + "..." if len(message_body) > 50 else message_body,
            "recipient": self.config['recipient_info']['phone']
        }
        
        try:
            # Log dosyasını oku veya oluştur
            try:
                with open('message_log.json', 'r', encoding='utf-8') as file:
                    logs = json.load(file)
            except FileNotFoundError:
                logs = []
            
            # Yeni log ekle
            logs.append(log_entry)
            
            # Son 100 log'u tut
            if len(logs) > 100:
                logs = logs[-100:]
            
            # Log dosyasına geri yaz
            with open('message_log.json', 'w', encoding='utf-8') as file:
                json.dump(logs, file, ensure_ascii=False, indent=2)
                
        except Exception as e:
            print(f"⚠️ Log kaydı başarısız: {e}")
    
    def list_schedules(self):
        """Tüm ilaç programlarını listele"""
        print("\n📋 Tanımlı İlaç Programları:")
        print("=" * 50)
        
        for i, schedule in enumerate(self.config['medication_schedules'], 1):
            status = "✅ Aktif" if schedule['enabled'] else "❌ Devre Dışı"
            print(f"{i}. {schedule['name']}")
            print(f"   ⏰ Saat: {schedule['time']}")
            print(f"   📱 Durum: {status}")
            print(f"   💬 Mesaj: {schedule['message'][:60]}...")
            print("-" * 30)
        
        print(f"\n👤 Alıcı: {self.config['recipient_info']['name']}")
        print(f"📞 Telefon: {self.config['recipient_info']['phone']}")
        print(f"🌍 Zaman Dilimi: {self.config['timezone']}")

def main():
    """Ana fonksiyon - komut satırı argümanlarını işle"""
    reminder = MedicationReminder()
    
    if len(sys.argv) == 1:
        # Argüman yoksa mevcut saate göre otomatik gönder
        reminder.send_medication_reminder()
    elif len(sys.argv) == 2:
        arg = sys.argv[1]
        if arg == "test":
            # Test mesajı gönder
            reminder.send_medication_reminder(test_message=True)
        elif arg == "list":
            # Programları listele
            reminder.list_schedules()
        elif arg in ["sabah", "öğle", "akşam", "diamicron", "dropia-sabah", "dropia-aksam", "ogle-ilaclar"]:
            # Belirli programa göre gönder
            schedule_map = {
                "sabah": "Diamicron 60mg (Aç Karnına)",
                "diamicron": "Diamicron 60mg (Aç Karnına)",
                "dropia-sabah": "Dropia-MET 15mg (Sabah - Tok Karnına)",
                "öğle": "Öğle İlaçları (Tok Karnına)",
                "ogle-ilaclar": "Öğle İlaçları (Tok Karnına)",
                "akşam": "Dropia-MET 15mg (Akşam - Tok Karnına)",
                "dropia-aksam": "Dropia-MET 15mg (Akşam - Tok Karnına)"
            }
            reminder.send_medication_reminder(schedule_map[arg])
        else:
            print("❌ Geçersiz argüman!")
            print_usage()
    else:
        print("❌ Çok fazla argüman!")
        print_usage()

def print_usage():
    """Kullanım bilgilerini göster"""
    print("\n📖 Kullanım:")
    print("  python medication_reminder.py                 # Mevcut saate göre otomatik gönder")
    print("  python medication_reminder.py test            # Test mesajı gönder")
    print("  python medication_reminder.py list            # Programları listele")
    print("  python medication_reminder.py sabah           # Diamicron 60mg mesajı gönder")
    print("  python medication_reminder.py öğle            # Öğle ilaçları mesajı gönder")
    print("  python medication_reminder.py akşam           # Dropia-MET akşam mesajı gönder")
    print("  python medication_reminder.py diamicron       # Diamicron 60mg mesajı gönder")
    print("  python medication_reminder.py dropia-sabah    # Dropia-MET sabah mesajı gönder")
    print("  python medication_reminder.py dropia-aksam    # Dropia-MET akşam mesajı gönder")
    print("  python medication_reminder.py ogle-ilaclar    # Linatin + Jaglif mesajı gönder")

if __name__ == "__main__":
    main()
