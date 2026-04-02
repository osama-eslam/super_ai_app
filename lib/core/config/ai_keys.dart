// 📁 lib/core/config/ai_keys.dart
// =============================================================
// 🔐 AI Configuration
// -------------------------------------------------------------
// This file contains API keys and base URLs for AI services.
// ⚠️ Do NOT upload this file publicly.
// Use .env for real keys in production (e.g., flutter_dotenv).
// All base URLs here are demo/test endpoints and can be changed.
// =============================================================

// ignore_for_file: constant_identifier_names

// 🧠 CHAT (OpenAI GPT)
const String AiKey_chat = ""; // Your OpenAI API key
const String AiBaseUrl_chat = "https://api.openai.com/v1"; // Demo URL

// ✍️ ARTICLE SUMMARIZER
const String AiKey_summarizer = ""; // Optional key for summarizer
const String AiBaseUrl_summarizer =
    "https://api.openai.com/v1/chat/completions"; // Demo URL

// 🖼️ IMAGE GENERATOR (DALL·E / gpt-image-1)
const String AiKey_imageGenerator = ""; // Optional image generator key
const String AiBaseUrl_imageGenerator =
    "https://api.openai.com/v1/images/generations"; // Demo URL

// 🧩 IMAGE ENHANCER (DeepAI Torch-SRGAN)
const String AiKey_imageEnhancer = ""; // Optional DeepAI key
const String AiBaseUrl_imageEnhancer =
    "https://api.deepai.org/api/torch-srgan"; // Demo URL
