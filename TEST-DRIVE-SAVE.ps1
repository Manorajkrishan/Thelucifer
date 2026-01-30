# Test Drive Link Save Process Manually

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Test Drive Link Save Process" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Login
Write-Host "1. Logging in..." -ForegroundColor Yellow
try {
    $loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 5
    $token = $response.token
    Write-Host "   ✅ Login successful" -ForegroundColor Green
    Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Login failed: $_" -ForegroundColor Red
    exit 1
}

# Test Drive link (use a test file link)
Write-Host "`n2. Testing Drive Link Processing..." -ForegroundColor Yellow
Write-Host "   Enter a Google Drive file link (or press Enter to skip):" -ForegroundColor Cyan
$driveLink = Read-Host

if ([string]::IsNullOrWhiteSpace($driveLink)) {
    Write-Host "   ⚠️  Skipping Drive link test" -ForegroundColor Yellow
} else {
    Write-Host "   Processing: $($driveLink.Substring(0, [Math]::Min(50, $driveLink.Length)))..." -ForegroundColor Gray
    
    try {
        $mlBody = @{
            drive_link = $driveLink
            auto_learn = $true
        } | ConvertTo-Json
        
        $mlResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/drive-link" -Method POST -Body $mlBody -ContentType "application/json" -TimeoutSec 30
        
        if ($mlResponse.success) {
            Write-Host "   ✅ ML Service processed successfully" -ForegroundColor Green
            Write-Host "   Filename: $($mlResponse.result.filename)" -ForegroundColor Cyan
            
            # Now save to Laravel API
            Write-Host "`n3. Saving to Laravel API..." -ForegroundColor Yellow
            
            $filePath = $mlResponse.result.file_path || $mlResponse.result.filename
            $fileExt = ($filePath -split '\.')[-1].ToLower()
            $validTypes = @('pdf', 'docx', 'txt', 'doc')
            $fileType = if ($validTypes -contains $fileExt) { $fileExt } else { 'txt' }
            
            $saveBody = @{
                title = $mlResponse.result.filename
                filename = $mlResponse.result.filename
                file_path = $mlResponse.result.file_path || "downloaded/$($mlResponse.result.filename)"
                file_type = $fileType
                file_size = 0
                status = 'processed'
                metadata = @{
                    source = 'google_drive'
                    drive_link = $driveLink
                }
                extracted_data = $mlResponse.result.extracted_data
            } | ConvertTo-Json -Depth 10
            
            Write-Host "   Sending save request..." -ForegroundColor Gray
            $saveResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method POST -Body $saveBody -ContentType "application/json" -Headers @{Authorization="Bearer $token"} -TimeoutSec 10
            
            if ($saveResponse.success) {
                Write-Host "   ✅ Document saved successfully!" -ForegroundColor Green
                Write-Host "   Document ID: $($saveResponse.data.id)" -ForegroundColor Cyan
                Write-Host "   Title: $($saveResponse.data.title)" -ForegroundColor Cyan
                Write-Host "   Status: $($saveResponse.data.status)" -ForegroundColor Cyan
            } else {
                Write-Host "   ❌ Save failed: $($saveResponse.message)" -ForegroundColor Red
            }
        } else {
            Write-Host "   ❌ ML Service failed: $($mlResponse.error)" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Error: $_" -ForegroundColor Red
        Write-Host "   Full error: $($_.Exception.Message)" -ForegroundColor Gray
    }
}

# Verify saved documents
Write-Host "`n4. Verifying Saved Documents..." -ForegroundColor Yellow
try {
    $docs = Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method GET -Headers @{Authorization="Bearer $token"} -TimeoutSec 5
    if ($docs.success) {
        $docList = $docs.data.data
        Write-Host "   Total documents: $($docList.Count)" -ForegroundColor Cyan
        $driveDocs = $docList | Where-Object { $_.metadata.source -eq 'google_drive' }
        Write-Host "   Drive documents: $($driveDocs.Count)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   ⚠️  Could not verify: $_" -ForegroundColor Yellow
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
