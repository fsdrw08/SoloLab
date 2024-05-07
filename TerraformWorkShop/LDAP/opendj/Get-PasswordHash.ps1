[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $password
)

$job = Start-Job -ScriptBlock {
    # https://github.com/ffquintella/lapi/blob/766b7cbe5414fc7dd41eb9b75209e9a27fdbdd03/lapi/Security/HashHelper.cs#L25
$code = @'
using System;
using System.Text;
using System.Linq;
using System.Security.Cryptography;
namespace PasswordHash
{
    public class Program
    {
        public static string SSHA(string plainTextString)
        {
            var saltBytes = GenerateSalt(4);
            var plainTextBytes = Encoding.ASCII.GetBytes(plainTextString);

            var plainTextWithSaltBytes = AppendByteArray(plainTextBytes, saltBytes);

            var saltedSha1Bytes = System.Security.Cryptography.SHA1.Create().ComputeHash(plainTextWithSaltBytes);

            byte[] saltedSha1WithAppendedSaltBytes = AppendByteArray(saltedSha1Bytes, saltBytes);

            return "{SSHA}" + Convert.ToBase64String(saltedSha1WithAppendedSaltBytes);
        } 

        private static byte[] GenerateSalt(int length)
        {
          var saltBytes = new byte[length];
          System.Security.Cryptography.RandomNumberGenerator.Create().GetBytes(saltBytes);
          return saltBytes;
        }

        private static byte[] AppendByteArray(byte[] byteArray1, byte[] byteArray2)
        {
            var byteArrayResult =
                new byte[byteArray1.Length + byteArray2.Length];

            for (var i = 0; i < byteArray1.Length; i++)
                byteArrayResult[i] = byteArray1[i];
            for (var i = 0; i < byteArray2.Length; i++)
                byteArrayResult[byteArray1.Length + i] = byteArray2[i];

            return byteArrayResult;
        }

    }
}
'@
Add-Type -TypeDefinition $code -Language CSharp
[PasswordHash.Program]::SSHA($args[0])
} -argumentlist @($password)
receive-job $job -autoremovejob -wait