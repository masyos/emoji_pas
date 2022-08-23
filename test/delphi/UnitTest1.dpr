program UnitTest1;
{

  Delphi DUnit テスト プロジェクト
  -------------------------
  このプロジェクトには、DUnit テスト フレームワークと GUI/コンソール型テスト ランナーが含まれています。
  プロジェクト オプションの条件定義エントリに "CONSOLE_TESTRUNNER" を追加すると、
  コンソール型テスト ランナーを使用できます。それ以外の場合は、デフォルトで GUI 型テスト ランナーが
  使用されます。

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  Testemoji in 'Testemoji.pas',
  emoji in '..\..\src\emoji.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

