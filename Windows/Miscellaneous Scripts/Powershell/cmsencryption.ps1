class ps_cms_Encryption {

    [object] encryptString([object] $___methodParams) {
        $___methodParams.stringData ??= $null
        $___methodParams.encryptionCert ??= $null

        $out = @{
            errorState = $false
            errorMessage = ''
            data = $null
        }

        if ($null -ne $___methodParams.stringData) {
            $cert = Get-ChildItem -Path Cert:\ -recurse | Where-Object FriendlyName -eq $___methodParams.encryptionCert

            if ($null -ne $cert) {
                $out.data = Protect-CMSMessage -To $cert -Content $___methodParams.stringData -ErrorAction SilentlyContinue
                $out.errorState = $?
                return $out
            }
            else {
                $out.errorMessage = "Could not get certificate $($___methodParams.encryptionCert)"
                return $out
            }
        }
        else {
            $out.errorMessage = 'Invalid Parameters'
            return $out
        }
    }

    [object] decryptString([object] $___methodParams) {
        $___methodParams.stringData ??= $null
        $___methodParams.encryptionCert ??= $null

        $out = @{
            errorState = $false
            errorMessage = ''
            data = $null
        }

        if ($null -ne $___methodParams.stringData) {
            $cert = Get-ChildItem -Path Cert:\ -recurse | Where-Object FriendlyName -eq $___methodParams.encryptionCert

            if ($null -ne $cert) {
                $out.data = Unprotect-CMSMessage -To $cert -Content $___methodParams.stringData -ErrorAction SilentlyContinue
                $out.errorState = $?
                
                if ($out.errorState -ne $false) {
                    return $out
                }
                else {
                    $out.errorMessage = "Could not decrypt data"
                    return $out
                }
            }
            else {
                $out.errorMessage = "Could not get certificate $($___methodParams.encryptionCert)"
                return $out
            }
        }
        else {
            $out.errorMessage = 'Invalid Parameters'
            return $out
        }
    }

    [object] encryptStringToFile([object] $___methodParams) {
        $___methodParams.stringData ??= $null
        $___methodParams.filePath ??= $null
        $___methodParams.encryptionCert ??= $null

        $out = @{
            errorState = $false
            errorMessage = ''
        }

        if ($null -ne $___methodParams.stringData -and $___methodParams.filePath -ne $null) {
            $cert = Get-ChildItem -Path Cert:\ -recurse | Where-Object FriendlyName -eq $___methodParams.encryptionCert

            if ($null -ne $cert) {
                Protect-CMSMessage -To $cert -Content $___methodParams.stringData -OutFile $___methodParams.filePath -ErrorAction SilentlyContinue
                $out.errorState = $?
                
                if ($out.errorState -ne $false) {
                    return $out
                }
                else {
                    $out.errorMessage = "Could not decrypt data"
                    return $out
                }
            }
            else {
                $out.errorMessage = "Could not get certificate $($___methodParams.encryptionCert)"
                return $out
            }
        }
        else {
            $out.errorMessage = 'Invalid Parameters'
            return $out
        }
    }

    [object] decryptStringFromFile([object] $___methodParams) {
        $___methodParams.filePath ??= $null
        $___methodParams.encryptionCert ??= $null

        $out = @{
            errorState = $false
            errorMessage = ''$ps_cms_Encryption| Where-Object FriendlyName -eq $___methodParams.encryptionCert

            if ($null -ne $cert) {
                $out.data = Unprotect-CMSMessage -To $cert -Path $___methodParams.filePath -ErrorAction SilentlyContinue
                $out.errorState = $?
                
                if ($out.errorState -ne $false) {
                    return $out
                }
                else {
                    $out.errorMessage = "Could not decrypt data"
                    return $out
                }
            }
            else {
                $out.errorMessage = "Could not get certificate $($___methodParams.encryptionCert)"
                return $out
            }
        }
        else {
            $out.errorMessage = 'Invalid Parameters'
            return $out
        }
    }
}

<#
$ps_cms_Encryption = [ps_cms_Encryption]::new()

#encrypt string to variable
$encstring = $ps_cms_Encryption.encryptString(@{
    stringData = 'sample string'
    encryptionCert = 'cert_name'
})

#save encrypted string to file
$ps_cms_Encryption.encryptStringToFile(@{
    stringData = 'sample string'
    encryptionCert = 'cert_name'
    filePath = 'D:\encflags\somefilename.enc'
})
#>