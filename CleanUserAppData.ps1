# Rename Title Window
$host.ui.RawUI.WindowTitle = "Clean Browser Temp Files"

Function Cleanup {
    # Set Date for Log
    $LogDate = Get-Date -Format "MM-d-yy-HHmm"
	
	# Set Deletion Date for Recent Items Folder
    $RecentItemsDate = (Get-Date).AddDays(-7)

    # Set Deletion Date for Office File Cache Folder
    $DelOfficeCacheDate = (Get-Date).AddDays(-7)

    # Get current user
    $userprofile = $env:USERPROFILE 

    # Get Disk Size
    $Before = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,
    @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
    @{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f ( $_.Size / 1gb) } },
    @{ Name = "FreeSpace (GB)" ; Expression = { "{0:N1}" -f ( $_.Freespace / 1gb ) } },
    @{ Name = "PercentFree" ; Expression = { "{0:P1}" -f ( $_.FreeSpace / $_.Size ) } },
	@{ Name = "AppDataItemsCount" ; Expression = { "{0:N0}" -f ( Get-ChildItem $userprofile\AppData -Recurse -File | Measure-Object | %{$_.Count} ) } }	|
        Format-Table -AutoSize | Out-String

    # Define log file location
    $Cleanuplog = "$userprofile\Cleanup$LogDate.log"

    # Start Logging
    Start-Transcript -Path "$CleanupLog"

    # Begin!
    Write-Host -ForegroundColor Green "Beginning Script...`n"
	
	#Clearing Recycle Bin
	Write-Host -ForegroundColor Green "Clearing Recycle Bin`n"
	Clear-RecycleBin -Force -DriveLetter C
	
    # Clear Firefox Cache
    if (Test-Path "$userprofile\AppData\Local\Mozilla\Firefox\Profiles") {
        Write-Host -ForegroundColor Green "Clearing Firefox Cache`n"
            Remove-Item -Path "$userprofile\AppData\Local\Mozilla\Firefox\Profiles\*\cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "$userprofile\AppData\Local\Mozilla\Firefox\Profiles\*\cache2\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Mozilla\Firefox\Profiles\*\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Mozilla\Firefox\Profiles\*\thumbnails\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Mozilla\Firefox\Profiles\*\webappsstore.sqlite" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Mozilla\Firefox\Profiles\*\chromeappsstore.sqlite" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Mozilla\Firefox\Profiles\*\OfflineCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "$userprofile\AppData\Roaming\Mozilla\Firefox\Profiles\*\storage\default\*\cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Write-Host -ForegroundColor Yellow "Done...`n"
    }
	
    # Clear Google Chrome
    if (Test-Path "$userprofile\AppData\Local\Google\Chrome\User Data") {
        Write-Host -ForegroundColor Green "Clearing Google Chrome Cache`n"
            Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\Default\Service Worker\CacheStorage" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\Default\GPUCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\Default\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\Default\ChromeDWriteFontCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose

            # Check Chrome Profiles. It looks as though when creating profiles, it just numbers them Profile 1, Profile 2 etc.
            $Profiles = Get-ChildItem -Path "$userprofile\AppData\Local\Google\Chrome\User Data" | Select-Object Name | Where-Object Name -Like "Profile*"
            foreach ($Account in $Profiles) {
                $Account = $Account.Name 
                Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\$Account\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\$Account\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose 
                Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\$Account\Service Worker\CacheStorage" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\$Account\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\$Account\GPUCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "$userprofile\AppData\Local\Google\Chrome\User Data\$Account\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }
	
	# Clear Edge
    if (Test-Path "$userprofile\AppData\Local\Microsoft\Edge\User Data") {
        Write-Host -ForegroundColor Green "Clearing Google Chrome Cache`n"
            Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\Default\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\Default\GPUCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\Default\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\Default\ChromeDWriteFontCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose

            # Check Chrome Profiles. It looks as though when creating profiles, it just numbers them Profile 1, Profile 2 etc.
            $Profiles = Get-ChildItem -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data" | Select-Object Name | Where-Object Name -Like "Profile*"
            foreach ($Account in $Profiles) {
                $Account = $Account.Name 
                Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\$Account\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\$Account\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose 
                Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\$Account\Service Worker\CacheStorage" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\$Account\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\$Account\GPUCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Edge\User Data\$Account\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Clear Internet Explorer
    Write-Host -ForegroundColor Yellow "Clearing Internet Explorer`n"
        Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Windows\INetCache\* " -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Windows\WebCache\* " -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Write-Host -ForegroundColor Yellow "Done...`n"
	
	# Clear MS App Cache
    if (Test-Path "$userprofile\AppData\Local\Packages") {
        Write-Host -ForegroundColor Green "Clearing MS App Cache`n"
			Remove-Item -Path "$userprofile\AppData\Local\Packages\*\AC\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Packages\*\LocalCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
		Write-Host -ForegroundColor Yellow "Done...`n"
    }
	
	# Clear Web Experience
    if (Test-Path "$userprofile\AppData\Local\Packages\MicrosoftWindows.Client.WebExperience*") {
        Write-Host -ForegroundColor Green "Clearing Web Experience`n"
            Remove-Item -Path "$userprofile\AppData\Local\Packages\MicrosoftWindows.Client.WebExperience*\LocalState\EBWebView\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Packages\MicrosoftWindows.Client.WebExperience*\LocalState\EBWebView\Default\Service Worker\CacheStorage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
		Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Clear Chromium
    if (Test-Path "$userprofile\AppData\Local\Chromium") {
        Write-Host -ForegroundColor Yellow "Clearing Chromium Cache`n"
            Remove-Item -Path "$userprofile\AppData\Local\Chromium\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "$userprofile\AppData\Local\Chromium\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Chromium\User Data\Default\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Chromium\User Data\Default\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Chromium\User Data\Default\Pepper Data" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Chromium\User Data\Default\Application Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Write-Host -ForegroundColor Yellow "Done...`n" 
    }
    
    # Clear Opera
    if (Test-Path "$userprofile\AppData\Local\Opera Software") {
        Write-Host -ForegroundColor Yellow "Clearing Opera Cache`n"
            Remove-Item -Path "$userprofile\AppData\Local\Opera Software\Opera Stable\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Clear Yandex
    if (Test-Path "$userprofile\AppData\Local\Yandex") {
        Write-Host -ForegroundColor Yellow "Clearing Yandex Cache`n"
            Remove-Item -Path "$userprofile\AppData\Local\Yandex\YandexBrowser\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Yandex\YandexBrowser\User Data\Default\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "$userprofile\AppData\Local\Yandex\YandexBrowser\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Yandex\YandexBrowser\User Data\Default\Media Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Yandex\YandexBrowser\User Data\Default\Pepper Data\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Yandex\YandexBrowser\User Data\Default\Application Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Yandex\YandexBrowser\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Clear User Temp Folders
    Write-Host -ForegroundColor Yellow "Clearing User Temp Folders`n"
        Remove-Item -Path "$userprofile\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Windows\AppCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "$userprofile\AppData\Local\CrashDumps\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Write-Host -ForegroundColor Yellow "Done...`n"
     
    # Delete Microsoft Teams Previous Version files
    Write-Host -ForegroundColor Yellow "Clearing Teams Previous version`n"
	if (Test-Path "$userprofile\AppData\Local\Microsoft\Teams\") {
            Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Teams\previous\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Teams\stage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        } 
    Write-Host -ForegroundColor Yellow "Done...`n"
	
	# Delete Microsoft Teams Cache files
    Write-Host -ForegroundColor Yellow "Clearing Teams Cache`n"
	if (Test-Path "$userprofile\AppData\Local\Microsoft\Teams\") {
            Remove-Item -Path "$userprofile\AppData\Roaming\Microsoft\Teams\Service Worker\CacheStorage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "$userprofile\AppData\Roaming\Microsoft\Teams\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Roaming\Microsoft\Teams\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        } 
    Write-Host -ForegroundColor Yellow "Done...`n"
	
	# Delete Whatsapp Cache files
    Write-Host -ForegroundColor Yellow "Clearing Whatsapp Cache`n"
    if (Test-Path "$userprofile\AppData\Roaming\WhatsApp") {
            Remove-Item -Path "$userprofile\AppData\Roaming\WhatsApp\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "$userprofile\AppData\Roaming\WhatsApp\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Roaming\WhatsApp\Service Worker\CacheStorage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    }
    Write-Host -ForegroundColor Yellow "Done...`n"
	
	# Delete Discord Cache files
    Write-Host -ForegroundColor Yellow "Clearing Discord Cache`n"
    if (Test-Path "$userprofile\AppData\Roaming\Discord") {
            Remove-Item -Path "$userprofile\AppData\Roaming\Discord\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "$userprofile\AppData\Roaming\Discord\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Roaming\Discord\Service Worker\CacheStorage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        }
    Write-Host -ForegroundColor Yellow "Done...`n"
	
	# Delete RDP Cache files
    Write-Host -ForegroundColor Yellow "Clearing RDP Cache`n"
    if (Test-Path "$userprofile\AppData\Local\Microsoft\Terminal Server Client") {
            Remove-Item -Path "$userprofile\AppData\Local\Microsoft\Terminal Server Client\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        }
    Write-Host -ForegroundColor Yellow "Done...`n"

    # Delete Slack Cache files
    Write-Host -ForegroundColor Yellow "Clearing Slack Cache`n"
    if (Test-Path "$userprofile\AppData\Roaming\Slack") {
            Remove-Item -Path "$userprofile\AppData\Roaming\Slack\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "$userprofile\AppData\Roaming\Slack\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\AppData\Roaming\Slack\Service Worker\CacheStorage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        }
    Write-Host -ForegroundColor Yellow "Done...`n"

    # Clear Dropbox
    Write-Host -ForegroundColor Yellow "Clearing Dropbox Cache`n"
    if (Test-Path "$userprofile\Dropbox\") {
            Remove-Item -Path "$userprofile\Dropbox\.dropbox.cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "$userprofile\Dropbox*\.dropbox.cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        }
    Write-Host -ForegroundColor Yellow "Done...`n"

	
	# Delete files older than x days from Recent Items folder
    if (Test-Path "$userprofile\AppData\Roaming\Microsoft\Windows\Recent") {
        Write-Host -ForegroundColor Yellow "Deleting files older than " + $RecentItemsDate + " from Recent Items folder`n"
        $RecentItems = "$userprofile\AppData\Roaming\Microsoft\Windows\Recent"
        $OldFiles = Get-ChildItem -Path "$RecentItems\*.lnk" -Recurse -File -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $RecentItemsDate | Where-Object Extension -Like ".lnk"
        foreach ($file in $OldFiles) {
            Remove-Item -Path "$RecentItems\$file" -Force -ErrorAction SilentlyContinue -Verbose
        }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Delete files older than x days from Office Cache Folder
    Write-Host -ForegroundColor Yellow "Clearing Office Cache older than " + $DelOfficeCacheDate + " `n"
    $officecache = "$userprofile\AppData\Local\Microsoft\Office\16.0\GrooveFileCache"
        if (Test-Path $officecache) {
            $OldFiles = Get-ChildItem -Path "$officecache\" -Recurse -File -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $DelOfficeCacheDate 
            foreach ($file in $OldFiles) {
                Remove-Item -Path "$officecache\$file" -Force -ErrorAction SilentlyContinue -Verbose
            }
        } 
    Write-Host -ForegroundColor Yellow "Done...`n"

    # Get Drive size after clean
    $After = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,
    @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
    @{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f ( $_.Size / 1gb) } },
    @{ Name = "FreeSpace (GB)" ; Expression = { "{0:N1}" -f ( $_.Freespace / 1gb ) } },
    @{ Name = "PercentFree" ; Expression = { "{0:P1}" -f ( $_.FreeSpace / $_.Size ) } },
	@{ Name = "AppDataItemsCount" ; Expression = { "{0:N0}" -f ( Get-ChildItem $userprofile\AppData -Recurse -File | Measure-Object | %{$_.Count} ) } }	|
        Format-Table -AutoSize | Out-String

    # Sends some before and after info for ticketing purposes
    Write-Host -ForegroundColor Green "Before: $Before"
    Write-Host -ForegroundColor Green "After: $After"

    # Read some of the output before going away
    ###Start-Sleep -s 15

    # Completed Successfully!
    # Open Log File
    ###Invoke-Item $Cleanuplog

    # Stop Script
    Stop-Transcript
}

Cleanup
