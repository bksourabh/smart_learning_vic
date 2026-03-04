import SwiftUI
import WebKit

struct MathTextView: UIViewRepresentable {
    let content: String
    @Binding var dynamicHeight: CGFloat

    init(content: String, dynamicHeight: Binding<CGFloat> = .constant(300)) {
        self.content = content
        self._dynamicHeight = dynamicHeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let isDark = UITraitCollection.current.userInterfaceStyle == .dark
        let html = Self.renderHTML(content: content, isDark: isDark)
        webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
    }

    static func renderHTML(content: String, isDark: Bool) -> String {
        let bgColor = isDark ? "#1c1c1e" : "#ffffff"
        let textColor = isDark ? "#ffffff" : "#1a1a2e"
        let secondaryColor = isDark ? "#ababab" : "#64748b"
        let codeBg = isDark ? "#2c2c2e" : "#f1f5f9"

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
                    background: \(bgColor);
                    padding: 0;
                    word-wrap: break-word;
                    overflow-wrap: break-word;
                }
                h1 { font-size: 24px; font-weight: 700; margin: 16px 0 8px; }
                h2 { font-size: 20px; font-weight: 600; margin: 14px 0 6px; }
                h3 { font-size: 18px; font-weight: 600; margin: 12px 0 6px; }
                p { margin: 8px 0; }
                ul, ol { padding-left: 24px; margin: 8px 0; }
                li { margin: 4px 0; }
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
                .katex-display { margin: 12px 0; overflow-x: auto; }
                .katex { font-size: 1.1em; }
                table { border-collapse: collapse; width: 100%; margin: 8px 0; }
                th, td { border: 1px solid \(isDark ? "#3a3a3c" : "#e2e8f0"); padding: 8px; text-align: left; }
                th { background: \(codeBg); font-weight: 600; }
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>
                function renderMarkdown(text) {
                    // Simple markdown to HTML conversion
                    let html = text
                        // Headers
                        .replace(/^### (.+)$/gm, '<h3>$1</h3>')
                        .replace(/^## (.+)$/gm, '<h2>$1</h2>')
                        .replace(/^# (.+)$/gm, '<h1>$1</h1>')
                        // Bold
                        .replace(/\\*\\*(.+?)\\*\\*/g, '<strong>$1</strong>')
                        // Italic
                        .replace(/\\*(.+?)\\*/g, '<em>$1</em>')
                        // Code blocks
                        .replace(/```([\\s\\S]*?)```/g, '<pre><code>$1</code></pre>')
                        // Inline code
                        .replace(/`(.+?)`/g, '<code>$1</code>')
                        // Unordered lists
                        .replace(/^[\\-\\*] (.+)$/gm, '<li>$1</li>')
                        // Ordered lists
                        .replace(/^\\d+\\. (.+)$/gm, '<li>$1</li>')
                        // Paragraphs
                        .replace(/\\n\\n/g, '</p><p>')
                        // Line breaks
                        .replace(/\\n/g, '<br>');
                    // Wrap list items
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

                // Report height
                setTimeout(function() {
                    const height = document.body.scrollHeight;
                    window.webkit.messageHandlers.heightUpdate.postMessage(height);
                }, 100);
            </script>
        </body>
        </html>
        """
    }

    private static func jsonEscape(_ string: String) -> String {
        let data = try? JSONSerialization.data(withJSONObject: string, options: [])
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "\"\""
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: MathTextView

        init(_ parent: MathTextView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.scrollHeight") { [weak self] result, _ in
                if let height = result as? CGFloat {
                    DispatchQueue.main.async {
                        self?.parent.dynamicHeight = height
                    }
                }
            }
        }
    }
}
