program vaip;

{$mode objfpc}{$H+}

uses
  strutils,
  SysUtils,
  Math;

type
  TPorand = record
    Laius: int64;
    Pikkus: int64;
  end;

  TPunkt = record
    X: int64;
    Y: int64;
  end;

  TVaip = record
    A: TPunkt;
    B: TPunkt;
  end;

  TVaipArray = array of TVaip;

  procedure AnnaVaibad(var Fail: TextFile; var Vaibad: TVaipArray;
  const VaipadeArv: byte; const Porand: TPorand);
  var
    Rida: string;
    I: integer;
  begin
    SetLength(Vaibad, VaipadeArv);

    for I := 0 to High(Vaibad) do
    begin
      ReadLn(Fail, Rida);

      Vaibad[I].A.X := StrToInt(ExtractWord(4, Rida, [' ']));
      Vaibad[I].A.Y := StrToInt(ExtractWord(1, Rida, [' ']));

      Vaibad[I].B.X := Porand.Laius - StrToInt(ExtractWord(3, Rida, [' ']));
      Vaibad[I].B.Y := Porand.Pikkus - StrToInt(ExtractWord(2, Rida, [' ']));
    end;
  end;

  function AnnaVaibaPindala(Vaip: TVaip): int64;
  begin
    Result := (Vaip.B.X - Vaip.A.X) * (Vaip.B.Y - Vaip.A.Y);
  end;

  function KasOnKattuvadVaibad(const Vaip1, Vaip2: TVaip): boolean;
  var
    KattuvX, KattuvY: int64;
  begin
    Result := False;

    KattuvX := Max(0, Min(Vaip1.B.X, Vaip2.B.X) - Max(Vaip1.A.X, Vaip2.A.X));
    KattuvY := Max(0, Min(Vaip1.B.Y, Vaip2.B.Y) - Max(Vaip1.A.Y, Vaip2.A.Y));

    if (KattuvX > 0) and (KattuvY > 0) then
      Result := True;
  end;

  function AnnaKattuvOsa(const Vaip1, Vaip2: TVaip): TVaip;
  begin
    Result.A.X := Max(Vaip1.A.X, Vaip2.A.X);
    Result.A.Y := Max(Vaip1.A.Y, Vaip2.A.Y);
    Result.B.X := Min(Vaip1.B.X, Vaip2.B.X);
    Result.B.Y := Min(Vaip1.B.Y, Vaip2.B.Y);
  end;

  procedure LisaKattuvadOsad(KattuvOsa: TVaip; var KattuvadOsad: TVaipArray);
  var
    I: integer;
    PeabLisama: boolean;
  begin
    PeabLisama := True;

    for I := 0 to High(KattuvadOsad) do
    begin
      if (KattuvOsa.A.X = KattuvadOsad[I].A.X) and (KattuvOsa.A.Y =
        KattuvadOsad[I].A.Y) and (KattuvOsa.B.X = KattuvadOsad[I].B.X) and
        (KattuvOsa.B.Y = KattuvadOsad[I].B.Y) then
        PeabLisama := False;
    end;

    if PeabLisama then
    begin
      SetLength(KattuvadOsad, Length(KattuvadOsad) + 1);
      KattuvadOsad[High(KattuvadOsad)] := KattuvOsa;
    end;
  end;

  function AnnaVaipadegaKaetudPindala(Vaibad: TVaipArray): int64;
  var
    I, J: integer;
    KoguPindala: int64;
    KattuvadOsad: TVaipArray;
  begin
    if not Assigned(Vaibad) then
    begin
      Result := 0;
      Exit;
    end;

    KoguPindala := AnnaVaibaPindala(Vaibad[High(Vaibad)]);

    for I := 0 to High(Vaibad) - 1 do
    begin
      KoguPindala := KoguPindala + AnnaVaibaPindala(Vaibad[I]);

      for J := I + 1 to High(Vaibad) do
      begin
        if KasOnKattuvadVaibad(Vaibad[I], Vaibad[J]) then
          LisaKattuvadOsad(AnnaKattuvOsa(Vaibad[I], Vaibad[J]), KattuvadOsad);
      end;
    end;

    Result := KoguPindala - AnnaVaipadegaKaetudPindala(KattuvadOsad);
  end;

var
  Fail: TextFile;
  Rida: string;
  Porand: TPorand;
  VaipadeArv: byte;
  Vaibad: TVaipArray;

begin
  try
    AssignFile(Fail, 'vaipsis.txt');
    Reset(Fail);

    ReadLn(Fail, Rida);

    VaipadeArv := StrToInt(ExtractWord(1, Rida, [' ']));
    Porand.Laius := StrToInt64(ExtractWord(2, Rida, [' ']));
    Porand.Pikkus := StrToInt64(ExtractWord(3, Rida, [' ']));

    AnnaVaibad(Fail, Vaibad, VaipadeArv, Porand);
  finally
    CloseFile(Fail);
  end;

  try
    AssignFile(Fail, 'vaipval.txt');
    Rewrite(Fail);

    WriteLn(Fail, AnnaVaipadegaKaetudPindala(Vaibad));
  finally
    CloseFile(Fail);
  end;
end.
