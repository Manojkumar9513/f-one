$dbBaseUrl = "https://f-one-e1ee1-default-rtdb.firebaseio.com/scores"
$iterations = 20

Write-Host "=== Starting Race Simulation ===" -ForegroundColor Cyan

for ($i = 1; $i -le $iterations; $i++) {
    Write-Host "`n--- Lap $i ---" -ForegroundColor Yellow
    
    # Fetch current state to get fresh lap counts
    $data = Invoke-RestMethod -Uri "$dbBaseUrl.json" -Method Get
    
    if ($null -eq $data) {
        Write-Host "No teams found!" -ForegroundColor Red
        break
    }

    foreach ($teamId in $data.PSObject.Properties.Name) {
        $team = $data.$teamId
        $newLaps = $team.laps + 1
        $newPoints = $team.points + (Get-Random -Minimum 1 -Maximum 10) # Randomized points for fun
        
        Write-Host "Updating $($team.house_name): Laps -> $newLaps, Points -> $newPoints"
        
        $updatePayload = @{
            laps = $newLaps
            points = $newPoints
        } | ConvertTo-Json
        
        Invoke-RestMethod -Uri "$dbBaseUrl/$teamId.json" -Method Patch -Body $updatePayload -ContentType "application/json" | Out-Null
    }
    
    Start-Sleep -Seconds 1
}

Write-Host "`n=== Simulation Finished ===" -ForegroundColor Green
