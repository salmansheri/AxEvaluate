using System;
using System.Runtime.InteropServices;
using System.Text;

namespace GetMessage.Helpers;

public static class DllHelper
{
    [DllImport("dmessagelib", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode)]
    public static extern void RegisterVar(string varName, char varType, string Value);

    [DllImport("dmessagelib", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode)]
    public static extern void Eval(string expression, StringBuilder output, int bufferSize);

    [DllImport("dmessagelib", CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
    public static extern void RegisterVarListInterop(string data);

    [DllImport("dmessagelib", CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
    public static extern void RegisterVarJsonInterop(string json); 

    



}
