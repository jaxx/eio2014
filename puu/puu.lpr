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

  procedure LoeAlluvad(PuuAlgmaterjal: array of string; var Ylem: TTipp);
  var
    Rida: string;
    I, OtsitavRida, AlluvateArv: smallint;
    Alluv: TTipp;
  begin
    OtsitavRida := Ylem.TipuVaartus;
    Rida := PuuAlgmaterjal[OtsitavRida - 1];

    AlluvateArv := StrToInt(ExtractWord(1, Rida, [' ']));

    for I := 1 to AlluvateArv do
    begin
      Alluv := TTipp.Create(StrToInt(ExtractWord(I + 1, Rida, [' '])));
      LoeAlluvad(PuuAlgmaterjal, Alluv);

      Ylem.LisaAlluv(Alluv);
    end;
  end;

  function EhitaPuu(var Fail: TextFile; const TippeKokku: smallint): TTipp;
  var
    I: smallint;
    PuuAlgmaterjal: array of string;
  begin
    SetLength(PuuAlgmaterjal, TippeKokku);

    for I := 0 to TippeKokku - 1 do
      ReadLn(Fail, PuuAlgmaterjal[I]);

    Result := TTipp.Create(1);
    LoeAlluvad(PuuAlgmaterjal, Result);
  end;

var
  Fail: TextFile;
  Rida: string;
  TippeKokku, UusJuurTipp: smallint;
  Ounapuu: TTipp;

begin
  try
    AssignFile(Fail, 'input/input15.txt');
    Reset(Fail);

    ReadLn(Fail, Rida);

    TippeKokku := StrToInt(ExtractWord(1, Rida, [' ']));
    UusJuurTipp := StrToInt(ExtractWord(2, Rida, [' ']));

    Ounapuu := EhitaPuu(Fail, TippeKokku);
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
