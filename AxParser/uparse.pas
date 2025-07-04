unit UParse;

{copied from ver Axpert9-XE3\Ver 11.2}

interface
uses
  SysUtils, Classes, Math, Variants, DOM, XMLRead, XMLWrite, DateUtils, StrUtils, uJSONUtils, memds, DB;


function FireSqlRaw(
  coreHandler: PChar;
  aQuery: PChar;
  paramList: PChar;
  paramType: PChar;
  paramValues: PChar
): PChar; cdecl; external 'libFireSql.so';

procedure FreeFireSql(ptr: PChar); cdecl; external 'libFireSql.so';




type TSetChar = set of Char;

type TParamArray = array[1..20] of String;

type TFunctions = record
 Fname : String;
 FType : Char;
 FParam : TParamArray;
 FParamCount : integer;
 FParamIndex : integer;
end;

type PFunctions = ^TFunctions;

type pPrep = ^TPrep;
TPrep = Record
  num, pIndex : integer;
  FCall : pFunctions;
  ExprList, ExprTypeList, OrgList : TStringList;
  TypeString : String;
end;



TOnSQLGet   = Procedure(SQLName,FieldName : String;Var ResultStr: String) of object;
TOnFindRecord = Procedure(SQLName,SearchField,SearchValue: String;var found: String) of object;
TOnFireSql  = Procedure(SQLName,SqlText: String) of object;
TOnCSVImport = procedure(DefName:String) of Object;

TCreateTStruct = function(transid : String):String of object;
TDeleteTStructure = function(sname : String):String of object;


//ReadTStructDef , WriteTStructDef , DeleteTStructDef Method pointers defined


//ReadIviewDef ,DeleteIviewDef method pointer

//ReadAxGloDef method pointer

type TEVAL = class
 private
    ValidFncList  : TList;
    FncList       : TList;
    Bracket       : String;
    ExpList : TStringList;
    ExpTypeList : TStringList;
    NewExprTypeList : TStringList;
    ExpIndex : Integer;
    StrCount : integer;
    DynamicCompute : boolean;
    FunList, FunTypeList, StkList, StkTypeList, Cpf : TStringList;
    prep, fprep : pPrep;
    CallType : Char;
    PrepList : TList;
    Prepnum : Integer;
    QueryList : TList;
    //CopyTable, CopyPost, QLockSeq, ModTable, QSeq : TXDS;
    CopyTables : TList;
    CopyRecordIds, loops, loopcond : TStringList;
    NoAppend  : String;
    //autorec:pAutoGenRec;

    Function IfFunction(LastWord : String) : boolean;
    Function IfParams(ParamMaster : String) : Boolean;
    Function EvalFunction : String;
    Function ValidFnc(s : String) : PFunctions;

    Procedure CopyParam(S : String);
    Procedure EvalFun;

    function ConvertToPostFix(ExprList,ExprTypeList: TStringList): TStringList;
    function InputPrecedence(StkVariable: String): integer;
    function StackPrecedence(StkVariable: String): integer;
    function EvaluatePostFix(ExprList, ExprTypeList: TStringList): String;
    function IsOperator(Variable: String): boolean;
    function Compute(Value1,Value2,Operator_,Expressiontype: String):String;
    function EvaluateExpression(ExprList,ExprTypeList: TStringList): String;
    procedure StartString;
    procedure EndString;
    Function Amt_Word(Str_Num : String) : String;
    function AmtInWordMillion(Str_num: String): String;
    function findcharpos(vStr:String;iStr:Char):integer;
    function chkuniqchar(vStr:String):Boolean;
    procedure Clearfnclist;
    Function TrimSpace(S:String):String;
    function EvaluatePower(ConstVal, Exponent: Extended): String;
    Function PAbs(s:String):String;
    procedure ClearPrepList;
    procedure ReplaceVars(Slist, typlist:TStringList;TypeString:String);
    procedure SetReturnValue(handle, i: integer; s: String);
    procedure BindVars(handle: integer);
    Function GetLength(pvalue : String) :integer;
    function ExtractNum(s: String): String;
    procedure FindRecord(SQLName, SearchField, SearchValue: String;
      var resultstr: String);
    //procedure FireSql(SQLName, SqlText: String);
    //function FireSql(SQLName, SqlText: WideString):WideString; // added after edit

    function ReplaceDynamicparams(SQLText: String): String;
    function GetDelimitedStr(SQLName, FieldName,
      Delimiter: String): String;
    function ConvertMD5(s: String): String;
    //Function TableFound(Tablename :String;q:TXDS) :Boolean;
    function FieldString(fname, ftype: String; fwidth,
      fdec: Integer): String;
    //function GetFieldType(fldDataType: TFieldType): String;
    procedure DoMRP(SDate, EDate: String);
    function Mods(v1,v2 : integer) : integer;
    //function GetCopyTable(S: String): TXDS;
    procedure InitCopyToTable(CTableNames:String);
    procedure CopyToTable(CTableNames:String;CallRow:Integer);
    procedure PostToTable(TableName, SearchFields, NoAppendStr:String);
    function verifyTree(TreeName: String): String;
//    procedure BuildTreeLink(TreeName: String);
//    function Isnumeral(s: String): boolean;
    procedure SetDeps(TblName : String);
    procedure ExportSQL(SQLText, FormatString, FileName , Delimiter: string; withheader : String = 'f');
    //function GetLastNo(arec : pAutoGenRec; axp:TAxprovider):string;
    //function GetParentValue(arec: pAutoGenRec; axp: TAxprovider): String;
    //function GetPrefixFieldValue(arec: pAutoGenRec; axp: TAxProvider): String;
    function EncryptStr(pValue: String): String;
    function DecryptStr(pValue: String): String;
    procedure CloneDir(SourceDir, TargetDir: String);
    procedure CloneFile(SourceFile, TargetFile: String; FailIfExists: string = 'false');
    procedure CreateFile(FileName, Data: String; OverWriteIfExists: string = 'false');
    procedure RemoveFile(FileName: String);
    procedure XCopyDir(SourceDir, TargetDir: String);
    procedure XCopyFile(SourceFile, TargetFile: String; FailIfExists: string = 'false');
    procedure DeleteDir(DirName: String);
    function GetCsvHeader(sFileName: String): String;
    procedure KillExcel(var App: Variant);
    procedure ConvertExcelToCSVFile(eFilePath, eFileName, tfilepath,
      tfilename: String);
    Procedure SetToRedis(HostName, KeyName, KeyValue , pwd : String ; timeout : integer); overload;
    Function GetFromRedis(Hostname, KeyName , pwd : String): String;  overload;
    Procedure SetToRedis(HostName, KeyName, KeyValue : String);  overload;
    Function GetFromRedis(Hostname, KeyName : String): String;  overload;
    function StringPOS(sSubString,sString: String;sSeparator : string = ','): String;
    function GetAxValue(rule, variable, code :  String): String;
    procedure ConvertFile(SourceFile, TargetFile, OverWriteTargetFile: String);
    procedure ConvertCSVToExcelFile(sSrcFile, sTgtFile, sOverWrite: String);

 protected
    Operators    : TSetChar;
    Delimiters   : TSetChar;
    ValueList    : TStringList;
    ExpStrPos     : integer;
    numbers       : TSetChar;
    ZeroValue    : String;

    //Procedure CallFunction(FncName : String; P : TParamArray; ParamCount: integer; var S:String); virtual;
    Function IfVariable(LastWord : String): boolean; virtual;
    function FindAndReplace(S, FindWhat, ReplaceWith: String): String;

 public
    ErrorMsg : String;
    Value : variant;
    Error : integer;
    ExpressionType : Char;
    Varlist       : TStringList;
    VarTypeStr    : String;
    LastVarType : String;
    Expression    : String;
    OnSQLGet           : TOnSQLGet;
    OnFireSQL     : TOnFireSQL;
    OnFindRecord       : TOnFindRecord;
    ExprSet, Varsused : TStringList;
//    SetProgress : TOnSetProgress;
//    OnDoMRP : TOnDoMRP;
//    OnDisplayMessage : TOnDisplayMessage;
//    OnSQLPost : TOnSQLPost;
//    OnExportSQL : TOnExportSQL ;
//    OnPostFromIview : TOnPostFromIview;
//    OnDownLoadAttachment : TOnDownLoadAttachment;
//    OnCreateTStruct : TCreateTStruct;
//    OnDeleteTStructure : TDeleteTStructure;
//    OnDeleteStructureWithDC : TOnDeleteStructureWithDC;
//    OnCopyFileFromTableToFolder : TOnCopyFileFromTableToFolder;
//
//    OnOpenTstruct : TOnOpenTstruct;
//    OnOpenIview : TOnOpenIview;
//    OnSave : TOnSave;
//    OnPdf : TOnPdf;
//    OnShowMessage : TOnShowMessage;
//    OnPrintForm : TOnPrintForm;
//    OnPreviewForm : TOnPreviewForm;
//    OnCancelTransaction : TOnCancelTransaction;
//    OnDeleteTransaction : TOnDeleteTransaction;
//    OnLoadTransaction : TOnLoadTransaction;
//    OnViewAttachment : TOnViewAttachment;
//    OnImportIntoGrid : TOnImportIntoGrid;
//    OnCSVImporting : TOnCSVImporting;
//    OnPost : TOnPost;
//
//    //OnReadTStructDef , OnWriteTStructDef & OnDeleteTStructDef public objects of TOnReadTStructDef , TOnWriteTStructDef and TOnDeleteTStructDef created.
//    OnReadTStructDef : TOnReadTStructDef;
//    OnWriteTStructDef : TOnWriteTStructDef;
//    OnDeleteTStructDef : TOnDeleteTStructDef;
//
//    //OnReadIviewDef,OnDeleteIviewDef public object of TOnReadIviewDef , TOnDeleteIviewDef created
//    OnReadIviewDef : TOnReadIviewDef;
//    OnDeleteIviewDef : TOnDeleteIviewDef;
//
//    // OnReadAxGloDef public object of TOnReadAxGloDef created
//    OnReadAxGloDef : TOnReadAxGloDef;
//    OnDoSaveAsStructure : TOnDoSaveAsStructure;
//    OnNotify : TOnNotify;
//
//    axp : TAxProvider;
    raiseonactionerr : boolean;
    ExpSqlFileName,FilesGeneratedByFunctions  : String;
    firstCall : boolean;
    MemVarList : TStringlist;
    MemTypeStr : String;
//    Dict : TDictionary<String, String>;
    slParams : TStringlist;
    ParamName,CallFromGetDep : String;

    procedure EvalExps(slist: tstringlist);
    procedure Assign(source: TEval);
    procedure EvalExprSet(startpos:integer);
    Property FunctionList : TList Read ValidFncList;
    function IsVarEmpty(VarName: String): String;
    function RegisterVar(VarName: String; VarType: Char; pValue : String):integer;
    procedure RegisterFnc(FncName: String; FncType: Char);
    function Evaluate(Expr : String) : boolean;
    Function IsEmpty(pvalue : String): String;
    constructor create({AxPro : TAxProvider});
    Destructor Destroy; Override;
    Function Upper(Str : String) : String;
    Function Lower(Str : String) : String;
    Function DTOC(PDate : TDateTime) : String;
    function CMonthYear(Dt : TDateTime): String;
    Function CTOD(PDate : String) : TDateTime;
    Function Rnd(Frm : Extended; RV : Integer) : Extended;
    Function Stuff(Str1,Str2 : String; P : Integer) : String;
    Function Round(Num : Extended; D : Integer) : Extended;
    Function IIF(BoolExpression : Boolean; True_Res, False_Res : Variant) : Variant;
    Function AmtWord(Act_Num : Extended) : String;
    Function CurrAmtWord(Act_Num : Extended;CurcyName,SubCurcyName :String;MRep:Boolean;DecWidth: integer) : String;
    Function Val(StrNum : String): Extended;
    Function Str(Num : Extended): String;
    Function SubStr(S:String;Sposn,Num:integer) : String;
    Function AddToDate(Dt:TDateTime;count:integer) : TDateTime;
    Function MandY(PDateTime : TDateTime) : String;
    Function DaysElapsed(D1,D2:String):real;
    Function TimeElapsed(T1,T2:String):real;
    Function AddToTime(Timestr:String; AddTime : real): String;
    Function IsEmptyValue(pValue, DataType:String):String;
    function AddToMonth(Dt:TDateTime; N:integer) : TDateTime;
    function LastDayOfMonth(Dt:TDateTime):TDateTime;
    function ValidEncodeDate(y, m, d:word):TDateTime;
    procedure ConstructTable(s, tablename: String);
    function Eval(Expr:String):String;
    function GetVarValue(VarName: String): String;
    Function Lpad(str1: String;Width: integer;padChar: Char): String;
    function Rpad(str1: String;Width: integer;padChar: Char): String;
    function VarsUsedInExpr(Expr: String; varnames: TStringList): String;
    Function Prepare(Expr:String) : integer;
    Function EvalPrepared(handle:Integer):Boolean;
    procedure SetVarValue(posn: integer; VarType: Char; pvalue: String);
    function GetNumber(s: String): String;
    function IsFunctionUsed(s: String): boolean;
    function BulkExecute(s: String) : String;
    function SaveSqlResult(sqltext,filename,delimitchar:String) : String;
    function doStoredProc(name , invars , outvars : String): String;
    //procedure ReplaceParams(Q: TXDS);
    //procedure AutoGenPost(arec:pAutoGenRec; axp:TAxProvider);
    function AxpCeil(pval:Extended):Integer;
    function AxpFloor(pval:Extended):Integer;
    Function Days360(StartDate, EndDate:TDateTime;Method:String = 'False'):Integer;
    function NetWorkDays(StartDate, EndDate: TDatetime; Holidays: Integer;
      Method: String='False'): Integer;
    procedure SQLRegVar(SQLText:String;Direct:String='False');
    function Isnumeral(s: String): boolean;
    function ExtractQueryParams(sqltext: String): String;
    function AxMemLoad(sFnName, sParamVars: String): String;
    //function FireSql(SQLName, SqlText: WideString):WideString;
   function FireSql(
  coreHandler, aQuery, aParamName, paramType, paramValues: WideString
): WideString;
     procedure SQLGETValue(SQLName, FieldName: String;
      var ResultStr: String);


end;

Const
   LocDecimalSeparator = '.';
   LocThousandSeparator = ',';

implementation



constructor TEval.create({AxPro : TAxProvider});
var i,j : Integer;
    s : String;
begin
 inherited create;
 //axp := AxPro;
 VarList := TStringList.create;
 VarTypeStr := '';
 ValueList := TStringList.create;
 MemVarList := TStringList.create;
 MemTypeStr := '';
 ZeroValue := '';
 ValidFncList := TList.create;
 FncList := TList.create;
 QueryList := TList.create;
 CopyTables := TList.Create;
 Bracket := '';
 ExpList := TStringList.create;
 ExpTypeList := TStringList.create;
 NewExprTypeList := TStringList.create;
 FunList := TStringList.create;
 FunTypeList := TStringList.create;
 StkList := TStringList.Create;
 StkTypeList := TStringList.create;
 Cpf := TStringList.create;
 PrepList := TList.create;
 VarList.Capacity := 500;
 ValueList.Capacity := 500;
 ValidFncList.Capacity := 500;
 ExpList.Capacity := 300;
 ExpTypeList.Capacity := 300;
 NewExprTypeList.Capacity := 300;
 FunList.Capacity := 20;
 FunTypeList.capacity := 20;
 StkList.Capacity := 100;
 StkTypeList.Capacity := 100;
 Cpf.Capacity := 100;
 PrepList.Capacity := 500;
 Error := 0;
 ExpIndex := 0;
 StrCount := 0;
 DeLimiters := [' ','(',')',','];
 CallFromGetDep := '';
 Operators := ['+','-','*','/','>','<','=','#','&','|','$'];
 numbers := ['0','1','2','3','4','5','6','7','8','9','-','.'];
 //if axp.dbm.gf.LocDecimalSeparator <> '.' then
// begin
//   numbers := numbers-['.'];
//   numbers := numbers+[','];
// end;

 RegisterVar('ApprovalNo', 'n', '0');
 RegisterVar('Recordid','n','0');
 RegisterVar('ApprovalStatus', 'c', '');
// RegisterVar('CompanyName', 'c', axp.dbm.gf.companyname);
// RegisterVar('UserName', 'c', axp.dbm.gf.username);
// RegisterVar('UserGroup', 'c', axp.dbm.gf.usergroup);
// RegisterVar('UserGroupNo', 'c', axp.dbm.gf.usergroupno);
// RegisterVar('GroupNo', 'c', axp.dbm.gf.usergroupno);
// RegisterVar('UserRoles', 'c', axp.dbm.gf.userroles);
// RegisterVar('UserCategory', 'c', axp.dbm.gf.usercategory);
// RegisterVar('UserDepartment', 'c', axp.dbm.gf.userdepartment);
// RegisterVar('DbRep', 'c', axp.dbm.gf.dbrep);
// RegisterVar('CrRep', 'c', axp.dbm.gf.crrep);
// RegisterVar('ProfitPath', 'c', axp.dbm.gf.ProfitPath);
// RegisterVar('AxpertPath', 'c', axp.dbm.gf.AxpertPath);
// RegisterVar('ConnectionName', 'c', axp.dbm.gf.connectionname);
// RegisterVar('_MainCurr', 'c', axp.dbm.gf._MainCurr);
// RegisterVar('_SubCurr', 'c', axp.dbm.gf._subCurr);
// RegisterVar('_currdecimal', 'n', inttostr(axp.dbm.gf._currdecimal));
// RegisterVar('finyrst', 'd', DateTimeToStr(axp.dbm.gf.finyrst));
// RegisterVar('finyred', 'd', DateTimeToStr(axp.dbm.gf.finyred));
// RegisterVar('afinyrst', 'd', DateTimeToStr(axp.dbm.gf.afinyrst));
// RegisterVar('afinyred', 'd', DateTimeToStr(axp.dbm.gf.afinyred));
// RegisterVar('basecurrencyid', 'n', FloatTostr(axp.dbm.gf.BaseCurrencyId));
// if axp.dbm.gf.millions then
//   RegisterVar('_millions', 'c', 'T')
// else
//   RegisterVar('_millions', 'c', 'F');
// if axp.dbm.gf.remoteLogin then
//   Registervar('_ConnectNo', 'c', axp.dbm.gf.sessionid)
// else
//   Registervar('_ConnectNo', 'c', inttostr(axp.dbm.gf.sescount));
// RegisterVar('SiteNo', 'n', IntToStr(axp.dbm.gf.SiteNo));
// RegisterVar('axp_timezone', 'n', '0');
// RegisterVar('axp_language', 'c', axp.dbm.gf.Applanguage);
// RegisterVar('axp_datemode', 'n', '0');
// if axp.dbm.gf.IsService then
//   RegisterVar('axp_service', 'c','T')
// else
//   RegisterVar('axp_service', 'c','F');
// if axp.dbm.gf.pwd_AES then
//   RegisterVar('axp_md5pwd', 'c', 'F')
// else
//   RegisterVar('axp_md5pwd', 'c', 'T');
 RegisterFnc('Power','n');
 RegisterFnc('abs','n');
 RegisterFnc('IsEmpty','c');
 RegisterFnc('IsEmptyValue', 'c');
 RegisterFnc('Upper', 'c');
 RegisterFnc('Lower','c');
 RegisterFnc('DTOC','c');
 RegisterFnc('CMonthYear','c');
 RegisterFnc('CTOD','d');
 RegisterFnc('MakeDate','d');
 RegisterFnc('Rnd','n');
 RegisterFnc('Stuff','n');
 RegisterFnc('Round','n');
 RegisterFnc('IIF','v');
 RegisterFnc('AmtWord','c');
 RegisterFnc('CurrAmtWord','c');
 RegisterFnc('Val','n');
 RegisterFnc('Str','c');
 RegisterFnc('SubStr','c');
 RegisterFnc('AddToDate','d');
 RegisterFnc('Date','d');
 RegisterFnc('Time','s');
 RegisterFnc('dayofdate','n');
 RegisterFnc('monthofdate','n');
 RegisterFnc('yearofdate','n');
 RegisterFnc('MandY','c');
 RegisterFnc('DaysElapsed','n');
 RegisterFnc('TimeElapsed','n');
 RegisterFnc('GetLength','n');
 RegisterFnc('AddToTime', 'c');
 RegisterFnc('FormatDateTime','c');
 RegisterFnc('AddToMonth','d');
 RegisterFnc('LastDayOfMonth', 'd');
 RegisterFnc('ValidEncodeDate', 'd');
 RegisterFnc('Eval','s');
 RegisterFnc('Trim', 's');
 RegisterFnc('RegVar','s'); //kishore
 RegisterFnc('IsVarEmpty', 's');
 RegisterFnc('sqlget','s');
 RegisterFnc('findrecord','s');
 RegisterFnc('firesql','s');
 RegisterFnc('getdelimitedstr','s');
 RegisterFnc('extractnum', 's');
 RegisterFnc('trimspace', 's');
 RegisterFnc('findandreplace','s');
 RegisterFnc('domrp','s');
 RegisterFnc('mod','n');
 RegisterFnc('verifytree','s');
 RegisterFnc('buildtreelink','s');
 RegisterFnc('convertmd5', 's');
 RegisterFnc('bulkexecute', 's');
 RegisterFnc('constructtable', 's');
 RegisterFnc('posttotable', 's');
 RegisterFnc('settoredis','s');
 RegisterFnc('getfromredis','s');
 RegisterFnc('savesqlresult', 's');
 RegisterFnc('setdeps','s');
 RegisterFnc('doStoredProc','s');
 RegisterFnc('sqlpost','s');
 RegisterFnc('nowstring','s');
 RegisterFnc('exportsql','s');
 RegisterFnc('postfromiview','s');
 RegisterFnc('downloadattachment','s');
 RegisterFnc('AxpCeil', 'n');
 RegisterFnc('AxpFloor', 'n');
 RegisterFnc('Days360', 'n');
 RegisterFnc('NetWorkDays', 'n');
 RegisterFnc('SQLRegVar', 'n');
 RegisterFnc('encryptstr', 's');
 RegisterFnc('decryptstr', 's');
 RegisterFnc('CreateTStruct','s');
 RegisterFnc('DeleteStructure','s');
 RegisterFnc('DeleteStructureWithDC','s');

 RegisterFnc ('OpenTstruct','s');
 RegisterFnc ('OpenIview','s');
 RegisterFnc ('Save','s');
 RegisterFnc ('Pdf','s');
 RegisterFnc ('ShowMessage','s');
 RegisterFnc ('PrintForm','s');
 RegisterFnc ('PreviewForm','s');
 RegisterFnc ('CancelTransaction','s');
 RegisterFnc ('DeleteTransaction','s');
 RegisterFnc ('LoadTransaction','s');
 RegisterFnc ('ViewAttachment','s');
 RegisterFnc ('ImportIntoGrid','s');
 RegisterFnc ('CSVImporting','s');
 RegisterFnc ('Post','s');

 RegisterFnc('clonedir', 's');
 RegisterFnc('clonefile', 's');
 RegisterFnc('createfile', 's');
 RegisterFnc('removefile', 's');
 RegisterFnc('xcopydir', 's');
 RegisterFnc('xcopyfile', 's');
 RegisterFnc('deletedir', 's');

 RegisterFnc('GetCsvHeader', 's');
 RegisterFnc('ConvertExcelToCSVFile', 's');
 RegisterFnc('ConvertFile', 's');
 RegiSterFnc('CopyFileFromTableToFolder','s');

 //Registering ReadTstructDef , WriteTstructDef & DeleteTStructDef functions
 RegisterFnc('ReadTstructDef','s');
 RegisterFnc('WriteTstructDef','s');
 RegisterFnc('DeleteTStructDef','s');

 //Registering ReadIviewDef,DeleteIviewDef functions
 RegisterFnc('ReadIviewDef','s');
 RegisterFnc('DeleteIviewDef','s');

 //Registering ReadAxGloDef function
 RegisterFnc('ReadAxGloDef','s');
 RegisterFnc('DoSaveAsStructure','s');
 RegisterFnc('Notify','s');

// RegisterFnc('AxMemLoad','s');
 RegisterFnc('StringPOS','s');
 RegisterFnc('GetAxValue','s');

 CallType := 'n';
 ExprSet := nil;
 //SetProgress := nil;
 varsused:=tstringlist.create;
// if assigned(axp.dbm.gf.appvars) then begin
//   if (axp.dbm.gf.AppVarTypes = '') then
//   begin
//     for i := 0 to axp.dbm.gf.appvars.Count-1 do
//       RegisterVar(axp.dbm.gf.appvars.Names[i], 'c', axp.dbm.gf.appvars.Values[axp.dbm.gf.appvars.Names[i]]);
//   end else
//   begin
//     j := length(axp.dbm.gf.AppVarTypes);
//     for i := 0 to axp.dbm.gf.appvars.Count-1 do
//     begin
//       if i+1 <= j then
//          RegisterVar(axp.dbm.gf.appvars.Names[i], axp.dbm.gf.AppVarTypes[i+1], axp.dbm.gf.appvars.Values[axp.dbm.gf.appvars.Names[i]])
//       else
//          RegisterVar(axp.dbm.gf.appvars.Names[i], 'c', axp.dbm.gf.appvars.Values[axp.dbm.gf.appvars.Names[i]])
//     end;
//   end;
// end;
// NoAppend := '';
 CopyRecordIds := TStringList.create;
// CopyPost:=nil;
// Copytable := nil;
 loops:=tstringlist.create;
 loopcond:=tstringlist.create;
 raiseonactionerr := false;
 ExpSqlFileName := '';
 FilesGeneratedByFunctions := '';
 firstCall := true;
 s := GetVarValue('axp_dataexchange');
// if lowercase(s) = 'yes' then
//   axp.dbm.gf.axpdataexchange := true
// else
//   axp.dbm.gf.axpdataexchange := false;
// s := GetVarValue('axp_multilanguage');
// if lowercase(s) = 'yes' then
//   axp.dbm.gf.multilingual := true;
// s := GetVarValue('axp_datemode');
// if s = '1' then axp.dbm.gf.datemode := '8907mode'
// else axp.dbm.gf.datemode := '8909mode';
// QLockSeq := nil;
// ModTable := nil;
// QSeq := nil;
// slParams := TStringlist.Create;
// Dict := TDictionary<String, String>.Create;
end;

Function TEval.IsEmpty(pvalue : String): String;
Begin
    if (trim(pValue) = '') OR ((lowercase(trim(pvalue))) = 'null') then Result := 'T' else Result := 'F';
End;

Function TEVal.IsEmptyValue(pValue, DataType:String):String;
begin
 Result := 'F';
 Datatype := lowercase(datatype);
 pValue := trim(pvalue);
 if (pvalue = '') or (lowercase(pvalue) = 'null') then
  Result := 'T'
 else begin
//  if (DataType = 'd') and (pvalue = axp.dbm.gf.ShortDateFormat.DateSeparator+'  '+axp.dbm.gf.ShortDateFormat.DateSeparator) then
//   Result := 'T'
//  else if (DataType = 'n') and (axp.dbm.gf.strtofloatz(pvalue) = 0) then
//   Result := 'T'
 end;
end;

Function TEval.IsVarEmpty(VarName:String):String;
var posn :integer;
    v : String;
    n : extended;
begin
  result := 'T';
  posn := VarList.IndexOf(lowercase(Varname));
  if Posn >= 0 then begin
    v := ValueList[posn];
    if (lowercase(VarTypeStr[posn+1]) = 'n') then begin
     if v <> '' then n := strtofloat(v) else n := 0;
     if (zerovalue[posn+1] = 'F') and (n = 0) then v := '';
    end;
  End;
  Result := IsEmptyValue(v, VarTypeStr[posn+1]);
end;

Function TEval.Prepare(Expr:String):integer;
begin
  Result := -1;
  CallType := 'p';
  PrepNum := PrepList.Count;
  Evaluate(Expr);
  Result := PrepNum;
  CallType := 'n';
end;

procedure TEVal.BindVars(handle:integer);
var i,j, posn:integer;
    s:String;
begin
  i:=handle;
  while (i < PrepList.Count) do begin
    prep := Preplist[i];
    //prep := pPrep(PrepList[i]);  // ✅ typecast to your pointer type
    inc(i);
    if prep^.num <> handle then break;
    if assigned(prep^.ExprList) then begin
      for j:=0 to prep^.exprlist.count-1 do begin
        if prep^.TypeString[j+1] = 'u' then begin
          s := lowercase(prep^.exprlist[j]);
          posn := VarList.IndexOf(s);
          if posn >= 0 then begin
            prep^.ExprList[j] := IntToStr(Posn);
            prep^.OrgList[j] := IntToStr(Posn);
            prep^.TypeString[j+1] := 'v';
            prep^.ExprTypeList[j] := VarTypeStr[posn+1];
          end;
        end;
      end;
    end;
  end;
end;

function TEVAL.BulkExecute(s: String): String;
begin

end;

function TEVAL.EvalPrepared(handle: Integer): Boolean;
var i:integer;
    s,expr:String;
    f : pFunctions;
begin
  result := false;
  value := '';
  if handle = -1 then exit;
  calltype := 'e';
  i := handle;
  s := '';
  dynamiccompute := false;
  BindVars(handle);
  while (i < PrepList.Count) do begin
    prep := Preplist[i];
    if prep^.num <> handle then break;
    if assigned(prep^.ExprList) then begin
      ReplaceVars(prep^.ExprList, prep^.ExprTypeList, prep^.TypeString);
      s := EvaluatePostFix(prep^.ExprList, prep^.ExprTypeList);
      if assigned(prep^.fcall) then
        prep^.FCall^.FParam[prep^.pIndex] := s;
    end else if assigned(prep^.FCall) then begin
      s := '';
      f := prep^.FCall;
      //CallFunction(f^.Fname, f^.Fparam, f^.FParamCount, S);
//      axp.dbm.gf.DoDebug.msg('   Result of '+f^.fname +' = '+s);
      ExpressionType := f^.FType;
      SetReturnValue(handle, i, s);
      if f^.Fname='eval' then break;
    end;
    inc(i);
  end;
  CallType := 'n';
  if dynamiccompute then evaluate(s)
  else begin
    value := s;
    if value = '~e~' then value := '';
  end;
  Result := true;
  for i:=handle to PrepList.count-1 do begin
    prep := PrepList[i];
    if prep^.num <> handle then break;
    if assigned(prep^.exprlist) then
      prep^.exprlist.assign(prep^.OrgList);
  end;
end;

function TEVAL.SaveSqlResult(sqltext, filename, delimitchar: String): String;
begin

end;

procedure TEVAL.SetDeps(TblName: String);
begin

end;

procedure TEVal.SetReturnValue(handle, i:integer; s:String);
var k,j:integer;
    p:pPrep;
    x:String;
begin
  k := i;
  x := '_xcall'+inttostr(i);
  for k := i to PrepList.count-1 do begin
    p := pPrep(PrepList[k]);
    if p^.num <> handle then break;
    if (assigned(p^.ExprList)) then begin
      for j:=0 to p^.exprlist.count-1 do begin
        if p^.exprlist[j] = x then begin
          p^.exprlist[j] := s;
          break;
        end;
      end;
    end;
  end;
end;

procedure TEVal.ReplaceVars(Slist, typlist:TStringList; TypeString:String);
var s:String;
    i, posn:integer;
begin
  for i:=0 to SList.count-1 do begin
    s := lowercase(slist[i]);
    if typestring[i+1] = 'c' then begin
      typlist[i] := 'c';
      ExpressionType := 'c';
    end else if typestring[i+1] = 'v' then begin
      posn := StrToInt(s);
      if posn >= 0 then begin
        If Trim(ValueList[Posn]) = '' then
         SList[i] := '~e~'
        else begin
         SList[i] := ValueList[posn];
        end;
//        axp.dbm.gf.DoDebug.msg('   ' + varlist[posn]+' = '+valuelist[posn]);
        ExpressionType := VarTypeStr[posn+1];
        typlist[i] := VarTypeStr[posn+1];
      end;
    end;
  end;
end;

Function TEval.Evaluate(Expr: String): Boolean;
var
  position: Integer;
  ch: Char;
  ConstWord: Boolean;
begin
  try
    DynamicCompute := False;
    Value := '';

    while True do
    begin
      position := 1;
      Bracket := '';
      Clearfnclist;
      Expression := Trim(Expr);
      ExpList.Clear;
      ExpTypeList.Clear;
      ExpList.Add('');
      ExpTypeList.Add('v');
      ExpIndex := 0;
      Error := 0;
      StrCount := 0;
      ExpressionType := 'v';
      ConstWord := False;

      while True do
      begin
        if position <= Length(Expression) then
          ch := Expression[position]
        else
          ch := Chr(32);

        ExpStrPos := position;

        if (ch = '{') then
          StartString;

        if (ch = '}') then
        begin
          EndString;
          ConstWord := True;
          ExpressionType := 'c';
          if CallType = 'p' then
            ExpList[ExpIndex] := '_c_' + ExpList[ExpIndex];
        end;


        if (ch = '"') then
        begin
          Inc(position); // Skip opening quote
          ExpList[ExpIndex] := '';
          while (position <= Length(Expression)) and (Expression[position] <> '"') do
          begin
            ExpList[ExpIndex] := ExpList[ExpIndex] + Expression[position];
            Inc(position);
          end;
          ExpTypeList[ExpIndex] := 'c';
          ConstWord := True;
          Inc(position); // Skip closing quote
          Continue; // Skip rest of loop for this iteration
        end;

        if (ch in Delimiters) or (ch in Operators) then
        begin
          if not ConstWord then
          begin
            ExpTypeList[ExpIndex] := 'n';
            if not IfVariable(ExpList[ExpIndex]) then
            begin
              if not IfFunction(ExpList[ExpIndex]) then
              begin
                if not IfParams(ExpList[ExpIndex]) then
                begin
                  if (CallType <> 'p') and (ExpList[ExpIndex] <> '') and
                    (ExpList[ExpIndex] <> Chr(1)) and (ExpList[ExpIndex] <> Chr(2)) and
                    (not IsNumeral(ExpList[ExpIndex])) then
                    raise Exception.Create(ExpList[ExpIndex] + ' is not defined');
                end;
              end;
            end;
            position := ExpStrPos;
          end
          else
          begin
            ConstWord := False;
            ExpTypeList[ExpIndex] := 'c';
          end;

          if ch = '(' then
          begin
            if (Length(Bracket) > 0) and (Copy(Bracket, Length(Bracket), 1) = 'F') then
              ch := ' ';
            Bracket := Bracket + '(';
          end;

          if ch = ')' then
          begin
            Delete(Bracket, Length(Bracket), 1);
            if (Length(Bracket) > 0) and (Copy(Bracket, Length(Bracket), 1) = 'F') then
            begin
              ExpList.Add(Chr(2));
              ExpTypeList.Add('v');
              Delete(Bracket, Length(Bracket), 1);
              ch := ' ';
            end;
          end;

          if ch <> ' ' then
          begin
            ExpList.Add(ch);
            ExpTypeList.Add('v');
          end;

          ExpList.Add('');
          ExpTypeList.Add('v');
          ExpIndex := ExpList.Count - 1;
        end
        else
        begin
          if not (((ch = '{') and (StrCount = 1)) or ((ch = '}') and (StrCount = 0))) then
            ExpList[ExpIndex] := ExpList[ExpIndex] + ch;
        end;

        if position > Length(Expression) then
          Break;

        Inc(position);
      end;

      EvalFun;
      Value := EvaluateExpression(ExpList, ExpTypeList);
      if Value = '~e~' then
        Value := '';

      if (not DynamicCompute) or (CallType <> 'n') then
        Break;

      DynamicCompute := False;
      Expr := Value;
    end;

    Clearfnclist;
    Result := True;
  except
    on e: Exception do
    begin
      ErrorMsg := e.Message;
      Result := False;
    end;
  end;
end;

procedure TEVal.Clearfnclist;
var i:integer;
begin
 for i:=0 to fnclist.count-1 do
   dispose(pFunctions(fnclist[i]));
 fnclist.clear;
end;

Procedure TEval.EvalFun;
var i,j : integer;
    temp : String;
begin
 FunList.clear;
 FunTypeList.clear;
 i:=ExpList.count-1;
 fprep := nil;
 while true do begin
  temp := explist[i];
  if explist[i] = chr(1) then begin
   j := i+1;
   FunList.clear;
   FunTypeList.Clear;
   new(fprep);
   new(fprep^.fcall);
   while true do begin
    temp := explist[j];
    if (explist[j] <> '') and (explist[j] <> ',') and (explist[j] <> chr(2)) then begin
      FunList.add(explist[j]);
      FunTypeList.Add(ExpTypeList[j]);
    end;
    if (ExpList[j] = chr(2)) or (explist[j] = ',') then begin
     CopyParam(EvaluateExpression(FunList,FunTypeList));
     FunList.Clear;
     FunTypeList.Clear;
    end;
    if ExpList[j] = chr(2) then begin
     ExpList.Delete(j);
     ExpTypeList.Delete(j);
     break;
    end;
    explist.delete(j);
    ExpTypeList.Delete(j);
   end;
   ExpTypeList[i] := PFunctions(FncList.Items[FncList.count-1])^.FType;
   ExpList[i] := EvalFunction;
//   if axp.dbm.gf.ErrorInActionExecution <> '' then break;
  end;
  if explist[i] = '' then begin
   explist.delete(i);
   exptypelist.delete(i);
  end;
  if i = 0 then break;
  dec(i);
 end;
 fprep := nil;
// if axp.dbm.gf.ErrorInActionExecution <> '' then raise exception.Create(axp.dbm.gf.ErrorInActionExecution)
end;

Function TEval.IfVariable(LastWord : String) : boolean;
var posn:integer;
begin
 result := false;
 posn := VarList.IndexOf(lowercase(LastWord));
 if Posn >= 0 then begin
  result := true;
  IfParams(ExpList[ExpIndex]);
  if varsused.IndexOf(lowercase(lastword)) = -1 then
    varsused.Add(lowercase(lastword));
  if calltype = 'p' then
    ExpList[ExpIndex] := '_v_'+IntToStr(Posn);
  ExpTypeList[ExpIndex] := VarTypeStr[posn+1];
  ExpressionType := VarTypeStr[posn+1];
 end;
 If (result) and (CallType = 'n') then
 begin
  If Trim(ValueList[Posn]) = '' then ExpList[ExpIndex] := '~e~' else
  ExpList[ExpIndex] := ValueList[posn];
//  axp.dbm.gf.DoDebug.msg('   ' + LastWord + ' = '+Valuelist[Posn]);
 End;
end;

Function TEval.GetVarValue(VarName:String) : String;
var posn:integer;
begin
 result := '';
 LastVarType := '';
 posn := VarList.IndexOf(lowercase(Varname));
 if Posn >= 0 then begin
  LastVarType := VarTypeStr[posn+1];
  Result := ValueList[posn];
 End;
end;


Function TEval.TrimSpace(S:String):String;
var i, l : integer;
    t: String;
begin
    result:='';
    l:=length(s);
    for i:=1 to l do begin
        if s[i]<>' ' then
           t:=t+s[i];
    end;
    result:=t;
end;

Function TEval.IfFunction(LastWord: String) : boolean;
var F, NF : pfunctions;
    i : integer;
begin
 result := false;
 LastWord := trim(LastWord);
 F := ValidFnc(LastWord);
 if F <> nil then begin
  result := true;
  ExpTypeList[ExpIndex] := F^.FType;
 end;
 if result then begin
  new(nf);
  nf^.fname := f^.fname;
  nf^.ftype := f^.ftype;
  nf^.FParamCount := 0;
  nf^.FParamIndex := 1;

  FncList.add(nf);
  Bracket := Bracket + 'F';
  ExpList[ExpIndex] := chr(1);
  ExpTypeList[ExpIndex] := 'v';
 end;
end;

function TEVAL.IfParams(ParamMaster: String): Boolean;
Var
  pv : String;
begin
  Result := False;
//  if not axp.dbm.gf.MobileWSFlag then
//  begin
//    Result := true;
//    Exit;
//  end;
//  if slParams.IndexOf(ParamMaster) > -1 then
//  begin
//    // Add the Master/Child dependency into Dict;      //ParamName
//    Result := True;
//    pv := '';
//    if Dict.ContainsKey(ParamMaster) then
//      pv := Dict.Items[ParamMaster];
//    if pv <> '' then
//    begin
//      if pos(ParamMaster,pv) > -1 then
//        exit;
//      pv := pv + ','+ ParamName;
//      Dict.Remove(ParamMaster);
//    end
//    else
//      pv := ParamName;
//    Dict.Add(ParamMaster, pv);
//  end;
end;

Function TEval.EvalFunction:String;
var S : String;
    f : PFunctions;
    i : integer;
begin
// if axp.dbm.gf.actionName = 'isave' then exit;
 if CallType = 'n' then begin
   f := FncList.Items[FncList.count-1];
//   axp.dbm.gf.DoDebug.msg('   Calling function ' + f^.fname);
   //CallFunction(f^.Fname, f^.Fparam, f^.FParamCount, S);
//   axp.dbm.gf.DoDebug.msg('   Result of '+f^.fname +' = '+s);
   if (f^.Fname = 'bulkexecute') and (s <> '') then
     {if axp.dbm.gf.isservice then} raise exception.Create(s);
   if (f^.Fname = 'savesqlresult') and (s <> '') then
     {if axp.dbm.gf.isservice then} raise exception.Create(s);
   Result := s;
   ExpressionType := f^.FType;
 end else if CallType = 'p' then begin
   f := FncList.Items[FncList.count-1];
   fprep^.num := prepnum;
   fprep^.FCall^.Fname := f^.Fname;
   fprep^.FCall^.FType := f^.ftype;
   for i:=1 to 20 do fprep^.fcall^.FParam[i] := f^.fparam[i];
   fprep^.FCall^.FParamCount := f^.FParamCount;
   fprep^.FCall^.FParamIndex := f^.FParamindex;
   fprep^.exprlist := nil;
   fprep^.ExprTypeList := nil;
   fprep^.OrgList := nil;
   fprep^.TypeString := '';
   fPrep^.pIndex := -1;
   preplist.add(fprep);
   result := '_xcall'+inttostr(preplist.count-1);
 end;
 FncList.delete(FncList.count-1);
end;

procedure TEval.CopyParam(S : String);
var f : PFunctions;
begin
 f := FncList[FncList.count-1];
 f^.FParam[f^.FParamIndex] := S;
 if CallType = 'p' then begin
   prep^.pindex := f^.fParamIndex;
   prep^.FCall := fprep^.FCall;
 end;
 Inc(f^.FParamIndex);
end;

procedure TEVAL.CopyToTable(CTableNames: String; CallRow: Integer);
begin

end;

Function TEval.ValidFnc(s : String) : pfunctions;
var i:integer;
    f:pfunctions;
begin
 result := nil;
 s:=lowercase(s);
 for i:=0 to validfnclist.count-1 do
 begin
  f := validfnclist.Items[i];
  if f^.fname = s then
  begin
   result := f;
   exit
  end;
 end;
end;

procedure TEVal.SetVarValue(posn:integer; VarType:Char; pvalue : String);
begin
  if posn >= 0 then begin
    if Ord(vartype) < 97 then vartype := Char((ord(vartype)+32));
    if (vartype = 'n') and (pvalue='') then begin
      pvalue := '0';
      zerovalue[posn+1] := 'F';
    end;
    if vartype = 'n' then pvalue := GetNumber({axp.dbm.gf.RemoveCommas}(pValue));
    valuelist[posn] := pvalue;
  end;
end;

//procedure TEVAL.SQLGETValue(SQLName, FieldName: String; var ResultStr: String);
//begin
//
//end;

procedure TEVAL.SQLRegVar(SQLText, Direct: String);
begin

end;

function TEval.RegisterVar(VarName: String; VarType: Char; pValue : String) : integer;
var
  posn : integer;
  v :  Variant;
  vtype,zval : String;
begin
 if Ord(vartype) < 97 then vartype := Char((ord(vartype)+32));
 vtype := Vartype;
 zval := 'T';
 if (vtype = 'n') and (pvalue='') then begin
   pvalue := '0';
   zval := 'F';
 end;
 if varname = '' then exit;
 if vtype = 'n' then pvalue := GetNumber({axp.dbm.gf.RemoveCommas}(pValue));
 posn := VarList.IndexOf(lowercase(VarName));
 result := posn;
 if posn < 0 then begin
  VarList.add(lowercase(VarName));
  VarTypeStr := VarTypeStr + VarType;
  ValueList.add(pvalue);
  zerovalue := zerovalue + zval;
  result := valuelist.count-1;
 end
 else begin
  ValueList[posn] := pvalue;
  zerovalue[posn+1] := zval[1];
 end;
end;

procedure TEval.RegisterFnc(FncName: String; FncType: Char);
var f : pfunctions;
begin
 New(f);
 f^.Fname := lowercase(FncName);
 f^.FType := FncType;
 ValidFncList.add(f);
end;

//Procedure TEval.CallFunction(FncName : String; P : TParamArray; ParamCount: integer; var S:String);
//var V : Boolean;
//    d,m,y : word;
//    dt : TDateTime;
//    k,i :integer;
//    ResultStr :String;
////    foundval : boolean;
//begin
// for i := 1 to 20 do begin
//   if P[i]='~e~' then p[i] := '';
// end;
// {
// foundval := false;
// for i := 1 to 20 do begin
//   if P[i]<>'' then
//   begin
//     foundval := true;
//     break;
//   end;
// end;
// if not foundval then exit;
// }
// FncName := LowerCase(FncName);
// if fncname = 'abs' then  s := PAbs(p[1])
// else If fncname = 'isempty' then  s := IsEmpty(p[1])
// else if fncname = 'isemptyvalue' then s := IsEmptyValue(p[1],p[2])
// else If FncName = 'upper' then      s := Upper(P[1])
// else If FncName = 'lower' then      s := Lower(P[1])
// else If FncName = 'dtoc' then       s := DTOC(StrToDateTime(P[1]))
// else If FncName = 'cmonthyear' then s := CMonthYear(StrToDateTime(P[1]))
// else If FncName = 'ctod' then       s := DateToStr(CTOD(P[1]))
// else if FncName = 'makedate' then begin
//  d := StrToInt(P[1]);
//  m := StrToInt(P[2]);
//  y := StrToInt(P[3]);
//  try
//   S := DateToStr(EncodeDate(y, m, d));
//  except on e:Exception do
//    begin
//      //if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\CallFunction - '+e.Message);
//      S := '';
//    end;
//  end;
// end else If FncName = 'rnd' then s := FloatToStr(Rnd(StrToFloat(P[1]),StrToInt(P[2])))
// else If FncName = 'stuff' then      s := Stuff(P[1],P[2],StrToInt(P[3]))
// else If FncName = 'round' then      s := FloatToStr(Round(StrToFloat(P[1]), StrToInt(P[2])))
// else If FncName = 'iif' then
// begin
//		If P[1] = '0' then
//			 V := False
//		Else
//			 V := True;
//		S := VarToStr(IIF(V,P[2],P[3]));
// end else If FncName = 'amtword' then    s := AmtWord(StrToFloat(P[1]))
// else If FncName = 'curramtword'  then begin
//   s := lowercase(p[4]);
//   v := s[1] = 't';
//   s := CurrAmtWord(StrToFloat(P[1]),p[2],p[3],V,strToInt(p[5]));
// end else If FncName = 'val' then begin
//   if p[1] = '' then s := '0' else S := P[1];
//   s := {axp.dbm.gf.removecommas}(s);
//   if s[1]='(' then begin
//     s := copy(s, 2, length(s)-2);
//     try
//     s := floattostr(0-strtofloat(s))
//     except on e:Exception do
//      begin
//        //if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\CallFunction - '+e.Message);
//        s:='0';
//      end;
//     end;
//   end else begin
//   try
//     s:=floattostr(strtofloat(s));
//   except on e:Exception do
//    begin
//      //if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\CallFunction - '+e.Message);
//      s:='0';
//    end;
//   end;
//   end;
//   k := pos(' ', s);
//   if k > 0 then
//     s := copy(s, 1, k-1);
// end else  If FncName = 'str' then        S := Str(StrToFloat(P[1]))
// else if FncName = 'substr' then     S := Substr(P[1],StrToInt(P[2]),StrToInt(P[3]))
// else if FncName = 'date' then       S := ''//DateToStr(AxP.dbm.GetServerDateTime)
// else if FncName = 'time' then       S := TimeToStr(Time)
// else if FncName = 'dayofdate' then begin
//	DecodeDate(StrToDateTime(p[1]),y,m,d);
//	s := IntToStr(d);
// end else if FncName = 'monthofdate' then begin
//	DecodeDate(StrToDateTime(p[1]),y,m,d);
//	s := IntToStr(m);
// end else if FncName = 'yearofdate' then begin
//	DecodeDate(StrToDateTime(p[1]),y,m,d);
//	s := IntToStr(y);
// end else if FncName = 'addtodate' then begin
//    try
//     dt := StrToDate(P[1]);
//		 S := DateToStr( AddToDate( Dt,StrToInt(P[2]) ) );
//    except on e:Exception do
//      begin
//        //if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\CallFunction - '+e.Message);
//        //S := formatDateTime(axp.dbm.gf.ShortDateFormat.ShortDateFormat,StrToDate('01/01/1990'));
//      end;
//    end;
// end else If FncName = 'mandy' then       s := MandY(StrToDateTime(P[1]))
// else if FncName = 'dayselapsed' then S := FloatToStr(DaysElapsed(P[1], P[2]))
// else if FncName = 'timeelapsed' then S := FloatToStr(TimeElapsed(P[1], P[2]))
// else if FncName = 'addtotime' then S := AddToTime(P[1], strtofloat(P[2]))
// else if FncName = 'formatdatetime' then S := FormatDateTime(P[1], StrToDateTime(P[2]))
// else if FncName = 'addtomonth' then S := DateTimeToStr(AddToMonth(StrToDateTime(P[1]),StrToInt(P[2])))
// else if FncName = 'lastdayofmonth' then S := DateTimeToStr(LastDayOfMonth(StrToDateTime(P[1])))
// else if FncName = 'validencodedate' then S := DateTimeToStr(ValidEncodeDate(StrToInt(P[1]), StrToInt(P[2]), StrToInt(P[3])))
// else if FncName = 'eval' then S := Eval(P[1])
// else if FncName = 'trim' then S := Trim(P[1])
// else if FncName = 'power' then S := EvaluatePower(StrToCurr(P[1]), StrToCurr(P[2]))
// else if FncName = 'regvar' then RegisterVar(P[1],P[2][1],P[3])
// else if FncName = 'isvarempty' then s := IsVarEmpty(p[1])
// else if FncName='findrecord' then begin
//    if Assigned(OnFindRecord) then
//        OnFindRecord(p[1],p[2],p[3],Resultstr)
//    else
//      FindRecord(p[1], p[2], p[3], ResultStr);
//     s:=resultstr;
// end else if FncName = 'firesql' then begin
//    if assigned(OnFireSQL) then
//       OnFireSQL(p[1],p[2])
//    else FireSQL(p[1], p[2]);
//    S := '';
// end else if FncName='sqlget' then begin
//    Resultstr := '';
//    if assigned(OnSQLGet) then
//     OnSQLGet(p[1],p[2],ResultStr)
//    else SQLGetValue(p[1],p[2],ResultStr);
//    S := ResultStr;
// end else if fncname = 'getlength' then begin
//    s := inttostr(getlength(p[1]));
// end else if fncname = 'extractnum' then begin
//    s := extractnum(p[1]);
// end else if FncName = 'getdelimitedstr' then begin
//    s := getdelimitedstr(p[1], P[2], p[3]);
// end else if fncname = 'findandreplace' then begin
//   s := findandreplace(p[1],p[2],p[3])
// end else if fncname = 'trimspace' then begin
//   s := trimspace(p[1]);
// end else if fncname = 'domrp' then begin
//   domrp(p[1],p[2]);
// end else if fncname = 'mod' then begin
//   s := inttostr(mods(strtoint(p[1]),strtoint(p[2])));
// end else if fncname = 'verifytree' then begin
//   verifytree(p[1]);
// end else if fncname = 'buildtreelink' then begin
////   buildtreelink(p[1]);
// end else if fncname='convertmd5' then begin
//   s:=convertmd5(p[1]);
// end else if fncname = 'bulkexecute' then begin
//   s := bulkexecute(p[1]);
//   if s <> '' then
//   begin
//     //if axp.dbm.gf.isservice then raise exception.Create(s)
//     //else showmessage(s);
//   end;
// end else if fncname = 'constructtable' then begin
//   constructtable(p[1],p[2]);
// end else if fncname = 'posttotable' then begin
//   PostToTable(p[1], p[2], p[3]);
// end else if fncname = 'settoredis' then begin
//   if P[4] <> '' then
//      SetToRedis(p[1], p[2], p[3] , p[4] , strtoint(p[5]))
//   else SetToRedis(p[1], p[2], p[3])
// end else if fncname = 'getfromredis' then begin
//   if P[3] <> '' then
//   s := GetFromRedis(p[1], p[2] , p[3])
//   else s := GetFromRedis(p[1], p[2])
// end else if fncname = 'savesqlresult' then begin
//   s := savesqlresult(p[1], p[2], p[3]);
//   if s <> '' then
//   begin
////    if isservice then raise exception.Create(s)
////    else showmessage(s);
//      raise exception.Create(s);
//   end;
// end else if fncname = 'setdeps' then begin
//   SetDeps(p[1]);
// end else if FncName = 'dostoredproc' then begin
//     s := doStoredProc(p[1],p[2],p[3]);
//// end else if FncName = 'sqlpost' then begin
////    if assigned(OnSQLPost) then
////      s := OnSQLPost(p[1],p[2],p[3],p[4],p[5]);
//// end else if FncName = 'nowstring' then begin
////    s := axp.dbm.gf.nowstring;
//// end else if FncName = 'exportsql' then begin
////    if assigned(OnExportSQL) then
////       OnExportSQL(p[1],p[2],p[3],p[4],p[5])
////    else ExportSQL(p[1], p[2],p[3],p[4],p[5]);
////    S := '';
// end else if fncname='encryptstr' then begin
//   s:= EncryptStr(p[1]);
// end else if fncname='decryptstr' then begin
//   s:= DecryptStr(p[1]);
// end else if fncname='clonedir' then begin
//   CloneDir(p[1],p[2]);
// end else if fncname='clonefile' then begin
//   CloneFile(p[1],p[2],p[3]);
// end else if fncname='createfile' then begin
//   CreateFile(p[1],p[2],p[3]);
// end else if fncname='removefile' then begin
//   RemoveFile(p[1]);
// end else if fncname='xcopydir' then begin
//   XCopyDir(p[1],p[2]);
// end else if fncname='xcopyfile' then begin
//   XCopyFile(p[1],p[2],p[3]);
// end else if fncname='deletedir' then begin
//   DeleteDir(p[1]);
//// end else if FncName = 'postfromiview' then begin
////    if assigned(OnPostFromIview) then
////      s := OnPostFromIview(p[1],p[2],p[3],p[4]);
// end else If FncName = 'axpceil' then s := IntToStr(Ceil(StrToFloat(P[1])))
// else If FncName = 'axpfloor' then s := IntToStr(Floor(StrToFloat(P[1])))
// else If FncName = 'days360' then begin
//   s := IntToStr(Days360(StrToDate(P[1]),StrToDate(P[2]),P[3]))
// end else If FncName = 'networkdays' then begin
//   s := IntToStr(NetWorkDays(StrToDate(P[1]),StrToDate(P[2]),StrToInt(P[3]),P[4]));
// end else if FncName = 'downloadattachment' then begin
////    if assigned(OnDownLoadAttachment) then
////        OnDownLoadAttachment(p[1],p[2],p[3],p[4]);
//    s := '';
// end else If FncName = 'sqlregvar' then begin
//   SqlRegVar(P[1],P[2]);
//// end else if fncname='createtstruct' then
//// begin
//////  if Assigned(OnCreateTStruct) then
//////    s := OnCreateTStruct(p[1]);
////
//// end else if FncName = 'opentstruct' then begin
//////    if assigned(OnOpenTstruct) then
//////      s := OnOpenTstruct(p[1],p[2],p[3],p[4]);
//// end else if FncName = 'openiview' then begin
//////    if assigned(OnOpenIview) then
//////      s := OnOpenIview(p[1],p[2],p[3],p[4]);
//// end else if FncName = 'save' then begin
////    if assigned(OnSave) then
////      s := OnSave(p[1]);
//// end else if FncName = 'pdf' then begin
////    if assigned(OnPdf) then
////      s := OnPdf(p[1],p[2],p[3],p[4],p[5],p[6],p[7]);
//// end else if FncName = 'showmessage' then begin
////    if assigned(OnShowMessage) then
////      s := OnShowMessage(p[1],p[2]);
//// end else if FncName = 'printform' then begin
////    if assigned(OnPrintForm) then
////      s := OnPrintForm(p[1],p[2]);
//// end else if FncName = 'previewform' then begin
////    if assigned(OnPreviewForm) then
////      s := OnPreviewForm(p[1],p[2],p[3],p[4]);
//// end else if FncName = 'canceltransaction' then begin
////    if assigned(OnCancelTransaction) then
////      s := OnCancelTransaction(p[1],p[2],p[3]);
//// end else if FncName = 'deletetransaction' then begin
////    if assigned(OnDeleteTransaction) then
////      s := OnDeleteTransaction(p[1],p[2]);
//// end else if FncName = 'loadtransaction' then begin
////    if assigned(OnLoadTransaction) then
////      s := OnLoadTransaction(p[1],p[2],p[3],p[4],p[5]);
//// end else if FncName = 'viewattachment' then begin
////    if assigned(OnViewAttachment) then
////      s := OnViewAttachment(p[1]);
//// end else if FncName = 'importintogrid' then begin
////    if assigned(OnImportIntoGrid) then
////      s := OnImportIntoGrid(p[1],p[2],p[3],p[4]);
//// end else if FncName = 'csvimporting' then begin
////    if assigned(OnCSVImporting) then
////      s := OnCSVImporting(p[1],p[2],p[3],p[4],p[5],p[6]);
//// end else if FncName = 'post' then begin
////    if assigned(OnPost) then
////      s := OnPost(p[1],p[2],p[3]);
////
//// end else if fncname='deletestructure' then
//// begin
////  if Assigned(OnDeleteTStructure) then
////    s := OnDeleteTStructure(p[1]);
//// end else if fncname='deletestructurewithdc' then
//// begin
////  if Assigned(OnDeleteStructureWithDC) then
////    s := OnDeleteStructureWithDC(p[1]);
// end else if fncname='getcsvheader' then
//   s:= GetCsvHeader(p[1])
// else if fncname='convertexceltocsvfile' then
//   ConvertExcelToCSVFile(p[1],p[2],p[3],p[4])
// else if fncname='convertfile' then
//   ConvertFile(p[1],p[2],p[3])
// else if fncname = 'copyfilefromtabletofolder' then begin
////   if assigned(OnCopyFileFromTableToFolder) then OnCopyFileFromTableToFolder(p[1],p[2]);
// end
// //OnReadTStructDef /  OnWriteTStructDef / OnDeleteTStructDef called based on fncname var value.
//// else if fncname='readtstructdef' then
//// begin
////  if Assigned(OnReadTStructDef) then
////    s := OnReadTStructDef(p[1]);
//// end
//// else if fncname='writetstructdef' then
//// begin
////  if Assigned(OnWriteTStructDef) then
////    s := OnWriteTStructDef(p[1],p[2]);
//// end
//// else if fncname='deletetstructdef' then
//// begin
////  if Assigned(OnDeleteTStructDef) then
////    s := OnDeleteTStructDef(p[1],False);//When calling from Axpert function isAppSchema will be set to false.
//// end
//// else if fncname='readiviewdef' then //Call OnReadIviewDef function
//// begin
////  if Assigned(OnReadIviewDef) then
////    s := OnReadIviewDef(p[1]);
//// end
//// else if fncname='deleteiviewdef' then //Call deleteiviewdef function
//// begin
////  if Assigned(OnDeleteIviewDef) then
////    s := OnDeleteIviewDef(p[1],False);//When calling from Axpert function isAppSchema will be set to false.
//// end
//// else if fncname='readaxglodef' then //Call OnReadAxGloDef function
//// begin
////  if Assigned(OnReadAxGloDef) then
////    s := OnReadAxGloDef();
//// end
//// else if fncname='dosaveasstructure' then
//// begin
////  if Assigned(OnDoSaveAsStructure) then
////    s := OnDoSaveAsStructure(p[1],p[2],p[3],p[4]);
//// end else if FncName = 'notify' then begin
////    if assigned(OnNotify) then
////      s := OnNotify(p[1],p[2],p[3],p[4]);
//// end else if FncName = 'axmemload' then begin
////      s := AxMemLoad(p[1],p[2]);
//// end
// else if FncName = 'stringpos' then begin
//      s := StringPOS(p[1],p[2],p[3]);
// end else if FncName = 'getaxvalue' then begin
//      s := GetAxValue(p[1],p[2],p[3]);
// end;
//
//end;

Function TEval.PAbs(s:String):String;
var x : extended;
begin
  x := StrToFloat(trim(s));
  x := abs(x);
  Result := FloatToStr(x);
end;

procedure TEVAL.PostToTable(TableName, SearchFields, NoAppendStr: String);
begin

end;

Function TEval.EvaluatePower(ConstVal:Extended;Exponent:Extended):String;
Begin
  Result:='0';
  Try
    Result:=CurrToStr(Power(ConstVal,Exponent));
  Except on e:Exception do
    //if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\EvaluatePower - '+e.Message);
  End;
End;

function TEval.EvaluateExpression(ExprList,ExprTypeList: TStringList): String;
begin
	NewExprTypeList.clear;
        ConvertToPostFix(ExprList, ExprTypeList);
	result := EvaluatePostFix(cpf,NewExprTypeList);
end;

function TEval.ConvertToPostFix(ExprList,ExprTypeList: TStringList): TStringList;
var i: integer;
    currElement,TopOfStkList,CurrType,TopOfStkTypeList: String;
begin
  result := cpf;
  cpf.clear;
  StkList.clear;
  StkTypeList.clear;
  NewExprTypeList.clear;
  ExprList.add(')');
  ExprTypeList.add('v');
  StkList.add('(');
  StkTypeList.add('v');
  for i:=0 to ExprList.count - 1 do
  begin
    if StkList.count < 1 then
    begin
      //if axp.dbm.gf.isservice then
         Raise Exception.Create('Invalid Expression')
      //else
        // showmessage('Invalid Expression');
//      exit;
    end;
    CurrElement := ExprList.Strings[i];
    CurrType := ExprTypeList[i];
    TopOfStkList := StkList.Strings[StkList.count-1];
    TopOfStkTypeList := StkTypeList[StkTypeList.count-1];
    while (InputPrecedence(CurrElement) < StackPrecedence(TopOfStkList)) do
    begin
      StkList.Delete(StkList.count-1);
      StkTypeList.Delete(StkTypeList.count-1);
      cpf.add(TopOfStkList);
      NewExprTypeList.add(TopOfStkTypeList);
    	TopOfStkList := StkList.Strings[StkList.count-1];
    end;
    if (InputPrecedence(CurrElement) <> StackPrecedence(TopOfStkList)) then begin
      StkList.add(CurrElement);
      StkTypeList.Add(CurrType);
    end else begin
      StkList.delete(StkList.count-1);
      StkTypeList.delete(StkTypeList.count-1);
    end;
  end;
end;

procedure TEVAL.InitCopyToTable(CTableNames: String);
begin

end;

function TEval.InputPrecedence(StkVariable: String): integer;
begin
  if StkVariable = ')' then  Result := 0
  else if (StkVariable = '|') then Result := 1
  else if (StkVariable = '&') then Result := 3
  else if (StkVariable = '+') or (StkVariable = '-') then Result := 5
  else if (StkVariable = '*') or (StkVariable = '/') then Result := 7
  else if (StkVariable = '^') or (StkVariable = '>') or (StkVariable = '=') or (StkVariable = '<') or (StkVariable = '#') or (StkVariable = '$')then Result := 10
  else if (StkVariable = '(') then Result := 13
  else Result := 11;     // for variables
end;

function TEval.StackPrecedence(StkVariable: String): integer;
begin
  if (StkVariable = '(') then Result := 0
  else if (StkVariable = '|') then Result := 2
  else if (StkVariable = '&') then Result := 4
  else if (StkVariable = '+') or (StkVariable = '-') then Result := 6
  else if (StkVariable = '*') or (StkVariable = '/') then Result := 8
  else if (StkVariable = '^') or (StkVariable = '>') or (StkVariable = '=') or (StkVariable = '<') or (StkVariable = '#') or (StkVariable = '$') then Result := 9
  else Result := 12;  		// for variables
end;

function TEval.EvaluatePostFix(ExprList,ExprTypeList: TStringList): String;
var
 	i,p: integer;
  Value1,Value2, Exptype, s: String;
begin
  if CallType = 'p' then begin
    new(prep);
    prep^.ExprList := TStringList.create;
    prep^.ExprTypeList := TStringList.create;
    prep^.OrgList := TStringList.create;
    prep^.TypeString := '';
    prep^.num := prepnum;
    prep^.FCall := nil;
    Prep^.ExprList.Assign(ExprList);
    Prep^.ExprTypeList.assign(exprtypelist);
    for i:=0 to prep^.exprlist.count-1 do begin
      s := prep^.exprlist[i];
      if copy(s,1,3)='_c_' then begin
        Prep^.ExprList[i] := copy(s,4,length(s));
        Prep^.TypeString := Prep^.TypeString + 'c';
      end else if copy(s,1,3)='_v_' then begin
        Prep^.ExprList[i] := copy(s,4,length(s));
        Prep^.TypeString := Prep^.TypeString + 'v';
      end else begin
        if (length(s)=1) and (s[1] in operators) then
          Prep^.TypeString := Prep^.TypeString + 'o'
        else
          Prep^.TypeString := Prep^.TypeString + 'u';
      end;
    end;
    Prep^.OrgList.Assign(prep^.ExprList);
    Prep^.pIndex := -1;
    PrepList.Add(prep);
    Result := '';
    exit;
  end;
  s := '';
  StkList.Clear;
  ExpType := 's';
  for i:=0 to ExprList.count-1 do
  begin
    if (IsOperator(ExprList.Strings[i])) then
    begin
      if (StkList.count < 2) then
      begin
       value2 := ''
      end else begin
       Value2 := StkList.Strings[StkList.count-1];  						  // Pop out the
       StkList.delete(StkList.count-1);             						  // first value
      end;
      Value1 := StkList.Strings[StkList.count-1];	 					    // pop out the
      StkList.delete(StkList.count-1); 						              // second value
      StkList.add(Compute(Value1,Value2,ExprList.Strings[i],ExpType));
    end
    else begin			// if it is a constant.
      StkList.add(ExprList.Strings[i]);
      if ExprTypeList[i] <> 'v' then exptype := ExprTypeList[i];
    end;
  end;
  if (StkList.count = 1) then
    Result := StkList.Strings[0]
  else
    Result := '';
end;

function TEval.IsOperator(Variable: String): boolean;
begin
  if ((Variable = '+') or (Variable = '-') or (Variable = '*') or (Variable = '/') or (variable='<') or (variable='>')or (variable='=')or (variable='#') or (variable='&') or (variable='|') or (variable='$')) then
    Result := true
  else
    Result := false;
end;

function TEval.Compute(Value1,Value2,Operator_,Expressiontype: String):String;
begin
  Self.ExpressionType := ExpressionType[1];
  If lowercase(trim(expressiontype)) = 's' then expressiontype := 'c';
  if value1 = '~e~' then value1 := '';
  if value2 = '~e~' then value2 := '';
  if lowercase(expressiontype) = 'n' then begin
    If (lowercase(Trim(Value1)) = 'null') or (trim(value1)='') then value1 := '0';
    If (lowercase(Trim(Value2)) = 'null') or (trim(value2)='') then value2 := '0';
   if Operator_ = '+' then result := floattostr(val(Value1) + val(Value2))
   else if Operator_ = '-' then result :=  floattostr((val(Value1) - val(Value2)))  // floattostr((strtofloat(trim(Value1)) - strtofloat(trim(Value2))))
   else if Operator_ = '*' then
     result := floattostr(val(Value1) * val(Value2))  //;floattostr(val(Value1) * val(Value2))
   else if Operator_  = '/' then
   begin
      if strtofloat(value2) = 0 then
         result := '0'
      else begin
         result :=  floattostr(val(Value1) / val(Value2))  ;
//         result := Floattostr(val(Value1) / val(Value2));
      end;
   end
   else if Operator_  = '>' then if val(value1) > val(value2) then result := '1' else result :='0'
   else if Operator_  = '<' then if val(value1) < val(value2) then result := '1' else result :='0'
   else if Operator_  = '=' then if val(value1) = val(value2) then result := '1' else result :='0'
   else if Operator_  = '#' then if val(value1) = val(value2) then result := '0' else result :='1'
   else if Operator_  = '&' then if (value1 = '1') and (value2 = '1') then result := '1' else result := '0'
   else if Operator_  = '|' then if (value1 = '1') or (value2 = '1') then result := '1' else result := '0';
  end;
  if expressiontype = 'c' then begin
    If lowercase(Trim(Value1)) = 'null' then value1 := '';
    If lowercase(Trim(Value2)) = 'null' then value2 := '' ;
   if Operator_  = '+' then result := Value1 + Value2
   else if Operator_  = '=' then if value1 = value2 then result := '1' else result :='0'
   else if Operator_  = '#' then if value1 = value2 then result := '0' else result :='1'
   else if Operator_  = '&' then if (value1 = '1') and (value2 = '1') then result := '1' else result := '0'
   else if Operator_  = '>' then if (value1 > value2) then result := '1' else result := '0'
   else if Operator_  = '<' then if (value1 < value2) then result := '1' else result := '0'
   else if Operator_  = '$' then
    if (pos(value1,value2) <> 0) then result := '1' else result := '0'
   else if Operator_  = '|' then if (value1 = '1') or (value2 = '1') then result := '1' else result := '0';
  end;
  if expressiontype = 'd' then begin
   //sab 17-sep-02 added checking for '' & '  /  /    '
   //If (lowercase(Trim(Value1)) = 'null') or (trim(value1)='') or (Trim(value1) = axp.dbm.gf.ShortDateFormat.DateSeparator + '  ' + axp.dbm.gf.ShortDateFormat.DateSeparator) then
   //   value1 := axp.dbm.gf.DummyDate;
   //If (lowercase(Trim(Value2)) = 'null') or (trim(value2)='') or (Trim(value2) = axp.dbm.gf.ShortDateFormat.DateSeparator + '  ' + axp.dbm.gf.ShortDateFormat.DateSeparator) then
   //   value2 := axp.dbm.gf.DummyDate;
   if Operator_  = '+' then result := FloatToStr(StrToDate(Value1)+StrToDate(value2))
   else if Operator_  = '-' then result := FloatToStr(StrToDate(Value1)-StrToDate(Value2))
   else if Operator_  = '>' then if strtodate(value1) > strtodate(value2) then result := '1' else result :='0'
   else if Operator_  = '<' then if strtodate(value1) < strtodate(value2) then result := '1' else result :='0'
   else if Operator_  = '=' then if value1 = value2 then result := '1' else result :='0'
   else if Operator_  = '#' then if value1 = value2 then result := '0' else result :='1'
   else if Operator_  = '&' then if (value1 = '1') and (value2 = '1') then result := '1' else result := '0'
   else if Operator_  = '|' then if (value1 = '1') or (value2 = '1') then result := '1' else result := '0';
  end;
  if expressiontype = 't' then begin
    If lowercase(Trim(Value1)) = 'null' then value1 := '';
    If lowercase(Trim(Value2)) = 'null' then value2 := '' ;
   if Operator_  = '+' then result := Value1 + Value2
   else if Operator_  = '=' then if value1 = value2 then result := '1' else result :='0'
   else if Operator_  = '#' then if value1 = value2 then result := '0' else result :='1'
   else if Operator_  = '$' then
    if (pos(value1,value2) <> 0) then result := '1' else result := '0'
   else if Operator_  = '|' then if (value1 = '1') or (value2 = '1') then result := '1' else result := '0';
  end;

end;

procedure TEVal.StartString;
begin
 inc(Strcount);
 DeLimiters := [];
 Operators := [];
end;

function TEVAL.EncryptStr(pValue: String): String;
begin

end;

procedure TEVal.EndString;
begin
 if strCount=0 then raise EParserError.Create('Invalid expression');
 dec(strcount);
 if strcount=0 then begin
   DeLimiters := [' ','(',')',','];
   Operators := ['+','-','*','/','>','<','=','#','&','|','$'];
 end;
end;

Function TEval.Amt_Word(Str_Num : String) : String;
var
    eflg: boolean;
    k: real;
    AddS : String;
    aval,k1,inc1,st_poin: integer;
    temp,var1,nam,first : String;
    number : array [1..19] of String;
    tens : array [1..9] of String;
    hun_mul : array [1..9] of String;
begin
    number[1]:='One ';
    number[2]:='Two ';
    number[3]:='Three ';
    number[4]:='Four ';
    number[5]:='Five ';
    number[6]:='Six ';
    number[7]:='Seven ';
    number[8]:='Eight ';
    number[9]:='Nine ';
    number[10]:='Ten ';
    number[11]:='Eleven ';
    number[12]:='Twelve ';
    number[13]:='Thirteen ';
    number[14]:='Fourteen ';
    number[15]:='Fifteen ';
    number[16]:='Sixteen ';
    number[17]:='Seventeen ';
    number[18]:='Eighteen ';
    number[19]:='Nineteen ';
    tens[1]:='Ten ';
    tens[2]:='Twenty ';
    tens[3]:='Thirty ';
    tens[4]:='Forty ';
    tens[5]:='Fifty ';
    tens[6]:='Sixty ';
    tens[7]:='Seventy ';
    tens[8]:='Eighty ';
    tens[9]:='Ninety ';
    hun_mul[1]:='';
    hun_mul[2]:='';
    hun_mul[3]:='Hundred ';
    hun_mul[4]:='Thousand ';
    hun_mul[5]:='Thousand ';
    hun_mul[6]:='Lakh';
    hun_mul[7]:='Lakh';
    hun_mul[8]:='Crore';
    hun_mul[9]:='Crore';

    k:=length(str_num)/2.0;
    aval:=0;
    k1:=trunc(k);
    eflg:=true;
    if (k<>k1) then
       inc1:=2
    else
       inc1:=1;
    st_poin:=1;
    while (eflg) do
    begin
       if ((length(str_num)- st_poin +1)=3) or (length(str_num)<2) then
      	 inc1:=1
       else if (length(str_num)=2) then inc1:=2;
       var1:=copy(str_num,st_poin,inc1);
       nam:='';
       if (strtoint(var1)<20) and (strToInt(var1)<>0) then begin
          nam:=number[strToInt(var1)];
          if strToint(var1)=1 then  Adds:=' ' else adds:='s ';
       end
       else if (strtoint(var1)<>0) then
       begin
          if strToint(var1)>19 then  Adds:='s ' else adds:=' ';  // nagu changed for lakhs or lakh
          first:=copy(var1,1,1);
          nam:=tens[strToint(first)];
          first:=copy(var1,2,1);

          if (strtoint(first)<>0) then begin
             nam:=nam+number[strToint(first)];
          end;
       end;
       if not (nam='') then begin
          if (aval=3) then begin
            //if not (axp.dbm.gf.millions) then
               temp:=temp+' and ';
          end;
            aval:=length(str_num)-st_poin+1;
//nagu
            nam:=nam+hun_mul[length(str_num)-st_poin+1];
            if length(str_num)-st_poin+1>5 then  nam:=nam+adds;
            temp:=temp+nam;
          end;
          if (st_poin+inc1-1=length(str_num)) then eflg:=false;
             st_poin:=st_poin+inc1;
             inc1:=2;
          end;
          result:=temp;
end;


Function TEval.Upper(Str : String) : String;
begin
		Result := UpperCase(Str);
end;

Function TEval.Lower(Str : String) : String;
begin
		Result := LowerCase(Str);
end;

Function TEval.DTOC(PDate : TDateTime) : String;
begin
	 Try
			Result := DateToStr(PDate);
	 Except on e:Exception do
    begin
			//if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\DTOC - '+e.Message);
      Result := '';
    end;
	 End;
end;

Function TEval.MandY(PDateTime : TDateTime) : String;
begin
	 Try
			Result := FormatDateTime('mmm yyyy',PDateTime);
	 Except on e:Exception do
    begin
			//if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\MandY - '+e.Message);
			Result := '';
    end;
	 End;
end;

Function TEval.CTOD(PDate : String) : TDateTime;
begin
	 Try
			Result := StrToDate(Trim(PDate));
	 Except on e:Exception do
    begin
		 //	if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\CTOD - '+e.Message);
			Result := Now;
    end;
	 End;
end;

Function TEval.Rnd(Frm : Extended; RV : Integer) : Extended;
var
	x: integer;
	m,d,nval,amt,h,rval: extended;
begin
	nval:=frm;
	x:=rv;
	m:=int(nval*100.0);
	h:=int(x/2.0);
	d:=m-x*int(m/x);
	amt:=iif(d>=h,(m+x-d),(m-d));
	rval:=amt/100.0;
	result :=rval;
end;

Function TEval.Stuff(Str1,Str2 : String; P : Integer) : String;
var
	 tempstr: String;
	 i,lenstr1: integer;
begin
//   axp.dbm.gf.Dodebug.Msg('   Executing Stuff()');
//   axp.dbm.gf.Dodebug.Msg('   Parameters :');
//   axp.dbm.gf.Dodebug.Msg('   Param 1 - '+str1);
//   axp.dbm.gf.Dodebug.Msg('   Param 2 - '+str2);
	 lenstr1:=length(str1);
	 if (p<=lenstr1) and not(str2='') then
			begin
				tempstr:=copy(str1,1,p-1);
				for i:=1 to length(str2) do
					begin
						tempstr:=tempstr+copy(str2,i,1);
	 //					inc(p);
					end;
				tempstr:=tempstr+copy(str1,p,lenstr1-p+1);
	 end;// else axp.dbm.gf.dodebug.Msg('   Position is out of focus or Param 2 is empty.');
	 result:=tempstr;
end;

function TEVAL.Round(num:extended;d:integer):extended;
var
	 f1,f2,d1,d2,fact,diff : real;
	 str_num: String;
	 l,w,p: integer;
begin
   //result := axp.dbm.gf.RealRound(num,d)
   {
   str_num :=  Trim(FormatFloat('0.######################',num))  ;
	 l:=length(str_num);
	 p:=pos(axp.dbm.gf.LocDecimalSeparator,str_num);
	 if (p>0 ) then
			str_num:=copy(str_num,p+1,l-p);
	 w:=length(str_num);
	 if (num=0) then
			begin
        result:= StrToFloat('0'+axp.dbm.gf.LocDecimalSeparator+'0');    //        result:=0.0;
        exit;
      end;
    if d > w then begin
     Result := num;
     exit;
    end;
    f1:=power(10,w);
    f2:=power(10,w-d);
    num:=num*f1;
    d1:= num/f2;
    d1 := int(d1);
//    d1:= int(num/f2);
    fact:= num-(d1*f2);
    if (fact>= f2/2) then
       begin
         diff:=f2-fact ;
         num:=num+diff;
       end
    else
        num:=num-fact;
   result:= num/f1;
   }
end;

Function TEval.IIF(BoolExpression : Boolean; True_Res, False_Res : Variant) : Variant;
begin
		try
			if Boolexpression then
				 result:=True_res
			else
				 result:=False_res;
		except on e:Exception do
      begin
        //if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\IIF - '+e.Message);
        //beep;
        //if axp.dbm.gf.isservice then
           Raise Exception.Create('Invalid boolean expression')
        //else
          // showmessage('Invalid boolean expression');
      end;
		end;
end;

Function TEval.AmtWord(Act_Num : Extended) : String;
var
 p: Integer;
 temp,temp1,name,rupees,paise: String;

begin
	name:='';
	temp1:='';
	temp:='';
	temp := trim(Format('%16.2f', [act_num]));
	//p:= pos(axp.dbm.gf.LocDecimalSeparator,trim(temp));
	if (p>0) then
		 Paise:= copy(temp,p+1,2);
	rupees := IntToStr(trunc(act_num));
  //      if axp.dbm.gf.millions then
          temp1:= AmtInWordMillion(rupees);
  //      else
	temp1:=amt_word(rupees);
	if not (temp1='') then
		 name:=name+'Rupees'+' '+temp1;
	temp1:=amt_word(paise);
	if ((name<>'') and (temp1<>'')) then
			name:=name+' and '+ 'Paise'+' '+ temp1
	else if (temp1<>'') then
			 name:='Paise'+' '+temp1;

	if name<>'' then
		 result:=name+' only'
	else
		 result:='';
end;

Function TEval.CurrAmtWord(Act_Num : Extended;CurcyName,SubCurcyName :String;MRep : Boolean;DecWidth: integer) : String;
var
 p: Integer;
 temp,temp1,name,rupees,paise: String;
begin
  name:='';
  temp1:='';
  temp:='';
  //if (decwidth<0) or (decwidth>3) then decwidth:=2;
  temp := trim(Format('%16.'+trim(intTostr(decwidth))+'f', [act_num]));
  //p:= pos(axp.dbm.gf.LocDecimalSeparator,trim(temp));
  if (p>0) then Paise:= copy(temp,p+1,decwidth) else paise:='0';
  rupees := IntToStr(trunc(act_num));
  //if (axp.dbm.gf.millions) or (MRep) then
    temp1:= trim(AmtInWordMillion(rupees));
  //else
    //temp1:=trim(amt_word(rupees));
  if not (temp1='') then name:=name + trim(CurcyName)+' '+temp1;
  temp1:=trim(amt_word(paise));
  if ((name<>'') and (temp1<>'')) then
     name:=name+' and '+ SubCurcyName +' '+ temp1
  else if (temp1<>'') then
     name:=SubCurcyName+' '+temp1;
  if name<>'' then result:=name+' only'
  else result:='';
end;

Function RemoveCommas(S: String): String;
Var
  k: integer;
Begin
  While true Do Begin
    k := pos(LocThousandSeparator, s);
    If k = 0 Then break;
    delete(s, k, 1);
  End;
  Result := S;
End;

Function TEval.Val(StrNum: String) : Extended;
var
	 num: real;
	 p,l: Integer;
	 strtemp: String;
begin
         result:=0;
         strnum := removecommas(strnum);
         if strnum='' then begin
            result:=0;
            exit;
         end;
         if strnum[1]='(' then
           strnum := copy(strnum, 2, length(strnum)-2);
         p := pos(' ', strnum);
         if p > 0 then
           strnum := copy(strnum, 1, p-1);
	 l:=0;
	 strtemp:=trim(strNum);
	 p:=pos('.',trim(strtemp));

	 if p >0 then
			begin
				l:=length(copy(strtemp,p+1,length(strtemp)-p));
			end;
	 try
		 num:=StrToFloat(strtemp);
	 except on e:Exception do
    begin
			//if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\Val - '+e.Message);
      num:=0;
    end;
	 end;
   result := num;
//	 result:=Round(num,l);
 end;

Function TEval.Str(Num : Extended): String;
var
	Strnum: String;
begin
		 try
			 StrNum:=floatToStr(num);
		 except on e:Exception do
      begin
			 //if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\Str - '+e.Message);
       strnum:='0';
      end;
		 end;
		 result:=strNum;
end;

Function TEval.SubStr(S:String;Sposn,Num:integer) : String;
begin
 if lowercase(s) = 'null' then s := '';
 result := Copy(S,Sposn,Num);
end;

Function TEval.AddToDate(Dt:TDateTime;count:integer) : TDateTime;
begin
 try
 result := dt + count;
 except on e:Exception do
  begin
    //if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\AddToDate - '+e.Message);
    //result := StrToDateTime('30'+ AxP.dbm.gf.ShortDateFormat.DateSeparator+'12'+ AxP.dbm.gf.ShortDateFormat.DateSeparator+'1900')
  end;
 end;
end;


function TEval.chkuniqchar(vStr:String):Boolean;
var
  i,j,l: integer;
begin
   vStr:=copy(trim(vStr),1,10);
   l:=length(trim(vstr));
   result:=true;
   for i:=1 to l do
     for j:=i+1 to l do
        if vStr[i]=vStr[j] then
             begin
               result:=false;
               exit;
             end;
end;

function TEval.findcharpos(vStr:String;iStr:Char):integer;
var
  i,p: integer;
begin
    vStr:=copy(Trim(vStr),1,10);
    result:=0;
    for i:=1 to length(vStr) do begin
       if vStr[i]=istr then
         begin
           result:=i;
           exit;
         end;
    end;
end;

Destructor TEVal.Destroy;
var i:integer;
begin
 for i:=0 to Validfnclist.Count-1 do
   dispose(pFunctions(validfnclist[i]));
 Validfnclist.clear;
 validfnclist.Free;
 ClearFncList;
 FncList.Free;
 varlist.Free;
 ExpList.free;
 ExpTypeList.free;
 NewExprTypeList.free;
 valuelist.Free;
 MemVarList.Free;
 funlist.free;
 funtypelist.free;
 StkList.free;
 StkTypeList.free;
 cpf.free;
 ClearPrepList;
 PrepList.free;
 PrepList := nil;
// for i:=0 to QueryList.count-1 do begin
//   if assigned(TXDS(Querylist[i]).CDS) then
//   begin
//     TXDS(Querylist[i]).close;
//     TXDS(Querylist[i]).destroy;
//   end;
// end;
 QueryList.free;
 varsused.Free;
 CopyRecordIds.free;
 loops.Free;
 loopcond.free;
// if assigned(copypost) then copypost.Free;
//// if CopyTable <> nil then CopyTable.Free;
// for i:=0 to copytables.count-1 do
// begin
//    txds(copytables[i]).Free;
// end;
// copytables.free;
// if assigned(QLockSeq) then QLockSeq.destroy;
// if assigned(ModTable) then ModTable.destroy;
// if assigned(QSeq) then QSeq.destroy;
// if Assigned(slParams) then
// begin
//    slParams.Clear;
//    FreeAndNil(slParams);
// end;
// if Assigned(Dict) then FreeAndNil(Dict);
 inherited Destroy;
end;

procedure TEVAL.DoMRP(SDate, EDate: String);
begin

end;

function TEVAL.doStoredProc(name, invars, outvars: String): String;
begin

end;

Procedure TEVal.ClearPrepList;
var i:integer;
begin
  for i:=0 to Preplist.count-1 do begin
    if assigned(pPrep(PrepList[i])^.ExprList) then begin
      pPrep(PrepList[i])^.ExprList.Free;
      pPrep(PrepList[i])^.ExprTypeList.free;
      pPrep(PrepList[i])^.OrgList.Free;
    end else if assigned(pPrep(PrepList[i])^.fcall) then
      dispose(pFunctions(pPrep(PrepList[i])^.fcall));
    dispose(pPrep(PrepList[i]));
  end;
  PrepList.clear;
end;

function TEval.DaysElapsed(D1,D2:String):real;
begin
 try
 Result := Int(strtodatetime(D2)-strtodatetime(D1));
 except on e:Exception do
  begin
//    if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\DaysElapsed - '+e.Message);
    Result := 0;
  end;
 end;
end;

function TEval.TimeElapsed(T1,T2:String):real;
var h,m,s,ms:word;
    d:integer;
    x:extended;
begin
try
 x := StrToDateTime(T2)-StrToDateTime(T1);
 D := trunc(x)*24;
 DecodeTime(strtodatetime(t2)-strtodatetime(t1), h, m, s, ms);
 if m<10 then
    Result := StrToFloat(inttostr(d+h)+'.0'+inttostr(m))
 else
    Result := StrToFloat(inttostr(d+h)+'.'+inttostr(m));
except on e:Exception do
  begin
//    if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\TimeElapsed - '+e.Message);
    Result := 0;
  end;
end;
end;

function TEVal.AddToTime(Timestr:String; AddTime : real): String;
var h,m,s,ms:word;
begin
 Result := '';
end;

function TEVal.AddToMonth(Dt:TDateTime; N:integer) : TDateTime;
var d,m,y:word;
    i:integer;
begin
 DecodeDate(Dt, y, m, d);
 if n < 0 then begin
  i := 1;
  n := abs(n);
  while i <= n do begin
    if m=1 then begin m:=12; dec(y); end else dec(m);
    inc(i);
  end;
 end else begin
  i := 1;
  while i <= n do begin
    if m=12 then begin m:=1; inc(y); end else inc(m);
    inc(i);
  end;
 end;
{ if (m+n)<=0 then begin
  y := y - (abs(m+n) div 12)-1;
  m := 12 - (abs(m+n) mod 12);
 end else if (m+n)>12 then begin
  y := y + ((m+n) div 12);
  m := (m+n) mod 12;
 end else
  m := m+n;}
 Result := ValidEncodeDate(y,m,d);
end;

function TEval.LastDayOfMonth(Dt:TDateTime):TDateTime;
var d,m,y:word;
begin
  decodeDate(dt,y,m,d);
  case m of
    1,3,5,7,8,10,12 : d:=31;
    4,6,9,11        : d:=30;
    else
    begin
       if IsLeapYear(y) then d:=29 else d:=28;
    end;
  end;
 dt:=encodedate(y,m,d);
{
 DecodeDate(Dt, y, m, d);
 d := 31;
 Result := ValidEncodeDate(y, m, d);}
 Result:=dt;
end;

function TEval.ValidEncodeDate(y, m, d:word):TDateTime;
begin
try
 Result := EncodeDate(y,m,d);
except on e:Exception do
  begin
//   if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\ValidEncodeDate - '+e.Message);
   try
    Result := EncodeDate(y,m,d-1);
   except on e:Exception do
    begin
//      if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\ValidEncodeDate - '+e.Message);
      try
       Result := EncodeDate(y,m,d-2);
      except on e:Exception do
        begin
//          if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\ValidEncodeDate - '+e.Message);
          Result := EncodeDate(y,m,d-3);
        end;
      end;
    end;
   end;
  end;
end;
end;

function TEVal.Eval(Expr:String):String;
begin
 DynamicCompute := true;
 Result := Expr;
end;

function TEval.AmtInWordMillion(Str_num: String): String;
var
    Q,d,act_num: real;
    R: integer;
    I: Byte;
    temp: String;
    AddS: String;
    WordArr: array [1..4] of String;
Begin
   Act_num:=StrtoCurr(Str_num);
   d:=1000000000000;
   wordarr[1]:='Trillion';
   wordarr[2]:='Billion';
   wordarr[3]:='Million';
   wordarr[4]:='Thousand';
    r:=1;
    result:='';
   While True do begin
      q:= act_num/d;
      if q>0 then begin
        temp:=currToStr(int(q));
        act_num:=act_num-(int(q)*d);
        result:=result+' '+amt_word(temp);
        if (StrToCurr(temp)<>1) and (r<4) then adds:='s' else adds:=' ';
        if (r<=4) and (temp<>'0')  then result:=result+' '+wordarr[r]+adds;
      end;
      d:=d/1000;
      inc(r);
      if d<1000 then begin
         result:=result+' '+amt_word(CurrToStr(act_num));
         break;
      end;
   end;
end;

function TEval.CMonthYear(Dt : TDateTime): String;
begin
    Try
     Result:=FormatDateTime('mmmm yyyy',dt);
    Except on e:Exception do
      begin
      // ShowMessage('Invalid Date ');
//        if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\CMonthYear - '+e.Message);
        result := 'Invalid Date';
     end;
    end;
end;
function TEVAL.Lpad(str1: String; Width: integer;padChar: Char): String;
var
 i,l: integer;
begin
    result:='';
    l:=length(str1);
    if l>=width then begin
       result:=copy(str1,1,l);
       exit;
    end;
    if padchar='' then padchar:=' ';
    for i:=1 to width-l do result:=result+padchar;
    Result:=result+str1;
end;

function TEVAL.Rpad(str1: String; Width: integer;padChar: Char): String;
var
 i,l: integer;
begin
    result:='';
    l:=length(str1);
    if l>=width then begin
       result:=copy(str1,1,l);
       exit;
    end;
    if padchar='' then padchar:=' ';
    for i:=1 to width-l do result:=result+padchar;
    Result:=str1+result;
end;

Function TEval.VarsUsedInExpr(Expr:String; varnames:TStringList): String;
var position : integer;
    ch : Char;
    ConstWord : boolean;
begin
 DynamicCompute := false;
 while true do begin // this loop is to handle eval function
  position := 1;
  Bracket := '';
  clearfnclist;
  Expression := Trim(Expr);
  ExpList.Clear;
  ExpList.add('');
  ExpIndex := 0;
  StrCount := 0;
  ConstWord := false;
  Result := '';
  while true do begin
   if position <= length(expression) then ch := expression[position] else ch := chr(32);
   expstrpos := position;
   if (ch='{') then StartString;
   if (ch='}') then begin
    EndString;
    ConstWord := true;
   end;

   if (ch in Delimiters) or (ch in operators) then begin

    if not ConstWord then begin
     if VarNames.indexof(Explist[expindex]) <> -1 then
       Result := Result + Explist[expindex] + ',';
     position := expstrpos;
    end else begin
     ConstWord := false;
    end;

    if ch = '(' then begin
     if (length(bracket)>0) and (copy(bracket,length(bracket),1) = 'F') then
      ch := ' ';
     Bracket := Bracket + '(';
    end;

    if ch = ')' then begin
     delete(bracket,length(bracket),1);
     if (length(bracket)>0) and (copy(bracket,length(bracket),1) = 'F') then begin
      ExpList.add(chr(2));
      delete(bracket,length(bracket),1);
      ch := ' '
     end;
    end;

    if ch<>' ' then begin
     ExpList.add(ch);
    end;
    ExpList.add('');
    ExpIndex := ExpList.Count-1;
   end
   else
     if not (((ch = '{') and (strcount = 1)) or ((ch='}') and (strcount = 0))) then
       ExpList[ExpIndex] := ExpList[ExpIndex] + ch;
   if position > length(Expression) then break;
   inc(position);
  end;
  if not DynamicCompute then break;
  DynamicCompute := false;
  Expr := Value;
 end;
End;

function TEVAL.verifyTree(TreeName: String): String;
begin

end;

function TEval.GetNumber(s:String):String;
var ch:Char;
    i:integer;
begin
  result := '';
  for i:=1 to length(s) do begin
    ch := s[i];
    if ch in numbers then result := result + ch;
  end;
end;


Function GetNthString(SrcString: String; StrPos: integer): String; overload;
Var
  i, k: integer;
Begin
  Result := '';
  i := 1;
  k := 1;
  while (k <= strpos) and (i<=length(srcstring)) do begin
   if srcstring[i] = ',' then
    inc(k)
   else if k = strpos then
    result := result + srcstring[i];
   inc(i);
  end;
End;

Function GetNthString(SrcString: String; StrPos: integer; Separator : Char ): String; overload;
Var
  i, k: integer;
Begin
  Result := '';
  i := 1;
  k := 1;
  while (k <= strpos) and (i<=length(srcstring)) do begin
   if srcstring[i] = Separator then
    inc(k)
   else if k = strpos then
    result := result + srcstring[i];
   inc(i);
  end;
end;

function GetNthString(SrcString: String; StrPos: integer; Separator: String): String; overload;
Var
  i, k: integer;
  searchlength : integer;
Begin
  if length(Separator) = 1 then
    Result := GetNthString(SrcString, StrPos, Separator[1])
  else
  begin
    Result := '';
    i := 1;
    k := 1;
    searchlength := length(Separator);
    while (k <= strpos) and (i<=length(srcstring)) do begin
      if copy(srcstring, i, searchlength) = Separator then
      begin
        inc(k);
        i := i + searchlength;
      end
      else if k = strpos then
      begin
        result := result + srcstring[i];
        inc(i);
      end
      else
        inc(i);
    end;
  end;
end;


procedure TEval.EvalExprSet(startpos:integer);
var i,p:integer;
    s, v, cond, cmd, op:String;
    cresult, skip, breakflag:boolean;
begin
// if axp.dbm.gf.actionName = 'isave' then exit;
 if not assigned(exprset) then exit;
 if ExprSet.count = 0 then exit;
// axp.dbm.gf.ErrorInActionExecution  := '';
 try
   loops.clear;loopcond.clear;
   i:=startpos;
   skip:=false;
   cresult:=true;
   breakflag:=false;
   while i<exprset.count do begin
    s:=exprset[i];
    cmd:=trimleft(s);
    if (s = '') or (copy(cmd,1,2) = '//') then begin
      inc(i);
      continue;
    end;
    if copy(cmd,1,1) = '{' then break;

    op:=lowercase(Getnthstring(cmd,1,' '));
    if breakflag then begin
      if op<>'endloop' then begin
        inc(i);
        continue;
      end;
    end;

    if (op='if') then begin
      delete(cmd, 1, 2);
      cond:=trim(cmd);
      if raiseonactionerr then
      begin
        //if axp.dbm.gf.ErrorInActionExecution <> '' then
          // raise exception.Create(axp.dbm.gf.ErrorInActionExecution)
        //else
         if not evaluate(cond) then raise exception.Create('');
      end else evaluate(cond);
      cresult:=Value='1';
      skip:=cresult;
    end else if (op='elseif') then begin
      if skip then cresult:=false
      else cresult:=not cresult;
      if cresult then begin
        delete(cmd, 1, 6);
        cond:=trim(cmd);
        if raiseonactionerr then
        begin
          //if axp.dbm.gf.ErrorInActionExecution <> '' then
            // raise exception.Create(axp.dbm.gf.ErrorInActionExecution)
          //else if not evaluate(cond) then raise exception.Create('');
        end
        else evaluate(cond);
        cresult:=Value='1';
        skip:=cresult;
      end;
    end else if (op='else') then begin
      if skip then cresult:=false
      else begin
        cresult:=not cresult;
        skip:=cresult;
      end;
    end else if (op = 'end') then begin
      cresult:= True;
      skip:=false;
    end else if (op='endloop') then begin
      if breakflag then begin
        breakflag:=false;
        loopcond.delete(loops.count-1);
        loops.Delete(loops.count-1);
      end else begin
        cond:=loopcond[loops.count-1];
        if raiseonactionerr then
        begin
         // if axp.dbm.gf.ErrorInActionExecution <> '' then
           //  raise exception.Create(axp.dbm.gf.ErrorInActionExecution)
          //else
          if not evaluate(cond) then raise exception.Create('');
        end
        else evaluate(cond);
        if value='1' then
          i:=strtoint(loops[loops.count-1])
        else begin
          loopcond.delete(loops.count-1);
          loops.Delete(loops.count-1);
        end;
      end;
    end else if (op='while') then begin
      delete(cmd, 1, 5);
      cond:=trim(cmd);
      if raiseonactionerr then
      begin
        //if axp.dbm.gf.ErrorInActionExecution <> '' then
          // raise exception.Create(axp.dbm.gf.ErrorInActionExecution)
        //else
         if not evaluate(cond) then raise exception.Create('');
      end
      else evaluate(cond);
      if value='1' then begin
        loops.add(inttostr(i));
        loopcond.add(cond);
      end;
    end else if (op='break') then begin
      breakflag:=true;
      cresult:=true;
      skip:=false;
    end else if (cresult) then begin
      //if assigned(SetProgress) then SetProgress('Evaluating Line '+IntToStr(i));
      p := pos(':=', s);
      v := '';
      if p <> 0 then begin
       v := trim(copy(s, 1, p-1));
       s := copy(s, p+2, length(s));
      end;
      if raiseonactionerr then
      begin
        //if axp.dbm.gf.ErrorInActionExecution <> '' then
          // raise exception.Create(axp.dbm.gf.ErrorInActionExecution)
        //else
         if not evaluate(s) then raise exception.Create('');
      end
      else evaluate(s);
      //if assigned(SetProgress) then SetProgress('');
      if value <> '' then begin
        if copy(value,1,7) = '@error*' then
          Raise Exception.Create(value);
      end;
      if v <> '' then
        registervar(v, expressiontype, value);
    end;
    inc(i);
   end;
   loops.clear;
   loopcond.clear;
 except on e:exception do
   begin
      //if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\EvalExprSet - '+e.Message);
      raise exception.Create(e.message);
   end;
 end;
end;

procedure TEval.EvalExps(slist:tstringlist);
begin
  if not assigned(slist) then exit;
  if slist.count = 0 then exit;
  exprset:=slist;
  evalexprset(0);
end;

Function TEVal.GetLength(pValue : String) :integer;
begin
 Result := Length(pvalue);
end;

procedure TEVAL.ExportSQL(SQLText, FormatString, FileName, Delimiter,
  withheader: String);
begin

end;

function TEVal.ExtractNum(s:String):String;
var i,j:integer;
begin
  j:=0;
  result := '';
  for i:=1 to length(s) do begin
    if ((ord(s[i]) >= 48) and (ord(s[i]) <= 57)) {or (s[i]= axp.dbm.gf.LocDecimalSeparator)} or (s[i]='-') then begin
      if j=0 then inc(j);
      result := result + s[i];
    end else if j=1 then break;
  end;
end;

function TEVAL.ExtractQueryParams(sqltext: String): String;
begin

end;

Function TEval.FindAndReplace(S:String;FindWhat:String;ReplaceWith: String):String;
var p:Integer;
begin
     Result:=s;
     p:=Pos(FindWhat,S);
     if p=0 then exit;
     Result:='';
     while p>0 do
     begin
          Result:=Result + copy(s,1,p-1) + ReplaceWith;
          Delete(s,1,p+length(FindWhat)-1);
          p:=Pos(FindWhat,S);
     end;
     Result := Result + s;
end;

function TEVal.IsFunctionUsed(s:String):boolean;
var i:integer;
begin
  result := false;
  s:=lowercase(s);
  for i:=0 to preplist.count-1 do begin
    if (assigned(pPrep(preplist[i])^.FCall)) and (pPrep(preplist[i])^.FCall^.Fname = s) then begin
      result := true;
      break;
    end;
  end;
end;

procedure TEVAL.FindRecord(SQLName, SearchField, SearchValue: String;
  var resultstr: String);
begin

end;




//
//function TEval.FireSql(SQLName, SqlText: WideString): WideString;
//Var i : integer;
//    Query:TClientDataSet;
//    FuncQry : Boolean;
//    pResult: PChar;
//    resultStr: string;
//begin
// try
//    pResult := FireSqlRaw(PChar(SQLName), PChar(SqlText));
//    resultStr := string(pResult);
//    Result := resultStr;
//
// finally
//    if Assigned(pResult) then
//       FreeFireSql(pResult);
//  end;
////  if axp.dbm.gf.actionName = 'isave' then exit;
////  Query := nil;
////  sqltext := Trim(sqltext);
////  FuncQry := False;
////  for i:=0 to querylist.count-1 do begin
////    if txds(querylist[i]).name='Expr_'+SQLName then begin
////      Query := Txds(QueryList[i]);
////      break;
////    end;
////  end;
////  if not assigned(Query) then begin
////    Query := axp.dbm.GetXDS(Query);
////    Query.Name := 'Expr_'+SQLName;
////    Query.SetCDSName('Parse_FireSQL_'+SQLName);//Query.SetCDSName('nolds_Parse_FireSQL_'+SQLName);
////    Query.buffered := true;
////    if lowercase(copy(sqltext,1,6)) = 'select' then
////      Querylist.Add(query)
////  end;
////  Query.close;
////  if (axp.dbm.Connection.DbType = 'postgre') and (lowercase(copy(trim(SQLText),1,4)) = 'call') then
////  begin
////    SQLText := Trim(SQLText);
////    if (lowercase(copy(trim(SQLText),1,8)) = 'callproc') then begin
////      Delete(SQLText,1,8);
////      SQLText := 'call '+SQLText;
////    end else begin
////      Delete(SQLText,1,4);
////      SQLText := 'select '+SQLText;
////    end;
////    FuncQry := True;
////  end;
////  Query.SetCDSName('Parse_FireSQL_'+SQLName);//Query.SetCDSName('nolds_Parse_FireSQL_'+SQLName);
////  Query.CDS.CommandText:=sqltext;
////  ReplaceParams(Query);
////  if axp.dbm.gf.remotelogin then
////     Query.open
////  else begin
////    if (lowercase(copy(trim(SQLText),1,6)) = 'select') and (not FuncQry) then
////      Query.Open
////    else
////      Query.execsql;
////  end;
////  if (lowercase(copy(sqltext,1,6)) <> 'select') or (FuncQry) then begin
////    query.close;
////    query.destroy;
////    query := nil;
////  end;
//end;

function TEval.FireSql(
  coreHandler, aQuery, aParamName, paramType, paramValues: WideString
): WideString;
var
  pResult: PChar;
  resultStr: string;
  Query: TMemDataset;
  I: Integer;
begin
  try
    // Reuse or create dataset
    Query := nil;
    for I := 0 to QueryList.Count - 1 do
    begin
      if TMemDataset(QueryList[I]).Name = 'Expr_' + coreHandler then
      begin
        Query := TMemDataset(QueryList[I]);
        Break;
      end;
    end;

    if not Assigned(Query) then
    begin
      Query := TMemDataset.Create(nil);
      Query.Name := 'Expr_' + coreHandler;
      if LowerCase(Copy(AQuery, 1, 6)) = 'select' then
        QueryList.Add(Query);
    end;

    // Call the .NET Core FireSQL function
    pResult := FireSqlRaw(
      PChar(coreHandler),
      PChar(AQuery),
      PChar(aParamName),
      PChar(paramType),
      PChar(paramValues)
    );

    resultStr := string(pResult);

    // Convert JSON to dataset
    if Assigned(Query) then
    begin
      Query.Close;
      LoadJSONToMemDS(Query, resultStr);
      Query.Open;
    end;

    Result := resultStr;
  finally
    if Assigned(pResult) then
      FreeFireSql(pResult);
  end;
end;

//Procedure TEVal.ReplaceParams(Q :TXDS);
//var cnt : integer;
//    SQLText,Paramname,DType,paramvalue : String;
//begin
//  SQLText := Q.CDS.CommandText ;
//  if (Pos('{',SQLText) <> 0) then
//    Q.CDS.CommandText := ReplaceDynamicparams(SQLText);
//  Q.GetParamNames;
//  For cnt := 0 to Q.CDS.Params.count-1 do begin
//    Paramname := Q.CDS.Params[cnt].Name;
//    Paramvalue := Getvarvalue(paramname);
//    DType := LastVarType;
//    IF (Paramvalue = '') and (dtype = 'n') then paramvalue := '0';
//    Q.AssignParam(cnt, ParamValue, Dtype);
//  end;
//end;

Function TEVal.ReplaceDynamicparams(SQLText:String):String;
var
 Lparamname, Lparamvalue:String;
 p1,p2:integer;
begin
  Result := SQLText;
  while true do begin
  p1 := pos('{',SQLText);
  if p1>0 then begin
   p2 := pos('}', SQLText);
   if p2 = 0 then
    Raise Exception.Create('Invalid sql '+SQLText);
   LParamName := Copy(SQLText,p1+1,p2-p1-1);
   Lparamvalue := GetVarValue(LParamName);
   Delete(SQLText, p1, p2-p1+1);
   Insert(LParamValue, SQLText, p1);
   Result := SQLText;
  end;
  if (p1=0) then break;
  end;
end;


procedure TEVal.SQLGETValue(SQLName, FieldName: String; var ResultStr: String);
var
  Q: TMemDataset;
  Fld: TField;
  I: Integer;
begin
  Q := nil;
  for I := 0 to QueryList.Count - 1 do
  begin
    if TMemDataset(QueryList[I]).Name = 'Expr_' + SQLName then
    begin
      Q := TMemDataset(QueryList[I]);
      Break;
    end;
  end;

  if not Assigned(Q) then Exit;

  Fld := Q.FindField(FieldName);
  if not Assigned(Fld) then
    raise Exception.Create('Unable to Evaluate an expression : SQLGet');

  ResultStr := Q.FieldByName(FieldName).AsString;
end;


//procedure TEVal.SQLGETValue(SQLName, FieldName: String; var ResultStr: String);
//Var
//  Q: TXDS;
//  Fld : Tfield;
//  i:integer;
//begin
//  Q := nil;
//  for i:=0 to querylist.count-1 do begin
//    if txds(querylist[i]).name='Expr_'+SQLName then begin
//      Q := txds(QueryList[i]);
//      break;
//    end;
//  end;
//  if not assigned(Q) then exit;
//  if (Q.CDS.CommandText = '') then Raise Exception.Create('Unable to Evaluate an expression : SQLGet');
//  fld:=q.cds.FindField(fieldname);
//  if not (Assigned(fld)) then Raise Exception.Create('Unable to Evaluate an expression : SQLGet');
//  ResultStr:=Q.cds.fieldbyname(fieldname).AsString;
//end;
//
//procedure TEVal.FindRecord(SQLName, SearchField, SearchValue: String;var resultstr: String);
//Var
//  Q: TXDS;
//  Fld : Txfield;
//  i:integer;
//begin
//  Q := nil;
//  for i:=0 to querylist.count-1 do begin
//    if txds(querylist[i]).name='Expr_'+SQLName then begin
//      Q := txds(QueryList[i]);
//      break;
//    end;
//  end;
//  if not assigned(Q) then exit;
//
//  if Q.SQL.Text = '' then Raise Exception.Create('Unable to Evaluate an expression : SQLGet');
//  fld:=Q.FindField(searchfield);
//  if not (Assigned(fld)) then Raise Exception.Create('Unable to Evaluate an expression : SQLGet'+searchfield);
//  if (Fld.DataType=ftFloat) or  (Fld.DataType=ftInteger) then begin
//      if axp.dbm.gf.QueryLocate(Q.CDS,SearchField,strToFloat(SearchValue)) then
//          resultstr:='T'
//      else
//         resultstr:='F';
//  end else begin
//     if Q.CDS.Locate(SearchField,SearchValue,[locaseinsensitive]) then
//        resultstr:='T'
//     else resultstr:='F';
//  end;
//end;
//
//function TEVal.GetDelimitedStr(SQLName, FieldName, Delimiter: String) : String;
//var Q: TXDS;
//    i:integer;
//begin
//  Result := '';
//  if lowercase(copy(SQLName, 1, 7))='select ' then begin
//    Q := axp.dbm.GetXDS(nil);
//    Q.Name := 'Q__Delimited';
//    Q.buffered := true;
//    Q.CDS.CommandText:=SQLName;
//    replacedynamicparams(q.CDS.CommandText);
//    if Q.CDS.Params.Count>0 then begin
//      for i:=0 to Q.CDS.Params.Count-1 do
//      //  Q.CDS.Params[i].AsString:=getvarvalue(q.CDS.Params[i].Name);
//         Q.AssignParam(i,getvarvalue(q.CDS.Params[i].Name),'c');
//    end;
//    Q.Open;
//  end else exit;
//  if not assigned(Q) then exit;
//  if not assigned(q.cds) then begin
//    q.close; q.destroy; q:=nil;
//    exit;
//  end;
//  if not assigned(q.cds.findfield(fieldname)) then begin
//    q.close; q.destroy; q:=nil;
//    exit;
//  end;
//  if delimiter = '' then delimiter := ',';
//  if not Q.CDS.IsEmpty then begin
//    Q.CDS.first;
//    while not Q.CDS.eof do begin
//      Result := Result + Q.CDS.fieldbyname(fieldname).asstring + delimiter;
//      Q.CDS.Next;
//    end;
//  end;
//  if result <> '' then result := copy(result,1, length(result)-length(delimiter));
//  q.close; q.destroy; q:=nil;
//end;

procedure TEVal.Assign(source:TEval);
var i:integer;
begin
  if not assigned(source) then exit;
  varlist.Clear;valuelist.Clear;
  VarTypeStr := '';zerovalue:='';
  for i:=0 to source.Varlist.Count-1 do begin
    varlist.add(source.Varlist[i]);
    valuelist.add(source.ValueList[i]);
    vartypestr:=vartypestr+source.vartypestr[i+1];
    zerovalue:=zerovalue+source.zerovalue[i+1];
  end;
end;

//function TEVal.ConvertMD5(s:String):String;
//  var  md5 : // removed: MessageDigest_5.IMD5;
//begin
//  md5 := // removed: MessageDigest_5.GetMD5();
//  md5.Update(s);
//  result := lowercase(md5.AsString());
//  md5 := nil;
//end;
//
//function TEval.BulkExecute(s:String) : String;
//var x,q:TXDS;
//    i : integer;
//    ptype,pval,s1 : String;
//begin
//  result := '';
//  axp.dbm.gf.DoDebug.msg('   >>Executing BulkExecute');
//  x := axp.dbm.GetXDS(nil);
//  x.buffered := True;
//  x.CDS.CommandText := s;
//  if x.CDS.Params.Count > 0 then begin
//    for i := 0 to x.CDS.Params.Count-1 do begin
//      pval := GetVarValue(x.CDS.Params[i].Name);
//      ptype := lastvartype;
//      x.AssignParam(i,pval,ptype);
//    end;
//  end;
//  axp.dbm.gf.DoDebug.msg('   Executing query '+s);
//  try
//    if axp.dbm.gf.remotelogin then
//      x.Open
//    else
//    begin
//      axp.dbm.gf.DoDebug.msg('   Executing query in server : '+s);
//      x.Open;
//    end;
//  except
//    on e:exception do begin
////      if remotelogin = false then showmessage(e.Message) ;
//      if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\BulkExecute - '+e.Message);
//      axp.dbm.gf.DoDebug.msg('   ' + e.Message);
//      result := e.Message;
//      x.close;x.Free;
//      exit;
//    end;
//  end;
//  if (x.CDS.IsEmpty )then begin
//    x.cds.Close; x.Free;
//    exit;
//  end;
//  q:=axp.dbm.GetXDS(nil);
//  q.buffered := True;
//  while not x.CDS.Eof do begin
//    if Trim(x.CDS.Fields[0].AsString) = '' then begin
//      x.CDS.Next;
//      continue;
//    end;
//    s1 := x.CDS.Fields[0].AsString;
//    q.CDS.CommandText := s1;
//    if assigned(ondisplaymessage) then
//      ondisplaymessage('Executing '+s1,'f');
//    axp.dbm.gf.DoDebug.msg('   Executing '+s1);
//    if x.CDS.FieldCount = 3 then begin
//      if assigned(ondisplaymessage) then
//        ondisplaymessage(x.CDS.Fields[2].AsString,'f');
//    end;
//    {
//    if q.CDS.Params.Count > 0 then begin
//      for i := 0 to q.CDS.Params.Count-1 do begin
//        if x.CDS.FieldCount = 1 then begin
//          q.CDS.Params[i].AsString := GetVarValue(q.CDS.Params[i].Name);
//        end else begin
//          ptype := lowercase(copy(x.CDS.Fields[1].AsString,i+1,1));
//          if ptype = '' then ptype := 'c';
//          if ptype = 'n' then
//            q.CDS.Params[i].AsFloat := StrToFloat(GetVarValue(q.CDS.Params[i].Name))
//          else if ptype = 'd' then
//            q.CDS.Params[i].AsDateTime := StrToDateTime(GetVarValue(q.CDS.Params[i].Name))
//          else if ptype = 'c' then
//            q.CDS.Params[i].AsString := GetVarValue(q.CDS.Params[i].Name);
//        end;
//      end;
//    end;
//    }
//    if q.CDS.Params.Count > 0 then begin
//      for i := 0 to q.CDS.Params.Count-1 do begin
//        if x.CDS.FieldCount = 1 then begin
//          q.CDS.Params[i].AsString := GetVarValue(q.CDS.Params[i].Name);
//          axp.dbm.gf.dodebug.Msg('   ' + q.CDS.Params[i].Name+'='+q.CDS.Params[i].AsString);
//        end else begin
//          ptype := lowercase(copy(x.CDS.Fields[1].AsString,i+1,1));
//          if ptype = '' then ptype := 'c';
//          q.AssignParam(i,GetVarValue(q.CDS.Params[i].Name),ptype);
//          axp.dbm.gf.dodebug.Msg('   '+ q.CDS.Params[i].Name+'='+GetVarValue(q.CDS.Params[i].Name));
//{--          if ptype = 'n' then
//            q.AssignParam(i,GetVarValue(q.CDS.Params[i].Name),ptype);
//          else if ptype = 'd' then
//            q.AssignParam(i,GetVarValue(q.CDS.Params[i].Name),ptype);
//            q.CDS.Params[i].AsDateTime := StrToDateTime(GetVarValue(q.CDS.Params[i].Name))
//          else if ptype = 'c' then
//            q.CDS.Params[i].AsString := GetVarValue(q.CDS.Params[i].Name);--}
//        end;
//      end;
//    end;
//
//    try
//    if axp.dbm.gf.remotelogin then
//      q.Open
//    else
//      q.execsql
//    except
//      on e:exception do begin
//        if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\BulkExecute - '+e.Message);
//        if assigned(ondisplaymessage) then
//          ondisplaymessage(x.CDS.Fields[2].AsString,'f')
//        else begin
////          if not remotelogin then
////             showmessage(e.Message+#13+x.CDS.Fields[0].AsString);
//          axp.dbm.gf.DoDebug.msg('   Result Error '+e.Message);
//        end;
//        x.Free;q.Free;
//        result := e.Message ;
//        exit;
//      end;
//    end;
//    x.CDS.Next;
//  end;
//  x.free;
//  q.free;
//end;
//
//procedure TEval.ConstructTable(s:String;tablename:String);
//var q,x,t : TXDS;
//    fs,fname,ftype,dtype : String;
//    fwidth,fdec : Integer;
//    fld : TField;
//    DispMsg : Boolean;
//begin
//  x := axp.dbm.GetXDS(nil);
//  x.buffered := True;
//  x.CDS.CommandText := s;
//  x.Open;
//  if x.CDS.IsEmpty then begin
//    x.close; x.destroy; x:= nil;
//  end;
//  DispMsg := False;
//  q := axp.dbm.GetXDS(nil);
//
//  if not TableFound(tablename,q) then begin
//    q.close;
//    x.CDS.First;
//    fs := '';
//    while not x.CDS.Eof do begin
//      fname := x.CDS.Fields[0].AsString;
//      ftype := lowercase(x.CDS.Fields[1].AsString);
//      fwidth := x.CDS.Fields[2].AsInteger;
//      fdec := x.CDS.Fields[3].AsInteger;
//      fs := fs + ', '+FieldString(fname,ftype,fwidth,fdec);
//      x.CDS.Next;
//    end;
//    delete(fs,1,1);
//    fs := 'create table '+tablename+'( '+fs+' )';
//    q.buffered := True;
//    q.CDS.CommandText := fs;
//    try
//      if axp.dbm.gf.remotelogin then
//        q.open
//      else
//        q.execsql;
//    except
//      on e:exception do begin
//        if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\ConstructTable - '+e.Message);
//        if not axp.dbm.gf.isservice then
//           showmessage(e.Message);
//         q.close; x.close;
//         q.destroy; x.destroy;
//         q := nil; x := nil;
//        exit;
//      end;
//    end;
//    DispMsg := True;
//  end else begin
//    t := axp.dbm.GetXDS(nil);
//    t.buffered := true;
//    t.CDS.CommandText := 'select * from '+tablename+' where 1=2';
//    try
//      t.Open;
//    except
//      on e:exception do begin
//        if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\ConstructTable - '+e.Message);
//        if not axp.dbm.gf.isservice then showmessage(e.Message);
//        q.close; x.close; t.close;
//        q.destroy; x.destroy; t.destroy;
//        q := nil; x := nil; t := nil;
//        exit;
//      end;
//    end;
//    x.CDS.First;
//    while not x.CDS.Eof do begin
//      fname := x.CDS.Fields[0].AsString;
//      fld := t.CDS.Fields.FindField(fname);
//      ftype := lowercase(x.CDS.Fields[1].AsString);
//      fwidth := x.CDS.Fields[2].AsInteger;
//      fdec := x.CDS.Fields[3].AsInteger;
//      if fld <> nil then begin
//        dtype := GetFieldType(fld.DataType);
//        if dtype <> ftype then begin
//          if messagedlg('FieldType of '+fname+' is changed '+#13+'Delete and Recreate the field '+fname+'?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then begin
//            x.CDS.Next;
//            continue;
//          end;
//          q.buffered := true;
//          q.CDS.CommandText := 'alter table '+tablename+' drop column '+fname ;
//          try
//            q.ExecSQL;
//          except
//            on e:exception do begin
//              if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\ConstructTable - '+e.Message);
//              if not axp.dbm.gf.isservice then showmessage(e.Message);
//              q.close; x.close; t.close;
//              q.destroy; x.destroy; t.destroy;
//              q := nil; x := nil; t := nil;
//              exit;
//            end;
//          end;
//          q.close;
//          q.buffered := True;
//          q.CDS.CommandText := 'alter table '+tablename+' add '+FieldString(fname,ftype,fwidth,fdec);
//          try
//            q.ExecSQL;
//          except
//            on e:exception do begin
//              if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\ConstructTable - '+e.Message);
//              if not axp.dbm.gf.isservice then showmessage(e.Message);
//              q.close; x.close; t.close;
//              q.destroy; x.destroy; t.destroy;
//              q := nil; x := nil; t := nil;
//              exit;
//            end;
//          end;
//          DispMsg := True;
//          q.close; t.destroy; t := nil;
//        end;
//      end else begin
//        q.close;
//        q.buffered := True;
//        q.CDS.CommandText := 'alter table '+tablename+' add '+FieldString(fname,ftype,fwidth,fdec);
//        try
//          q.ExecSQL;
//        except
//          on e:exception do begin
//            if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\ConstructTable - '+e.Message);
//            if not axp.dbm.gf.isservice then showmessage(e.Message);
//            q.destroy; x.destroy; t.destroy;
//            q := nil; x := nil; t := nil;
//            exit;
//          end;
//        end;
//        DispMsg := True;
//      end;
//      x.CDS.Next;
//    end;
//    t.close; t.destroy; t := nil;
//  end;
//  if assigned(x) then begin
//    x.close;
//    x.destroy;
//    x := nil;
//  end;
//  if assigned(q) then begin
//    q.close;
//    q.destroy;
//    q := nil;
//  end;
//end;
//
//Function TEval.TableFound(Tablename :String;q:TXDS) :Boolean;
//begin
//  Result :=False;
//  q.buffered := True;
//  {$ifdef access}
//    q.CDS.CommandText := 'Select * from [' + UpperCase(Tablename) +'] where 1=2 ';
//  {$else}
//    q.CDS.CommandText := 'Select * from ' + UpperCase(Tablename) +' where 1=2 ';
//  {$endif}
//  Try
//    q.CDS.Active := True;
//    Result := True;
//  Except on e:Exception do
//    if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\TableFound - '+e.Message);
//  end;
//end;

Function TEval.FieldString(fname,ftype:String;fwidth,fdec:Integer):String;
var s,dbtype: String;

begin
  s := fname;
  //if axp.dbm.gf.remotelogin then
  //  dbtype := axp.dbm.gf.remotedbType
  //else
  //  dbtype := axp.dbm.Connection.DbType;
  if ftype = 'c' then begin
    if fwidth < 255 then begin
      if (dbtype = 'access') then
        s := s+' '+'Text('+inttostr(fwidth)+')'
      else if (dbtype = 'ms sql') or (dbtype='mysql') or (dbtype='postgre') then
        s := s+' '+'Varchar('+inttostr(fwidth)+')'
      else
        s := s+' '+'Varchar2('+inttostr(fwidth)+')';
    end else begin
      if (dbtype = 'access') then
        s := s+' Memo '
      else if (dbtype = 'ms sql') then
        s := s+' varchar(max) '
      else if (dbtype = 'mysql') or (dbtype='postgre')then
        s := s+' Text '
      else
        s := s+' CLOB ';
    end;
  end else if ftype = 'n' then begin
    if (dbtype = 'access') then
      If (fWidth<=5) And (fDec=0) Then s := s + '  INTEGER'
      Else  s := s + '  DOUBLE'
    else
      s := s + '  NUMERIC('+inttostr(fwidth+fdec)+ ',' + inttostr(fdec)+')';
  end else if ftype = 'd' then begin
    if (dbtype = 'ms sql') or (dbtype = 'mysql') then
      s := s + '  DATETIME'
    else
      s := s + '  DATE';
  end else if ftype = 't' then begin
    if (dbtype = 'access') then
      s := s+' Memo '
    else if (dbtype = 'ms sql') then
      s := s+' varchar(max) '
    else if (dbtype = 'mysql') or (dbtype='postgre') then
        s := s+' Text '
    else
      s := s+' CLOB ';
  end else if ftype = 'i' then begin
    if (dbtype = 'access') then
      s := s+' Memo '
    else if (dbtype = 'ms sql') then
      s := s+' varbinary(max) '
    else if (dbtype = 'mysql') then
      s := s+' Blob '
    else if (dbtype = 'postgre') then
      s := s+' BYTEA '
    else
      s := s+' BLOB ';
  end;
  result := s;
end;

//function TEval.GetFieldType(fldDataType:TFieldType):String;
//begin
//  if (fldDataType in [ftString, ftFixedChar, ftWideString]) then Result := 'c'
//  else if (fldDataType in [ftSmallInt, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD,
//          ftBytes, ftVarBytes, ftAutoInc, ftLargeInt, ftFMTBcd]) then Result := 'n'
//  else if (fldDataType in [ftDate, ftTime, ftDateTime, ftTimeStamp]) then Result := 'd'
//  else if (fldDataType in [ftMemo, ftFmtMemo, ftOraClob]) then Result := 't'
//  else if (fldDataType in [ftblob,ftGraphic, ftOraBlob]) then Result := 'i'
//  else if (fldDataType in [ftBoolean]) then Result := 'b'
//  else if (fldDataType in [ftunknown, ftVariant, ftInterface, ftParadoxOLE, ftDBaseOLE,
//                ftTypedBinary, ftADT, ftArray, ftReference, ftDataSet, ftIDispatch,
//                ftGUID, ftCursor]) then Result := 'u';
//end;

function TEVal.Mods(v1,v2: integer):integer;
begin
  result := v1 mod v2;
end;

//procedure TEVal.DoMRP(SDate, EDate: String);
//var s,s1,s2:String;
//MRP : TMRPRUN;
//aa : TXDS;
//fdate,tdate : TDateTime;
//begin
//  aa := TXDS.create('aa',nil,axp.dbm.Connection,axp.dbm.gf);
//  aa.buffered := true;
//  aa.CDS.CommandText := 'select min(demanddate) fdate,max(demanddate) tdate from demand';
//  aa.open;
//  if not aa.CDS.IsEmpty then begin
//    fdate := strtodatetime(aa.CDS.fieldbyname('fdate').asString);
//    tdate := strtodatetime(aa.CDS.fieldbyname('tdate').asString);
//  end;
//  aa.close;
//  aa.Free;
//  MRP := TMRPRun.Create;
//  MRP.dbm := axp.dbm;
//  MRP.axp := axp;
//  if trim(sdate) = '' then
//    MRP.StartDate := fdate
//  else
//    MRP.StartDate := strtodatetime(Sdate);
//  if trim(edate) = '' then
//    MRP.EndDate := tdate
//  else
//  MRP.EndDate := strtodatetime(Edate);
//  mrp.SetProgress := SetProgress;
//  try
//    MRP.RunMRP;
//    mrp.Destroy;
//
//  except on e:Exception do
//    begin
//      if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\DoMRP - '+e.Message);
//      mrp.Destroy;
//    end;
//  end;
//end;
//
//procedure TEVal.PostToTable(TableName, SearchFields, NoAppendStr:String);
//begin
//  axp.dbm.gf.doDebug.Msg('   PosttoTable Table Name : ' +  TableName);
//  axp.dbm.gf.doDebug.Msg('   PosttoTable SearchFields : ' +  SearchFields);
//  axp.dbm.gf.doDebug.Msg('   PosttoTable NoAppendStr : ' +  NoAppendStr);
//  TableName := lowercase(trim(tablename));
//  registervar(tablename+'_id', 'c', SearchFields);
//  InitCopyToTable(TableName);
//  NoAppend := NoAppendStr;
//  CopyToTable(TableName, 0);
//end;
//
//procedure TEVal.InitCopyToTable(CTableNames:String);
//var i,k,p:integer;
//    c, CopyTableName, CopyRecordId : String;
//begin
//  if CTableNames = '' then exit;
//  p := 1;
//  while true do begin
//    CopyTableName := trim(axp.dbm.gf.Getnthstring(CTableNames,p));
//    if CopyTableName = '' then break;
//    CopyRecordId := GetVarValue(CopyTableName+'_ID');
//    CopyTable := GetCopyTable(CopyTableName);
//    CopyTable.buffered := True;
//    if CopyTable.CDS.CommandText <> '' then break;
//    CopyRecordIds.Add(CopyRecordId);
//    CopyTable.CDS.CommandText := 'SELECT * FROM '+UpperCase(CopyTableName);
//    if CopyRecordId = '' then begin
//      CopyTable.CDS.CommandText := CopyTable.CDS.CommandText + ' WHERE '+CopyTableName + 'ID = 0';
//    end else begin
//       k := 1;
//       CopyTable.CDS.CommandText := CopyTable.CDS.CommandText + ' WHERE ';
//       while true do begin
//         c := trim(axp.dbm.gf.getnthstring(CopyRecordId, k));
//         if c = '' then break;
//        // i := GetColNo(c);
//        // if i = -1 then
//        //   Raise EDatabaseError.Create(c+' defined in CopyRecordId is improper');
//         if k > 1 then CopyTable.CDS.CommandText := CopyTable.CDS.CommandText + ' AND ';
//         CopyTable.CDS.CommandText := CopyTable.CDS.CommandText + UpperCase(c) + ' = :v'+inttostr(k);
//         inc(k);
//       end;
//    end;
//    inc(p);
//  end;
//end;
//
//procedure TEVal.CopyToTable(CTableNames:String;CallRow:integer);
//var i,k,p,n:integer;
//    s,c, CopyTableName, CopyRecordId, wstr:String;
//begin
////  if pos('[v]',fStringGrid.cells[fStringGrid.colcount-1, CallRow]) = 0 then exit;
//
//  p := 1;
//  while true do begin
//    k := 1;
//    CopyTableName := trim(axp.dbm.gf.GetNthString(CTableNames,p));
//    if CopyTableName = '' then break;
//    CopyRecordId := CopyRecordIds[p-1];
//    CopyTable := GetCopytable(Copytablename);
//    CopyPost := axp.dbm.GetXDS(copypost);
//    CopyPost.buffered := True;
//    s := copytable.CDS.CommandText;
//    n := pos(' WHERE ', s);
//    if n>0 then
//      wstr := copy(copytable.CDS.CommandText, p+8, 5000);
//    while true do begin
//      c := trim(axp.dbm.gf.getnthstring(CopyRecordId, k));
//      if c = '' then break;
////      i :=  getcolno(c);
////      s := parser.getvarvalue(colnames[i-1]);
//      s := getvarvalue(c);
//      Copytable.AssignParam(k-1, s, 'c');
//      if LastVarType='c' then s:=quotedstr(s)
//      else if LastVarType='d' then s:=datetimetostr(axp.dbm.GetServerDateTime);
//      wstr := findandreplace(wstr, ':v'+inttostr(k), s);
//      inc(k)
//    end;
//
//    CopyTable.Open;
//    if CopyTable.CDS.IsEmpty then begin
//      if (p <= length(NoAppend)) and (NoAppend[p]='T') then begin
//        CopyTable.Close;
//        inc(p);
//        Continue;
//      end;
//      CopyPost.Append(copytablename);
//      axp.dbm.gf.doDebug.Msg('   Append Table : ' + copytablename);
//      for i:=0 to CopyTable.CDS.Fields.Count-1 do begin
//        if (CopyTable.CDS.Fields[i].DataType = ftInteger) or (CopyTable.CDS.Fields[i].Datatype = ftFloat) then
//          CopyTable.CDS.Fields[i].AsFloat := 0;
//      end;
//      CopyPost.Submit(Copytablename+'id', floattostr(axp.dbm.Gen_id(axp.dbm.Connection)),'n');
//    end else
//    begin
//      n := pos(' WHERE ',wstr);
//      if n > 0 then  wstr := copy(wstr,n+7,length(wstr)- n+7);
//      CopyPost.Edit(CopyTableName, wstr);
//    end;
//    {
//    for i := 0 to CopyTable.CDS.Fields.Count-1 do begin
//      c := lowercase(copytable.CDS.fields[i].fieldname);
//      k := Colnames.indexof(c);
//      s := parser.getvarvalue(c);
//      if (s <> '') or (k <> -1) then begin
//        if ColTypes[k+1] = 'N' then s := RemoveCommas(s);
//        if coltypes[k+1]='D' then begin
//          CopyPost.Submit(c,s,'d')
//        end else
//          CopyPost.Submit(c,s,'c');
//      end;
//    end;
//    }
//    for i := 0 to CopyTable.CDS.Fields.Count-1 do begin
//      c := lowercase(copytable.CDS.fields[i].fieldname);
//      s := getvarvalue(c);
//      if (LastVarType<>'') then begin
//        if LastVarType = 'n' then s := axp.dbm.gf.RemoveCommas(s);
//        if LastVarType='d' then begin
//          CopyPost.Submit(c,s,'d')
//        end else
//          CopyPost.Submit(c,s,'c');
//      end;
//    end;
//    CopyPost.Post;
//    if lowercase(copy(CopyTable.CDS.CommandText,1,6)) <> 'select' then begin
//      CopyTable.close;
//      CopyTable.destroy;
//      CopyTable := nil;
//    end;
//    inc(p);
//  end;
//end;
//
//function TEVal.GetCopyTable(S:String):TXDS;
//var i:integer;
//begin
//  result := nil;
//  for i:=0 to copytables.count-1 do begin
//    if txds(copytables[i]).name = s then begin
//      result := txds(copytables[i]);
//      break;
//    end;
//  end;
//  if not assigned(result) then begin
//    result := axp.dbm.getxds(nil);
//    result.name := s;
//    copytables.Add(result);
//  end;
//end;
//
//function TEVal.verifyTree(TreeName : String):String;
//var t1 : Txds;
//TMCount,MCount,TGCount,GCount,TCount,L1Count,L2Count :integer;
//tabname : String;
//begin
//  axp.dbm.gf.Dodebug.Msg('   >> Executing verifytree');
//  tabname := Treename+'tree';
//  t1 := Txds.create('t1',nil,axp.dbm.Connection,axp.dbm.gf);
//  t1.buffered := true;
//  t1.CDS.CommandText := 'select count(*) MCount from master';
//  t1.open;
//  MCount := t1.CDS.FieldByName('MCount').AsInteger;
//  t1.close;
//  t1.CDS.CommandText := 'select count(*) TMCount from master m,'+tabname+' t where m.masterid=t.recordid';
//  t1.open;
//  TMCount := t1.CDS.FieldByName('TMCount').AsInteger;
//  t1.close;
//  if MCount <> TMCount then begin
//    Result := 'mismatch in account count';
//    t1.free;
//    exit;
//  end;
//  t1.CDS.CommandText := 'select count(*) GCount from acgpmaster';
//  t1.open;
//  GCount := t1.CDS.FieldByName('GCount').AsInteger;
//  t1.close;
//  t1.CDS.CommandText := 'select count(*) TGCount from acgpmaster a,'+tabname+' t where a.acgpmasterid=t.recordid';
//  t1.open;
//  TGCount := t1.CDS.FieldByName('TGCount').AsInteger;
//  t1.close;
//  if GCount <> TGCount then begin
//    Result := 'mismatch in group count';
//    t1.free;
//    exit;
//  end;
//  t1.CDS.CommandText := 'select count(*) cnt from '+tabname+' where transid is null';
//  t1.open;
//  TCount := t1.CDS.fieldbyname('cnt').AsInteger;
//  t1.close;
//  if TCount > 0 then begin
//    result := 'transid is improper in tree';
//    t1.Free;
//    exit;
//  end;
//  t1.CDS.CommandText := 'select sum(treelevel-1) cnt from '+tabname;
//  t1.open;
//  L1Count := t1.CDS.FieldByName('cnt').AsInteger;
//  t1.close;
//  t1.CDS.CommandText := 'select count(*) cnt from '+tabname+'link';
//  t1.open;
//  L2Count := t1.CDS.FieldByName('cnt').AsInteger;
//  t1.close;
//  if L1Count <> L2Count then begin
//    t1.Free;
//    result := 'Treelink is not proper';
//    exit;
//  end;
//  t1.Free;
//  Result :='';
//end;
//{
//procedure TEval.BuildTreeLink(TreeName : String);
//var TreeObj : TTreeObj;
//begin
//  TreeObj := TTreeObj.Create;
//  TreeObj.DBM := axp.dbm;
//  TreeObj.axp := axp;
//  TreeObj.TreeTable := Treename+'tree';
//  TreeObj.TreeLink := Treename+'treelink';
//  TreeObj.FixTreeLink;
//  TreeObj.Destroy;
//  TreeObj := nil;
//end;
//}
//function TEval.SaveSqlResult(sqltext,filename,delimitchar:String) : String;
//var x : TXDS;
//    i : integer;
//    ptype,pval,s : String;
//    sfile : TStringList;
//begin
//  result := '';
//  sfile := TStringlist.create;
//  if trim(delimitchar) = ''  then delimitchar := ',' ;
//  if copy(delimitchar,1,1) = '''' then delimitchar := copy(delimitchar,2,1);
//  axp.dbm.gf.DoDebug.msg('   >>Executing SaveSqlResult');
//  x := axp.dbm.GetXDS(nil);
//  x.buffered := True;
//  x.CDS.CommandText := sqltext;
//  if x.CDS.Params.Count > 0 then
//  begin
//    for i := 0 to x.CDS.Params.Count-1 do
//    begin
//      pval := GetVarValue(x.CDS.Params[i].Name);
//      ptype := lastvartype;
//      x.AssignParam(i,pval,ptype);
//    end;
//  end;
//  axp.dbm.gf.DoDebug.msg('   Executing query '+ sqltext);
//  try
//     x.Open ;
//     if (x.CDS.IsEmpty )then
//     begin
//        raise exception.Create('No data to export...');
//        exit;
//     end;
//    while not x.CDS.Eof do
//    begin
//      s := '';
//      for i := 0 to x.CDS.FieldCount - 1 do
//      begin
//        s := s + x.CDS.Fields[i].AsString + delimitchar;
//      end ;
//      delete(s,length(s),2);
//      sfile.Add(s);
//      x.CDS.Next;
//    end;
//  except
//    on e:exception do begin
//      if assigned(AxP) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\SaveSqlResult - '+e.Message);
//      axp.dbm.gf.DoDebug.msg('   ' + e.Message);
//      result := e.Message;
//      x.close;
//      x.Free;
//      sfile.Free;
//      exit;
//    end;
//  end;
//  s := extractfilename(fileName);
//  if axp.dbm.gf.isservice then
//  begin
//     filename := GetCurrentDir + '\Axpert\' + axp.dbm.gf.SessionId + '\' + s;
//     axp.dbm.gf.SessionId := '~'+ filename ;
//  end;
//  sfile.SaveToFile(filename);
//  x.free;
//  sfile.Free;
//end;

function TEVal.Isnumeral(s:String):boolean;
var i:integer;
begin
  result:=true;
  for I := 1 to length(s) do begin
    if not (s[i] in numbers) then begin
      result:=false;
      break;
    end;
  end;
end;
//
//procedure TEVal.SetDeps(TblName: String);
//var tQry : TXDS;
//    dlist,deps,elist : TStringList;
//    sExpr,vname,dval,fval : String;
//    i,ind,j : Integer;
//begin
//  tQry := axp.dbm.GetXDS(nil);
//  tQry.buffered := True;
//  tQry.CDS.CommandText := 'select varname,expr,deps,dirty from '+tblname+' where '+axp.dbm.gf.sqllower+'(dirty) = ''t''';
//  tQry.open;
//  if tQry.CDS.RecordCount = 0 then begin
//    tQry.close;
//    tQry.Free;
//    exit;
//  end;
//  tQry.CDS.First;
//  dlist := TStringList.Create;
//  elist := TStringList.Create;
//  deps := TStringList.Create;
//  while not tQry.CDS.Eof do begin
//    vname := tQry.CDS.FieldByName('varname').AsString;
//    registervar(vname, 'n', '0');
//    ind := dlist.IndexOfName(vname);
//    if ind < 0 then
//      dlist.Add(vname+'=,');
//    if Trim(tQry.CDS.FieldByName('expr').AsString) <> '' then begin
//      ind := elist.IndexOfName(vname);
//      if ind < 0 then
//        elist.Add(vname+'='+tQry.CDS.FieldByName('expr').AsString);
//    end;
//    tQry.CDS.Next;
//  end;
//  tQry.CDS.First;
//  while not tQry.CDS.Eof do begin
//    if Trim(tQry.CDS.FieldByName('expr').AsString) <> '' then begin
//      vname := tQry.CDS.FieldByName('varname').AsString;
//      deps.Clear;
//      deps.Add(vname);
//      i := 0;
//      while True do begin
//        ind := elist.IndexOfName(deps[i]);
//        if ind > -1 then begin
//          sExpr := elist.ValueFromIndex[ind];
//          VarsUsed.clear;
//          Evaluate(sExpr);
//          for j := 0 to VarsUsed.Count - 1 do begin
//            dval := '';
//            ind := dlist.IndexOfName(VarsUsed[j]);
//            if ind > -1 then
//              dval := dlist.ValueFromIndex[ind];
//            if pos(','+lowercase(vname)+',',lowercase(dval)) = 0 then begin
//              dval := dval+vname+',';
//              dlist.ValueFromIndex[ind] := dval;
//            end;
//            if deps.IndexOf(VarsUsed[j]) = -1 then
//              deps.Add(VarsUsed[j]);
//          end;
//        end;
//        inc(i);
//        if i = deps.Count then break;
//      end;
//    end;
//    tQry.CDS.Next;
//  end;
//  try
//    for i := 0 to dlist.Count - 1 do begin
//      dval := dlist.ValueFromIndex[i];
//      if dval <> '' then begin
//        fval := dlist.Names[i];
//        if copy(dval,1,1) = ',' then delete(dval,1,1);
//        if copy(dval,Length(dval),1) = ',' then delete(dval,Length(dval),1);
//        tQry.close;
//        tQry.CDS.CommandText := 'update '+tblname+' set deps = '+quotedstr(dval)+
//            ', dirty = ''f'' where varname = '+quotedstr(fval)+' and '+axp.dbm.gf.sqllower+'(dirty)= ''t''';
//        if axp.dbm.gf.RemoteLogin then
//          tQry.open
//        else
//          tQry.execsql;
//      end;
//    end;
//  except
//    on e:exception do begin
//      if assigned(axp) then begin
//        AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\SetDeps - '+e.Message);
//        axp.dbm.gf.DoDebug.msg('   ' + e.Message);
//      end;
//      dlist.free;elist.Free;deps.Free;
//      tQry.close;tQry.Free;
//      exit;
//    end;
//  end;
//  dlist.free;elist.Free;deps.Free;
//  tQry.close;tQry.Free;
//end;
//
//function TEVal.doStoredProc(name, invars, outvars: String): String;
//  var sp : TXDS;
//  s,s1,s2 : String;
//  i : integer;
//begin
//  axp.dbm.gf.Dodebug.Msg('   Starting doStoreProc');
//  result := 'false';
//  axp.dbm.gf.Dodebug.Msg('   Proc Name : ' + name);
//  sp:=nil;
//  try
//  while true do
//  begin
//    if copy(invars,1,1) = '''' then
//    begin
//      delete(invars,1,1);
//      if invars = '' then break;
//      if copy(invars,1,pos('''',invars)-1) <> '' then
//      begin
//         s1 := copy(invars,1,pos('''',invars)-1);
//         delete(invars,1,pos('''',invars));
//      end else begin
//         s1 := invars;
//         invars := '';
//      end;
//      s := s + s1 + '~' ;
//    end else
//    begin
//      if copy(invars,1,1) = ',' then delete(invars,1,1);
//      if invars = '' then break;
//      if copy(invars,1,pos(',',invars)-1) <> '' then
//      begin
//         s1 := copy(invars,1,pos(',',invars)-1);
//         delete(invars,1,pos(',',invars));
//      end else begin
//         s1 := invars;
//         invars := '';
//      end;
//      s1 := GetVarValue(s1);
//      if LastVarType = 'c' then
//         s := s + s1 + '~'
//      else s := s + s1 + '~';
//    end;
//    if invars = '' then break;
//  end;
//  s := trim(s);
//  sp := TXds.Create('sp',Nil,axp.dbm.Connection,axp.dbm.gf);
//  s := sp.StoredProcExec(name, s , outvars);
//  i := 1;
//  if s <> '' then
//  begin
//    while true do
//    begin
//      s1 := axp.dbm.gf.GetnthString(s,i,'~');
//      if s1 = '' then break;
//      s2 := s1;
//      s1 := copy(s1,1,pos('=',s1)-1);
//      delete(s2,1,pos('=',s2)) ;
//      RegisterVar(s1,'c',s2);
//      i := i + 1;
//    end;
//  end;
//  except on e:exception do
//    begin
//       if assigned(AxP) then begin
//         AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\doStoredProc - '+e.Message);
//         axp.dbm.gf.Dodebug.Msg('   Error Message : ' + e.Message);
//       end;
//    end;
//  end;
//  if assigned(sp) then
//    sp.destroy;
//  sp := nil;
//end;
//
//procedure TEval.ExportSQL(SQLText, FormatString, FileName , Delimiter : string; withheader : String = 'f');
//Var i , l , k : integer;
//    Query:TXDS;
//    fs,fstmp : TStringList;
//    s,v,pvalue,ExportPath : string;
//    f : TextFile;
//begin
//  Query := nil;
//  ExportPath := '';
//  sqltext := Trim(sqltext);
//  Query := axp.dbm.GetXDS(Query);
//  Query.buffered := true;
//  Query.CDS.CommandText:=sqltext;
//  ReplaceParams(Query);
//  Query.Open ;
//  if Query.CDS.IsEmpty then
//  begin
//    query.close;
//    FreeAndNil(query);
//    exit;
//  end;
//  filename := trim(filename);
//  if copy(filename,1,1) = ':' then
//  begin
//    delete(filename,1,1);
//    filename := GetVarValue(filename);
//    firstcall := true;
//  end;
//  ExportPath := ExtractFilePath(filename);
//  if (ExportPath <> '') then
//     filename := ExtractFileName(filename);
//  ExpSqlFileName := FileName;
//  if pos(',',Delimiter) > 0 then Delimiter := ',';
//  if ExportPath <> '' then begin
//     if not DirectoryExists(ExportPath) then
//        CreateDir(ExportPath);
//     FileName := ExportPath+FileName;
//  end
//  else begin
//    if axp.dbm.gf.IsService then
//      filename := axp.dbm.gf.startpath+'\'+filename
//    else begin
//       if not DirectoryExists(axp.dbm.gf.StartPath + 'DataFiles') then
//          CreateDir(axp.dbm.gf.StartPath + 'DataFiles');
//       filename := axp.dbm.gf.StartPath + 'DataFiles\'+ filename;
//    end;
//  end;
//  AssignFile(f, filename);
//  if firstCall then
//  begin
//     if (fileexists(filename)) then deletefile(filename);
//     rewrite(f);
//     firstcall := false;
//  end else Append(f);
//  FormatString := lowercase(FormatString);
//  fs := TStringList.Create;
//  fstmp := TStringList.Create;
//  i := 1;
//  while True do
//  begin
//    s := trim(axp.dbm.gf.GetnthString(FormatString,i));
//    if s = '' then break;
//    l := length(s);
//    v := trim(copy(s,LastDelimiter('~',s)+1,l));
//    delete(s,LastDelimiter('~',s),l);
//    fs.Add(s + '=' +v);
//    fstmp.Add(s);
//    i := i + 1;
//  end;
//  withheader := lowercase(withheader);
//  if (withheader = 't') or (withheader = 'true') then begin
//    for i:=0 to Query.CDS.FieldCount-1 do begin
//      if fstmp.IndexOf(lowercase(Query.CDS.Fields[i].FieldName)) = -1 then continue;
//      if pvalue = '' then
//         pvalue := Query.CDS.Fields[i].FieldName
//      else
//         pvalue := pvalue + Delimiter + Query.CDS.Fields[i].FieldName;
//    end;
//      WriteLn(f, pValue);
//  end;
//  Query.CDS.First;
//  while not Query.CDS.Eof do begin
//    value := '';
//    for i:=0 to Query.CDS.FieldCount-1 do begin
//      l := fstmp.IndexOf(lowercase(Query.CDS.Fields[i].FieldName));
//      k := l;
//      if l = -1 then continue;
//      s := Query.CDS.Fields[i].AsString;
//      s := trim(s);
//      v := fs.Values[fs.Names[k]];
//      if copy(v,1,1) = 'n' then
//      begin
//        delete(v,1,1);
//        if s <> '' then
//        begin
//          if pos('.',v) > 0  then
//          begin
//            k := strtoint(copy(v,1,pos('.',v)-1));
//            delete(v,1,pos('.',v));
//            l := strtoint(v);
//            s := axp.dbm.gf.FormatValue(s,l);
//            if length(s) < k then s := axp.dbm.gf.LeftPad(s,k,' ');
//          end else begin
//            k := strtoint(v);
//            if length(s) < k then s := axp.dbm.gf.LeftPad(s,k,' ');
//          end;
//        end else begin
//          s := ' ';
//          k := strtoint(v);
//          s := axp.dbm.gf.LeftPad(s,k,' ');
//        end;
//      end else if copy(v,1,1) = 'c' then
//      begin
//        if s = '' then s:= ' ';
//        delete(v,1,1);
//        k := strtoint(v);
//        if length(s) < k then s := axp.dbm.gf.Pad(s,k,' ');
//      end else if copy(v,1,1) = 'd' then
//      begin
//        delete(v,1,1);
//        k := length(v);
//        if s <> '' then
//        begin
//          s := formatdatetime(axp.dbm.gf.ShortDateFormat.ShortDateFormat,strtodate(s));
//          s := formatdatetime(v,strtodate(s));
//        end
//        else s := axp.dbm.gf.Pad(s,k,' ');
//      end;
//      value := value + s + Delimiter ;
//    end;
//      Delete(value,length(value),1);   //Added delete func to delete comma at the end of every row
//      WriteLn(f, Value) ;
//    Query.CDS.next;
//  end;
//  CloseFile(f);
//  query.close;
//  FreeAndNil(query);
//  FreeAndNil(fs);
//  FreeAndNil(fstmp);
//end;
//
//procedure TEval.AutoGenPost(arec:pAutoGenRec; axp:TAxProvider);
//var sql, wstr, Val : String;
//begin
//  autorec := arec;
//  ModTable := Axp.dbm.GetXDS(ModTable);
//  Modtable.Edit(arec.Schema+arec.TableName,arec.TableName+'id='+FloatToStr(arec.RecordId));
//  if arec.RType = 'auto' then
//  begin
//    Val := GetLastNo(arec,axp);
//  end else
//  begin
//    Val := GetParentValue(arec,axp);
//  end;
//  arec.Value := Val;
//  Modtable.Submit(arec.FieldName,Val,'c');
//  ModTable.Post;
//end;
//
//function TEval.GetLastNo(arec : pAutoGenRec; axp:TAxprovider):String;
//var i,j,digits:integer;
//    lastno, wstr, sql, fieldname, dstr : String;
//    xdoc : ixmldocument;
//    n,dnode : ixmlnode;
//
////    CompName,lastno, Transid, wstr, sql,dstr,sval,prefix,prefixfield,s : String;
//begin
//  fieldname := lowercase(arec.FieldName);
//  result := '';
//  if (axp.dbm.Connection.DbType = 'ms sql') then
//     sql:='Select * FROM '+uppercase(arec.Schema)+'SEQUENCE ' + axp.dbm.gf.forupdate + ' WHERE '+axp.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(arec.Transid))+' and '+axp.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(fieldname))
//  else
//     sql:='Select * FROM '+uppercase(arec.Schema)+'SEQUENCE WHERE '+axp.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(arec.Transid))+' and '+axp.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(fieldname));
//  wstr := axp.dbm.gf.sqllower+'(TRANSTYPE) = '+lowercase(quotedstr(arec.Transid))+' and '+axp.dbm.gf.sqllower+'(FIELDNAME) = '+lowercase(quotedstr(fieldname))+ ' ';
//  if arec.Active then begin
//    SQl := sql + ' and ACTIVESEQUENCE = ''T''';
//    wstr := wstr + ' and ACTIVESEQUENCE = ''T''';
//  end else begin
//    SQl := sql + ' and '+ axp.dbm.gf.sqllower+'(prefix) ='+lowercase(quotedstr(arec.prefix));
//    wstr := wstr + ' and '+ axp.dbm.gf.sqllower+'(prefix) ='+lowercase(quotedstr(arec.prefix));
//  end;
//  QSeq := axp.dbm.GetXDS(QSeq);
//  Qseq.buffered := True;
//  Qseq.CDS.CommandText := sql;
//  Qseq.open;
//
//  if (axp.dbm.Connection.dbtype<>'access') then begin
//    QLockSeq := axp.dbm.GetXDS(QLockSeq);
//    QLockSeq.buffered := True;
//    if axp.dbm.Connection.DbType = 'ms sql' then
//       QLockSeq.CDS.CommandText := sql
//    else QLockSeq.CDS.CommandText := sql+ axp.dbm.gf.forupdate;
//    QLockSeq.open;
//  end;
//  if (axp.dbm.connection.dbtype<>'access') then begin
//    if axp.dbm.Connection.DbType = 'ms sql' then
//       axp.ExecSQL(sql, '', '', false)
//    else axp.ExecSQL(sql+axp.dbm.gf.forupdate, '', '', false);
//  end;
//
//  if QSeq.CDS.RecordCount > 0 then begin
//    lastno := QSeq.CDS.FieldByName('lastno').AsString;
//    digits := QSeq.CDS.FieldByName('noofdigits').AsInteger;
//    dstr := '';
//    for j := 0 to digits-1 do
//      dstr := dstr+'0';
//    if arec.PrefixField <> '' then begin
//      result := GetPrefixFieldValue(arec,axp);
//      if (axp.dbm.connection.dbtype<>'access') then QLockSeq.Close;
//      Qseq.Close;
//      exit;
//    end else
//      result := arec.prefix + copy(dstr, 1, (digits - length(lastno))) + lastno;
//    axp.ExecSQL('update '+arec.Schema+'sequence set lastno = '+inttostr(strtoint(lastno) + 1)+' where '+wstr,'','',false);
//  end;
//  if (axp.dbm.connection.dbtype<>'access') then QLockSeq.Close;
//  Qseq.close;
//end;
//
//function TEval.GetPrefixFieldValue(arec:pAutoGenRec; axp:TAxProvider):String;
//var j,digits :Integer;
//    pval,sql,wstr,dstr,s,lastno,fval : String;
//    id : Extended;
//    GetVal : Boolean;
//    xdoc : ixmldocument;
//    n,pnode,dnode : ixmlnode;
//begin
//  result := '';
//  pval := arec.Prefix;
//  sql:='Select * FROM '+uppercase(arec.Schema)+'SEQUENCE WHERE '+axp.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(arec.Transid))+
//       ' and '+axp.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(arec.FieldName))+
//       ' and '+axp.dbm.gf.sqllower+'(prefix)='+lowercase(quotedstr(pval));
//  wstr := axp.dbm.gf.sqllower+'(TRANSTYPE) = '+lowercase(quotedstr(arec.Transid))+' and '+
//          axp.dbm.gf.sqllower+'(FIELDNAME) = '+lowercase(quotedstr(arec.fieldname))+
//         ' and '+axp.dbm.gf.sqllower+'(prefix)='+lowercase(quotedstr(pval));
//  qseq.close;
//  qseq.buffered := True;
//  qseq.CDS.CommandText := sql;
//  qseq.open;
//  if qseq.CDS.RecordCount = 0 then begin
//    s := axp.dbm.gf.getnthstring(arec.PrefixField,2);
//    if s <> '' then
//      lastno := s
//    else
//      lastno := '1';
//    s := axp.dbm.gf.getnthstring(arec.PrefixField,3);
//    if s <> '' then
//      digits := StrToInt(s);
//    qseq.close;
//    id := axp.dbm.Gen_id(axp.dbm.Connect.Connection);
//    s := 'insert into '+uppercase(arec.Schema)+'SEQUENCE(sequenceid, prefix,transtype,fieldname,activesequence,'+
//     'description,prefixfield,lastno,noofdigits) values(';
//    s := s+FloatToStr(id)+',';
//    s := s+Quotedstr(pval)+',';
//    s := s+Quotedstr(arec.Transid)+',';
//    s := s+QuotedStr(arec.fieldname)+',';
//    s := s+QuotedStr('F')+',';
//    s := s+QuotedStr('~dynamic prefix')+',';
//    s := s+quotedstr('''')+',';
//    s := s+inttostr(Strtoint(LastNo)+1)+',';
//    s := s+IntToStr(digits)+')';
//    qseq.close;
//    qseq.cds.CommandText := s;
//    try
//      if axp.dbm.gf.remotelogin then
//        qseq.open
//      else
//        qseq.CDS.Execute;
//      GetVal := False;
//    except
//      On E:Exception do begin
//        if assigned(axp) then AxP.dbm.gf.DoDebug.Log(AxP.dbm.gf.Axp_logstr+'\uParse\GetPrefixFieldValue - '+e.Message);
//        if pos('unique',lowercase(e.Message))>0 then
//          GetVal := True
//        else
//          Raise Exception.Create(E.Message);
//      end;
//    end;
//  end else
//    GetVal := True;
//
//  if GetVal then begin
//    if axp.dbm.Connection.DbType = 'ms sql' then
//      sql:='Select * FROM '+uppercase(arec.Schema)+'SEQUENCE WHERE '+axp.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(arec.Transid))+
//        ' and '+axp.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(arec.fieldname))+
//        ' and '+axp.dbm.gf.sqllower+'(prefix)='+lowercase(quotedstr(pval))
//    else
//      sql:='Select * FROM '+uppercase(arec.Schema)+'SEQUENCE WHERE '+axp.dbm.gf.sqllower+'(TRANSTYPE)='+lowercase(Quotedstr(arec.Transid))+
//        ' and '+axp.dbm.gf.sqllower+'(FIELDNAME)='+lowercase(quotedstr(arec.fieldname))+
//        ' and '+axp.dbm.gf.sqllower+'(prefix)='+lowercase(quotedstr(pval)) ;
//
//    xdoc:=axp.GetOneRecord(sql,'','');
//    n:=xdoc.DocumentElement;
//    if (axp.dbm.connection.dbtype<>'access') then begin
//      QLockSeq.close;
//      QLockSeq.buffered := True;
//    if axp.dbm.Connection.DbType = 'ms sql' then
//      QLockSeq.CDS.CommandText := sql
//    else QLockSeq.CDS.CommandText := sql+ axp.dbm.gf.forupdate;
//      QLockSeq.open;
//    end;
//    if (axp.dbm.connection.dbtype<>'access') then begin
//      if axp.dbm.Connection.DbType = 'ms sql' then
//        axp.ExecSQL(sql, '', '', false)
//      else axp.ExecSQL(sql+axp.dbm.gf.forupdate, '', '', false);
//    end;
//    if n.ChildNodes.count > 0 then begin
//      n:=n.childnodes[0];
//      lastno := vartostr(axp.dbm.gf.FindNode(n,'LASTNO').NodeValue);
//      dnode := axp.dbm.gf.FindNode(n,'NOOFDIGITS');
//      if (assigned(dnode)) and (vartostr(dnode.NodeValue) <> '') then
//        digits := StrToInt(vartostr(dnode.NodeValue));
//      pval := arec.prefix;
//    end else
//      pval := '';
//  end;
//  if pval <> '' then begin
//    dstr := '';
//    for j := 0 to digits-1 do
//      dstr := dstr+'0';
//    result := pval + copy(dstr, 1, (digits - length(lastno))) + lastno;
//    if (GetVal) then begin
//      axp.ExecSQL('update '+arec.Schema+'sequence set lastno = '+inttostr(strtoint(lastno) + 1)+' where '+wstr,'','',false);
//      if (axp.dbm.connection.dbtype<>'access') then QLockSeq.Close;
//    end;
//  end;
//end;
//
//Function TEval.GetParentValue(arec:pAutoGenRec;axp:TAxprovider):String;
//var i : integer;
//    parec : pAutoGenRec;
//begin
//  for i := 0 to axp.dbm.gf.AutoGenData.Count - 1 do
//  begin
//    parec := pAutoGenRec(axp.dbm.gf.AutoGenData[i]);
//    if (parec.Transid = arec.ParentTransid) and (parec.FieldName = arec.ParentFldName) then
//    begin
//      result := parec.Value;
//      break;
//    end;
//  end;
//end;

function TEVAL.AxMemLoad(sFnName, sParamVars: String): String;
begin

end;

Function TEval.AxpCeil(pVal:Extended):Integer;
begin
  Result := Ceil(pVal);
end;

Function TEval.AxpFloor(pVal:Extended):Integer;
begin
  Result := Floor(pVal);
end;

Function TEval.Days360(StartDate, EndDate:TDatetime;Method:String = 'False'):Integer;
var TempMonths  : Integer;
    StartDay, EndDay, SMonth, EMonth, SYear, EYear : Word;
Begin
  result := 0;
  Method := lowercase(Method);
  DecodeDate(StartDate,SYear,SMonth,StartDay);
  DecodeDate(EndDate,EYear,EMonth,EndDay);
  If (Method = 't') or (Method='true') Then
  begin
    If StartDay > 30 Then
      StartDate := Incday(StartDate, -1);
    If EndDay > 30 Then
      EndDate := Incday(EndDate, -1)
  End Else begin
    If StartDay > 30 Then
      StartDate := Incday(StartDate, -1);
    If (EndDay = 31) And (StartDay >= 30) Then
       EndDate := Incday(EndDate, -1);
  End;
  DecodeDate(StartDate,SYear,SMonth,StartDay);
  DecodeDate(EndDate,EYear,EMonth,EndDay);
  TempMonths := ((EYear - SYear) * 12) + (EMonth - SMonth);
  result := (TempMonths * 30) + (EndDay - StartDay);
End;

Function TEval.NetWorkDays(StartDate, EndDate:TDatetime;Holidays: Integer;Method:String = 'False'):Integer;
var Sun, Sat : Integer;
begin
  result := 0;
  Method := lowercase(method);
  if  (Method = 't') or (Method = 'true') then
  begin
    Sun := 7;
    Sat := 6;
    while StartDate <= EndDate do
    begin
      if (DayofTheWeek(StartDate) <> Sun) and (DayofTheWeek(StartDate) <> Sat) then
        Inc(result);
      StartDate := IncDay(StartDate,1);
    end;
  end else
  begin
    Sun := 1;
    Sat := 7;
    while StartDate <= EndDate do
    begin
      if (DayofWeek(StartDate) <> Sun) and (DayofWeek(StartDate) <> Sat) then
        Inc(result);
      StartDate := IncDay(StartDate,1);
    end;
   end;
  result := result-Holidays;
end;
//
//procedure TEval.SQLRegVar(SQLText:String;Direct:String='False');
//var t,Paramname:string;
//    work : TXDS;
//    i,ind : integer;
//begin
//  if not assigned(axp.dbm) then exit;
//  work := nil;
//  ind := -1;
//  work := axp.dbm.GetXDS(work);
//  work.buffered := True;
//  work.CDS.CommandText := sqltext;
//  if CallFromGetDep = 'yes' then
//  begin
//    work.GetParamNames;
//    For i := 0 to work.CDS.Params.count-1 do
//    begin
//      Paramname := work.CDS.Params[i].Name;
//      if varsused.IndexOf(lowercase(Paramname)) = -1 then
//         varsused.Add(lowercase(Paramname));
//    end;
//  end;
//  ReplaceParams(work);
//  work.open;
//  Direct := lowercase(Direct);
//  if (Direct = 'true') or (Direct = 't') then
//  begin
//    while not work.cds.eof do begin
//      for i := 0 to work.cds.Fields.Count - 1 do
//      begin
//        t := lowercase(axp.dbm.gf.GetDataType(work.cds.fields[i].DataType));
//        if (t = 'image') then continue;
//        if (t = 'text') or (t = 'unknown') then t := 'character';
//        RegisterVar(work.cds.Fields[i].FieldName, Char(t[1]), work.cds.Fields[i].AsString);
//        ind := MemVarList.IndexOfName(work.cds.Fields[i].FieldName);
//        if ind >= 0 then
//        begin
//          MemVarList[ind] := work.cds.Fields[i].FieldName + '=' + work.cds.Fields[i].AsString;
//          MemTypeStr[ind+1] :=t[1];
//        end else
//        begin
//          MemVarList.Add(work.cds.Fields[i].FieldName+'='+work.cds.Fields[i].AsString);
//          MemTypeStr := MemTypeStr+t[1];
//        end;
//      end;
//      work.cds.next;
//    end;
//  end else
//  begin
//    if (assigned(work.cds.findfield('varname'))) and (assigned(work.cds.findfield('varvalue'))) and (assigned(work.cds.findfield('vartype')))then begin
//      work.CDS.first;
//      while not work.cds.eof do begin
//        t := work.cds.fieldbyname('vartype').asstring;
//        RegisterVar(work.cds.fieldbyname('varname').asstring, Char(t[1]), work.cds.fieldbyname('varvalue').asstring);
//        ind := MemVarList.IndexOfName(work.cds.fieldbyname('varname').asstring);
//        if ind >= 0 then
//        begin
//          MemVarList[ind] := work.cds.fieldbyname('varname').asstring + '=' + work.cds.fieldbyname('varvalue').asstring;
//          MemTypeStr[ind+1] :=t[1];
//        end else
//        begin
//          MemVarList.Add(work.cds.fieldbyname('varname').asstring+'='+work.cds.fieldbyname('varvalue').asstring);
//          MemTypeStr := MemTypeStr+t[1];
//        end;
//        work.cds.next;
//      end;
//    end;
//  end;
//  work.close;
//  work.Free;
//  work := nil;
//end;
//

//function TEVal.EncryptStr(Value : String): String;
//begin
//  if copy(Value,1,1) = ':' then
//  begin
//    delete(Value,1,1);
//    Value := GetVarValue(Value);
//  end;
//  Result := Encrypt(Value, Sym_key);
//end;
//
//function TEVal.DecryptStr(Value : String): String;
//begin
//  if copy(Value,1,1) = ':' then
//  begin
//    delete(Value,1,1);
//    Value := GetVarValue(Value);
//  end;
//  Result := Trim(Decrypt(Value, Sym_key));
//end;


Procedure TEVal.CreateFile(FileName,Data : String;OverWriteIfExists:string = 'false');
var
  ErrMsg , FilePath: String;
  f:textfile;
begin
  try
    ErrMsg := '';
    if copy(FileName,1,1) = ':' then
    begin
      delete(FileName,1,1);
      FileName := GetVarValue(FileName);
    end;
    if copy(Data,1,1) = ':' then
    begin
      delete(Data,1,1);
      Data := GetVarValue(Data);
    end;
    if copy(OverWriteIfExists,1,1) = ':' then
    begin
      delete(OverWriteIfExists,1,1);
      FileName := GetVarValue(OverWriteIfExists);
    end;
    FilePath := ExtractFilePath(FileName);
    if FilePath = '' then
    begin
      //FilePath := axp.dbm.gf.startpath;
      FileName := FilePath + FileName;
    end;
    if Not DirectoryExists(FilePath) then
       if Not ForceDirectories(FilePath) then RaiseLastOSError;
    //if FileExists(FileName) and axp.dbm.gf.IsFileInUse(FileName) then
      //raise Exception.Create(FileName+' File is being accessed by some other process.')
    //else
    begin
      Assignfile(f, FileName);
      if fileexists(FileName) then
      begin
        if Lowercase(OverWriteIfExists) = 'true' then rewrite(f)
        else append(f);
      end
      else rewrite(f);
      writeln(f, Data);
      closefile(f);
    end;
  Except
    on E:Exception do
      ErrMsg := E.Message;
  end;
//  if ErrMsg <> '' then
//  begin
//    axp.dbm.gf.dodebug.log('Error in CreateFile : '+ErrMsg);
//    axp.dbm.gf.dodebug.msg('Error in CreateFile : '+ErrMsg);
//  end;
end;


Procedure TEVal.RemoveFile(FileName : String);
var
  ErrMsg : String;
begin
  try
    ErrMsg := '';
    if copy(FileName,1,1) = ':' then
    begin
      delete(FileName,1,1);
      FileName := GetVarValue(FileName);
    end;
    if Not FileExists(FileName) then Exit;
    //if Not DeleteFile(pWdieChar(FileName)) then
      //RaiseLastOSError;
  Except
  on E:Exception do
    begin
      ErrMsg := E.Message;
      //axp.dbm.gf.dodebug.log('Error in RemoveFile : '+ErrMsg);
      if POS('Access is denied',ErrMsg) > 0 then
      begin
        //axp.dbm.gf.DeleteReadOnlyFile(FileName);
        ErrMsg := '';
      end;
    end;
  end;
  //if ErrMsg <> '' then
    // axp.dbm.gf.dodebug.msg('Error in RemoveFile : '+ErrMsg);
end;


Procedure TEVal.CloneFile(SourceFile , TargetFile : String;FailIfExists : string = 'false');
var
  ErrMsg : String;
  FilePath : String;
begin
  try
    if copy(SourceFile,1,1) = ':' then
    begin
      delete(SourceFile,1,1);
      SourceFile := GetVarValue(SourceFile);
    end;
    if copy(TargetFile,1,1) = ':' then
    begin
      delete(TargetFile,1,1);
      TargetFile := GetVarValue(TargetFile);
    end;
    if copy(FailIfExists,1,1) = ':' then
    begin
      delete(FailIfExists,1,1);
      FailIfExists := GetVarValue(FailIfExists);
    end;
    if (Not FileExists(SourceFile)) then
        Raise Exception.Create('Source file :' + SourceFile + ' deos not exits');
    FilePath := ExtractFilePath(TargetFile);
    if (FilePath <> '') and (Not DirectoryExists(FilePath)) then
       if Not ForceDirectories(FilePath) then RaiseLastOSError;
    if Length(TargetFile) > 255 then
      raise Exception.Create('The file name (filepath+filename) is larger than is supported by the file system.'+
           'It should have lesss than 255 characters.');
    //if not CopyFile(pChar(SourceFile),pChar(TargetFile),LowerCase(FailIfExists)='true') then
      //RaiseLastOSError;
  except  on E: Exception do
    ErrMsg := e.Message;
  end;
  if ErrMsg <> '' then
  begin
    //Axp.dbm.gf.DoDebug.Log('Error in CloneFile : '+ErrMsg);
    //Axp.dbm.gf.DoDebug.Msg('Error in CloneFile : '+ErrMsg);
  end;
end;


Procedure TEVal.CloneDir(SourceDir , TargetDir : String);
var
  ErrMsg : String;
begin
  ErrMsg := '';
  if copy(SourceDir,1,1) = ':' then
  begin
    delete(SourceDir,1,1);
    SourceDir := GetVarValue(SourceDir);
  end;
  if copy(TargetDir,1,1) = ':' then
  begin
    delete(TargetDir,1,1);
    TargetDir := GetVarValue(TargetDir);
  end;
  if AnsiLastChar(SourceDir) = '\' then Delete(SourceDir,Length(SourceDir),1);
  if AnsiLastChar(TargetDir) = '\' then Delete(TargetDir,Length(TargetDir),1);
  if Not DirectoryExists(SourceDir) then raise Exception.Create('Source directory does not found.');
  if Not DirectoryExists(TargetDir) then
      if Not ForceDirectories(TargetDir) then RaiseLastOSError;
  try
    //axp.CopyFiles(SourceDir,TargetDir);
  Except
    on E:Exception do
    begin
      ErrMsg := E.Message;
      if DirectoryExists(TargetDir) then
      //    axp.dbm.gf.DeleteFilesFromFolder(TargetDir+'\*.*');
    end;
  end;
  if ErrMsg <> '' then
  begin
   // Axp.dbm.gf.DoDebug.Log('Error in CloneDir : '+ErrMsg);
   // Axp.dbm.gf.DoDebug.Msg('Error in CloneDir : '+ErrMsg);
  end;
end;


Procedure TEVal.XCopyFile(SourceFile , TargetFile : String;FailIfExists : string = 'false');
var
  ErrMsg,FilePath : String;
  IsFileMoved : Boolean;
  ErrCode : Integer;
begin
  ErrMsg := '';
  if copy(SourceFile,1,1) = ':' then
  begin
    delete(SourceFile,1,1);
    SourceFile := GetVarValue(SourceFile);
  end;
  if copy(TargetFile,1,1) = ':' then
  begin
    delete(TargetFile,1,1);
    TargetFile := GetVarValue(TargetFile);
  end;
  if copy(FailIfExists,1,1) = ':' then
  begin
    delete(FailIfExists,1,1);
    FailIfExists := GetVarValue(FailIfExists);
  end;
  FilePath := ExtractFilePath(TargetFile);
  if (FilePath <> '') and (Not DirectoryExists(FilePath)) then
     if Not ForceDirectories(FilePath) then RaiseLastOSError;
  if FileExists(SourceFile) then
  begin
    try
      //if LowerCase(FailIfExists) = 'false' then
      //   IsFileMoved := MoveFileEx(PChar(SourceFile), PChar(TargetFile),MOVEFILE_REPLACE_EXISTING)
      //else
      //   IsFileMoved := MoveFile(PChar(SourceFile), PChar(TargetFile));
      //if (Not IsFileMoved) then
      //begin
      //   ErrCode := GetLastError;
      //   If (ErrCode <> 183) and (ErrCode <> NOERROR)  then
      //     raise Exception.Create(SysErrorMessage(ErrCode));
      //end;
    Except on E:Exception do
        ErrMsg :=  E.message;
    end;
  end
  else ErrMsg := 'Source file ('+SourceFile+') does not exists.';
  if ErrMsg <> '' then
  begin
   // Axp.dbm.gf.DoDebug.Log('Error in XCopy : '+ErrMsg);
   // Axp.dbm.gf.DoDebug.Msg('Error in XCopy : '+ErrMsg);
  end;
end;


Procedure TEVal.XCopyDir(SourceDir , TargetDir : String);
var
  ErrMsg : String;
  fRec : TSearchRec;
  IsFileMoved : Boolean;
begin
  ErrMsg := '';
  try
    if copy(SourceDir,1,1) = ':' then
    begin
      delete(SourceDir,1,1);
      SourceDir := GetVarValue(SourceDir);
    end;
    if copy(TargetDir,1,1) = ':' then
    begin
      delete(TargetDir,1,1);
      TargetDir := GetVarValue(TargetDir);
    end;
    if  (Not DirectoryExists(SourceDir)) or (SourceDir = '') then raise Exception.Create('SourceDir ('+SourceDir+') does not exist.');
    if (TargetDir = '') then raise Exception.Create('TargetDir ('+TargetDir+') does not exist.');
    if (Not DirectoryExists(TargetDir)) then
     if Not ForceDirectories(TargetDir) then RaiseLastOSError;
    if Not (AnsiLastChar(SourceDir) = '\') then SourceDir := SourceDir + '\';
    if Not (AnsiLastChar(TargetDir) = '\') then TargetDir := TargetDir + '\';
    if FindFirst(SourceDir+'*.*', faAnyFile, fRec) = 0 then
    repeat
      try
        if (fRec.name = '.') or (fRec.Name = '..') then continue;
        if Length(TargetDir+fRec.Name) > 255 then
           raise Exception.Create('The file name (filepath+filename) is larger than is supported by the file system.'+
               'It should have less than 255 characters.');
        //IsFileMoved := MoveFileEx(PChar(SourceDir+fRec.Name), PChar(TargetDir+fRec.Name),MOVEFILE_REPLACE_EXISTING);
        if Not IsFileMoved then
            RaiseLastOSError;
      Except on E:Exception do
        begin
          ErrMsg := E.message;
//          Axp.dbm.gf.dodebug.Msg(SourceDir+fRec.Name+' file is not Moved to '+TargetDir+fRec.Name);
        end;
      end;
      if ErrMsg <> '' then
      begin
     //   Axp.dbm.gf.dodebug.Msg('XCopyDir Error : '+ErrMsg);
     //   Axp.dbm.gf.dodebug.Log('XCopyDir Error : '+ErrMsg);
        ErrMsg := '';
      end;
    until FindNext(fRec) <> 0;
    //FindClose(fRec);
  Except on E:Exception do
    begin
      ErrMsg := E.message;
      //Axp.dbm.gf.dodebug.Msg(SourceDir+fRec.Name+' file is not Moved to '+TargetDir+fRec.Name);
    end;
  end;
  if ErrMsg <> '' then
  begin
    //Axp.dbm.gf.dodebug.Msg('XCopyDir Error : '+ErrMsg);
    //Axp.dbm.gf.dodebug.Log('XCopyDir Error : '+ErrMsg);
  end;
end;


function TEVAL.DecryptStr(pValue: String): String;
begin

end;

Procedure TEVal.DeleteDir(DirName : String);
var
  ErrMsg : String;
Begin
  try
  ErrMsg := '';
  if copy(DirName,1,1) = ':' then
  begin
    delete(DirName,1,1);
    DirName := GetVarValue(DirName);
  end;
  if AnsiLastChar(DirName) = '\' then Delete(DirName,Length(DirName),1);
  if DirectoryExists(DirName) then begin
    //if Not Axp.dbm.gf.IsDirectoryEmpty(DirName) then
      //axp.dbm.gf.DeleteFilesFromFolder(DirName);
    RemoveDir(DirName);
  end;
  Except
    on E:Exception do
      ErrMsg := E.Message;
  end;
  if ErrMsg <> '' then
  begin
    //Axp.dbm.gf.dodebug.Msg('DeleteDir Error : '+ErrMsg);
    //Axp.dbm.gf.dodebug.Log('DeleteDir Error : '+ErrMsg);
  end;
End;

function TEVAL.GetAxValue(rule, variable, code: String): String;
begin

end;

function TEVal.GetCsvHeader(sFileName:String):String;
//var fs : TFileStream;
//    sr : TStreamReader;
//    ErrStr : String;
begin
  result := '';
  //ErrStr := '';
  //fs := nil;
  //sr := nil;
  try
    //fs := TFileStream.Create(sFileName, fmOpenRead or fmShareDenyNone);
    //sr := TStreamReader.Create(fs, TEncoding.Default, True);
    //if not sr.EndOfStream then
    //begin
    //  result := sr.ReadLine;
    //end;
  except
      on E:Exception do
    //  ErrStr := E.Message;
  end;
  //if ErrStr <> '' then
  //begin
    //Axp.dbm.gf.dodebug.Msg('GetCsvHeader Error : '+ErrStr);
   // Axp.dbm.gf.dodebug.Log('GetCsvHeader Error : '+ErrStr);
  //end else
  //begin
    //sr.Close;
    //FreeAndNil(sr);
    //FreeAndNil(fs);
  //end;
end;

function TEVAL.GetDelimitedStr(SQLName, FieldName, Delimiter: String): String;
begin

end;

Procedure TEVal.ConvertFile(SourceFile,TargetFile,OverWriteTargetFile:String);
var sSrcExt, sTgtExt,ErrStr, sSrcFName, sTgtFName, sSrcPath, sTgtPath : String;
    bFailIfExists, bFileExists : Boolean;
begin
  Try
    if (Trim(SourceFile) = '') or (Trim(TargetFile)='') then
      raise Exception.Create('SourceFile/TargetFile can not be left empty');
    sSrcExt := lowercase(ExtractFileExt(SourceFile));
    if sSrcExt='' then raise Exception.Create('SourceFile should be given with extension');
    sTgtExt := lowercase(ExtractFileExt(TargetFile));
    if sTgtExt='' then raise Exception.Create('TargetFile should be given with extension');

    sSrcFName := ExtractFileName(SourceFile);
    sTgtFName := ExtractFileName(TargetFile);
    sSrcPath := ExtractFilePath(SourceFile);
    sTgtPath := ExtractFilePath(TargetFile);
    if (lowercase(OverWriteTargetFile) = 'true') or (lowercase(OverWriteTargetFile) = 't') then
      bFailIfExists := False
    else
      bFailIfExists := true;
    bFileExists := FileExists(TargetFile);
    if bFileExists then
     // Axp.dbm.gf.dodebug.Msg('File '+TargetFile+' found.');

    if (not bFileExists) or (bFileExists and (Not bFailIfExists)) then begin
      if ((sSrcExt = '.xls') or (sSrcExt = '.xlsx')) and (sTgtExt = '.csv') then
        ConvertExcelToCSVFile(sSrcPath,sSrcFName,sTgtPath,sTgtFName)
      else if ((sTgtExt = '.xls') or (sTgtExt = '.xlsx')) and (sSrcExt = '.csv') then
        ConvertCSVToExcelFile(SourceFile,TargetFile,OverWriteTargetFile)
      else if (sSrcExt = '.csv') and (sTgtExt = '.txt') then
       // CopyFile(pChar(SourceFile),pChar(TargetFile),bFailIfExists)
      else if (sSrcExt = '.txt') and (sTgtExt = '.csv') then
        //CopyFile(pChar(SourceFile),pChar(TargetFile),bFailIfExists);
    end;

  Except On E:Exception do
    ErrStr := E.Message;
  End;
  if ErrStr <> '' then
  begin
//    Axp.dbm.gf.dodebug.Msg('ConvertFile Error : '+ErrStr);
//    Axp.dbm.gf.dodebug.Log('ConvertFile Error : '+ErrStr);
  end;


end;

function TEVAL.ConvertMD5(s: String): String;
begin

end;

Procedure TEVal.ConvertExcelToCSVFile(eFilePath,eFileName,tfilepath,tfilename: String);
var xls, xlw: Variant;
    xlcsv : integer;
    ErrStr : String;
begin
//  xlcsv:=6;
//  try
//    if AnsiLastChar(eFilePath) <> '\' then
//      eFilePath := eFilePath+'\';
//    if AnsiLastChar(tfilepath) <> '\' then
//      eFilePath := tfilepath+'\';
//
//    xls := CreateOleObject('Excel.Application');
//    xls.visible := false;
//    xls.Displayalerts := False;
//    xlw := xls.WorkBooks.Open(eFilePath+eFileName);
//    xlw.SaveAs(tfilepath+tfilename, xlCSV);
//    xls.WorkBooks.close;
//    xls.quit;
//    KillExcel(xls);
//  except On e:exception do
//    ErrStr := e.Message;
//  end;
//  if ErrStr <> '' then
//  begin
////    Axp.dbm.gf.dodebug.Msg('ConvertExcelToCSVFile Error : '+ErrStr);
////    Axp.dbm.gf.dodebug.Log('ConvertExcelToCSVFile Error : '+ErrStr);
//  end;
end;

procedure TEVAL.ConstructTable(s, tablename: String);
begin

end;

Procedure TEVal.ConvertCSVToExcelFile(sSrcFile,sTgtFile,sOverWrite: String);
var xls, xlw: Variant;
    xlExcel8,xlOpenXMLWorkbook : integer;
    ErrStr : String;
begin
//   xlExcel8 := 56;
//   xlOpenXMLWorkbook := 51;
//  try
//    xls := CreateOleObject('Excel.Application');
//    xls.visible := false;
//    xls.Displayalerts := False;
//    xlw := xls.WorkBooks.Open(sSrcFile);
//    if lowercase(ExtractFileExt(sTgtFile)) = '.xls' then
//      xlw.SaveAs(sTgtFile,xlExcel8)
//    else
//      xlw.SaveAs(sTgtFile,xlOpenXMLWorkbook) ;
////    xlw.SaveAs(tfilepath+tfilename, xlCSV);
//    xls.WorkBooks.close;
//    xls.quit;
//    KillExcel(xls);
//  except On e:exception do
//    ErrStr := e.Message;
//  end;
//  if ErrStr <> '' then
//  begin
////    Axp.dbm.gf.dodebug.Msg('ConvertCSVToExcelFile Error : '+ErrStr);
////    Axp.dbm.gf.dodebug.Log('ConvertCSVToExcelFile Error : '+ErrStr);
//  end;
end;


procedure TEVal.KillExcel(var App: Variant);
//var
//  ProcID: DWORD;
//  hProc: THandle;
//  hW: HWND;
begin
  //hW := App.Application.Hwnd;
  //// close with usual methods
  //App.DisplayAlerts := False;
  //App.Workbooks.Close;
  //App.Quit;
  //App := Unassigned;
  //// close with WinApi
  //if not IsWindow(hW) then Exit; // already closed?
  //GetWindowThreadProcessId(hW, ProcID);
  //hProc := OpenProcess(PROCESS_TERMINATE, False, ProcID);
  //TerminateProcess(hProc, 0);
end;

Procedure TEVal.SetToRedis(HostName, KeyName, KeyValue , pwd : String ; timeout : integer);
begin
//  axp.dbm.gf.SetValuesToRedis(HostName, KeyName, KeyValue , pwd, timeout);
end;

Procedure TEVal.SetToRedis(HostName, KeyName, KeyValue : String);
begin
//  axp.dbm.gf.SetValuesToRedisConn(HostName, KeyName, KeyValue);
end;

Function TEVal.GetFromRedis(Hostname, KeyName , pwd : String): String;
begin
//  Result := axp.dbm.gf.GetValuesFromRedis(Hostname, KeyName , pwd);
end;

Function TEVal.GetFromRedis(Hostname, KeyName : String): String;
begin
//  Result := axp.dbm.gf.GetValuesFromRedisConn(Hostname, KeyName);
end;
//
//Function TEVal.ExtractQueryParams(sqltext:String):String;
//var sxds:TXds;
//    i : integer;
//begin
//  result := '';
//  sxds := axp.dbm.GetXDS(nil);
//  sxds.buffered := true;
//  sxds.CDS.CommandText:=ReplaceDynamicparams(sqltext);
//  for i := 0 to sxds.CDS.Params.Count-1 do begin
//    result := result+','+sxds.CDS.Params[i].Name;
//  end;
//  if result <> '' then
//    Delete(result,1,1);
//  sxds.close;
//  sxds.Destroy;
//  sxds := nil;
//end;
//
////Function to register the memory variables
//Function TEVAL.AxMemLoad(sFnName, sParamVars: String): String;
//var
//  sxds: TXDS;
//  iIdx: integer;
//  ErrStr,fnparams, sFnResult,tmpVar,tmpVal,sVar,sVal,sVarType: String;
//  jsnObject: TJsonObject;
//  jsnArray : TJsonArray;
//  jsnPair : TJSONPair;
//  bPushToGFAppVars : Boolean;
//begin
//  Result := '';
//  sFnResult := '';
//  sxds := nil;
//  jsnObject := nil;
//  jsnArray := nil;
//  bPushToGFAppVars := False;
//  try
//    try
//      if sFnName = '' then
//        raise exception.create('Invalid function name.');
//      axp.dbm.gf.DoDebug.msg('AxMemLoad - functionname : ' + sFnName);
//      sxds := axp.dbm.GetXDS(nil);
//      sxds.buffered := true;
//      {
//      if (axp.dbm.Connection.DbType = 'oracle') then
//        sxds.CDS.CommandText := 'select ' + sFnName + '(:fnparams) as memvars from dual'
//      else // mssql , mysql , postgres
//        sxds.CDS.CommandText := 'select ' + sFnName + '(:fnparams) as memvars';
//      }
//      fnparams := '';
//      jsnObject := TJsonObject.Create;
//      iIdx := 1;
//      tmpVar := axp.dbm.gf.GetNthString(sParamVars,iIdx);
//      while tmpVar <> '' do
//      begin
//        tmpVal := GetVarValue(tmpVar);
//        //Read tmpVar value from  gf.AppVars
//        (*
//        if we use AXPERTVARIABLES variable as a param in immediate next variable script/expression, then getvarvalue may not return value
//        since we are not registering  default values into parser variables(check loadappvar method).
//        So to handle this we are taking values from gf.AppVars , hope there wont be any issue if we use those vars in AxGlo.
//        Need to check .
//        *)
//        if tmpVal = '' then tmpVal := axp.dbm.gf.AppVars.Values[tmpVar];
//        jsnObject.AddPair(tmpVar,tmpVal);
//        fnparams := fnparams + quotedstr(tmpVal) + ',';
//        Inc(iIdx);
//        tmpVar := axp.dbm.gf.GetNthString(sParamVars,iIdx);
//      end;
//      {
//      if Assigned(jsnObject) then
//      begin
//         //Pushing json object inside json array, requested by solution team
//         fnparams := '['+jsnObject.ToString+']';
//         jsnObject.Free;
//         jsnObject := nil;
//      end;
//      }
//      if fnparams <> '' then
//      begin
//        delete(fnparams,length(fnparams),1);
//        axp.dbm.gf.DoDebug.msg('AxMemLoad - fnparams : ' + fnparams);
//        //sxds.CDS.Params[0].asstring := fnparams;
//        if (axp.dbm.Connection.DbType = 'oracle') then
//          sxds.CDS.CommandText := 'select ' + sFnName + '(' + fnparams + ') as memvars from dual'
//        else // mssql , mysql , postgres
//          sxds.CDS.CommandText := 'select ' + sFnName + '(' + fnparams + ') as memvars';
//      end else
//      begin
//        if (axp.dbm.Connection.DbType = 'oracle') then
//          sxds.CDS.CommandText := 'select ' + sFnName + ' as memvars from dual'
//        else // mssql , mysql , postgres
//          sxds.CDS.CommandText := 'select ' + sFnName + ' as memvars';
//      end;
//      sxds.open;
//      if sxds.CDS.RecordCount > 0 then
//        sFnResult := sxds.CDS.fieldbyname('memvars').AsString;
//     axp.dbm.gf.DoDebug.msg('AxMemLoad - function result : ' + sFnResult);
//     if sFnResult = '' then
//      Exit
//     else
//     begin
//       jsnArray := TJSONObject.ParseJSONValueUTF8(TEncoding.UTF8.GetBytes(sFnResult), 0) as TJSONArray;
//       if Assigned(jsnArray) then
//       begin
//         jsnObject := jsnArray.Get(0) as TJSONObject;
//         if Assigned(jsnObject) then
//         begin
//           try
//             bPushToGFAppVars := assigned(axp.dbm.gf.appvars);
//             axp.dbm.gf.DoDebug.msg('AxMemLoad - registering vars...');
//             for jsnPair in jsnObject do
//             begin
//                 sVar := jsnPair.JsonString.Value;// ToString;
//                 sVal := jsnPair.JsonValue.Value;// ToString;
//                 axp.dbm.gf.DoDebug.msg(Format('1) Key=%s Value=%s',[sVar,sVal]));
//                 //If the variable not starts with ARV_ then raise exception
//                 //if Not AnsiStartsStr('ARV_',UpperCase(sVar)) then
//                    //raise Exception.Create('AxMemVariable name should start with ARV_.');
//
//                 sVarType := Copy(sVar,Length(sVar),1); //To Extract Datatype
//                 if sVarType = '' then sVarType := 'c';
//                 Delete(sVar,Length(sVar),1); // To Extract variable name
//                 if sVal = 'null' then sVal := ''; // To convert null string to empty str
//                 RegisterVar(sVar,sVarType[1],sVal);
//                 //if appvars assigned and ServiceName is 'Login' then add AppVar details
//                 if (bPushToGFAppVars) and ((axp.dbm.gf.ServiceName = 'Login') or (axp.dbm.gf.ServiceName='Get Global Variables')
//                  or (axp.dbm.gf.ServiceName='OpenSessionForFlutter'))then
//                 begin
//                   axp.dbm.gf.AppVarTypes := axp.dbm.gf.AppVarTypes+sVarType;
//                   axp.dbm.gf.appvars.Add(sVar+'='+sVal);
//                 end;
//             end;
//             if (axp.dbm.gf.ServiceName = 'Login') or (axp.dbm.gf.ServiceName='Get Global Variables')
//                or (axp.dbm.gf.ServiceName='OpenSessionForFlutter') then
//              axp.dbm.gf.AxMemVars := ''
//             else
//             begin
//                axp.dbm.gf.AxMemVars := sFnResult;
//             end;
//           finally
//             jsnObject.Free;
//           end;
//         end;
//       end;
//     end;
//     Result := sFnResult;
//     axp.dbm.gf.DoDebug.msg('Resulr of AxMemLoad : ' + Result);
//    except
//      On e: exception do
//        ErrStr := e.message;
//    end;
//    if ErrStr <> '' then
//    begin
//      axp.dbm.gf.DoDebug.msg('uParse\AxMemLoad Error : ' + ErrStr);
//      axp.dbm.gf.DoDebug.Log('uParse\AxMemLoad Error : ' + ErrStr);
////      raise Exception.Create(ErrStr); //AxMemLoad- should raise any exception | As discussed with Unni sir
//    end;
//  finally
//    if assigned(sxds) then
//    begin
//      if sxds.Active then
//        sxds.close;
//      FreeAndNil(sxds);
//    end;
//    jsnObject := nil;
//    jsnArray := nil;
//  end;
//
//end;

//Get position of substring
Function TEVAL.StringPOS(sSubString,sString: String;sSeparator : string = ','): String;
var
  sErrStr : String;
  iStrIdx : Integer;
begin
  Result := '-1';
  if (Trim(sString) = '') then Exit;
  if (Trim(sSeparator)) = '' then sSeparator := ',';

  iStrIdx := -1;
  // Define a string list object
  With TStringList.create do
  begin
    CaseSensitive := True; //CaseSensitive
    Delimiter := sSeparator[1]; //Assiging Separator / Delimiter
    DelimitedText := sString; //Adding strings to list using DelimitedText
    //Finding index of string -- > 0 string found | < 0 (-1) String not found
    iStrIdx := IndexOf(sSubString);
    Free;
  end;
  Result := IntToStr(iStrIdx);
end;



//function TEVAL.GetAxValue(rule, variable, code: String): String;
//  var jsonValue , f , ruleData , variationDetails , vType , vName , variation : string;
//      jsnObject,jo1: TJsonObject;
//      jsnPair,jsnPair1 : TJSONPair;
//      j,i : integer;
//begin
//  Result := '';
//  if Trim(rule) = '' then exit;
//  axp.dbm.gf.DoDebug.msg('GetAxValue - Rule : ' + rule);
//  axp.dbm.gf.DoDebug.msg('GetAxValue - Variable : ' + variable);
//  jsonValue := getvarvalue(rule);
//  jsnObject := nil;
//  jsnObject := TJSONObject.ParseJSONValueUTF8(TEncoding.UTF8.GetBytes(jsonValue), 0) as TJsonObject;
//  if Assigned(jsnObject) then
//  begin
//    if code <> '' then
//    begin
//       axp.dbm.gf.DoDebug.msg('GetAxValue - Code : ' + code);
//       for jsnPair in jsnObject do
//       begin
//          f := jsnPair.JsonString.Value;// ToString;
//          if f = code then
//          begin
//            jo1 := jsnObject.Get(code).JsonValue as TJsonObject;
//            break;
//          end;
//       end;
//    end else
//       jo1 := jsnObject.Get(code).JsonValue as TJsonObject;
//  end;
//  if jo1 <> nil then
//  begin
//    if Assigned(jo1) then
//    begin
//       jsnObject := jo1;
//       for jsnPair in jo1 do
//       begin
//          f := jsnPair.JsonString.Value;// ToString;
//          if f = 'variations' then
//          begin
//             variationDetails := jsnPair.jsonvalue.value;
//             axp.dbm.gf.DoDebug.msg('GetAxValue - variations : ' + variationDetails);
//             vType := axp.dbm.gf.GetNthString(variationDetails,1,'~');
//             vName := axp.dbm.gf.GetNthString(variationDetails,2,'~');
//             //fldName := vName;
//             //fldIdx := dbcall.struct.GetFieldIndex(fldName);
//             //if fldIdx <> -1 then variation := dbcall.Validate.Parser.GetVarValue(fldName);
//             variation := GetVarValue(vName);
//             break;
//          end;
//       end;
//       if variation <> '' then
//       begin
//         axp.dbm.gf.DoDebug.msg('GetAxValue - vName : ' + vName);
//         for jsnPair in jo1 do
//         begin
//            f := jsnPair.JsonString.Value;
//            if f = vName then
//            begin
//              jo1 := jo1.Get(vName).JsonValue as TJsonObject;
//              if assigned(jo1) then
//              begin
//                for jsnPair1 in jo1 do
//                begin
//                  f := jsnPair1.JsonString.Value;
//                  if lowercase(f) = lowercase(variation) then
//                  begin
//                    axp.dbm.gf.DoDebug.msg('GetAxValue - variation : ' + variation);
//                    jo1 := jo1.Get(variation).JsonValue as TJsonObject;
//                    jsnObject := jo1;
//                    break;
//                  end;
//                end;
//              end;
//              break;
//            end;
//         end;
//       end;
//    end;
//    if Assigned(jsnObject) then
//    begin
//       for jsnPair in jsnObject do
//       begin
//          f := jsnPair.JsonString.Value;
//          if f = variable then
//          begin
//            result := jsnPair.JsonValue.Value;
//            axp.dbm.gf.DoDebug.msg('GetAxValue - Result : ' + result);
//            break;
//          end;
//       end;
//    end;
//  end;
//  jsnObject := nil; jo1 := nil;
//end;

end.
