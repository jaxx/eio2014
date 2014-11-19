program puu;

{$mode objfpc}{$H+}

uses
  strutils,
  SysUtils,
  Classes;

type
  TTipp = class(TObject)
  private
    FTipuVaartus: smallint;
    FYlem: TTipp;
    FAlluvad: TList;
  public
    property TipuVaartus: smallint read FTipuVaartus;
    property Ylem: TTipp read FYlem;
    property Alluvad: TList read FAlluvad;

    constructor Create(Vaartus: smallint);
    destructor Destroy; override;
    procedure LisaAlluv(Alluv: TTipp);
    procedure EemaldaAlluv(TippPtr: Pointer);
    procedure EemaldaYlem;
  end;

  { TTipp }

  constructor TTipp.Create(Vaartus: smallint);
  begin
    FTipuVaartus := Vaartus;
    FAlluvad := TList.Create;
  end;

  destructor TTipp.Destroy;
  begin
    FAlluvad.Free;

    inherited Destroy;
  end;

  procedure TTipp.LisaAlluv(Alluv: TTipp);
  begin
    Alluv.FYlem := Self;
    FAlluvad.Add(Alluv);
  end;

  procedure TTipp.EemaldaYlem;
  begin
    Self.FYlem.FAlluvad.Remove(Self);
    Self.FYlem := nil;
  end;

  procedure TTipp.EemaldaAlluv(TippPtr: Pointer);
  begin
    FAlluvad.Remove(TippPtr);
  end;

  {-------------------------------------------------------------------------------------}
  {-------------------------------------------------------------------------------------}

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

  function LeiaTipp(AlguseTipp: TTipp; TipuVaartus: smallint): TTipp;
  var
    I: smallint;
  begin
    Result := nil;

    if AlguseTipp.TipuVaartus = TipuVaartus then
      Result := AlguseTipp
    else
    begin
      for I := 0 to AlguseTipp.Alluvad.Count - 1 do
      begin
        Result := LeiaTipp(TTipp(AlguseTipp.Alluvad[I]), TipuVaartus);

        if Assigned(Result) then
          Break;
      end;
    end;
  end;

  function AnnaAsukohtNaabriteHulgas(YlemTipp: TTipp; TipuVaartus: smallint): smallint;
  var
    I: smallint;
  begin
    Result := -1;

    for I := 0 to YlemTipp.Alluvad.Count - 1 do
    begin
      if (TTipp(YlemTipp.Alluvad[I]).TipuVaartus = TipuVaartus) and
        (I > 0) {and (I <> YlemTipp.Alluvad.Count - 1)} then
      begin
        Result := I;
        Break;
      end;
    end;
  end;

  procedure MuudaNaabritePositsioonid(var YlemTipp: TTipp; TipuAsukoht: smallint);
  var
    Pos: smallint;
    TempTipp: TTipp;
  begin
    Pos := 0;

    repeat
      TempTipp := TTipp(YlemTipp.Alluvad[0]);
      YlemTipp.EemaldaAlluv(YlemTipp.Alluvad[0]);
      YlemTipp.LisaAlluv(TempTipp);

      Inc(Pos);
    until Pos = TipuAsukoht;
  end;

  procedure SatiAlluvad(var Tipp: TTipp);
  var
    YlemTipp: TTipp;
  begin
    YlemTipp := Tipp.Ylem;

    if not Assigned(YlemTipp) then
      Exit;

    SatiAlluvad(YlemTipp);

    Tipp.EemaldaYlem;
    Tipp.LisaAlluv(YlemTipp);
  end;

  function MuudaJuurikat(var JuurTipp: TTipp; UueJuurikaVaartus: smallint): TTipp;
  var
    YlemTipp: TTipp;
    TipuAsukoht: smallint;
  begin
    Result := LeiaTipp(JuurTipp, UueJuurikaVaartus);
    YlemTipp := Result.Ylem;

    if not Assigned(YlemTipp) then
      Exit;

    TipuAsukoht := AnnaAsukohtNaabriteHulgas(YlemTipp, UueJuurikaVaartus);

    SatiAlluvad(Result);

    if TipuAsukoht <> -1 then
      MuudaNaabritePositsioonid(YlemTipp, TipuAsukoht);

    //SatiAlluvad(Result);
  end;

  procedure VabastaAlluvad(Tipp: TTipp);
  var
    I: smallint;
    Alluv: TTipp;
  begin
    for I := 0 to Tipp.Alluvad.Count - 1 do
    begin
      Alluv := TTipp(Tipp.Alluvad[I]);
      VabastaAlluvad(Alluv);

      Alluv.Free;
    end;
  end;

  procedure PrindiPuuFaili(Puu: TTipp; TippudeArv: smallint; Fail: string);
  var
    Read: TStringList;
    LeitudTipp: TTipp;
    I, J: smallint;
    Rida: string;
  begin
    Read := TStringList.Create;

    try
      for I := 1 to TippudeArv do
      begin
        LeitudTipp := LeiaTipp(Puu, I);

        Rida := Format('%d', [LeitudTipp.Alluvad.Count]);

        for J := 0 to LeitudTipp.Alluvad.Count - 1 do
          Rida := Rida + Format(' %d', [TTipp(LeitudTipp.Alluvad[J]).TipuVaartus]);

        Read.Add(Rida);
      end;

      Read.SaveToFile(Fail);
    finally
      Read.Free;
    end;
  end;

var
  Fail: TextFile;
  Rida: string;
  TippeKokku, UusJuurTipp: smallint;
  Ounapuu: TTipp;

begin
  try
    AssignFile(Fail, 'input/input9.txt');
    Reset(Fail);

    ReadLn(Fail, Rida);

    TippeKokku := StrToInt(ExtractWord(1, Rida, [' ']));
    UusJuurTipp := StrToInt(ExtractWord(2, Rida, [' ']));

    Ounapuu := EhitaPuu(Fail, TippeKokku);
  finally
    CloseFile(Fail);
  end;

  Ounapuu := MuudaJuurikat(Ounapuu, UusJuurTipp);
  PrindiPuuFaili(Ounapuu, TippeKokku, 'output/output.txt');

  VabastaAlluvad(Ounapuu);
  Ounapuu.Free;
end.
