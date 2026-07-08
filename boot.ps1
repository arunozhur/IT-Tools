# ========================================================================
# ADVANCED WINDOWS OPTIMIZATION ENGINE - V7.1 (STABLE & COMPATIBLE)
# ========================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$CONFIG = [ordered]@{
    "Tweaks" = @("Restart Spooler", "Force Screen Timeout", "System Corruption Scan", "Clear Temp Files", "Optimize Performance", "Enable Long Paths", "Create Restore Point")
    "Config" = @("System Hardware Report", "Computer Management", "Control Panel", "Network Connections", "Power Panel", "Printer Panel", "Region", "Sound Settings", "System Properties", "Time and Date", "Check for Updates")
    "Automation" = @("Schedule Shutdown", "Schedule Restart", "Cancel Scheduled Task", "View Shutdown/Restart Log")
    "Network Tools" = @("Network Adaptor", "IP Config Overview", "Ping Diagnostic (8.8.8.8)", "GP Update Force", "Network Reset Sequence", "Flush DNS Cache", "View Active Connections", "Firewall Status Check", "NTP Server Sync", "OpenSSH Server Enable")
    "Fixes & Updates" = @("Chkdsk Scan", "Restart Explorer", "Clear DNS Resolver", "Reset Winsock")
}

$Global:CurrentCategory = "Config"

# --- CORE FUNCTIONS ---
function Run-Cmd($command, $title) { 
    Start-Process "cmd.exe" -ArgumentList "/k title $title && echo === Executing: $title === && echo. && $command" 
}

function Get-SystemHardwareInfo {
    $ContentWorkspace.Controls.Clear()
    $OS = Get-CimInstance Win32_OperatingSystem
    $BIOS = Get-CimInstance Win32_BIOS
    $CPU = Get-CimInstance Win32_Processor
    $RAM = Get-CimInstance Win32_PhysicalMemory
    $Array = Get-CimInstance Win32_PhysicalMemoryArray
    $Disk = Get-CimInstance MSFT_PhysicalDisk -Namespace root\Microsoft\Windows\Storage -ErrorAction SilentlyContinue
    
    # Ternary ഒഴിവാക്കി സാധാരണ IF ഉപയോഗിക്കുന്നു
    $SType = "HDD"
    if ($Disk.MediaType -eq 4) { $SType = "SSD" }
    
    $Report = "--- OS & SYSTEM ---`r`nOS Name        : $($OS.Caption)`r`nCPU            : $($CPU.Name)`r`nRAM Capacity   : $([math]::Round(($RAM | Measure-Object Capacity -Sum).Sum / 1GB, 2)) GB`r`nSlots Used     : $($RAM.Count)`r`nStorage Type   : $SType"
    
    $Box = New-Object System.Windows.Forms.TextBox; $Box.Multiline = $true; $Box.Font = [System.Drawing.Font]::new("Consolas", 11); $Box.Size = New-Object System.Drawing.Size(1235, 400); $Box.Location = New-Object System.Drawing.Point(20, 20); $Box.Text = $Report; $Box.ReadOnly = $true; $ContentWorkspace.Controls.Add($Box)
    $ReturnBtn = New-Object System.Windows.Forms.Button; $ReturnBtn.Text = "← Return"; $ReturnBtn.Location = New-Object System.Drawing.Point(20, 440); $ReturnBtn.Add_Click({ Render-Workspace }); $ContentWorkspace.Controls.Add($ReturnBtn)
}

function Render-Workspace {
    $ContentWorkspace.Controls.Clear(); $Y = 20
    foreach ($subText in $CONFIG[$Global:CurrentCategory]) {
        $B = New-Object System.Windows.Forms.Button; $B.Text = $subText; $B.Size = New-Object System.Drawing.Size(300, 40); $B.Location = New-Object System.Drawing.Point(20, $Y); $B.Font = $FontBtn; $B.Add_Click({ Resolve-Command $this.Text }); $ContentWorkspace.Controls.Add($B); $Y += 50
    }
}

function Resolve-Command($label) {
    $txt = $label.Trim().ToLower()
    switch ($txt) {
        "system hardware report" { Get-SystemHardwareInfo }
        "check for updates"      { Run-Cmd "start https://github.com/your-repo/latest" "Checking Updates..." }
        "schedule shutdown"      { $t = [Microsoft.VisualBasic.Interaction]::InputBox("Seconds:", "Shutdown", "3600"); if($t){Run-Cmd "shutdown /s /t $t" "Shutdown Scheduled"} }
        "schedule restart"       { $t = [Microsoft.VisualBasic.Interaction]::InputBox("Seconds:", "Restart", "3600"); if($t){Run-Cmd "shutdown /r /t $t" "Restart Scheduled"} }
        "cancel scheduled task"  { Run-Cmd "shutdown /a" "Tasks Cancelled" }
        "view shutdown/restart log" { Run-Cmd "eventvwr.msc /c:System" "System Event Log (ID 1074)" }
        "restart spooler"        { Run-Cmd "net stop spooler && del /q /f /s %systemroot%\System32\Spool\Printers\* && net start spooler" "Spooler Reset" }
        "force screen timeout"   { $min = [Microsoft.VisualBasic.Interaction]::InputBox("Minutes:", "Timeout", "60"); if($min){$s=[int]$min*60; Run-Cmd "powercfg /setacvalueindex scheme_current sub_video videoidle $s && powercfg /setactive scheme_current" "Timeout Set"} }
        "optimize performance"   { $c = [System.Windows.Forms.MessageBox]::Show("Yes: High Perf, No: Balanced", "Mode", 4); if($c -eq 6){Run-Cmd "powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" "High Perf"}elseif($c -eq 7){Run-Cmd "powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e" "Balanced"} }
        default { Run-Cmd $txt $txt }
    }
}

# --- GUI SETUP ---
$Form = New-Object System.Windows.Forms.Form; $Form.Text = "Advanced Windows Optimization Engine"; $Form.Size = New-Object System.Drawing.Size(1350, 900); $Form.StartPosition = "CenterScreen"
$FontBtn = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$TopHeader = New-Object System.Windows.Forms.Panel; $TopHeader.Height = 70; $TopHeader.Dock = "Top"; $Form.Controls.Add($TopHeader)
$TabContainer = New-Object System.Windows.Forms.FlowLayoutPanel; $TabContainer.Location = New-Object System.Drawing.Point(25, 12); $TabContainer.Size = New-Object System.Drawing.Size(800, 50); $TopHeader.Controls.Add($TabContainer)
$ContentWorkspace = New-Object System.Windows.Forms.Panel; $ContentWorkspace.Location = New-Object System.Drawing.Point(30, 90); $ContentWorkspace.Size = New-Object System.Drawing.Size(1275, 530); $Form.Controls.Add($ContentWorkspace)

foreach ($cat in $CONFIG.Keys) {
    $B = New-Object System.Windows.Forms.Button; $B.Text = $cat; $B.Size = New-Object System.Drawing.Size(150, 40); $B.Add_Click({ $Global:CurrentCategory = $this.Text; Render-Workspace }); $TabContainer.Controls.Add($B)
}

Render-Workspace
[System.Windows.Forms.Application]::Run($Form)
