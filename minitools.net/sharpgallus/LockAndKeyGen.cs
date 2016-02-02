﻿using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;

namespace Sharpgallus
{
    /* The contents of this class were shamelessly nicked from MSNP-sharp, which had this comment to say about it:
        // This piece of code was written by Siebe Tolsma (Copyright 2005).
        // Based on documentation by ZoRoNaX (http://zoronax.bot2k3.net/msn_beta/)
        //
        // This code is for eductional purposes only. Modification, use and/or publishing this code
        // is entirely on your OWN risk, I can not be held responsible for any damages done by using it.
        // If you have questions please contact me by posting on the BOT2K3 forum: http://bot2k3.net/forum/
    * I then adjusted it to use SHA-256 to match Skype.
    */
    public class LockAndKeyGen
    {
        private static readonly string SkypeProductId = "msmsgs@msnmsgr.com";
        private static readonly string SkypeProductKey = "Q1P7W2E4J9R8U3S5";

        public static string CalculateHeader()
        {
            string time = DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1)).TotalSeconds.ToString();
            string token = Sharpgallus.LockAndKeyGen.Calculate(time);

            return string.Format("appId={0}; time={1}; lockAndKeyResponse={2}", SkypeProductId, time, token);
        }

        public static string Calculate(string time)
        {
            return Calculate(SkypeProductId, SkypeProductKey, time);
        }

        public static string Calculate(string strProductID, string strProductKey, string strCHLData)
        {
            // First generate an MD5 hash object
            SHA1CryptoServiceProvider MD5 = new SHA1CryptoServiceProvider();
            byte[] bMD5Bytes = Encoding.Default.GetBytes(strCHLData + strProductKey);
            MD5.TransformFinalBlock(bMD5Bytes, 0, bMD5Bytes.Length);

            // Once we are done with that we should create 4 integers from the MD5 hash
            string strMD5Hash = To_Hex(MD5.Hash);
            ulong[] uMD5Ints = MD5_To_Int(strMD5Hash);

            // Create a new string from the ProdID and CHLData and padd with zero's, then convert it to ulongs :-)
            string strCHLID = strCHLData + strProductID;
            strCHLID = strCHLID.PadRight(strCHLID.Length + (8 - (strCHLID.Length % 8)), '0');
            ulong[] uCHLIDInts = CHLID_To_Int(strCHLID);

            // Then fetch the key from the two arrays
            ulong uKey = Create_Key(uMD5Ints, uCHLIDInts);

            // And finally create the new hash :-)
            ulong uPartOne = ulong.Parse(strMD5Hash.Substring(0, 16), NumberStyles.HexNumber);
            ulong uPartTwo = ulong.Parse(strMD5Hash.Substring(16, 16), NumberStyles.HexNumber);
            return String.Format("{0:x16}{1:x16}", uPartOne ^ uKey, uPartTwo ^ uKey);
        }

        private static ulong[] MD5_To_Int(string strMD5Hash)
        {
            // Create new array
            ulong[] uMD5Ints = new ulong[strMD5Hash.Length / 4];

            // For each 8 characters we swap bytes and logically AND them
            for (int i = 0; i < strMD5Hash.Length; i += 8)
                uMD5Ints[i / 8] = ulong.Parse(Swap_Bytes(strMD5Hash.Substring(i, 8), 2), NumberStyles.HexNumber) & 0x7FFFFFFF;

            // Return the array of integers
            return uMD5Ints;
        }

        private static ulong[] CHLID_To_Int(string strCHLID)
        {
            // Create new arrays
            ulong[] uCHLIDInts = new ulong[strCHLID.Length / 4];

            // For each 4 characters we swap bytes and convert to integers
            for (int i = 0; i < strCHLID.Length; i += 4)
                uCHLIDInts[i / 4] = ulong.Parse(Swap_Bytes(To_Hex(Encoding.Default.GetBytes(strCHLID.Substring(i, 4))), 2), NumberStyles.HexNumber);

            // Return the array of integers
            return uCHLIDInts;
        }

        private static ulong Create_Key(ulong[] uMD5Ints, ulong[] uCHLIDInts)
        {
            // Walk over each two elements in the uCHLIDInts array
            ulong temp = 0, high = 0, low = 0;
            for (int i = 0; i < uCHLIDInts.Length; i += 2)
            {
                // First multiply by a constant, modulo and add the high key
                // Then multiply by the first MD5Int, add the second and modulo again
                temp = ((uCHLIDInts[i] * 0x0E79A9C1) % 0x7FFFFFFF) + high;
                temp = ((temp * uMD5Ints[0]) + uMD5Ints[1]) % 0x7FFFFFFF;

                // Add the i+1 to the temp variable and modulo
                // Then multiply by the third MD5Int and add the fourth, modulo!
                high = (uCHLIDInts[i + 1] + temp) % 0x7FFFFFFF;
                high = ((high * uMD5Ints[2]) + uMD5Ints[3]) % 0x7FFFFFFF;

                // Add both high and temp to low
                low += high + temp;
            }

            // Add some more MD5Ints and modulo again, also swap bytes around
            high = ulong.Parse(Swap_Bytes(String.Format("{0:x8}", (high + uMD5Ints[1]) % 0x7FFFFFFF), 2), NumberStyles.HexNumber);
            low = ulong.Parse(Swap_Bytes(String.Format("{0:x8}", (low + uMD5Ints[3]) % 0x7FFFFFFF), 2), NumberStyles.HexNumber);

            // Bitshift the high value 32 bits to the left and add low, then return it
            return (high << 32) + low;
        }

        private static string To_Hex(byte[] bBinary)
        {
            // For each character encode it
            string strHex = "";
            foreach (byte i in bBinary)
                strHex += Convert.ToString(i, 16).PadLeft(2, '0');

            // Return the new stirng
            return strHex;
        }

        private static string Swap_Bytes(string strString, int iStep)
        {
            // Walk over each iStep characters
            string strNewString = "";
            for (int i = 0; i < strString.Length; i += iStep)
                strNewString = strString.Substring(i, iStep) + strNewString;

            // Return the result
            return strNewString;
        }
    }
}
