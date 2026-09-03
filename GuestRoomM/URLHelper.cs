using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace GuestRoomApp.GuestRoomM
{
    public static class URLHelper
    {
        // Simple salt and key for URL protection
        private static readonly string EncryptionKey = "GR_Secure_Access_2026"; 
        private static readonly byte[] Salt = new byte[] { 0x47, 0x52, 0x53, 0x65, 0x63, 0x75, 0x72, 0x65 }; // "GRSecure"

        /// <summary>
        /// Encrypts a plain text string (like a Reservation Number) for safe use in URL QueryStrings.
        /// </summary>
        public static string Encrypt(string plainText)
        {
            if (string.IsNullOrEmpty(plainText)) return "";
            
            byte[] clearBytes = Encoding.Unicode.GetBytes(plainText);
            using (Aes encryptor = Aes.Create())
            {
                Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(EncryptionKey, Salt);
                encryptor.Key = pdb.GetBytes(32);
                encryptor.IV = pdb.GetBytes(16);
                using (MemoryStream ms = new MemoryStream())
                {
                    using (CryptoStream cs = new CryptoStream(ms, encryptor.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        cs.Write(clearBytes, 0, clearBytes.Length);
                        cs.Close();
                    }
                    plainText = Convert.ToBase64String(ms.ToArray());
                }
            }
            // URL Encode the base64 string to make it safe for the address bar
            return HttpUtility.UrlEncode(plainText);
        }

        /// <summary>
        /// Decrypts a string from a URL QueryString back to its original plain text value.
        /// </summary>
        public static string Decrypt(string cipherText)
        {
            if (string.IsNullOrEmpty(cipherText)) return "";

            try
            {
                // URL Decode and handle potential space replacement
                string decodedText = HttpUtility.UrlDecode(cipherText).Replace(" ", "+");
                byte[] cipherBytes = Convert.FromBase64String(decodedText);
                
                using (Aes encryptor = Aes.Create())
                {
                    Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(EncryptionKey, Salt);
                    encryptor.Key = pdb.GetBytes(32);
                    encryptor.IV = pdb.GetBytes(16);
                    using (MemoryStream ms = new MemoryStream())
                    {
                        using (CryptoStream cs = new CryptoStream(ms, encryptor.CreateDecryptor(), CryptoStreamMode.Write))
                        {
                            cs.Write(cipherBytes, 0, cipherBytes.Length);
                            cs.Close();
                        }
                        return Encoding.Unicode.GetString(ms.ToArray());
                    }
                }
            }
            catch
            {
                // Return empty if decryption fails (tampered URL)
                return "";
            }
        }

        /// <summary>
        /// Helper to get a decrypted value directly from Request.QueryString
        /// </summary>
        public static string GetParam(string key)
        {
            string val = HttpContext.Current.Request.QueryString[key];
            return string.IsNullOrEmpty(val) ? "" : Decrypt(val);
        }
    }
}
