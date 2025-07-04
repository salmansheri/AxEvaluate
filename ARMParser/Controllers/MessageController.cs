using System;
using System.Runtime.InteropServices;
using System.Text;
using GetMessage.Dto;
using GetMessage.Helpers;
using Microsoft.AspNetCore.Mvc;

namespace GetMessage.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MessageController : ControllerBase
    {
        private const string DllName = "dmessagelib"; // Linux shared library

        // Import GetMessage
        [DllImport(DllName, CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
        private static extern void GetMessage([Out] StringBuilder buffer, int bufSize);

        [HttpGet("getmessage")]
        public IActionResult GetMessageFromSo()
        {
            int bufferSize = 1024;
            var buffer = new StringBuilder(bufferSize);

            try
            {
                GetMessage(buffer, bufferSize);
                string message = buffer.ToString().TrimEnd('\0');
                return Ok(new { Message = message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Error = ex.Message });
            }
        }

        // Import ProcessMessage
        [DllImport(DllName, CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
        private static extern void ProcessMessage(string input, [Out] StringBuilder output, int bufSize);

        [HttpGet("processmessage")]
        public IActionResult ProcessMessageGet()
        {
            string inputString = "hello from .NET!";
            int bufferSize = 1024;
            var outputBuffer = new StringBuilder(bufferSize);

            try
            {
                ProcessMessage(inputString, outputBuffer, bufferSize);
                string message = outputBuffer.ToString().TrimEnd('\0');
                return Ok(new { Message = message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Error = ex.Message });
            }
        }

        // Import ProcessMessage2
        [DllImport(DllName, CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
        private static extern void ProcessMessage2(string input, [Out] StringBuilder output, int bufSize);

        [HttpPost("processmessage")]
        public IActionResult ProcessMessagePost([FromBody] string inputString)
        {
            int bufferSize = 2048;
            var outputBuffer = new StringBuilder(bufferSize);

            try
            {
                ProcessMessage2(inputString, outputBuffer, bufferSize);
                string message = outputBuffer.ToString().TrimEnd('\0');
                return Ok(new { Message = message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Error = ex.Message });
            }
        }

        // Import Eval
        [DllImport(DllName, CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
        private static extern void Eval(string input, [Out] StringBuilder output, int bufSize);

        [HttpPost("eval")]
        public IActionResult EvalPost([FromBody] string inputString)
        {
            int bufferSize = 2048;
            var outputBuffer = new StringBuilder(bufferSize);

            try
            {
                Eval(inputString, outputBuffer, bufferSize);
                string result = outputBuffer.ToString().TrimEnd('\0');
                return Ok(new { Message = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Error = ex.Message });
            }
        }

        // Enrypt
        //[DllImport(DllName, CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
        //private static extern void TestEncrypt(string input, [Out] StringBuilder output, int bufSize);

        [DllImport(DllName, CharSet = CharSet.Unicode, CallingConvention = CallingConvention.Cdecl)]
        private static extern void TestEncrypt(
    [MarshalAs(UnmanagedType.LPWStr)] string input,
    [Out, MarshalAs(UnmanagedType.LPWStr)] StringBuilder output,
    int bufSize);

        [HttpPost("encrypt")]
        public IActionResult TestEncryptPost([FromBody] string inputString)
        {
            int bufferSize = 2048;
            var outputBuffer = new StringBuilder(bufferSize);

            try
            {
                TestEncrypt(inputString, outputBuffer, bufferSize);
                string result = outputBuffer.ToString().TrimEnd('\0');
                return Ok(new { Message = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Error = ex.Message });
            }
        }

        [HttpPost("AxEvaluate")]
        public IActionResult AxEvaluate([FromBody] AxEvaluateRequestDto request)
        {
            try
            {
                foreach (var kvp in request.axEvaluate.vars)
                {
                    string name = kvp.Key;
                    string raw = kvp.Value;
                    char varType;
                    string value;

                    if (raw.Contains("~") || raw.Length < 3)
                    {
                        varType = raw[0];
                        value = raw.Substring(2);

                    }
                    else
                    {
                        if (double.TryParse(raw, out _))
                        {
                            varType = 'N';
                            value = raw;
                        }
                        else
                        {
                            varType = 'C';
                            value = raw;
                        }
                    }

                    DllHelper.RegisterVar(name, varType, value); 
                
                    


                }

                var expression = request.axEvaluate.expr.value;
                var outputBuffer = new StringBuilder(1024);

                DllHelper.Eval(expression, outputBuffer, outputBuffer.Capacity);

                return Ok(new { result = outputBuffer.ToString().TrimEnd('\0') });


            }
            catch (Exception ex)
            {
                return StatusCode(500, new { status = "Failed", Message = ex.Message }); 
            }
        }



    }
}
