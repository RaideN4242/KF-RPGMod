class ID_GUI_Tab_BuyMenu extends KFTab_BuyMenu;

var Class<Pickup> SelectedItem;
var automated ID_GUI_Panel_ItemInfo IDItemInfo;
var automated GUILabel TimeLeftLabel;
var color RedColor;
var color GreenGreyColor;

final function RefreshSelection()
{
	if( SaleSelect.List.Index==-1 )
	{
		if( InvSelect.List.Index!=-1 )
			TheBuyable = InvSelect.GetSelectedBuyable();
		else TheBuyable = None;
	}
	else TheBuyable = SaleSelect.GetSelectedBuyable();
}

function OnAnychange()
{
	LastBuyable = TheBuyable;
	RefreshSelection();
	IDItemInfo.Display(TheBuyable);
	SetInfoText();
	UpdatePanel();
	UpdateBuySellButtons();
}

function bool InternalOnClick(GUIComponent Sender)
{
	RefreshSelection();
	return Super.InternalOnClick(Sender);
}

function UpdateAll()
{
	KFPlayerController(PlayerOwner()).bDoTraderUpdate = false;
	InvSelect.List.UpdateMyBuyables();
	SaleSelect.List.UpdateForSaleBuyables();

	RefreshSelection();
	GetUpdatedBuyable();
	UpdatePanel();
}
function UpdateBuySellButtons()
{
	RefreshSelection();
	if ( InvSelect.List.Index==-1 || TheBuyable==None || !TheBuyable.bSellable )
		SaleButton.DisableMe();
	else SaleButton.EnableMe();

	if ( SaleSelect.List.Index==-1 || TheBuyable==None || (TheBuyable.ItemCost > PlayerOwner().PlayerReplicationInfo.Score) )
		PurchaseButton.DisableMe();
	else PurchaseButton.EnableMe();
}
function GetUpdatedBuyable(optional bool bSetInvIndex)
{
	InvSelect.List.UpdateMyBuyables();
	RefreshSelection();
}

function UpdateAutoFillAmmo()
{
	Super.UpdateAutoFillAmmo();
	RefreshSelection();
}

function SaleChange(GUIComponent Sender)
{
	InvSelect.List.Index = -1;
	
	TheBuyable = SaleSelect.GetSelectedBuyable();

	if( TheBuyable==None ) // Selected category.
	{
		GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = 0;
		if( SaleSelect.List.CanBuys[SaleSelect.List.Index]>1 )
		{
			ID_GUI_List_Sale(SaleSelect.List).SetCategoryNum(SaleSelect.List.CanBuys[SaleSelect.List.Index]-2);
		}
	}
	else GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = TheBuyable.ItemWeight;
	OnAnychange();
}
function bool SaleDblClick(GUIComponent Sender)
{
	InvSelect.List.Index = -1;
	
	TheBuyable = SaleSelect.GetSelectedBuyable();

	if( TheBuyable==None ) // Selected category.
	{
		GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = 0;
	}
	else
	{
		GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = TheBuyable.ItemWeight;
		if ( SaleSelect.List.CanBuys[SaleSelect.List.Index]==1 )
		{
			DoBuy();
   			TheBuyable = none;
		}
	}
	OnAnychange();
	return false;
}

function UpdatePanel()
{
	local float Price;

	Price = 0.0;

	if ( TheBuyable != none && !TheBuyable.bSaleList && TheBuyable.bSellable )
	{
		SaleValueLabel.Caption = SaleValueCaption $ TheBuyable.ItemSellValue;

		SaleValueLabel.bVisible = true;
		SaleValueLabelBG.bVisible = true;
	}
	else
	{
		SaleValueLabel.bVisible = false;
		SaleValueLabelBG.bVisible = false;
	}

	if ( TheBuyable == none || !TheBuyable.bSaleList )
	{
		GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = 0;
	}

	IDItemInfo.Display(TheBuyable);
	UpdateAutoFillAmmo();
	SetInfoText();

	// Money update
	if ( PlayerOwner() != none )
	{
		MoneyLabel.Caption = MoneyCaption $ int(PlayerOwner().PlayerReplicationInfo.Score);
	}
}

function DoBuy()
{
	if ( KFPawn(PlayerOwner().Pawn) != none )
	{
		if (TheBuyable.ItemWeaponClass != none)
		{
			KFPawn(PlayerOwner().Pawn).ServerBuyWeapon(TheBuyable.ItemWeaponClass, TheBuyable.ItemWeight);
		}
		else if (ID_GUI_BuyableItem(TheBuyable).ItemUtilClass != none)
		{
			ID_RPG_Base_HumanPawn(PlayerOwner().Pawn).ServerBuyUtil(ID_GUI_BuyableItem(TheBuyable).ItemUtilClass);
		}
		MakeSomeBuyNoise();

		SaleSelect.List.Index = -1;
		TheBuyable = none;
		LastBuyable = none;
	}
}

function DoSell()
{
	if ( KFPawn(PlayerOwner().Pawn) != none )
	{
		if (TheBuyable.ItemWeaponClass != none)
		{
			KFPawn(PlayerOwner().Pawn).ServerSellWeapon(TheBuyable.ItemWeaponClass);
		}
		else if (ID_GUI_BuyableItem(TheBuyable).ItemUtilClass != none)
		{
			ID_RPG_Base_HumanPawn(PlayerOwner().Pawn).ServerSellUtil(ID_GUI_BuyableItem(TheBuyable).ItemUtilClass);
		}

		InvSelect.List.Index = -1;
		TheBuyable = none;
		LastBuyable = none;
	}
}

defaultproperties
{
     Begin Object Class=ID_GUI_Panel_ItemInfo Name=IDItemInf
         WinTop=0.193730
         WinLeft=0.332571
         WinWidth=0.333947
         WinHeight=0.489407
     End Object
     IDItemInfo=ID_GUI_Panel_ItemInfo'IDRPGMod.ID_GUI_Tab_BuyMenu.IDItemInf'

     RedColor=(R=255,A=255)
     GreenGreyColor=(B=158,G=176,R=175,A=255)
     MagLabel=None

     FillLabel=None

     Begin Object Class=ID_GUI_ListBox_Inv Name=InventoryBox
         OnCreateComponent=InventoryBox.InternalOnCreateComponent
         WinTop=0.070841
         WinLeft=0.000108
         WinWidth=0.328204
         WinHeight=0.521856
     End Object
     InvSelect=ID_GUI_ListBox_Inv'IDRPGMod.ID_GUI_Tab_BuyMenu.InventoryBox'

     ItemInfo=None

     Begin Object Class=ID_GUI_ListBox_Sale Name=SaleBox
         OnCreateComponent=SaleBox.InternalOnCreateComponent
         WinTop=0.064312
         WinLeft=0.672632
         WinWidth=0.325857
         WinHeight=0.674039
     End Object
     SaleSelect=ID_GUI_ListBox_Sale'IDRPGMod.ID_GUI_Tab_BuyMenu.SaleBox'

     WinTop=0.050000
     WinHeight=0.860000
}
