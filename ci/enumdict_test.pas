program enumdict_test;
// Checks whether TDictionary with an enum key works with this FPC/CPU combination.
{$mode delphi}{$H+}
uses Classes, SysUtils, Generics.Collections;
type
  TNT = (a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14);
var
  D: TDictionary<TNT, TStringList>;
  L, R: TStringList;
  n: TNT;
  Fails: Integer;
begin
  Fails := 0;
  D := TDictionary<TNT, TStringList>.Create;
  for n := Low(TNT) to High(TNT) do begin
    if not D.ContainsKey(n) then begin
      L := TStringList.Create;
      D.Add(n, L);
    end;
    R := nil;
    if (not D.TryGetValue(n, R)) or (R = nil) then
      Inc(Fails);
  end;
  WriteLn('enum-key dictionary lookup failures: ', Fails, ' of ', Ord(High(TNT))+1);
end.
