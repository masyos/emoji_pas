program UnitTest1;
{

  Delphi DUnit �e�X�g �v���W�F�N�g
  -------------------------
  ���̃v���W�F�N�g�ɂ́ADUnit �e�X�g �t���[�����[�N�� GUI/�R���\�[���^�e�X�g �����i�[���܂܂�Ă��܂��B
  �v���W�F�N�g �I�v�V�����̏�����`�G���g���� "CONSOLE_TESTRUNNER" ��ǉ�����ƁA
  �R���\�[���^�e�X�g �����i�[���g�p�ł��܂��B����ȊO�̏ꍇ�́A�f�t�H���g�� GUI �^�e�X�g �����i�[��
  �g�p����܂��B

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

