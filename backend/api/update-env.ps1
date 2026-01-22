$envFile = ".env"
$content = Get-Content $envFile -Raw

$content = $content -replace "APP_NAME=Laravel", "APP_NAME=SentinelAI"
$content = $content -replace "APP_URL=http://localhost", "APP_URL=http://localhost:8000"
$content = $content -replace "DB_CONNECTION=mysql", "DB_CONNECTION=pgsql"
$content = $content -replace "DB_PORT=3306", "DB_PORT=5432"
$content = $content -replace "DB_DATABASE=laravel", "DB_DATABASE=sentinelai"
$content = $content -replace "DB_USERNAME=root", "DB_USERNAME=sentinelai_user"
$content = $content -replace "DB_PASSWORD=", "DB_PASSWORD=sentinelai_password"

if ($content -notmatch "NEO4J_URI") {
    $content += "`n`n# Neo4j Configuration`nNEO4J_URI=bolt://127.0.0.1:7687`nNEO4J_USER=neo4j`nNEO4J_PASSWORD=sentinelai_password`n`n# ML Service`nML_SERVICE_URL=http://localhost:5000`n`n# Real-time Service`nREALTIME_SERVICE_URL=http://localhost:3001"
}

[System.IO.File]::WriteAllText($envFile, $content, [System.Text.Encoding]::UTF8)
Write-Host ".env file updated!" -ForegroundColor Green
