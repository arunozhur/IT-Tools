# Ensure script runs with elevated Administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$irm_script`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- UI WINDOW ROOT ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Advanced Optimization Engine"
$form.Size = New-Object System.Drawing.Size(500,450)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#F4F7F5") # Forest Sage BG

# --- HEADER TITLE ---
$title = New-Object System.Windows.Forms.Label
$title.Text = "⚡ Action Sequences Dashboard"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#15803D") # Forest Accent
$title.Size = New-Object System.Drawing.Size(400,30)
$title.Location = New-Object System.Drawing.Point(30,20)
$form.Controls.Add($title)

# --- HELPER FUNCTION TO GENERATE PROFESSIONAL BUTTONS ---
function Create-AdminButton($text, $yPos, $scriptBlock) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(420, 40)
    $btn.Location = New-Object System.Drawing.Point(30, $yPos)
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btn.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#FFFFFF")
    $btn.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#1F2937")
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml("#15803D")
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    $btn.Add_Click($scriptBlock)
    $form.Controls.Add($btn)
}

# --- BUTTON 1: RESTART PRINTER SPOOLER ---
Create-AdminButton "1. Restart Print Spooler Engine" 80 {
    Write-Host "[ENGINE] Stopping Print Spooler..." -ForegroundColor Yellow
    Stop-Service -Name "Spooler" -Force
    Remove-Item "$env:SystemRoot\System32\Spool\Printers\*.*" -Force -ErrorAction SilentlyContinue
    Start-Service -Name "Spooler"
    [System.Windows.Forms.MessageBox]::Show("Print Spooler successfully recycled and caches cleared!", "Success")
}

# --- BUTTON 2: SYSTEM INTEGRITY SCAN ---
Create-AdminButton "2. Run SFC System Corruption Scan" 140 {
    Write-Host "[ENGINE] Launching SFC Integrity Verification Chain..." -ForegroundColor Green
    Start-Process cmd.exe -ArgumentList "/k sfc /scannow"
}

# --- BUTTON 3: FLUSH NETWORK DNS CACHE ---
Create-AdminButton "3. Flush Local DNS Resolver Cache" 200 {
    Clear-DnsClientCache
    [System.Windows.Forms.MessageBox]::Show("DNS cache purged successfully.", "Network Notification")
}

# --- BUTTON 4: OPTIMIZE POWER SCHEME ---
Create-AdminButton "4. Force High Performance Power Scheme" 260 {
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    [System.Windows.Forms.MessageBox]::Show("System shifted to High Performance Energy Matrix.", "Success")
}

# Display the layout view window
$form.ShowDialog()
