import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isSentByMe {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.isSentByMe ? .trailing : .leading, spacing: 4) {
                if message.isPaymentRequest {
                    paymentRequestBubble
                } else {
                    textBubble
                }

                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundStyle(.lpavSecondaryText)
                    .padding(.horizontal, 4)
            }

            if !message.isSentByMe {
                Spacer(minLength: 60)
            }
        }
    }

    private var textBubble: some View {
        Text(message.content)
            .font(.subheadline)
            .foregroundStyle(message.isSentByMe ? .white : .lpavText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(message.isSentByMe ? .primaryGreen : Color.lpavCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(message.isSentByMe ? Color.clear : .lpavSurface, lineWidth: 1)
            )
    }

    private var paymentRequestBubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(.primaryGreen)
                Text("Payment Request")
                    .font(.caption.bold())
                    .foregroundStyle(.primaryGreen)
            }

            Text(message.content)
                .font(.subheadline)
                .foregroundStyle(.lpavText)

            if let amount = message.paymentAmount {
                HStack {
                    Text("$\(Int(amount).formatted()) MXN")
                        .font(.headline.bold())
                        .foregroundStyle(.primaryGreen)

                    Spacer()

                    if let status = message.paymentStatus {
                        Text(status.capitalized)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(status == "completed" ? .primaryGreen : .primaryGreen)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(12)
        .background(.primaryGreen.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.primaryGreen.opacity(0.3), lineWidth: 1)
        )
    }
}
