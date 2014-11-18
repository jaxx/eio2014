program jalu;

{$mode objfpc}{$H+}

uses
  strutils,
  SysUtils;

  function TeisendaAegSekunditeks(const Aeg: string): integer;
  var
    MinutitePos, SekunditePos: byte;
    Minutid, Sekundid: smallint;
  begin
    Minutid := 0;
    Sekundid := 0;

    MinutitePos := Pos('m', Aeg);
    SekunditePos := Pos('s', Aeg);

    if MinutitePos <> 0 then
    begin
      Minutid := StrToInt(Copy(Aeg, 0, MinutitePos - 1));
      Sekundid := StrToInt(Copy(Aeg, MinutitePos + 1, SekunditePos - MinutitePos - 1));
    end
    else
      Sekundid := StrToInt(Copy(Aeg, 0, SekunditePos - 1));

    Result := Minutid * 60 + Sekundid;
  end;

  function ArvutaTeepikkus(const Kirje: string; out AegKokku: integer): single;
  var
    Aeg, Kiirus: string;
    AegSekundites, KiirusSekundites: integer;
  begin
    Aeg := ExtractWord(1, Kirje, [' ']);

    Kiirus := ExtractWord(3, Kirje, [' ']);
    Kiirus := Copy(Kiirus, 0, Pos('/', Kiirus) - 1);

    AegSekundites := TeisendaAegSekunditeks(Aeg);
    KiirusSekundites := TeisendaAegSekunditeks(Kiirus);

    AegKokku := AegKokku + AegSekundites;

    Result := AegSekundites / KiirusSekundites * 1000;
  end;

var
  Fail: TextFile;
  Kirje: string;
  TeepikkusKokku, KeskmineKiirus: single;
  AegKokku: integer;

begin
  TeepikkusKokku := 0;
  AegKokku := 0;

  try
    AssignFile(Fail, 'input/input0.txt');
    Reset(Fail);

    ReadLn(Fail);

    repeat
      ReadLn(Fail, Kirje);
      TeepikkusKokku := TeepikkusKokku + ArvutaTeepikkus(Kirje, AegKokku);
    until EOF(Fail);
  finally
    CloseFile(Fail);
  end;

  KeskmineKiirus := 3.6 * TeepikkusKokku / AegKokku;

  try
    AssignFile(Fail, 'output/output0.txt');
    Rewrite(Fail);

    WriteLn(Fail, FormatFloat('0m', TeepikkusKokku));
    WriteLn(Fail, FormatFloat('0.000km/h', KeskmineKiirus));
  finally
    CloseFile(Fail);
  end;
end.
