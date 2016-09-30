﻿if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {    Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
[PSObject[]]$global:resultsarray = @()#Output File Prefix$outfile = "ipfscustom"      $enumActions = $true#output file name$fileName = ".\logs\$outfile-" + $(Get-Date -Format "yyyyMMddHHmmss") + ".csv"        $WebApplications = Get-SPWebApplication
foreach($webApp in $WebApplications){    Write-Host "Checking: $($webApp.DisplayName) $($webApp.Url)"    foreach($site in $webApp.Sites)    {        #Skip deep sites        if ($site.AllWebs.Count -gt 100){Write-Host "Skipping $($site.RootWeb.Title)" -ForegroundColor Magenta; Continue}        if ((Get-SPSite $site.url -ErrorAction SilentlyContinue) -ne $null)         {            try            {                foreach($web in $site.AllWebs)                {                    if ((Get-SPWeb $web.url -ErrorAction SilentlyContinue) -ne $null)                     {                        foreach ($list in $web.Lists)                        {                            #does this have to be done for every content type in the list?                            $isUsingInfoPath = $list.ContentTypes[0].ResourceFolder.Properties["_ipfs_infopathenabled"] 
                            if ($isUsingInfoPath)
                            {
                                Write-Host "Found a form on: $($webApp.DisplayName) $($list.Title)"
                                $outObject = new-object PSObject                                $outObject | add-member -membertype NoteProperty -name "URL" -Value $web.Url                                $outObject | add-member -membertype NoteProperty -name "List/Library" -Value $list.Title                                $outObject | add-member -membertype NoteProperty -name "File" -Value $list.ContentTypes[0].ResourceFolder.Properties["_ipfs_solutionName"]                                $outObject | add-member -membertype NoteProperty -name "Created By" -Value ""                                $outObject | add-member -membertype NoteProperty -name "Created Date" -Value ""                                $outObject | add-member -membertype NoteProperty -name "Modified By" -Value ""                                $outObject | add-member -membertype NoteProperty -name "Modified Date" -Value ""
                                $outObject | add-member -membertype NoteProperty -name "Notes" -Value ""
                                $global:resultsarray += $outObject                            }                        }                    }                }            }            catch            {                Write-Host "Caught an exception accessing site: $($site.RootWeb.Title) ($($site.Url))" -ForegroundColor Yellow
                #Write-Host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
                Write-Host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red            }        }    }} #output file$resultsarray | Export-csv $fileName -notypeinformation#New-Alias -Name Notepad -Value 'C:\Program Files (x86)\Notepad++\notepad++.exe' -ErrorAction SilentlyContinueNotepad $fileName
