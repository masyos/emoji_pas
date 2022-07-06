unit TestCase1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry,
  fpjson,
  Emoji;

type

  { TTestCase1 }

  TTestCase1= class(TTestCase)
  protected
    FEmojiData: TEmojiData;
    FJson: TJsonData;

    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHookUp;
  	procedure TextEmojiMatch;

    procedure TestJsonMatch;
  end;

implementation



const
  LocalEmojiDataSourceFilename = '..\local\emoji-datasource\emoji.json';

  EmojiName = 'GRINNING FACE';
  EmojiText = '😀';

procedure TTestCase1.TestHookUp;
var
  i: integer;
  s: utf8string;
begin
  i := FEmojiData.FindByName(EmojiName);
  if i < 0 then
    Fail('FindByName error: ' + EmojiName);
  if not SameText(FEmojiData.Entries[i].Name, EmojiName) then
    Fail('FindByName Entries Index error: ' + EmojiName);

  s := FEmojiData.EmojizeByName(EmojiName);
  if CompareStr(s, EmojiText) <> 0 then
    Fail('Emojizen error: ' + EmojiName);
  s := FEmojiData.DemojizeNameIn(s);
  if CompareStr(s, EmojiName) <> 0 then
    Fail('Demojizen error: ' + EmojiName);

end;

procedure TTestCase1.TextEmojiMatch;
var
  idx, count: integer;
  name, val, s: utf8string;
begin
  count := FEmojiData.Count;
  if count = 0 then
  	Fail('Error: GetEmojiDataFromFile: empty Emoji.');

  for idx := 0 to count-1 do begin
    name := FEmojiData.Entries[idx].Name;

    if FEmojiData.FindByName(name) <> idx then
      Fail('Error: FindByName: ' + name + '[' + IntToStr(idx) + ']');

    val := FEmojiData.EmojizeByName(name);
	s := FEmojiData.DemojizeNameIn(val);
    if CompareStr(name, s) <> 0 then
      Fail('Error: Emojize/Demojizen: ' + name + '[' + IntToStr(idx) + ']');
  end;
end;

procedure TTestCase1.TestJsonMatch;
var
  root: TJsonArray;
  obj: TJsonObject;
  index, cnt, val: integer;
begin
  root := FJson as TJsonArray;
  if not Assigned(root) then
    Fail('Error: json root is not array');

  cnt := root.Count-1;
  for index := 0 to cnt do begin
    obj := root.Items[index] as TJsonObject;
    if not Assigned(obj) then
      Fail('Error: not json object');

    val := FEmojiData.FindByName(obj.Strings['name']);
    if val < 0 then
      Fail('Error: emoji name not found [' + IntToStr(index) + '] : ' + obj.Strings['name'] );
  end;

  if root.Count <> FEmojiData.Count then
    Fail('Error: count miss match (' + IntToStr(FEmojiData.Count) + '/' + IntToStr(root.Count) + ')' );
end;


procedure TTestCase1.SetUp;
var
  stream: TStringStream;
  s: utf8string;
begin
  stream := TStringStream.Create;
  try
    stream.LoadFromFile(LocalEmojiDataSourceFilename);
    s := stream.DataString;
  finally
    stream.Free;
  end;

  FJson := GetJSON(s);
  if not Assigned(FJson) then
    Fail('load error: emoji-data source json.');

  //FEmojiData := GetEmojiDataFromEmojiDataSource;
  FEmojiData := GetEmojiData(s);
  if not Assigned(FEmojiData) then
    Fail('load error: emoji-data source.');
end;

procedure TTestCase1.TearDown;
begin
  if Assigned(FEmojiData) then
    FreeAndNil(FEmojiData);
end;

initialization

  RegisterTest(TTestCase1);
end.

