unit Testemoji;
{

  Delphi DUnit テスト ケース
  ----------------------
  このユニットには、テスト ケース ウィザードで生成されたスケルトン テスト ケース クラスが含まれています。
  生成されたコードを正しくセットアップできるように修正し、テスト対象ユニットのメソッドを 
  呼び出します。

}

interface

uses
  TestFramework, Classes, Generics.Collections, SysUtils, Emoji;

type
  // クラスのテスト メソッド TEmojiData

  TestTEmojiData = class(TTestCase)
  strict private
    FEmojiData: TEmojiData;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCtor;
    procedure TestHookUp;
  	procedure TextEmojiMatch;

    procedure TestJsonMatch;
  end;

implementation

const
  LocalEmojiDataSourceFilename = '..\..\..\..\local\emoji-datasource\emoji.json';

  EmojiName = 'GRINNING FACE';
  EmojiText = '😀';


procedure TestTEmojiData.SetUp;
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

  //FEmojiData := GetEmojiDataFromEmojiDataSource;
  FEmojiData := GetEmojiData(s);
  if not Assigned(FEmojiData) then
    Fail('load error: emoji-data source.');
end;

procedure TestTEmojiData.TearDown;
begin
  if Assigned(FEmojiData) then
    FreeAndNil(FEmojiData);
end;

procedure TestTEmojiData.TestCtor;
begin
  //FEmojiDataEntry.;
  // TODO: メソッド結果の検証
end;

procedure TestTEmojiData.TestHookUp;
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

procedure TestTEmojiData.TestJsonMatch;
begin

end;

procedure TestTEmojiData.TextEmojiMatch;
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

initialization
  // テスト ケースをテスト ランナーに登録する
  RegisterTest(TestTEmojiData.Suite);
end.

