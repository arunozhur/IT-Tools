# ========================================================================
# ADVANCED WINDOWS OPTIMIZATION ENGINE - V5.2 (STABLE)
# ========================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$CONFIG = @{
    "Tweaks" = @("Restart Spooler", "Force Screen Timeout", "System Corruption Scan", "Clear Temp Files", "Optimize Performance", "Enable Long Paths", "Create Restore Point")
    "Config" = @("System Hardware Report", "Computer Management", "Control Panel", "Network Connections", "Power Panel", "Printer Panel", "Region", "Sound Settings", "System Properties", "Time and Date", "Check for Updates")
    "Automation" = @("Schedule Shutdown", "Schedule Restart", "Cancel Scheduled Task")
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
    
    $SMBIOS = $RAM[0].SMBIOSMemoryType
    $RType = if ($SMBIOS -eq 26) {"DDR4"} elseif ($SMBIOS -eq 34) {"DDR5"} elseif ($SMBIOS -eq 24) {"DDR3"} else {"Unknown"}
    $SType = if ($Disk.MediaType -eq 4) { "SSD / NVMe" } else { "HDD" }
    
    $Report = "--- OS & SYSTEM ---`r`nOS Name        : $($OS.Caption)`r`nSerial Number  : $($BIOS.SerialNumber)`r`nCPU            : $($CPU.Name)`r`n`r`n--- MEMORY (RAM) ---`r`nTotal RAM      : $([math]::Round(($RAM | Measure-Object Capacity -Sum).Sum / 1GB, 2)) GB`r`nRAM Type       : $RType`r`nSlots Total    : $($Array.MemoryDevices)`r`nSlots Used     : $($RAM.Count)`r`nSlots Available: $($Array.MemoryDevices - $RAM.Count)`r`n`r`n--- STORAGE ---`r`nDevice Type    : $SType`r`nModel          : $($Disk.Model)`r`nTotal Size     : $([math]::Round(($Disk.Size | Measure-Object -Sum).Sum / 1GB, 0)) GB"
    
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
        "check for updates" { Run-Cmd "start https://github.com/your-repo/latest" "Checking Updates..." }
        "system hardware report" { Get-SystemHardwareInfo }
        "computer management"    { Start-Process "compmgmt.msc" }
        "schedule shutdown" { $t = [Microsoft.VisualBasic.Interaction]::InputBox("Seconds:", "Shutdown", "3600"); if($t){Run-Cmd "shutdown /s /t $t" "Shutdown Scheduled"} }
        "schedule restart" { $t = [Microsoft.VisualBasic.Interaction]::InputBox("Seconds:", "Restart", "3600"); if($t){Run-Cmd "shutdown /r /t $t" "Restart Scheduled"} }
        "cancel scheduled task" { Run-Cmd "shutdown /a" "Tasks Cancelled" }
        default { Run-Cmd $txt $txt }
    }
}

# --- GUI SETUP ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Windows Optimization Engine"
$Form.Size = New-Object System.Drawing.Size(1350, 900)
$Form.StartPosition = "CenterScreen"
$FontBtn = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)

$TopHeader = New-Object System.Windows.Forms.Panel; $TopHeader.Height = 70; $TopHeader.Dock = "Top"; $Form.Controls.Add($TopHeader)
$TabContainer = New-Object System.Windows.Forms.FlowLayoutPanel; $TabContainer.Location = New-Object System.Drawing.Point(25, 12); $TabContainer.Size = New-Object System.Drawing.Size(800, 50); $TopHeader.Controls.Add($TabContainer)
$ContentWorkspace = New-Object System.Windows.Forms.Panel; $ContentWorkspace.Location = New-Object System.Drawing.Point(30, 90); $ContentWorkspace.Size = New-Object System.Drawing.Size(1275, 530); $Form.Controls.Add($ContentWorkspace)

foreach ($cat in $CONFIG.Keys) {
    $B = New-Object System.Windows.Forms.Button; $B.Text = $cat; $B.Size = New-Object System.Drawing.Size(150, 40); $B.Add_Click({ $Global:CurrentCategory = $this.Text; Render-Workspace }); $TabContainer.Controls.Add($B)
}

Render-Workspace
[System.Windows.Forms.Application]::Run($Form)
