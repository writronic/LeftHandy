import SwiftUI

struct AboutWindowView: View {
    @State private var aboutWindow: NSWindow?

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var yearString: String {
        String(Calendar.current.component(.year, from: Date()))
    }

    var body: some View {
        VStack(spacing: 14) {
            if let appIcon = NSApp.applicationIconImage {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            }

            Text(AppConstants.appName)
                .font(.system(size: 24, weight: .bold, design: .rounded))

            VStack(spacing: 6) {
                Text("Version \(appVersion)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                Text("Left-handed cursor and mouse button support for macOS")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()
                .frame(height: 10)

            VStack(spacing: 6) {
                Text("Made with ❤️")
                    .font(.system(size: 14, weight: .semibold))

                Text("Copyright © \(yearString) Writronic. All rights reserved.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Link("Visit Website", destination: URL(string: "https://writronic.com")!)
                    .font(.system(size: 12))
                    .padding(.top, 1)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
            }

            Spacer()
                .frame(height: 5)

            Text("GPL-3.0")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 40)
        .fixedSize()
        .background(AboutWindowAccessor(window: $aboutWindow))
        .overlay {
            Button("") { aboutWindow?.close() }
                .keyboardShortcut(.cancelAction)
                .frame(width: 0, height: 0)
                .opacity(0)
                .allowsHitTesting(false)
        }
    }
}

private struct AboutWindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        self.window = nsView.window
    }
}
