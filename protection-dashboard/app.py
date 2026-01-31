"""
SentinelAI X - Protection System Demo Dashboard
Minimal web UI to show that the real protection system is working.
Run: python app.py  then open http://localhost:5050
"""

import sys
import os

# Add project root so we can import demo_protection and sentinelai_protection
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from flask import Flask, render_template_string, jsonify

app = Flask(__name__)


HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SentinelAI X - Protection Demo</title>
  <style>
    * { box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', system-ui, sans-serif;
      max-width: 720px;
      margin: 0 auto;
      padding: 24px;
      background: #0d1117;
      color: #e6edf3;
      min-height: 100vh;
    }
    h1 { font-size: 1.5rem; margin-bottom: 0.5rem; color: #58a6ff; }
    .sub { color: #8b949e; font-size: 0.9rem; margin-bottom: 24px; }
    .btn {
      display: inline-block;
      padding: 10px 20px;
      background: #238636;
      color: #fff;
      border: none;
      border-radius: 6px;
      font-size: 1rem;
      cursor: pointer;
    }
    .btn:hover { background: #2ea043; }
    .btn:disabled { background: #30363d; cursor: not-allowed; }
    #results { margin-top: 24px; }
    .item {
      padding: 12px 16px;
      margin-bottom: 8px;
      border-radius: 8px;
      border-left: 4px solid #30363d;
    }
    .item.pass { border-left-color: #3fb950; background: rgba(63, 185, 80, 0.1); }
    .item.fail { border-left-color: #f85149; background: rgba(248, 81, 73, 0.1); }
    .item .name { font-weight: 600; margin-bottom: 4px; }
    .item .detail { font-size: 0.85rem; color: #8b949e; }
    .item .proof { font-size: 0.8rem; color: #6e7681; margin-top: 4px; }
    .summary {
      margin-top: 16px;
      padding: 12px 16px;
      background: #161b22;
      border-radius: 8px;
      font-weight: 600;
    }
    .summary.ok { color: #3fb950; }
    .summary.warn { color: #d29922; }
    .loading { color: #8b949e; }
  </style>
</head>
<body>
  <h1>SentinelAI X - Real Protection System</h1>
  <p class="sub">Demo dashboard: prove each component is working (no frontend in main app)</p>

  <button class="btn" id="runDemo">Run Demo</button>

  <div id="results"></div>

  <script>
    const resultsEl = document.getElementById('results');
    const btn = document.getElementById('runDemo');

    document.getElementById('runDemo').onclick = async function () {
      btn.disabled = true;
      resultsEl.innerHTML = '<p class="loading">Running demo tests...</p>';
      try {
        const r = await fetch('/api/demo');
        const data = await r.json();
        let html = '';
        (data.results || []).forEach(function (item) {
          const cls = item.passed ? 'pass' : 'fail';
          const status = item.passed ? 'PASS' : 'FAIL';
          html += '<div class="item ' + cls + '">';
          html += '<div class="name">[' + status + '] ' + (item.name || '') + '</div>';
          html += '<div class="detail">' + (item.detail || '') + '</div>';
          html += '<div class="proof">' + (item.proof || '') + '</div>';
          html += '</div>';
        });
        const passed = (data.results || []).filter(function (x) { return x.passed; }).length;
        const total = (data.results || []).length;
        const summaryCls = passed === total ? 'ok' : 'warn';
        html += '<div class="summary ' + summaryCls + '">Result: ' + passed + ' / ' + total + ' components working</div>';
        resultsEl.innerHTML = html;
      } catch (e) {
        resultsEl.innerHTML = '<p class="item fail">Error: ' + e.message + '</p>';
      }
      btn.disabled = false;
    };
  </script>
</body>
</html>
"""


@app.route("/")
def index():
    return render_template_string(HTML)


@app.route("/api/demo")
def api_demo():
    try:
        from demo_protection import run_all_demos
        results = run_all_demos()
        return jsonify({"ok": True, "results": results})
    except Exception as e:
        return jsonify({"ok": False, "error": str(e), "results": []}), 500


@app.route("/api/status")
def api_status():
    """Quick status: which components are available (no heavy imports)."""
    status = {}
    try:
        import importlib.util
        spec = importlib.util.spec_from_file_location("sentinelai_protection", os.path.join(ROOT, "sentinelai_protection.py"))
        mod = importlib.util.module_from_spec(spec)
        # Don't load full module (has side effects). Just report dashboard is up.
        status["dashboard"] = "ok"
        status["protection_script"] = os.path.exists(os.path.join(ROOT, "sentinelai_protection.py"))
    except Exception as e:
        status["error"] = str(e)
    return jsonify(status)


if __name__ == "__main__":
    print("\nSentinelAI X - Protection Demo Dashboard")
    print("Open in browser: http://localhost:5050")
    print("Click 'Run Demo' to prove each component works.\n")
    app.run(host="0.0.0.0", port=5050, debug=False)
