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
  try
    str := EmojiData.EmojizeByName('GRINNING FACE');
    // str = '😀'
  finaly
    EmojiData.Free;
  end;
end;
```


## License

MIT.
