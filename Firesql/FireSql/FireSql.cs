using System.Net.Mail;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;


namespace FireSql;

public class FireSql
{
    [UnmanagedCallersOnly(EntryPoint = "FireSqlRaw", CallConvs = [typeof(CallConvCdecl)])]

    public static IntPtr ExecuteFireSql(
        IntPtr coreHandlerPtr,
        IntPtr queryPtr,
        IntPtr paramListPtr,
        IntPtr paramTypePtr, 
        IntPtr paramValuesPtr
    )
    {
        try
        {
            string coreHandler = Marshal.PtrToStringUni(coreHandlerPtr) ?? string.Empty;
            string query = Marshal.PtrToStringUni(queryPtr) ?? string.Empty;
            string paramList = Marshal.PtrToStringUni(paramListPtr) ?? string.Empty;
            string paramType = Marshal.PtrToStringUni(paramTypePtr) ?? string.Empty;
            string paramValues = Marshal.PtrToStringUni(paramValuesPtr) ?? string.Empty;


            string[] paramNames = paramList.Split('~', StringSplitOptions.RemoveEmptyEntries);
            string[] paramVals = paramValues.Split('~', StringSplitOptions.RemoveEmptyEntries);


            string debugParams = "";

            for (int i = 0; i < Math.Min(paramNames.Length, paramVals.Length); i++)
            {
                debugParams += $"{paramNames[i]} = {paramVals[i]}";
            }


            string dummyJson = """
        [
            {"email": "user1@example.com"},
            {"email": "user2@example.com"}
        ]
        """;

            return Marshal.StringToHGlobalAnsi(dummyJson); 

        }
        catch (Exception ex)
        {
            return Marshal.StringToHGlobalAnsi("Error: " + ex.Message);

        }
    }

    [UnmanagedCallersOnly(EntryPoint = "FreeFireSql", CallConvs = [typeof(CallConvCdecl)])]
    public static void FreeFireSql(IntPtr ptr)
    {
        if (ptr != IntPtr.Zero) Marshal.FreeHGlobal(ptr);
    }

}
