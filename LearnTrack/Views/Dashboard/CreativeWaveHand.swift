import SwiftUI

struct CreativeWaveHand: View {
    @State private var wave = false
    var body: some View {
        ZStack {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 32))
                .foregroundColor(AppColors.primary)
                .rotationEffect(.degrees(wave ? 18 : -8), anchor: .bottomLeading)
                .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: wave)
        }
        .onAppear { wave = true }
        .accessibilityLabel("Waving hand")
    }
}
