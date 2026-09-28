# DocuMind FastAPI Backend

This extracts the RAG logic from the original Streamlit application and exposes it through HTTP for Flutter.

## Run

```bash
cd backend
python -m venv .venv

# Windows
.venv\Scripts\activate

pip install -r requirements.txt
copy .env.example .env
# put your MISTRAL_API_KEY in .env

uvicorn app.main:app --reload
```

API:
- GET `/health`
- GET `/documents`
- POST `/documents/upload`
- POST `/documents/chat`

Swagger:
`http://127.0.0.1:8000/docs`
