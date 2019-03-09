unit numericedit;

{$mode objfpc}{$H+}

interface
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     //by humberto
uses
  Classes, SysUtils, math, strutils, StdCtrls, LResources, LCLType, Controls,
  Clipbrd;

type

  ////////////////////////TNumericEdit///////////////////////////////
  //   Desenvolvedor: Humberto Sales                               //
  //   Email        : humbertoliveira@hotmail.com                  //
  //   Telegram     : https://t.me/joinchat/CSQp_RFqlyfvOQYE5oKKZw //
  //   Colaboradores:                                              //
  //        (informe nomes aqui - caso seja um colaborador)        //
  //        *                                                      //
  //        *                                                      //
  //                                                               //
  ///////////////////////////////////////////////////////////////////

  { TNumericEdit }

  TNumericEdit = Class(TCustomEdit)
  private
    FCurrencyValue: Boolean;
    FDecimalRound: ShortInt;
    FDecimals: ShortInt;
    FInvalidEntry: TNotifyEvent;
    FValidChange: TNotifyEvent;
    FMaxValue: Double;
    FMinValue: Double;
    FormatMask: String;
    function ConfigCurrency(AValue: String; Ative: boolean): String;
    procedure DeleteKey(Key: Word);
    procedure DeleteSelection;
    function GetAsCurrency: Currency;
    function GetAsFloat: Double;
    function GetAsFormatCurrency: String;
    function GetAsInteger: Integer;
    function GetAsRound: Double;
    function GetValue: Double;
    procedure SetAsCurrency(AValue: Currency);
    procedure SetAsFloat(AValue: Double);
    procedure SetAsInteger(AValue: Integer);
    procedure SetCurrencyValue(AValue: Boolean);
    procedure SetDecimalRound(AValue: ShortInt);
    procedure SetDecimals(AValue: ShortInt);
    procedure SetFormatMask;
    procedure SetMaxValue(AValue: Double);
    procedure SetMinValue(AValue: Double);
    procedure SetValue(AValue: Double);
    procedure InvalidEntry;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property AsCurrency       : Currency read GetAsCurrency write SetAsCurrency;
    property Asinteger        : Integer  read GetAsInteger  Write SetAsInteger;
    property AsFloat          : Double   read GetAsFloat    write SetAsFloat;
    property AsRound          : Double   read GetAsRound;
    property AsFormatCurrency : String   read GetAsFormatCurrency;
  published
    property Decimals         : ShortInt     read FDecimals      write SetDecimals;
    property DecimalRound     : ShortInt     read FDecimalRound  write SetDecimalRound;
    property MaxValue         : Double       read FMaxValue      write SetMaxValue;
    property MinValue         : Double       read FMinValue      write SetMinValue;
    property Value            : Double       read GetValue       write SetValue;
    property CurrencyValue    : Boolean      read FCurrencyValue write SetCurrencyValue;
    property OnValidChange    : TNotifyEvent read FValidChange   write FValidChange;
    property OnInvalidEntry   : TNotifyEvent read FInvalidEntry  write FInvalidEntry;
    property AutoSelect;
    property AutoSize;
    property BorderStyle;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property MaxLength;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  protected
    procedure Change; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  end;

procedure Register;


implementation

procedure Register;
begin
  {$i numericedit.lrs}
 RegisterComponents('Humberto',[TNumericEdit]);
end;


procedure TNumericEdit.SetDecimals(AValue: ShortInt);
begin
  if FCurrencyValue then
      if AValue < 2 then
         Raise Exception.Create('Decimals não pode ser menor que 2 pois a propriedade CurrencyValue está ativada!');
    if FDecimals = AValue then Exit;
    if AValue > 9 then
         FDecimals := 9
    else
         FDecimals:= AValue;
    SetFormatMask;
end;

procedure TNumericEdit.SetMaxValue(AValue: Double);
begin
  if FMaxValue=AValue then Exit;
     FMaxValue:=AValue;
end;

procedure TNumericEdit.SetMinValue(AValue: Double);
begin
  if FMinValue=AValue then Exit;
     FMinValue:=AValue;
end;

procedure TNumericEdit.SetValue(AValue: Double);
var
  NewText: string;
  ChangeEvent: TNotifyEvent;
  DisabledOnChange: boolean;
begin
  DisabledOnChange:= csReading in ComponentState;
  ChangeEvent := onChange;
  if DisabledOnChange then
     onChange := nil;
  NewText := FormatFloat(FormatMask, AValue);
  if Text <> NewText then
     Text := NewText;
  onChange := ChangeEvent;
end;

procedure TNumericEdit.InvalidEntry;
begin
  if assigned(FInvalidEntry) then
    FInvalidEntry(Self);
end;

constructor TNumericEdit.Create(AOwner: TComponent);
begin
  FormatSettings.ThousandSeparator := '.';
  FormatSettings.DecimalSeparator := ',';
  inherited Create(AOwner);
  DecimalSeparator:= ',';
  ControlStyle := ControlStyle - [csSetCaption];
  Text:= '0' + DecimalSeparator + '00';
  Width := 73;
  FDecimals := 2;
  FDecimalRound := 2;
  FMaxValue := 0;
  FMinValue := 0;
  Value := 0;
  SetFormatMask;
  Alignment:= taRightJustify;
end;

destructor TNumericEdit.Destroy;
begin
  inherited Destroy;
end;

procedure TNumericEdit.Change;
var
  NumVal: extended;
begin
  inherited Change;
  NumVal:= Value;
  if (NumVal >= MinValue) and (NumVal <= MaxValue) then
    begin
      if Assigned(FValidChange) then
         FValidChange(Self);
    end
    else
      if Assigned(FInvalidEntry) then
         FInvalidEntry(Self)
end;

procedure TNumericEdit.DoEnter;
begin
  if AutoSelect and not (csLButtonDown in ControlState) then
    SelectAll;
  if FCurrencyValue then
     Text := ConfigCurrency(Text,False);
  inherited DoEnter;
end;

procedure TNumericEdit.DoExit;
begin
  SELSTART := MAXLENGTH;
  if FMinValue <> FMaxValue then
    if (AsFloat < FMinValue) or (AsFloat > FMaxValue) then
       InvalidEntry;
   if FCurrencyValue then
      Text := ConfigCurrency(Text,True);
  inherited DoExit;
end;

procedure TNumericEdit.KeyPress(var Key: Char);
var
  X: Integer;
  N: Boolean;
begin
  if (Key = #13) or (Key = #27) then
     Key := #0;
  if ReadOnly then exit;
  { Ctrl C, V and X. }
  if Key in [#3, #22, #24] then exit;
      if Key = DecimalSeparator then
        SelLength := 0
      else
        if (SelLength > 0) then DeleteSelection;
           N := (Pos('-', Text) > 0);
  if not (Key in ['0'..'9', DecimalSeparator, '-', #3, #8, #22, #24]) then
    Key := #0;
  if (SelStart = 0) and (Key = '0') then
    Key := #0;
  if (Key = DecimalSeparator) and (FDecimals = 0) then Key := #0;
  if (Key = '-') then
      begin
        if MinValue < 0 then
           begin
             X:= SelStart;
             if Pos('-', Text) = 0 then
                begin
                  Text:= '-' + Text;
                  SelStart := X + 1;
                end
                else begin
                  Text:= Copy(Text, 2, Length(Text) - 1);
                  SelStart:= X - 1;
                end;
           end;
        Key := #0;
      end;
  if (SelStart = Length(Text)) and (Key <> #8) and (Key <> DecimalSeparator) and (FDecimals > 0) then
     Key := #0;
  if Key = DecimalSeparator then
     begin
       SelStart := Length(Text) - FDecimals;
       Key := #0;
     end;
  if N and (SelStart = 0) then SelStart := 1;
      if Key <> #0 then
        if Key = #8 then
          begin
            if SelLength > 0 then DeleteSelection else DeleteKey(VK_BACK);
            Key := #0;
          end
          else
             if FDecimals = 0 then
               begin
                 if (SelStart <= 2) and (Copy(Text, 2, 1) = '0') and N then
                 begin
                   Text:= '-' + Key;
                   SelLength:= 0;
                   SelStart:= 1;
                   Key:= #0;
                 end else
                   if (SelStart <= 1) and (Copy(Text, 1, 1) = '0') then
                   begin
                     Text:= Key;
                     SelLength:= 0;
                     SelStart:= 1;
                     Key:= #0;
                   end;
               end
             else begin
                 if (SelStart <= 2) and (Copy(Text, 2, 1) = '0') and N then
                     begin
                       Text:= '-' + Key + Copy(Text, 3, Length(Text) - 2);
                       SelLength:= 0;
                       SelStart:= 2;
                       Key:= #0;
                     end else
                       if (SelStart <= 1) and (Copy(Text, 1, 1) = '0') then
                           begin
                             Text:= Key + Copy(Text, 2, Length(Text) - 1);
                             SelLength:= 0;
                             SelStart:= 1;
                             Key:= #0;
                           end else
                             if SelStart >= (Length(Text) - FDecimals) then
                                 begin
                                     X:= SelStart;
                                     Text:= Copy(Text, 1, SelStart) + Key + Copy(Text, SelStart + 2, Length(Text));
                                     SelStart:= X + 1;
                                     SelLength:= 0;
                                     Key:= #0;
                                 end else
                                   if SelStart < (Length(Text) - FDecimals) - 1 then
                                       begin
                                         X:= SelStart;
                                         if SelStart + SelLength > Length(Text) - FDecimals then
                                           dec(X);
                                         Text:= Copy(Text, 1, SelStart) + Key + Copy(Text, SelStart + 1, Length(Text));
                                         SelStart:= X + 1;
                                         SelLength:= 0;
                                         Key:= #0;
                                       end;
             end;
end;

procedure TNumericEdit.KeyDown(var Key: Word; Shift: TShiftState);
var
clp: String;
vlr : double;
txt: TCaption;
i: Integer;
begin
  if not ReadOnly then
    begin
        if Key = VK_DELETE then
            begin
              if SelLength > 0 then
                begin
                  DeleteSelection;
                  Change;
                end
                else
                  DeleteKey(VK_DELETE);
              Key:= 0;
            end;
      if (ssCtrl in Shift) and (key = VK_V) Then
          begin
            if SelText <> '' then
               begin
                  txt := text;
                  txt := ReplaceStr(txt,SelText,Clipboard.Astext);
                  if TextToFloat(pchar(txt),vlr,fvDouble) = false then
                     begin
                        key := 0;
                        raise Exception.Create('Não pode colar. Valor inválido!');
                     end;
               end
               else begin
                   txt := text;
                   clp := Clipboard.Astext;
                   i   := selstart;
                   insert(clp,txt, i);
                   if TextToFloat(pchar(txt),vlr,fvDouble) = false then
                       begin
                          key := 0;
                          raise Exception.Create('Não pode colar. Valor inválido!');
                       end;
               end;
          end;
    end;
  inherited KeyDown(Key, Shift)

end;

procedure TNumericEdit.DeleteKey(Key: Word);
var
  P: Integer;
  N: Boolean;
begin
  if Key = VK_DELETE then
    P := SelStart + 1
  else
    P := SelStart;
  N := (Pos('-', Text) > 0);
  if (P = 0) or (P = Length(Text) + 1) then
    exit;
  if FDecimals = 0 then
  begin
    if (P = 2) and (Length(Text) = 2) and N then
    begin
      Text := '-0' + Copy(Text, 3, Length(Text) - 2);
      SelStart := 1;
    end else
      if (P = 1) and (Length(Text) = 1) then
      begin
        Text := '0' + Copy(Text, 2, Length(Text) - 1);
        SelStart := 1;
      end else
      begin
        Text := Copy(Text, 1, P - 1) + Copy(Text, P + 1, Length(Text) - P);
        SelStart := P - 1;
      end
  end else
  begin
    if P > (Length(Text) - FDecimals) then
    begin
      Text := Copy(Text, 1, P - 1) + Copy(Text, P + 1, Length(Text) - P) + '0';
      SelStart := P - 1;
    end else
      if (P = (Length(Text) - FDecimals)) then
        if Key = VK_DELETE then
          SelStart := (Length(Text) - FDecimals)
        else
          SelStart := (Length(Text) - FDecimals) - 1
      else
        if (P = 2) and (P = (Length(Text) - FDecimals) - 1) and N then
        begin
          Text := '-0' + Copy(Text, 3, Length(Text) - 2);
          SelStart := 1;
        end else
          if (P = 1) and (P = (Length(Text) - FDecimals) - 1) then
          begin
            Text := '0' + Copy(Text, 2, Length(Text) - 1);
            SelStart := 1;
          end else
            if P > 0 then
            begin
                Text := Copy(Text, 1, P - 1) + Copy(Text, P + 1, Length(Text) - P);
                SelStart := P - 1;
            end;
  end;
end;


procedure TNumericEdit.DeleteSelection;
var
  X: Integer;
  Y: Integer;
  ChangeEvent: TNotifyEvent;
begin
  ChangeEvent:= onChange;
  onChange:= nil;
  if SelLength = 0 then exit;
  Y := Length(SelText);
  SelStart := SelStart + Y;
  for X:= 1 to Y do
  begin
    DeleteKey(VK_BACK);
  end;
  onChange:= ChangeEvent;
end;

function TNumericEdit.GetAsCurrency: Currency;
begin
  Result := StrToCurr(Text);
end;

function TNumericEdit.GetAsFloat: Double;
begin
  Result := StrToFloat(Text);
end;

function TNumericEdit.GetAsFormatCurrency: String;
begin
  Result := FormatFloat('R$#,##0.' + StringOfChar('0',Decimals),value);
end;

function TNumericEdit.GetAsInteger: Integer;
begin
  Result := trunc(StrToFloat(Text));
end;

function TNumericEdit.GetAsRound: Double;
var
   Pow, PowValue, RestPart, FracValue : Extended;
   IntCalc, FracCalc, LastNumber, IntValue : Int64;
begin
   Pow       := intpower(10, abs(FDecimalRound) );
   PowValue  := Value / 10 ;
   IntValue  := trunc(PowValue);
   FracValue := frac(PowValue);

   PowValue := SimpleRoundTo(FracValue * 10 * Pow, -9) ; // SimpleRoundTo elimina ﻿dizimas ;
   IntCalc  := trunc( PowValue );
   FracCalc := trunc( frac( PowValue ) * 100);

   if (FracCalc > 50) then
      Inc( IntCalc )

   else if (FracCalc = 50) then
    begin
      LastNumber := trunc( frac( IntCalc / 100) * 10);

      if odd(LastNumber) then
         Inc( IntCalc )
      else
       begin
         RestPart := frac( PowValue * 10 ) ;

         if RestPart > 0 then
            Inc( IntCalc );
       end ;
    end ;

   Result := ((IntValue*10) + (IntCalc / Pow));
end;



function TNumericEdit.GetValue: Double;
begin
  if text <> '' then
     if FCurrencyValue then
         if text <> '0,00' then
            Result := StrToFloat( ConfigCurrency(Text,false) )
         else
            Result := StrToFloat(Text)
     else
         Result := StrToFloat(Text);
end;

procedure TNumericEdit.SetAsCurrency(AValue: Currency);
begin
  if text <> '' then
     Text := FormatFloat(FormatMask, Value);
end;

procedure TNumericEdit.SetAsFloat(AValue: Double);
begin
  if text <> '' then
     Text := FormatFloat(FormatMask, Value);
end;

procedure TNumericEdit.SetAsInteger(AValue: Integer);
begin
  if text <> '' then
     Text := FormatFloat(FormatMask, Value);
end;

Function TNumericEdit.ConfigCurrency(AValue : String; Ative : boolean) : String;
var
   vlr : Extended;
   I: Integer;
begin
  Case Ative of
        false  :
                  begin
                      AValue := ReplaceStr(AValue,FormatSettings.ThousandSeparator,'');
                      AValue := ReplaceStr(AValue,'R$ ','');
                      Result := AValue;
                  end;
        True   :
                  begin

                           for I := 0 to Length(AValue) - 1 do
                               if not(AValue[I] in ['0' .. '9']) then
                                  delete(AValue, I, 1);
                           vlr := StrToFloatDef(AValue, 0) / 100;
                           AValue := 'R$ ' +Format('%n', [vlr]);
                           Result := AValue;
                  end;
  end;

end;

procedure TNumericEdit.SetCurrencyValue(AValue: Boolean);
begin
  if FCurrencyValue=AValue then Exit;
  if FDecimals < 2 then
       Raise Exception.Create('Decimals não pode ser menor que 2');
  FCurrencyValue:=AValue;
  Case AValue of
     true  : Text := ConfigCurrency(Text,True);
     False : Text := ConfigCurrency(Text,False);
  end;
end;

procedure TNumericEdit.SetDecimalRound(AValue: ShortInt);
begin
  if FDecimalRound=AValue then Exit;
  FDecimalRound:=AValue;
end;

procedure TNumericEdit.SetFormatMask;
  function StringOfChar(const Character: Char; const StrLength: word): string;
  var
    OutString: String[255];
  begin
    FillChar(OutString, SizeOf(OutString), ord(Character));
    OutString[0]:= chr(StrLength);
    StringOfChar:= OutString;
  end;
var
  ChangeEvent: TNotifyEvent;
begin
  if FDecimals = 0 then
     FormatMask := '0'
  else
     FormatMask := '0.' + StringOfChar('0', FDecimals);
  ChangeEvent:= onChange;
  onChange:= nil;
  try
    Text := FormatFloat(FormatMask, AsFloat);
  finally
    onChange:= ChangeEvent;
  end;
end;



end.


