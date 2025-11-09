//
//  AIAssistantView.swift
//  TechAssist2
//
//  Lightweight, on-device assistant that references the incident playbook.
//

import SwiftUI

struct AIAssistantView: View {
    let workOrder: WorkOrder
    let document: ServerIssueDocument?
    
    @Environment(\.dismiss) private var dismiss
    @State private var inputText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    
    struct ChatMessage: Identifiable, Hashable {
        enum Role {
            case user
            case assistant
        }
        
        let id = UUID()
        let role: Role
        let text: String
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(messages) { message in
                                messageBubble(for: message)
                                    .id(message.id)
                            }
                            
                            if isTyping {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accentPrimary))
                                    Text("Assistant is thinking...")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 18)
                    }
                    .background(AppTheme.backgroundPrimary)
                    .onChange(of: messages.count) { _ in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                inputBar
                    .padding()
                    .background(AppTheme.backgroundSecondary)
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: setupInitialContext)
        }
    }
    
    private func setupInitialContext() {
        let greeting = ChatMessage(
            role: .assistant,
            text: initialMessage()
        )
        messages = [greeting]
    }
    
    private func initialMessage() -> String {
        if let document = document {
            return """
            I’m ready to help with **\(document.title)** for work order **\(workOrder.taskID)**. Ask me about safety precautions, troubleshooting steps, or how to escalate this incident.
            """
        } else {
            return """
            I’m ready to help with work order **\(workOrder.taskID)**. Ask about safety, next steps, or escalation guidance.
            """
        }
    }
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask the assistant...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(AppTheme.backgroundPrimary)
                .cornerRadius(12)
                .lineLimit(1...4)
            
            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(inputText.isEmpty ? AppTheme.textSecondary : AppTheme.accentPrimary)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTyping)
        }
    }
    
    private func messageBubble(for message: ChatMessage) -> some View {
        HStack {
            if message.role == .assistant {
                bubble(for: message, color: AppTheme.backgroundSecondary, foreground: AppTheme.textPrimary, alignment: .leading)
                Spacer()
            } else {
                Spacer()
                bubble(for: message, color: AppTheme.accentPrimary, foreground: .white, alignment: .trailing)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func bubble(for message: ChatMessage, color: Color, foreground: Color, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(attributedMessage(from: message.text))
                .foregroundColor(foreground)
                .font(.system(size: 14))
                .padding(14)
                .background(color)
                .cornerRadius(16)
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: alignment == .leading ? .leading : .trailing)
    }
    
    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, text: trimmed)
        messages.append(userMessage)
        inputText = ""
        isTyping = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.35) {
            let replyText = generateResponse(for: trimmed)
            let reply = ChatMessage(role: .assistant, text: replyText)
            DispatchQueue.main.async {
                messages.append(reply)
                isTyping = false
            }
        }
    }
    
    private func generateResponse(for input: String) -> String {
        let lower = input.lowercased()
        let doc = document
        
        if lower.contains("safety") {
            if let safety = doc?.safetyNotes {
                return "Safety checklist:\n• " + safety.joined(separator: "\n• ")
            }
            return "Wear ESD protection, power down equipment before servicing, and follow local data center safety policy."
        }
        
        if lower.contains("tools") || lower.contains("gear") {
            if let tools = doc?.recommendedTools {
                return "Recommended tools for this task:\n• " + tools.joined(separator: "\n• ")
            }
            return "Gather the standard field kit (ESD strap, flashlight, torque driver) before proceeding."
        }
        
        if lower.contains("validate") || lower.contains("verification") {
            if let validation = doc?.validationSteps {
                return "Validation steps:\n" + validation.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
            }
            return "Validate that the system boots, services are restored, and monitoring clears the original alert."
        }
        
        if lower.contains("escalate") || lower.contains("supervisor") {
            if let escalation = doc?.escalationGuidance {
                return escalation
            }
            return "Escalate to your shift supervisor if the incident cannot be cleared within the SLA or if additional authorization is required."
        }
        
        if lower.contains("next") || lower.contains("step") || lower.contains("fix") {
            if let steps = doc?.resolutionSteps {
                return "Next recommended steps:\n" + steps.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
            }
        }
        
        if let doc = doc {
            return """
            Here's a quick summary for \(doc.title):
            • Primary symptoms: \(doc.symptoms.prefix(2).joined(separator: ", "))
            • Immediate actions: \(doc.immediateActions.prefix(2).joined(separator: "; "))
            • Estimated time: \(doc.estimatedTimeMinutes) minutes
            Ask about safety, tools, validation, or escalation for more detail.
            """
        } else {
            return """
            I'm monitoring work order \(workOrder.taskID). Ask about next steps, safety guidance, or when to escalate.
            """
        }
    }
    
    private func attributedMessage(from text: String) -> AttributedString {
        if let attributed = try? AttributedString(markdown: text) {
            return attributed
        }
        return AttributedString(text)
    }
}


