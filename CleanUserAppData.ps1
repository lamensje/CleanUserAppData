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
    $user = $env:USERNAME 

    # Get Disk Size
    $Before = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,
    @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
    @{ Name = "Size (GB)" ; Expression = { "{0:N1}" -f ( $_.Size / 1gb) } },
    @{ Name = "FreeSpace (GB)" ; Expression = { "{0:N1}" -f ( $_.Freespace / 1gb ) } },
    @{ Name = "PercentFree" ; Expression = { "{0:P1}" -f ( $_.FreeSpace / $_.Size ) } },
	@{ Name = "AppDataItemsCount" ; Expression = { "{0:N0}" -f ( Get-ChildItem C:\Users\$user\AppData -Recurse -File | Measure-Object | %{$_.Count} ) } }	|
        Format-Table -AutoSize | Out-String

    # Define log file location
    $Cleanuplog = "C:\users\$env:USERNAME\Cleanup$LogDate.log"

    # Start Logging
    Start-Transcript -Path "$CleanupLog"

    # Begin!
    Write-Host -ForegroundColor Green "Beginning Script...`n"

	#Delete .tmp files older than 2 days
	Write-Host -ForegroundColor Green "Removing old .tmp files`n"
	$Folder = "C:\Users\$user"
	Get-ChildItem $Folder\*.tmp -Recurse -Force -ea 0 |
	? {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-2)} |
	ForEach-Object {
		$_ | del -Force
		$_.FullName
	}
	
    # Clear Firefox Cache
    if (Test-Path "C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles") {
        Write-Host -ForegroundColor Green "Clearing Firefox Cache`n"
            Remove-Item -Path "C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*\cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*\cache2\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*\thumbnails\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*\webappsstore.sqlite" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*\chromeappsstore.sqlite" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Mozilla\Firefox\Profiles\*\OfflineCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "C:\Users\$user\AppData\Roaming\Mozilla\Firefox\Profiles\*\storage\default\*\cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Write-Host -ForegroundColor Yellow "Done...`n"
    }
	
    # Clear Google Chrome
    if (Test-Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data") {
        Write-Host -ForegroundColor Green "Clearing Google Chrome Cache`n"
            Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Service Worker\CacheStorage" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\GPUCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\ChromeDWriteFontCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose

            # Check Chrome Profiles. It looks as though when creating profiles, it just numbers them Profile 1, Profile 2 etc.
            $Profiles = Get-ChildItem -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data" | Select-Object Name | Where-Object Name -Like "Profile*"
            foreach ($Account in $Profiles) {
                $Account = $Account.Name 
                Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\$Account\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\$Account\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose 
                Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\$Account\Service Worker\CacheStorage" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\$Account\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\$Account\GPUCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "C:\Users\$user\AppData\Local\Google\Chrome\User Data\$Account\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }
	
	# Clear Edge
    if (Test-Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data") {
        Write-Host -ForegroundColor Green "Clearing Google Chrome Cache`n"
            Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\GPUCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\Default\ChromeDWriteFontCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose

            # Check Chrome Profiles. It looks as though when creating profiles, it just numbers them Profile 1, Profile 2 etc.
            $Profiles = Get-ChildItem -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data" | Select-Object Name | Where-Object Name -Like "Profile*"
            foreach ($Account in $Profiles) {
                $Account = $Account.Name 
                Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\$Account\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\$Account\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose 
                Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\$Account\Service Worker\CacheStorage" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\$Account\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\$Account\GPUCache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
                Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Edge\User Data\$Account\JumpListIconsOld" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Clear Internet Explorer
    Write-Host -ForegroundColor Yellow "Clearing Internet Explorer`n"
        Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Windows\INetCache\* " -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Windows\WebCache\* " -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Write-Host -ForegroundColor Yellow "Done...`n"
	
	# Clear MS App Cache
    if (Test-Path "C:\Users\$user\AppData\Local\Packages") {
        Write-Host -ForegroundColor Green "Clearing MS App Cache`n"
			Remove-Item -Path "C:\Users\$user\AppData\Local\Packages\*\AC\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Packages\*\LocalCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
		Write-Host -ForegroundColor Yellow "Done...`n"
    }
	
	# Clear Web Experience
    if (Test-Path "C:\Users\$user\AppData\Local\Packages\MicrosoftWindows.Client.WebExperience*") {
        Write-Host -ForegroundColor Green "Clearing Web Experience`n"
            Remove-Item -Path "C:\Users\$user\AppData\Local\Packages\MicrosoftWindows.Client.WebExperience*\LocalState\EBWebView\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Packages\MicrosoftWindows.Client.WebExperience*\LocalState\EBWebView\Default\Service Worker\CacheStorage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
		Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Clear Chromium
    if (Test-Path "C:\Users\$user\AppData\Local\Chromium") {
        Write-Host -ForegroundColor Yellow "Clearing Chromium Cache`n"
            Remove-Item -Path "C:\Users\$user\AppData\Local\Chromium\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "C:\Users\$user\AppData\Local\Chromium\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Chromium\User Data\Default\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Chromium\User Data\Default\Media Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Chromium\User Data\Default\Pepper Data" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Chromium\User Data\Default\Application Cache" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Write-Host -ForegroundColor Yellow "Done...`n" 
    }
    
    # Clear Opera
    if (Test-Path "C:\Users\$user\AppData\Local\Opera Software") {
        Write-Host -ForegroundColor Yellow "Clearing Opera Cache`n"
            Remove-Item -Path "C:\Users\$user\AppData\Local\Opera Software\Opera Stable\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Clear Yandex
    if (Test-Path "C:\Users\$user\AppData\Local\Yandex") {
        Write-Host -ForegroundColor Yellow "Clearing Yandex Cache`n"
            Remove-Item -Path "C:\Users\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\GPUCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "C:\Users\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\Media Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\Pepper Data\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Yandex\YandexBrowser\User Data\Default\Application Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Yandex\YandexBrowser\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Clear User Temp Folders
    Write-Host -ForegroundColor Yellow "Clearing User Temp Folders`n"
        Remove-Item -Path "C:\Users\$user\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Windows\AppCache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        Remove-Item -Path "C:\Users\$user\AppData\Local\CrashDumps\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    Write-Host -ForegroundColor Yellow "Done...`n"
     
    # Delete Microsoft Teams Previous Version files
    Write-Host -ForegroundColor Yellow "Clearing Teams Previous version`n"
	if (Test-Path "C:\Users\$user\AppData\Local\Microsoft\Teams\") {
            Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Teams\previous\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Teams\stage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        } 
    Write-Host -ForegroundColor Yellow "Done...`n"
	
	# Delete Microsoft Teams Cache files
    Write-Host -ForegroundColor Yellow "Clearing Teams Cache`n"
	if (Test-Path "C:\Users\$user\AppData\Local\Microsoft\Teams\") {
            Remove-Item -Path "C:\Users\$user\AppData\Roaming\Microsoft\Teams\Service Worker\CacheStorage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "C:\Users\$user\AppData\Roaming\Microsoft\Teams\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Roaming\Microsoft\Teams\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        } 
    Write-Host -ForegroundColor Yellow "Done...`n"
	
	# Delete Whatsapp Cache files
    Write-Host -ForegroundColor Yellow "Clearing Whatsapp Cache`n"
    if (Test-Path "C:\Users\$user\AppData\Roaming\WhatsApp") {
            Remove-Item -Path "C:\Users\$user\AppData\Roaming\WhatsApp\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "C:\Users\$user\AppData\Roaming\WhatsApp\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Roaming\WhatsApp\Service Worker\CacheStorage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
    }
    Write-Host -ForegroundColor Yellow "Done...`n"
	
	# Delete Discord Cache files
    Write-Host -ForegroundColor Yellow "Clearing Discord Cache`n"
    if (Test-Path "C:\Users\$user\AppData\Roaming\Discord") {
            Remove-Item -Path "C:\Users\$user\AppData\Roaming\Discord\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "C:\Users\$user\AppData\Roaming\Discord\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Roaming\Discord\Service Worker\CacheStorage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        }
    Write-Host -ForegroundColor Yellow "Done...`n"
	
	# Delete RDP Cache files
    Write-Host -ForegroundColor Yellow "Clearing RDP Cache`n"
    if (Test-Path "C:\Users\$user\AppData\Local\Microsoft\Terminal Server Client") {
            Remove-Item -Path "C:\Users\$user\AppData\Local\Microsoft\Terminal Server Client\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        }
    Write-Host -ForegroundColor Yellow "Done...`n"

    # Delete Slack Cache files
    Write-Host -ForegroundColor Yellow "Clearing Slack Cache`n"
    if (Test-Path "C:\Users\$user\AppData\Roaming\Slack") {
            Remove-Item -Path "C:\Users\$user\AppData\Roaming\Slack\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
			Remove-Item -Path "C:\Users\$user\AppData\Roaming\Slack\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\AppData\Roaming\Slack\Service Worker\CacheStorage\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        }
    Write-Host -ForegroundColor Yellow "Done...`n"

    # Clear Dropbox
    Write-Host -ForegroundColor Yellow "Clearing Dropbox Cache`n"
    if (Test-Path "C:\Users\$user\Dropbox\") {
            Remove-Item -Path "C:\Users\$user\Dropbox\.dropbox.cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Remove-Item -Path "C:\Users\$user\Dropbox*\.dropbox.cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose
        }
    Write-Host -ForegroundColor Yellow "Done...`n"

	
	# Delete files older than x days from Recent Items folder
    if (Test-Path "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Recent") {
        Write-Host -ForegroundColor Yellow "Deleting files older than " + $RecentItemsDate + " from Recent Items folder`n"
        $RecentItems = "C:\Users\$user\AppData\Roaming\Microsoft\Windows\Recent"
        $OldFiles = Get-ChildItem -Path "$RecentItems\" -Recurse -File -ErrorAction SilentlyContinue | Where-Object LastWriteTime -LT $RecentItemsDate
        foreach ($file in $OldFiles) {
            Remove-Item -Path "$RecentItems\$file" -Force -ErrorAction SilentlyContinue -Verbose
        }
        Write-Host -ForegroundColor Yellow "Done...`n"
    }

    # Delete files older than x days from Office Cache Folder
    Write-Host -ForegroundColor Yellow "Clearing Office Cache older than " + $DelOfficeCacheDate + " `n"
    $officecache = "C:\Users\$user\AppData\Local\Microsoft\Office\16.0\GrooveFileCache"
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
	@{ Name = "AppDataItemsCount" ; Expression = { "{0:N0}" -f ( Get-ChildItem C:\Users\$user\AppData -Recurse -File | Measure-Object | %{$_.Count} ) } }	|
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
