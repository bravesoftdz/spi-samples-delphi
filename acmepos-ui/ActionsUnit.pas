unit ActionsUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, ComObj, SPIClient_TLB;

type
  TfrmActions = class(TForm)
    pnlActions: TPanel;
    btnAction1: TButton;
    btnAction2: TButton;
    lblAmount: TLabel;
    edtAmount: TEdit;
    pnlFlow: TPanel;
    lblFlow: TLabel;
    lblFlowStatus: TLabel;
    lblFlowMessage: TLabel;
    richEdtFlow: TRichEdit;
    btnAction3: TButton;
    procedure btnAction1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure btnAction2Click(Sender: TObject);
    procedure btnAction3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent; _Spi: SPIClient_TLB.Spi); overload;
  end;

var
  Spi: SPIClient_TLB.Spi;
  ComWrapper: SPIClient_TLB.ComWrapper;

implementation

{$R *.dfm}

uses MainUnit;

constructor TfrmActions.Create(AOwner: TComponent; _Spi: SPIClient_TLB.Spi);
begin
  inherited Create(AOwner);
  Spi := _Spi;
  ComWrapper := CreateComObject(CLASS_ComWrapper) AS SPIClient_TLB.ComWrapper;
end;

procedure DoPurchase;
var
  purchase: SPIClient_TLB.InitiateTxResult;
  amount: Integer;
begin
  amount := StrToInt(frmActions.edtAmount.Text);
  purchase := CreateComObject(CLASS_InitiateTxResult)
    AS SPIClient_TLB.InitiateTxResult;
  purchase := Spi.InitiatePurchaseTx(ComWrapper.Get_Id('prchs'), amount);

  if (purchase.Initiated) then
  begin
    frmActions.richEdtFlow.Lines.Add
      ('# Purchase Initiated. Will be updated with Progress.');
  end
  else
  begin
    frmActions.richEdtFlow.Lines.Add('# Could not initiate purchase: ' +
      purchase.Message + '. Please Retry.');
  end;
end;

procedure DoRefund;
var
  refund: SPIClient_TLB.InitiateTxResult;
  amount: Integer;
begin
  amount := StrToInt(frmActions.edtAmount.Text);
  refund := CreateComObject(CLASS_InitiateTxResult)
    AS SPIClient_TLB.InitiateTxResult;
  refund := Spi.InitiateRefundTx(ComWrapper.Get_Id('rfnd'), amount);

  if (refund.Initiated) then
  begin
    frmActions.richEdtFlow.Lines.Add
      ('# Refund Initiated. Will be updated with Progress.');
  end
  else
  begin
    frmActions.richEdtFlow.Lines.Add('# Could not initiate refund: ' +
      refund.Message + '. Please Retry.');
  end;
end;

procedure TfrmActions.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmActions.FormCreate(Sender: TObject);
begin
  ComWrapper := CreateComObject(CLASS_ComWrapper) AS SPIClient_TLB.ComWrapper;
end;

procedure TfrmActions.FormHide(Sender: TObject);
begin
  frmMain.Enabled := True;
end;

procedure TfrmActions.FormShow(Sender: TObject);
begin
  lblFlowStatus.Caption := ComWrapper.GetSpiFlowEnumName(Spi.CurrentFlow);
end;

procedure TfrmActions.btnAction1Click(Sender: TObject);
begin
  if (btnAction1.Caption = 'Confirm Code') then
  begin
    Spi.PairingConfirmCode;
  end
  else if (btnAction1.Caption = 'Cancel Pairing') then
  begin
    Spi.PairingCancel;
    frmMain.lblStatus.Color := clRed;
  end
  else if (btnAction1.Caption = 'Cancel') then
  begin
    Spi.CancelTransaction;
  end
  else if (btnAction1.Caption = 'OK') then
  begin
    Spi.AckFlowEndedAndBackToIdle;
    frmActions.richEdtFlow.Lines.Clear;
    frmActions.lblFlowMessage.Caption := 'Select from the options below';
    frmMain.DPrintStatusAndActions;
    frmMain.Enabled := True;
    frmMain.btnPair.Enabled := True;
    frmMain.edtPosID.Enabled := True;
    frmMain.edtEftposAddress.Enabled := True;
    Hide;
  end
  else if (btnAction1.Caption = 'Accept Signature') then
  begin
    Spi.AcceptSignature(True);
  end
  else if (btnAction1.Caption = 'Retry') then
  begin
    Spi.AckFlowEndedAndBackToIdle;
    frmActions.richEdtFlow.Lines.Clear;
    if (Spi.CurrentTxFlowState.type_ = TransactionType_Purchase) then
    begin
      DoPurchase;
    end
    else
    begin
      frmActions.lblFlowStatus.Caption :=
        'Retry by selecting from the options below';
      frmMain.DPrintStatusAndActions;
    end;
  end
  else if (btnAction1.Caption = 'Purchase') then
  begin
    DoPurchase;
  end
  else if (btnAction1.Caption = 'Refund') then
  begin
    DoRefund;
  end;
end;

procedure TfrmActions.btnAction2Click(Sender: TObject);
begin
  if (btnAction2.Caption = 'Cancel Pairing') then
  begin
    Spi.PairingCancel;
    frmMain.lblStatus.Color := clRed;
  end
  else if (btnAction2.Caption = 'Decline Signature') then
  begin
    Spi.AcceptSignature(False);
  end
  else if (btnAction2.Caption = 'Cancel') then
  begin
    Spi.AckFlowEndedAndBackToIdle;
    frmActions.richEdtFlow.Lines.Clear;
    frmMain.DPrintStatusAndActions;
    frmMain.Enabled := True;
    Hide
  end;
end;

procedure TfrmActions.btnAction3Click(Sender: TObject);
begin
  if (btnAction3.Caption = 'Cancel') then
  begin
    Spi.CancelTransaction;
  end;
end;

end.