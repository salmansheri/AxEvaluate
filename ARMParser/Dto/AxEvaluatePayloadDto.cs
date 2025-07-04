using System;


namespace GetMessage.Dto;

public class AxEvaluatePayloadDto
{
    public Dictionary<string, string> vars { get; set; } = new();
    public Expression expr { get; set; } = new(); 


}

public class Expression
{
    public string value { get; set; } = string.Empty; 
}
