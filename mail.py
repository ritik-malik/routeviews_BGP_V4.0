import smtplib, ssl, sys

message = sys.argv[1]
EMAIL = "sender email"
PASSWD = "passwd here"
RECEIVER = "receiver email"

port = 587  # For starttls
smtp_server = "smtp.gmail.com"
sender_email = EMAIL
receiver_email = RECEIVER
password = PASSWD

context = ssl.create_default_context()
with smtplib.SMTP(smtp_server, port) as server:
    server.starttls(context=context)
    server.login(sender_email, password)
    server.sendmail(sender_email, receiver_email, message)
