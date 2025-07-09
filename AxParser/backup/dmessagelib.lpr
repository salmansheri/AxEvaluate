library dmessagelib;

uses
  cwstring,
  SysUtils,
  Classes,
  UParse in 'UParse.pas',
  RegExpr;

var
  Parser: TEVAL = nil;
  LogFile: TextFile;
  LogFileName: string = 'dll_debug.log';

// Logging utility procedures
procedure WriteLog(const msg: string);
var
  timestamp: string;
begin
  try
    timestamp := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now);
    Append(LogFile);
    WriteLn(LogFile, '[' + timestamp + '] ' + msg);
    Flush(LogFile);
    Close(LogFile);
  except
  end;
end;

procedure LogVarList(const context: string);
var
  i: Integer;
  varInfo: string;
begin
  try
    if Assigned(Parser) and Assigned(Parser.VarList) then
    begin
      WriteLog(context + ' - VarList Count: ' + IntToStr(Parser.VarList.Count));
      for i := 0 to Parser.VarList.Count - 1 do
      begin
        varInfo := Parser.VarList[i];
        WriteLog(context + ' - VarList[' + IntToStr(i) + ']: ' + varInfo);
      end;
      if Parser.VarList.Count = 0 then
        WriteLog(context + ' - VarList is EMPTY');
    end
    else
    begin
      if not Assigned(Parser) then
        WriteLog(context + ' - Parser is NIL')
      else
        WriteLog(context + ' - Parser.VarList is NIL');
    end;
  except
    on E: Exception do
      WriteLog(context + ' - ERROR logging VarList: ' + E.Message);
  end;
end;

procedure InitializeLogging;
begin
  try
    AssignFile(LogFile, LogFileName);
    if FileExists(LogFileName) then
      Append(LogFile)
    else
      Rewrite(LogFile);
    Close(LogFile);
  except
  end;
end;

function EncryptMessage(input: PWideChar; output: PWideChar; bufferSize: Integer): Integer; cdecl; external 'libCryptoLibrary.so';

procedure TestEncrypt(Input: PWideChar; Output: PWideChar; BufSize: Integer); cdecl;
var
  Buffer: array[0..1023] of WideChar;
  OutputStr: WideString;
begin
  WriteLog('=== TestEncrypt called ===');
  LogVarList('TestEncrypt START');
  if EncryptMessage(Input, @Buffer[0], SizeOf(Buffer)) = 0 then
    OutputStr := WideString(Buffer)
  else
    OutputStr := 'Encryption failed.';
  StrPLCopy(Output, OutputStr, BufSize - 1);
  LogVarList('TestEncrypt END');
  WriteLog('=== TestEncrypt completed ===');
end;

procedure GetMessage(Buffer: PWideChar; BufSize: Integer); cdecl;
const
  Msg: WideString = 'Hello from Lazarus!';
begin
  WriteLog('=== GetMessage called ===');
  LogVarList('GetMessage START');
  StrPLCopy(Buffer, Msg, BufSize - 1);
  LogVarList('GetMessage END');
  WriteLog('=== GetMessage completed ===');
end;

procedure ProcessMessage(Input: PWideChar; Output: PWideChar; BufSize: Integer); cdecl;
var
  ProcessedStr: WideString;
begin
  WriteLog('=== ProcessMessage called ===');
  LogVarList('ProcessMessage START');
  ProcessedStr := WideUpperCase(Input);
  StrPLCopy(Output, ProcessedStr, BufSize - 1);
  LogVarList('ProcessMessage END');
  WriteLog('=== ProcessMessage completed ===');
end;

procedure ProcessMessage2(Input: PWideChar; Output: PWideChar; BufSize: Integer); cdecl;
var
  ProcessedStr: WideString;
begin
  WriteLog('=== ProcessMessage2 called ===');
  LogVarList('ProcessMessage2 START');
  ProcessedStr := WideUpperCase(Input);
  StrPLCopy(Output, ProcessedStr, BufSize - 1);
  LogVarList('ProcessMessage2 END');
  WriteLog('=== ProcessMessage2 completed ===');
end;

procedure ResetParser; cdecl;
begin
  WriteLog('*** RESET PARSER CALLED ***');
  LogVarList('RESET START');
  if Assigned(Parser) then
  begin
    WriteLog('RESET - Freeing existing parser');
    try
      FreeAndNil(Parser);
      WriteLog('RESET - Existing parser freed successfully');
    except
      on E: Exception do
      begin
        WriteLog('RESET - ERROR freeing existing parser: ' + E.Message);
        Parser := nil;
      end;
    end;
  end
  else
    WriteLog('RESET - No existing parser to free');

  try
    Parser := TEVAL.Create;
    WriteLog('RESET - New parser created successfully');
  except
    on E: Exception do
    begin
      WriteLog('RESET - ERROR creating new parser: ' + E.Message);
      Parser := nil;
      raise;
    end;
  end;

  LogVarList('RESET END');
  WriteLog('*** RESET PARSER COMPLETED ***');
end;

procedure Eval(Input: PWideChar; Output: PWideChar; BufSize: Integer); cdecl;
var
  ExprValue, OutputStr, SQLName, SQLText, FieldName, ResultStr: WideString;
  Regex: TRegExpr;
begin
  WriteLog('=== Eval called ===');
  ExprValue := WideString(Input);
  WriteLog('Eval - Input expression: ' + ExprValue);

  if not Assigned(Parser) then
  begin
    OutputStr := 'Parser not initialized.';
    WriteLog('Eval - ERROR: Parser not initialized');
  end
  else
  begin
    // Handle firesql
    Regex := TRegExpr.Create;
    try
      Regex.Expression := 'firesql\(\{(.+?)\},\{(.+?)\}\);sqlgetvalue\(\{\1\},\{(.+?)\}\)';
      if Regex.Exec(ExprValue) then
      begin
        SQLName := Regex.Match[1];
        SQLText := Regex.Match[2];
        FieldName := Regex.Match[3];

        WriteLog('Eval - SQLName: ' + SQLName);
        WriteLog('Eval - SQLText: ' + SQLText);
        WriteLog('Eval - FieldName: ' + FieldName);


        OutputStr := Parser.FireSql(
          SQLName,
          SQLText,
          Parser.GetParamNamesTilde,
          Parser.GetParamTypesTilde,
          Parser.GetParamValuesTilde
        );


        Parser.SQLGETValue(SQLName, FieldName, ResultStr);
        OutputStr := ResultStr;

        WriteLog('Eval - Final Output: ' + OutputStr);
      end
      else
      begin
        OutputStr := 'Invalid expression syntax';
        WriteLog('Eval - Invalid expression');
      end;
    finally
      Regex.Free;
    end;
  end;

  if OutputStr = '' then
    OutputStr := 'No result.';

  StrPLCopy(Output, OutputStr, BufSize - 1);
  WriteLog('Eval - Response sent');
end;

procedure RegisterVarInterop(VarName: PWideChar; VarType: WideChar; pValue: PWideChar); cdecl;
var
  NameStr, ValueStr: WideString;
begin
  WriteLog('=== RegisterVar called ===');
  NameStr := VarName;
  ValueStr := pValue;
  WriteLog('RegisterVar - Name: ' + NameStr + ', Type: ' + VarType + ', Value: ' + ValueStr);
  LogVarList('RegisterVar START');

  if not Assigned(Parser) then
    raise Exception.Create('Parser not initialized.')
  else
  begin
    try
      Parser.RegisterVar(NameStr, VarType, ValueStr);
      WriteLog('RegisterVar - Registered successfully');
    except
      on E: Exception do
      begin
        WriteLog('RegisterVar - ERROR: ' + E.Message);
        raise;
      end;
    end;
  end;

  LogVarList('RegisterVar END');
  WriteLog('=== RegisterVar completed ===');
end;

procedure RegisterVarListInterop(pData: PWideChar); cdecl;
var
  DataStr, NameStr, TypeStr, ValueStr: WideString;
  Items: TStringList;
  i: Integer;
begin
  WriteLog('=== RegisterVarListInterop called ===');
  DataStr := pData;
  Items := TStringList.Create;
  try
    ExtractStrings(['~'], [], PChar(DataStr), Items);
    i := 0;
    while i + 2 < Items.Count do
    begin
      NameStr := Items[i];
      TypeStr := Items[i + 1];
      ValueStr := Items[i + 2];
      Parser.RegisterVar(NameStr, TypeStr[1], ValueStr);
      WriteLog(Format('Registered: %s = %s (%s)', [NameStr, ValueStr, TypeStr]));
      Inc(i, 3);
    end;
  except
    on E: Exception do
      WriteLog('ERROR in RegisterVarListInterop: ' + E.Message);
  end;
  Items.Free;
end;


procedure CleanupParser;
begin
  WriteLog('*** CLEANUP PARSER CALLED ***');
  LogVarList('CLEANUP START');
  if Assigned(Parser) then
  begin
    FreeAndNil(Parser);
    WriteLog('CLEANUP - Parser freed');
  end
  else
    WriteLog('CLEANUP - Parser was NIL');
  WriteLog('*** CLEANUP PARSER COMPLETED ***');
end;

exports
  GetMessage,
  ProcessMessage,
  ProcessMessage2,
  Eval,
  TestEncrypt,
  RegisterVarInterop name 'RegisterVar',
  RegisterVarListInterop;

begin
  WriteLog('*** DLL INITIALIZATION STARTED ***');
  InitializeLogging;
  try
    Parser := TEVAL.Create;
    WriteLog('DLL INIT - Parser created');
  except
    on E: Exception do
    begin
      WriteLog('DLL INIT - ERROR creating parser: ' + E.Message);
      Parser := nil;
    end;
  end;
  LogVarList('DLL INIT');
  AddExitProc(@CleanupParser);
  WriteLog('*** DLL INITIALIZATION COMPLETED ***');
end.

