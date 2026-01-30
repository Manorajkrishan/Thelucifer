<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Threat Alert – SentinelAI X</title>
    <style>
        body { font-family: system-ui, -apple-system, sans-serif; line-height: 1.5; color: #1f2937; background: #f3f4f6; margin: 0; padding: 24px; }
        .container { max-width: 560px; margin: 0 auto; background: #fff; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,.1); overflow: hidden; }
        .header { background: #dc2626; color: #fff; padding: 16px 24px; font-weight: 600; }
        .body { padding: 24px; }
        .meta { margin-bottom: 16px; }
        .meta dt { font-weight: 600; color: #6b7280; font-size: 12px; text-transform: uppercase; margin-bottom: 4px; }
        .meta dd { margin: 0 0 12px 0; }
        .severity-high { color: #dc2626; font-weight: 600; }
        .footer { padding: 16px 24px; font-size: 12px; color: #9ca3af; border-top: 1px solid #e5e7eb; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">High-severity threat detected</div>
        <div class="body">
            <p>A high-severity threat has been recorded in SentinelAI X.</p>
            <dl class="meta">
                <dt>Type</dt>
                <dd>{{ $threat->type }}</dd>
                <dt>Severity</dt>
                <dd class="severity-high">{{ $threat->severity }}/10</dd>
                <dt>Status</dt>
                <dd>{{ $threat->status }}</dd>
                @if($threat->source_ip)
                <dt>Source IP</dt>
                <dd>{{ $threat->source_ip }}</dd>
                @endif
                @if($threat->classification)
                <dt>Classification</dt>
                <dd>{{ $threat->classification }}</dd>
                @endif
                <dt>Description</dt>
                <dd>{{ $threat->description }}</dd>
                <dt>Detected at</dt>
                <dd>{{ $threat->detected_at?->format('Y-m-d H:i:s') ?? '-' }}</dd>
            </dl>
            <p>Review and take action in the Admin Dashboard.</p>
        </div>
        <div class="footer">SentinelAI X – Threat alert. Configure THREAT_ALERT_EMAIL and mail settings in .env.</div>
    </div>
</body>
</html>
