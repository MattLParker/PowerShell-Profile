 $ProVersion = "Version 2.3"
<#

PowerShell Profile $ProVersion

Author: Jeremy DeWitt aka JBear

Update Notes:
Version 2.3:
	-Upgraded GUI to XAML as opposed to WinForms.
	-Added CSV output functionality to reports when Export-CSV checkbox is checked.
	-Added test code for Create New User GUI. This is NOT functioning as currently intended.

Version 2.2:
	- Fixed bug in HotFix GUI button.
	- Adding checkbox to output to CSV file.

Version 2.1:
	- Tweaked several function outputs to GridView instead of writing to the shell; allows for searching, filtering, etc. of all outputs.
	- Added command completion pop-up messages for some functions.
	- Added confirmation prompt to Reboot button in GUI.
	- Added Windows Forms GUI capabilities to several functions; will continue to add.

Version 2.0:
	- Completed CreateNewUser function for automating User account creations and all helper functions.
	- Fixed Nithins Test-Path to look for the .HTA file; issue would arise if you had used SCCM function prior to Nithins.
	- Added .CSV removal from SAARConverter output folder to allow new files to pass through.
	- Tweaked UpdateProfile function to push to PowerShell and PowerShell ISE.

Version 1.9:
	- Fixed syntax error in installEXE that was causing a $Variable to be null.

Version 1.8:
	- Added specific Home Path to 'cd' command; set location to \\SERVERA01\IT\Documentation\PowerShell\Scripts.

Version 1.7:
	- Moved repository to permanent location. Changed file references to reflect changes.

Version 1.6:
	- Added ability to enter only number portion of property numbers to RDP and Ghost.
		(i.e. RDP 123456 or RDP COMPUTER123456; Ghost 123456 or Ghost COMPUTER123456)
	- Updated Get-Help for all functions included in this repository.

Version 1.5:
	- Fixed bugs for InstallEXE and InstallMSI that were catching due to first if(!() statement.	
	- Added custom MMC for SCCM Console.

Version 1.4:
	- Added remote GPupdate to interaction file | Commented out - processing issues.
	- Working on bug fixes for 

Version 1.3:
	- Added ADcleanup function to interaction file.
	- Added Nithins function, includes bringing down a local copy on current workstation.

Version 1.2:

	-Added Certificate removal function to list.

Version 1.1:
	- Removed InstallDate and Vendor from SWcheck function.
	- Added version notes to file updating process.
	- Changed Set-Location to my scripts folder "\\SERVERa01\transfer\JBear\Scripts".
	- Bug fixes.

	- Need to fix bugs in Create in SAARNewUser section.
	
#>

#Shell Window Setup
#$Shell = $Host.UI.RawUI
#$size = $Shell.BufferSize
#$size.width=150
#$size.height=5000
#$Shell.BufferSize = $size
#$size = $Shell.WindowSize
#$Shell.WindowSize = $size
#$shell.BackgroundColor = “Black”
#$shell.ForegroundColor = “White”
Set-Location "\\SERVERa01\IT\Documentation\PowerShell\Scripts"

#Update-Help

#Custom menu that lists currently available functions within the shell repository
function PrintMenu{
	Write-Host(" ------------------------------ ")
	Write-Host("| Bear Necessities $ProVersion |")
	Write-Host(" ------------------------------ ")
	Write-Host('Type "GUI" to launch GUI interface!')
	Write-Host("")
	Write-Host("Command           Function")
	Write-Host("-------           --------")
	Write-Host("ADcleanup         Remove specified workstation(s) from AD and SCCM")
	Write-Host("ADgroup           Copy Specified User Groups to Clipboard")
	Write-Host("cl                Clear Shell and Reprint Command Menu")
	Write-Host("CrossCertRm       Remove Inoperable Certificates From Specified Workstation(s)")
	Write-Host("Enac              Enable User Account in AD")
	Write-Host("GetSAM            Search For SAM Account Name By User Last Name")
	Write-Host("Ghost             Opens SCCM Ghost Session")
	Write-Host("GodMode           Access God Mode")
	Write-Host("GPR               Group Policy (Remote)")
	Write-Host("HuntUser          Query SCCM For Last System Logged On By Specified User")
	Write-Host("InstallEXE        Silent Install EXE's For Specified Workstation(s)")
	Write-Host("InstallMSI        Silent Install MSI's For Specified Workstation(s)")
	Write-Host("JavaCache         Clear Java Cache For Specified Workstation(s)")
	Write-Host("LastBoot          Last Reboot Time For Specified Workstation(s)")
	Write-Host("LoggedUser        Current Logged On User For Specified Workstation(s)")
	Write-Host("NetMSG            On-screen Message For Specified Workstation(s)")
	Write-Host("NewADuser         Create New Active Directory Users From SAAR Forms")
	Write-Host("Nithins           Opens Nithin's SCCM Client Tool")
	Write-Host("RDP               Remote Desktop")
	Write-Host("Reboot            Force Restart For Specified Workstation(s)")
	Write-Host("RmPrint           Clear Printer Drivers")
	Write-Host("SCCM              Active Directory/SCCM Console")	
	Write-Host("SWcheck           Check Installed Software For Specified Workstation(s)")
	Write-Host("SYS               All Remote System Info For Specified Workstation(s)")
	Write-Host("UpdateProfile     Update PowerShell Profile (Will Overwrite Current Version & Any Changes)")
	Write-Host("")
	Write-Host("")
}#End PrintMenu

Remove-Item Alias:cd
#Rebuild cd command
function cd {
	if ($args[0] -eq '-') {
	$pwd=$OLDPWD;} 
		else {
	$pwd=$args[0];}
	$tmp=pwd;
	if ($pwd) {
	#Enter Previous Working Directory when using cd - 
	Set-Location $pwd;}
	Set-Variable -Name OLDPWD -Value $tmp -Scope global;
}#End CD

#Set Home Path
(Get-PSProvider 'FileSystem').Home = '\\SERVERA01\IT\Documentation\PowerShell\Scripts'

#Pulls latest howtogeek.com link titles from their main page	
<#function Get-Latest {
	((Invoke-WebRequest -Uri 'http://howtogeek.com').Links | Where-Object class -eq "title").Title 
}#End Get-Latest#>

function cl {
    <# 
    .SYNOPSIS 
    Used to clear current PowerShell window

    .DESCRIPTION 
    Clears screen (same as clear) but, writes created 'PrintMenu' back onto the main shell for function reference

    .EXAMPLE 
    cl 
    #> 
	clear-host
	PrintMenu
}#End cl

function GodMode {
    <# 
    .SYNOPSIS 
    Access GodMode tools
 
    .EXAMPLE 
    GodMode
    #> 	
	#GodMode path based on current $env and current user
	$userpath = [environment]::getfolderpath("desktop")
	$godpath = "\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
	$finalpath = $userpath + $godpath
		if (!(Test-Path -Path $finalpath)) 
	{
	#Creates GodMode path for current user
	New-Item -Type directory -Path $finalpath -force | Out-Null
}	
	#Opens GodMode path
	Start-Process "$finalpath"
}#End GodMode

function ADgroup {
    <# 
    .SYNOPSIS 
    Copies specified users' AD Groups to clipboard - created for specific person who needed this information
 
    .EXAMPLE 
    ADGroup User1
    #> 	
	param(
	[Parameter(Mandatory=$true)]
	[string[]] $Username)
foreach ($Name in $UserName) {
	
	(Get-ADUser -Identity $name -property MemberOf | select MemberOf).MemberOf | %{Get-ADGroup $_} | Select Name | clip
    }
}#End ADgroup

function UpdateProfile {
    <# 
    .SYNOPSIS 
    Update PowerShell profile to current repository content

    .EXAMPLE 
    UpdateProfile 
    #> 

$NetworkLocation = "\\SERVERa01\IT\Documentation\PowerShell\Profile Repository\DevOps\TechProfile.txt"

$MyDocuments = [environment]::getfolderpath("mydocuments") + "\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
$MyDocuments2 = [environment]::getfolderpath("mydocuments") + "\WindowsPowerShell\Profile.ps1"

	#Overwrite current $Profile for PowerShell and PowerShell ISE
	Copy-Item -path "$NetworkLocation" -destination "$MyDocuments" -Force
	Copy-Item -path "$NetworkLocation" -destination "$MyDocuments2" -Force	

#Reload PowerShell
Powershell
	
}#End UpdateProfile

#Opens SCCM Admin Console.msc
function SCCM {
    <# 
    .SYNOPSIS 
    Opens pre-generated Active Directory and SCCM mmc

    .EXAMPLE 
    SCCM  
    #> 
	$pat1 = "\\SERVERa01\it\Applications\Microsoft (Multiple Items)\SCCM (Item 3107)\Admin Console.msc"
	$dir1 = "C:\Program Files (x86)\SCCM Tools"
	$des1 = $dir1 + "\Admin Console.msc"
if (!(Test-Path -Path $dir1)) {
	#Creates SCCM Console path
	New-Item -Type directory -Path $dir1 -force | Out-Null
	Copy-Item $pat1 $des1 -Force
}

if (Test-Path -Path $dir1) {
	Copy-Item $pat1 $des1
}
	#Opens SCCM Admin Console
	Start-Process "$des1"
}#End SCCM

clear-host
PrintMenu
function GetSAM {
    <# 
    .SYNOPSIS 
    Retrieve users' SAM account name based on full or partial name search. 

    .Parameter GivenName
    Search user by Given Name. Default search is by Surname.

    .DESCRIPTION
    The GetSAM function uses the Get-ADUser cmdlet to query Active Directory for all users including the value entered (i.e. Users' first name (using -GivenName parameter), or users' last name (Default search Surname).
 
    .EXAMPLE 
    GetSAM Smith

    .EXAMPLE 
    GetSAM Smi 

    .EXAMPLE 
    GetSAM -GivenName John

    .EXAMPLE
    GetSAM -GivenName Jo
    #>

Param([parameter(Mandatory=$true)] 
        [string[]]$NameValue,
        [Switch]$GivenName)

    $name = switch ($GivenName.IsPresent) {
	    $true { "GivenName" }
	    default { "Surname" }
    }

    #Get SAM Account Name for specified user
    Get-ADUser -Filter "$Name -like '$NameValue*'" | FT GivenName, SurName, SamAccountName	
}#End GetSAM

function HuntUser {
    <# 
    .SYNOPSIS 
    Retrieve workstation(s) last logged on by user (SAM Account Name)

    .DESCRIPTION 
    The HuntUser function will retrieve workstation(s) by the last logged on user (SAM Account Name). This queries SCCM; accuracy will depend on the last time each workstation has communicated with SCCM.

    .EXAMPLE 
    HuntUser dewittj 
    #> 
	Param([parameter(Mandatory = $true)]$SamAccountName,
	#SCCM Site Name
    $SiteName="ABC",
	#SCCM Server Name
    $SCCMServer="SERVERV02")
	#SCCM Namespace
    $SCCMNameSpace="root\sms\site_$SiteName"
	#Calls SCCM Server Query for list of workstations last logged on by specified SAM account name
    Get-WmiObject -namespace $SCCMNameSpace -computer $SCCMServer -query "select Name from sms_r_system where LastLogonUserName='$SamAccountName'" | select Name
}#End HuntUser

function LoggedUser{
    <# 
    .SYNOPSIS 
    Retrieve current user logged into specified workstations(s) 

    .EXAMPLE 
    LoggedUser COMPUTER123456 

    .EXAMPLE 
    LoggedUser 123456 
    #> 
	Param([Parameter(Mandatory=$true)]
	[string[]] $ComputerName)
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}
	write-host("")
	write-host("Gathering resources. Please wait...")
	write-host("")
foreach ($Computer in $ComputerName) 
{
	$computerSystem = Get-CimInstance CIM_ComputerSystem -Computer $Computer
	Write-Host "User Logged In: " + $computerSystem.UserName
	Write-Host ""
	}
}#End LoggedUser

　
#Imports AD/SCCM console; Active Directory module needed
Import-Module ActiveDirectory

#Reboots specified workstation(s)
function Reboot {
    <# 
    .SYNOPSIS 
    Restarts specified workstation(s) 

    .EXAMPLE 
    Reboot COMPUTER123456 

    .EXAMPLE 
    Reboot 123456 

    .EXAMPLE
    Reboot (Get-Content C:\SomeDirectory\WhateverTextFileYouWant.txt)
    #> 
	param(
	[Parameter(Mandatory=$true)]
	[string[]] $ComputerName)
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}
foreach ($Computer in $ComputerName) {
	#Force reboot on specified workstation or array
	restart-computer $Computer -Force
	}
[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$RebootConfirmation = [Microsoft.VisualBasic.Interaction]::MsgBox("Reboot sequence has been started on workstation(s)!", "OKOnly,SystemModal,Information", "Success")

}#End Reboot

 
#ActiveDirectory module needed
function Ghost {
    <# 
    .SYNOPSIS 
    Opens Ghost session to specified workstation(s) 

    .EXAMPLE 
    Ghost COMPUTER123456 

    .EXAMPLE 
    Ghost 123456 
    #> 
	param(
	[Parameter(Mandatory=$true)]
	[string]$computername)
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}

	#Start 'Ghost' or interactive Remote Tools session with specified workstation 
	Start-Process 'C:\Program Files (x86)\Microsoft Configuration Manager Console\AdminUI\bin\i386\rc.exe' "1 $Computername"   

}#End Ghost

 
function RDP {
    <# 
    .SYNOPSIS 
    Remote Desktop Protocol to specified workstation(s) 

    .EXAMPLE 
    RDP COMPUTER123456 

    .EXAMPLE 
    RDP 123456 
    #> 
	param(
	[Parameter(Mandatory=$true)]
	[string]$computername)
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}

	#Start Remote Desktop Protocol on specifed workstation
	& "C:\windows\system32\mstsc.exe" /v:$computername /fullscreen
}#End RDP

function GPR {
    <# 
    .SYNOPSIS 
    Open Group Policy for specified workstation(s) 

    .EXAMPLE 
    GPR COMPUTER123456 

    .EXAMPLE 
    GPR 123456 
    #> 
	param(
	[Parameter(Mandatory=$true)]
	[string[]] $ComputerName)
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}
		foreach ($Computer in $ComputerName) {

	#Opens (Remote) Group Policy for specified workstation
	gpedit.msc /gpcomputer: $Computer
    
	}
}#End GPR

function Enac {
    <# 
    .SYNOPSIS 
    Enable User Account in AD; Requires proper permissions. Search by partial or full last name, manually enter SAM Account Name.
  
    .EXAMPLE 
    Enac Smith

    .EXAMPLE 
    Enac Smi 
    #> 
	$last = Read-Host -Prompt 'Search by Last Name'
	#Last Name search for Active Directory users - Returns First, Last, & SAM Account Name
	Get-ADUser -Filter "Surname -like '$last*'" | FT GivenName,Surname,SamAccountName
	#Enter desired SAM Account Name to enable user account, if disabled
		Enable-ADAccount –Identity (Read-Host “Enter Desired Username”)
	write-host("")
	write-host("Specified Account Unlocked!")
	write-host("")
}#End Enac

function LastBoot {
    <# 
    .SYNOPSIS 
    Retrieve last restart time for specified workstation(s) 

    .EXAMPLE 
    LastBoot COMPUTER123456 

    .EXAMPLE 
    LastBoot 123456 
    #> 
    param([Parameter(Mandatory=$true)]
	[string[]] $ComputerName)
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}
foreach ($Computer in $ComputerName) {      
    New-Object psobject -Property @{
    "Computer Name" = $Computer
    "Last Boot Time" = [Management.ManagementDateTimeConverter]::ToDateTime( (Get-WmiObject -Class Win32_OperatingSystem -Computer $Computer | Select -Exp "Last Boot Time") )}
    }
}#End LastBoot

　
function SYS {
    <# 
    .SYNOPSIS 
    Retrieve basic system information for specified workstation(s) 

    .EXAMPLE 
    SYS COMPUTER123456 

    .EXAMPLE 
    SYS 123456 
    #> 
	param(
	[Parameter(Mandatory=$true)]
	[string[]] $ComputerName)
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}

$Stamp = (Get-Date -Format G) + ":"
$ComputerArray = @()

function Systeminformation {	
foreach ($Computer in $ComputerArray) {

	$x64 = "\\$computer\C$\Program Files (x86)"
	
    if(Test-Path -Path $x64) {
	    #Gather specified workstation information; CimInstance only works on 64-bit
	    $computerSystem = Get-CimInstance CIM_ComputerSystem -Computer $Computer
	    $computerBIOS = Get-CimInstance CIM_BIOSElement -Computer $Computer
	    $computerOS = Get-CimInstance CIM_OperatingSystem -Computer $Computer
	    $computerCPU = Get-CimInstance CIM_Processor -Computer $Computer
	    $computerHDD = Get-CimInstance Win32_LogicalDisk -Computer $Computer -Filter "DeviceID = 'C:'"
    
            [pscustomobject]@{
                "Computer Name"=$Computer
                "Last Reboot"=$computerOS.LastBootUpTime
                "Operating System"=$computerOS.OSArchitecture + " " + $computerOS.caption
                    Model=$computerSystem.Model
                    RAM= "{0:N2}" -f [int]($computerSystem.TotalPhysicalMemory/1GB) + "GB"
                "Disk Capacity"="{0:N2}" -f ($computerHDD.Size/1GB) + "GB"
                "Total Disk Space"="{0:P2}" -f ($computerHDD.FreeSpace/$computerHDD.Size) + " Free (" + "{0:N2}" -f ($computerHDD.FreeSpace/1GB) + "GB)"
                "Current User"=$computerSystem.UserName
            }

}
	else {
	    #Gather specified workstation information; uses WmiObject for 32-bit
        $ComputerProgram = Get-WmiObject -class Win32_Product | Select-Object -Property Name | Sort-Object Name 
        $computerSystem = Get-WmiObject Win32_ComputerSystem -Computer $Computer
        $computerBIOS = Get-WmiObject Win32_BIOS -Computer $Computer
        $computerOS = Get-WmiObject Win32_OperatingSystem -Computer $Computer
        $computerCPU = Get-WmiObject Win32_Processor -Computer $Computer
        $computerHDD = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter drivetype=3

　
            [pscustomobject]@{
                "Computer Name"=$Computer
                "Last Reboot"=$computerOS.ConvertToDateTime($computerOS.LastBootUpTime)
                "Operating System"=$computerOS.OSArchitecture + " " + $computerOS.caption
                    Model=$computerSystem.Model
                    RAM= "{0:N2}" -f [int]($computerSystem.TotalPhysicalMemory/1GB) + "GB"
                "Disk Capacity"="{0:N2}" -f ($computerHDD.Size/1GB) + "GB"
                "Total Disk Space"="{0:P2}" -f ($computerHDD.FreeSpace/$computerHDD.Size) + " Free (" + "{0:N2}" -f ($computerHDD.FreeSpace/1GB) + "GB)"
                "Current User"=$computerSystem.UserName
            }
    
        		}

    		} 
	}

	foreach ($computer in $ComputerName) {	     
		If (Test-Connection -quiet -count 1 -Computer $Computer) {
		    
		    $ComputerArray += $Computer
		}
	}

	$SystemInformation = SystemInformation | Sort ComputerName | Select "Computer Name", "Current User", "Operating System", Model, RAM, "Disk Capacity", "Total Disk Space", "Last Reboot"
	$DocPath = [environment]::getfolderpath("mydocuments") + "\SystemInformation-Report.csv"

		Switch ($CheckBox.IsChecked){
		    $true { $SystemInformation | Export-Csv $DocPath -NoTypeInformation -Force; }
		    default { $SystemInformation | Out-GridView -Title "System Information"; }
		
    }

	if ($CheckBox.IsChecked -eq $true){
	    Try { 
		$listBox.Items.Add("$stamp Export-CSV to $DocPath!`n")
	    } 

	    Catch {
		    #Do Nothing 
	    }
	}
	
	else{
	    Try {
	        $listBox.Items.Add("$stamp System Information output processed!`n")
	    } 
	    Catch {
	        #Do Nothing 
	    }
	}
}#End SYS

function RmPrint {
    <# 
    .SYNOPSIS 
    Remove printer drivers from registry of specified workstation(s) 

    .EXAMPLE 
    RmPrint COMPUTER123456 

    .EXAMPLE 
    RmPrint 123456 
    #> 
	param([Parameter(Mandatory=$true)]
	[string[]]$computername)
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}

function RmPrintDrivers {
 	
foreach ($Computer in $ComputerName) { 
	Try {
		$RemoteSession = New-PSSession -ComputerName $Computer
		write-host "Removing printer drivers... Please wait..."
}
	Catch {
		"Something went wrong. Unable to connect to $Computer"
		Break
}
	Invoke-Command -Session $RemoteSession -ScriptBlock {
    # Removes print drivers, other than default image drivers
		if ((Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows x64\') -eq $true) {
			Remove-Item -PATH 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows x64\Drivers\Version-3\*' -EXCLUDE "*ADOBE*", "*MICROSOFT*", "*XPS*", "*REMOTE*", "*FAX*", "*ONENOTE*" -recurse
			Remove-Item -PATH 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\*' -EXCLUDE "*ADOBE*", "*MICROSOFT*", "*XPS*", "*REMOTE*", "*FAX*", "*ONENOTE*" -recurse
		Set-Service Spooler -startuptype manual
		Restart-Service Spooler
		Set-Service Spooler -startuptype automatic
			}
		}
	} RmPrintDrivers
}
	Remove-PSSession *

[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$RMprintConfirmation = [Microsoft.VisualBasic.Interaction]::MsgBox("Print drivers have been cleared on workstation(s)!", "OKOnly,SystemModal,Information", "Success")

}#End RmPrint

#Removes botched Office 2013 installations due to Programs and Features removal not working
#This function is commented out; due to specifics of function, keeping code for future reference
<#function rmOffice {
$ErrorActionPreference= 'silentlycontinue'
$Workstation = (Read-Host -Prompt "Enter Workstation")

Try {
    $RemoteSession = New-PSSession -ComputerName $Workstation
}
Catch {
    "Something went wrong. Unable to connect to $Workstation"
    Break
}
Invoke-Command -Session $RemoteSession -ScriptBlock {

	New-PSDrive -PSProvider registry -root HKEY_CLASSES_ROOT -Name HKCR
	write-host ""
	write-host "Removing Microsoft Office 2013 registry and file components... Please Wait..."
	New-PSDrive -PSProvider registry -root HKEY_CURRENT_USER -Name HKCU | Out-Null
	remove-item -path 'C:\Program Files (x86)\Common Files\microsoft shared\OFFICE15' -force -recurse | Out-Null
	remove-item -path 'C:\Program Files (x86)\Common Files\microsoft shared\Source Engine' -force -recurse | Out-Null
	remove-item -path 'C:\Program Files (x86)\Microsoft Office\Office15' -force -recurse | Out-Null
	remove-item -path 'C:\MSOCache\All Users\*0FF1CE}*' -force -recurse | Out-Null
	remove-item -path '*\AppData\Roaming\Microsoft\Templates\*.dotm' -force -recurse | Out-Null
	remove-item -path '*\AppData\Roaming\Microsoft\Templates\*.dotx' -force -recurse | Out-Null
	remove-item -path '*\AppData\microsoft\document building blocks\*.dotx' -force -recurse | Out-Null
	remove-item -path 'HKCU:\Software\Microsoft\Office\15.0' -recurse | Out-Null
	remove-item -path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\15.0' -recurse | Out-Null
	remove-item -path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\Delivery\SourceEngine\Downloads\*0FF1CE}-*' -recurse | Out-Null
	remove-item -path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*0FF1CE*' -recurse | Out-Null
	remove-item -path 'HKLM:\SYSTEM\CurrentControlSet\Services\ose' -recurse | Out-Null
	remove-item -path 'HKCR:\Installer\Features\*F01FEC' -recurse | Out-Null
	remove-item -path 'HKCR:\Installer\Products\*F01FEC' -recurse | Out-Null
	remove-item -path 'HKCR:\Installer\UpgradeCodes\*F01FEC' -recurse | Out-Null
	remove-item -path 'HKCR:\Installer\Win32Asemblies\*Office15*' -recurse | Out-Null
	Remove-Item -path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*Office15*' -recurse | Out-Null
	write-host ""
	write-host "Object removal complete..."}
Remove-PSSession *
}#>#End RmOffice

　
function NetMSG{
    <# 
    .SYNOPSIS 
    Generate a pop-up window on specified workstation(s) with desired message 

    .EXAMPLE 
    NetMSG COMPUTER123456 

    .EXAMPLE 
    NetMSG 123456 
    #> 
	#Network messaging is disabled on the domain - this is a workaround for the same type of results
	param([Parameter(Mandatory=$true)][string[]] $ComputerName)
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}
	$ReadMe = read-host -prompt("Enter desired message")
	$User = [Environment]::UserName
	$UserInfo = Get-ADUser $User -Property Title | Select Title
	$UserJob = $UserInfo.Title
	
foreach($Computer in $ComputerName){
	$g = $ReadMe
	$CallBack = "$User | 5-2444 | $UserJob"

		#Invoke local MSG command on specified workstation - will generate pop-up message for any user logged onto that workstation - *Also shows on Login screen, stays there for 100,000 seconds or until interacted with
		invoke-command -computername $Computer {
		param($g, $CallBack, $User, $UserInfo, $UserJob) msg /time:100000 * /v "$g {$CallBack}"} -argumentlist $g, $CallBack, $User, $UserInfo, $UserJob}

}#End NetMSG

function SWcheck {
    <# 
    .SYNOPSIS 
    Grabs all installed Software on specified workstation(s) 

    .EXAMPLE 
    SWcheck COMPUTER123456 

    .EXAMPLE 
    SWcheck 123456 
    #> 
    param (
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [string]$NameRegex = '')
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}

$Stamp = (Get-Date -Format G) + ":"
$ComputerArray = @()

function SoftwareCheck {
    foreach ($computer in $ComputerArray) {
        $keys = '','\Wow6432Node'
        foreach ($key in $keys) {
            try {
                $apps = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$computer).OpenSubKey("SOFTWARE$key\Microsoft\Windows\CurrentVersion\Uninstall").GetSubKeyNames()
            } catch {
                continue
            }

            foreach ($app in $apps) {
                $program = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$computer).OpenSubKey("SOFTWARE$key\Microsoft\Windows\CurrentVersion\Uninstall\$app")
                $name = $program.GetValue('DisplayName')
                if ($name -and $name -match $NameRegex) {
                    [pscustomobject]@{
                        "Computer Name" = $computer
                        Software = $name
                        Version = $program.GetValue('DisplayVersion')
                        Publisher = $program.GetValue('Publisher')
                        "Install Date" = $program.GetValue('InstallDate')
                        "Uninstall String" = $program.GetValue('UninstallString')
                        Bits = $(if ($key -eq '\Wow6432Node') {'64'} else {'32'})
                        Path = $program.name
                    }
                }
            }
        } 
    }
}	

foreach ($computer in $ComputerName) {	     
    If (Test-Connection -quiet -count 1 -Computer $Computer) {
		    
        $ComputerArray += $Computer
    }	
}
	$SoftwareCheck = SoftwareCheck | Sort "Computer Name" | Select "Computer Name", Software, Version, Publisher, "Install Date", "Uninstall String", Bits, Path
    	$DocPath = [environment]::getfolderpath("mydocuments") + "\Software-Report.csv"

    		Switch ($CheckBox.IsChecked){
    		    $true { $SoftwareCheck | Export-Csv $DocPath -NoTypeInformation -Force; }
    		    default { $SoftwareCheck | Out-GridView -Title "Software"; }
		}
		
	if ($CheckBox.IsChecked -eq $true){
	    Try { 
		$listBox.Items.Add("$stamp Export-CSV to $DocPath!`n")
	    } 

	    Catch {
		    #Do Nothing 
	    }
	}
	
	else{
	    Try {
	        $listBox.Items.Add("$stamp Software output processed!`n")
	    } 
	    Catch {
	        #Do Nothing 
	    }
	}
}#End SWcheck

　
function JavaCache {
    <# 
    .SYNOPSIS 
    Clear Java cache on specified workstation(s) 

    .EXAMPLE 
    JavaCache COMPUTER123456 

    .EXAMPLE 
    JavaCache 123456 
    #> 
[cmdletbinding()]
	Param ( #Define a Mandatory name input
	[Parameter(
	ValueFromPipeline=$true,
	ValueFromPipelinebyPropertyName=$true, 
	Position=0)]
	[Alias('Computer', 'ComputerName', 'Server', '__ServerName')]
		[string[]]$name = $ENV:Computername,
	[Parameter(Position=1)]
		[string]$progress = "Yes"
	) #End Param

ForEach ($computer in $name){

Try {
	$RemoteSession = New-PSSession -ComputerName $computer
	Invoke-Command -Session $RemoteSession -ScriptBlock {&"javaws" '-uninstall'}
	Remove-PSSession *
}
Catch {
	"Something went wrong. Can't connect to $computer. Sorry!"
	Remove-PSSession *
	Break
		} 
	}
[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$JavaConfirmation = [Microsoft.VisualBasic.Interaction]::MsgBox("Java cache has been cleared on workstation(s)!", "OKOnly,SystemModal,Information", "Success")
}#End JavaCache

　
　
function ADcleanup {
    <# 
    .SYNOPSIS 
    Removes workstation(s) from Active Directory and SCCM 

    .EXAMPLE 
    ADcleanup COMPUTER123456 
    #> 
	Param([parameter(Mandatory = $true)] [string[]]$computerName,
	#SCCM Site Name
    $SiteName="ABC",
	#SCCM Server Name
    $SCCMServer="SERVERV02")
	#SCCM Namespace
    $SCCMNameSpace="root\sms\site_$SiteName"
foreach ($Computer in $computerName) {
	
	#Find and delete specified workstation(s) from Active Directory
	$dom = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
	$root = $dom.GetDirectoryEntry()
	$search = [System.DirectoryServices.DirectorySearcher]$root
	$search.filter = "(&(objectclass=computer)(name=$Computer))"
	$search.findall() | %{$_.GetDirectoryEntry() } | %{$_.DeleteObject(0)}

	#Find and delete specified workstation(s) from SCCM
	$comp = get-wmiobject -query "select * from sms_r_system where Name='$Computer'" -computer $SCCMServer -namespace $SCCMNameSpace
	$comp.psbase.delete()
	}

[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$CleanConfirmation = [Microsoft.VisualBasic.Interaction]::MsgBox("Removed workstation(s) from SCCM and Active Directory!", "OKOnly,SystemModal,Information", "Success")
}#End ADcleanup

　
function Nithins {  
<# 
    .SYNOPSIS 
    Opens Nithin's SCCM Tools

    .EXAMPLE 
    Nithins 
    #> 
	$pat1 = "\\SERVERa01\it\Applications\Microsoft (Multiple Items)\SCCM (Item 3107)\ClientActionsTool.hta"
	$dir1 = "C:\Program Files (x86)\SCCM Tools"
	$des1 = $dir1 + "\ClientActionsTool.hta"
if (!(Test-Path -Path $des1)) {
	#Creates Nithin's path
	New-Item -Type directory -Path $dir1 -force | Out-Null
	Copy-Item $pat1 $des1 -Force
}	
	#Opens Nithin's Client
	Start-Process "$des1"
}#End Nithins

function CheckProcess {
    <# 
    .SYNOPSIS 
    Grabs all processes on specified workstation(s).

    .EXAMPLE 
    CheckProcess COMPUTER123456 

    .EXAMPLE 
    CheckProcess 123456 
    #> 
    param (
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [string]$NameRegex = '')
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}

$Stamp = (Get-Date -Format G) + ":"
$ComputerArray = @()

function ChkProcess {

    foreach ($computer in $ComputerArray) {

        $getProcess = Get-Process -ComputerName $computer

        foreach ($Process in $getProcess) {
                
                [pscustomobject]@{
		"Computer Name" = $computer
                "Process Name" = $Process.ProcessName
                PID = '{0:f0}' -f $Process.ID
                Company = $Process.Company
                "CPU(s)" = $Process.CPU
                Description = $Process.Description
                }           
            }
        } 
}
	
foreach ($computer in $ComputerName) {	     
    If (Test-Connection -quiet -count 1 -Computer $Computer) {
		    
        $ComputerArray += $Computer
    }	
}
	$chkProcess = ChkProcess | Sort "Computer Name" | Select "Computer Name","Process Name", PID, Company, "CPU(s)", Description
    	$DocPath = [environment]::getfolderpath("mydocuments") + "\Process-Report.csv"

    		Switch ($CheckBox.IsChecked){
    		    $true { $chkProcess | Export-Csv $DocPath -NoTypeInformation -Force; }
    		    default { $chkProcess | Out-GridView -Title "Processes";  }
    		}

	if($CheckBox.IsChecked -eq $true){
	    Try { 
		$listBox.Items.Add("$stamp Export-CSV to $DocPath!`n")
	    } 

	    Catch {
		    #Do Nothing 
	    }
	}
	
	else{
	    Try {
	        $listBox.Items.Add("$stamp Check Process output processed!`n")
	    } 
	    Catch {
	        #Do Nothing 
	    }
	}
    
}#End CheckProcess

　
function FindHotFixes {
    <# 
    .SYNOPSIS 
    Grabs all processes on specified workstation(s).

    .EXAMPLE 
    FindHotFixes COMPUTER123456 

    .EXAMPLE 
    FindHotFixes 123456 
    #> 
    param (
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [string]$NameRegex = '')
	if (($computername.length -eq 6)) {
    		[int32] $dummy_output = $null;

    	if ([int32]::TryParse($computername , [ref] $dummy_output) -eq $true) {
        	$computername = "COMPUTER" + $computername.Replace("COMPUTER","")}	
	}

    $Stamp = (Get-Date -Format G) + ":"
    $ComputerArray = @()

        function HotFix {
	    foreach ($computer in $ComputerArray) {

	        Get-HotFix -Computername $computer
        }
    
    }

foreach ($computer in $ComputerName) {	     
    If (Test-Connection -quiet -count 1 -Computer $Computer) {
		    
        $ComputerArray += $Computer
    }	
}

$HotFix = HotFix
$DocPath = [environment]::getfolderpath("mydocuments") + "\HotFix-Report.csv"

    		Switch ($CheckBox.IsChecked){
    		    $true { $HotFix | Export-Csv $DocPath -NoTypeInformation -Force; }
    		    default { $HotFix | Out-GridView -Title "Processes";  }
    		}

	if($CheckBox.IsChecked -eq $true){
	    Try { 
		$listBox.Items.Add("$stamp Export-CSV to $DocPath!`n")
	    } 

	    Catch {
		    #Do Nothing 
	    }
	}
	
	else{
	    Try {
	        $listBox.Items.Add("$stamp HotFixes output processed!`n")
	    } 
	    Catch {
	        #Do Nothing 
	    }
	}
}#End FindHotFixes
#Install MSI files silently; enter workstation(s) into pipeline, then enter full MSI path into prompt
function installMSI {
    <# 
    .SYNOPSIS 
    Installs an MSI file on specified workstation; then specify MSI file location.

    .EXAMPLE 
    installMSI COMPUTER123456 
    #> 
	[cmdletbinding()]
	Param ( #Define a Mandatory name input
	[Parameter(
	ValueFromPipeline=$true,
	ValueFromPipelinebyPropertyName=$true, 
	Position=0)]
	[Alias('Computer', 'ComputerName', 'Server', '__ServerName')]
		[string[]]$name = $ENV:Computername,
	[Parameter(Position=1)]
		[string]$progress = "Yes"
	) #End Param

#Edit only $path with desired starting .MSI path
Write-Host ('Example: \\SERVERa01\it\installer.msi')
$NetPath = Read-Host -prompt("Enter full MSI path")

ForEach ($computer in $name){
	#Do not edit $DirDest or $InstallDir, these values are static
	$DirDest = "\\$computer\C$\InstallationTemp\SETUP.msi"
	$InstallDir = "\\$computer\C$\InstallationTemp\"
Try {		
	$RemoteSession = New-PSSession -ComputerName $computer
		if(!(Test-Path -Path $InstallDir)) {
		New-Item "$InstallDir" -type directory -Force | Out-Null
		Copy-Item -Path "$NetPath" -Destination "$DirDest" -Force
		}
		Write-host "Attempting installation on $computer ... This may take several moments... Please Wait..`n"
	
		Invoke-Command -Session $RemoteSession -ScriptBlock {
		#Do not edit $LocalDest, this value is static
		$LocalDest = '"C:\InstallationTemp\SETUP.msi"'
		Start-Process 'msiexec.exe' "/i $LocalDest /qn" -wait}

		Write-Host "If no errors occured, installation should be successful!`n"
	
		Remove-item "$InstallDir" -Recurse -Force | Out-Null
		Remove-PSSession *
		
	}
Catch {
	"Something went wrong. Can't connect to $computer or filepath invalid. Sorry!`n"
        Write-Host "Caught an exception:" -ForegroundColor Red
        Write-Host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
        Write-Host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
	Remove-item "$InstallDir" -recurse -force | Out-Null
	Remove-PSSession *
	Break
		}
	}
}#End installMSI

#Install EXE files silently; enter workstation(s) into pipeline, then enter full EXE path into prompt
function installEXE{
    <# 
    .SYNOPSIS 
    Installs an EXE file on specified workstation; then specify EXE file location.

    .EXAMPLE 
    installEXE COMPUTER123456 
    #> 
	[cmdletbinding()]
	Param ( #Define a Mandatory name input
	[Parameter(
	ValueFromPipeline=$true,
	ValueFromPipelinebyPropertyName=$true, 
	Position=0)]
	[Alias('Computer', 'Computername', 'Server', '__ServerName')]
		[string[]]$name = $ENV:Computername,
	[Parameter(Position=1)]
		[string]$progress = "Yes"
	) #End Param
	
#Edit only $path with desired starting .EXE path
Write-Host ('Example: \\SERVER01\it\installer.exe')
$NetPath = Read-Host -prompt("Enter full EXE path")

ForEach ($computer in $name){
	#Do not edit $Destination path
	$Dest = "\\$computer\C$\InstallationTemp\SETUP.exe"
	$InstallDir = "\\$computer\C$\InstallationTemp\"
Try {	
if(!(Test-Path -Path $InstallDir)) {
	New-Item "$InstallDir" -type directory -Force | Out-Null
	Copy-Item -Path "$NetPath" -Destination "$Dest" -force
	}

		if(!(Test-Path -Path $InstallDir)) {
		New-Item "$InstallDir" -type directory -Force | Out-Null
		Copy-Item -Path "$NetPath" -Destination "$Dest" -Force
        }
			Write-host "Attempting installation on $computer ... This may take several moments... Please Wait..`n"

		Invoke-Command -Computername $computer { 
		param ($dest) Start-Process $dest -ArgumentList "/s"} -argumentlist $dest
		Write-Host "If no errors occured, installation should be successful!"

		Remove-item "$InstallDir" -Recurse -Force | Out-Null
	}
Catch {
	"Something went wrong. Can't connect to $computer or filepath invalid. Sorry!`n"
        Write-Host "Caught an exception:" -ForegroundColor Red
        Write-Host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
        Write-Host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    	Remove-item "$InstallDir" -recurse -force | Out-Null
	Remove-PSSession *
	Break
		}
	}
}#End installEXE

function CrossCertRm {
    <# 
    .SYNOPSIS 
    Executes the Cross Certificate removal application on specified workstation(s) 

    .EXAMPLE 
    CrossCertRm COMPUTER123456 

    .EXAMPLE 
    CrossCertRm 123456 

    .EXAMPLE
    CrossCertRm (Get-Content C:\SomeDirectory\WhateverTextFileYouWant.txt)
    #> 
[cmdletbinding()]
	Param ( #Define a Mandatory name input
	[Parameter(
	ValueFromPipeline=$true,
	ValueFromPipelinebyPropertyName=$true, 
	Position=0)]
	[Alias('Computer', 'ComputerName', 'Server', '__ServerName')]
		[string[]]$name = $ENV:Computername,
	[Parameter(Position=1)]
		[string]$progress = "Yes"
	) #End Param

function RemoveCertificates {
Process
{ #Process Each object on Pipeline
ForEach ($computer in $name){

		Try {
			$RemoteSession = New-PSSession -ComputerName $computer
}
	Catch {
		"Can't connect. Bad Workstation name, User name or Password. Aborting run."
	Break
	}

		New-Item "\\$computer\C$\Program Files\CrossCertRemoverTemp" -type directory -Force | Out-Null
	}

	Copy-Item -Path "\\SERVER01\it\Documentation\PowerShell\Profile Repository\FBCA_crosscert_remover_v114.exe" -Destination "\\$computer\C$\Program Files\CrossCertRemoverTemp\FBCA_crosscert_remover_v114.exe" -force
	Copy-Item -Path "\\SERVER01\it\Documentation\PowerShell\Profile Repository\FBCA_crosscert_remover_v114.config" -Destination "\\$computer\C$\Program Files\CrossCertRemoverTemp\FBCA_crosscert_remover_v114.config" -force

		Invoke-Command -Session $RemoteSession -ScriptBlock {Start-Process "C:\Program Files\CrossCertRemoverTemp\FBCA_crosscert_remover_v114.exe" -ArgumentList "/s" -NoNewWindow -wait}

	Remove-Item "\\$computer\C$\Program Files\CrossCertRemoverTemp" -recurse -force
	Remove-PSSession *
		}
	} RemoveCertificates

[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$CleanConfirmation = [Microsoft.VisualBasic.Interaction]::MsgBox("Invalid Certificate Authorities have been removed from workstation(s)!", "OKOnly,SystemModal,Information", "Success")
}#End CrossCertRm

function NewADuser {
    <# 
    .SYNOPSIS 
    Creates new user profile in Active Directory by parsing the users' SAAR form

    .EXAMPLE 
    NewADuser
    #>
 
#Load Visual Basic .NET Framework
[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$CurrentUser = [environment]::getfolderpath("mydocuments") + "\SAAR Forms"

If(!(Test-Path "C:\Program Files\SAARConverter")) { 
	Copy-Item -Path "\\SERVER01\it\Documentation\PowerShell\SAARConverter" -Destination "C:\Program Files\" -Recurse
	}

If(!(Test-Path "$CurrentUser")){
	New-Item -Itemtype Directory -Path "$CurrentUser"
	$SAMError = [Microsoft.VisualBasic.Interaction]::MsgBox("$CurrentUser path has been created`n"+"Please place SAAR Forms in this location and try again...", "OKOnly,SystemModal", "Error")
		Break;
	}

Copy-Item -Path "$CurrentUser\*.PDF" -Destination "C:\Program Files\SAARConverter\Release\Input" -Recurse

	#Execute ConvertSAAR function
	ConvertSAAR	
	
	#Execute CreateNewUser function
	CreateNewUser

	#Clear contents of Output folder
	Remove-Item -Path "C:\Program Files\SAARConverter\Release\Output\*.CSV" -Recurse -Force
}#End NewADuser

function ConvertSAAR {
$SAARpre = "C:\Program Files\SAARConverter\Release"
cd $SAARpre
cmd.exe /c SAARConverter.exe "C:\Program Files\SAARConverter\Release\Input" "C:\Program Files\SAARConverter\Release\Output\Output.csv"
cd ~ 
}#End ConvertSAAR

　
function CreateNewUser {
    <#
.SYNOPSIS 
Written by:
JBear 11/2/2016

Last Edited: 
JBear 11/18/2016

Requires: ActiveDirectory Module
            & PowerShell Version 3 or higher

Creates a new active directory user from a template.

Purpose of script to assist Help Desk with the creation of End-User accounts in Active Directory.
#>

　
#Script requires ActiveDirectory Module to be loaded
Import-Module ActiveDirectory

　
#Import all User information from CSV generated from ConvertSAAR program
$Users = Import-Csv -Path "C:\Program Files\SAARConverter\Release\Output\Output.csv"

　
#Filter each line of Output.csv individually
ForEach ($User in $Users) { 
    

    #User account information variables
    $Designation = $(

        If($User.Citizenship -EQ "3") {
            "USA"
        }
                       
        ElseIf($User.Citizenship -EQ "2") {
            "CND"
        }

        ElseIf($User.Designation -EQ "1") {
            "Sector 01"
        }

        ElseIf($User.Designation -EQ "2") {
            "Sector 02"
        })
                                                                     
    $Displayname = $(

        If($User.MiddleIn -EQ $Null){
            $User.LastName + ", " + $User.FirstName + " $Designation"
        }
        
        ElseIf(!($User.MiddleIn -EQ $Null)){
            $User.LastName + ", " + $User.FirstName + " " + $User.MiddleIn + " $Designation"
        })
 
    $UserFirstname = $User.FirstName
    $UserInitial = $User.MiddleIn
    $UserLastname = $User.LastName  
    $SupervisorEmail = $User.SupervisorEmail
    $UserCompany = $User.Company
    $UserDepartment =  $User.Department
    $Citizenship = $User.Citizenship
    $FileServer = $User.Location
    $UserJobTitle = $User.JobTitle
    $OfficePhone = $User.Phone
    $Description = $(
	
	If($User.Citizenship -eq 2){
            "Domain User (FN)"
        }
	
	ElseIf($User.Citizenship -eq 1){
            "Domain User"
        })

    $Email = $User.Email
    $Info = $(
	$Date = Get-Date
	"Account Created: " + $Date.ToShortDateString() + " " + $Date.ToShortTimeString() + " - " +  [Environment]::UserName
    )

    $FindSuperV = Get-ADUser -Filter {(mail -like $User.SupervisorEmail)}
    $FindSuperV = $FindSuperV | select -First "1" -ExpandProperty SamAccountName

    $Password = 'Th!sP@55w0rd$uCk5'

　
    #Prompt header and message display
    $Caption = "Choose Employer Template";
    $Message = "Please Select The Proper User Template for $Displayname";

    $Caption2 = "Are you sure?"
    $Message2 = "You have selected $Template for $Displayname :"

　
    #Prompt options for user templates
    $Alutiiq = New-Object System.Management.Automation.Host.ChoiceDescription "&Template01","Template01";
    $Berry = New-Object System.Management.Automation.Host.ChoiceDescription "&Template02","Template02";
    $Chugach = New-Object System.Management.Automation.Host.ChoiceDescription "&Template03","Template03";
    $FireDept = New-Object System.Management.Automation.Host.ChoiceDescription "&Template04","Template04";
    $Hospital= New-Object System.Management.Automation.Host.ChoiceDescription "&Template05","Template05";
    $KRS = New-Object System.Management.Automation.Host.ChoiceDescription "&Template06","Template06";
    $Seabee = New-Object System.Management.Automation.Host.ChoiceDescription "&Template07","Template07";
    $USAGKA = New-Object System.Management.Automation.Host.ChoiceDescription "&Template08","Template08";

    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes";
    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No","No";

　
    #Array of choices
    $Choices = ([System.Management.Automation.Host.ChoiceDescription[]](
                    $Template01,$Template02,$Template03,$Template04,$Template05,$Template06,$Template07,$Template08));

    $Choices2 = ([System.Management.Automation.Host.ChoiceDescription[]](
                    $Yes,$No));

　
    #Display template choices
    while($true) { 
        $Answer = $host.ui.PromptForChoice($Caption,$Message,$Choices,5);

　
        #Set $Answer variable based on user selection
        switch ($Answer) {

                #Values are SAM names of Templates
                0 { $Template = ("Template01"); $Answer2 }
                1 { $Template = ("Template02"); $Answer2 }
                2 { $Template = ("Template03"); $Answer2 }
                3 { $Template = ("Template04"); $Answer2 }
                4 { $Template = ("Template05"); $Answer2 }
                5 { $Template = ("Template06"); $Answer2 }
                6 { $Template = ("Template07"); $Answer2 }
                7 { $Template = ("Template08"); $Answer2 }
            }#Switch
       

        #Confirm selected choice
        $Message2 = "You have selected $Template for $Displayname :"
       
        $Answer2 = $host.ui.PromptForChoice($Caption2,$Message2,$Choices2,1);

       
        #Loop back to $Answer, if No; continue, if Yes
        if($Answer2 -eq 0) {
                break;
            }#If
        
        }#While

　
#Load Visual Basic .NET Framework
[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

　
    #Do{ process } Until( )
    Do{ 

        #Continue if $True
        While($True) {
            $SAM = [Microsoft.VisualBasic.Interaction]::InputBox("Enter desired Username for $Displayname :", "Create Username", "") 
            
            #Will loop if no value is supplied for $SAM
            If($SAM -ne "$Null"){

                #If AD user exists, throw error warning; loop back to $SAM input
                Try {

                    #On error, jump to Catch { }
                    $FindSAM = Get-ADUser $SAM -ErrorAction Stop
                    $SAMError = [Microsoft.VisualBasic.Interaction]::MsgBox("Username [$SAM] already in use by: " + $FindSAM.Name + "`nPlease try again...", "OKOnly,SystemModal", "Error")
                }#Try

                #On -EA Stop, specified account doesn't exist; continue with creation
                Catch {
                    $SAMFound = $False 
                    Break;   
                }#Catch
            }#If
        }#While
    }#Do

#Break from Do { } when $SAMFound is $False
Until($SAMFound -eq $False)
            

    #Parameters from Template User Object
    $AddressPropertyNames = @("StreetAddress","State","PostalCode","POBox","Office","Country","City")

    $SchemaNamingContext = (Get-ADRootDSE).schemaNamingContext

    $PropertiesToCopy = Get-ADObject -Filter "objectCategory -eq 'CN=Attribute-Schema,$SchemaNamingContext' -and searchflags -eq '16'" -SearchBase $SchemaNamingContext -Properties * |  
        Select -ExpandProperty lDAPDisplayname

    $PropertiesToCopy += $AddressPropertyNames

    $Password_SS = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $Template_Obj = Get-ADUser -Identity $Template -Properties $PropertiesToCopy

    $OU = $Template_Obj.DistinguishedName -replace '^cn=.+?(?<!\\),'

    #Replace SAMAccountName of Template User with new account for properties like the HomeDrive that need to be dynamic
    $Template_Obj.PSObject.Properties | where {
        $_.Value -match ".*$($Template_Obj.SAMAccountName).*" -and
        $_.Name -ne "SAMAccountName" -and
        $_.IsSettable -eq $True
        } | ForEach {

            Try{
                $_.Value = $_.Value -replace "$($Template_Obj.SamAccountName)","$SAM"
            }#Try

            Catch {

                #DoNothing
            }#Catch
        }#ForEach

    #ADUser parameters
    $params = @{
            "Instance"=$Template_Obj
            "Name"=$DisplayName
            "DisplayName"=$DisplayName
            "GivenName"=$UserFirstname
            "SurName"=$UserLastname
            "Initials"=$UserInitial
            "AccountPassword"=$Password_SS
            "Enabled"=$false
            "ChangePasswordAtLogon"=$false
            "UserPrincipalName"=$UserPrincipalName
            "SAMAccountName"=$SAM
            "Path"=$OU
            "OfficePhone"=$OfficePhone
            "EmailAddress"=$Email
            "Company"=$UserCompany
            "Department"=$UserDepartment
            "Description"=$Description   
            "Title"=$UserJobTitle 
            "SmartCardLogonRequired"=$True
        }#params

    $AddressPropertyNames | foreach {$params.Add("$_","$($Template_obj."$_")")}

    New-ADUser @params
    
    Set-AdUser "$SAM" -Manager $FindSuperV -Replace @{Info="$Info"}

    $TempMembership = Get-ADUser -Identity $Template -Properties MemberOf
    $TempMembership = $TempMembership | Select -ExpandProperty MemberOf
     
    $TempMembership | Add-ADGroupMember -Members $SAM

        If($FindSuperV -EQ $Null){
        
            $NoEmail = [Microsoft.VisualBasic.Interaction]::MsgBox("Please add Manager's Email Address to their User Account!`n" + $User.SupervisorEmail, "OKOnly,SystemModal", "Error")
        }

    <#Below

    <#Below section removed due to inability to cross Tiers; If capability ever becomes available again,
        will need to add ShareUtils to function.#>

    <#
    #Create user Home Drive based on $FileServer location
        if ($FileServer -eq 'Denver'){

	            New-Item -Itemtype directory -Path "\\SERVERA03.acme.com\Home$\" -Name $SAM
     
                #Create share and share permissions
                New-Share -Name $SAM$ -ComputerName SERVERA03 -Path D:\Home\$SAM -AllowMaximum:$False -MaximumAllowed 16777216 | Set-Share
                Start-Sleep -Seconds 5
                Get-Share -Name $SAM$ -ComputerName SERVERA03 | Add-SharePermission -User 'Authenticated Users' -AccessType Allow -Permission FullControl | Set-Share
                Start-Sleep -Seconds 5
                Get-Share -Name $SAM$ -ComputerName SERVERA03 | Remove-SharePermission -User Everyone | Set-Share

                #Set ACLs on the folder
                $directory = "\\SERVERA03.acme.com\Home$\$SAM"
                $acl = Get-Acl $directory
                $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("SERVER\$SAM","Modify","ContainerInherit,ObjectInherit","None","Allow")
                $acl.AddAccessRule($accessrule)
                Set-Acl -AclObject $acl $directory

	            #Map user's H: drive to their AD account
	            Set-ADUser $SAM -HomeDrive H: -HomeDirectory "\\SERVERa03\$SAM$"        
        
        }

        elseif ($FileServer -eq 'Salt Lake City') {

	            New-Item -Itemtype directory -Path "\\SERVERA04.acme.com\Home$\" -Name $SAM
     
                #Create share and share permissions
                New-Share -Name $SAM$ -ComputerName SERVERA04 -Path D:\Home\$SAM -AllowMaximum:$False -MaximumAllowed 16777216 | Set-Share
                Start-Sleep -Seconds 5
                Get-Share -Name $SAM$ -ComputerName SERVERA04 | Add-SharePermission -User 'Authenticated Users' -AccessType Allow -Permission FullControl | Set-Share
                Start-Sleep -Seconds 5
                Get-Share -Name $SAM$ -ComputerName SERVERA04 | Remove-SharePermission -User Everyone | Set-Share

                #Set ACLs on the folder
                $directory = "\\SERVERA04.acme.com\Home$\$SAM"
                $acl = Get-Acl $directory
                $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("SERVER\$SAM","Modify","ContainerInherit,ObjectInherit","None","Allow")
                $acl.AddAccessRule($accessrule)
                Set-Acl -AclObject $acl $directory

	            #Map user's H: drive to their AD account
	            Set-ADUser $SAM -HomeDrive H: -HomeDirectory "\\SERVERa04\$SAM$"    
        
        }

        else {

	            #Create folder
	            New-Item -Itemtype directory -Path "\\SERVERA05.acme.com\Home$\" -Name $SAM
     
                #Create share and share permissions
                New-Share -Name $SAM$ -ComputerName SERVERA05 -Path I:\Home\$SAM -AllowMaximum:$False -MaximumAllowed 16777216 | Set-Share
                Start-Sleep -Seconds 5
                Get-Share -Name $SAM$ -ComputerName SERVERA05 | Add-SharePermission -User 'Authenticated Users' -AccessType Allow -Permission FullControl | Set-Share
                Start-Sleep -Seconds 5
                Get-Share -Name $SAM$ -ComputerName SERVERA05 | Remove-SharePermission -User Everyone | Set-Share

                #Set ACLs on the folder
                $directory = "\\SERVERA05.acme.com\Home$\$SAM"
                $acl = Get-Acl $directory
                $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule("SERVER\$SAM","Modify","ContainerInherit,ObjectInherit","None","Allow")
                $acl.AddAccessRule($accessrule)
                Set-Acl -AclObject $acl $directory

	            #Map user's H: drive to their AD account
	            Set-ADUser $SAM -HomeDrive H: -HomeDirectory "\\SERVERa05\$SAM$"
            }#>
	}
}#End CreateNewUser

function GUI {

$Baloo = "\\SERVERa01\it\Documentation\BalooTrooper.png"
$MyDocuments = [environment]::getfolderpath("mydocuments") + "\WindowsPowerShell\BalooTrooper.png"

if(!(Test-Path $MyDocuments)){  
    Copy-Item "$Baloo" "$MyDocuments"
}  

Start-Process powershell.exe -argument '-NonInteractive -WindowStyle Hidden "CallGUI"'
}

function CallGUI { 

$MyDocuments = [environment]::getfolderpath("mydocuments") + "\WindowsPowerShell\BalooTrooper.png"

#XML code for GUI objects
$inputXML = @"
<Window x:Class="BearNecessities.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:BearNecessities"
        mc:Ignorable="d"
        Title="Bear Necessities | v2.3" Height="510" Width="750" BorderBrush="#FF211414" Background="#FF6C6B6B" ResizeMode="CanMinimize" WindowStartupLocation="CenterScreen">

    <Grid>

        <Image Height="256" HorizontalAlignment="Left" Name="image1" Stretch="Fill" VerticalAlignment="Top" Width="192" SnapsToDevicePixels="False" Source="$MyDocuments" />
        <TextBox Name="TextBox" Text="$env:ComputerName" Height="276" HorizontalAlignment="Left" Margin="584,27,0,0"  VerticalAlignment="Top" Width="132" Background="Black" Foreground="White" Cursor="IBeam" CharacterCasing="Upper" AcceptsReturn="True" TextWrapping="Wrap" AcceptsTab="True"/>
        <Label Content="**Separate with commas(,)" Height="28" HorizontalAlignment="Left" Margin="580,297,0,0" VerticalAlignment="Top" />
        <Label Content="Computer Name(s)**" Height="28" HorizontalAlignment="Left" Margin="580,5,0,0" VerticalAlignment="Top" />
        <ListView Name="ListBox" Height="197" HorizontalAlignment="Left" Margin="12,262,0,0" VerticalAlignment="Top" Width="375" Background="Black" Foreground="White" BorderBrush="White" />
        <Button Name="SysInfo" Background="Black" BorderBrush="Black" BorderThickness="2" Content="System Information" Foreground="White" Height="32" HorizontalAlignment="Left" Margin="395,324,0,0" VerticalAlignment="Top" Width="104" FontSize="10" FontWeight="Normal" FontFamily="Arial" />
        <Button Name="HotFixInfo" Background="Black" BorderBrush="Black" BorderThickness="2" Content="HotFix Information" FontFamily="Arial" FontSize="10" FontWeight="Normal" Foreground="White" Height="32" HorizontalAlignment="Left" Margin="615,324,0,0" VerticalAlignment="Top" Width="104" />
        <Button Name="SoftwareList" Background="Black" BorderBrush="Black" BorderThickness="2" Content="Software List" FontFamily="Arial" FontSize="10" FontWeight="Normal" Foreground="White" Height="32" HorizontalAlignment="Left" Margin="505,324,0,0" VerticalAlignment="Top" Width="104" />
        <Button Name="Ghost" Background="Black" BorderBrush="Black" BorderThickness="2" Content="Enter Ghost Session" FontFamily="Arial" FontSize="10" FontWeight="Normal" Foreground="White" Height="32" HorizontalAlignment="Left" Margin="615,420,0,0" VerticalAlignment="Top" Width="104" />
        <Button Name="ClearDrivers" Background="Black" BorderBrush="Black" BorderThickness="2" Content="Clear Printer Drivers" FontFamily="Arial" FontSize="10" FontWeight="Normal" Foreground="White" Height="32" HorizontalAlignment="Left" Margin="395,420,0,0" VerticalAlignment="Top" Width="104" />
        <Button Name="ClearCerts" Background="Black" BorderBrush="Black" BorderThickness="2" Content="Clear Invalid Certificates" FontFamily="Arial" FontSize="9" FontWeight="Normal" Foreground="White" Height="32" HorizontalAlignment="Left" Margin="505,420,0,0" VerticalAlignment="Top" Width="104" />
        <Button Name="Reboot" Background="#FFFF2424" BorderBrush="Black" BorderThickness="2" Content="Reboot Workstation(s)" FontFamily="Arial" FontSize="12" FontWeight="Bold" Foreground="White" Height="37" HorizontalAlignment="Left" Margin="198,27,0,0" VerticalAlignment="Top" Width="145" />
        <Button Name="Clear" Background="White" BorderBrush="Black" BorderThickness="2" Content="Clear" FontFamily="Arial" FontSize="12" FontWeight="Bold" Foreground="Black" Height="25" HorizontalAlignment="Left" Margin="175,235,0,0" VerticalAlignment="Top" Width="110" />
	<Button Name="Processes" Background="Black" BorderBrush="Black" BorderThickness="2" Content="Check Processes" FontFamily="Arial" FontSize="10" FontWeight="Normal" Foreground="White" Height="32" HorizontalAlignment="Left" Margin="395,372,0,0" VerticalAlignment="Top" Width="104" />
        <CheckBox Name="CheckBox" Content="Export-CSV" Height="16" HorizontalAlignment="Left" Margin="305,245,0,0" VerticalAlignment="Top" IsChecked="False" />

        
    </Grid>
</Window>               
 
"@       
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )}

catch{
Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

#Connect to Controls
$inputTextBox = $Form.FindName('TextBox')
$sysinfoButton = $Form.FindName('SysInfo')
$hotfixButton = $Form.FindName('HotFixInfo')
$softwareButton = $Form.FindName('SoftwareList')
$ghostButton = $Form.FindName('Ghost')
$printdriversButton = $Form.FindName('ClearDrivers')
$invalidcertsButton = $Form.FindName('ClearCerts')
$rebootButton = $Form.FindName('Reboot')
$checkBox = $Form.FindName('CheckBox')
$listBox = $Form.FindName('ListBox')
$clearButton = $Form.FindName('Clear')
$processButton = $Form.FindName('Processes') 

#===========================================================================
# Actually make the objects work
#===========================================================================

#Clear Button 
$clearButton.Add_Click({
    $listBox.Items.Clear()
})

#Reboot Button
$rebootButton.Add_Click({

$Stamp = (Get-Date -Format G) + ":"

    $SplitString = $inputTextBox.Text.Split(",")
    $SplitString = $SplitString.Trim()

#Confirmation variables; prompt user
$Caption = "Are you sure?"
$Message = "All workstations listed will be restarted. Do you want to continue?"

$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes";
$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No","No";

$Choices = ([System.Management.Automation.Host.ChoiceDescription[]](
                $Yes,$No));

$Answer = $host.ui.PromptForChoice($Caption,$Message,$Choices,1);

#If NO, do nothing
    if($Answer -eq 1) {
	#Do nothing
 	$listBox.Items.Add("$Stamp Reboot(s) aborted!`n")
        }

#If YES, execute Reboot
elseif(!($Answer -eq 1)){
        Reboot $SplitString; $listBox.Items.Add("$Stamp Reboot initialized!`n")
	}
})

#Ghost Button
$ghostButton.Add_Click({

$Stamp = (Get-Date -Format G) + ":"

    $SplitString = $inputTextBox.Text.Split(",")
    $SplitString = $SplitString.Trim()

    Ghost $SplitString; $listBox.Items.Add("$Stamp Ghost session opened!`n")

})

#HotFix Button
$hotfixButton.Add_Click({

$Stamp = (Get-Date -Format G) + ":"

    $listBox.Items.Add("Processing... please wait...`n")

    $SplitString = $inputTextBox.Text.Split(",")
    $SplitString = $SplitString.Trim()

    FindHotFixes $SplitString;
})

#Certificates Button
$invalidcertsButton.Add_Click({

$Stamp = (Get-Date -Format G) + ":"

    $listBox.Items.Add("Processing... please wait...`n")

    $SplitString = $inputTextBox.Text.Split(",")
    $SplitString = $SplitString.Trim()

    CrossCertRm $SplitString; $listBox.Items.Add("$Stamp Invalid certificates removed!`n")

})

#Printer Drivers Button
$printdriversButton.Add_Click({

$Stamp = (Get-Date -Format G) + ":"

    $SplitString = $inputTextBox.Text.Split(",")
    $SplitString = $SplitString.Trim()

    RmPrint $SplitString; $listBox.Items.Add("$Stamp Printer drivers removed!`n")

})

#Software Button
$softwareButton.Add_Click({

$Stamp = (Get-Date -Format G) + ":"

    $SplitString = $inputTextBox.Text.Split(",")
    $SplitString = $SplitString.Trim()

    SWcheck $SplitString

})

#System Information Button
$sysinfoButton.Add_Click({

$Stamp = (Get-Date -Format G) + ":"
    
    $SplitString = $inputTextBox.Text.Split(",")
    $SplitString = $SplitString.Trim()
  
    SYS $SplitString
})

#Process Button
$processButton.Add_Click({

$Stamp = (Get-Date -Format G) + ":"
    
    $SplitString = $inputTextBox.Text.Split(",")
    $SplitString = $SplitString.Trim()
  
    CheckProcess $SplitString
})

#Show Form
$Form.ShowDialog() | out-null
}#EndGUI
 