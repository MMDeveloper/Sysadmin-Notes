class oracleDBAccess {

    hidden $dbConnectionObject = $null
    hidden $connectionStringBuilder = $null
    hidden $isConnected = $false
    
    [object]init([object] $___methodParams) {
        $returnObject = $this.getGenericReturnObject()

        #validate OMDA dll
        if ($null -ne $___methodParams.OMDA) {
            if ((Test-Path -LiteralPath $___methodParams.OMDA -PathType Leaf) -eq $true -and $___methodParams.OMDA -like '*.dll') {
                $returnObject.errorState = $true
                Add-Type -LiteralPath $___methodParams.OMDA -ErrorAction SilentlyContinue

                $assemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object FullName -like '*Oracle.ManagedDataAccess*'

                if ($assemblies.Count -gt 0) {
                    #good
                }
                else {
                    $returnObject.errorState = $false
                    $returnObject.errorMessages += 'Cound not find correct Assembly'
                    return $returnObject
                }
            }
            else {
                $returnObject.errorState = $false
                $returnObject.errorMessages += 'Invalid dll path'
                return $returnObject
            }
        }
        else {
            $returnObject.errorState = $false
            $returnObject.errorMessages += 'Missing OMDA dll path'
            return $returnObject
        }


        #validate csvData
        if ($null -ne $___methodParams.csbData -and $___methodParams.csbData -is [Hashtable]) {
            $returnObject.errorState = $true
            #good
        }
        else {
            $returnObject.errorState = $false
            $returnObject.errorMessages += 'Missing or invalid csbData hashtable'
            return $returnObject
        }


        #build connection string
        $this.connectionStringBuilder = New-Object Oracle.ManagedDataAccess.Client.OracleConnectionStringBuilder
        foreach ($param in $___methodParams.csbData.GetEnumerator()) {
            $this.connectionStringBuilder[$param.Name] = $param.Value
        }

        #make DB connection
        try {
            $this.dbConnectionObject = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($this.connectionStringBuilder.ConnectionString)
            $this.dbConnectionObject.Open()
            $this.isConnected = $true
        }
        catch {
            $returnObject.errorState = $false
            $returnObject.errorMessages += 'Error connecting with specified DSN parameters'
            return $returnObject
        }
        
        return $returnObject
    }

    [void] cleanup() {
        $this.dbConnectionObject.Close()
        $this.dbConnectionObject = $null
        $this.connectionStringBuilder = $null
        $this.isConnected = $false
    }

    [object] doQuery([object] $___methodParams) {
        $returnObject = $this.getGenericReturnObject()

        if ($this.isConnected -eq $true) {

            if ($null -ne $___methodParams.query -and $___methodParams.query -is [String]) {
                $queryObject = $this.dbConnectionObject.CreateCommand()
                $queryObject.CommandText = $___methodParams.query
                $queryObject.CommandTimeout = 3600 #Seconds
                $queryObject.FetchSize = 10000000 #10MB

                if ($null -ne $___methodParams.params -and $___methodParams.params -is [array]) {
                    foreach ($paramDatum in $___methodParams.params) {
                        $queryObject.Parameters.Add($paramDatum.name, $paramDatum.value)
                    }
                }


                $oracleDataAdapter = New-Object Oracle.ManagedDataAccess.Client.OracleDataAdapter($queryObject);
                $queryObjectResults = New-Object System.Data.DataTable

                try {
                    [void]$oracleDataAdapter.fill($queryObjectResults)
                    $returnObject.data = $queryObjectResults
                }
                catch {
                    $returnObject.errorState = $false
                    $returnObject.errorMessages += $Error[0]
                }

                return $returnObject
            }
            else {
                $returnObject.errorState = $false
                $returnObject.errorMessages += 'Missing or non-string query'
                return $returnObject
            }
        }
        else {
            $returnObject.errorState = $false
            $returnObject.errorMessages += 'Not connected to database'
            return $returnObject
        }
    }

    [object]getGenericReturnObject() {
        return @{
            errorState = $true
            errorMessages = @()
        }
    }
}

<#
$oracleCredential = Get-Credential
$oracleDBAccess = [oracleDBAccess]::new()
$oracleDBAccess.init(@{
    OMDA = '\\directory\path\to\Oracle.ManagedDataAccess.dll'
    csbData = @{
        'Data Source' = 'OracleServerHostname:1521/DatabaseName'
        'User ID' = $oracleCredential.UserName
        Password = $oracleCredential.GetNetworkCredential().password
        'Persist Security Info' = $true
        Pooling = $true
        'Connection Timeout' = 5
    }
})

$ret = $oracleDBAccess.doQuery(@{
    query = 'SELECT
                t_cdr.donationDate,
                t_cdr.donorID,
                t_cdr.donorAmount,
                t_cdd.donorDisplayName
            FROM
                someSchema.tableContainingDonationRecords t_cdr
                INNER JOIN someSchema.tableContainingDonorDemographics t_cdd
                    ON t_cdd.donorID = t_cdr.donorID
            WHERE
                t_cdr.donorID = :donorID
            --FETCH FIRST 10 ROWS ONLY'

    params = @(
        @{
            name = 'donorID'
            value = '23345'
        }
    )
})

if ($ret.errorState -eq $true) {
    $ret.data | Format-List
}
else {
    Write-Host $ret.errorMessages -ForegroundColor Red
}

$oracleDBAccess.cleanup()
#>