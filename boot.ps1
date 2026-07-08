# ========================================================================
# ADVANCED WINDOWS OPTIMIZATION ENGINE - V2.8 (DYNAMIC CONTROLS)
# ========================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CONFIGURATION MATRIX ---
$CONFIG = @{
    "Tweaks" = @("Restart Spooler", "Force Screen Timeout", "System Corruption Scan", "Clear Temp Files", "Optimize Performance", "Enable Long Paths", "Create Restore Point")
    "Config" = @("System Hardware Report", "Computer Management", "Control Panel", "Network Connections", "Power Panel", "Printer Panel", "Region", "Sound Settings", "System Properties", "Time and Date")
    "Network Tools" = @("Network Adaptor", "IP Config Overview", "Ping Diagnostic (8.8.8.8)", "GP Update Force", "Network Reset Sequence", "Flush DNS Cache", "View Active Connections", "Firewall Status Check", "NTP Server Sync", "OpenSSH Server Enable")
    "Fixes & Updates" = @("Windows Update Reset", "WinGet Reinstall", "Rebuild Icon Cache", "Reset Windows Store", "Repair Component Store", "Chkdsk Scan", "Fix Package Manager", "Restart Explorer", "Clear DNS Resolver", "Reset Winsock")
}

# --- GUI SETTINGS ---
$Global:ActiveTheme = "Forest Sage"
$Global:CurrentCategory = "Tweaks"
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Windows Optimization Engine"
$Form.Size = New-Object System.Drawing.Size(1350, 900)
$Form.StartPosition = "CenterScreen"
$FontBtn = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)

$TopHeader = New-Object System.Windows.Forms.Panel; $TopHeader.Height = 70; $TopHeader.Dock = "Top"; $Form.Controls.Add($TopHeader)
$TabContainer = New-Object System.Windows.Forms.FlowLayoutPanel; $TabContainer.Location = New-Object System.Drawing.Point(25, 12); $TabContainer.Size = New-Object System.Drawing.Size(800, 50); $TopHeader.Controls.Add($TabContainer)
$ContentWorkspace = New-Object System.Windows.Forms.Panel; $ContentWorkspace.Location = New-Object System.Drawing.Point(30, 90); $ContentWorkspace.Size = New-Object System.Drawing.Size(1275, 530); $Form.Controls.Add($ContentWorkspace)

# --- COMMAND EXECUTION ---
function Run-Cmd($command, $title) { Start-Process "cmd.exe" -ArgumentList "/k title $title && echo === Executing: $title === && echo. && $command" }

function Resolve-Command($label) {
    $txt = $label.Trim().ToLower()
    switch ($txt) {
        # Tweaks with dynamic logic
        "force screen timeout" {
            $minutes = [Microsoft.VisualBasic.Interaction]::InputBox("Enter timeout duration (in minutes):", "Screen Timeout", "60")
            if ($minutes -ne "") { Run-Cmd "powercfg /setacvalueindex scheme_current sub_video videoidle $($minutes * 60) && powercfg /setactive scheme_current" "Screen Timeout Set to $minutes mins" }
        }
        "optimize performance" {
            $choice = [System.Windows.Forms.MessageBox]::Show("Click Yes to Enable High Performance, No to return to Balanced.", "Optimize Performance", [System.Windows.Forms.MessageBoxButtons]::YesNoCancel)
            if ($choice -eq "Yes") { Run-Cmd "powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" "High Performance Enabled" }
            elseif ($choice -eq "No") { Run-Cmd "powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e" "Balanced Mode Restored" }
        }
        
        # Other Commands (Kept the same)
        "system hardware report" { Get-SystemHardwareInfo }
        "computer management"    { Start-Process "compmgmt.msc" }
        "restart spooler"        { Run-Cmd "net stop spooler && del /q /f /s %systemroot%\System32\Spool\Printers\* && net start spooler" "Spooler Reset" }
        "clear temp files"       { Run-Cmd "del /q /f /s %temp%\* && del /q /f /s C:\Windows\Temp\*" "Temp Files Purge" }
        default { Run-Cmd $txt $txt }
    }
}

# --- GUI RENDERERS ---
function Get-SystemHardwareInfo {
    $ContentWorkspace.Controls.Clear()
    $BIOS = Get-CimInstance Win32_BIOS; $CPU = Get-CimInstance Win32_Processor; $RAM = Get-CimInstance Win32_PhysicalMemory; $Slots = Get-CimInstance Win32_PhysicalMemoryArray; $Disk = Get-CimInstance MSFT_PhysicalDisk -Namespace root\Microsoft\Windows\Storage -ErrorAction SilentlyContinue
    $RAMType = if ($RAM[0].SMBIOSMemoryType -eq 26) { "DDR4" } elseif ($RAM[0].SMBIOSMemoryType -eq 34) { "DDR5" } else { "Unknown" }
    $DType = if ($Disk.MediaType -eq 4) { "SSD / NVMe" } else { "HDD" }
    $Report = "--- SYSTEM HARDWARE REPORT ---`r`nSerial Number  : $($BIOS.SerialNumber)`r`nCPU            : $($CPU.Name)`r`n`r`n--- MEMORY (RAM) ---`r`nTotal RAM      : $([math]::Round(($RAM | Measure-Object Capacity -Sum).Sum / 1GB, 2)) GB`r`nRAM Type       : $RAMType`r`nSlots Total    : $($Slots.MemoryDevices)`r`nSlots Used     : $($RAM.Count)`r`n`r`n--- STORAGE ---`r`nDevice Type    : $DType`r`nModel          : $($Disk.Model)`r`nTotal Size     : $([math]::Round(($Disk.Size | Measure-Object -Sum).Sum / 1GB, 0)) GB"
    $Box = New-Object System.Windows.Forms.TextBox; $Box.Multiline = $true; $Box.Font = [System.Drawing.Font]::new("Consolas", 11); $Box.Size = New-Object System.Drawing.Size(1235, 400); $Box.Location = New-Object System.Drawing.Point(20, 20); $Box.Text = $Report; $Box.ReadOnly = $true; $ContentWorkspace.Controls.Add($Box)
    $ReturnBtn = New-Object System.Windows.Forms.Button; $ReturnBtn.Text = "← Return"; $ReturnBtn.Location = New-Object System.Drawing.Point(20, 440); $ReturnBtn.Add_Click({ Render-Workspace }); $ContentWorkspace.Controls.Add($ReturnBtn)
}

function Render-Workspace {
    $ContentWorkspace.Controls.Clear(); $Y = 20
    foreach ($subText in $CONFIG[$Global:CurrentCategory]) {
        $B = New-Object System.Windows.Forms.Button; $B.Text = $subText; $B.Size = New-Object System.Drawing.Size(300, 40); $B.Location = New-Object System.Drawing.Point(20, $Y); $B.Font = $FontBtn; $B.Add_Click({ Resolve-Command $this.Text }); $ContentWorkspace.Controls.Add($B); $Y += 50
    }
}

foreach ($cat in $CONFIG.Keys) {
    $B = New-Object System.Windows.Forms.Button; $B.Text = $cat; $B.Size = New-Object System.Drawing.Size(150, 40); $B.Add_Click({ $Global:CurrentCategory = $this.Text; Render-Workspace }); $TabContainer.Controls.Add($B)
}

Render-Workspace
[System.Windows.Forms.Application]::Run($Form)
