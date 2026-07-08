# ========================================================================
# ADVANCED WINDOWS OPTIMIZATION ENGINE - V5.0 (WITH AUTOMATION & UPDATER)
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

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Windows Optimization Engine"
$Form.Size = New-Object System.Drawing.Size(1350, 900)
$Form.StartPosition = "CenterScreen"
$FontBtn = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)

$TopHeader = New-Object System.Windows.Forms.Panel; $TopHeader.Height = 70; $TopHeader.Dock = "Top"; $Form.Controls.Add($TopHeader)
$TabContainer = New-Object System.Windows.Forms.FlowLayoutPanel; $TabContainer.Location = New-Object System.Drawing.Point(25, 12); $TabContainer.Size = New-Object System.Drawing.Size(800, 50); $TopHeader.Controls.Add($TabContainer)
$ContentWorkspace = New-Object System.Windows.Forms.Panel; $ContentWorkspace.Location = New-Object System.Drawing.Point(30, 90); $ContentWorkspace.Size = New-Object System.Drawing.Size(1275, 530); $Form.Controls.Add($ContentWorkspace)

function Run-Cmd($command, $title) { Start-Process "cmd.exe" -ArgumentList "/k title $title && echo === Executing: $title === && echo. && $command" }

function Resolve-Command($label) {
    $txt = $label.Trim().ToLower()
    switch ($txt) {
        # Config
        "check for updates" { Run-Cmd "start https://your-website-url.com/latest-version" "Checking Updates..." }
        "system hardware report" { Get-SystemHardwareInfo }
        "computer management"    { Start-Process "compmgmt.msc" }
        # Automation
        "schedule shutdown" { 
            $t = [Microsoft.VisualBasic.Interaction]::InputBox("Enter time in seconds (e.g., 3600 for 1 hr):", "Shutdown", "3600")
            if($t){Run-Cmd "shutdown /s /t $t" "Shutdown Scheduled"} 
        }
        "schedule restart" { 
            $t = [Microsoft.VisualBasic.Interaction]::InputBox("Enter time in seconds:", "Restart", "3600")
            if($t){Run-Cmd "shutdown /r /t $t" "Restart Scheduled"} 
        }
        "cancel scheduled task" { Run-Cmd "shutdown /a" "Tasks Cancelled" }
        
        # ... (Keep existing Resolve-Command logic here)
        default { Run-Cmd $txt $txt }
    }
}

# --- REMAINING GUI FUNCTIONS (Get-SystemHardwareInfo, Render-Workspace, etc. as before) ---
# [Copy existing functions from V4.0 here]

Render-Workspace
[System.Windows.Forms.Application]::Run($Form)
