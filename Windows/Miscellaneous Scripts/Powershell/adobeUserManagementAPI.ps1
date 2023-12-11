class adobeManagement {
    hidden [string] $org_id = 'some-id@AdobeOrg'
    hidden [string] $api_key = 'some-api-key'
    hidden [string] $client_secret = 'client-secret'
    hidden [string] $apiURLBase = 'https://usermanagement.adobe.io/v2/usermanagement'
    hidden [string] $getTokenURL = 'https://ims-na1.adobelogin.com/ims/token/v3'
    hidden [PSCustomObject] $oAuthTokenInfo = @{}

    [bool] initOAuthAuthorization() {
        $headers = @{
            'Content-Type' = 'application/x-www-form-urlencoded'
        }

        $body = @{
            'client_id' = $this.api_key
            'client_secret' = $this.client_secret
            'scope' = 'openid, user_management_sdk, AdobeID'
            'grant_type' = 'client_credentials'
        }
        $this.oAuthTokenInfo = Invoke-RestMethod -uri $this.getTokenURL -Method POST -Headers $headers -Body $body

        if ($null -ne $this.oAuthTokenInfo.access_token) {
            return $true
        }
        else {
            return $false
        }
    }

    [object] doAPIRequest([object] $___methodParams) {
        $___methodParams.url ??= $null
        $___methodParams.requestMethod ??= $null
        $___methodParams.body ??= $null

        $uri = "$($this.apiURLBase)$($___methodParams.url)"

        $headers = @{
            'Content-Type' = 'application/json'
            'Accept' = 'application/json'
            'Authorization' = "Bearer $($this.oAuthTokenInfo.access_token)"
            'X-Api-Key' = $this.api_key
        }

        return Invoke-RestMethod -Uri $uri -Header $headers -Body $___methodParams.body -Method $___methodParams.requestMethod
    }

    [object] getUserInfo([object] $___methodParams) {
        $___methodParams.emailAddress ??= $null

        return $this.doAPIRequest(@{
            url = "/organizations/$($this.org_id)/users/$($___methodParams.emailAddress)"
            requestMethod = 'GET'
        })
    }

    [object] deleteTenantUser([object] $___methodParams) {
        $___methodParams.emailAddress ??= $null

        return $this.doAPIRequest(@{
            url = "/action/$($this.org_id)"
            requestMethod = 'POST'
            body = @{
                user = $___methodParams.emailAddress
                requestID = 'removeUser'
                do = @(@{
                    removeFromOrg = @{
                        deleteAccount = 'true'
                    }
                })
            } | ConvertTo-Json -Depth 10 -AsArray
        })
    }

    [object] userNameChange([object] $___methodParams) {
        $___methodParams.emailAddressFrom ??= $null
        $___methodParams.emailAddressTo ??= $null
        $___methodParams.firstNameTo ??= $null
        $___methodParams.lastNameTo ??= $null

        return $this.doAPIRequest(@{
            url = "/action/$($this.org_id)"
            requestMethod = 'POST'
            body = @{
                user = $___methodParams.emailAddressFrom
                requestID = 'updateUser'
                do = @(@{
                    update = @{
                        email = $___methodParams.emailAddressTo
                        lastname = $___methodParams.lastNameTo
                        firstname = $___methodParams.firstNameTo
                    }
                })
            } | ConvertTo-Json -Depth 10 -AsArray
        })
    }
}


<#

$adobeManagement = [adobeManagement]::new()
if ($adobeManagement.initOAuthAuthorization() -eq $true) {
    $adobeManagement.deleteTenantUser(@{
        emailAddress = 'reallynobody@mydomain.edu'
    })
}


$a = $adobeManagement.userNameChange(@{
    emailAddressFrom = 'reallynobody@mydomain.edu'
    emailAddressTo = 'reallynobodyatall@mydomain.edu'
    firstNameTo = 'Nobody'
    lastNameTo = 'Really'
})

$a.errors | FL

#>