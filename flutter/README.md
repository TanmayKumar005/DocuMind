# DocuMind Flutter

## 1. Start FastAPI

Run the backend first:

```bash
cd ../backend
uvicorn app.main:app --reload
```

## 2. Flutter

```bash
cd flutter
flutter pub get
flutter run
```

## API address

Android emulator uses:

`http://10.0.2.2:8000`

If using a physical phone, change `baseUrl` in:

`lib/services/api_service.dart`

to your computer's LAN address, e.g.:

`http://192.168.1.5:8000`

## Demo flow

1. Start FastAPI.
2. Open Flutter.
3. Upload a PDF.
4. Wait for "Indexing..." to finish.
5. Open the document.
6. Ask a question.
7. Show the generated answer and source/page cards.
