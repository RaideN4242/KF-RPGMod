//=============================================================================
// The trader menu's list with player's current inventory
//=============================================================================
class ID_GUI_List_Inv extends KFBuyMenuInvList;

var ID_RPG_Base_PlayerController PPC;

final function CopyAllBuyables()
{
	local int i;

	if( PPC==None )
	{
		PPC = ID_RPG_Base_PlayerController(PlayerOwner());
		if( PPC==None ) return;
	}
	for( i=0; i<MyBuyables.Length; ++i )
		if( MyBuyables[i]!=None )
			PPC.AllocatedObjects[PPC.AllocatedObjects.Length] = MyBuyables[i];
}
final function FreeEntry( int Index )
{
	if( PPC==None )
	{
		PPC = ID_RPG_Base_PlayerController(PlayerOwner());
		if( PPC==None ) return;
	}
	if( MyBuyables[Index]!=None )
		PPC.AllocatedObjects[PPC.AllocatedObjects.Length] = MyBuyables[Index];
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

event Closed(GUIComponent Sender, bool bCancelled)
{
	CopyAllBuyables();
	MyBuyables.Length = 0;
	super.Closed(Sender, bCancelled);
}

function bool IsInInventory(class<Pickup> Item)
{
	local Inventory CurInv;

	for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
		if ( CurInv.default.PickupClass == Item  ||
			(class<ID_RPG_Base_Util_Pickup>(CurInv.default.PickupClass) != none && class<ID_RPG_Base_Util_Pickup>(Item) != none 
				&& class<ID_RPG_Base_Util_Pickup>(CurInv.default.PickupClass).default.BasePickupClass == class<ID_RPG_Base_Util_Pickup>(Item).default.BasePickupClass))
		{
			return true;
		}
	}

	return false;
}

function UpdateMyBuyables()
{
	local ID_GUI_BuyableItem MyBuyable;
	local Inventory CurInv;
	local KFLevelRules KFLR;
	local ID_RPG_Stats_ReplicationLink RepLink;
	local float CurAmmo, MaxAmmo;
	local class<KFWeaponPickup> MyPickup;
	local class<ID_RPG_Base_Util_Pickup> UtilPickup;
	//local int  NumInvItems;
	local float cost;

	//Let's start with our current inventory
	if ( PlayerOwner().Pawn.Inventory == none )
	{
		//log("Inventory is none!");
		return;
	}

	RepLink = Class'ID_RPG_Stats_ReplicationLink'.Static.FindStats(PlayerOwner());
	if( RepLink==None )
		return;
	
	AutoFillCost = 0.00000;

	//Clear the MyBuyables array
	CopyAllBuyables();
	MyBuyables.Length = 0;

	// Grab the items for sale, we need the categories
	foreach PlayerOwner().DynamicActors(class'KFLevelRules', KFLR)
		break;


	// Fill the Buyables
	//NumInvItems = 0;
	MyBuyable = AllocateEntry();

	MyBuyable.ItemName 		= class'BuyableVest'.default.ItemName;
	MyBuyable.ItemDescription 	= class'BuyableVest'.default.ItemDescription;
	MyBuyable.ItemCategorie		= "";
	MyBuyable.ItemImage		= class'BuyableVest'.default.ItemImage;
	MyBuyable.ItemAmmoCurrent	= PlayerOwner().Pawn.ShieldStrength;
	MyBuyable.ItemAmmoMax	= ID_RPG_Base_HumanPawn(PlayerOwner().Pawn).MaxShieldStrength;
	cost = class'BuyableVest'.default.ItemCost - class'BuyableVest'.default.ItemCost * class'ID_Skill_Discount'.static.GetReduceCostMulti(RepLink, MyPickup);
	MyBuyable.ItemCost		= cost;
	MyBuyable.ItemAmmoCost		= MyBuyable.ItemCost / ID_RPG_Base_HumanPawn(PlayerOwner().Pawn).MaxShieldStrength;
	MyBuyable.ItemFillAmmoCost	= int((ID_RPG_Base_HumanPawn(PlayerOwner().Pawn).MaxShieldStrength - MyBuyable.ItemAmmoCurrent) * MyBuyable.ItemAmmoCost);
	MyBuyable.bIsVest			= true;
	MyBuyable.bMelee			= false;
	MyBuyable.bSaleList		= false;
	MyBuyable.bSellable		= false;
	MyBuyable.ItemPerkIndex		= class'BuyableVest'.default.CorrespondingPerkIndex;
	MyBuyables.Insert(0,1);
	MyBuyables[0] = MyBuyable;
	
	
	for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
		if ( CurInv.IsA('Ammunition') || CurInv.IsA('ID_RPG_Misc_Welder') || CurInv.IsA('ID_RPG_Misc_Syringe') )
			continue;
			
		//log("MyBuyable.ItemName"@MyBuyable.ItemName);

		if (CurInv.IsA('ID_RPG_Base_Util'))
		{
			MyBuyable = AllocateEntry();
		
			UtilPickup = class<ID_RPG_Base_Util_Pickup>(ID_RPG_Base_Util(CurInv).default.PickupClass);
			MyBuyable.ItemName = UtilPickup.default.UtilItemClass.default.ItemName;
			MyBuyable.ItemDescription = "";
			MyBuyable.ItemUtilClass = UtilPickup.default.UtilItemClass;
			MyBuyable.ItemUtilPickupClass = UtilPickup;
			//MyBuyable.ItemCost = cost;
			MyBuyable.ItemWeight = 0;
			MyBuyable.bSaleList = false;
			MyBuyable.bSellable =  UtilPickup.default.Sellable;
			if (ID_RPG_Base_Util(CurInv).SellValue > 0)
				cost = ID_RPG_Base_Util(CurInv).SellValue;
			else
				cost = UtilPickup.default.Cost - UtilPickup.default.Cost * class'ID_Skill_Discount'.static.GetReduceCostMulti(RepLink, UtilPickup) * 0.75;
			MyBuyable.ItemSellValue = cost;
			//MyBuyables.Insert(0,1);
			MyBuyables[MyBuyables.Length] = MyBuyable;
			continue;
		}
			
		MyPickup = class<KFWeaponPickup>(KFWeapon(CurInv).default.PickupClass);

		if ( CurInv.IsA('ID_RPG_Base_Weapon') )
		{
			KFWeapon(CurInv).GetAmmoCount(MaxAmmo, CurAmmo);

			MyBuyable = AllocateEntry();

			MyBuyable.ItemName 		= KFWeapon(CurInv).default.ItemName;
			MyBuyable.ItemDescription 	= KFWeapon(CurInv).default.Description;
			MyBuyable.ItemCategorie		= KFLR.EquipmentCategories[MyPickup.default.EquipmentCategoryID].EquipmentCategoryName;
			MyBuyable.ItemImage		= KFWeapon(CurInv).default.TraderInfoTexture;
			MyBuyable.ItemWeaponClass	= KFWeapon(CurInv).class;
			MyBuyable.ItemAmmoClass		= KFWeapon(CurInv).default.FireModeClass[0].default.AmmoClass;
			MyBuyable.ItemPickupClass	= MyPickup;
			
			cost = MyPickup.default.Cost - MyPickup.default.Cost * class'ID_Skill_Discount'.static.GetReduceCostMulti(RepLink, MyPickup);
			MyBuyable.ItemCost		= cost;
			//MyBuyable.ItemAmmoCost	= MyPickup.default.AmmoCost;
			MyBuyable.ItemFillAmmoCost	= (int(((MaxAmmo - CurAmmo) * float(MyPickup.default.AmmoCost)) / float(KFWeapon(CurInv).default.MagCapacity))) ;
			MyBuyable.ItemWeight		= KFWeapon(CurInv).Weight;
			
			if(MyBuyable.ItemName=="Shield" || InStr(MyBuyable.ItemName,"MedKit")>=0 || InStr(MyBuyable.ItemName,"Stun")>=0 )
			{
				MyBuyable.ItemAmmoCurrent	= CurAmmo;
				MyBuyable.ItemAmmoMax		= MaxAmmo;
			}
			else if( InStr(MyBuyable.ItemName,"Petrolboomer")>=0 ||InStr(MyBuyable.ItemName,"EBR Pro")>=0 || InStr(MyBuyable.ItemName,"M32 PRO")>=0 || InStr(MyBuyable.ItemName,"PatGun")>=0 || InStr(MyBuyable.ItemName,"Laser SCAR")>=0 || InStr(MyBuyable.ItemName,"Dual MP7s")>=0)
			{
				//log("Calculate ammo for"@MyBuyable.ItemName);
				
				KFWeapon(CurInv).GetSecondaryAmmoCount(MaxAmmo, CurAmmo);
				MyBuyable.ItemAmmoClass		= KFWeapon(CurInv).default.FireModeClass[1].default.AmmoClass;
				MyBuyable.ItemAmmoCurrent	= CurAmmo;
				MyBuyable.ItemAmmoMax		= MaxAmmo;				
				MyBuyable.ItemFillAmmoCost	= (int(((MaxAmmo - CurAmmo) * float(MyPickup.default.AmmoCost)) / float(KFWeapon(CurInv).default.MagCapacity))) ;
			}
			MyBuyable.bMelee			= (ID_RPG_Base_Weapon_Melee(CurInv)!=none || MyBuyable.ItemAmmoClass==None);
			MyBuyable.bSaleList		= false;
			MyBuyable.ItemPerkIndex		= MyPickup.default.CorrespondingPerkIndex;

			if ( KFWeapon(CurInv) != none && KFWeapon(CurInv).SellValue != -1 )
				MyBuyable.ItemSellValue = KFWeapon(CurInv).SellValue;
			else MyBuyable.ItemSellValue = MyBuyable.ItemCost * 0.75;

			if ( !MyBuyable.bMelee && int(MaxAmmo)>int(CurAmmo) )
				AutoFillCost += MyBuyable.ItemFillAmmoCost;

			MyBuyable.bSellable	= (!KFWeapon(CurInv).default.bKFNeverThrow || VestRPGBase(CurInv)!=None);
			MyBuyables.Insert(0,1);
			MyBuyables[0] = MyBuyable;
			//NumInvItems++;
		}
	
		
	}

	//Now Update the list
	UpdateList();
}

function UpdateList()
{
	local int i;
	local ID_RPG_Stats_ReplicationLink KFLR;

	KFLR = Class'ID_RPG_Stats_ReplicationLink'.Static.FindStats(PlayerOwner());

	if ( MyBuyables.Length < 1 )
	{
		bNeedsUpdate = true;
		return;
	}

	// Clear the arrays
	NameStrings.Remove(0, NameStrings.Length);
	AmmoStrings.Remove(0, AmmoStrings.Length);
	ClipPriceStrings.Remove(0, ClipPriceStrings.Length);
	FillPriceStrings.Remove(0, FillPriceStrings.Length);
	PerkTextures.Remove(0, PerkTextures.Length);

	// Update the ItemCount and select the first item
	ItemCount = MyBuyables.Length;

	// Update the players inventory list
	for ( i = 0; i < ItemCount; i++ )
	{
		if ( MyBuyables[i] == none )
			continue;

		NameStrings[i] = MyBuyables[i].ItemName; //@ "(" $	MyBuyables[i].ItemCategorie $ ")";
		
		//log("MyBuyables[i].ItemName"@MyBuyables[i].ItemName);

		if ( !MyBuyables[i].bIsVest && MyBuyables[i].ItemName!="Shield" && InStr(MyBuyables[i].ItemName,"MedKit")<0 && InStr(MyBuyables[i].ItemName,"PatGun")<0 && InStr(MyBuyables[i].ItemName,"Stun")<0 &&
			InStr(MyBuyables[i].ItemName,"Laser SCAR")<0 && InStr(MyBuyables[i].ItemName,"Dual MP7s")<0 && InStr(MyBuyables[i].ItemName,"M32 PRO")<0 && InStr(MyBuyables[i].ItemName,"EBR Pro")<0
			&& InStr(MyBuyables[i].ItemName,"Petrolboomer")<0
		)
		{
			AmmoStrings[i] = int(MyBuyables[i].ItemAmmoCurrent)$"/"$int(MyBuyables[i].ItemAmmoMax);

			if ( MyBuyables[i].ItemAmmoCurrent < MyBuyables[i].ItemAmmoMax )
			{
				if ( MyBuyables[i].ItemAmmoCost > MyBuyables[i].ItemFillAmmoCost )
				{
					ClipPriceStrings[i] = "£" @ int(MyBuyables[i].ItemFillAmmoCost);
				}
				else
				{
					ClipPriceStrings[i] = "£" @ int(MyBuyables[i].ItemAmmoCost);
				}
			}
			else
			{
				ClipPriceStrings[i] = "£ 0";
			}

			FillPriceStrings[i] = "£" @ int(MyBuyables[i].ItemFillAmmoCost);
		}
		else
		{
			//log("Set FillPriceStrings for"@MyBuyables[i].ItemName);
			
			AmmoStrings[i] = int((MyBuyables[i].ItemAmmoCurrent / MyBuyables[i].ItemAmmoMax) * 100.0)$"%";

			if ( MyBuyables[i].ItemAmmoCurrent == 0 )
			{
				FillPriceStrings[i] = BuyString @ ": £" @ int(MyBuyables[i].ItemFillAmmoCost);
			}
			else if ( MyBuyables[i].ItemAmmoCurrent == ID_RPG_Base_HumanPawn(PlayerOwner().Pawn).MaxShieldStrength )
			{
				FillPriceStrings[i] = PurchasedString;
			}
			else
			{
				FillPriceStrings[i] = BuyString @ ": £" @ int(MyBuyables[i].ItemFillAmmoCost);
			}
		}
		if( KFLR!=None && KFLR.ShopPerkIcons.Length>MyBuyables[i].ItemPerkIndex )
			PerkTextures[i] = Texture(KFLR.ShopPerkIcons[MyBuyables[i].ItemPerkIndex]);
	}

	if ( bNotify )
		CheckLinkedObjects(Self);
	if ( MyScrollBar != none )
		MyScrollBar.AlignThumb();
}


function DrawInvItem(Canvas Canvas, int CurIndex, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local float IconBGSize, ItemBGWidth, AmmoBGWidth, ClipButtonWidth, FillButtonWidth;
	local float TempX, TempY;
	local float StringHeight, StringWidth;

	OnClickSound=CS_Click;

	// Initialize the Canvas
	Canvas.Style = 1;
	// Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
	Canvas.SetDrawColor(255, 255, 255, 255);

	if ( MyBuyables[CurIndex] == none )
	{
		return;
	}
	else
	{
		//log("MyBuyables[CurIndex].ItemName"@MyBuyables[CurIndex].ItemName);
		
		// Calculate Widths for all components
		IconBGSize = Height;
		ItemBGWidth = (Width * ItemBGWidthScale) - IconBGSize + 100;
		AmmoBGWidth = Width * AmmoBGWidthScale - 20;

		if ( !MyBuyables[CurIndex].bIsVest && MyBuyables[CurIndex].ItemName!="Shield" && InStr(MyBuyables[CurIndex].ItemName,"MedKit")<0 && InStr(MyBuyables[CurIndex].ItemName,"PatGun")<0 && InStr(MyBuyables[CurIndex].ItemName,"Stun")<0 &&
			InStr(MyBuyables[CurIndex].ItemName,"Laser SCAR")<0 && InStr(MyBuyables[CurIndex].ItemName,"Dual MP7s")<0 && InStr(MyBuyables[CurIndex].ItemName,"M32 PRO")<0 && InStr(MyBuyables[CurIndex].ItemName,"EBR Pro")<0
			&& InStr(MyBuyables[CurIndex].ItemName,"Petrolboomer")<0
		)
		{
			FillButtonWidth = ((1.0 - ItemBGWidthScale - AmmoBGWidthScale) * Width) - ButtonSpacing;
			ClipButtonWidth = FillButtonWidth * ClipButtonWidthScale;
			FillButtonWidth -= ClipButtonWidth;
		}
		else
		{
			//log("Set FillButtonWidth for"@MyBuyables[CurIndex].ItemName);
			
			FillButtonWidth = ((1.0 - ItemBGWidthScale - AmmoBGWidthScale - 0.1) * Width);
		}

		// Offset for the Background
		TempX = X;
		TempY = Y;

		// Draw Item Background
		Canvas.SetPos(TempX, TempY);

		if ( bSelected )
		{
			Canvas.SetPos(TempX, TempY + ItemBGYOffset);
			Canvas.DrawTileStretched(SelectedItemBackgroundRight, ItemBGWidth, IconBGSize - (2.0 * ItemBGYOffset));
		}
		else
		{
			Canvas.SetPos(TempX, TempY + ItemBGYOffset);
			Canvas.DrawTileStretched(ItemBackgroundRight, ItemBGWidth, IconBGSize - (2.0 * ItemBGYOffset));
		}

		// Select Text color
		if ( CurIndex == MouseOverIndex && MouseOverXIndex == 0 )
		{
			Canvas.SetDrawColor(255, 255, 255, 255);
		}
		else
		{
			Canvas.SetDrawColor(0, 0, 0, 255);
		}

		// Draw the item's name
		Canvas.StrLen(NameStrings[CurIndex], StringWidth, StringHeight);
		Canvas.SetPos(TempX + ItemNameSpacing, Y + ((Height - StringHeight) / 2.0));
		Canvas.DrawText(NameStrings[CurIndex]);

		// Draw the item's ammo status if it is not a melee weapon
		if ( !MyBuyables[CurIndex].bMelee )
		{
			TempX += ItemBGWidth + AmmoSpacing;

			if ( MyBuyables[CurIndex].bIsVest || MyBuyables[CurIndex].ItemName=="Shield" || InStr(MyBuyables[CurIndex].ItemName,"MedKit")>=0 || InStr(MyBuyables[CurIndex].ItemName,"PatGun")>=0 || InStr(MyBuyables[CurIndex].ItemName,"Stun")>=0 ||
				InStr(MyBuyables[CurIndex].ItemName,"Laser SCAR")>=0 || InStr(MyBuyables[CurIndex].ItemName,"Dual MP7s")>=0 || InStr(MyBuyables[CurIndex].ItemName,"M32 PRO")>=0 || InStr(MyBuyables[CurIndex].ItemName,"EBR Pro")>=0
				|| InStr(MyBuyables[CurIndex].ItemName,"Petrolboomer")>=0
			)
			{
				//log("Draw for"@MyBuyables[CurIndex].ItemName);
				
				Canvas.SetDrawColor(255, 255, 255, 255);
				Canvas.SetPos(TempX, TempY + ((Height - AmmoBGHeightScale * Height) / 2.0));
				Canvas.DrawTileStretched(AmmoBackground, AmmoBGWidth, AmmoBGHeightScale * Height);

				Canvas.SetDrawColor(175, 176, 158, 255);
				Canvas.StrLen(AmmoStrings[CurIndex], StringWidth, StringHeight);
				Canvas.SetPos(TempX + ((AmmoBGWidth - StringWidth) / 2.0), TempY + ((Height - StringHeight) / 2.0));
				Canvas.DrawText(AmmoStrings[CurIndex]);
			}
			TempX += AmmoBGWidth + AmmoSpacing;

			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.SetPos(TempX, TempY + ((Height - ButtonBGHeightScale * Height) / 2.0));

			if ( !MyBuyables[CurIndex].bIsVest && MyBuyables[CurIndex].ItemName!="Shield" && InStr(MyBuyables[CurIndex].ItemName,"MedKit")<0 && InStr(MyBuyables[CurIndex].ItemName,"PatGun")<0 && InStr(MyBuyables[CurIndex].ItemName,"Stun")<0 && 
				InStr(MyBuyables[CurIndex].ItemName,"Laser SCAR")<0 && InStr(MyBuyables[CurIndex].ItemName,"Dual MP7s")<0 && InStr(MyBuyables[CurIndex].ItemName,"M32 PRO")<0 && InStr(MyBuyables[CurIndex].ItemName,"EBR Pro")<0
				&& InStr(MyBuyables[CurIndex].ItemName,"Petrolboomer")<0
			)
			{
				if ( MyBuyables[CurIndex].ItemAmmoCurrent >= MyBuyables[CurIndex].ItemAmmoMax ||
					(PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemFillAmmoCost && PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemAmmoCost) )
				{
					Canvas.SetDrawColor(0, 0, 0, 255);
				}
				else if ( CurIndex == MouseOverIndex && MouseOverXIndex == 1 )
				{
				}
				else
				{
					Canvas.SetDrawColor(0, 0, 0, 255);
				}

				TempX += ClipButtonWidth + ButtonSpacing;

				Canvas.SetDrawColor(255, 255, 255, 255);
				Canvas.SetPos(TempX, TempY + ((Height - ButtonBGHeightScale * Height) / 2.0));

				if ( MyBuyables[CurIndex].ItemAmmoCurrent >= MyBuyables[CurIndex].ItemAmmoMax ||
					(PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemFillAmmoCost && PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemAmmoCost) )
				{
					Canvas.SetDrawColor(0, 0, 0, 255);
				}
				else if ( CurIndex == MouseOverIndex && MouseOverXIndex == 2 )
				{
				}
				else
				{
					Canvas.SetDrawColor(0, 0, 0, 255);
				}
			}			
			else
			{
				if ( (PlayerOwner().Pawn.ShieldStrength > 0 && PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemAmmoCost) ||
					(PlayerOwner().Pawn.ShieldStrength <= 0 && PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemCost) ||
					MyBuyables[CurIndex].ItemAmmoCurrent >= MyBuyables[CurIndex].ItemAmmoMax )
				{
					Canvas.DrawTileStretched(DisabledButtonBackground, FillButtonWidth, ButtonBGHeightScale * Height);
					Canvas.SetDrawColor(0, 0, 0, 255);
				}
				else if ( CurIndex == MouseOverIndex && MouseOverXIndex >= 1 )
				{
					Canvas.DrawTileStretched(HoverButtonBackground, FillButtonWidth, ButtonBGHeightScale * Height);
				}
				else
				{
					Canvas.DrawTileStretched(ButtonBackground, FillButtonWidth, ButtonBGHeightScale * Height);
					Canvas.SetDrawColor(0, 0, 0, 255);
				}
				
				Canvas.StrLen(FillPriceStrings[CurIndex], StringWidth, StringHeight);
				Canvas.SetPos(TempX + ((FillButtonWidth - StringWidth) / 2.0), TempY + ((Height - StringHeight) / 2.0));
				Canvas.DrawText(FillPriceStrings[CurIndex]);
			}
		}
		Canvas.SetDrawColor(255, 255, 255, 255);
	}
}

function float InvItemHeight(Canvas c)
{
	return (MenuOwner.ActualHeight() / 12) - 1.0;
}

defaultproperties
{
     GetItemHeight=ID_GUI_List_Inv.InvItemHeight
     FontScale=FNS_Small
}
