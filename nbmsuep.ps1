Write-Host @"
  ________   ________  _____ ______   ________           ___  ___  _______   ________   
|\   ___  \|\   __  \|\   _ \  _   \|\   ____\         |\  \|\  \|\  ___ \ |\   __  \  
\ \  \\ \  \ \  \|\ /\ \  \\\__\ \  \ \  \___|_        \ \  \\\  \ \   __/|\ \  \|\  \ 
 \ \  \\ \  \ \   __  \ \  \\|__| \  \ \_____  \        \ \  \\\  \ \  \_|/_\ \   ____\
  \ \  \\ \  \ \  \|\  \ \  \    \ \  \|____|\  \        \ \  \\\  \ \  \_|\ \ \  \___|
   \ \__\\ \__\ \_______\ \__\    \ \__\____\_\  \        \ \_______\ \_______\ \__\   
    \|__| \|__|\|_______|\|__|     \|__|\_________\        \|_______|\|_______|\|__|   
                                       \|_________|                                    
"@ -ForegroundColor Cyan

Write-Host "usb event parser by nbm`n" -ForegroundColor White

$drives = Get-WinEvent -LogName System |
    Where-Object { $_.Message -match "USB" -or $_.Message -match "FAT32" -or $_.Message -match "NTFS" -or $_.Message -match "exFAT" } |
    Select-Object @{Name="TimeCreated"; Expression={ $_.TimeCreated.ToString("MM/dd/yyyy hh:mm tt") }},
                  @{Name="Label"; Expression={
                      if ($_.Message -match "label\s+'([^']+)'") { $matches[1] }
                      elseif ($_.Message -match "volume\s+([^\s]+)") { $matches[1] }
                  }},
                  @{Name="FileSystem"; Expression={
                      if ($_.Message -match "FAT32") {"FAT32"}
                      elseif ($_.Message -match "NTFS") {"NTFS"}
                      elseif ($_.Message -match "exFAT") {"exFAT"}
                  }},
                  @{Name="Event"; Expression={
                      if ($_.Message -match "removed") {"Dismount"}
                      elseif ($_.Message -match "configured" -or $_.Message -match "connected") {"Mount"}
                  }} |
    Where-Object { $_.Label -and $_.FileSystem }

if ($drives) {
    $drives
} else {
    Write-Output "no drives detected"
} -ForegroundColor Red

