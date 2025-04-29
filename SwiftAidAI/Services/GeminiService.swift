import SwiftUI
import Foundation

// Service class for interacting with Google's Gemini AI API
class GeminiService: ObservableObject {
    // API configuration
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    
    // Published properties for UI state management
    @Published var isProcessing = false
    @Published var lastError: String?
    
    // Initialize with API key from Info.plist or provided key
    init(apiKey: String? = nil) {
        self.apiKey = apiKey ?? Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String ?? ""
    }
    
    // Main function to analyze symptoms and generate health advice
    func analyzeSymptoms(_ input: String, previousMessages: [ChatMessage] = []) async throws -> String {
        isProcessing = true
        lastError = nil
        defer { isProcessing = false }
        
        // Build conversation history for context
        var conversationContext = ""
        if !previousMessages.isEmpty {
            conversationContext = previousMessages.map { message in
                "\(message.isUser ? "User" : "Assistant"): \(message.text)"
            }.joined(separator: "\n") + "\n"
        }
        
        // Construct the prompt with conversation context and guidelines
        let prompt = """
        You are a helpful, empathetic, and safety-conscious virtual health assistant. Respond directly and naturally to the user, avoiding any meta-references to "the user's statement" or similar phrases. Start your response immediately with a warm, natural greeting or acknowledgment.

        \(conversationContext.isEmpty ? "" : "Previous conversation:\n\(conversationContext)\n")
        Current message: "\(input)"

        Your response should:
        - Start with a natural, empathetic acknowledgment
        - Briefly explain **possible common causes** (keep it simple)
        - Offer **1–3 safe, general tips** for home care (if relevant)
        - List **serious symptoms to watch for** in a compact bullet list
        - End with a relevant, helpful **follow-up question** (keep it conversational)

        Style guidelines:
        - Use short paragraphs or bullets — no long blocks of text
        - Be slightly informative, but don't overload with information
        - Keep the tone friendly, casual, and human
        - Use **bold headers** and **emoji icons** to guide the eye
        - Do **not** give a medical diagnosis or recommend treatments that require a prescription
        - Do **remind the user you're not a doctor**
        - Reference previous messages when relevant to maintain conversation flow

        Important: If this appears to be an emergency situation (bleeding, choking, unconsciousness, severe pain, etc.), emphasize the urgency of seeking immediate medical attention and provide clear, step-by-step first aid guidance while help is on the way.

        Avoid repeating obvious things or going into too much detail — keep it light and helpful.
        """
        
        // Configure API request parameters
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": prompt
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 1024
            ],
            "safetySettings": [
                [
                    "category": "HARM_CATEGORY_HARASSMENT",
                    "threshold": "BLOCK_NONE"
                ],
                [
                    "category": "HARM_CATEGORY_HATE_SPEECH",
                    "threshold": "BLOCK_NONE"
                ],
                [
                    "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    "threshold": "BLOCK_NONE"
                ],
                [
                    "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                    "threshold": "BLOCK_NONE"
                ]
            ]
        ]
        
        // Create and configure URL request
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw GeminiError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        
        do {
            // Send request and handle response
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GeminiError.badServerResponse
            }
            
            // Handle HTTP errors
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                    throw GeminiError.apiError(message: errorResponse.error.message)
                }
                throw GeminiError.httpError(statusCode: httpResponse.statusCode)
            }
            
            // Decode and process successful response
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            guard let firstCandidate = geminiResponse.candidates.first,
                  let firstPart = firstCandidate.content.parts.first,
                  !firstPart.text.isEmpty else {
                throw GeminiError.noValidResponse
            }
            
            // Format and clean up the response text
            return firstPart.text
                .replacingOccurrences(of: "\\*", with: "•")
                .replacingOccurrences(of: "**", with: "")
                .replacingOccurrences(of: "*", with: "•")
                .replacingOccurrences(of: "\n\n\n", with: "\n\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }
}

// MARK: - Response Models

// Main response structure from Gemini API
struct GeminiResponse: Codable {
    let candidates: [Candidate]
    let usageMetadata: UsageMetadata
}

// Individual response candidate
struct Candidate: Codable {
    let content: Content
    let finishReason: String
    let citationMetadata: CitationMetadata?
    let avgLogprobs: Double?
}

// Content of a response
struct Content: Codable {
    let parts: [Part]
    let role: String
}

// Individual part of content (text)
struct Part: Codable {
    let text: String
}

// Citation metadata for responses
struct CitationMetadata: Codable {
    let citationSources: [CitationSource]?
}

// Source of a citation
struct CitationSource: Codable {
    let startIndex: Int
    let endIndex: Int
}

// Token usage metadata
struct UsageMetadata: Codable {
    let promptTokenCount: Int
    let candidatesTokenCount: Int
    let totalTokenCount: Int
    let promptTokensDetails: [TokenDetails]
    let candidatesTokensDetails: [TokenDetails]
}

// Details about token usage
struct TokenDetails: Codable {
    let modality: String
    let tokenCount: Int
}

// Error response structure
struct GeminiErrorResponse: Codable {
    let error: GeminiError
    
    struct GeminiError: Codable {
        let code: Int
        let message: String
        let status: String
    }
}

// Custom error types for Gemini service
enum GeminiError: Error {
    case badURL
    case badServerResponse
    case httpError(statusCode: Int)
    case apiError(message: String)
    case noValidResponse
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid API URL"
        case .badServerResponse:
            return "Unexpected server response"
        case .httpError(let statusCode):
            return "Server error (Status \(statusCode))"
        case .apiError(let message):
            return "API Error: \(message)"
        case .noValidResponse:
            return "No valid response received"
        }
    }
}