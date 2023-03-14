program CharManiac;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils;

type
  TEncodingInfo = record
    Encoding: TEncoding;
    OwnEncoding: Boolean;
    HasPreamble: Boolean;
    NewLine: string;
    procedure Release;
  end;

  TUTF8EncodingWithoutBom = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

  TUnicodeEncodingWithoutBom = class(TUnicodeEncoding)
  public
    function GetPreamble: TBytes; override;
  end;

  TStreamReaderHelper = class helper for TStreamReader
    function GetLastChar: Char;
  end;

procedure DumpUsage;
begin
  WriteLn('CharManiac SourceEncoding TargetEncoding SourceFile TargetFile');
  WriteLn('Possible text encodings:');
  WriteLn(' ASCII');
  WriteLn(' ANSI');
  WriteLn(' UTF-8(-BOM)');
  WriteLn(' Unicode(-BOM)');
  WriteLn('');
  WriteLn('Optional newline config, append to TargetEncoding:');
  WriteLn(' -UnixNewLine');
  WriteLn(' -WindowsNewLine');
  WriteLn('');
  WriteLn('Examples for valid encodings:');
  WriteLn(' UTF-8-UnixNewLine');
  WriteLn(' Unicode-BOM-WindowsNewLine');
  WriteLn('');
  WriteLn('Warning: TargetFile will be overwritten.');
end;

function IsValidEncoding(const AEncName: string;
  out AEncInfo: TEncodingInfo): Boolean;

  function HasEncFlag(const CheckFlag: string): Boolean;
  begin
    Result := ContainsText(AEncName, CheckFlag);
  end;

  function HasEncBomFlag: Boolean;
  begin
    Result := HasEncFlag('-BOM');
  end;

  function HasEncNewLineFlag(out NewLine: string): Boolean;
  begin
    Result := True;
    if HasEncFlag('-UnixNewLine') then
      NewLine := #10
    else if HasEncFlag('-WindowsNewLine') then
      NewLine := #13#10
    else
      Result := False;
  end;

var
  NewLine: string;
begin
  Result := True;
  AEncInfo := Default (TEncodingInfo);

  if StartsText('ASCII', AEncName) then
  begin
    AEncInfo.Encoding := TEncoding.ASCII;
  end
  else if StartsText('ANSI', AEncName) then
  begin
    AEncInfo.Encoding := TEncoding.ANSI;
  end
  else if StartsText('UTF-8', AEncName) then
  begin
    if HasEncBomFlag then
    begin
      AEncInfo.Encoding := TEncoding.UTF8;
      AEncInfo.HasPreamble := True;
    end
    else
    begin
      AEncInfo.Encoding := TUTF8EncodingWithoutBom.Create;
      AEncInfo.OwnEncoding := True;
    end;
  end
  else if StartsText('Unicode', AEncName) then
  begin
    if HasEncBomFlag then
    begin
      AEncInfo.Encoding := TEncoding.Unicode;
      AEncInfo.HasPreamble := True;
    end
    else
    begin
      AEncInfo.Encoding := TUnicodeEncodingWithoutBom.Create;
      AEncInfo.OwnEncoding := True;
    end;
  end
  else
    Result := False;

  if Result then
  begin
    if HasEncNewLineFlag(NewLine) then
      AEncInfo.NewLine := NewLine
    else
      AEncInfo.NewLine := sLineBreak;
  end;
end;

procedure Convert(const ASourceEnc: TEncodingInfo;
  const ATargetEnc: TEncodingInfo; const ASourceFileName: string;
  const ATargetFileName: string);
var
  SourceReader: TStreamReader;
  TargetWriter: TStreamWriter;
  Line: string;

  function IsLastCharCrOrLf: Boolean;
  begin
    var LastChar := SourceReader.GetLastChar;
    Result := (LastChar = #10) or (LastChar = #13);
  end;

begin
  TargetWriter := nil;
  SourceReader := TStreamReader.Create(ASourceFileName, ASourceEnc.Encoding);
  try
    TargetWriter := TStreamWriter.Create(ATargetFileName, False,
      ATargetEnc.Encoding);
    TargetWriter.NewLine := ATargetEnc.NewLine;

    while not SourceReader.EndOfStream do
    begin
      Line := SourceReader.ReadLine;
      if SourceReader.EndOfStream and not IsLastCharCrOrLf then
        TargetWriter.Write(Line)
      else
        TargetWriter.WriteLine(Line);
    end;
  finally
    SourceReader.Free;
    TargetWriter.Free;
  end;
end;

{ TUTF8EncodingWithoutBom }

function TUTF8EncodingWithoutBom.GetPreamble: TBytes;
begin
  Result := nil;
end;

{ TUnicodeEncodingWithoutBom }

function TUnicodeEncodingWithoutBom.GetPreamble: TBytes;
begin
  Result := nil;
end;

{ TEncodingInfo }

procedure TEncodingInfo.Release;
begin
  if OwnEncoding then
    FreeAndNil(Encoding);
end;

{ TStreamReaderHelper }

function TStreamReaderHelper.GetLastChar: Char;
begin
  Result := FBufferedData.Chars[FBufferedData.Length - 1];
end;

var
  SourceEnc: TEncodingInfo;
  TargetEnc: TEncodingInfo;
begin
  try
    try
      if (ParamCount = 4) and IsValidEncoding(ParamStr(1), SourceEnc) and
        IsValidEncoding(ParamStr(2), TargetEnc) and FileExists(ParamStr(3)) then
      begin
        Convert(SourceEnc, TargetEnc, ParamStr(3), ParamStr(4));
      end
      else
        DumpUsage;
    finally
      SourceEnc.Release;
      TargetEnc.Release;
    end;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
end.
