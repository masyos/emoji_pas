# emoji_pas

emoji-data unit for Lazarus (Free Pascal).

[emoji-data](https://github.com/iamcal/emoji-data)  

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
