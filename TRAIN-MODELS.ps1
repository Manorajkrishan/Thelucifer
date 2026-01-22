# Train ML Models for SentinelAI X
# This script trains the machine learning models using available datasets

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SentinelAI X - Model Training" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$ML_SERVICE_URL = "http://localhost:5000"

# Check if ML service is running
Write-Host "Checking ML Service..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$ML_SERVICE_URL/health" -Method GET -TimeoutSec 5
    Write-Host "✅ ML Service is running" -ForegroundColor Green
} catch {
    Write-Host "❌ ML Service is not running!" -ForegroundColor Red
    Write-Host "Please start it first: cd backend\ml-service; python app.py" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n1. Training Threat Detection Model" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

try {
    $trainBody = @{
        model_type = "threat_detector"
        dataset = "CICIDS2017"  # or "UNSW-NB15", "NSL-KDD", "EMBER"
        epochs = 10
        batch_size = 32
        validation_split = 0.2
    } | ConvertTo-Json
    
    Write-Host "Starting training with CICIDS2017 dataset..." -ForegroundColor Yellow
    Write-Host "This may take several minutes..." -ForegroundColor Yellow
    
    $response = Invoke-RestMethod -Uri "$ML_SERVICE_URL/api/v1/training/train" -Method POST -Body $trainBody -ContentType "application/json" -TimeoutSec 300
    
    if ($response.success) {
        Write-Host "✅ Threat Detection Model trained successfully!" -ForegroundColor Green
        Write-Host "   Accuracy: $($response.accuracy)" -ForegroundColor Cyan
        Write-Host "   Loss: $($response.loss)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Training failed: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error training model: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Note: Dataset may need to be downloaded first" -ForegroundColor Yellow
}

Write-Host "`n2. Training Document Processing Model" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

try {
    $trainBody = @{
        model_type = "document_processor"
        documents = @()  # Will use existing processed documents
        epochs = 5
    } | ConvertTo-Json
    
    Write-Host "Training on existing documents..." -ForegroundColor Yellow
    
    $response = Invoke-RestMethod -Uri "$ML_SERVICE_URL/api/v1/training/train" -Method POST -Body $trainBody -ContentType "application/json" -TimeoutSec 180
    
    if ($response.success) {
        Write-Host "✅ Document Processing Model trained successfully!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Training skipped: $($response.message)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Training skipped: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n3. Downloading Datasets" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Gray

$datasets = @("CICIDS2017", "UNSW-NB15", "NSL-KDD")

foreach ($dataset in $datasets) {
    Write-Host "Downloading $dataset..." -ForegroundColor Yellow -NoNewline
    try {
        $response = Invoke-RestMethod -Uri "$ML_SERVICE_URL/api/v1/datasets/download" -Method POST -Body (@{dataset_id = $dataset} | ConvertTo-Json) -ContentType "application/json" -TimeoutSec 60
        
        if ($response.success) {
            Write-Host " ✅" -ForegroundColor Green
        } else {
            Write-Host " ⚠️  ($($response.message))" -ForegroundColor Yellow
        }
    } catch {
        Write-Host " ❌" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Training Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Test the models using threat detection API" -ForegroundColor White
Write-Host "2. Process documents to improve learning" -ForegroundColor White
Write-Host "3. Run simulations to validate models" -ForegroundColor White
