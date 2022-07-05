# emoji_pas

Emoji utils for FreePascal.

[emoji-data](https://github.com/iamcal/emoji-data)  
emoji-data Unit for Lazarus (Free Pascal).

## usage

(now writing...)

```
uses
  Emoji;

var
  EmojiData: TEmojiData;
  str: utf8string;
begin
  EmojiData  := GetEmojiDataFromEmojiDataSource;

  str := FEmojiData.EmojizeByName('GRINNING FACE');
  // str = '😀'

  EmojiData.Free;
end;
```


## License

MIT.
