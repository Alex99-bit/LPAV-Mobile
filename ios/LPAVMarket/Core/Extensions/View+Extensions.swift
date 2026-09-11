import SwiftUI

extension View {
    func lpavCardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    func lpavCardStroke() -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
    }

    @ViewBuilder
    func hiddenIf(_ condition: Bool) -> some View {
        if condition {
            self.hidden()
        } else {
            self
        }
    }

    @ViewBuilder
    func redactedIf(_ condition: Bool) -> some View {
        if condition {
            self.redacted(reason: .placeholder)
        } else {
            self
        }
    }

    func hapticImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }

    func hapticNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    func onFirstAppear(perform action: @escaping () async -> Void) -> some View {
        modifier(FirstAppearModifier(action: action))
    }

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func shimmering(active: Bool = true) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}

struct FirstAppearModifier: ViewModifier {
    let action: () async -> Void
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .task {
                guard !hasAppeared else { return }
                hasAppeared = true
                await action()
            }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct ShimmerModifier: ViewModifier {
    let active: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.5),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: active ? 300 : -300)
                .animation(
                    .linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: phase
                )
                .onAppear {
                    if active { phase = 1 }
                }
            )
            .mask(content)
    }
}

extension View {
    @inlinable
    func reverseMask<Mask: View>(@ViewBuilder _ mask: () -> Mask) -> some View {
        self.mask(
            ZStack {
                Rectangle()
                mask()
                    .blendMode(.destinationOut)
            }
        )
    }
}
