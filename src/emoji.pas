unit Emoji;

{$mode ObjFPC}{$H+}

(*
emoji-data - Easy to consume Emoji data and images
https://github.com/iamcal/emoji-data

https://cdn.jsdelivr.net/npm/emoji-datasource@14.0.0/emoji.json
 *)

interface

uses
  Classes, SysUtils,
  Generics.Collections;

const
  EmojiCodeMax = 16;
  EmojiDataSourceUrl: utf8string =
    'https://cdn.jsdelivr.net/npm/emoji-datasource@14.0.0/emoji.json';

type
  THasImageService = (hisUser, hisApple, hisGoogle, hisTwitter, hisFacebook);
  THasImageServices = set of THasImageService;

  TEmojiCode = array [1..EmojiCodeMax] of Uint32;
  TEmojiAddedIn = record
    LoVer, HiVer: Uint8;
  end;

  { TEmojiDataEntry }

  TEmojiDataEntry = class
  private
    FName: utf8string;
    FUnified: utf8string;
    FCode: TEmojiCode;
    FText: utf8string;
    FNonQualified: utf8string;
	FShortName: utf8string;
  	FShortNames: TStringList;
    FCategory: utf8string;
    FSubCategory: utf8string;
    FSortOrder: integer;
    FAddedIn: Uint32;
    FHasImageServices: THasImageServices;
    function GetAddedInMajorVer: Uint32;
    function GetAddedInMinorVer: Uint32;
    procedure SetUnified(AValue: utf8string);
  public
    constructor Create;
    destructor Destroy; override;


    property Name: utf8string read FName write FName;
    property Unified: utf8string read FUnified write SetUnified;
    property Text: utf8string read FText;
    property NonQualified: utf8string read FNonQualified write FNonQualified;
	property ShortName: utf8string read FShortName write FShortName;
  	property ShortNames: TStringList read FShortNames;
    property AddedIn: Uint32 read FAddedIn write FAddedIn;
    property AddedInMajorVer: Uint32 read GetAddedInMajorVer;
    property AddedInMinorVer: Uint32 read GetAddedInMinorVer;
    property Category: utf8string read FCategory write FCategory;
    property SubCategory: utf8string read FSubCategory write FSubCategory;
    property SortOrder: integer read FSortOrder write FSortOrder;
    property HasImageServices: THasImageServices read FHasImageServices write FHasImageServices;
  end;

  TEmojiData = class
  private
    FCaseSensitive: boolean;
    FAddedIn: Uint32;

    FEntries: specialize TObjectList<TEmojiDataEntry>;
    FNameDict: specialize TDictionary<utf8string, integer>;
    FShortNameDict: specialize TDictionary<utf8string, integer>;
    FTextDict: specialize TDictionary<utf8string, integer>;

    function GetEntries(index: integer): TEmojiDataEntry;

  public
    constructor Create(ACaseSensitive: boolean = false; AAddedIn: uint32 = 0);
    destructor Destroy; override;

    function Add(entry: TEmojiDataEntry): integer;

    // enties count.
    function Count: Integer;


    function FindByName(const value: utf8string): integer;
    function FindByShortName(const value: utf8string): integer;
    function FindByText(const value: utf8string): integer;

    function EmojizeByName(const value: utf8string): utf8string;
    function EmojizeByShortName(const value: utf8string): utf8string;
    function DemojizeNameIn(const value: utf8string): utf8string;
    function DemojizeShortNameIn(const value: utf8string): utf8string;

    property CaseSensitive: boolean read FCaseSensitive;
    property AddedIn: Uint32 read FAddedIn;
	property Entries[index: integer]: TEmojiDataEntry read GetEntries;
  end;

(* emoji-data: json format. *)
function GetEmojiData(const value: utf8string; CaseSensitive: boolean = false; RegUpVer: uint32 = 0): TEmojiData;
function GetEmojiDataFromFile(const filename: string; CaseSensitive: boolean = false; RegUpVer: uint32 = 0): TEmojiData;
function GetEmojiDataFromEmojiDataSource(CaseSensitive: boolean = false; RegUpVer: uint32 = 0): TEmojiData;



implementation

uses
  fpjson, jsonparser, fphttpclient, opensslsockets;



//  0xxx-xxxx
//  110y-yyyx 	10xx-xxxx
// 	1110-yyyy 	10yx-xxxx 	10xx-xxxx 	
//  1111-0yyy 	10yy-xxxx 	10xx-xxxx 	10xx-xxxx
function CodeToStr(code: Uint32): utf8string;
begin
  Result := EmptyStr;
  if code < $80 then begin
    SetLength(Result, 1);
    Result[1] := Chr(code);
  end else if code < $800 then begin 
    SetLength(Result, 2);
    Result[2] := Chr($80 or ((code      ) and $0000003F));
    Result[1] := Chr($C0 or ((code shr 6) and $0000001F));
  end else if code < $10000 then begin
    SetLength(Result, 3);
    Result[3] := Chr($80 or ((code       ) and $0000003F));
    Result[2] := Chr($80 or ((code shr  6) and $0000003F));
    Result[1] := Chr($E0 or ((code shr 12) and $00000007));
  end else begin // < $110000.
    SetLength(Result, 4);
    Result[4] := Chr($80 or (code and $0000003F));
    Result[3] := Chr($80 or ((code shr  6) and $0000003F));
    Result[2] := Chr($80 or ((code shr 12) and $0000003F));
    Result[1] := Chr($F0 or ((code shr 18) and $00000007));
  end;
end;

function StrToCode(const str: utf8string; var code: uint32): integer;
var
  len: integer;
begin
  code := 0;
  Result := 0;
  if Length(str) < 1 then Exit;
  
  Result := 1;
  code := Ord(str[Result]);
  if (code < $80) then Exit;

  if (code and $F0) = $F0 then begin
    len := 4;
    code := code and $07;
  end else if (code and $E0) = $E0 then begin
    len := 3;
    code := code and $0F;
  end else if (code and $C0) = $C0 then begin
    len := 2;
    code := code and $1F;
  end;

  while Result < len do begin
    code := (code shl 6) or Ord(str[Result]);
    inc(Result);
  end;
end;


function DecodeUnified(const value: utf8string; var code: TEmojiCode): integer;
var
  idx, start, term: integer;
  s: utf8string;
begin
  Result := 0;
  for idx := 1 to EmojiCodeMax do begin
    code[idx] := 0;
  end;
  start := 1;
  idx := 1;

  term := Pos('-', value, start);
  while term > 0 do begin
    s := '$' + Copy(value, start, term - start);
    code[idx] := StrToInt(s);
    Inc(idx);
    start := term + 1;

    term := Pos('-', value, start);
  end;
  s := '$' + Copy(value, start);
  code[idx] := StrToInt(s);
  Result := idx;
end;

function DecodeAddedIn(const value: utf8string): Uint32;
var
  sep: integer;
  l, h: uint32;
begin
  Result := 0;
  if value = EmptyStr then Exit;
  h := 0;
  l := 0;
  sep := Pos('.', value);
  if sep > 0 then begin
    h := StrToInt(Copy(value, 1, sep-1));
    l := StrToInt(Copy(value, sep+1));
  end else begin
    h := StrToInt(value);
  end;
  Result := (h shl 24) or (l shl 16);
end;

(*
  [{
	"name":"HASH KEY",
    "unified":"0023-FE0F-20E3",
    "non_qualified":"0023-20E3",
    "docomo":"E6E0",
    "au":"EB84",
    "softbank":"E210",
    "google":"FE82C",
    "image":"0023-fe0f-20e3.png",
    "sheet_x":0,
    "sheet_y":0,
    "short_name":"hash",
    "short_names":["hash"],
    "text":null,
    "texts":null,
    "category":"Symbols",
    "subcategory":"keycap",
    "sort_order":1500,
    "added_in":"0.6",
    "has_img_apple":true,
    "has_img_google":true,
    "has_img_twitter":true,
    "has_img_facebook":false
  },
*)
function GetEmojiData(const value: utf8string; CaseSensitive: boolean;
  RegUpVer: uint32): TEmojiData;
var
  dat: TJSONData;
  root, ary: TJsonArray;
  obj: TJsonObject;
  index, sindex: integer;
  entry: TEmojiDataEntry;
begin
  dat := GetJSON(value);
  Result := TEmojiData.Create(CaseSensitive, RegUpVer);

  root := dat as TJsonArray;


  for index := 0 to root.Count-1 do begin
    obj := root.Items[index] as TJsonObject;
    entry := TEmojiDataEntry.Create;
    entry.Name := obj.Strings['name'];
    entry.ShortName:= obj.Strings['short_name'];
    entry.Unified:= obj.Strings['unified'];
    entry.NonQualified:=obj.Get('non_qualified', EmptyStr); // null ok.
    entry.Category:= obj.Strings['category'];
    entry.SubCategory:=obj.Strings['subcategory'];
    entry.SortOrder:=obj.Integers['sort_order'];
    entry.AddedIn := DecodeAddedIn(obj.Strings['added_in']);
    if obj.Booleans['has_img_apple'] then
      entry.HasImageServices := entry.HasImageServices + [hisApple];
    if obj.Booleans['has_img_google'] then
      entry.HasImageServices := entry.HasImageServices + [hisGoogle];
    if obj.Booleans['has_img_twitter'] then
      entry.HasImageServices := entry.HasImageServices + [hisTwitter];
    if obj.Booleans['has_img_facebook'] then
      entry.HasImageServices := entry.HasImageServices + [hisFacebook];

    ary := obj.Arrays['short_names'];
    for sindex := 0 to ary.Count-1 do begin
      entry.ShortNames.Add(ary.Strings[sindex]);
    end;

    Result.Add(entry);
  end;
end;

function GetEmojiDataFromFile(const filename: string; CaseSensitive: boolean;
  RegUpVer: uint32): TEmojiData;
var
  f: TStringStream;
  s: utf8string;
begin
  Result := nil;
  s := EmptyStr;
  f := TStringStream.Create;
  try
    f.LoadFromFile(filename);
    s := f.DataString;
  finally
  	f.Free;
  end;
  if Length(s) > 0 then begin
    Result := GetEmojiData(s, CaseSensitive, RegUpVer);
  end;
end;

function GetEmojiDataFromEmojiDataSource(CaseSensitive: boolean;
  RegUpVer: uint32): TEmojiData;
var
  Client: TFPHttpClient;
  Strm: TStringStream;
  s: utf8string;
begin
  Result := nil;
  s := EmptyStr;

  Client := TFPHttpClient.Create(nil);
  Strm := TStringStream.Create;
  try
    { Allow redirections }
    Client.AllowRedirect := true;
    Client.Get(EmojiDataSourceUrl, Strm);
  	s := Strm.DataString;
  finally
    Strm.Free;
    Client.Free;
  end;

  if Length(s) > 0 then begin
    Result := GetEmojiData(s, CaseSensitive, RegUpVer);
  end;
end;

{ TEmojiData }

function TEmojiData.GetEntries(index: integer): TEmojiDataEntry;
begin
  Result := FEntries[index];
end;



constructor TEmojiData.Create(ACaseSensitive: boolean; AAddedIn: uint32);
begin
  FCaseSensitive := ACaseSensitive;
  FAddedIn := AAddedIn;

  FEntries := specialize TObjectList<TEmojiDataEntry>.Create;
  FNameDict := specialize TDictionary<utf8string, integer>.Create;
  FShortNameDict := specialize TDictionary<utf8string, integer>.Create;
  FTextDict := specialize TDictionary<utf8string, integer>.Create;
end;

destructor TEmojiData.Destroy;
begin
  FTextDict.Free;
  FShortNameDict.Free;
  FNameDict.Free;
  FEntries.Free;
  inherited Destroy;
end;

function TEmojiData.Add(entry: TEmojiDataEntry): integer;
var
  s: utf8string;
begin
  Result := -1;
  if (FAddedIn > 0) and (entry.AddedIn > FAddedIn) then
    Exit;

  s := entry.Name;
  if not FCaseSensitive then
    s := UpperCase(s);
  if FNameDict.ContainsKey(s) then begin
    Result := FNameDict[s];
    Exit;
  end;

  Result := FEntries.Add(entry);
  FNameDict.Add(s, Result);

  s := entry.ShortName;
  if not FCaseSensitive then
    s := UpperCase(s);
  FShortNameDict.Add(s, Result);

  FTextDict.Add(entry.Text, Result);
end;

function TEmojiData.Count: Integer;
begin
  Result := FEntries.Count;
end;

function TEmojiData.FindByName(const value: utf8string): integer;
var
  s: utf8string;
begin
  Result := -1;
  s := value;
  if not FCaseSensitive then
    s := UpperCase(s);
  if FNameDict.ContainsKey(s) then begin
    Result := FNameDict[s];
  end;
end;

function TEmojiData.FindByShortName(const value: utf8string): integer;
var
  s: utf8string;
begin
  Result := -1;
  s := value;
  if not FCaseSensitive then
    s := UpperCase(s);
  if FShortNameDict.ContainsKey(s) then begin
    Result := FShortNameDict[s];
  end;
end;

function TEmojiData.FindByText(const value: utf8string): integer;
begin
  Result := -1;
  if FTextDict.ContainsKey(value) then begin
    Result := FTextDict[value];
  end;
end;

function TEmojiData.EmojizeByName(const value: utf8string): utf8string;
var
  i: integer;
begin
  Result := EmptyStr;
  i := FindByName(value);
  if i >= 0 then begin
    Result := FEntries[i].Text;
  end;
end;

function TEmojiData.EmojizeByShortName(const value: utf8string): utf8string;
var
  i: integer;
begin
  Result := EmptyStr;
  i := FindByShortName(value);
  if i >= 0 then begin
    Result := FEntries[i].Text;
  end;
end;

function TEmojiData.DemojizeNameIn(const value: utf8string): utf8string;
var
  i: integer;
begin
  Result := EmptyStr;
  i := FindByText(value);
  if i >= 0 then begin
    Result := FEntries[i].Name;
  end;
end;

function TEmojiData.DemojizeShortNameIn(const value: utf8string
  ): utf8string;
var
  i: integer;
begin
  Result := EmptyStr;
  i := FindByText(value);
  if i >= 0 then begin
    Result := FEntries[i].ShortName;
  end;
end;


{ TEmojiDataEntry }

procedure TEmojiDataEntry.SetUnified(AValue: utf8string);
var
  start, term: integer;
begin
  if FUnified=AValue then Exit;
  FUnified:=AValue;

  // set code
  term := DecodeUnified(AValue, FCode);

  // set text
  FText := EmptyStr;
  for start := 1 to term do begin
    FText := FText + CodeToStr(FCode[start]);
  end;
end;

function TEmojiDataEntry.GetAddedInMajorVer: Uint32;
begin
  Result := FAddedIn shr 24;
end;

function TEmojiDataEntry.GetAddedInMinorVer: Uint32;
begin
  Result := FAddedIn shr 16;
end;

constructor TEmojiDataEntry.Create;
begin
  FShortNames := TStringList.Create;
end;

destructor TEmojiDataEntry.Destroy;
begin
  FShortNames.Free;
  inherited Destroy;
end;




end.
