# ========================================================================
# ADVANCED WINDOWS OPTIMIZATION ENGINE - V2.0 (HARDWARE REPORT INTEGRATED)
# ========================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CONFIGURATION MATRIX ---
$CONFIG = @{
    "Tweaks" = @(
        "Restart Spooler", "Force Screen Timeout", "System Corruption Scan", 
        "Clear Temp Files", "Optimize Performance", "Enable Long Paths", 
        "Disable Sticky Keys", "Create Restore Point"
    )
    "Config" = @(
        "System Hardware Report", "Computer Management", "Control Panel", "Network Connections", 
        "Power Panel", "Printer Panel", "Region", "Sound Settings", 
        "System Properties", "Time and Date"
    )
    "Network Tools" = @(
        "Network Adaptor", "IP Config Overview", "Ping Diagnostic (8.8.8.8)", 
        "GP Update Force", "Network Reset Sequence", "Flush DNS Cache", 
        "View Active Connections", "Firewall Status Check", "NTP Server Sync", "OpenSSH Server Enable"
    )
    "Fixes & Updates" = @(
        "Windows Update Reset", "WinGet Reinstall", "Rebuild Icon Cache", 
        "Reset Windows Store", "Repair Component Store", "Chkdsk Scan", 
        "Fix Package Manager", "Restart Explorer", "Clear DNS Resolver", "Reset Winsock"
    )
}

# --- THEME ENGINE MATRIX ---
$THEMES = @{
    "Forest Sage"      = @{ bg = [System.Drawing.Color]::FromArgb(244,247,245); card = [System.Drawing.Color]::White; accent = [System.Drawing.Color]::FromArgb(21,128,61); text = [System.Drawing.Color]::FromArgb(31,41,55) }
    "Slate Corporate"  = @{ bg = [System.Drawing.Color]::FromArgb(248,250,252); card = [System.Drawing.Color]::White; accent = [System.Drawing.Color]::FromArgb(30,58,138); text = [System.Drawing.Color]::FromArgb(15,23,42) }
    "Dark Cyberpunk"   = @{ bg = [System.Drawing.Color]::FromArgb(11,15,25); card = [System.Drawing.Color]::FromArgb(22,27,34); accent = [System.Drawing.Color]::FromArgb(0,240,255); text = [System.Drawing.Color]::FromArgb(226,232,240) }
    "Obsidian Black"   = @{ bg = [System.Drawing.Color]::FromArgb(18,18,18); card = [System.Drawing.Color]::FromArgb(30,30,30); accent = [System.Drawing.Color]::FromArgb(187,134,252); text = [System.Drawing.Color]::White }
}

$Global:ActiveTheme = "Forest Sage"
$Global:CurrentCategory = "Tweaks"
$Global:OptimizeState = $false

# --- BACKGROUND TASK SAFETY HANDLES ---
$Global:ActiveProcess = $null
$Global:ActiveTimer = $null

function Reset-BackgroundPipeline {
    if ($null -ne $Global:ActiveTimer) { try { $Global:ActiveTimer.Stop(); $Global:ActiveTimer.Dispose() } catch {} }
    if ($null -ne $Global:ActiveProcess) { try { if (-not $Global:ActiveProcess.HasExited) { Stop-Process -Id $Global:ActiveProcess.Id -Force -ErrorAction SilentlyContinue } } catch {} }
}

# --- UI INITIALIZATION ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Windows Optimization Engine"
$Form.Size = New-Object System.Drawing.Size(1350, 900)
$Form.StartPosition = "CenterScreen"
$Form.Add_FormClosing({ Reset-BackgroundPipeline })

$FontTitle = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$FontBtn = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$FontTab = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$FontConsole = New-Object System.Drawing.Font("Consolas", 10)

$TopHeader = New-Object System.Windows.Forms.Panel
$TopHeader.Height = 70
$TopHeader.Dock = "Top"
$Form.Controls.Add($TopHeader)

$TabContainer = New-Object System.Windows.Forms.FlowLayoutPanel
$TabContainer.Location = New-Object System.Drawing.Point(25, 12)
$TabContainer.Size = New-Object System.Drawing.Size(800, 50)
$TopHeader.Controls.Add($TabContainer)

$ContentWorkspace = New-Object System.Windows.Forms.Panel
$ContentWorkspace.Location = New-Object System.Drawing.Point(30, 90)
$ContentWorkspace.Size = New-Object System.Drawing.Size(1275, 530)
$Form.Controls.Add($ContentWorkspace)

$NotificationText = New-Object System.Windows.Forms.Label
$NotificationText.Text = "✓ Engine Ready"
$NotificationText.Location = New-Object System.Drawing.Point(30, 820)
$NotificationText.Size = New-Object System.Drawing.Size(1275, 30)
$Form.Controls.Add($NotificationText)

# --- HARDWARE REPORT LOGIC ---
function Get-SystemHardwareInfo {
    Reset-BackgroundPipeline
    $ContentWorkspace.Controls.Clear()
    $tm = $THEMES[$Global:ActiveTheme]

    $BIOS = Get-CimInstance Win32_BIOS
    $CPU = Get-CimInstance Win32_Processor
    $RAM = Get-CimInstance Win32_PhysicalMemory
    $Slots = Get-CimInstance Win32_PhysicalMemoryArray
    $Disk = Get-CimInstance MSFT_PhysicalDisk -Namespace root\Microsoft\Windows\Storage -ErrorAction SilentlyContinue

    $Report = @"
--- SYSTEM HARDWARE REPORT ---
Serial Number  : $($BIOS.SerialNumber)
CPU            : $($CPU.Name)

--- MEMORY (RAM) ---
Total RAM      : $([math]::Round(($RAM | Measure-Object Capacity -Sum).Sum / 1GB, 2)) GB
RAM Type       : $($RAM[0].SMBIOSMemoryType -eq 26 ? "DDR4" : ($RAM[0].SMBIOSMemoryType -eq 34 ? "DDR5" : "DDR3/Unknown"))
Slots Total    : $($Slots.MemoryDevices)
Slots Used     : $($RAM.Count)

--- STORAGE ---
Device Type    : $($Disk.MediaType -eq 4 ? "SSD / NVMe" : "HDD")
Model          : $($Disk.Model)
Total Size     : $([math]::Round(($Disk.Size | Measure-Object -Sum).Sum / 1GB, 0)) GB
"@

    $Box = New-Object System.Windows.Forms.TextBox
    $Box.Multiline = $true
    $Box.Font = $FontConsole
    $Box.Size = New-Object System.Drawing.Size(1235, 400)
    $Box.Location = New-Object System.Drawing.Point(20, 20)
    $Box.Text = $Report
    $Box.ReadOnly = $true
    $ContentWorkspace.Controls.Add($Box)
    
    $ReturnBtn = New-Object System.Windows.Forms.Button
    $ReturnBtn.Text = "← Return to Workspace"
    $ReturnBtn.Location = New-Object System.Drawing.Point(20, 440)
    $ReturnBtn.Size = New-Object System.Drawing.Size(200, 40)
    $ReturnBtn.Add_Click({ Render-Workspace })
    $ContentWorkspace.Controls.Add($ReturnBtn)
}

# --- TERMINAL EXECUTION ---
function Run-Cmd($command, $title) {
    try {
        $Arguments = "/k `"title $title && echo === EXECUTING: $title === && echo. && $command`""
        Start-Process "cmd.exe" -ArgumentList $Arguments -NoNewWindow:$false
    } catch { }
}

# --- COMMAND DISPATCHER ---
function Resolve-Command($label) {
    $txt = $label.Trim().ToLower()
    switch -wildcard ($txt) {
        "*system hardware report*" { Get-SystemHardwareInfo }
        "*computer management*"    { Start-Process "compmgmt.msc" }
        "*ping diagnostic*"        { Run-Cmd "ping 8.8.8.8" "Ping Test" }
        "*ip config*"              { Run-Cmd "ipconfig /all" "IP Config" }
        "*clear temp files*"       { Run-Cmd "del /q/f/s %TEMP%\* && cleanmgr /sagerun:1" "Cleanup" }
        "*corruption scan*"        { Run-Cmd "sfc /scannow" "System Scan" }
        "*windows update reset*"   { Run-Cmd "net stop wuauserv && net stop bits && net start wuauserv && net start bits" "Update Reset" }
        "*restart spooler*"        { Run-Cmd "net stop spooler && del /q /f /s %systemroot%\System32\Spool\Printers\* && net start spooler" "Spooler Reset" }
        "*reset winsock*"          { Run-Cmd "netsh winsock reset" "Winsock Reset" }
        "*winget reinstall*"       { Run-Cmd "powershell -Command Get-AppxPackage -AllUsers *Microsoft.DesktopAppInstaller* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register `'$($_.InstallLocation)\AppXManifest.xml`';}" "WinGet Restore" }
        default                    { $txt | Write-Host }
    }
}

# --- RENDER ENGINE ---
function Render-Workspace {
    $ContentWorkspace.Controls.Clear()
    $tm = $THEMES[$Global:ActiveTheme]
    $currentSubs = $CONFIG[$Global:CurrentCategory]

    $Y = 70
    foreach ($subText in $currentSubs) {
        $B = New-Object System.Windows.Forms.Button
        $B.Text = $subText
        $B.Size = New-Object System.Drawing.Size(250, 40)
        $B.Location = New-Object System.Drawing.Point(20, $Y)
        $B.Add_Click({ Resolve-Command $this.Text })
        $ContentWorkspace.Controls.Add($B)
        $Y += 50
    }
}

# --- NAVIGATION ---
foreach ($cat in $CONFIG.Keys) {
    $B = New-Object System.Windows.Forms.Button
    $B.Text = $cat
    $B.Size = New-Object System.Drawing.Size(120, 40)
    $B.Add_Click({ $Global:CurrentCategory = $this.Text; Render-Workspace })
    $TabContainer.Controls.Add($B)
}

Render-Workspace
[System.Windows.Forms.Application]::Run($Form)
