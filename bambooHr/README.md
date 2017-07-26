# Bamboo HR API Wrapper

This **PowerShell** script is an API Wrapper for the BambooHR human resource SaaS provider.  It uses the REST API provided by BambooHR and requires that you have administrative privileges and an API key.  You can find documentation on BambooHR's
API by clicking [here](https://www.bamboohr.com/api/documentation/).

This script currently supports the following actions to be completed:

* Retrieve a list of employee fields
* Retrieve a list of employees
* Retrieve detailed information about a specific employee
* Retrieve table information (i.e. salary, location, etc.)
* Update Employee information

## Installation
_Note: Currently this is not designed to function as a **PowerShell** module._

### Prerequisites
* Powershell 4.0 for Windows

### Installation and Configuration Steps
1. Copy the `bamboohr.ps1` file to your preferred directory
2. Update `$apiKey = "<api key>"` by replacing `<api key>` with your API Key
3. Update `$baseUrl = "https://api.bamboohr.com/api/gateway.php/<company>/v1/"` by replacing `<company>` with your BambooHR company domain
4. Run the script in a **PowerShell** session or include it in your own scripts

# Usage
## Invoke-BambooMethod
This **cmdlet** is used to create each of the other ones.  It uses `Invoke-RestMethod` to interact with the API.  This returns the full unparsed HTTP response.  Each of the lower level cmdlets handle the parsing of the response

#### Parameters

##### `method`

This controls the HTTP request stype used

###### Supported Values:

* `get` - Sets the request as a GET request and makes available the _get_ actions of the `method` object.
* `post` - Sets the request as a POST request and makes available the _post_ actions of the `method` object.

##### `action`

This is the action that you want to complete from the `method` object.  Each action acts as an alias to each of the API calls.

###### Supported Values:

* employee
* employeeTable
* employees
* fields
* tables

##### `searchObj`
This is an object variable that needs to be passed to the `Invoke-BambooMethod` that contains the information needed to replace the bracketed variables in method object.  These allow for dynamic use of the API wrapper.

###### Example:
```
# This will replace any instance of {employeeid} with the $employeeId

$search = @(
    @{key='employeeId'; value=$employeeId}
)
```

## cmdlets

### GET Methods

#### Get-BambooFields
This will return all of the Employee Fields, including custom fields, that are available on your BambooHR account.
##### Syntax
```
C:\>  Get-BambooFields
```

#### Get-BambooEmployees
This will return every employee with some basic information that is in your BambooHR account.
##### Syntax
```
C:\>  Get-BambooEmployees
```

#### Get-BambooEmployee
This will return detailed information for a specific user based on the `employeeId` provided.
##### Syntax
```
C:\> Get-BambooEmployee -employeeId <BambooHR Employee ID> -properties <properties list>
```
##### Parameters

###### `employeeId`
This is a users employeeId within BambooHR.

###### `properties`
This is a comma delimited list of properties to include in the output.  The `$BAMBOO_FIELDS` variable contains the available _aliases_ that can be used.

#### Get-BambooEmployeeTable
This allows you to retrieve the tabular data that is available for each individual user.

##### Syntax
```
C:\> Get-BambooEmployeeTable -employeeId <BambooHR Employee ID> -tableName <Table Name>
```
##### Parameters

###### `employeeId`
This is a users employeeId within BambooHR.

###### `tableName`
This is the case-sensitive name of a table.  The API currently supports the following tables:

* jobInfo
* employmentStatus
* compensation
* dependents
* emergencyContacts

Additionally, any custom table can be accessed by its' alias.

## POST Methods

#### Update-BambooEmployee
This allows you to update individual employee information.

##### Syntax
```
C:\> Update-BambooEmployee -employeeId <BambooHR Employee ID> <Parameters to Update>
```
##### Parameters

###### `employeeId`
This is a users employeeId within BambooHR.

###### Available Parameters to Update
* `address1`
* `address2`
* `city`
* `country`
* `dateOfBirth`
* `department`
* `division`
* `eeo`
* `employeeNumber`
* `employmentHistoryStatus`
* `ethnicity`
* `exempt`
* `firstName`
* `gender`
* `hireDate`
* `homeEmail`
* `homePhone`
* `includeInPayroll`
* `jobTitle`
* `lastName`
* `location`
* `maritalStatus`
* `middleName`
* `mobilePhone`
* `nickname`
* `paidPer`
* `payChangeReason`
* `payGroup`
* `payGroupId`
* `payPer`
* `payPeriod`
* `payRate`
* `payRateEffectiveDate`
* `payType`
* `preferredName`
* `sin`
* `ssn`
* `state`
* `status`
* `twitterFeed`
* `workEmail`
* `workPhone`
* `zipcode`
* `customSAMIID`
