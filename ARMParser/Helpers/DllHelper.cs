using System;
using System.Runtime.InteropServices;
using System.Text;

namespace GetMessage.Helpers;

public class DllHelper
{
    [DllImport("dmessagelib", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode)]
    public static extern void RegisterVar(string varName, char varType, string Value);

    [DllImport("dmessagelib", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode)]
    public static extern void Eval(string expression, StringBuilder output, int bufferSize); 



}
