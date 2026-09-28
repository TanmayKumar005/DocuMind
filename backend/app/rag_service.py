import os
from pathlib import Path

from dotenv import load_dotenv

from langchain_community.document_loaders import PyPDFLoader
from langchain_community.vectorstores import Chroma
from langchain_core.prompts import ChatPromptTemplate
from langchain_mistralai import ChatMistralAI, MistralAIEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter

load_dotenv()

# -----------------------------
# Paths
# -----------------------------

BASE_DIR = Path(__file__).resolve().parent.parent

UPLOAD_DIR = BASE_DIR / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

DB_DIR = BASE_DIR / "chroma-db"


# -----------------------------
# Models
# -----------------------------

embedding_model = MistralAIEmbeddings()


# -----------------------------
# Prompt
# -----------------------------

prompt = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            """You are an AI document assistant.

Use ONLY the provided context to answer the question.

If the answer is not present in the context, say:

"I could not find the answer in the document."

Do not make up information.""",
        ),
        (
            "human",
            """Context:

{context}

Question:

{question}
""",
        ),
    ]
)


# -----------------------------
# Build / Index PDF
# -----------------------------

def build_database(pdf_path: str) -> int:
    """Load a PDF, split it into chunks and store embeddings in Chroma."""

    splitter = RecursiveCharacterTextSplitter(
        chunk_size=10000,
        chunk_overlap=200,
    )

    loader = PyPDFLoader(pdf_path)
    documents = loader.load()

    chunks = splitter.split_documents(documents)

    if not chunks:
        raise ValueError("No readable content was found in the PDF.")

    Chroma.from_documents(
        documents=chunks,
        embedding=embedding_model,
        persist_directory=str(DB_DIR),
    )

    return len(chunks)


# -----------------------------
# Vector Store
# -----------------------------

def get_vectorstore():
    return Chroma(
        persist_directory=str(DB_DIR),
        embedding_function=embedding_model,
    )


# -----------------------------
# Ask Document
# -----------------------------

def ask_document(question: str):

    vectorstore = get_vectorstore()

    retriever = vectorstore.as_retriever(
        search_type="mmr",
        search_kwargs={
            "k": 4,
            "fetch_k": 10,
            "lambda_mult": 0.5,
        },
    )

    docs = retriever.invoke(question)

    if not docs:
        return {
            "answer": "I could not find the answer in the document.",
            "sources": [],
            "fallback": False,
        }

    # Combine retrieved chunks
    context = "\n\n".join(
        doc.page_content
        for doc in docs
    )

    # Build source information
    sources = []

    for doc in docs:
        sources.append(
            {
                "document": Path(
                    doc.metadata.get(
                        "source",
                        "Unknown document"
                    )
                ).name,
                "page": (
                    doc.metadata.get("page", 0) + 1
                    if doc.metadata.get("page") is not None
                    else None
                ),
                "snippet": doc.page_content[:300],
            }
        )

    # -----------------------------
    # Try Mistral
    # -----------------------------

    try:

        llm = ChatMistralAI(
            model_name=os.getenv(
                "MISTRAL_MODEL",
                "mistral-small-2506",
            )
        )

        final_prompt = prompt.invoke(
            {
                "context": context,
                "question": question,
            }
        )

        response = llm.invoke(final_prompt)

        return {
            "answer": response.content,
            "sources": sources,
            "fallback": False,
        }

    except Exception as exc:

        error_text = str(exc)

        # -----------------------------
        # Mistral rate-limit fallback
        # -----------------------------

        if (
            "429" in error_text
            or "rate_limit" in error_text.lower()
            or "rate limit" in error_text.lower()
        ):

            fallback_text = (
                "⚠️ Mistral API is currently rate-limited.\n\n"
                "The RAG retriever successfully found these "
                "relevant passages from your document:\n\n"
            )

            fallback_text += "\n\n---\n\n".join(
                doc.page_content[:1200]
                for doc in docs
            )

            return {
                "answer": fallback_text,
                "sources": sources,
                "fallback": True,
            }

        # Other errors should still be reported
        raise