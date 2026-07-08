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
    "Forest Sage"      = @{ bg = "#F4F7F5"; card = "#FFFFFF"; accent = "#15803D"; hover = "#166534"; text = "#1F2937" }
    "Slate Corporate"  = @{ bg = "#F8FAFC"; card = "#FFFFFF"; accent = "#1E3A8A"; hover = "#1E40AF"; text = "#0F172A" }
    "Dark Cyberpunk"   = @{ bg = "#0B0F19"; card = "#161B22"; accent = "#00F0FF"; hover = "#00B8D4"; text = "#E2E8F0" }
    "Nordic Frost"     = @{ bg = "#ECEFF4"; card = "#FFFFFF"; accent = "#5E81AC"; hover = "#81A1C1"; text = "#2E3440" }
    "Obsidian Black"   = @{ bg = "#121212"; card = "#1E1E1E"; accent = "#BB86FC"; hover = "#3700B3"; text = "#FFFFFF" }
    "Ocean Breeze"     = @{ bg = "#F0F7F7"; card = "#FFFFFF"; accent = "#0D9488"; hover = "#0F766E"; text = "#111827" }
    "Steel Industrial" = @{ bg = "#F1F5F9"; card = "#FFFFFF"; accent = "#475569"; hover = "#334155"; text = "#0F172A" }
    "Sunset Copper"    = @{ bg = "#FAF7F5"; card = "#FFFFFF"; accent = "#C2410C"; hover = "#9A3412"; text = "#1F2937" }
    "Midnight Blue"    = @{ bg = "#0A0E1A"; card = "#121829"; accent = "#3B82F6"; hover = "#2563EB"; text = "#F8FAFC" }
    "Dracula Accent"   = @{ bg = "#282A36"; card = "#44475A"; accent = "#BD93F9"; hover = "#FF79C6"; text = "#F8F8F2" }
}

$Global:ActiveTheme = "Forest Sage"
$Global:CurrentCategory = "Tweaks"
$Global:OptimizeState = $false

# --- MAIN ARTIFACT WINDOW ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Windows Optimization Engine"
$Form.Size = New-Object System.Drawing.Size(1350, 900)
$Form.StartPosition = "CenterScreen"

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
$NotificationText.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#10B981")
$NotificationText.Dock = "Fill"
$NotificationText.TextAlign = "MiddleLeft"
$NotificationBar.Controls.Add($NotificationText)

# --- CONSOLE BLOCK ---
$ConsoleBox = New-Object System.Windows.Forms.TextBox
$ConsoleBox.Multiline = $true
$ConsoleBox.ScrollBars = "Vertical"
$ConsoleBox.Font = $FontConsole
$ConsoleBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1E293B")
$ConsoleBox.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#38BDF8")
$ConsoleBox.Height = 150
$ConsoleBox.Dock = "Bottom"
$ConsoleBox.ReadOnly = $true
$BottomStickyFrame.Controls.Add($ConsoleBox)

# --- LOG ENGINE ---
function Log($msg) {
    $ConsoleBox.AppendText("[ENGINE]: $msg`r`n")
    $ConsoleBox.SelectionStart = $ConsoleBox.Text.Length
    $ConsoleBox.ScrollToCaret()
}

function Update-Status($msg, $isError=$false) {
    $prefix = if ($isError) { "⚠ Error: " } else { "✓ Active: " }
    $color = if ($isError) { "#F87171" } else { "#34D399" }
    $NotificationText.Text = "$prefix$msg"
    $NotificationText.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($color)
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
    $ContentWorkspace.Controls.Clear()
    Update-Status "Executing automation run sequence: $title"
    $tm = $THEMES[$Global:ActiveTheme]

    $TerminalPanel = New-Object System.Windows.Forms.Panel
    $TerminalPanel.Dock = "Fill"
    $TerminalPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.card)
    $ContentWorkspace.Controls.Add($TerminalPanel)

    $HeaderLabel = New-Object System.Windows.Forms.Label
    $HeaderLabel.Text = $title
    $HeaderLabel.Font = $FontTitle
    $HeaderLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
    $HeaderLabel.Location = New-Object System.Drawing.Point(20, 15)
    $HeaderLabel.Size = New-Object System.Drawing.Size(600, 30)
    $TerminalPanel.Controls.Add($HeaderLabel)

    $ReturnBtn = New-Object System.Windows.Forms.Button
    $ReturnBtn.Text = "← Return to Workspace"
    $ReturnBtn.Font = $FontBtn
    $ReturnBtn.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#EF4444")
    $ReturnBtn.ForeColor = [System.Drawing.Color]::White
    $ReturnBtn.Location = New-Object System.Drawing.Point(1000, 15)
    $ReturnBtn.Size = New-Object System.Drawing.Size(220, 35)
    $ReturnBtn.FlatStyle = "Flat"
    $ReturnBtn.FlatAppearance.BorderSize = 0
    $ReturnBtn.Add_Click({ Render-Workspace })
    $TerminalPanel.Controls.Add($ReturnBtn)

    $OutBox = New-Object System.Windows.Forms.TextBox
    $OutBox.Multiline = $true
    $OutBox.ScrollBars = "Vertical"
    $OutBox.Font = $FontConsole
    $OutBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")
    $OutBox.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#F8FAFC")
    $OutBox.Location = New-Object System.Drawing.Point(20, 65)
    $OutBox.Size = New-Object System.Drawing.Size(1235, 440)
    $OutBox.ReadOnly = $true
    $TerminalPanel.Controls.Add($OutBox)

    # Use native Invoke-Expression tracking without structural pipeline breaks
    $PowershellAsync = [powershell]::Create().AddScript($command)
    $AsyncResult = $PowershellAsync.BeginInvoke()
    
    $Timer = New-Object System.Windows.Forms.Timer
    $Timer.Interval = 200
    $Timer.Add_Tick({
        if ($AsyncResult.IsCompleted) {
            $Timer.Stop()
            $Output = $PowershellAsync.EndInvoke($AsyncResult)
            if ($Output) {
                $CleanText = ($Output | Out-String)
                $OutBox.Text = $CleanText
            } else {
                $OutBox.Text = "Command completed with empty stdout engine data pipeline."
            }
            Update-Status "Completed execution sequence stack run: $title"
            $PowershellAsync.Dispose()
        }
    })
    $Timer.Start()
}

# --- ACTION: RESTART SPOOLER ---
function Trigger-Spooler {
    $ContentWorkspace.Controls.Clear()
    $tm = $THEMES[$Global:ActiveTheme]
    
    $Wrapper = New-Object System.Windows.Forms.Panel
    $Wrapper.Dock = "Fill"
    $Wrapper.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.card)
    $ContentWorkspace.Controls.Add($Wrapper)

    $HeaderLabel = New-Object System.Windows.Forms.Label
    $HeaderLabel.Text = "Print Spooler Infrastructure System Service"
    $HeaderLabel.Font = $FontTitle
    $HeaderLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
    $HeaderLabel.Location = New-Object System.Drawing.Point(20, 15)
    $HeaderLabel.Size = New-Object System.Drawing.Size(600, 30)
    $Wrapper.Controls.Add($HeaderLabel)

    $ReturnBtn = New-Object System.Windows.Forms.Button
    $ReturnBtn.Text = "← Return to Workspace"
    $ReturnBtn.Font = $FontBtn
    $ReturnBtn.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#EF4444")
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
    $StatusBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")
    $StatusBox.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#F8FAFC")
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
    $ContentWorkspace.Controls.Clear()
    $tm = $THEMES[$Global:ActiveTheme]

    $TopPanel = New-Object System.Windows.Forms.Panel
    $TopPanel.Height = 50
    $TopPanel.Dock = "Top"
    $ContentWorkspace.Controls.Add($TopPanel)

    $ReturnBtn = New-Object System.Windows.Forms.Button
    $ReturnBtn.Text = "← Return to Workspace"
    $ReturnBtn.Font = $FontBtn
    $ReturnBtn.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#EF4444")
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
    $Panel.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.card)
    $ContentWorkspace.Controls.Add($Panel)

    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = "Lock Screen Timeout Value Strategy"
    $Label.Font = $FontTitle
    $Label.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
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
    $CommitBtn.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.accent)
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
            Update-Status "Synchronized lockout thresholds to ${s}s."
            Render-Workspace
        } else {
            Update-Status "Invalid structural input configuration value." -isError $true
        }
    })
    $Panel.Controls.Add($CommitBtn)
}

# --- INTERFACE: NETWORK MANAGEMENT UI ---
function Show-NetworkUI {
    $ContentWorkspace.Controls.Clear()
    $tm = $THEMES[$Global:ActiveTheme]

    $Panel = New-Object System.Windows.Forms.Panel
    $Panel.Dock = "Fill"
    $Panel.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.card)
    $ContentWorkspace.Controls.Add($Panel)

    $Label1 = New-Object System.Windows.Forms.Label
    $Label1.Text = "Identified System Interface Hardware profiles:"
    $Label1.Font = $FontTitle
    $Label1.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
    $Label1.Location = New-Object System.Drawing.Point(20, 20)
    $Label1.Size = New-Object System.Drawing.Size(600, 30)
    $Panel.Controls.Add($Label1)

    $ReturnBtn = New-Object System.Windows.Forms.Button
    $ReturnBtn.Text = "← Return to Workspace"
    $ReturnBtn.Font = $FontBtn
    $ReturnBtn.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#EF4444")
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
    $Box.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.bg)
    $Box.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
    $Box.Location = New-Object System.Drawing.Point(20, 60)
    $Box.Size = New-Object System.Drawing.Size(1235, 130)
    $Box.ReadOnly = $true
    $Adapters = Get-NetAdapter | Select-Object -ExpandProperty Name
    $Box.Text = $Adapters -join "`r`n"
    $Panel.Controls.Add($Box)

    $Label2 = New-Object System.Windows.Forms.Label
    $Label2.Text = "Input targeted adapter label string precisely:"
    $Label2.Font = $FontBtn
    $Label2.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
    $Label2.Location = New-Object System.Drawing.Point(20, 210)
    $Label2.Size = New-Object System.Drawing.Size(500, 25)
    $Panel.Controls.Add($Label2)

    $Entry = New-Object System.Windows.Forms.TextBox
    $Entry.Size = New-Object System.Drawing.Size(400, 35)
    $Entry.Location = New-Object System.Drawing.Point(20, 240)
    $Entry.Font = $FontBtn
    $Panel.Controls.Add($Entry)

    $BtnFrame = New-Object System.Windows.Forms.FlowLayoutPanel
    $BtnFrame.Location = New-Object System.Drawing.Point(20, 300)
    $BtnFrame.Size = New-Object System.Drawing.Size(800, 60)
    $Panel.Controls.Add($BtnFrame)

    $Actions = @("Disable", "Enable", "Restart")
    foreach ($act in $Actions) {
        $B = New-Object System.Windows.Forms.Button
        $B.Text = if ($act -eq "Restart") { "Power-Cycle Interfacer" } else { "$act Path" }
        $B.Font = $FontBtn
        $B.Size = New-Object System.Drawing.Size(220, 40)
        $B.FlatStyle = "Flat"
        $B.FlatAppearance.BorderSize = 0
        $B.ForeColor = [System.Drawing.Color]::White
        
        if ($act -eq "Disable") { $B.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#EF4444") }
        elseif ($act -eq "Enable") { $B.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#10B981") }
        else { $B.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.accent) }

        $B.Add_Click({
            $n = $Entry.Text.Trim()
            if (-not $n) { return }
            Update-Status "Sending active instructions to adapter pipeline node: $n"
            if ($act -eq "Disable") { Disable-NetAdapter -Name $n -Confirm:$false }
            elseif ($act -eq "Enable") { Enable-NetAdapter -Name $n -Confirm:$false }
            else { Restart-NetAdapter -Name $n -Confirm:$false }
            Update-Status "Successfully processed net interface target operation: $n"
            Render-Workspace
        })
        $BtnFrame.Controls.Add($B)
    }
}

# --- CORE RENDER ENGINES ---
function Render-Workspace {
    $ContentWorkspace.Controls.Clear()
    $tm = $THEMES[$Global:ActiveTheme]
    $currentSubs = $CONFIG[$Global:CurrentCategory]

    if ($Global:CurrentCategory -eq "Config") {
        $Wrapper = New-Object System.Windows.Forms.Panel
        $Wrapper.Dock = "Fill"
        $Wrapper.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.card)
        $ContentWorkspace.Controls.Add($Wrapper)

        $TitleLbl = New-Object System.Windows.Forms.Label
        $TitleLbl.Text = "Legacy System Administration Panels"
        $TitleLbl.Font = $FontTitle
        $TitleLbl.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
        $TitleLbl.Location = New-Object System.Drawing.Point(20, 20)
        $TitleLbl.Size = New-Object System.Drawing.Size(500, 30)
        $Wrapper.Controls.Add($TitleLbl)

        $Y = 70
        foreach ($subText in $currentSubs) {
            $B = New-Object System.Windows.Forms.Button
            $B.Text = "  $subText"
            $B.Font = $FontBtn
            $B.Size = New-Object System.Drawing.Size(1235, 38)
            $B.Location = New-Object System.Drawing.Point(20, $Y)
            $B.FlatStyle = "Flat"
            $B.TextAlign = "MiddleLeft"
            $B.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.bg)
            $B.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
            $B.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml($tm.accent)
            
            $B.Add_Click({ Resolve-Command $this.Text.Trim() })
            $Wrapper.Controls.Add($B)
            $Y += 44
        }
    } else {
        $LeftPanel = New-Object System.Windows.Forms.Panel
        $LeftPanel.Size = New-Object System.Drawing.Size(625, 520)
        $LeftPanel.Location = New-Object System.Drawing.Point(0, 0)
        $LeftPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.card)
        $ContentWorkspace.Controls.Add($LeftPanel)

        $RightPanel = New-Object System.Windows.Forms.Panel
        $RightPanel.Size = New-Object System.Drawing.Size(625, 520)
        $RightPanel.Location = New-Object System.Drawing.Point(650, 0)
        $RightPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.card)
        $ContentWorkspace.Controls.Add($RightPanel)

        $LTitle = New-Object System.Windows.Forms.Label
        $LTitle.Text = "⚡ Action Sequences"
        $LTitle.Font = $FontTitle
        $LTitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
        $LTitle.Location = New-Object System.Drawing.Point(20, 20)
        $LTitle.Size = New-Object System.Drawing.Size(300, 30)
        $LeftPanel.Controls.Add($LTitle)

        $RTitle = New-Object System.Windows.Forms.Label
        $RTitle.Text = "🛠 Interface Preferences"
        $RTitle.Font = $FontTitle
        $RTitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
        $RTitle.Location = New-Object System.Drawing.Point(20, 20)
        $RTitle.Size = New-Object System.Drawing.Size(300, 30)
        $RightPanel.Controls.Add($RTitle)

        $LY = 70; $RY = 70
        
        $splitThreshold = [Math]::Ceiling($currentSubs.Count / 2)
        
        for ($i=0; $i -lt $currentSubs.Count; $i++) {
            $subText = $currentSubs[$i]
            $B = New-Object System.Windows.Forms.Button
            
            if ($subText -eq "Optimize Performance") {
                if ($Global:OptimizeState) { $B.Text = "  Disable Performance Mode" }
                else { $B.Text = "  Optimize Performance (Enable)" }
            } else {
                $B.Text = "  $subText"
            }
            
            $B.Font = $FontBtn
            $B.Size = New-Object System.Drawing.Size(585, 40)
            $B.FlatStyle = "Flat"
            $B.TextAlign = "MiddleLeft"
            $B.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.bg)
            $B.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
            $B.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml($tm.accent)
            
            $B.Add_Click({ 
                $cmdLabel = $this.Text.Trim()
                if ($cmdLabel -match "Performance Mode$|Performance \(Enable\)$") {
                    Resolve-Command "Optimize Performance"
                } else {
                    Resolve-Command $cmdLabel
                }
            })

            if ($i -lt $splitThreshold) {
                $B.Location = New-Object System.Drawing.Point(20, $LY)
                $LeftPanel.Controls.Add($B)
                $LY += 50
            } else {
                $B.Location = New-Object System.Drawing.Point(20, $RY)
                $RightPanel.Controls.Add($B)
                $RY += 50
            }
        }
    }
}

function Render-Navigation {
    $TabContainer.Controls.Clear()
    $tm = $THEMES[$Global:ActiveTheme]

    foreach ($category in $CONFIG.Keys) {
        $isActive = ($category -eq $Global:CurrentCategory)
        $B = New-Object System.Windows.Forms.Button
        $B.Text = $category
        $B.Size = New-Object System.Drawing.Size(150, 42)
        $B.Font = $FontTab
        $B.FlatStyle = "Flat"
        $B.FlatAppearance.BorderSize = 0
        
        if ($isActive) {
            $B.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.accent)
            $B.ForeColor = [System.Drawing.Color]::White
        } else {
            $B.BackColor = [System.Drawing.Color]::Transparent
            $B.ForeColor = [System.Drawing.ColorTranslator]::FromHtml($tm.text)
        }

        $B.Add_Click({
            $Global:CurrentCategory = $this.Text
            Apply-ThemeEngine
            Update-Status "Switched view workspace focus context target to: $($this.Text)"
        })
        $TabContainer.Controls.Add($B)
    }
}

function Apply-ThemeEngine {
    $tm = $THEMES[$Global:ActiveTheme]
    $Form.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.bg)
    $TopHeader.BackColor = [System.Drawing.ColorTranslator]::FromHtml($tm.card)
    $NotificationBar.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")
    
    Render-Navigation
    Render-Workspace
}

# --- THEME DROPDOWN SETUP ---
$ThemeDropdown = New-Object System.Windows.Forms.ComboBox
$ThemeDropdown.Location = New-Object System.Drawing.Point(1100, 15)
$ThemeDropdown.Size = New-Object System.Drawing.Size(180, 40)
$ThemeDropdown.Font = $FontBtn
$ThemeDropdown.DropDownStyle = "DropDownList"
foreach ($key in $THEMES.Keys) { [void]$ThemeDropdown.Items.Add($key) }
$ThemeDropdown.SelectedItem = $Global:ActiveTheme
$ThemeDropdown.Add_SelectedIndexChanged({
    $Global:ActiveTheme = $ThemeDropdown.SelectedItem.ToString()
    Apply-ThemeEngine
    Update-Status "Global layout color themes synchronized to: '$($Global:ActiveTheme)'"
})
$TopHeader.Controls.Add($ThemeDropdown)

# --- EXECUTION INITIALIZATION ---
Apply-ThemeEngine
Log "Advanced Windows Optimization Core Engine Environment Initialized."
[System.Windows.Forms.Application]::Run($Form)
