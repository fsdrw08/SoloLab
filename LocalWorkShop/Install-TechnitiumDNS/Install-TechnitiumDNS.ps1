[CmdletBinding()]
param (
    [uri]$DownloadLink = "https://download.technitium.com/dns/DnsServerSetup.zip",
    [string]$Path = $PSScriptRoot
)

begin {
    # $downloadLink = "https://download.technitium.com/dns/DnsServerSetup.zip"
    # $Path = "~\source\repos\SoloLab\LocalWorkShop\Install-TechnitiumDNS\"
    $lastIndexOfSlash = $downloadLink.ToString().LastIndexOf("/")+1
    $lengthOfFileName = $downloadLink.ToString().Length-$lastIndexOfSlash
    $InstallationFileName = $downloadLink.ToString().Substring($lastIndexOfSlash,$lengthOfFileName)
    if (-not (Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.displayname -like "Technitium DNS*"})) {
        if (-not (Test-Path (Join-Path -Path $Path -ChildPath $InstallationFileName))) {
            $Title = "Get-TechnitiumDNS"
            $Info = "download the iso from $DownloadLink to $(Join-Path -Path $Path -ChildPath $InstallationFileName) in powershell now?"
            $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
            [int]$defaultchoice = 1
            $downloadOpt = $host.UI.PromptForChoice($Title , $Info , $Options, $defaultchoice)
        } elseif (-not (Test-Path "$PSScriptRoot\DnsServerSetup.exe")) {
            "Start Install"
            Expand-Archive -Path $PSScriptRoot\$InstallationFileName -DestinationPath $PSScriptRoot
        } else {
            . "$PSScriptRoot\DnsServerSetup.exe" /SILENT
        }
    } else {
        "Already install"
    }
    # if (-not (Test-Path (Join-Path -Path $Path -ChildPath $InstallationFileName))) {
    #     $Title = "Get-TechnitiumDNS"
    #     $Info = "download the iso from $DownloadLink to $(Join-Path -Path $Path -ChildPath $InstallationFileName) in powershell now?"
    #     $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
    #     [int]$defaultchoice = 1
    #     $downloadOpt = $host.UI.PromptForChoice($Title , $Info , $Options, $defaultchoice)
    # } elseif (-not (Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.displayname -like "Technitium DNS*"})) {
    #     "Start Install"
    # } else {
    #     "Already install"
    # }
}

process {
    if (-not ($null -eq $downloadOpt)) {
        switch($downloadOpt) {
            0 { 
                Write-Host "download now" -ForegroundColor Yellow
                function Restart-Command {
                    [CmdletBinding()]
                    Param(
                        [Parameter(Position=0, Mandatory=$true)]
                        [scriptblock]$ScriptBlock,
                
                        [Parameter(Position=1, Mandatory=$false)]
                        [int]$Maximum = 5,
                
                        [Parameter(Position=2, Mandatory=$false)]
                        [int]$Delay = 500
                    )
                
                    Begin {
                        $cnt = 0
                    }
                
                    Process {
                        do {
                            $cnt++
                            try {
                                $ScriptBlock.Invoke()
                                return
                            } catch {
                                Write-Error $_.Exception.InnerException.Message -ErrorAction Continue
                                Start-Sleep -Milliseconds $Delay
                            }
                        } while ($cnt -lt $Maximum)
                
                        # Throw an error after $Maximum unsuccessful invocations. Doesn't need
                        # a condition, since the function returns upon successful invocation.
                        throw 'Execution failed.'
                    }
                }

                Restart-Command -ScriptBlock {
                    $WebClient = New-Object System.Net.WebClient
                    $WebClient.DownloadFile($downloadLink, (Join-Path -Path $Path -ChildPath $InstallationFileName))
                }
                $downloadOpt = $null
                . $MyInvocation.MyCommand.Path -Path $Path
            }
            1 { 
                Write-Host "Cancel" -ForegroundColor Green
                $downloadOpt = $null
            }
        }
    }
}

end {
    
}
