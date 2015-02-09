unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, INIFiles, LCLType, unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    PromptDeletion: TCheckBox;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    TrayMenu: TCheckBox;
    CreateFolders, ModalWindow, RunMinimized: TCheckBox;
    FileExtension, IntervalText: TEdit;
    PopupMenu1: TPopupMenu;
    ExitItem, ShowItem, RunNow: TMenuItem;
    ExitButton, MonitorButton: TButton;
    Label1, Label2, Label3, Label4: TLabel;
    InputEdit, OutputEdit: TEdit;
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;

    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IntervalTextChange(Sender: TObject);
    procedure RunNowClick(Sender: TObject);
    procedure ShowItemClick(Sender: TObject);
    procedure MonitorButtonClick(Sender: TObject);
    procedure ExitButtonClick(Sender: TObject);
    procedure InputEditClick(Sender: TObject);
    procedure OutputEditClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ProcessFiles();
    function ReadIniBoolean(IniFile: TMemINIFile; Section, ValueName: string): boolean;
    procedure WriteIniBoolean(IniFile: TMemINIFile; Section, ValueName: string;
      Value: boolean);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  Ini: TMemINIFile;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MonitorButtonClick(Sender: TObject);
begin
  Hide;
end;

procedure TForm1.FormHide(Sender: TObject);
begin
  InPath := InputEdit.Text;
  Ini.WriteString('Default', 'InPath', InputEdit.Text);
  Timer1.Interval := StrToInt(IntervalText.Text) * 1000;
  Ini.WriteString('Default', 'Interval', IntervalText.Text);
  OutPath := OutputEdit.Text;
  Ini.WriteString('Default', 'OutPath', OutputEdit.Text);
  FileType := FileExtension.Text;
  Ini.WriteString('Default', 'FileExtension', FileExtension.Text);
  WriteIniBoolean(Ini, 'Default', 'CreateFolders', CreateFolders.Checked);
  CreateFoldersFlag := CreateFolders.Checked;
  WriteIniBoolean(Ini, 'Default', 'AlwaysOnTop', ModalWindow.Checked);
  WriteIniBoolean(Ini, 'Default', 'RunMinimized', RunMinimized.Checked);
  WriteIniBoolean(Ini, 'Default', 'TrayMenu', TrayMenu.Checked);
  WriteIniBoolean(Ini, 'Default', 'PromptDeletion', PromptDeletion.Checked);
  PromptDeletionFlag := PromptDeletion.Checked;
  Ini.UpdateFile;
  if not TrayMenu.Checked then
    TrayIcon1.PopupMenu := nil;
  TrayIcon1.Show;
  Timer1.Enabled := True;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if (FileExists('filemon.ini')) then
  begin
    Ini := TMemINIFile.Create('filemon.ini');
    InPath := Ini.ReadString('Default', 'InPath', '');
    InputEdit.Text := InPath;
    OutPath := Ini.ReadString('Default', 'OutPath', '');
    OutputEdit.Text := OutPath;
    IntervalText.Text := Ini.ReadString('Default', 'Interval', '');
    Timer1.Interval := StrToInt(IntervalText.Text) * 1000;
    FileType := Ini.ReadString('Default', 'FileExtension', '');
    FileExtension.Text := FileType;
    CreateFoldersFlag := ReadIniBoolean(Ini, 'Default', 'CreateFolders');
    CreateFolders.Checked := CreateFoldersFlag;
    ModalWindow.Checked := ReadIniBoolean(Ini, 'Default', 'AlwaysOnTop');
    RunMinimized.Checked := ReadIniBoolean(Ini, 'Default', 'RunMinimized');
    TrayMenu.Checked := ReadIniBoolean(Ini, 'Default', 'TrayMenu');
    PromptDeletion.Checked := ReadIniBoolean(Ini, 'Default', 'PromptDeletion');
    PromptDeletionFlag := PromptDeletion.Checked;
  end
  else
  begin
    Application.MessageBox('Не найден INI-файл.', 'Ошибка!', MB_ICONERROR);
    Application.Terminate;
  end;
  if not TrayMenu.Checked then
    TrayIcon1.PopupMenu := nil;
  if RunMinimized.Checked then
  begin
    Application.ShowMainForm := False;
    TrayIcon1.Show;
    Timer1.Enabled := True;
    //    Hide;
  end;
end;

function TForm1.ReadIniBoolean(IniFile: TMemINIFile;
  Section, ValueName: string): boolean;
var
  ValueStr: string;
begin
  ValueStr := LowerCase(IniFile.ReadString(Section, ValueName, ''));
  if (ValueStr = 'yes') or (ValueStr = 'true') then
    Result := True
  else
    Result := False;
end;

procedure TForm1.WriteIniBoolean(IniFile: TMemINIFile; Section, ValueName: string;
  Value: boolean);
begin
  if Value then
    IniFile.WriteString(Section, ValueName, 'Yes')
  else
    IniFile.WriteString(Section, ValueName, 'No');
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  TrayIcon1.Hide;
  Timer1.Enabled := False;
end;


procedure TForm1.IntervalTextChange(Sender: TObject);
var
  TimerValue: integer;
begin
  try
    TimerValue := StrToInt(IntervalText.Text);
  except
    begin
      Application.MessageBox('Интервал не меньше 5 сек.', 'Ошибка!', MB_ICONERROR);
      IntervalText.Text := '5';
    end;
  end;
  if TimerValue < 5 then
  begin
    Application.MessageBox('Интервал не меньше 5 сек.', 'Ошибка!', MB_ICONERROR);
    IntervalText.Text := '5';
  end;
end;

procedure TForm1.ShowItemClick(Sender: TObject);
begin
  WindowState := wsNormal;
  Show;
end;

procedure TForm1.ExitButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.InputEditClick(Sender: TObject);
begin
  SelectDirectoryDialog1.FileName := InputEdit.Text;
  if SelectDirectoryDialog1.Execute then
    InputEdit.Text := SelectDirectoryDialog1.FileName + '\';
end;

procedure TForm1.OutputEditClick(Sender: TObject);
begin
  SelectDirectoryDialog1.FileName := OutputEdit.Text;
  if SelectDirectoryDialog1.Execute then
    OutputEdit.Text := SelectDirectoryDialog1.FileName + '\';
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  Info: TSearchRec;
begin
  Timer1.Enabled := False;
  ProcessFiles();
  Timer1.Enabled := True;
end;

procedure TForm1.RunNowClick(Sender: TObject);
begin
  Timer1.Enabled := False;
  ProcessFiles();
  Timer1.Enabled := True;
end;

procedure TForm1.ProcessFiles();
var
  Info: TSearchRec;
begin
  if FindFirst(InputEdit.Text + '*.' + FileType, faAnyFile, Info) = 0 then
  begin
    repeat
      FrameName := Info.Name;
      if ModalWindow.Checked then
      begin
        Form2.BorderIcons := Form2.BorderIcons - [biMaximize] - [biMinimize];
        Form2.FormStyle := fsSystemStayOnTop;
        Form2.showModal;
        Form2.Close;
      end
      else
      begin
        Form2.BorderIcons := Form2.BorderIcons + [biMaximize] + [biMinimize];
        Form2.FormStyle := fsNormal;
        Form2.showModal;
        Form2.Close;
      end;
    until FindNext(Info) <> 0;
  end;
  FindClose(Info);
  Form2.OutFileName.Text := '';
  Form2.OutFileName2.Text := '';
  Form2.OutFileName3.Text := '';
  Form2.OutID.Text := '';
end;

end.
