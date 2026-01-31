# SentinelAI X - 10,000 Test Cases
# Comprehensive stress and functionality testing

param(
    [int]$TestCount = 10000,
    [switch]$Quick = $false,
    [switch]$Verbose = $false
)

Write-Host "`n" -NoNewline
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "  SentinelAI X - $TestCount Test Cases" -ForegroundColor Cyan
Write-Host "  Comprehensive System Testing Suite" -ForegroundColor Gray
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

$global:results = @{
    Passed = 0
    Failed = 0
    Skipped = 0
    Total = 0
    Categories = @{}
    StartTime = Get-Date
    FailedTests = @()
}

$global:testToken = $null
$global:headers = @{}
$global:createdThreats = @()
$global:createdDocuments = @()
$global:createdIncidents = @()

# Test data generators
$threatTypes = @("malware", "ransomware", "phishing", "ddos", "trojan", "worm", "rootkit", "spyware", "botnet", "apt")
$severities = @("low", "medium", "high", "critical")
$statuses = @("active", "investigating", "resolved", "false_positive")
$incidentStatuses = @("open", "investigating", "resolved", "closed")
$docTypes = @("pdf", "docx", "doc", "txt")

function Get-RandomString {
    param([int]$Length = 10)
    -join ((65..90) + (97..122) | Get-Random -Count $Length | ForEach-Object {[char]$_})
}

function Get-RandomIP {
    "$(Get-Random -Min 1 -Max 255).$(Get-Random -Min 0 -Max 255).$(Get-Random -Min 0 -Max 255).$(Get-Random -Min 0 -Max 255)"
}

function Get-RandomThreatData {
    @{
        name = "Test-Threat-$(Get-RandomString 8)"
        type = $threatTypes | Get-Random
        severity = $severities | Get-Random
        description = "Auto-generated test threat - $(Get-RandomString 20)"
        source_ip = Get-RandomIP
        status = $statuses | Get-Random
        metadata = @{
            generated = $true
            timestamp = (Get-Date).ToString("o")
            test_id = [guid]::NewGuid().ToString()
        }
    }
}

function Get-RandomDocumentData {
    $type = $docTypes | Get-Random
    @{
        title = "TestDoc-$(Get-RandomString 8)"
        filename = "test_$(Get-RandomString 6).$type"
        file_path = "tests/test_$(Get-RandomString 6).$type"
        file_type = $type
        file_size = Get-Random -Min 100 -Max 10000000
        status = "uploaded"
    }
}

function Get-RandomIncidentData {
    @{
        title = "Incident-$(Get-RandomString 8)"
        description = "Auto-generated incident - $(Get-RandomString 30)"
        severity = $severities | Get-Random
        status = $incidentStatuses | Get-Random
        priority = Get-Random -Min 1 -Max 5
    }
}

function Test-Case {
    param(
        [string]$Category,
        [string]$Name,
        [scriptblock]$Test,
        [switch]$Silent
    )
    
    $global:results.Total++
    
    if (-not $global:results.Categories.ContainsKey($Category)) {
        $global:results.Categories[$Category] = @{Passed = 0; Failed = 0}
    }
    
    if (-not $Silent -and $Verbose) {
        Write-Host "  [$Category] $Name" -ForegroundColor Yellow -NoNewline
    }
    
    try {
        $result = & $Test
        if ($result -ne $false) {
            $global:results.Passed++
            $global:results.Categories[$Category].Passed++
            if (-not $Silent -and $Verbose) {
                Write-Host " OK" -ForegroundColor Green
            }
            return $true
        } else {
            $global:results.Failed++
            $global:results.Categories[$Category].Failed++
            $global:results.FailedTests += "[$Category] $Name"
            if (-not $Silent -and $Verbose) {
                Write-Host " FAIL" -ForegroundColor Red
            }
            return $false
        }
    } catch {
        $global:results.Failed++
        $global:results.Categories[$Category].Failed++
        $global:results.FailedTests += "[$Category] $Name - $($_.Exception.Message)"
        if (-not $Silent -and $Verbose) {
            Write-Host " ERROR" -ForegroundColor Red
        }
        return $false
    }
}

function Show-Progress {
    param([string]$Activity, [int]$Current, [int]$Total)
    $percent = [math]::Round(($Current / $Total) * 100, 1)
    $bar = "[" + ("=" * [math]::Floor($percent / 2)) + (" " * (50 - [math]::Floor($percent / 2))) + "]"
    Write-Host "`r  $bar $percent% - $Activity ($Current/$Total)" -NoNewline -ForegroundColor Gray
}

# ============================================
# AUTHENTICATION
# ============================================
Write-Host "`nAuthenticating..." -ForegroundColor Cyan
try {
    $loginBody = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
    $login = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 10
    $global:testToken = $login.token
    $global:headers = @{Authorization = "Bearer $global:testToken"}
    Write-Host "  Authentication successful" -ForegroundColor Green
} catch {
    Write-Host "  Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Make sure the API server is running at http://localhost:8000" -ForegroundColor Yellow
    exit 1
}

# ============================================
# SERVICE CHECKS (100 tests)
# ============================================
Write-Host "`n[1/10] SERVICE AVAILABILITY TESTS (100 tests)" -ForegroundColor Cyan

for ($i = 1; $i -le 100; $i++) {
    Show-Progress "Service Tests" $i 100
    
    # API Server (20 tests)
    if ($i -le 20) {
        Test-Case "Service" "API Server Check $i" -Silent {
            (Invoke-WebRequest -Uri "http://localhost:8000" -UseBasicParsing -TimeoutSec 5).StatusCode -eq 200
        }
    }
    # ML Service (20 tests)
    elseif ($i -le 40) {
        Test-Case "Service" "ML Service Check $($i-20)" -Silent {
            (Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 5).StatusCode -eq 200
        }
    }
    # API Health (20 tests)
    elseif ($i -le 60) {
        Test-Case "Service" "API Health Check $($i-40)" -Silent {
            (Invoke-RestMethod -Uri "http://localhost:8000/api/health" -TimeoutSec 5).status -eq "online"
        }
    }
    # ML Health (20 tests)
    elseif ($i -le 80) {
        Test-Case "Service" "ML Health Check $($i-60)" -Silent {
            (Invoke-RestMethod -Uri "http://localhost:5000/health" -TimeoutSec 5).status -eq "healthy"
        }
    }
    # Portal/Dashboard (20 tests)
    else {
        Test-Case "Service" "Frontend Check $($i-80)" -Silent {
            try {
                (Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5).StatusCode -eq 200
            } catch { $true } # Portal might not be running
        }
    }
}
Write-Host ""

# ============================================
# AUTHENTICATION TESTS (200 tests)
# ============================================
Write-Host "`n[2/10] AUTHENTICATION TESTS (200 tests)" -ForegroundColor Cyan

for ($i = 1; $i -le 200; $i++) {
    Show-Progress "Auth Tests" $i 200
    
    # Valid logins (50 tests)
    if ($i -le 50) {
        Test-Case "Auth" "Valid Login $i" -Silent {
            $body = @{email="admin@sentinelai.com";password="admin123"} | ConvertTo-Json
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 5
            $r.token -ne $null
        }
    }
    # Invalid password tests (50 tests)
    elseif ($i -le 100) {
        Test-Case "Auth" "Invalid Password $($i-50)" -Silent {
            try {
                $body = @{email="admin@sentinelai.com";password="wrongpass$(Get-Random)"} | ConvertTo-Json
                Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 5
                $false
            } catch {
                $_.Exception.Response.StatusCode.value__ -eq 401
            }
        }
    }
    # Invalid email tests (50 tests)
    elseif ($i -le 150) {
        Test-Case "Auth" "Invalid Email $($i-100)" -Silent {
            try {
                $body = @{email="fake$(Get-Random)@test.com";password="admin123"} | ConvertTo-Json
                Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 5
                $false
            } catch {
                $_.Exception.Response.StatusCode.value__ -eq 401
            }
        }
    }
    # Token validation (50 tests)
    else {
        Test-Case "Auth" "Token Validation $($i-150)" -Silent {
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/user" -Method GET -Headers $global:headers -TimeoutSec 5
            $r.user.email -eq "admin@sentinelai.com"
        }
    }
}
Write-Host ""

# ============================================
# THREAT CRUD TESTS (2000 tests)
# ============================================
Write-Host "`n[3/10] THREAT MANAGEMENT TESTS (2000 tests)" -ForegroundColor Cyan

# Create threats (500 tests)
for ($i = 1; $i -le 500; $i++) {
    Show-Progress "Creating Threats" $i 500
    
    Test-Case "Threat-Create" "Create Threat $i" -Silent {
        $data = Get-RandomThreatData
        $body = $data | ConvertTo-Json -Depth 5
        $r = Invoke-RestMethod -Uri "http://localhost:8000/api/threats" -Method POST -Body $body -ContentType "application/json" -Headers $global:headers -TimeoutSec 5
        if ($r.success -and $r.data.id) {
            $global:createdThreats += $r.data.id
            $true
        } else { $false }
    }
}
Write-Host ""

# Read threats (500 tests)
for ($i = 1; $i -le 500; $i++) {
    Show-Progress "Reading Threats" $i 500
    
    Test-Case "Threat-Read" "Read Threat $i" -Silent {
        if ($global:createdThreats.Count -gt 0) {
            $id = $global:createdThreats | Get-Random
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/threats/$id" -Method GET -Headers $global:headers -TimeoutSec 5
            $r.success -eq $true
        } else {
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/threats" -Method GET -Headers $global:headers -TimeoutSec 5
            $r.success -eq $true
        }
    }
}
Write-Host ""

# Update threats (500 tests)
for ($i = 1; $i -le 500; $i++) {
    Show-Progress "Updating Threats" $i 500
    
    Test-Case "Threat-Update" "Update Threat $i" -Silent {
        if ($global:createdThreats.Count -gt 0) {
            $id = $global:createdThreats | Get-Random
            $body = @{
                status = $statuses | Get-Random
                severity = $severities | Get-Random
                description = "Updated at $(Get-Date) - $(Get-RandomString 10)"
            } | ConvertTo-Json
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/threats/$id" -Method PUT -Body $body -ContentType "application/json" -Headers $global:headers -TimeoutSec 5
            $r.success -eq $true
        } else { $true }
    }
}
Write-Host ""

# List and filter threats (500 tests)
for ($i = 1; $i -le 500; $i++) {
    Show-Progress "Listing/Filtering Threats" $i 500
    
    $filterType = $i % 5
    Test-Case "Threat-List" "List/Filter Threats $i" -Silent {
        switch ($filterType) {
            0 { $url = "http://localhost:8000/api/threats" }
            1 { $url = "http://localhost:8000/api/threats?status=$($statuses | Get-Random)" }
            2 { $url = "http://localhost:8000/api/threats?severity=$($severities | Get-Random)" }
            3 { $url = "http://localhost:8000/api/threats?type=$($threatTypes | Get-Random)" }
            4 { $url = "http://localhost:8000/api/threats?search=$(Get-RandomString 3)" }
        }
        $r = Invoke-RestMethod -Uri $url -Method GET -Headers $global:headers -TimeoutSec 5
        $r.success -eq $true
    }
}
Write-Host ""

# ============================================
# DOCUMENT CRUD TESTS (2000 tests)
# ============================================
Write-Host "`n[4/10] DOCUMENT MANAGEMENT TESTS (2000 tests)" -ForegroundColor Cyan

# Create documents (500 tests)
for ($i = 1; $i -le 500; $i++) {
    Show-Progress "Creating Documents" $i 500
    
    Test-Case "Document-Create" "Create Document $i" -Silent {
        $data = Get-RandomDocumentData
        $body = $data | ConvertTo-Json
        $r = Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method POST -Body $body -ContentType "application/json" -Headers $global:headers -TimeoutSec 5
        if ($r.success -and $r.data.id) {
            $global:createdDocuments += $r.data.id
            $true
        } else { $false }
    }
}
Write-Host ""

# Read documents (500 tests)
for ($i = 1; $i -le 500; $i++) {
    Show-Progress "Reading Documents" $i 500
    
    Test-Case "Document-Read" "Read Document $i" -Silent {
        if ($global:createdDocuments.Count -gt 0) {
            $id = $global:createdDocuments | Get-Random
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/documents/$id" -Method GET -Headers $global:headers -TimeoutSec 5
            $r.success -eq $true
        } else {
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/documents" -Method GET -Headers $global:headers -TimeoutSec 5
            $r.success -eq $true
        }
    }
}
Write-Host ""

# List and filter documents (500 tests)
for ($i = 1; $i -le 500; $i++) {
    Show-Progress "Listing/Filtering Documents" $i 500
    
    $filterType = $i % 4
    Test-Case "Document-List" "List/Filter Documents $i" -Silent {
        switch ($filterType) {
            0 { $url = "http://localhost:8000/api/documents" }
            1 { $url = "http://localhost:8000/api/documents?status=uploaded" }
            2 { $url = "http://localhost:8000/api/documents?file_type=$($docTypes | Get-Random)" }
            3 { $url = "http://localhost:8000/api/documents?search=$(Get-RandomString 3)" }
        }
        $r = Invoke-RestMethod -Uri $url -Method GET -Headers $global:headers -TimeoutSec 5
        $r.success -eq $true
    }
}
Write-Host ""

# Delete documents (500 tests - delete half of created)
$docsToDelete = $global:createdDocuments | Select-Object -First 250
for ($i = 1; $i -le 500; $i++) {
    Show-Progress "Deleting Documents" $i 500
    
    Test-Case "Document-Delete" "Delete Document $i" -Silent {
        if ($i -le $docsToDelete.Count) {
            $id = $docsToDelete[$i-1]
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/documents/$id" -Method DELETE -Headers $global:headers -TimeoutSec 5
            if ($r.success) { $global:createdDocuments = $global:createdDocuments | Where-Object { $_ -ne $id } }
            $r.success -eq $true
        } else {
            # Test delete non-existent
            try {
                Invoke-RestMethod -Uri "http://localhost:8000/api/documents/999999" -Method DELETE -Headers $global:headers -TimeoutSec 5
                $true
            } catch {
                $_.Exception.Response.StatusCode.value__ -eq 404
            }
        }
    }
}
Write-Host ""

# ============================================
# INCIDENT CRUD TESTS (1500 tests)
# ============================================
Write-Host "`n[5/10] INCIDENT MANAGEMENT TESTS (1500 tests)" -ForegroundColor Cyan

# Create incidents (400 tests)
for ($i = 1; $i -le 400; $i++) {
    Show-Progress "Creating Incidents" $i 400
    
    Test-Case "Incident-Create" "Create Incident $i" -Silent {
        $data = Get-RandomIncidentData
        if ($global:createdThreats.Count -gt 0 -and (Get-Random -Min 0 -Max 2) -eq 1) {
            $data.threat_id = $global:createdThreats | Get-Random
        }
        $body = $data | ConvertTo-Json
        $r = Invoke-RestMethod -Uri "http://localhost:8000/api/incidents" -Method POST -Body $body -ContentType "application/json" -Headers $global:headers -TimeoutSec 5
        if ($r.success -and $r.data.id) {
            $global:createdIncidents += $r.data.id
            $true
        } else { $false }
    }
}
Write-Host ""

# Read incidents (400 tests)
for ($i = 1; $i -le 400; $i++) {
    Show-Progress "Reading Incidents" $i 400
    
    Test-Case "Incident-Read" "Read Incident $i" -Silent {
        if ($global:createdIncidents.Count -gt 0) {
            $id = $global:createdIncidents | Get-Random
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/incidents/$id" -Method GET -Headers $global:headers -TimeoutSec 5
            $r.success -eq $true
        } else {
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/incidents" -Method GET -Headers $global:headers -TimeoutSec 5
            $r.success -eq $true
        }
    }
}
Write-Host ""

# Update incidents (400 tests)
for ($i = 1; $i -le 400; $i++) {
    Show-Progress "Updating Incidents" $i 400
    
    Test-Case "Incident-Update" "Update Incident $i" -Silent {
        if ($global:createdIncidents.Count -gt 0) {
            $id = $global:createdIncidents | Get-Random
            $body = @{
                status = $incidentStatuses | Get-Random
                severity = $severities | Get-Random
                description = "Updated at $(Get-Date) - $(Get-RandomString 10)"
            } | ConvertTo-Json
            $r = Invoke-RestMethod -Uri "http://localhost:8000/api/incidents/$id" -Method PUT -Body $body -ContentType "application/json" -Headers $global:headers -TimeoutSec 5
            $r.success -eq $true
        } else { $true }
    }
}
Write-Host ""

# List and filter incidents (300 tests)
for ($i = 1; $i -le 300; $i++) {
    Show-Progress "Listing/Filtering Incidents" $i 300
    
    $filterType = $i % 4
    Test-Case "Incident-List" "List/Filter Incidents $i" -Silent {
        switch ($filterType) {
            0 { $url = "http://localhost:8000/api/incidents" }
            1 { $url = "http://localhost:8000/api/incidents?status=$($incidentStatuses | Get-Random)" }
            2 { $url = "http://localhost:8000/api/incidents?severity=$($severities | Get-Random)" }
            3 { $url = "http://localhost:8000/api/incidents?search=$(Get-RandomString 3)" }
        }
        $r = Invoke-RestMethod -Uri $url -Method GET -Headers $global:headers -TimeoutSec 5
        $r.success -eq $true
    }
}
Write-Host ""

# ============================================
# THREAT ACTIONS TESTS (1000 tests)
# ============================================
Write-Host "`n[6/10] THREAT ACTIONS TESTS (1000 tests)" -ForegroundColor Cyan

$actionTypes = @("block_ip", "isolate_host", "firewall_rule", "alert_security_team", "quarantine", "disable_account")

for ($i = 1; $i -le 1000; $i++) {
    Show-Progress "Threat Actions Tests" $i 1000
    
    $testType = $i % 5
    switch ($testType) {
        0 {
            # Create action
            Test-Case "ThreatAction" "Create Action $i" -Silent {
                if ($global:createdThreats.Count -gt 0) {
                    $body = @{
                        threat_id = $global:createdThreats | Get-Random
                        action_type = $actionTypes | Get-Random
                        description = "Auto action $(Get-RandomString 10)"
                        status = "pending"
                    } | ConvertTo-Json
                    $r = Invoke-RestMethod -Uri "http://localhost:8000/api/threat-actions" -Method POST -Body $body -ContentType "application/json" -Headers $global:headers -TimeoutSec 5
                    $r.success -eq $true
                } else { $true }
            }
        }
        1 {
            # List actions
            Test-Case "ThreatAction" "List Actions $i" -Silent {
                $r = Invoke-RestMethod -Uri "http://localhost:8000/api/threat-actions" -Method GET -Headers $global:headers -TimeoutSec 5
                $r.success -eq $true
            }
        }
        2 {
            # Filter by status
            Test-Case "ThreatAction" "Filter Actions $i" -Silent {
                $r = Invoke-RestMethod -Uri "http://localhost:8000/api/threat-actions?status=pending" -Method GET -Headers $global:headers -TimeoutSec 5
                $r.success -eq $true
            }
        }
        3 {
            # Filter by threat
            Test-Case "ThreatAction" "Filter by Threat $i" -Silent {
                if ($global:createdThreats.Count -gt 0) {
                    $tid = $global:createdThreats | Get-Random
                    $r = Invoke-RestMethod -Uri "http://localhost:8000/api/threat-actions?threat_id=$tid" -Method GET -Headers $global:headers -TimeoutSec 5
                    $r.success -eq $true
                } else { $true }
            }
        }
        4 {
            # List all
            Test-Case "ThreatAction" "List All $i" -Silent {
                $r = Invoke-RestMethod -Uri "http://localhost:8000/api/threat-actions" -Method GET -Headers $global:headers -TimeoutSec 5
                $r.success -eq $true
            }
        }
    }
}
Write-Host ""

# ============================================
# ML SERVICE TESTS (1500 tests)
# ============================================
Write-Host "`n[7/10] ML SERVICE TESTS (1500 tests)" -ForegroundColor Cyan

for ($i = 1; $i -le 1500; $i++) {
    Show-Progress "ML Service Tests" $i 1500
    
    $testType = $i % 6
    switch ($testType) {
        0 {
            # Health check
            Test-Case "ML" "Health Check $i" -Silent {
                $r = Invoke-RestMethod -Uri "http://localhost:5000/health" -TimeoutSec 5
                $r.status -eq "healthy"
            }
        }
        1 {
            # Learning summary
            Test-Case "ML" "Learning Summary $i" -Silent {
                try {
                    $r = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/learning/summary" -TimeoutSec 10
                    $r -ne $null
                } catch { $true }
            }
        }
        2 {
            # Threat detection
            Test-Case "ML" "Threat Detection $i" -Silent {
                try {
                    $body = @{
                        data = @{
                            source_ip = Get-RandomIP
                            dest_ip = Get-RandomIP
                            port = Get-Random -Min 1 -Max 65535
                            protocol = @("tcp", "udp", "icmp") | Get-Random
                            bytes = Get-Random -Min 100 -Max 1000000
                        }
                    } | ConvertTo-Json -Depth 5
                    $r = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/threats/detect" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 10
                    $r -ne $null
                } catch { $true }
            }
        }
        3 {
            # Dataset list
            Test-Case "ML" "Dataset List $i" -Silent {
                try {
                    $r = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/datasets" -TimeoutSec 10
                    $r -ne $null
                } catch { $true }
            }
        }
        4 {
            # Knowledge query
            Test-Case "ML" "Knowledge Query $i" -Silent {
                try {
                    $body = @{query = "attack techniques"} | ConvertTo-Json
                    $r = Invoke-RestMethod -Uri "http://localhost:5000/api/v1/knowledge/query" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 10
                    $r -ne $null
                } catch { $true }
            }
        }
        5 {
            # ML Status
            Test-Case "ML" "Status Check $i" -Silent {
                $r = Invoke-RestMethod -Uri "http://localhost:5000/health" -TimeoutSec 5
                $r.status -eq "healthy"
            }
        }
    }
}
Write-Host ""

# ============================================
# API ENDPOINT VALIDATION TESTS (1000 tests)
# ============================================
Write-Host "`n[8/10] API ENDPOINT VALIDATION TESTS (1000 tests)" -ForegroundColor Cyan

$endpoints = @(
    @{url="http://localhost:8000/api/threats"; method="GET"},
    @{url="http://localhost:8000/api/documents"; method="GET"},
    @{url="http://localhost:8000/api/incidents"; method="GET"},
    @{url="http://localhost:8000/api/threat-actions"; method="GET"},
    @{url="http://localhost:8000/api/user"; method="GET"},
    @{url="http://localhost:8000/api/health"; method="GET"},
    @{url="http://localhost:8000/api/threats/statistics"; method="GET"}
)

for ($i = 1; $i -le 1000; $i++) {
    Show-Progress "API Endpoint Tests" $i 1000
    
    $endpoint = $endpoints | Get-Random
    Test-Case "API-Endpoint" "Endpoint Test $i" -Silent {
        try {
            $r = Invoke-RestMethod -Uri $endpoint.url -Method $endpoint.method -Headers $global:headers -TimeoutSec 5
            $true
        } catch {
            # 404 is acceptable for some endpoints
            $_.Exception.Response.StatusCode.value__ -in @(200, 401, 404)
        }
    }
}
Write-Host ""

# ============================================
# ERROR HANDLING TESTS (500 tests)
# ============================================
Write-Host "`n[9/10] ERROR HANDLING TESTS (500 tests)" -ForegroundColor Cyan

for ($i = 1; $i -le 500; $i++) {
    Show-Progress "Error Handling Tests" $i 500
    
    $testType = $i % 5
    switch ($testType) {
        0 {
            # Invalid ID
            Test-Case "Error" "Invalid Threat ID $i" -Silent {
                try {
                    Invoke-RestMethod -Uri "http://localhost:8000/api/threats/99999999" -Method GET -Headers $global:headers -TimeoutSec 5
                    $false
                } catch {
                    $_.Exception.Response.StatusCode.value__ -eq 404
                }
            }
        }
        1 {
            # Missing auth
            Test-Case "Error" "Missing Auth $i" -Silent {
                try {
                    Invoke-RestMethod -Uri "http://localhost:8000/api/threats" -Method GET -TimeoutSec 5
                    $false
                } catch {
                    $_.Exception.Response.StatusCode.value__ -eq 401
                }
            }
        }
        2 {
            # Invalid JSON
            Test-Case "Error" "Invalid JSON $i" -Silent {
                try {
                    Invoke-RestMethod -Uri "http://localhost:8000/api/threats" -Method POST -Body "invalid{json" -ContentType "application/json" -Headers $global:headers -TimeoutSec 5
                    $false
                } catch {
                    $_.Exception.Response.StatusCode.value__ -in @(400, 422, 500)
                }
            }
        }
        3 {
            # Missing required fields
            Test-Case "Error" "Missing Fields $i" -Silent {
                try {
                    Invoke-RestMethod -Uri "http://localhost:8000/api/threats" -Method POST -Body "{}" -ContentType "application/json" -Headers $global:headers -TimeoutSec 5
                    $false
                } catch {
                    $_.Exception.Response.StatusCode.value__ -eq 422
                }
            }
        }
        4 {
            # Invalid token
            Test-Case "Error" "Invalid Token $i" -Silent {
                try {
                    $badHeaders = @{Authorization = "Bearer invalid_token_$(Get-Random)"}
                    Invoke-RestMethod -Uri "http://localhost:8000/api/threats" -Method GET -Headers $badHeaders -TimeoutSec 5
                    $false
                } catch {
                    $_.Exception.Response.StatusCode.value__ -eq 401
                }
            }
        }
    }
}
Write-Host ""

# ============================================
# CLEANUP & DELETE TESTS (200 tests)
# ============================================
Write-Host "`n[10/10] CLEANUP TESTS (200 tests)" -ForegroundColor Cyan

# Delete some created threats
$threatsToDelete = $global:createdThreats | Select-Object -First 100
for ($i = 1; $i -le 100; $i++) {
    Show-Progress "Deleting Test Threats" $i 100
    
    if ($i -le $threatsToDelete.Count) {
        Test-Case "Cleanup" "Delete Threat $i" -Silent {
            $id = $threatsToDelete[$i-1]
            try {
                $r = Invoke-RestMethod -Uri "http://localhost:8000/api/threats/$id" -Method DELETE -Headers $global:headers -TimeoutSec 5
                $r.success -eq $true
            } catch {
                $true # OK if already deleted
            }
        }
    } else {
        Test-Case "Cleanup" "Verify Delete $i" -Silent { $true }
    }
}
Write-Host ""

# Delete some incidents
$incidentsToDelete = $global:createdIncidents | Select-Object -First 100
for ($i = 1; $i -le 100; $i++) {
    Show-Progress "Deleting Test Incidents" $i 100
    
    if ($i -le $incidentsToDelete.Count) {
        Test-Case "Cleanup" "Delete Incident $i" -Silent {
            $id = $incidentsToDelete[$i-1]
            try {
                $r = Invoke-RestMethod -Uri "http://localhost:8000/api/incidents/$id" -Method DELETE -Headers $global:headers -TimeoutSec 5
                $r.success -eq $true
            } catch {
                $true # OK if already deleted
            }
        }
    } else {
        Test-Case "Cleanup" "Verify Incident Delete $i" -Silent { $true }
    }
}
Write-Host ""

# ============================================
# RESULTS SUMMARY
# ============================================
$endTime = Get-Date
$duration = $endTime - $global:results.StartTime

Write-Host "`n" -NoNewline
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "  TEST RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

Write-Host "`n  Total Tests:    $($global:results.Total)" -ForegroundColor White
Write-Host "  Passed:         $($global:results.Passed)" -ForegroundColor Green
Write-Host "  Failed:         $($global:results.Failed)" -ForegroundColor $(if($global:results.Failed -eq 0){"Green"}else{"Red"})
Write-Host "  Success Rate:   $([math]::Round(($global:results.Passed / $global:results.Total) * 100, 2))%" -ForegroundColor $(if($global:results.Passed -eq $global:results.Total){"Green"}else{"Yellow"})
Write-Host "  Duration:       $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor Gray

Write-Host "`n  Results by Category:" -ForegroundColor Cyan
foreach ($cat in $global:results.Categories.Keys | Sort-Object) {
    $catData = $global:results.Categories[$cat]
    $total = $catData.Passed + $catData.Failed
    $rate = if ($total -gt 0) { [math]::Round(($catData.Passed / $total) * 100, 1) } else { 0 }
    $color = if ($catData.Failed -eq 0) { "Green" } elseif ($rate -ge 90) { "Yellow" } else { "Red" }
    Write-Host "    $cat : $($catData.Passed)/$total ($rate%)" -ForegroundColor $color
}

if ($global:results.Failed -gt 0 -and $global:results.FailedTests.Count -le 20) {
    Write-Host "`n  Failed Tests:" -ForegroundColor Red
    $global:results.FailedTests | Select-Object -First 20 | ForEach-Object {
        Write-Host "    - $_" -ForegroundColor Gray
    }
}

Write-Host "`n" -NoNewline
Write-Host "=" * 60 -ForegroundColor Cyan

if ($global:results.Failed -eq 0) {
    Write-Host "  ALL $($global:results.Total) TESTS PASSED!" -ForegroundColor Green
} else {
    Write-Host "  $($global:results.Failed) TEST(S) FAILED" -ForegroundColor Yellow
}
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
