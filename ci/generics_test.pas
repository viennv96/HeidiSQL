program generics_test;
// Broad check of Generics.Collections dictionaries on this FPC/CPU combination.
{$mode delphi}{$H+}
uses Classes, SysUtils, Generics.Collections;
type
  TNT = (a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14);
  {$PACKENUM 4}
  TNT4 = (b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14);
  {$PACKENUM DEFAULT}
var
  Report: String;

procedure Check(const Name: String; Fails, Total: Integer);
begin
  Report := Report + Format('%s=%d/%d; ', [Name, Fails, Total]);
end;

procedure TestEnum;
var D: TDictionary<TNT, TObject>; n: TNT; o: TObject; f: Integer;
begin
  f := 0; D := TDictionary<TNT, TObject>.Create;
  for n := Low(n) to High(n) do D.Add(n, TObject(PtrUInt(Ord(n)+1)));
  for n := Low(n) to High(n) do if (not D.TryGetValue(n, o)) or (PtrUInt(o) <> PtrUInt(Ord(n)+1)) then Inc(f);
  Check('enum(size'+IntToStr(SizeOf(TNT))+')', f, Ord(High(n))+1); D.Free;
end;

procedure TestEnum4;
var D: TDictionary<TNT4, TObject>; n: TNT4; o: TObject; f: Integer;
begin
  f := 0; D := TDictionary<TNT4, TObject>.Create;
  for n := Low(n) to High(n) do D.Add(n, TObject(PtrUInt(Ord(n)+1)));
  for n := Low(n) to High(n) do if (not D.TryGetValue(n, o)) or (PtrUInt(o) <> PtrUInt(Ord(n)+1)) then Inc(f);
  Check('enum4', f, Ord(High(n))+1); D.Free;
end;

procedure TestInt;
var D: TDictionary<Integer, TObject>; i, f: Integer; o: TObject;
begin
  f := 0; D := TDictionary<Integer, TObject>.Create;
  for i := 0 to 999 do D.Add(i, TObject(PtrUInt(i+1)));
  for i := 0 to 999 do if (not D.TryGetValue(i, o)) or (PtrUInt(o) <> PtrUInt(i+1)) then Inc(f);
  Check('int', f, 1000); D.Free;
end;

procedure TestStr;
var D: TDictionary<String, TObject>; i, f: Integer; o: TObject; k: String;
begin
  f := 0; D := TDictionary<String, TObject>.Create;
  for i := 0 to 999 do D.Add('`levnode9_migration2`.`table_'+IntToStr(i)+'`', TObject(PtrUInt(i+1)));
  for i := 0 to 999 do begin
    k := '`levnode9_migration2`.`table_'+IntToStr(i)+'`';
    UniqueString(k);
    if (not D.TryGetValue(k, o)) or (PtrUInt(o) <> PtrUInt(i+1)) then Inc(f);
  end;
  Check('string', f, 1000); D.Free;
end;

procedure TestPtr;
var D: TDictionary<Pointer, String>; i, f: Integer; s: String;
begin
  f := 0; D := TDictionary<Pointer, String>.Create;
  for i := 1 to 1000 do D.Add(Pointer(PtrUInt(i*16)), IntToStr(i));
  for i := 1 to 1000 do if (not D.TryGetValue(Pointer(PtrUInt(i*16)), s)) or (s <> IntToStr(i)) then Inc(f);
  Check('pointer', f, 1000); D.Free;
end;

procedure TestStrCachePattern;
// Same pattern as TDBObject.GetTableColumns: ContainsKey -> AddOrSetValue -> TryGetValue,
// keys built from UTF-8 strings, fresh string instance on every call.
var D: TDictionary<String, TObject>; i, f: Integer; o: TObject; Db, Tbl: UTF8String;
  function Key: String;
  begin
    Result := '`' + Db + '`.`' + Tbl + '`';
  end;
begin
  f := 0; D := TDictionary<String, TObject>.Create;
  Db := 'levnode9_migration2';
  SetCodePage(RawByteString(Db), CP_UTF8, False);
  for i := 0 to 499 do begin
    Tbl := 'dedicated_plans_' + IntToStr(i);
    if not D.ContainsKey(Key) then
      D.AddOrSetValue(Key, TObject(PtrUInt(i+1)));
    o := nil;
    if (not D.TryGetValue(Key, o)) or (PtrUInt(o) <> PtrUInt(i+1)) then Inc(f);
  end;
  Check('string-cache-pattern', f, 500); D.Free;
end;

begin
  Report := '';
  TestEnum; TestEnum4; TestInt; TestStr; TestPtr; TestStrCachePattern;
  WriteLn(Report);
end.
