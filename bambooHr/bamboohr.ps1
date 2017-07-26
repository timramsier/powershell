$apiKey = "<api key>"
$baseUrl = "https://api.bamboohr.com/api/gateway.php/<company>/v1/"

# Method Object
# {} brackets act as variables that are replaced in the string upon invocation
$methods = @{
    get = @{
        employees = 'employees/directory'
        employee = 'employees/{employeeId}?fields={fieldList}'
        employeeTable = 'employees/{employeeId}/tables/{tableName}'
        fields = 'meta/fields/'
        tables = 'meta/tables'
    }
    post = @{
        employee = 'employees/{employeeId}'
    }
}

# Config Object
$config = @{
    defaultView = @{
        employees = @(
            'employeeNumber',
            'firstName',
            'lastName',
            'jobTitle',
            'location',
            'workEmail'
        )
    }
}

function Ignore-SelfSignedCerts {
    try
    {
        Write-Host "Adding TrustAllCertsPolicy type." -ForegroundColor White
        Add-Type -TypeDefinition  @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy
        {
             public bool CheckValidationResult(
             ServicePoint srvPoint, X509Certificate certificate,
             WebRequest request, int certificateProblem)
             {
                 return true;
            }
        }
"@
        Write-Host "TrustAllCertsPolicy type added." -ForegroundColor White
      }
    catch
    {
        Write-Host $_ -ForegroundColor "Yellow"
    }
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

function Invoke-BambooMethod ($method, $action, $searchObj = @(), $body = '') {
    $api = $methods[$method][$action]
    foreach ($replace in $searchObj){
        $api = $api.Replace("{$($replace.key)}",$replace.value)
    }

    if ($method -like 'post') {
        $params = @{
            body = $body
            ContentType = 'application/xml'
        }
    } else {
        $params = @{
            ContentType = "text/xml"
        }
    }
    Write-Host "$($baseUrl)$($api)" -ForegroundColor Green
    $response = Invoke-RestMethod -Method $method -Uri "$($baseUrl)$($api)" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -DisableKeepAlive @params
    $response
}

# GET
function Get-BambooFields {
    $response = Invoke-RestMethod -Uri "$($baseUrl)$($methods.get.fields)" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -DisableKeepAlive -ContentType "text/xml"
    $PSObject = @()
    foreach ($Object in $response.fields.field) {
        $PSObject += New-Object -TypeName psobject -Property @{
            id = $Object.id
            type = $Object.type
            alias = $Object.alias
            name = $Object.InnerText
        }
    }
    $PSObject
}
function Get-BambooEmployees {
    $response = Invoke-BambooMethod -method get -action employees -searchObj $search
    $employeeData = @()
    foreach ($employee in $response.directory.employees.employee) {
        $PSObject = New-Object PSObject
        $PSObject | Add-Member NoteProperty "employeeId" $employee.id -ErrorAction SilentlyContinue
        foreach ($Object in $employee.field) {
            $PSObject | Add-Member NoteProperty $Object.id $Object.InnerText -ErrorAction SilentlyContinue
        }
        $employeeData += $PSObject
    }
    $employeeData
}
function Get-BambooEmployee ($employeeId = 0, $properties) {
    if ($properties -eq '*') {
        $fieldList = [String]::Join(",",@($BAMBOO_FIELDS.alias))
    } else {
        $fieldList = [String]::Join(",",@($config.defaultView.employees + $properties))
    }
    $search = @(
        @{key='employeeId'; value=$employeeId}
        @{key='fieldList'; value=$fieldList}
    )
    $response = Invoke-BambooMethod -method get -action employee -searchObj $search

    $PSObject = New-Object PSObject
    $PSObject | Add-Member NoteProperty "employeeId" $response.employee.id -ErrorAction SilentlyContinue
    foreach ($Object in $response.employee.field) {
        $PSObject | Add-Member NoteProperty $Object.id $Object.InnerText -ErrorAction SilentlyContinue
    }
    $PSObject
}

function Get-BambooEmployeeTable ($employeeId = 0, $tableName) {
    $search = @(
        @{key='employeeId'; value=$employeeId}
        @{key='tableName'; value=$tableName}
    )
    $response = Invoke-BambooMethod -method get -action employeeTable -searchObj $search

    $PSArray = @()
    # $PSObject | Add-Member NoteProperty "employeeId" $response.employee.id -ErrorAction SilentlyContinue
    foreach ($Object in $response.table.row) {
       $PSObject = New-Object PSObject
       foreach ($entry in $Object.field) {
         $PSObject | Add-Member NoteProperty $entry.id $entry.InnerText -ErrorAction SilentlyContinue
       }
       $PSArray += $PSObject
    }
    $PSArray
}

# UPDATE
function Update-BambooEmployee {
    Param(
        [Parameter(Mandatory=$True)]
        [String]$employeeId,
        [String]$address1,
        [String]$address2,
        [String]$city,
        [String]$country,
        [String]$dateOfBirth,
        [String]$department,
        [String]$division,
        [String]$eeo,
        [String]$employeeNumber,
        [String]$employmentHistoryStatus,
        [String]$ethnicity,
        [String]$exempt,
        [String]$firstName,
        [String]$gender,
        [String]$hireDate,
        [String]$homeEmail,
        [String]$homePhone,
        [String]$includeInPayroll,
        [String]$jobTitle,
        [String]$lastName,
        [String]$location,
        [String]$maritalStatus,
        [String]$middleName,
        [String]$mobilePhone,
        [String]$nickname,
        [String]$paidPer,
        [String]$payChangeReason,
        [String]$payGroup,
        [String]$payGroupId,
        [String]$payPer,
        [String]$payPeriod,
        [String]$payRate,
        [String]$payRateEffectiveDate,
        [String]$payType,
        [String]$preferredName,
        [String]$sin,
        [String]$ssn,
        [String]$state,
        [String]$status,
        [String]$twitterFeed,
        [String]$workEmail,
        [String]$workPhone,
        [String]$zipcode,
        [String]$customSAMIID


    )
    function _AddField($key,$value) {
        "`t<field id=`"$key`">$value</field>`n"
    }

    $updateFields
    foreach ($param in $PSBoundParameters.GetEnumerator()) {
        if ($param.key -ne 'employeeId') {
             $updateFields += _AddField -key $param.key -value $param.value
        }
    }

    $body = @"
<employee>
$updateFields</employee>
"@

    $search = @(@{key='employeeId'; value=$employeeId})
    $response = Invoke-BambooMethod -method 'post' -action employee -body $body -searchObj $search
}

Ignore-SelfSignedCerts

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $apiKey,"x")))

$BAMBOO_FIELDS = Get-BambooFields | ? { $_.alias -and $_.alias -match "^[a-zA-Z0-9_]*$"} | sort alias -Unique
