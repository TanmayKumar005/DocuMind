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
