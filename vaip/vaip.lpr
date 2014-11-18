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

  function AnnaVaipadeYhinePindala(Vaip1, Vaip2: TVaip): int64;
  var
    KattuvX, KattuvY: int64;
  begin
    KattuvX := Max(0, Min(Vaip1.B.X, Vaip2.B.X) - Max(Vaip1.A.X, Vaip2.A.X));
    KattuvY := Max(0, Min(Vaip1.B.Y, Vaip2.B.Y) - Max(Vaip1.A.Y, Vaip2.A.Y));

    Result := KattuvX * KattuvY;
  end;

  function AnnaVaipadegaKaetudPindala(Vaibad: TVaipArray): int64;
  var
    I, J: integer;
    KoguPindala, KattuvPindala: int64;
  begin
    KattuvPindala := 0;
    KoguPindala := AnnaVaibaPindala(Vaibad[High(Vaibad)]);

    for I := 0 to High(Vaibad) - 1 do
    begin
      KoguPindala := KoguPindala + AnnaVaibaPindala(Vaibad[I]);

      for J := I + 1 to High(Vaibad) do
      begin
        KattuvPindala := KattuvPindala + AnnaVaipadeYhinePindala(Vaibad[I], Vaibad[J]);
      end;
    end;

    Result := KoguPindala - KattuvPindala;
  end;

var
  Fail: TextFile;
  Rida: string;
  Porand: TPorand;
  VaipadeArv: byte;
  Vaibad: TVaipArray;

begin
  try
    AssignFile(Fail, 'input/input11.txt');
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
    AssignFile(Fail, 'output/output.txt');
    Rewrite(Fail);

    WriteLn(Fail, AnnaVaipadegaKaetudPindala(Vaibad));
  finally
    CloseFile(Fail);
  end;
end.
