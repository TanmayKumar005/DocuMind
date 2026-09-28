import os
import shutil
from pathlib import Path
from typing import List

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from .rag_service import UPLOAD_DIR, build_database, ask_document

app = FastAPI(
    title="DocuMind API",
    version="1.0.0",
    description="FastAPI backend for the DocuMind Flutter AI document assistant.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

documents = []

class ChatRequest(BaseModel):
    question: str

@app.get("/health")
def health():
    return {"status": "ok", "service": "documind"}

@app.get("/documents")
def list_documents():
    return {"documents": documents}

@app.post("/documents/upload")
async def upload_document(file: UploadFile = File(...)):
    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are supported.")

    safe_name = Path(file.filename).name
    target = UPLOAD_DIR / safe_name

    with target.open("wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    try:
        chunks = build_database(str(target))
    except Exception as exc:
        if target.exists():
            target.unlink()
        raise HTTPException(status_code=500, detail=f"Document processing failed: {exc}")

    item = {
        "id": safe_name,
        "name": safe_name,
        "chunks": chunks,
        "status": "ready",
    }

    documents[:] = [d for d in documents if d["id"] != safe_name]
    documents.append(item)

    return item

@app.post("/documents/chat")
def chat(request: ChatRequest):
    if not request.question.strip():
        raise HTTPException(status_code=400, detail="Question cannot be empty.")

    try:
        return ask_document(request.question.strip())
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"RAG request failed: {exc}")
