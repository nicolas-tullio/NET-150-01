param(

    [Alias("y")]
    [Parameter(Mandatory = $true)]
    [string]$year,

    [Alias("k")]
    [Parameter(Mandatory = $true)]
    [string]$keyword,

    [Alias("f")]
    [Parameter(Mandatory = $true)]
    [string]$filename

)
# Storyline: Parsing the NVD datafeed
Clear-Host

# Convert Json File into Powershell Object
$nvd_vulns = (Get-Content -Raw -Path ".\nvdcve-1.1-$year.json" | `
        ConvertFrom-Json) | Select-Object  CVE_Items

# Headers for the CSV file
Set-Content -Value "`"PublishDate`",`"Description`",`"Impact`",`"CVS`"" $filename

# Srray to store the data
$theV = @()

foreach ($vuln in $nvd_vulns.CVE_Items) {

    # Vuln Description
    $descript = $vuln.cve.description.description_data

    # Search for the keyword
    if ($descript -imatch "$keyword") {
        
        # Published date
        $pubDate = $vuln.publishedDate
        
        # Description
        $z = $descript | Select-Object value
        $description = $z.value
       
        # Impact
        $y = $vuln.impact
        $impact = $y.baseMetricV2.severity

        # CVE Number
        $cve = $vuln.cve.CVE_data_meta.ID

        # Format the CSV file
        $theV += "`"$pubDate`",`"$description`",`"$impact`",`"$cve`"`n"
    }
    
} # End foreach loop

# Convert the array to a string and append to the CSV file
"$theV" | Add-Content -Path $filename