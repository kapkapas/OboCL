// This is part of the Obo Component Library

// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// This software is distributed without any warranty.

// @author Domenico Mammola (mimmo71@gmail.com - www.mammola.net)

unit mGridEditors;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

interface

uses
  Classes, Grids,
  LCLType
  //  ,ECEditBtns
  ;

type
  (*
  The user can digit free text in the editor but if a special key is pressed the editor will run the event.
  So, for instance, a lookup panel can be activated while keeping both the hands on the keyboard.
  The default special key is VK_RETURN.
  If the editor is read-only it is still possible to clear the value of the cell by pressing DELETE (key can be customized).
  The editor can be activated throw the OnSelectEditor event of the grid:

  [..]
  if .. then
  begin
    FEditor.Text := myGrid.Cells[myGrid.Col, myGrid.Row];
    Editor := FEditor;
  end;
  [..]

  before in the creation method of the parent component:
  [..]
  FEditor := TmExtStringCellEditor.Create(Self);
  FEditor.Visible := false;
  FEditor.Event:= Self.myEvent;
  FEditor.ParentGrid := ..;
  [..]

  *)

  TmOnCellEditorShowEditorEvent = function(const aCol, aRow: integer;
    var aNewDisplayValue: string; var aNewActualValue: variant): boolean of object;
  TmOnCellEditorShowWizardEvent = function(const aCol, aRow: integer;
    var aNewDisplayValue: string; var aNewActualValue: variant): boolean of object;
  TmOnCellEditorClearEvent = function(const aCol, aRow: integer): boolean of object;

  { TmExtStringCellEditor }

  TmExtStringCellEditor = class(TStringCellEditor)
  strict private
    FParentGrid: TCustomStringGrid;
    FOnShowEditorEvent: TmOnCellEditorShowEditorEvent;
    FOnShowWizardEvent: TmOnCellEditorShowWizardEvent;
    FOnClearEvent: TmOnCellEditorClearEvent;
    FDefaultShowEditorKey: word;
    FDefaultShowWizardKey: word;
    FDefaultClearKey: word;
    FAllowDeleteWhenReadOnly: boolean;
  protected
    procedure KeyDown(var Key: word; Shift: TShiftState); override;
    procedure DblClick; override;
  public
    constructor Create(Aowner: TComponent); override;

    property ParentGrid: TCustomStringGrid read FParentGrid write FParentGrid;

    property OnShowEditorEvent: TmOnCellEditorShowEditorEvent read FOnShowEditorEvent write FOnShowEditorEvent;
    property OnShowWizardEvent: TmOnCellEditorShowWizardEvent read FOnShowWizardEvent write FOnShowWizardEvent;
    property OnClearEvent: TmOnCellEditorClearEvent read FOnClearEvent write FOnClearEvent;

    property DefaultShowEditorKey: word read FDefaultShowEditorKey
      write FDefaultShowEditorKey;
    property DefaultClearKey: word read FDefaultClearKey write FDefaultClearKey;
    property DefaultShowWizardKey: word read FDefaultShowWizardKey
      write FDefaultShowWizardKey;
    property AllowDeleteWhenReadOnly: boolean
      read FAllowDeleteWhenReadOnly write FAllowDeleteWhenReadOnly;
  end;

(*  TmExtButtonCellEditor = class (TECEditBtn)
  strict private
    FParentGrid : TCustomStringGrid;
    FOnKeyPressEvent : TOnSelectEvent;
  public
    property ParentGrid : TCustomStringGrid read FParentGrid write FParentGrid;
    property OnKeyPressEvent : TOnSelectEvent read FOnKeyPressEvent write FOnKeyPressEvent;
  end;*)

implementation

{ TmExtStringCellEditor }

procedure TmExtStringCellEditor.KeyDown(var Key: word; Shift: TShiftState);
var
  newDisplayValue: string;
  newActualValue: variant;
begin
  inherited KeyDown(Key, Shift);
  if Key = FDefaultShowEditorKey then
  begin
    if Assigned(FOnShowEditorEvent) then
    begin
      if FOnShowEditorEvent(FParentGrid.Col, FParentGrid.Row, newDisplayValue, newActualValue) then
        Self.Text := newDisplayValue;
      //FParentGrid.Cells[FParentGrid.Col, FParentGrid.Row];
    end;
  end
  else
  if Key = FDefaultShowWizardKey then
  begin
    if Assigned(FOnShowWizardEvent) then
    begin
      if FOnShowWizardEvent(FParentGrid.Col, FParentGrid.Row, newDisplayValue, newActualValue) then
        Self.Text := newDisplayValue;
    end;
  end
  else
  if FAllowDeleteWhenReadOnly and (Self.ReadOnly) and (Key = FDefaultClearKey) then
  begin
    if Assigned(FOnClearEvent) then
    begin
      if FOnClearEvent(FParentGrid.Col, FParentGrid.Row) then
      begin
        FParentGrid.Cells[FParentGrid.Col, FParentGrid.Row] := '';
        Self.Text := '';
      end;
    end
    else
    begin
      FParentGrid.Cells[FParentGrid.Col, FParentGrid.Row] := '';
      Self.Text := '';
    end;
  end;
end;

procedure TmExtStringCellEditor.DblClick;
var
  newDisplayValue: string;
  newActualValue: variant;
begin
  inherited DblClick;
  if Assigned(FOnShowEditorEvent) then
  begin
    if FOnShowEditorEvent(FParentGrid.Col, FParentGrid.Row, newDisplayValue,
      newActualValue) then
      Self.Text := newDisplayValue;
    //FParentGrid.Cells[FParentGrid.Col, FParentGrid.Row];
  end;
end;

constructor TmExtStringCellEditor.Create(Aowner: TComponent);
begin
  inherited Create(Aowner);
  FDefaultShowEditorKey := VK_RETURN;
  FDefaultShowWizardKey := VK_F1;
  FDefaultClearKey := VK_DELETE;
  FAllowDeleteWhenReadOnly := True;
  FOnShowEditorEvent := nil;
  FOnShowWizardEvent := nil;
  FOnClearEvent := nil;
end;

end.
