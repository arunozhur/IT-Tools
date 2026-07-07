# ========================================================================
# ADVANCED SYSTEM ADMINISTRATION GUI UTILITY
# ========================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Main Window Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "System Administration Tool"
$form.Size = New-Object System.Drawing.Size(450, 500)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(249, 250, 251) # Off-White Background
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# --- Header Label ---
$header = New-Object System.Windows.Forms.Label
$header.Text = "SYSTEM ADMINISTRATION TOOL"
$header.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$header.ForeColor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$header.BackColor = [System.Drawing.Color]::FromArgb(99, 102, 241) # Indigo
$header.TextAlign = "MiddleCenter"
$header.Size = New-Object System.Drawing.Size(450, 60)
$form.Controls.Add($header)

# --- Output RichTextBox (For Results) ---
$outputBox = New-Object System.Windows.Forms.RichTextBox
$outputBox.Location = New-Object System.Drawing.Point(25, 260)
$outputBox.Size = New-Object System.Drawing.Size(385, 180)
$outputBox.ReadOnly = $true
$outputBox.Font = New-Object System.Drawing.Font("Consolas", 9.5)
$outputBox.BackColor = [System.Drawing.Color]::FromArgb(243, 244, 246) # Cool Gray
$outputBox.ForeColor = [System.Drawing.Color]::Black
$form.Controls.Add($outputBox)

# --- Helper Function to Create Styled Buttons ---
function Create-Button($text, $topPosition, $scriptBlock) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(385, 38)
    $btn.Location = New-Object System.Drawing.Point(25, $topPosition)
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.BackColor = [System.Drawing.Color]::FromArgb(99, 102, 241) # Indigo
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.Add_Click($scriptBlock)
    $form.Controls.Add($btn)
}

# --- Button Actions ---

# 1. System Info Action
$sysInfoAction = {
    $outputBox.Clear()
    $outputBox.AppendText("Fetching System Information...`n`n")
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    $cpu = Get-CimInstance Win32_Processor
    
    $outputBox.AppendText("Computer Name : $($cs.Name)`n")
    $outputBox.AppendText("OS Version    : $($os.Caption)`n")
    $outputBox.AppendText("Processor     : $($cpu.Name)`n")
    $outputBox.AppendText("Total Memory  : $([Math]::Round($cs.TotalPhysicalMemory / 1GB, 2)) GB`n")
}

# 2. Restart Spooler Action
$spoolerAction = {
    $outputBox.Clear()
    $outputBox.AppendText("Attempting to restart Print Spooler...`n")
    try {
        Stop-Service -Name "Spooler" -Force -ErrorAction Stop
        Start-Sleep -Seconds 1
        Start-Service -Name "Spooler" -ErrorAction Stop
        $outputBox.AppendText("`n[SUCCESS] Printer Spooler restarted successfully!")
    } catch {
        $outputBox.AppendText("`n[ERROR] Failed to restart Spooler.`nRun PowerShell as Administrator.")
    }
}

# 3. IP Config Action
$ipConfigAction = {
    $outputBox.Clear()
    $outputBox.AppendText("Active IPv4 Network Configuration:`n`n")
    $ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127*"}
    foreach ($ip in $ips) {
        $outputBox.AppendText("Interface : $($ip.InterfaceAlias)`n")
        $outputBox.AppendText("IP Address: $($ip.IPAddress)`n--------------------`n")
    }
}

# 4. Optimize Action
$optimizeAction = {
    $outputBox.Clear()
    $outputBox.AppendText("Clearing Temporary Files...`n")
    $tempPaths = @("$env:TEMP\*")
    foreach ($path in $tempPaths) {
        try { Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue } catch {}
    }
    $outputBox.AppendText("`n[SUCCESS] System temporary files optimized.")
}

# --- Create the GUI Buttons ---
Create-Button "1. View System & Hardware Info" 80  $sysInfoAction
Create-Button "2. Restart Printer Spooler Service" 125 $spoolerAction
Create-Button "3. View Network IP Configuration" 170 $ipConfigAction
Create-Button "4. Clear Temp Files & Optimize" 215 $optimizeAction

# --- Hide PowerShell Console Background ---
$window = Add-Type -memberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@ -name "Win32ShowWindow" -namespace Win32Functions -passThru

$form.Add_Shown({
    $consolePtr = [IntPtr]::Zero
    $process = [System.Diagnostics.Process]::GetCurrentProcess()
    $consolePtr = $process.MainWindowHandle
    if ($consolePtr -ne [IntPtr]::Zero) {
        $window::ShowWindow($consolePtr, 0) # Hide the black box
    }
})

# --- Run the GUI Application ---
[System.Windows.Forms.Application]::Run($form)
