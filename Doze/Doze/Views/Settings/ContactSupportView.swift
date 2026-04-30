import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var topic = "General"
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let topics = ["General", "Bug Report", "Feature Request", "Subscription", "Data Export", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Topic") {
                    Picker("Topic", selection: $topic) {
                        ForEach(topics, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                }

                Section("Your Info") {
                    TextField("Name (Optional)", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Message") {
                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") { submitFeedback() }
                        .disabled(!isValid || isSubmitting)
                }
            }
            .alert("Feedback", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("success") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var isValid: Bool {
        !email.isEmpty && email.contains("@") && !message.isEmpty && message.count >= 3
    }

    private func submitFeedback() {
        isSubmitting = true

        let body: [String: Any?] = [
            "topic": topic,
            "name": name.isEmpty ? nil : name,
            "email": email,
            "message": message
        ]

        guard let url = URL(string: ProcessInfo.processInfo.environment["FEEDBACK_BACKEND_URL"] ?? "https://httpbin.org/post") else {
            alertMessage = "Invalid server URL"
            showAlert = true
            isSubmitting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let filteredBody = body.compactMapValues { $0 }
        request.httpBody = try? JSONSerialization.data(withJSONObject: filteredBody)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    alertMessage = "Failed to send: \(error.localizedDescription)"
                } else {
                    alertMessage = "Message sent successfully! We'll get back to you soon."
                }
                showAlert = true
            }
        }.resume()
    }
}
