===== TWILIO WHATSAPP SANDBOX KURULUM REHBERİ =====

1. TWILIO CONSOLE'A GİRİN:
   https://console.twilio.com/us1/develop/sms/try-it-out/whatsapp-learn

2. WHATSAPP SANDBOX'I AKTİFLEŞTİRİN:
   - "Get Started" butonuna tıklayın
   - Size verilen sandbox numarasını kaydedin
   - Size verilen kodu WhatsApp'tan gönderin

3. SANDBOX NUMARASINI ALIRken:
   - Format: +1415523XXXX gibi bir numara olacak
   - Bu numarayı .env dosyasına kopyalayın

4. .ENV DOSYASINI GÜNCELLEYİN:
   nano .env
   
   TWILIO_WHATSAPP_NUMBER="+1415523XXXX"  # Console'dan alacağınız gerçek sandbox numarası

5. TEST EDİN:
   source twilio_env/bin/activate
   python send_message.py

===== MEVCUT SORUN =====
❌ WhatsApp sandbox numarası "+19037651259" geçersiz
✅ Account SID ve Auth Token artık doğru çalışıyor!

===== İLETİŞİM AYARLARI =====
- Alıcı numara: +9055538826863 (Format doğru)
- Gönderen numara: Twilio Console'dan güncellenecek

Bu adımları takip ettikten sonra sistem çalışacak!
