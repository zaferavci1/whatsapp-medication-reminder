from twilio.rest import Client
import os
from dotenv import load_dotenv

# .env dosyasından environment variables'ları yükle
load_dotenv()

# BU BİLGİLERİ ASLA KODUN İÇİNE DOĞRUDAN YAZMAYIN!
# Güvenlik için "Environment Variables" (Ortam Değişkenleri) kullanacağız.
ACCOUNT_SID = os.environ.get('TWILIO_ACCOUNT_SID')
AUTH_TOKEN = os.environ.get('TWILIO_AUTH_TOKEN')
TWILIO_WHATSAPP_NUMBER = os.environ.get('TWILIO_WHATSAPP_NUMBER')
RECIPIENT_WHATSAPP_NUMBER = os.environ.get('RECIPIENT_WHATSAPP_NUMBER')

client = Client(ACCOUNT_SID, AUTH_TOKEN)

try:
    message_body = 'Canım annem, sabah ilacını içme zamanı geldi. Seni çok seviyorum. ❤️'

    message = client.messages.create(
                          body=message_body,
                          from_=f'whatsapp:{TWILIO_WHATSAPP_NUMBER}',
                          to=f'whatsapp:{RECIPIENT_WHATSAPP_NUMBER}'
                      )
    print(f"Mesaj başarıyla gönderildi! SID: {message.sid}")

except Exception as e:
    print(f"Hata oluştu: {e}")