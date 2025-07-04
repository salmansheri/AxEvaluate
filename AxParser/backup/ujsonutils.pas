unit uJSONUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, memds, db, fpjson, jsonparser;

procedure LoadJSONToMemDS(DS: TMemDataset; const JSONStr: string);

implementation

procedure LoadJSONToMemDS(DS: TMemDataset; const JSONStr: string);
var
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  I, J: Integer;
  FieldName: string;
  Field: TField;
  JSONValue: TJSONData;
begin
  DS.Close;
  DS.FieldDefs.Clear;
  DS.Fields.Clear;

  JSONArray := TJSONParser.Create(JSONStr).Parse as TJSONArray;
  try
    if JSONArray.Count > 0 then
    begin
      JSONObject := JSONArray.Objects[0];

      // Define fields based on first object
      for J := 0 to JSONObject.Count - 1 do
      begin
        FieldName := JSONObject.Names[J];
        DS.FieldDefs.Add(FieldName, ftString, 255);
      end;

      DS.CreateDataset;

      // Add rows
      for I := 0 to JSONArray.Count - 1 do
      begin
        JSONObject := JSONArray.Objects[I];
        DS.Append;
        for J := 0 to JSONObject.Count - 1 do
        begin
          FieldName := JSONObject.Names[J];
          JSONValue := JSONObject.Items[J];
          Field := DS.FindField(FieldName);
          if Assigned(Field) then
            Field.AsString := JSONValue.AsString;
        end;
        DS.Post;
      end;
    end;
  finally
    JSONArray.Free;
  end;
end;

end.

