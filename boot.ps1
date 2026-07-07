# ========================================================================
# SYSTEM ADMINISTRATION UTILITY TOOL
# ========================================================================

clear-host

function Show-Menu {
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "       SYSTEM ADMINISTRATION TOOL          " -ForegroundColor White -BackgroundColor DarkCyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host " 1." -ForegroundColor Cyan -NoNewline; Write-Host " View System & hardware Information"
    Write-Host " 2." -ForegroundColor Cyan -NoNewline; Write-Host " Restart Printer Spooler Service"
    Write-Host " 3." -ForegroundColor Cyan -NoNewline; Write-Host " View Network IP Configuration"
    Write-Host " 4." -ForegroundColor Cyan -NoNewline; Write-Host " Clear Temp Files & Optimize System"
    Write-Host " 5." -ForegroundColor Cyan -NoNewline; Write-Host " Exit"
    Write-Host "==========================================" -ForegroundColor Cyan
}

function Get-SystemInfo {
    clear-host
    Write-Host "--- Fetching System Information ---`n" -ForegroundColor Cyan
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $cpu = Get-CimInstance Win32_Processor
    
    Write-Host "Computer Name : " -NoNewline; Write-Host $cs.Name -ForegroundColor Yellow
    Write-Host "OS Version    : " -NoNewline; Write-Host $os.Caption -ForegroundColor Yellow
    Write-Host "Processor     : " -NoNewline; Write-Host $cpu.Name -ForegroundColor Yellow
    Write-Host "Total Memory  : " -NoNewline; Write-Host "$([Math]::Round($cs.TotalPhysicalMemory / 1GB, 2)) GB" -ForegroundColor Yellow
    Write-Host "`nPress any key to return to menu..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Restart-Spooler {
    clear-host
    Write-Host "--- Restarting Printer Spooler ---`n" -ForegroundColor Cyan
    try {
        Write-Host "Stopping Print Spooler service..." -ForegroundColor Yellow
        Stop-Service -Name "Spooler" -Force -ErrorAction Stop
        Start-Sleep -Seconds 2
        
        Write-Host "Starting Print Spooler service..." -ForegroundColor Yellow
        Start-Service -Name "Spooler" -ErrorAction Stop
        Write-Host "`n[SUCCESS] Printer Spooler restarted successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "`n[ERROR] Failed to restart Spooler. Make sure you ran this as Administrator." -ForegroundColor Red
    }
    Write-Host "`nPress any key to return to menu..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Get-IPConfig {
    clear-host
    Write-Host "--- Network Configuration ---`n" -ForegroundColor Cyan
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127*"} | Format-Table InterfaceAlias, IPAddress, IPv4Address -AutoSize
    Write-Host "`nPress any key to return to menu..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Optimize-System {
    clear-host
    Write-Host "--- Clearing Temporary Files ---`n" -ForegroundColor Cyan
    $tempPaths = @("$env:TEMP\*")
    
    foreach ($path in $tempPaths) {
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    Write-Host "[SUCCESS] Temporary files cleared." -ForegroundColor Green
    Write-Host "`nPress any key to return to menu..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Main Loop Execution
do {
    clear-host
    Show-Menu
    $choice = Read-Host "`nSelect an option (1-5)"
    
    switch ($choice) {
        '1' { Get-SystemInfo }
        '2' { Restart-Spooler }
        '3' { Get-IPConfig }
        '4' { Optimize-System }
        '5' { clear-host; Write-Host "Exiting tool. Goodbye!`n" -ForegroundColor Cyan; exit }
        default { Write-Host "Invalid selection! Please try again." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($true)
