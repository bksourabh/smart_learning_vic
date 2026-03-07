import SwiftUI
import WebKit

// MARK: - Shared WebView Resources

/// Shared process pool so all math WKWebViews reuse the same web content process.
/// KaTeX JS is compiled once and cached across all instances.
private let sharedProcessPool = WKProcessPool()

/// Shared configuration avoids re-creating process pool per WebView.
private func makeSharedConfiguration(coordinator: MathWebView.Coordinator) -> WKWebViewConfiguration {
    let config = WKWebViewConfiguration()
    config.processPool = sharedProcessPool
    config.userContentController.add(coordinator, name: "sizeNotify")
    return config
}

// MARK: - Smart Text View (auto-selects native vs WKWebView)

/// Renders text natively when possible, only falls back to WKWebView for math content.
struct SmartTextView: View {
    let content: String
    let font: Font

    init(_ content: String, font: Font = .subheadline) {
        self.content = content
        self.font = font
    }

    private var containsMath: Bool {
        content.contains("$") ||
        content.contains("\\(") ||
        content.contains("\\[")
    }

    var body: some View {
        if containsMath {
            MathContentView(content: content, placeholderFont: font)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            NativeMarkdownView(content: content, font: font)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Math Content View (SwiftUI wrapper with height management)

/// Wraps the WKWebView-based math renderer with dynamic height tracking and shimmer placeholder.
private struct MathContentView: View {
    let content: String
    let placeholderFont: Font
    @State private var contentHeight: CGFloat = 0
    @State private var webViewReady = false

    /// Estimate an initial height from content to avoid layout jumps.
    private var estimatedHeight: CGFloat {
        let lineCount = max(1, content.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count)
        let hasDisplayMath = content.contains("$$") || content.contains("\\[")
        let hasTable = content.contains("|") && content.components(separatedBy: "|").count > 3
        let basePerLine: CGFloat = 26 // ~16px font * 1.6 line height
        var estimate = CGFloat(lineCount) * basePerLine
        if hasDisplayMath { estimate += 40 }
        if hasTable { estimate += CGFloat(lineCount) * 10 }
        return max(30, estimate)
    }

    private var displayHeight: CGFloat {
        let height = contentHeight > 0 ? contentHeight : estimatedHeight
        return height + 8
    }

    private var estimatedLineCount: Int {
        max(1, content.components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // WKWebView always present, fades in when ready
            MathWebView(content: content, contentHeight: $contentHeight)
                .frame(height: displayHeight)
                .opacity(webViewReady ? 1 : 0)

            // Shimmer placeholder until WKWebView loads
            if !webViewReady {
                MathShimmerPlaceholder(lineCount: estimatedLineCount)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: contentHeight)
        .onChange(of: contentHeight) { _, h in
            if h > 0 && !webViewReady {
                withAnimation(.easeIn(duration: 0.15)) {
                    webViewReady = true
                }
            }
        }
    }
}

/// Animated shimmer bars shown while math content loads in WKWebView.
private struct MathShimmerPlaceholder: View {
    let lineCount: Int
    @State private var shimmer = false

    private let widths: [CGFloat] = [0.95, 0.8, 0.9, 0.65]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<min(lineCount, 4), id: \.self) { i in
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(shimmer ? 0.14 : 0.07))
                    .frame(height: 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(x: widths[i % widths.count], anchor: .leading)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
    }
}

// MARK: - Native Markdown View (no WKWebView)

/// Fast native rendering for text without math formulas.
private struct NativeMarkdownView: View {
    let content: String
    let font: Font

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                blockView(block)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private enum Block {
        case heading(Int, String)
        case paragraph(String)
        case listItem(String)
        case orderedItem(Int, String)
    }

    private var blocks: [Block] {
        var result: [Block] = []
        var orderedIndex = 0

        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            if trimmed.hasPrefix("### ") {
                result.append(.heading(3, String(trimmed.dropFirst(4))))
            } else if trimmed.hasPrefix("## ") {
                result.append(.heading(2, String(trimmed.dropFirst(3))))
            } else if trimmed.hasPrefix("# ") {
                result.append(.heading(1, String(trimmed.dropFirst(2))))
            } else if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                result.append(.listItem(String(trimmed.dropFirst(2))))
            } else if let match = trimmed.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                orderedIndex += 1
                result.append(.orderedItem(orderedIndex, String(trimmed[match.upperBound...])))
            } else {
                orderedIndex = 0
                result.append(.paragraph(trimmed))
            }
        }
        return result
    }

    @ViewBuilder
    private func blockView(_ block: Block) -> some View {
        switch block {
        case .heading(let level, let text):
            Text(styledText(text))
                .font(level == 1 ? .title3.bold() : level == 2 ? .headline : .subheadline.bold())
                .fixedSize(horizontal: false, vertical: true)
        case .paragraph(let text):
            Text(styledText(text))
                .font(font)
                .fixedSize(horizontal: false, vertical: true)
        case .listItem(let text):
            HStack(alignment: .top, spacing: 6) {
                Text("\u{2022}")
                    .font(font)
                Text(styledText(text))
                    .font(font)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .orderedItem(let n, let text):
            HStack(alignment: .top, spacing: 6) {
                Text("\(n).")
                    .font(font)
                    .foregroundStyle(.secondary)
                    .frame(width: 20, alignment: .trailing)
                Text(styledText(text))
                    .font(font)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// Convert **bold** and *italic* markdown to AttributedString.
    private func styledText(_ input: String) -> AttributedString {
        // Try the built-in Markdown initializer first (handles bold/italic/code)
        if let attributed = try? AttributedString(markdown: input, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            return attributed
        }
        return AttributedString(input)
    }
}

// MARK: - Math Web View (WKWebView UIViewRepresentable)

struct MathWebView: UIViewRepresentable {
    let content: String
    @Binding var contentHeight: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(heightBinding: $contentHeight)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = makeSharedConfiguration(coordinator: context.coordinator)
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastContent == content { return }
        context.coordinator.lastContent = content
        context.coordinator.measuredHeight = 0

        let isDark = webView.traitCollection.userInterfaceStyle == .dark
        let html = Self.renderHTML(content: content, isDark: isDark)
        webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
    }

    static func renderHTML(content: String, isDark: Bool) -> String {
        let textColor = isDark ? "#ffffff" : "#1a1a2e"
        let secondaryColor = isDark ? "#ababab" : "#64748b"
        let codeBg = isDark ? "#2c2c2e" : "#f1f5f9"
        let tableBorder = isDark ? "#3a3a3c" : "#e2e8f0"

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <link rel="stylesheet" href="KaTeX/katex.min.css">
            <script src="KaTeX/katex.min.js"></script>
            <script src="KaTeX/auto-render.min.js"></script>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: \(textColor);
                    background: transparent;
                    padding: 0 0 2px 0;
                    word-wrap: break-word;
                    overflow-wrap: break-word;
                }
                h1 { font-size: 24px; font-weight: 700; margin: 16px 0 8px; }
                h2 { font-size: 20px; font-weight: 600; margin: 14px 0 6px; }
                h3 { font-size: 18px; font-weight: 600; margin: 20px 0 8px; color: \(textColor); }
                h3:first-child { margin-top: 0; }
                hr { border: none; border-top: 1px solid \(tableBorder); margin: 18px 0; }
                p { margin: 6px 0; }
                ul, ol { padding-left: 24px; margin: 6px 0; }
                li { margin: 3px 0; }
                code {
                    background: \(codeBg);
                    padding: 2px 6px;
                    border-radius: 4px;
                    font-size: 14px;
                }
                pre {
                    background: \(codeBg);
                    padding: 12px;
                    border-radius: 8px;
                    overflow-x: auto;
                    margin: 8px 0;
                }
                blockquote {
                    border-left: 3px solid #3b82f6;
                    padding-left: 12px;
                    margin: 8px 0;
                    color: \(secondaryColor);
                }
                strong { font-weight: 600; }
                .katex-display { margin: 10px 0; overflow-x: auto; }
                .katex { font-size: 1.1em; }
                table { border-collapse: collapse; width: 100%; margin: 8px 0; }
                th, td { border: 1px solid \(tableBorder); padding: 6px 8px; text-align: left; font-size: 14px; }
                th { background: \(codeBg); font-weight: 600; }
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>
                function renderMarkdown(text) {
                    let html = text
                        .replace(/^---$/gm, '<hr>')
                        .replace(/^### (.+)$/gm, '<h3>$1</h3>')
                        .replace(/^## (.+)$/gm, '<h2>$1</h2>')
                        .replace(/^# (.+)$/gm, '<h1>$1</h1>')
                        .replace(/\\*\\*(.+?)\\*\\*/g, '<strong>$1</strong>')
                        .replace(/\\*(.+?)\\*/g, '<em>$1</em>')
                        .replace(/```([\\s\\S]*?)```/g, '<pre><code>$1</code></pre>')
                        .replace(/`(.+?)`/g, '<code>$1</code>')
                        .replace(/^[\\-\\*] (.+)$/gm, '<li>$1</li>')
                        .replace(/^\\d+\\. (.+)$/gm, '<li>$1</li>')
                        .replace(/\\n\\n/g, '</p><p>')
                        .replace(/\\n/g, '<br>');
                    html = html.replace(/(<li>.*<\\/li>)/gs, '<ul>$1</ul>');
                    return '<p>' + html + '</p>';
                }

                const content = \(Self.jsonEscape(content));
                document.getElementById('content').innerHTML = renderMarkdown(content);

                if (typeof renderMathInElement !== 'undefined') {
                    renderMathInElement(document.getElementById('content'), {
                        delimiters: [
                            {left: '$$', right: '$$', display: true},
                            {left: '$', right: '$', display: false},
                            {left: '\\\\(', right: '\\\\)', display: false},
                            {left: '\\\\[', right: '\\\\]', display: true}
                        ],
                        throwOnError: false
                    });
                }

                // Debounced height notification — collapses rapid changes into one update
                let maxH = 0;
                let pending = null;
                function notifyHeight() {
                    const h = Math.max(
                        document.body.scrollHeight,
                        document.body.offsetHeight,
                        document.documentElement.scrollHeight
                    );
                    if (h > maxH) {
                        maxH = h;
                        if (pending) clearTimeout(pending);
                        pending = setTimeout(function() {
                            window.webkit.messageHandlers.sizeNotify.postMessage(maxH);
                        }, 60);
                    }
                }
                // Two checks: after initial render, after KaTeX async render
                setTimeout(notifyHeight, 50);
                setTimeout(notifyHeight, 400);
                // MutationObserver catches KaTeX DOM insertions (debounced via notifyHeight)
                new MutationObserver(notifyHeight)
                    .observe(document.body, { childList: true, subtree: true });
            </script>
        </body>
        </html>
        """
    }

    private static func jsonEscape(_ string: String) -> String {
        let data = try? JSONSerialization.data(withJSONObject: string, options: .fragmentsAllowed)
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "\"\""
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var lastContent: String?
        var heightBinding: Binding<CGFloat>
        var measuredHeight: CGFloat = 0

        init(heightBinding: Binding<CGFloat>) {
            self.heightBinding = heightBinding
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Fallback height measurement via JS
            let js = "Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.scrollHeight)"
            webView.evaluateJavaScript(js) { [weak self] result, _ in
                if let height = result as? Double, height > 0 {
                    self?.updateHeight(CGFloat(height))
                }
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let height = message.body as? Double, height > 0 {
                updateHeight(CGFloat(height))
            }
        }

        /// Only grow — never shrink the height to prevent layout flicker.
        private func updateHeight(_ newHeight: CGFloat) {
            guard newHeight > measuredHeight else { return }
            measuredHeight = newHeight
            DispatchQueue.main.async {
                self.heightBinding.wrappedValue = newHeight
            }
        }
    }
}
