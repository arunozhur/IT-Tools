# ========================================================================
# ADVANCED WINDOWS OPTIMIZATION ENGINE - PURE POWERSHELL GUI (FINAL STABLE)
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
        "Computer Management", "Control Panel", "Network Connections", 
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
    "Nordic Frost"     = @{ bg = [System.Drawing.Color]::FromArgb(236,239,244); card = [System.Drawing.Color]::White; accent = [System.Drawing.Color]::FromArgb(94,129,172); text = [System.Drawing.Color]::FromArgb(46,52,64) }
    "Obsidian Black"   = @{ bg = [System.Drawing.Color]::FromArgb(18,18,18); card = [System.Drawing.Color]::FromArgb(30,30,30); accent = [System.Drawing.Color]::FromArgb(187,134,252); text = [System.Drawing.Color]::White }
    "Ocean Breeze"     = @{ bg = [System.Drawing.Color]::FromArgb(240,247,247); card = [System.Drawing.Color]::White; accent = [System.Drawing.Color]::FromArgb(13,148,136); text = [System.Drawing.Color]::FromArgb(17,24,39) }
    "Steel Industrial" = @{ bg = [System.Drawing.Color]::FromArgb(241,253,249); card = [System.Drawing.Color]::White; accent = [System.Drawing.Color]::FromArgb(71,85,105); text = [System.Drawing.Color]::FromArgb(15,23,42) }
    "Sunset Copper"    = @{ bg = [System.Drawing.Color]::FromArgb(250,247,245); card = [System.Drawing.Color]::White; accent = [System.Drawing.Color]::FromArgb(194,65,12); text = [System.Drawing.Color]::FromArgb(31,41,55) }
    "Midnight Blue"    = @{ bg = [System.Drawing.Color]::FromArgb(10,14,26); card = [System.Drawing.Color]::FromArgb(18,24,41); accent = [System.Drawing.Color]::FromArgb(59,130,246); text = [System.Drawing.Color]::FromArgb(248,250,252) }
    "Dracula Accent"   = @{ bg = [System.Drawing.Color]::FromArgb(40,42,54); card = [System.Drawing.Color]::FromArgb(68,71,90); accent = [System.Drawing.Color]::FromArgb(189,147,249); text = [System.Drawing.Color]::FromArgb(248,248,242) }
}

$Global:ActiveTheme = "Forest Sage"
$Global:CurrentCategory = "Tweaks"
$Global:OptimizeState = $false

# --- BACKGROUND TASK SAFETY HANDLES ---
$Global:ActiveProcess = $null
$Global:ActiveTimer = $null
$Global:LogReaderIndex = 0
$Global:TempLogPath = "$env:TEMP\engine_terminal_stream.log"

function Reset-BackgroundPipeline {
    if ($null -ne $Global:ActiveTimer) {
        try { $Global:ActiveTimer.Stop(); $Global:ActiveTimer.Dispose() } catch {}
        $Global:ActiveTimer = $null
    }
    if ($null -ne $Global:ActiveProcess) {
        try {
            if (-not $Global:ActiveProcess.HasExited) {
                Stop-Process -Id $Global:ActiveProcess.Id -Force -ErrorAction SilentlyContinue
            }
        } catch {}
        try { $Global:ActiveProcess.Dispose() } catch {}
        $Global:ActiveProcess = $null
    }
    # Safely clear temp file session
    if (Test-Path $Global:TempLogPath) {
        try { Remove-Item $Global:TempLogPath -Force -ErrorAction SilentlyContinue } catch {}
    }
    $Global:LogReaderIndex = 0
}

# --- MAIN WINDOW INTERFACE ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Windows Optimization Engine"
$Form.Size = New-Object System.Drawing.Size(1350, 900)
$Form.StartPosition = "CenterScreen"
$Form.Add_FormClosing({ Reset-BackgroundPipeline })

# --- UI FONTS ---
$FontTitle = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$FontBtn = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$FontTab = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$FontNotify = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$FontConsole = New-Object System.Drawing.Font("Consolas", 10)

# --- TOP HEADER PANEL ---
$TopHeader = New-Object System.Windows.Forms.Panel
$TopHeader.Height = 70
$TopHeader.Dock = "Top"
$Form.Controls.Add($TopHeader)

# --- TAB CONTAINER ---
$TabContainer = New-Object System.Windows.Forms.FlowLayoutPanel
$TabContainer.Location = New-Object System.Drawing.Point(25, 12)
$TabContainer.Size = New-Object System.Drawing.Size(800, 50)
$TabContainer.FlowDirection = "LeftToRight"
$TopHeader.Controls.Add($TabContainer)

# --- WORKSPACE AREA ---
$ContentWorkspace = New-Object System.Windows.Forms.Panel
$ContentWorkspace.Location = New-Object System.Drawing.Point(30, 90)
$ContentWorkspace.Size = New-Object System.Drawing.Size(1275, 530)
$Form.Controls.Add($ContentWorkspace)

# --- BOTTOM CONTAINER ---
$BottomStickyFrame = New-Object System.Windows.Forms.Panel
$BottomStickyFrame.Location = New-Object System.Drawing.Point(30, 635)
$BottomStickyFrame.Size = New-Object System.Drawing.Size(1275, 210)
$Form.Controls.Add($BottomStickyFrame)

# --- NOTIFICATION BAR ---
$NotificationBar = New-Object System.Windows.Forms.Panel
$NotificationBar.Height = 40
$NotificationBar.Dock = "Top"
$BottomStickyFrame.Controls.Add($NotificationBar)

$NotificationText = New-Object System.Windows.Forms.Label
$NotificationText.Text = "✓ Engine Status: Operational | Ready for Administration Sequence Tasks"
$NotificationText.Font = $FontNotify
$NotificationText.ForeColor = [System.Drawing.Color]::FromArgb(16,185,129)
$NotificationText.Dock = "Fill"
$NotificationText.TextAlign = "MiddleLeft"
$NotificationBar.Controls.Add($NotificationText)

# --- CONSOLE BLOCK ---
$ConsoleBox = New-Object System.Windows.Forms.TextBox
$ConsoleBox.Multiline = $true
$ConsoleBox.ScrollBars = "Vertical"
$ConsoleBox.Font = $FontConsole
$ConsoleBox.BackColor = [System.Drawing.Color]::FromArgb(30,41,59)
$ConsoleBox.ForeColor = [System.Drawing.Color]::FromArgb(56,189,248)
$ConsoleBox.Height = 150
$ConsoleBox.Dock = "Bottom"
$ConsoleBox.ReadOnly = $true
$BottomStickyFrame.Controls.Add($ConsoleBox)

# --- LOG ENGINE ---
function Log($msg) {
    if ($null -ne $ConsoleBox -and -not $ConsoleBox.IsDisposed) {
        $ConsoleBox.AppendText("[ENGINE]: $msg`r`n")
        $ConsoleBox.SelectionStart = $ConsoleBox.Text.Length
        $ConsoleBox.ScrollToCaret()
    }
}

function Update-Status($msg, $isError=$false) {
    if ($null -ne $NotificationText -and -not $NotificationText.IsDisposed) {
        $prefix = if ($isError) { "⚠ Error: " } else { "✓ Active: " }
        if ($isError) {
            $NotificationText.ForeColor = [System.Drawing.Color]::FromArgb(248,113,113)
        } else {
            $NotificationText.ForeColor = [System.Drawing.Color]::FromArgb(52,211,153)
        }
        $NotificationText.Text = "$prefix$msg"
    }
    Log $msg
}

# --- PERFORMANCE TOGGLE LOGIC ---
function Toggle-Performance {
    if ($Global:OptimizeState) {
        Resolve-Command "powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e"
        $Global:OptimizeState = $false
        Update-Status "Performance Mode Disabled (Switched to Balanced)"
    } else {
        Resolve-Command "powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        $Global:OptimizeState = $true
        Update-Status "High Performance Power Mode Enabled"
    }
}

# --- COMMAND DISPATCHER ---
function Resolve-Command($label) {
    $txt = $label.Trim().ToLower()
    Reset-BackgroundPipeline
    
    switch -wildcard ($txt) {
        "*computer management*" { Start-Process "compmgmt.msc"; Update-Status "Deployed Computer Management Panel" }
        "*control panel*"       { Start-Process "control"; Update-Status "Deployed Control Panel" }
        "*network connections*" { Start-Process "ncpa.cpl"; Update-Status "Deployed Network Connections" }
        "*power panel*"         { Start-Process "control" "powercfg.cpl"; Update-Status "Deployed Power Panel" }
        "*printer panel*"       { Start-Process "control" "printers"; Update-Status "Deployed Printer Panel" }
        "*region*"              { Start-Process "intl.cpl"; Update-Status "Deployed Region Panel" }
        "*sound settings*"      { Start-Process "mmsys.cpl"; Update-Status "Deployed Sound Settings" }
        "*system properties*"   { Start-Process "sysdm.cpl"; Update-Status "Deployed System Properties" }
        "*time and date*"       { Start-Process "timedate.cpl"; Update-Status "Deployed Time & Date Panel" }
        "*spooler*"             { Trigger-Spooler }
        "*timeout*"             { Show-TimeoutUI }
        "*corruption scan*"     { Run-Cmd "sfc /scannow" "SFC System Integrity Target" }
        "*clear temp files*"    { Run-Cmd "cmd.exe /c del /q/f/s %TEMP%\* && cleanmgr /sagerun:1" "Temporary System Cache Purge" }
        "*performance*"         { Toggle-Performance }
        "*long paths*"          { Run-Cmd 'reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f' "Win32 Naming Path Extension Limit Lifted" }
        "*sticky keys*"         { Run-Cmd 'reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 506 /f' "Sticky Keys System Interrupter Disabled" }
        "*restore point*"       { Run-Cmd "powershell -Command Checkpoint-Computer -Description 'AdminToolRestore' -RestorePointType 'MODIFY_SETTINGS'" "System Restore Snapshot Validation" }
        "*network adaptor*"     { Show-NetworkUI }
        "*ip config*"           { Run-Cmd "ipconfig /all" "IP Protocol Configuration Matrix" }
        "*ping diagnostic*"     { Run-Cmd "ping 8.8.8.8" "ICMP Destination Core Ping Stream" }
        "*gp update*"           { Run-Cmd "gpupdate /force" "Group Policy Policy Refresh Optimization" }
        "*network reset*"       { Run-Cmd "cmd.exe /c netsh int ip reset && netsh winsock reset" "Network Interface Stack Clear Sequence" }
        "*flush dns*"           { Run-Cmd "ipconfig /flushdns" "DNS Resolver Local Cache Purge" }
        "*active connections*"  { Run-Cmd "netstat -an" "Active Inter-Network Route Monitor Output" }
        "*firewall status*"     { Run-Cmd "netsh advfirewall show allprofiles" "Windows Defender Security Firewall Verification" }
        "*ntp server*"          { Run-Cmd "w32tm /resync" "System Hardware Time NTP Synchronization Sequence" }
        "*openssh server*"      { Run-Cmd "powershell -Command Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0" "Deploy and Bind Local Secure Shell Architecture" }
        "*windows update reset*" { Run-Cmd "cmd.exe /c net stop wuauserv && net stop bits && net start wuauserv && net start bits" "Windows Update Subsystem Stack Reset" }
        "*winget reinstall*"    { Run-Cmd "powershell -Command Get-AppxPackage -AllUsers *Microsoft.DesktopAppInstaller* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register `'$($_.InstallLocation)\AppXManifest.xml`';}" "WinGet Package Manager Deployment Restoration" }
        "*rebuild icon cache*"  { Run-Cmd "cmd.exe /c ie4uinit.exe -show && taskkill /IM explorer.exe /F && del /f /q %localappdata%\IconCache.db && start explorer.exe" "Shell Graphical Environment Refresher Sequence" }
        "*windows store*"       { Run-Cmd "wsreset.exe" "Microsoft Store Architecture Cache Clearing Matrix" }
        "*component store*"     { Run-Cmd "DISM /Online /Cleanup-Image /RestoreHealth" "Deployment Image Servicing Engine Optimization Sync" }
        "*chkdsk scan*"         { Run-Cmd "chkdsk C: /f /r /x" "NTFS File Allocation Index Sector Validation Task" }
        "*package manager*"     { Run-Cmd "dism /online /cleanup-image /startcomponentcleanup" "WinSxS Side-by-Side Component Library Optimization" }
        "*restart explorer*"    { Run-Cmd "cmd.exe /c taskkill /f /im explorer.exe && start explorer.exe" "Windows Shell Execution Infrastructure Recycling Task" }
        "*dns resolver*"        { Run-Cmd "ipconfig /registerdns" "Network Registration Handle Updates Initiated" }
        "*winsock*"             { Run-Cmd "netsh winsock reset catalog" "Winsock API Layer Catalog Protocol Reset Pipeline" }
        default                 { Update-Status "Command triggered: $label" }
    }
}

# --- TERMINAL EXECUTION PIPELINE ---
function Run-Cmd($command, $title) {
    Reset-BackgroundPipeline
    $ContentWorkspace.Controls.Clear()
    Update-Status "Executing Sequence: $title"
    $tm = $THEMES[$Global:ActiveTheme]

    $TerminalPanel = New-Object System.Windows.Forms.Panel
    $TerminalPanel.Dock = "Fill"
    $TerminalPanel.BackColor = $tm.card
    $ContentWorkspace.Controls.Add($TerminalPanel)

    $HeaderLabel = New-Object System.Windows.Forms.Label
    $HeaderLabel.Text = $title
    $HeaderLabel.Font = $FontTitle
    $HeaderLabel.ForeColor = $tm.text
    $HeaderLabel.Location = New-Object System.Drawing.Point(20, 15)
    $HeaderLabel.Size = New-Object System.Drawing.Size(600, 30)
    $TerminalPanel.Controls.Add($HeaderLabel)

    $ReturnBtn = New-Object System.Windows.Forms.Button
    $ReturnBtn.Text = "← Return to Workspace"
    $ReturnBtn.Font = $FontBtn
    $ReturnBtn.BackColor = [System.Drawing.Color]::FromArgb(239,68,68)
    $ReturnBtn.ForeColor = [System.Drawing.Color]::White
    $ReturnBtn.Location = New-Object System.Drawing.Point(1000, 15)
    $ReturnBtn.Size = New-Object System.Drawing.Size(220, 35)
    $ReturnBtn.FlatStyle = "Flat"
    $ReturnBtn.FlatAppearance.BorderSize = 0
    $ReturnBtn.Add_Click({ 
        Reset-BackgroundPipeline
        Render-Workspace 
    })
    $TerminalPanel.Controls.Add($ReturnBtn)

    $OutBox = New-Object System.Windows.Forms.TextBox
    $OutBox.Multiline = $true
    $OutBox.ScrollBars = "Vertical"
    $OutBox.Font = $FontConsole
    $OutBox.BackColor = [System.Drawing.Color]::FromArgb(15,23,42)
    $OutBox.ForeColor = [System.Drawing.Color]::FromArgb(248,250,252)
    $OutBox.Location = New-Object System.Drawing.Point(20, 65)
    $OutBox.Size = New-Object System.Drawing.Size(1235, 440)
    $OutBox.ReadOnly = $true
    $TerminalPanel.Controls.Add($OutBox)

    $OutBox.Text = "Initializing Live Terminal Architecture Pipeline...`r`n"

    # Reset logging target
    $Global:LogReaderIndex = 0
    if (Test-Path $Global:TempLogPath) { Remove-Item $Global:TempLogPath -Force -ErrorAction SilentlyContinue }
    "Initial Session Bind Validation Sequence Operational." | Out-File $Global:TempLogPath -Encoding utf8

    $Psi = New-Object System.Diagnostics.ProcessStartInfo
    $Psi.FileName = "cmd.exe"
    
    # FIX: Using Tee-Object forcing immediate flush of stream buffer into the temp file line-by-line
    $Psi.Arguments = "/c powershell -NoProfile -Command `"$command 2>&1 | Tee-Object -FilePath '$Global:TempLogPath' -Append`""
    $Psi.UseShellExecute = $false
    $Psi.CreateNoWindow = $true

    $Global:ActiveProcess = New-Object System.Diagnostics.Process
    $Global:ActiveProcess.StartInfo = $Psi
    
    try {
        [void]$Global:ActiveProcess.Start()
    } catch {
        Update-Status "Failed to initiate background diagnostic task pipeline." -isError $true
        return
    }

    $Global:ActiveTimer = New-Object System.Windows.Forms.Timer
    $Global:ActiveTimer.Interval = 200 # Balanced refresh interval
    $Global:ActiveTimer.Add_Tick({
        if ($null -eq $OutBox -or $OutBox.IsDisposed) {
            Reset-BackgroundPipeline
            return
        }

        try {
            if (Test-Path $Global:TempLogPath) {
                # Read contents safely using dynamic line-indexing
                $Lines = Get-Content $Global:TempLogPath -ErrorAction SilentlyContinue
                if ($null -ne $Lines -and $Lines.Count -gt $Global:LogReaderIndex) {
                    for ($i = $Global:LogReaderIndex; $i -lt $Lines.Count; $i++) {
                        if ($null -ne $Lines[$i]) {
                            $OutBox.AppendText($Lines[$i] + "`r`n")
                        }
                    }
                    $Global:LogReaderIndex = $Lines.Count
                    $OutBox.SelectionStart = $OutBox.Text.Length
                    $OutBox.ScrollToCaret()
                }
            }
        } catch {}

        if ($null -eq $Global:ActiveProcess -or $Global:ActiveProcess.HasExited) {
            $Global:ActiveTimer.Stop()
            try {
                if (Test-Path $Global:TempLogPath) {
                    $FinalLines = Get-Content $Global:TempLogPath -ErrorAction SilentlyContinue
                    if ($null -ne $FinalLines -and $FinalLines.Count -gt $Global:LogReaderIndex) {
                        for ($i = $Global:LogReaderIndex; $i -lt $FinalLines.Count; $i++) {
                            $OutBox.AppendText($FinalLines[$i] + "`r`n")
                        }
                    }
                }
            } catch {}
            Reset-BackgroundPipeline
            Update-Status "Completed execution sequence stack run: $title"
        }
    })
    $Global:ActiveTimer.Start()
}

# --- ACTION: RESTART SPOOLER ---
function Trigger-Spooler {
    Reset-BackgroundPipeline
    $ContentWorkspace.Controls.Clear()
    $tm = $THEMES[$Global:ActiveTheme]
    
    $Wrapper = New-Object System.Windows.Forms.Panel
    $Wrapper.Dock = "Fill"
    $Wrapper.BackColor = $tm.card
    $ContentWorkspace.Controls.Add($Wrapper)

    $HeaderLabel = New-Object System.Windows.Forms.Label
    $HeaderLabel.Text = "Print Spooler Infrastructure System Service"
    $HeaderLabel.Font = $FontTitle
    $HeaderLabel.ForeColor = $tm.text
    $HeaderLabel.Location = New-Object System.Drawing.Point(20, 15)
    $HeaderLabel.Size = New-Object System.Drawing.Size(600, 30)
    $Wrapper.Controls.Add($HeaderLabel)

    $ReturnBtn = New-Object System.Windows.Forms.Button
    $ReturnBtn.Text = "← Return to Workspace"
    $ReturnBtn.Font = $FontBtn
    $ReturnBtn.BackColor = [System.Drawing.Color]::FromArgb(239,68,68)
    $ReturnBtn.ForeColor = [System.Drawing.Color]::White
    $ReturnBtn.Location = New-Object System.Drawing.Point(1000, 15)
    $ReturnBtn.Size = New-Object System.Drawing.Size(220, 35)
    $ReturnBtn.FlatStyle = "Flat"
    $ReturnBtn.FlatAppearance.BorderSize = 0
    $ReturnBtn.Add_Click({ Render-Workspace })
    $Wrapper.Controls.Add($ReturnBtn)

    $StatusBox = New-Object System.Windows.Forms.TextBox
    $StatusBox.Multiline = $true
    $StatusBox.Font = $FontConsole
    $StatusBox.BackColor = [System.Drawing.Color]::FromArgb(15,23,42)
    $StatusBox.ForeColor = [System.Drawing.Color]::FromArgb(248,250,252)
    $StatusBox.Location = New-Object System.Drawing.Point(20, 70)
    $StatusBox.Size = New-Object System.Drawing.Size(1235, 435)
    $StatusBox.ReadOnly = $true
    $Wrapper.Controls.Add($StatusBox)

    Update-Status "Terminating dynamic printing subsystem task allocations..."
    $StatusBox.AppendText("[PROCESS] Halting Print Spooler service structure...`r`n")
    Stop-Service -Name "Spooler" -Force
    
    $StatusBox.AppendText("[PROCESS] Purging local memory print pipeline caches...`r`n")
    Get-ChildItem -Path "$env:systemroot\System32\Spool\Printers\*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force
    
    $StatusBox.AppendText("[PROCESS] Re-initializing subsystem engine handles...`r`n")
    Start-Service -Name "Spooler"
    $StatusBox.AppendText("[SUCCESS] Dynamic service framework is now fully restored and stable.`r`n")
    Update-Status "Print spooler subsystem engine fully restored and online."
}

# --- INTERFACE: FORCE TIMEOUT UI ---
function Show-TimeoutUI {
    Reset-BackgroundPipeline
    $ContentWorkspace.Controls.Clear()
    $tm = $THEMES[$Global:ActiveTheme]

    $TopPanel = New-Object System.Windows.Forms.Panel
    $TopPanel.Height = 50
    $TopPanel.Dock = "Top"
    $ContentWorkspace.Controls.Add($TopPanel)

    $ReturnBtn = New-Object System.Windows.Forms.Button
    $ReturnBtn.Text = "← Return to Workspace"
    $ReturnBtn.Font = $FontBtn
    $ReturnBtn.BackColor = [System.Drawing.Color]::FromArgb(239,68,68)
    $ReturnBtn.ForeColor = [System.Drawing.Color]::White
    $ReturnBtn.Location = New-Object System.Drawing.Point(1000, 8)
    $ReturnBtn.Size = New-Object System.Drawing.Size(220, 35)
    $ReturnBtn.FlatStyle = "Flat"
    $ReturnBtn.FlatAppearance.BorderSize = 0
    $ReturnBtn.Add_Click({ Render-Workspace })
    $TopPanel.Controls.Add($ReturnBtn)

    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.Size = New-Object System.Drawing.Size(500, 300)
    $Panel.Location = New-Object System.Drawing.Point(380, 100)
    $Panel.BackColor = $tm.card
    $ContentWorkspace.Controls.Add($Panel)

    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = "Lock Screen Timeout Value Strategy"
    $Label.Font = $FontTitle
    $Label.ForeColor = $tm.text
    $Label.Size = New-Object System.Drawing.Size(460, 40)
    $Label.Location = New-Object System.Drawing.Point(20, 20)
    $Label.TextAlign = "Center"
    $Panel.Controls.Add($Label)

    $Entry = New-Object System.Windows.Forms.TextBox
    $Entry.Size = New-Object System.Drawing.Size(300, 35)
    $Entry.Location = New-Object System.Drawing.Point(100, 100)
    $Entry.Font = $FontBtn
    $Panel.Controls.Add($Entry)

    $CommitBtn = New-Object System.Windows.Forms.Button
    $CommitBtn.Text = "Commit Threshold Metrics"
    $CommitBtn.Font = $FontBtn
    $CommitBtn.BackColor = $tm.accent
    $CommitBtn.ForeColor = [System.Drawing.Color]::White
    $CommitBtn.Size = New-Object System.Drawing.Size(300, 40)
    $CommitBtn.Location = New-Object System.Drawing.Point(100, 170)
    $CommitBtn.FlatStyle = "Flat"
    $CommitBtn.FlatAppearance.BorderSize = 0
    $CommitBtn.Add_Click({
        $s = $Entry.Text.Trim()
        if ($s -match "^\d+$") {
            powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $s
            powercfg /SETACTIVE SCHEME_CURRENT
            Update-Status "Synchronized lockout thresholds to $s seconds."
            Render-Workspace
        } else {
            Update-Status "Invalid structural input configuration value." -isError $true
        }
    })
    $Panel.Controls.Add($CommitBtn)
}

# --- INTERFACE: NETWORK MANAGEMENT UI ---
function Show-NetworkUI {
    Reset-BackgroundPipeline
    $ContentWorkspace.Controls.Clear()
    $tm = $THEMES[$Global:ActiveTheme]

    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.Dock = "Fill"
    $Panel.BackColor = $tm.card
    $ContentWorkspace.Controls.Add($Panel)

    $Label1 = New-Object System.Windows.Forms.Label
    $Label1.Text = "Identified System Interface Hardware profiles:"
    $Label1.Font = $FontTitle
    $Label1.ForeColor = $tm.text
    $Label1.Location = New-Object System.Drawing.Point(20, 20)
    $Label1.Size = New-Object System.Drawing.Size(600, 30)
    $Panel.Controls.Add($Label1)

    $ReturnBtn = New-Object System.Windows.Forms.Button
    $ReturnBtn.Text = "← Return to Workspace"
    $ReturnBtn.Font = $FontBtn
    $ReturnBtn.BackColor = [System.Drawing.Color]::FromArgb(239,68,68)
    $ReturnBtn.ForeColor = [System.Drawing.Color]::White
    $ReturnBtn.Location = New-Object System.Drawing.Point(1000, 20)
    $ReturnBtn.Size = New-Object System.Drawing.Size(220, 35)
    $ReturnBtn.FlatStyle = "Flat"
    $ReturnBtn.FlatAppearance.BorderSize = 0
    $ReturnBtn.Add_Click({ Render-Workspace })
    $Panel.Controls.Add($ReturnBtn)

    $Box = New-Object System.Windows.Forms.TextBox
    $Box.Multiline = $true
    $Box.Font = $FontConsole
    $Box.BackColor = $tm.bg
    $Box.ForeColor = $tm.text
    $Box.Location = New-Object System.Drawing.Point(20, 60)
    $Box.Size = New-Object System.Drawing.Size(1235, 130)
    $Box.ReadOnly = $true
    $Adapters = Get-NetAdapter | Select-Object -ExpandProperty Name
    $Box.Text = $Adapters -join "`r`n"
    $Panel.Controls.Add($Box)

    $Label2 = New-Object System.Windows.Forms.Label
    $Label2.Text = "Input targeted adapter label string precisely:"
    $Label2.Font = $FontBtn
    $Label2.ForeColor = $tm.text
    $Label2.Location = New-Object System.Drawing.Point(20, 210)
    $Label2.Size = New-Object System.Drawing.Size(500, 25)
    $Panel.Controls.Add($Label2)

    $Entry = New-Object System.Windows.Forms.TextBox
    $Entry.Size = New-Object System.Drawing.Size(400, 35)
    $Entry.Location = New-Object System.Drawing.Point(20, 240)
    $Entry.Font = $FontBtn
    $Panel.Controls.Add($Entry)
