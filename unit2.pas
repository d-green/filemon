unit unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, StrUtils, LCLType;

type

  { TForm2 }

  TForm2 = class(TForm)
    SaveButton,SkipButton,DelButton: TButton;
    OutFileName,OutFileName2,OutFileName3: TEdit;
    OutID: TEdit;
    Image1: TImage;
    OutPathLabel,InPathLabel,NoViewText: TLabel;
    Label1, Label2, Label3, Label4, Label5, Label6: TLabel;
    ImagePanel, ControlPanel: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure DelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function GetMonth(MonthNum: string): string;
    function GetFolderStructure(): string;
    procedure OutFileNameChange(Sender: TObject);
    procedure SkipButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;
  InPath,OutPath,FrameName: string;
  CreateFoldersFlag,PromptDeletionFlag: boolean;
  FileType,FolderStructure: string;
  FolderTime: TDateTime;
  Fa: longint;
  FileTimeStr: string;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.Button1Click(Sender: TObject);
var
  DestFileFullName: string;
  Confirmed, Overwrite: boolean;
begin
  DestFileFullName := OutPath + FolderStructure + FrameName;
  Confirmed := False;
  if (OutFileName.Text = '') or (OutFileName3.Text = '') or (OutFileName2.Text = '') then
  begin
    MessageDlg('Внимание!', 'Обязательно необходимо заполнить ФИО',
      mtConfirmation, [mbYes], 0);
    exit;
  end;
  if PromptDeletionFlag then //need ask
    if MessageDlg('Внимание!', 'Вы уверены?', mtConfirmation, [mbYes, mbNo], 0) =
      mrYes then
      Confirmed := True  //asked, approved
    else
      Confirmed := False //asked, not approved
  else
    Confirmed := True; //don't ask
  if (FileExists(Utf8Decode(DestFileFullName))) and PromptDeletionFlag and
    Confirmed then
    //need ask and already have file
    if MessageDlg('Внимание!', 'Файл существует в месте назначения. Перезаписать?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      Overwrite := True // have file, approved overwrite
    else
      Overwrite := False //have file, not approved overwrite
  else
    Overwrite := True; //don't ask even have file
  if Confirmed and Overwrite then
  begin
    if CopyFile(InPath + FrameName, DestFileFullName,
      [cffOverwriteFile, cffCreateDestDirectory, cffPreserveTime]) then
    begin
      try
        DeleteFile(InPath + FrameName);
      except
        Application.MessageBox('Ошибка удаления файла.', 'Ошибка!', MB_ICONERROR);
      end;
    end;
  end;
  Close;
end;

procedure TForm2.DelButtonClick(Sender: TObject);
var
  Confirmed: boolean;
begin
  Confirmed := True;
  if PromptDeletionFlag then
    if MessageDlg('Внимание!', 'Вы уверены?', mtConfirmation,
      [mbYes, mbNo], 0) = mrNo then
      Confirmed := False;
  if Confirmed then
  begin
    try
      DeleteFile(InPath + FrameName);
    except
      Application.MessageBox('Ошибка удаления файла.', 'Ошибка!', MB_ICONERROR);
    end;
  end;
  Close;
end;

procedure TForm2.FormShow(Sender: TObject);
var
  Extension: string;
begin
  InPathLabel.Caption := InPath + FrameName;
  OutPathLabel.Caption := OutPath;
  Extension := ExtractFileExt(FrameName);
  if (Extension = '.jpg') or (Extension = '.jpeg') or (Extension = '.png') or
    (Extension = '.bmp') or (Extension = '.gif') then
  begin
    NoViewText.Visible := False;
    Image1.Picture.LoadFromFile(InPath + FrameName);
    if (Image1.Picture.Bitmap.Height > Screen.Height - ControlPanel.Height - 200) or
      (Image1.Picture.Bitmap.Width > Screen.Width - 200) then
      if Image1.Picture.bitmap.Height < Image1.Picture.bitmap.Width then
        Height := Width * Image1.Picture.bitmap.Height div
          Image1.Picture.bitmap.Width + ControlPanel.Height
      else
        Height := Screen.Height - 200
    else
    begin
      Height := Image1.Picture.bitmap.Height + ControlPanel.Height;
      Width := Image1.Picture.bitmap.Width;
    end;
    if Height < 369 then
      Height := 369;
    if Width < 258 then
      Width := 258;
    Top := (Screen.Height - Height) div 2;
    Left := (Screen.Width - Width) div 2;
    Image1.Visible := True;
    Repaint;
  end
  else
  begin
    Image1.Visible := False;
    NoViewText.Caption := 'Просмотр недоступен';
    NoViewText.Visible := True;
  end;
  if CreateFoldersFlag then   //create folders YYYY\MM\DD structure
  begin
    Fa := FileAge(InPath + FrameName);
    if Fa <> -1 then
    begin
      FolderTime := FileDateTodateTime(fa);
      FileTimeStr := DateTimeToStr(FolderTime);
      FolderStructure := GetFolderStructure();
      OutPathLabel.Caption := OutPath + FolderStructure + FrameName;
    end;
  end
  else
  begin
    FolderStructure := '';
  end;
end;

function TForm2.GetMonth(MonthNum: string): string;
var
  Month: array[1..12] of string = (
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август',
    'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь');
begin
  Result := Month[StrToInt(MonthNum)];
end;

procedure TForm2.OutFileNameChange(Sender: TObject);
begin
  if CreateFoldersFlag then
    FolderStructure := GetFolderStructure()
  else
    FolderStructure := '';
  OutPathLabel.Caption := OutPath + FolderStructure + FrameName;
end;

procedure TForm2.SkipButtonClick(Sender: TObject);
begin
  Close;
end;

function TForm2.GetFolderStructure(): string;
var
  F, I, O, ID: string;
begin
  F := StringReplace(Trim(OutFileName.Text), ' ', '_', [rfReplaceAll]);
  I := StringReplace(Trim(OutFileName2.Text), ' ', '_', [rfReplaceAll]);
  O := StringReplace(Trim(OutFileName3.Text), ' ', '_', [rfReplaceAll]);
  ID := StringReplace(Trim(OutID.Text), ' ', '_', [rfReplaceAll]);

  F := StringReplace(F, '\', '', [rfReplaceAll]);
  I := StringReplace(I, '\', '', [rfReplaceAll]);
  O := StringReplace(O, '\', '', [rfReplaceAll]);
  ID := StringReplace(ID, '\', '', [rfReplaceAll]);

  F := StringReplace(F, '.', '', [rfReplaceAll]);
  I := StringReplace(I, '.', '', [rfReplaceAll]);
  O := StringReplace(O, '.', '', [rfReplaceAll]);
  ID := StringReplace(ID, '\', '', [rfReplaceAll]);

  Result := MidStr(FileTimeStr, 7, 4) + '\' + GetMonth(MidStr(FileTimeStr, 4, 2)) +
    '\' + MidStr(FileTimeStr, 1, 2) + '\' + F + '_' + I + '_' + O + '_' + ID + '\';
end;


end.
