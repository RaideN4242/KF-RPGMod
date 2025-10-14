class ID_GUI_List_Sale extends KFBuyMenuSaleList;

var ID_RPG_Base_PlayerController PPC;
var int ActiveCategory,SelectionOffset;
var localized string WeaponGroupText;

final function GUIBuyable GetSelectedBuyable()
{
	if( Index-SelectionOffset >= ForSaleBuyables.Length || Index >= CanBuys.length || CanBuys[Index]>1 )
		return None;
	return ForSaleBuyables[Index-SelectionOffset];
}

final function CopyAllBuyables()
{
	local int i;

	if( PPC==None )
	{
		PPC = ID_RPG_Base_PlayerController(PlayerOwner());
		if( PPC==None ) return;
	}
	for( i=0; i<ForSaleBuyables.Length; ++i )
		if( ForSaleBuyables[i]!=None )
			PPC.AllocatedObjects[PPC.AllocatedObjects.Length] = ForSaleBuyables[i];
}

final function ID_GUI_BuyableItem AllocateEntry()
{
	local GUIBuyable G;

	if( PPC==None )
	{
		PPC = ID_RPG_Base_PlayerController(PlayerOwner());
		if( PPC==None ) return new Class'ID_GUI_BuyableItem';
	}
	if( PPC.AllocatedObjects.Length==0 )
		return new Class'ID_GUI_BuyableItem';
	G = PPC.AllocatedObjects[0];
	PPC.ResetItem(G);
	PPC.AllocatedObjects.Remove(0,1);
	return ID_GUI_BuyableItem(G);
}

final function SetCategoryNum( int N )
{
	if( ActiveCategory==N )
		ActiveCategory = -1;
	else ActiveCategory = N;
	SelectionOffset = (N+1);
	UpdateForSaleBuyables();
	Index = N;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	CopyAllBuyables();
	ForSaleBuyables.Length = 0;
	super.Closed(Sender, bCancelled);
}


function bool IsInInventory(class<Pickup> Item)
{
	local Inventory CurInv;

	for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
		if ( CurInv.default.PickupClass == Item  ||
			(class<ID_RPG_Base_Util_Pickup>(CurInv.default.PickupClass) != none && class<ID_RPG_Base_Util_Pickup>(Item) != none 
				&& class<ID_RPG_Base_Util_Pickup>(CurInv.default.PickupClass).default.BasePickupClass == class<ID_RPG_Base_Util_Pickup>(Item).default.BasePickupClass) ||
				(ClassIsChildOf(CurInv.default.PickupClass, class'ID_Weapon_Base_Turret_Pickup') && ClassIsChildOf(Item, class'ID_Weapon_Base_Turret_Pickup')) ||
				(ClassIsChildOf(CurInv.default.PickupClass, class'ID_Weapon_Base_Turret_PickupM') && ClassIsChildOf(Item, class'ID_Weapon_Base_Turret_PickupM')) ||
				(ClassIsChildOf(CurInv.default.PickupClass, class'PTurretPickupM') && ClassIsChildOf(Item, class'PTurretPickupM')) ||
				(ClassIsChildOf(CurInv.default.PickupClass, class'ID_Weapon_Base_Turret_PickupM') && ClassIsChildOf(Item, class'PTurretPickupM')) ||
				(ClassIsChildOf(CurInv.default.PickupClass, class'PTurretPickupM') && ClassIsChildOf(Item, class'ID_Weapon_Base_Turret_PickupM')) ||				
				(ClassIsChildOf(CurInv.default.PickupClass, class'AKFTurretPickup') && ClassIsChildOf(Item, class'AKFTurretPickup')) ||
				(ClassIsChildOf(CurInv.default.PickupClass, class'DemoSentryGunPickup') && ClassIsChildOf(Item, class'DemoSentryGunPickup')) ||
				(ClassIsChildOf(CurInv.default.PickupClass, class'SentryGunWYDTPickup') && ClassIsChildOf(Item, class'SentryGunWYDTPickup')) ||
				(ClassIsChildOf(CurInv.default.PickupClass, class'VestRPGBasePickup') && ClassIsChildOf(Item, class'VestRPGBasePickup'))
			)
		{
			return true;
		}
	}

	return false;
}

function UpdateForSaleBuyables()
{
	local KFPlayerReplicationInfo KFPRI;
	local ID_RPG_Stats_ReplicationLink KFLR;
	local ID_GUI_BuyableItem ForSaleBuyable;
	local class<KFWeaponPickup> ForSalePickup;
	local class<ID_RPG_Base_Util_Pickup> ForSaleUtilPickup;
	local int j;
	local class<KFWeapon> ForSaleWeapon;
	local int cost;

	//Clear the ForSaleBuyables array
	CopyAllBuyables();
	ForSaleBuyables.Length = 0;

	// Grab the items for sale
	KFLR = Class'ID_RPG_Stats_ReplicationLink'.Static.FindStats(PlayerOwner());
	if( KFLR==None )
		return; // Hmmmm?

	KFPRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);

	//Grab the perk's weapons first
	for ( j = 0; j < KFLR.ShopInventory.Length; j++ )
	{
		//log("ShopInventory"@KFLR.ShopInventory[j].PC);
		
		if ( KFLR.ShopInventory[j].PC != none )
		{
			ForSaleUtilPickup = class<ID_RPG_Base_Util_Pickup>(KFLR.ShopInventory[j].PC);
			if (ForSaleUtilPickup != None)
			{
				if ( ActiveCategory != KFLR.ShopInventory[j].CatNum || IsInInventory(ForSaleUtilPickup) )
					continue;
					
				ForSaleBuyable = AllocateEntry();
				
				ForSaleBuyable.ItemName = ForSaleUtilPickup.default.UtilItemClass.default.ItemName;
				ForSaleBuyable.ItemDescription = "";
				ForSaleBuyable.ItemUtilClass = ForSaleUtilPickup.default.UtilItemClass;
				ForSaleBuyable.ItemUtilPickupClass = ForSaleUtilPickup;
				cost = ForSaleUtilPickup.default.Cost - ForSaleUtilPickup.default.Cost * class'ID_Skill_Discount'.static.GetReduceCostMulti(KFLR, ForSaleUtilPickup);
				ForSaleBuyable.ItemCost = cost;
				ForSaleBuyable.ItemWeight = 0;
				ForSaleBuyable.bSaleList = true;
				ForSaleBuyables[ForSaleBuyables.Length] = ForSaleBuyable;
				
				continue;
			}
			
			
			ForSalePickup =  class<KFWeaponPickup>(KFLR.ShopInventory[j].PC);

			if ( ForSalePickup==None || ActiveCategory!=KFLR.ShopInventory[j].CatNum ||
				(class<KFWeapon>(ForSalePickup.default.InventoryType).default.bKFNeverThrow && class<VestRPGBase>(ForSalePickup.default.InventoryType)==None) ||
				IsInInventory(ForSalePickup) )
				continue;

			ForSaleWeapon =  class<KFWeapon>(ForSalePickup.default.InventoryType);
			ForSaleBuyable = AllocateEntry();

   			ForSaleBuyable.ItemName 		= ForSaleWeapon.default.ItemName;
			ForSaleBuyable.ItemDescription 	= ForSalePickup.default.Description;
			ForSaleBuyable.ItemCategorie		= "Melee"; // Dummy stuff..
			ForSaleBuyable.ItemImage			= ForSaleWeapon.default.TraderInfoTexture;
			ForSaleBuyable.ItemWeaponClass	= ForSaleWeapon;
			ForSaleBuyable.ItemAmmoClass	= ForSaleWeapon.default.FireModeClass[0].default.AmmoClass;
			ForSaleBuyable.ItemPickupClass	= ForSalePickup;
			cost = ForSalePickup.default.Cost - ForSalePickup.default.Cost * class'ID_Skill_Discount'.static.GetReduceCostMulti(KFLR, ForSalePickup);
			ForSaleBuyable.ItemCost			= cost;
			ForSaleBuyable.ItemWeight	= ForSaleWeapon.default.Weight;
			
			ForSaleBuyable.ItemPerkIndex		= ForSalePickup.default.CorrespondingPerkIndex;

			// Make sure we mark the list as a sale list
			ForSaleBuyable.bSaleList = true;

			ForSaleBuyables[ForSaleBuyables.Length] = ForSaleBuyable;
		}
	}

	//Now Update the list
	UpdateList();
}

function UpdateList()
{
	local int i,j;
	local ID_RPG_Stats_ReplicationLink KFLR;

	KFLR = Class'ID_RPG_Stats_ReplicationLink'.Static.FindStats(PlayerOwner());

	// Update the ItemCount and select the first item
	ItemCount = KFLR.ShopCategories.Length + ForSaleBuyables.Length;

	// Clear the arrays
	if ( ForSaleBuyables.Length < ItemPerkIndexes.Length )
	{
		ItemPerkIndexes.Length = ItemCount;
		PrimaryStrings.Length = ItemCount;
		SecondaryStrings.Length = ItemCount;
		CanBuys.Length = ItemCount;
	}

	// Update categories
	if( ActiveCategory>=0 )
	{
		for( i=0; i<(ActiveCategory+1); ++i )
		{
			PrimaryStrings[j] = KFLR.ShopCategories[i];
			CanBuys[j] = 2+i;
			++j;
		}
	}
	else
	{
		for( i=0; i<KFLR.ShopCategories.Length; ++i )
		{
			PrimaryStrings[j] = KFLR.ShopCategories[i];
			CanBuys[j] = 2+i;
			++j;
		}
	}

	// Update the players inventory list
	for ( i=0; i<ForSaleBuyables.Length; i++ )
	{
		//log("ForSaleBuyables"@ForSaleBuyables[i].ItemName);
		
		PrimaryStrings[j] = ForSaleBuyables[i].ItemName;
		SecondaryStrings[j] = "£" @ int(ForSaleBuyables[i].ItemCost);

		ItemPerkIndexes[j] = ForSaleBuyables[i].ItemPerkIndex;

		if ( ForSaleBuyables[i].ItemCost > PlayerOwner().PlayerReplicationInfo.Score ||
			ForSaleBuyables[i].ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight )
		{
			CanBuys[j] = 0;
		}
		else
		{
			CanBuys[j] = 1;
		}
		++j;
	}

	if( ActiveCategory>=0 && ActiveCategory<KFLR.ShopCategories.Length )
	{
		for( i=(ActiveCategory+1); i<KFLR.ShopCategories.Length; ++i )
		{
			PrimaryStrings[j] = KFLR.ShopCategories[i];
			CanBuys[j] = 2+i;
			++j;
		}
	}

	if ( bNotify )
 	{
		CheckLinkedObjects(Self);
	}

	if ( MyScrollBar != none )
	{
		MyScrollBar.AlignThumb();
	}

	bNeedsUpdate = false;
}

function DrawInvItem(Canvas Canvas, int CurIndex, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local float TempX, TempY, TempHeight;
	local float StringHeight, StringWidth;
	local int HeightCoeff, HeightCoeff_2;

	OnClickSound=CS_Click;
	ItemSpacing /= 8;
	// Offset for the Background
	TempX = X;
	TempY = Y + ItemSpacing;// / 2.0;
	HeightCoeff = 4;
	HeightCoeff_2 = 1;
	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.Font = class'ID_HUD'.Static.LoadRPGInfoFontStatic(14);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	Canvas.SetPos(TempX, TempY);
	TempHeight = Height - HeightCoeff;
	TempY += HeightCoeff_2;
	Canvas.SetPos(TempX, TempY);
	if ( CanBuys[CurIndex]>1 ) // Drawing without perk icon.
	{
		if ( bSelected )
			Canvas.DrawTileStretched(SelectedItemBackgroundRight, Width - (Height - ItemSpacing), Height - HeightCoeff);
		else Canvas.DrawTileStretched(ItemBackgroundRight, Width - (Height - ItemSpacing), Height - HeightCoeff);
	}
	else
	{
		TempX += ((Height - ItemSpacing) - 1);
		Canvas.SetPos(TempX, TempY);
		if ( CanBuys[CurIndex]==0 )
			Canvas.DrawTileStretched(DisabledItemBackgroundRight, Width - (Height - ItemSpacing), Height - HeightCoeff);
		else if ( bSelected )
			Canvas.DrawTileStretched(SelectedItemBackgroundRight, Width - (Height - ItemSpacing), Height - HeightCoeff);
		else
			Canvas.DrawTileStretched(ItemBackgroundRight, Width - (Height - ItemSpacing), Height - HeightCoeff);
	}
	

	// Select Text color
	if ( CurIndex == MouseOverIndex )
		Canvas.SetDrawColor(0, 255, 0, 255);
	else
		Canvas.SetDrawColor(73, 255, 255, 255);

	// Draw the item's name or category
	Canvas.StrLen(PrimaryStrings[CurIndex], StringWidth, StringHeight);
	Canvas.SetPos(TempX + (0.2 * Height), TempY + ((TempHeight - StringHeight) / 2));
	Canvas.DrawText(PrimaryStrings[CurIndex]);

	// Draw the item's price
	if ( CanBuys[CurIndex] <2 )
	{
		Canvas.StrLen(SecondaryStrings[CurIndex], StringWidth, StringHeight);
		Canvas.SetPos((TempX - Height) + Width - (StringWidth + (0.2 * Height)), TempY + ((TempHeight - StringHeight) / 2));
		Canvas.DrawText(SecondaryStrings[CurIndex]);
	}
	else
	{
		Canvas.StrLen(WeaponGroupText, StringWidth, StringHeight);
		Canvas.SetPos((TempX - Height) + Width - (StringWidth + (0.2 * Height)), TempY + ((TempHeight - StringHeight) / 2));
		Canvas.DrawText(WeaponGroupText);
	}

	Canvas.SetDrawColor(255, 255, 255, 255);
}

function IndexChanged(GUIComponent Sender)
{
	if ( CanBuys[Index]==0 )
	{
		if ( ForSaleBuyables[Index-SelectionOffset].ItemCost > PlayerOwner().PlayerReplicationInfo.Score )
			PlayerOwner().Pawn.DemoPlaySound(TraderSoundTooExpensive, SLOT_Interface, 2.0);
		else if ( ForSaleBuyables[Index-SelectionOffset].ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight )
			PlayerOwner().Pawn.DemoPlaySound(TraderSoundTooHeavy, SLOT_Interface, 2.0);
	}
	Super(GUIVertList).IndexChanged(Sender);
}


function float SaleItemHeight(Canvas c)
{
	return (MenuOwner.ActualHeight() / 24 - 1);
}

defaultproperties
{
     ActiveCategory=-1
     WeaponGroupText="Weapon group"
     GetItemHeight=ID_GUI_List_Sale.SaleItemHeight
     FontScale=FNS_Small
}
