unit TestCase1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry,
  Emoji;

type

  { TTestCase1 }

  TTestCase1= class(TTestCase)
  protected
    FEmojiData: TEmojiData;

    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHookUp;
  	procedure TextEmojiMatch;

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
//  Fail('Write your own test');

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


procedure TTestCase1.SetUp;
begin
  //FEmojiData := GetEmojiDataFromEmojiDataSource;
  FEmojiData := GetEmojiDataFromFile(LocalEmojiDataSourceFilename);
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

