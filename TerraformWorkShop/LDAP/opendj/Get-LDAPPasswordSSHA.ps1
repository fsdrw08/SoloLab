[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]
    $Password,

    [Parameter()]
    [int]
    $saltByteLength = 5
)
# https://www.openldap.org/faq/data/cache/347.html
# https://serverfault.com/questions/260003/slappasswd-output-randomized
# https://github.com/ffquintella/lapi/blob/766b7cbe5414fc7dd41eb9b75209e9a27fdbdd03/lapi/Security/HashHelper.cs#L25

# get the password byte value
[byte[]] $passwordBytes = [System.Text.Encoding]::ASCII.GetBytes($Password)

# generate the salt and get the salt byte value
[byte[]] $saltBytes = New-Object -TypeName 'Byte[]' -Argumentlist $saltByteLength
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($saltBytes)
$rng.Dispose()

# create the byte container to host the byte of password + byte of salt
[byte[]] $mergedBytes = New-Object -TypeName 'Byte[]' -Argumentlist ($passwordBytes.Length + $saltByteLength)

# put the bytes of password + bytes of salt into the container
# https://stackoverflow.com/questions/415291/best-way-to-combine-two-or-more-byte-arrays-in-c-sharp#415396
# https://github.com/samratashok/nishang/blob/d87229d2112456470ad30a50edbf312463f2b09a/MITM/Invoke-Interceptor.ps1#L438
[System.Buffer]::BlockCopy( $passwordBytes, 0, $mergedBytes, 0, $passwordBytes.Length)
[System.Buffer]::BlockCopy( $saltBytes, 0, $mergedBytes, $passwordBytes.Length, $saltBytes.Length ) 

# hash the byte container above to sha1
$SHA1Generator = [System.Security.Cryptography.SHA1]::Create()
[byte[]] $mergedBytesSHA1 = $SHA1Generator.ComputeHash($mergedBytes)
$SHA1Generator.Dispose()

# create the final byte container to host the sha1 byte above + byte of salt
[byte[]] $finalMergedBytes = New-Object -TypeName 'Byte[]' -Argumentlist ($mergedBytesSHA1.Length + $saltByteLength)
[System.Buffer]::BlockCopy( $mergedBytesSHA1, 0, $finalMergedBytes, 0, $mergedBytesSHA1.Length)
[System.Buffer]::BlockCopy( $saltBytes, 0, $finalMergedBytes, $mergedBytesSHA1.Length, $saltBytes.Length ) 

# convert the final byte to base64
$result = [Convert]::ToBase64String($finalMergedBytes)

return "{SSHA}$result"
