class duoSecurity {
    hidden [string] $integrationKey = 'false'
    hidden [string] $secretKey = 'false'
    hidden [string] $apiHostname = 'false'

    
    hidden [string] $auth_integrationKey = 'false'
    hidden [string] $auth_secretKey = 'false'
    hidden [string] $auth_apiHostname = 'false'

    [void] configInstance([string] $integrationKey, [string] $secretKey, [string] $apiHostname) {
        $this.integrationKey = $integrationKey
        $this.secretKey = $secretKey
        $this.apiHostname = $apiHostname
    }

    [void] configAuthInstance([string] $integrationKey, [string] $secretKey, [string] $apiHostname) {
        $this.auth_integrationKey = $integrationKey
        $this.auth_secretKey = $secretKey
        $this.auth_apiHostname = $apiHostname
    }

    [hashtable] convertToDuoRequest([string] $httpMethod, [string] $apiPath, [hashtable] $apiParams) {
        if ($this.integrationKey -ne 'false' -and $this.secretKey -ne 'false' -and $this.apiHostname -ne 'false') {
            ($apiParams.GetEnumerator() | Where-Object { -not $_.Value }) | ForEach-Object { $apiParams.Remove($_.Name) }
            $Date = (Get-Date).ToUniversalTime().ToString('ddd, dd MMM yyyy HH:mm:ss -0000')

            $StringAPIParams = ($apiParams.Keys | Sort-Object | ForEach-Object {
                    $_ + '=' + [uri]::EscapeDataString($apiParams.$_)
                }) -join '&'

            $DuoParams = @(
                $Date.Trim(),
                $httpMethod.ToUpper().Trim(),
                $this.apiHostname.ToLower().Trim(),
                $apiPath.Trim(),
                $StringAPIParams.trim()
            ).trim() -join "`n"
            $DuoParams = $DuoParams.ToCharArray()
            
            $DuoParams = $DuoParams.ToByte([System.IFormatProvider]$global:UTF8)

            $HMACSHA1 = [System.Security.Cryptography.HMACSHA1]::new($this.secretKey.ToCharArray().ToByte([System.IFormatProvider]$global:UTF8))
            $hmacsha1.ComputeHash($DuoParams) | Out-Null
            $ASCII = [System.BitConverter]::ToString($hmacsha1.Hash).Replace('-', '').ToLower()
            $AuthHeader = $this.integrationKey + ':' + $ASCII
            [byte[]]$ASCIBytes = [System.Text.Encoding]::ASCII.GetBytes($AuthHeader)

            return @{
                URI         = "https://$($this.apiHostname)$($apiPath)"
                Headers     = @{
                    'X-Duo-Date'    = $Date
                    'Authorization' = "Basic $([System.Convert]::ToBase64String($ASCIBytes))"
                }
                Body        = $apiParams
                Method      = $httpMethod
                ContentType = 'application/x-www-form-urlencoded'
            }
        }
        else {
            throw 'No Keys or API Host Specified'
        }
    }

    [hashtable] convertToDuoAuthRequest([string] $httpMethod, [string] $apiPath, [hashtable] $apiParams) {
        if ($this.auth_integrationKey -ne 'false' -and $this.auth_secretKey -ne 'false' -and $this.apiHostname -ne 'false') {
            ($apiParams.GetEnumerator() | Where-Object { -not $_.Value }) | ForEach-Object { $apiParams.Remove($_.Name) }
            $Date = (Get-Date).ToUniversalTime().ToString('ddd, dd MMM yyyy HH:mm:ss -0000')

            $StringAPIParams = ($apiParams.Keys | Sort-Object | ForEach-Object {
                    $_ + '=' + [uri]::EscapeDataString($apiParams.$_)
                }) -join '&'

            $DuoParams = @(
                $Date.Trim(),
                $httpMethod.ToUpper().Trim(),
                $this.auth_apiHostname.ToLower().Trim(),
                $apiPath.Trim(),
                $StringAPIParams.trim()
            ).trim() -join "`n"
            $DuoParams = $DuoParams.ToCharArray()
            
            $DuoParams = $DuoParams.ToByte([System.IFormatProvider]$global:UTF8)

            $HMACSHA1 = [System.Security.Cryptography.HMACSHA1]::new($this.auth_secretKey.ToCharArray().ToByte([System.IFormatProvider]$global:UTF8))
            $hmacsha1.ComputeHash($DuoParams) | Out-Null
            $ASCII = [System.BitConverter]::ToString($hmacsha1.Hash).Replace('-', '').ToLower()
            $AuthHeader = $this.auth_integrationKey + ':' + $ASCII
            [byte[]]$ASCIBytes = [System.Text.Encoding]::ASCII.GetBytes($AuthHeader)

            return @{
                URI         = "https://$($this.auth_apiHostname)$($apiPath)"
                Headers     = @{
                    'X-Duo-Date'    = $Date
                    'Authorization' = "Basic $([System.Convert]::ToBase64String($ASCIBytes))"
                }
                Body        = $apiParams
                Method      = $httpMethod
                ContentType = 'application/x-www-form-urlencoded'
            }
        }
        else {
            throw 'No Keys or API Host Specified'
        }
    }

    [object] get_duoUserByUsername ([string] $username) {

        $generatedRequest = $this.convertToDuoRequest( 'GET', '/admin/v1/users', @{
                'username' = $username
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'

        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @{}
        }
    }

    [object] get_duoUserByUserID ([string] $userID) {
        
        $generatedRequest = $this.convertToDuoRequest('GET', "/admin/v1/users/$($userID)", @{})

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @{}
        }
    }

    [object] new_duoUser ([hashtable] $userObject) {

        $generatedRequest = $this.convertToDuoRequest('POST', '/admin/v1/users', $userObject)

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response.response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @{}
        }
    }

    [object] set_duoUserByUserID ([string] $userID, [hashtable] $userObject) {
        
        $generatedRequest = $this.convertToDuoRequest('POST', "/admin/v1/users/$($userID)", $userObject)

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response.response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @{}
        }
    }

    [object] del_duoUserByUserID ([string] $userID) {

        $generatedRequest = $this.convertToDuoRequest('DELETE', "/admin/v1/users/$($userID)", @{})

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response.response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @{}
        }
    }

    [string] set_enrollDuoUser ([string] $username, [string] $email, [int] $valid_secs = 2592000) {

        $generatedRequest = $this.convertToDuoRequest('POST', '/admin/v1/users/enroll', @{
                'username'   = $username
                'email'      = $email
                'valid_secs' = $valid_secs
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response.response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return ''
        }
    }

    [array] set_createDuoUserBypassCodesByUserID ([string] $userID, [int] $count, [int] $valid_secs = 0) {

        $generatedRequest = $this.convertToDuoRequest('POST', "/admin/v1/users/$($userID)/bypass_codes", @{
                'count'       = $count
                'reuse_count' = 1
                'valid_secs'  = $valid_secs
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response.response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }

    [array] get_duoUserBypassCodes ([string] $userID, [int] $limit, [int] $offset) {

        $generatedRequest = $this.convertToDuoRequest('GET', "/admin/v1/users/$($userID)/bypass_codes", @{
                'limit'  = $limit
                'offset' = $offset
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }

    [array] get_duoUserGroupsByUserID ([string] $userID, [int] $limit, [int] $offset) {

        $generatedRequest = $this.convertToDuoRequest('GET', "/admin/v1/users/$($userID)/groups", @{
                'limit'  = $limit
                'offset' = $offset
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }

    [bool] set_duoUserGroupAddMembershipByUserIDAndGroupID ([string] $userID, [string] $groupID) {

        $generatedRequest = $this.convertToDuoRequest('POST', "/admin/v1/users/$($userID)/groups", @{
                'group_id' = $groupID
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $true
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return $false
        }
    }

    [bool] set_duoUserGroupRemoveMembershipByUserIDAndGroupID ([string] $userID, [string] $groupID) {

        $generatedRequest = $this.convertToDuoRequest('DELETE', "/admin/v1/users/$($userID)/groups/$($groupID)", @{})

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $true
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return $false
        }
    }

    [array] get_duoUserPhonesByUserID ([string] $userID, [int] $limit, [int] $offset) {

        $generatedRequest = $this.convertToDuoRequest('GET', "/admin/v1/users/$($userID)/phones", @{
                'limit'  = $limit
                'offset' = $offset
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }

    [array] set_duoUserPhoneActivationCode ([string] $phoneID) {

        $generatedRequest = $this.convertToDuoRequest('POST', "/admin/v1/phones/$($phoneID)/activation_url", @{
                valid_secs = 86400
                install    = 1
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response.response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }

    [array] set_duoUserPhoneSMSActivationByUserID ([string] $phoneID, [int] $install) {

        $generatedRequest = $this.convertToDuoRequest('POST', "/admin/v1/phones/$($phoneID)/send_sms_activation", @{
                'install' = $install
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response.response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }

    [bool] set_duoUserPhoneAddByUserIDAndPhoneID ([string] $userID, [string] $phoneID) {

        $generatedRequest = $this.convertToDuoRequest('POST', "/admin/v1/users/$($userID)/phones", @{
                'phone_id' = $phoneID
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $true
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return $false
        }
    }

    [bool] set_duoUserPhoneRemoveByUserIDAndPhoneID ([string] $userID, [string] $phoneID) {

        $generatedRequest = $this.convertToDuoRequest('DELETE', "/admin/v1/users/$($userID)/phones/$($phoneID)", @{})

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $true
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return $false
        }
    }

    [array] get_duoUserHardwareTokensByUserID ([string] $userID, [int] $limit, [int] $offset) {

        $generatedRequest = $this.convertToDuoRequest('GET', "/admin/v1/users/$($userID)/tokens", @{
                'limit'  = $limit
                'offset' = $offset
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }

    [array] get_duoUserHardwareTokens ([int] $limit, [int] $offset) {

        $generatedRequest = $this.convertToDuoRequest('GET', '/admin/v1/tokens', @{
                'limit'  = $limit
                'offset' = $offset
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }

    [bool] set_duoUserHardwareTokenAddByUserIDAndTokenID ([string] $userID, [string] $tokenID) {
        $generatedRequest = $this.convertToDuoRequest('POST', "/admin/v1/users/$($userID)/tokens", @{
                'token_id' = $tokenID
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $true
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return $false
        }
    }

    [bool] set_duoUserHardwareTokenRemoveByUserIDAndTokenID ([string] $userID, [string] $tokenID) {

        $generatedRequest = $this.convertToDuoRequest('DELETE', "/admin/v1/users/$($userID)/tokens/$($tokenID)", @{})

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $true
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return $false
        }
    }

    [array] get_duoUserWebAuthnByUserID ([string] $userID) {

        $generatedRequest = $this.convertToDuoRequest('GET', "/admin/v1/users/$($userID)/webauthncredentials", @{})

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }

    [array] get_duoUserGroups ([int] $limit, [int] $offset) {

        $generatedRequest = $this.convertToDuoRequest('GET', '/admin/v1/groups', @{
                'limit'  = $limit
                'offset' = $offset
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }

    [object] get_duoUserAuthChallenge ([string] $userID, [string] $deviceID) {

        $generatedRequest = $this.convertToDuoAuthRequest('POST', '/auth/v2/auth', @{
                'user_id'  = $userID
                'factor'   = 'auto'
                'hostname' = 'SJR Helpdesk'
                'device'   = $deviceID
                'async'    = 0
                'type'     = 'Verification For'
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        
        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @{}
        }
    }

    [object] get_duoPhones ([int] $limit, [int] $offset) {

        $generatedRequest = $this.convertToDuoRequest('GET', '/admin/v1/phones', @{
                'limit'  = $limit
                'offset'   = $offset
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @{}
        }
    }

    [object] set_removeDuoPhone ([string] $phoneID) {

        $generatedRequest = $this.convertToDuoRequest('DELETE', "/admin/v1/phones/$($phoneID)", @{})

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode'
        if ($statusCode -eq '200') {
            return $response.response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @{}
        }
    }

    [array] triggerDirectorySyncForUser([string] $username, [string] $directoryKey) {
        $generatedRequest = $this.convertToDuoRequest('POST', "/admin/v1/users/directorysync/$directoryKey/syncuser", @{
                'username' = $username
            })

        $statusCode = ''
        $response = Invoke-RestMethod @generatedRequest -StatusCodeVariable 'statusCode' -ErrorAction SilentlyContinue

        if ($statusCode -eq '200') {
            return $response.response
        }
        else {
            Write-Warning 'DUO REST Call Failed'
            Write-Warning "APiParams: $($generatedRequest | Out-String)"
            return @()
        }
    }
}

#$duoSecurity = [duoSecurity]::new()
#$duoSecurity.configInstance([string] $integrationKey, [string] $secretKey, [string] $apiHostname)

<#remove users in duo who aren't in AD
$users = $duoSecurity.get_duoUserByUsername('myusername')
foreach ($user in $users.response) {
    try {
        $u = Get-ADUser $user.username -ErrorAction SilentlyContinue
    }
    catch {
        Write-Output $user.username
        $u = $duoSecurity.get_duoUserByUsername($user.username)
        Write-Output $u.response.user_id
        #$duoSecurity.del_duoUserByUserID($u.response.user_id)
    }
}
#>

<#Add user, to duo group, and send enrollment email
$duoSecurity.new_duoUser(@{
        'username' = 'myusername'
        'realname' = 'lastname, firstname'
        'email'    = 'FirstLast@mydomain.edu'
    })

$user = $duoSecurity.get_duoUserByUsername('myusername')
$group = $duoSecurity.get_duoUserGroups(10, 0).response | Where-Object name -like 'Staff/Faculty'
$duoSecurity.set_duoUserGroupAddMembershipByUserIDAndGroupID($user.response.user_id, $group.group_id)
$duoSecurity.set_enrollDuoUser($user.response.username, $user.response.email, 2592000)
#>


<#generate and retrieve bypass codes for user
$user = $duoSecurity.get_duoUserByUsername('FirstLast@mydomain.edu')
$duoSecurity.set_createDuoUserBypassCodesByUserID($user.response.user_id, 3, 600)
$duoSecurity.get_duoUserBypassCodes($user.response.user_id, 10, 0)
#>