fastapi
opencv-python
os


uvicorn Facial_recognition:app --host 127.0.0.1 --port 8080 --reload
uvicorn Facial_recognition:app --host 192.168.203.26 --port 8080 --reload
/home/javandroid/projects/Mpm12/api/api/Facial_recognition.py

curl -X 'POST' \
  'http:/127.0.0.1:8080/save-face/' \
  -H 'accept: application/json' \
  -H 'Content-Type: multipart/form-data' \
  -F 'file=@/home/javandroid/projects/Mpm12/api/api/image1.jpg' \
  -F 'name=test_user'


