// This is part of the Obo Component Library
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// This software is distributed without any warranty.
//
// @author Domenico Mammola (mimmo71@gmail.com - www.mammola.net)

unit mLookupPanel;

{$mode objfpc}
{$H+}

interface

uses
  Classes, Controls, ExtCtrls, ComCtrls, DB, contnrs,
  Variants,
  ListViewFilterEdit,
  mLookupWindowEvents, mMaps,
  mDatasetStandardSetup, mDataProviderInterfaces;

type

  { TmLookupPanel }

  TmLookupPanel = class (TCustomPanel)
  private
    LValues: TListView;
    LValuesFilter: TListViewFilterEdit;
    FOnSelectAValue : TOnSelectAValue;
    FFieldsList : TStringList;

    FKeyFieldName : String;
    FDataProvider : IVDDataProvider;
    FDisplayFieldNames : TStringList;

    procedure LValuesDblClick (Sender : TObject);
    procedure LValuesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AdjustColumnsWidth;
  protected
    procedure DoOnResize; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure Init(const aDataProvider : IVDDataProvider; const aFieldNames : TStringList; const aKeyFieldName : string; const aDisplayFieldNames : TStringList);
    procedure SetFocusOnFilter;
    procedure GetSelectedValues (out aKeyValue: variant; out aDisplayLabel: string);

    property OnSelectAValue : TOnSelectAValue read FOnSelectAValue write FOnSelectAValue;
  end;

implementation

uses
  SysUtils;

type
  TResultValues = class
    ValueAsVariant : variant;
    DisplayLabel : string;
  end;

{ TmLookupPanel }

procedure TmLookupPanel.LValuesDblClick(Sender: TObject);
var
  tmpDisplayLabel: string;
  tmpKeyValue: variant;
begin
  if (LValues.SelCount = 1) and (Assigned(FOnSelectAValue)) then
  begin
    Self.GetSelectedValues(tmpKeyValue, tmpDisplayLabel);
    FOnSelectAValue(tmpKeyValue, tmpDisplayLabel);
  end;
end;

procedure TmLookupPanel.LValuesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  tmpDisplayLabel: string;
  tmpKeyValue: variant;
begin
  if (Key = 13) and (LValues.SelCount = 1) and (Assigned(FOnSelectAValue)) then
  begin
    Self.GetSelectedValues(tmpKeyValue, tmpDisplayLabel);
    FOnSelectAValue(tmpKeyValue, tmpDisplayLabel);
  end;
end;

procedure TmLookupPanel.AdjustColumnsWidth;
var
  ColWidth : integer;
  i : integer;
begin
  if FFieldsList.Count > 0 then
  begin
    ColWidth := (Self.Width - 30) div FFieldsList.Count;
    LValues.BeginUpdate;
    try
      for i := 0 to LValues.Columns.Count -1 do
        LValues.Columns[i].Width:= ColWidth;
    finally
      LValues.EndUpdate;
    end;
  end;
end;

procedure TmLookupPanel.DoOnResize;
begin
  inherited DoOnResize;
  AdjustColumnsWidth;
end;

procedure TmLookupPanel.GetSelectedValues (out aKeyValue: variant; out aDisplayLabel: string);
var
  i : integer;
begin
  if (LValues.SelCount = 1) then
  begin
    i := UIntPtr(LValues.Selected.Data);
    aKeyValue := FDataProvider.GetDatum(i).GetPropertyByFieldName(FKeyFieldName);
    aDisplayLabel:= ConcatenateFieldValues(FDataProvider.GetDatum(i), FDisplayFieldNames);
  end
  else
  begin
    aDisplayLabel:= '';
    aKeyValue:= null;
  end;
end;

constructor TmLookupPanel.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Self.FOnSelectAValue:= nil;

  Self.BevelInner:= bvNone;
  Self.BevelOuter:= bvNone;
  LValuesFilter := TListViewFilterEdit.Create(Self);
  LValuesFilter.PArent := Self;
  LValuesFilter.Align:= alTop;
  LValuesFilter.ByAllFields:= true;
  LValues:= TListView.Create(Self);
  LValues.Parent := Self;
  LValues.Align:= alClient;
  LValues.OnDblClick:= @LValuesDblClick;
  LValues.GridLines := True;
  LValues.HideSelection := False;
  LValues.ReadOnly := True;
  LValues.RowSelect := True;
  LValues.ViewStyle := vsReport;
  FFieldsList := TStringList.Create;
  FDisplayFieldNames := TStringList.Create;
end;

destructor TmLookupPanel.Destroy;
begin
  FFieldsList.Free;
  FDisplayFieldNames.Free;
  inherited Destroy;
end;

procedure TmLookupPanel.Init(const aDataProvider : IVDDataProvider;  const aFieldNames : TStringList; const aKeyFieldName : string; const aDisplayFieldNames : TStringList);
var
  k, i : integer;
  ptr : UIntPtr;
  col : TListColumn;
  item : TListItem;
  str : String;
  curValue : Variant;
  curDatum : IVDDatum;
begin
  FKeyFieldName:= aKeyFieldName;
  FDisplayFieldNames.Clear;
  FDisplayFieldNames.AddStrings(aDisplayFieldNames);
  FDataProvider := aDataProvider;

  LValues.BeginUpdate;
  try
    FFieldsList.Clear;
    FFieldsList.AddStrings(aFieldNames);

    for i := 0 to aFieldNames.Count -1 do
    begin
      col := LValues.Columns.Add;
      col.Caption:= GenerateDisplayLabel(aFieldNames.Strings[i]);
      col.Width:= 200;
    end;

    ptr := 0;
    for i := 0 to FDataProvider.Count - 1 do
    begin
      item := LValues.Items.Add;
      item.Data:= pointer(ptr);
      ptr := ptr + 1;

      for k := 0 to FFieldsList.Count - 1 do
      begin
        curDatum := FDataProvider.GetDatum(i);
        curValue := curDatum.GetPropertyByFieldName(FFieldsList.Strings[k]);

        if VarIsNull(curValue) then
          str := ''
        else
          str := VarToStr(curValue);
        if k = 0 then
          item.Caption:= str
        else
          item.SubItems.Add(str);
      end;
    end;
  finally
    LValues.EndUpdate;
  end;
  LValuesFilter.FilteredListview := LValues;
end;

procedure TmLookupPanel.SetFocusOnFilter;
begin
  LValuesFilter.SetFocus;
end;

end.
