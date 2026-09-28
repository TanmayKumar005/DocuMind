# DocuMind

> An AI-powered document research workspace that lets users upload PDFs, search their content semantically, and ask grounded questions about their documents.

DocuMind combines a **Flutter frontend**, **FastAPI backend**, **LangChain-based RAG pipeline**, **Mistral AI**, and **Chroma vector database** into a single document intelligence application.

---

## ✨ Features

- 📄 Upload PDF documents
- 🧠 Automatic document processing and vectorization
- 🔎 Semantic document retrieval
- 💬 Ask natural-language questions about uploaded documents
- 🤖 AI-generated answers grounded in retrieved document context
- 📚 Source snippets for retrieved information
- ⚡ MMR-based retrieval for diverse relevant results
- 🌐 Flutter Web interface
- 🔌 REST API powered by FastAPI
- 🛡️ Environment-based API key configuration
- 🧩 Modular frontend/backend architecture
- ⚠️ Graceful fallback when the AI provider is temporarily rate-limited

---

## 🏗️ Architecture

```text
                    ┌─────────────────────┐
                    │     Flutter UI      │
                    │                     │
                    │  Document Dashboard │
                    │  PDF Upload         │
                    │  AI Chat            │
                    └──────────┬──────────┘
                               │
                               │ REST API
                               ▼
                    ┌─────────────────────┐
                    │     FastAPI         │
                    │                     │
                    │ /documents          │
                    │ /documents/upload   │
                    │ /documents/chat     │
                    └──────────┬──────────┘
                               │
                 ┌─────────────┴─────────────┐
                 │                           │
                 ▼                           ▼
        ┌─────────────────┐        ┌─────────────────┐
        │ Document        │        │ Chroma Vector   │
        │ Processing      │───────▶│ Database        │
        │                 │        │                 │
        │ PyPDFLoader     │        │ Embeddings      │
        │ Text Splitter   │        │ Semantic Search │
        └─────────────────┘        └────────┬────────┘
                                            │
                                            │ Retrieved Context
                                            ▼
                                   ┌─────────────────┐
                                   │   Mistral AI    │
                                   │                 │
                                   │ Context-grounded│
                                   │ Answer          │
                                   └─────────────────┘

🛠️ Tech Stack
Frontend
Flutter
Dart
Dio
Material 3
Backend
Python
FastAPI
Uvicorn
AI / RAG
LangChain
Mistral AI
Mistral Embeddings
ChromaDB
PyPDFLoader
📁 Project Structure
DocuMind/
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   └── rag_service.py
│   ├── uploads/
│   ├── chroma-db/
│   ├── requirements.txt
│   └── .env.example
│
├── flutter/
│   ├── lib/
│   │   ├── models/
│   │   ├── pages/
│   │   ├── services/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── .gitignore
└── README.md
🚀 Setup
Backend
cd backend

python -m venv .venv

Windows:

.venv\Scripts\activate

Install dependencies:

pip install -r requirements.txt

Create .env:

MISTRAL_API_KEY=your_mistral_api_key
MISTRAL_MODEL=mistral-small-2506

Start the server:

uvicorn app.main:app --reload

Backend:

http://localhost:8000

API documentation:

http://localhost:8000/docs
Flutter
cd flutter
flutter pub get
flutter run -d chrome
🔄 RAG Pipeline
PDF
 ↓
Text Extraction
 ↓
Chunking
 ↓
Embeddings
 ↓
ChromaDB
 ↓
MMR Retrieval
 ↓
Relevant Context
 ↓
Mistral LLM
 ↓
Grounded Answer

The system instructs the LLM to answer only using the retrieved document context. If the information cannot be found, it returns:

"I could not find the answer in the document."

🔌 API Endpoints
Method	Endpoint	Description
GET	/health	Backend health check
GET	/documents	List documents
POST	/documents/upload	Upload a PDF
POST	/documents/chat	Ask a question
🚨 Rate Limit Handling

If the Mistral API returns a 429 rate-limit error, DocuMind falls back to displaying the most relevant retrieved passages instead of failing completely.

🔮 Future Improvements
Multi-document conversations
Chat history
Streaming responses
PDF page previews
OCR for scanned documents
Hybrid search
Reranking
Authentication
Cloud deployment
👨‍💻 Author

Tanmay

Built as an AI/full-stack project demonstrating practical implementation of RAG, LLMs, vector databases, FastAPI, and Flutter.


