program puu;

{$mode objfpc}{$H+}

uses
  strutils,
  SysUtils,
  Classes;

type

  { TTipp }

  PTipp = ^TTipp;

  TTipp = class(TObject)
  private
    FTipuVaartus: smallint;
    FYlem: TTipp;
    FAlluvad: TList;
  public
    property TipuVaartus: smallint read FTipuVaartus write FTipuVaartus;
    property Ylem: TTipp read FYlem;
    property Alluvad: TList read FAlluvad;

    constructor Create(Vaartus: smallint);
    destructor Destroy; override;
    procedure LisaAlluv(Alluv: TTipp);
  end;

  { TTipp }

  constructor TTipp.Create(Vaartus: smallint);
  begin
    FTipuVaartus := Vaartus;
    FAlluvad := TList.Create;
  end;

  destructor TTipp.Destroy;
  var
    I: smallint;
  begin
    for I := 0 to FAlluvad.Count - 1 do
      TTipp(FAlluvad[I]).Free;

    FAlluvad.Free;
    inherited Destroy;
  end;

  procedure TTipp.LisaAlluv(Alluv: TTipp);
  begin
    Alluv.FYlem := Self;
    FAlluvad.Add(Alluv);
  end;

  {-------------------------------------------------------------------------------------}
  {-------------------------------------------------------------------------------------}

  function LeiaTipp(TipuVaartus: smallint; AlgusTipp: TTipp): TTipp;
  var
    I: integer;
  begin
    if AlgusTipp.TipuVaartus = TipuVaartus then
      Result := AlgusTipp
    else
    begin
      for I := 0 to AlgusTipp.Alluvad.Count - 1 do
      begin
        Result := LeiaTipp(TipuVaartus, TTipp(AlgusTipp.Alluvad[I]));
      end;
    end;
  end;

  function EhitaPuu(var Fail: TextFile): TTipp;
  var
    Rida: string;
    I, TipuLugeja, AlluvateArv: smallint;
    LeitudTipp: TTipp;
  begin
    TipuLugeja := 1;
    Result := TTipp.Create(TipuLugeja);

    repeat
      ReadLn(Fail, Rida);

      AlluvateArv := StrToInt(ExtractWord(1, Rida, [' ']));

      if AlluvateArv = 0 then
        Continue;

      LeitudTipp := LeiaTipp(TipuLugeja, Result);

      for I := 1 to AlluvateArv do
        LeitudTipp.LisaAlluv(TTipp.Create(StrToInt(ExtractWord(I + 1, Rida, [' ']))));

      Inc(TipuLugeja);
    until EOF(Fail);
  end;

var
  Fail: TextFile;
  Rida: string;
  UusJuurTipp: smallint;
  Ounapuu: TTipp;

begin
  try
    AssignFile(Fail, 'input/input0.txt');
    Reset(Fail);

    ReadLn(Fail, Rida);

    UusJuurTipp := StrToInt(ExtractWord(2, Rida, [' ']));
    Ounapuu := EhitaPuu(Fail);
  finally
    CloseFile(Fail);
  end;

  try
    AssignFile(Fail, 'output/output.txt');
    Rewrite(Fail);

    WriteLn(Fail, 'Pole veel midagi kirjutada.');
  finally
    CloseFile(Fail);
    Ounapuu.Free;
  end;
end.
