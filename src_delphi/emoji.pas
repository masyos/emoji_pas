(* SPDX-License-Identifier: MIT *)
(*
    Emoji data for Lazarus (Free Pascal) version 0.0.1

    Copyright 2022 YOSHIDA, Masahiro.

    https://github.com/masyos/emoji_pas

	emoji-data - Easy to consume Emoji data and images @br
    https://github.com/iamcal/emoji-data @br
	https://cdn.jsdelivr.net/npm/emoji-datasource@14.0.0/emoji.json @br

 *)
unit Emoji;

interface

uses
  Classes, SysUtils,  System.JSON,
  Generics.Collections, System.Net.HttpClientComponent;

const
  { Emoji Code Count Max }
  EmojiCodeMax = 16;
  { emoji-datasource URL }
  EmojiDataSourceUrl: utf8string =
    'https://cdn.jsdelivr.net/npm/emoji-datasource@14.0.0/emoji.json';

type
  { Emoji vender }
  TEmojiVender = (evUser, evApple, evGoogle, evTwitter, evFacebook);
  { Emoji venders }
  TEmojiVenders = set of TEmojiVender;

  { Emoji Code }
  TEmojiCode = array [1..EmojiCodeMax] of Uint32;
  { Emoji version }
  TEmojiVersion = Uint32;

  { TEmojiError }
  EEmojiError = class(Exception);

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
    FAddedIn: TEmojiVersion;
    FVenders: TEmojiVenders;
    function GetAddedInMajor: Uint8;
    function GetAddedInMinor: Uint8;
    procedure SetUnified(AValue: utf8string);
  public
    { constructor }
    constructor Create;
    { destructor }
    destructor Destroy; override;

    { emoji name }
    property Name: utf8string read FName write FName;
    { emoji unified }
    property Unified: utf8string read FUnified write SetUnified;
    { emoji utf8 text }
    property Text: utf8string read FText;
    { emoji non qualified }
    property NonQualified: utf8string read FNonQualified write FNonQualified;
    { emoji short name }
    property ShortName: utf8string read FShortName write FShortName;
    { emoji short names }
    property ShortNames: TStringList read FShortNames;
    { emoji added in version (Emoji Version) }
    property AddedIn: TEmojiVersion read FAddedIn write FAddedIn;
    { emoji added in version majro  }
    property AddedInMajor: Uint8 read GetAddedInMajor;
    { emoji added in version minor }
    property AddedInMinor: Uint8 read GetAddedInMinor;
    { emoji category }
    property Category: utf8string read FCategory write FCategory;
    { emoji sub category }
    property SubCategory: utf8string read FSubCategory write FSubCategory;
    { emoji sort order }
    property SortOrder: integer read FSortOrder write FSortOrder;
    { emoji vender }
    property Venders: TEmojiVenders read FVenders write FVenders;
  end;

  { Emnoji data entries }
  TEmojiDataEntries =  TObjectList<TEmojiDataEntry>;
  { Emoji string to index dictionary }
  TEmojiStrDict =  TDictionary<utf8string, integer>;

  { TEmojiData }

  TEmojiData = class
  private
    FCaseSensitive: boolean;
    FRegisterdVersion: TEmojiVersion;

    FVersion: TEmojiVersion;
    FEntries: TEmojiDataEntries;
    FNameDict: TEmojiStrDict;
    FShortNameDict: TEmojiStrDict;
    FTextDict: TEmojiStrDict;

    function GetEntries(index: integer): TEmojiDataEntry;

  public
    { constructor
      @param(ACaseSensitive is Distinguish the case of names when searching)
      @param(ARegVer is Registered EmojiVersion, 0 is all register)
    }
    constructor Create(ACaseSensitive: boolean = false; ARegVer: TEmojiVersion = 0);
    { destructor }
    destructor Destroy; override;

    { add entry.
      @param(entry is 1char emoji data, Management is delegated.)
    }
    function Add(entry: TEmojiDataEntry): integer;

    { entries count. }
    function Count: Integer;

    { find entry by name.
      @param(value is "CLDR Short Name")
      @returns(entries index)
    }
    function FindByName(const value: utf8string): integer;
    { find entry by short-name.
      @param(value is emoji-data Short Name)
      @returns(entries index)
    }
    function FindByShortName(const value: utf8string): integer;
    { find entry by text.
      @param(value is emoji char(UTF-8))
      @returns(entries index)
    }
    function FindByText(const value: utf8string): integer;

    { Emojize
      @param(value is "CLDR Short Name")
      @returns(emoji char(utf8))
    }
    function EmojizeByName(const value: utf8string): utf8string;
    { Emojize
      @param(value is short-name)
      @returns(emoji char(utf8))
    }
    function EmojizeByShortName(const value: utf8string): utf8string;
    { Demojize
      @param(value is emoji char(UTF-8))
      @returns(emoji "CLDR Short Name")
    }
    function DemojizeNameIn(const value: utf8string): utf8string;
    { Demojize
      @param(value is emoji char(UTF-8))
      @returns(emoji short-name)
    }
    function DemojizeShortNameIn(const value: utf8string): utf8string;

    { load from '.json' stream.
      @param(Filename is '.json' format stream)
    }
    procedure LoadFromStream(const Stream: String);
    { load from '.json' file.
      @param(Filename is '.json' format file)
    }
    procedure LoadFromFile(const Filename: string);

    { save to '.json' stream.
      @param(Filename is '.json' format stream)
    }
    procedure SaveToStream(const Stream: TStream);

    { sace to '.json' file.
      @param(Filename is '.json' format file)
    }
    procedure SaveToFile(const Filename: string);

    { name is case sensitive ? }
    property CaseSensitive: boolean read FCaseSensitive;
    { emoji version }
    property Version: TEmojiVersion read FVersion;
    { emoji entries
      @param(index is Entries index)
    }
    property Entries[index: integer]: TEmojiDataEntry read GetEntries;
  end;

(* emoji version utils. *)

{ make emoji version }
function MakeEmojiVersion(AMajor, AMinor, APatch, ABuild: Uint8): TEmojiVersion;
{ get emoji major version }
function GetEmojiVersionMajor(value: TEmojiVersion): Uint8;
{ get emoji minor version }
function GetEmojiVersionMinor(value: TEmojiVersion): Uint8;
{ get emoji patch version }
function GetEmojiVersionPatch(value: TEmojiVersion): Uint8;
{ get emoji build version }
function GetEmojiVersionBuild(value: TEmojiVersion): Uint8;


(* emoji-data: json format. *)

{ create EmojiData from string }
function GetEmojiData(const value: utf8string; CaseSensitive: boolean = false; RegUpVer: uint32 = 0): TEmojiData;
{ create EmojiData from file }
function GetEmojiDataFromFile(const filename: string; CaseSensitive: boolean = false; RegUpVer: uint32 = 0): TEmojiData;
{ create EmojiData from emoji-datasource URL }
function GetEmojiDataFromEmojiDataSource(CaseSensitive: boolean = false; RegUpVer: uint32 = 0): TEmojiData;



implementation

//  00 0000..00 007f    0xxx-xxxx


//  00 0080..00 07ff    110y-yyyx 	10xx-xxxx
//  00 0800..00 ffff    1110-yyyy 	10yx-xxxx 	10xx-xxxx
//  01 0000..10 ffff    1111-0yyy 	10yy-xxxx 	10xx-xxxx 	10xx-xxxx
function CodeToStr(code: System.UInt32): System.UTF8String;
begin
  Result := UTF8String(EmptyStr);
  if code < $80 then begin
    SetLength(Result, 1);
    Result[1] := AnsiChar( Chr(code));
  end else if code < $800 then begin
    SetLength(Result, 2);
    Result[2] := AnsiChar( Chr($80 or ((code      ) and $0000003F)));
    Result[1] := AnsiChar( Chr($C0 or ((code shr 6) and $0000001F)));
  end else if code < $10000 then begin
    SetLength(Result, 3);
    Result[3] := AnsiChar( Chr($80 or ((code       ) and $0000003F)));
    Result[2] := AnsiChar( Chr($80 or ((code shr  6) and $0000003F)));
    Result[1] := AnsiChar( Chr($E0 or ((code shr 12) and $0000000F)));
  end else begin // < $110000.
    SetLength(Result, 4);
    Result[4] := AnsiChar( Chr($80 or ((code       ) and $0000003F)));
    Result[3] := AnsiChar( Chr($80 or ((code shr  6) and $0000003F)));
    Result[2] := AnsiChar( Chr($80 or ((code shr 12) and $0000003F)));
    Result[1] := AnsiChar( Chr($F0 or ((code shr 18) and $00000007)));
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
const
  UnifiedSep = '-';
//  UnifiedSep = '_';
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

  term := Pos(UnifiedSep, value, start);
  while term > 0 do begin
    s := '$' + Copy(value, start, term - start);
    code[idx] := StrToInt(s);
    Inc(idx);
    start := term + 1;

    term := Pos(UnifiedSep, value, start);
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
  Result := MakeEmojiVersion(h, l, 0, 0);
end;


function MakeEmojiVersion(AMajor, AMinor, APatch, ABuild: Uint8): TEmojiVersion;
begin
  Result := (Uint32(AMajor) shl 24) or
            (Uint32(AMinor) shl 16) or
            (Uint32(APatch) shl  8) or
            (Uint32(ABuild));
end;

function GetEmojiVersionMajor(value: TEmojiVersion): Uint8;
begin
  Result := (value shr 24) and $ff;
end;

function GetEmojiVersionMinor(value: TEmojiVersion): Uint8;
begin
  Result := (value shr 16) and $ff;
end;

function GetEmojiVersionPatch(value: TEmojiVersion): Uint8;
begin
  Result := (value shr  8) and $ff;
end;

function GetEmojiVersionBuild(value: TEmojiVersion): Uint8;
begin
  Result := value and $ff;
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
  stream: TStream;
begin
  Result := nil;
  stream := TStringStream.Create(value);
  try
    Result := TEmojiData.Create(CaseSensitive, RegUpVer);
    Result.LoadFromStream(value);
  finally
    stream.Free;
  end;
end;

function GetEmojiDataFromFile(const filename: string; CaseSensitive: boolean;
  RegUpVer: uint32): TEmojiData;
begin
  Result := TEmojiData.Create(CaseSensitive, RegUpVer);
  Result.LoadFromFile(filename);
end;

function GetEmojiDataFromEmojiDataSource(CaseSensitive: boolean;
  RegUpVer: uint32): TEmojiData;
var
  Client: TNetHTTPClient;
  Strm: TStringStream;
  s: utf8string;
begin
  Result := nil;
  s := EmptyStr;

  Client := TNetHTTPClient.Create(nil);
  Strm := TStringStream.Create;
  try
    { Allow redirections }
    //Client.AllowRedirect := true;
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



constructor TEmojiData.Create(ACaseSensitive: boolean; ARegVer: TEmojiVersion);
begin
  FCaseSensitive := ACaseSensitive;
  FRegisterdVersion := ARegVer;
  FVersion := 0;
  FEntries := TEmojiDataEntries.Create;
  FNameDict := TEmojiStrDict.Create;
  FShortNameDict := TEmojiStrDict.Create;
  FTextDict := TEmojiStrDict.Create;
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
  s, sit: utf8string;
begin
  Result := -1;
  if (entry.Name = EmptyStr) then
    Exit;
  if (FRegisterdVersion > 0) and (entry.AddedIn > FRegisterdVersion) then
    Exit;

  // name.
  s := entry.Name;
  if not FCaseSensitive then
    s := UpperCase(s);
  if FNameDict.ContainsKey(s) then begin
    Result := FNameDict[s];
    Exit;
  end;
  Result := FEntries.Add(entry);
  FNameDict.Add(s, Result);

  // short name.
  s := entry.ShortName;
  if not FCaseSensitive then
    s := UpperCase(s);
  FShortNameDict.Add(s, Result);

  for sit in entry.ShortNames do begin
    s := sit;
    if not FCaseSensitive then begin
      s := UpperCase(s);
    end;
    if not FShortNameDict.ContainsKey(s) then begin
      FShortNameDict.Add(s, Result);
    end;
  end;

  // text.
  FTextDict.Add(entry.Text, Result);

  if entry.AddedIn > FVersion then begin
    FVersion := entry.AddedIn;
  end;
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



procedure TEmojiData.LoadFromStream(const Stream: String);
var
  //dat: TJSONData;
  dat: TJSONArray;
  root, ary: TJsonArray;
  obj: TJsonObject;
  index, sindex: integer;
  entry: TEmojiDataEntry;
  cnt: Integer;
begin

  //JSON := Utf8toAnsi(RawByteString(Stream));
  dat := TJSONObject.ParseJSONValue(Stream) as TJSONArray;


  //dat := GetJSON(Stream);
  if not Assigned(dat) then Exit;
  root := dat as TJsonArray;
  if not Assigned(root) then Exit;

  cnt := root.Count-1;
  for index := 0 to cnt do begin
    obj := root.Items[index] as TJsonObject;
    if not Assigned(obj) then begin
      Break;
    end;

    entry := TEmojiDataEntry.Create;
    try
      entry.Name := obj.GetValue<string>('name');

      // Ummm...
      // https://github.com/iamcal/emoji-data/issues/188
      if (obj.GetValue<string>('name') = 'MAN IN TUXEDO') and (obj.GetValue<string>('unified') = '1F935') then begin
        entry.Name := 'PERSON IN TUXEDO';
      end;

      entry.ShortName:= obj.GetValue<string>('short_name');
      entry.Unified:= obj.GetValue<string>('unified');

      {entry.NonQualified:=obj.Get('non_qualified', EmptyStr); // null ok.
      entry.Category:= obj.Strings['category'];
      entry.SubCategory:=obj.Strings['subcategory'];
      entry.SortOrder:=obj.Integers['sort_order'];
      entry.AddedIn := DecodeAddedIn(obj.Strings['added_in']);
      if obj.Booleans['has_img_apple'] then
        entry.Venders := entry.Venders + [evApple];
      if obj.Booleans['has_img_google'] then
        entry.Venders := entry.Venders + [evGoogle];
      if obj.Booleans['has_img_twitter'] then
        entry.Venders := entry.Venders + [evTwitter];
      if obj.Booleans['has_img_facebook'] then
        entry.Venders := entry.Venders + [evFacebook];}


      ary :=  obj.GetValue<TJSONArray>('short_names');
      for sindex := 0 to ary.Count-1 do begin
        entry.ShortNames.Add(ary.Items[sindex].ToString);
      end;

      Add(entry);
      entry := nil;
    finally
      entry.Free;
    end;
  end;
end;

procedure TEmojiData.LoadFromFile(const Filename: string);
var
  stream: TFileStream;
begin
  stream := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(stream.ToString);
  finally
    stream.Free;
  end;
end;

procedure TEmojiData.SaveToStream(const Stream: TStream);
//var
  //dat: TJsonData;
begin

end;

procedure TEmojiData.SaveToFile(const Filename: string);
var
  stream: TFileStream;
begin
  stream := TFileStream.Create(Filename, fmCreate or fmShareDenyRead);
  try
    SaveToStream(stream);
  finally
    stream.Free;
  end;
end;


{ TEmojiDataEntry }

function TEmojiDataEntry.GetAddedInMajor: Uint8;
begin
  Result := GetEmojiVersionMajor(FAddedIn);
end;

function TEmojiDataEntry.GetAddedInMinor: Uint8;
begin
  Result := GetEmojiVersionMinor(FAddedIn);
end;

procedure TEmojiDataEntry.SetUnified(AValue: utf8string);
var
  start, term: integer;
begin
  if FUnified=AValue then Exit;
  FUnified:=AValue;
  FText := EmptyStr;

  // set code
  term := DecodeUnified(AValue, FCode);

  // set text
  for start := 1 to term do begin
    FText := FText + CodeToStr(FCode[start]);
  end;
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

