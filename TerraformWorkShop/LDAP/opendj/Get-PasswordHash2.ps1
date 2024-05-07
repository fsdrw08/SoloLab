[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $password,

    [Parameter()]
    [int]
    $saltLength = 4
)

$job = Start-Job -ScriptBlock {
    # https://github.com/SharonKoch/test_cs_file_Demo/blob/26c92df7e5e48df112d216921dd81f961bcc89ad/StaffController.cs#L87
    # https://github.com/ffquintella/lapi/blob/766b7cbe5414fc7dd41eb9b75209e9a27fdbdd03/lapi/Security/HashHelper.cs#L23
$code = @'
using System;
using System.Text;
using System.Linq;
using System.Security.Cryptography;
namespace PasswordHash
{
    public class Program
    {
        public static string SSHA(string input, int saltLength)
        {

            // var sha1 = SHA1.Create();
            var salt = GenerateSalt(saltLength);
            // var hash = sha1.ComputeHash(Encoding.ASCII.GetBytes(input).Concat(salt).ToArray());
            var hash = System.Security.Cryptography.SHA1.Create().ComputeHash(Encoding.ASCII.GetBytes(input).Concat(salt).ToArray());
            var result = "{SSHA}" + System.Convert.ToBase64String(hash.Concat(salt).ToArray());

            return result;
        }

        private static byte[] GenerateSalt(int length)
        {
            var saltBytes = new byte[length];
            System.Security.Cryptography.RandomNumberGenerator.Create().GetBytes(saltBytes);
            return saltBytes;
        }
    }
}
'@
Add-Type -TypeDefinition $code -Language CSharp
[PasswordHash.Program]::SSHA($args[0], $args[1])
} -argumentlist @($password, $saltLength)

# https://stackoverflow.com/questions/3369662/can-you-remove-an-add-ed-type-in-powershell-again
receive-job $job -autoremovejob -wait