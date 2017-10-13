class UIStrategyCard_Multi extends UIStrategyPolicy;

var int FactionStartIndex;
var array<name> AllFactions;

var UIButton NextFactionButton, PrevFactionButton;

var UIImage FactionMaskA, FactionMaskB, FactionMaskC;
var array<UIImage> FactionMasks;

var UIList PrevFactions, NextFactions;

simulated function OnInit()
{
	NextFactions = Spawn(class'UIList', self);
	NextFactions.InitList('ListNextPageFactions', 1780, 530, 130, 185);

	PrevFactions = Spawn(class'UIList', self);
	PrevFactions.InitList('ListPrevPageFactions', 0, 530, 150, 185);

	FactionMasks.AddItem(none);

	FactionMaskA = Spawn(class'UIImage', self);
	FactionMaskA.bAnimateOnInit = false;
	FactionMaskA.InitImage('FactionMaskA');
	FactionMaskA.SetPosition(565, 55);
	FactionMaskA.SetSize(375, 185);
	FactionMaskA.Hide();
	FactionMasks.AddItem(FactionMaskA);

	FactionMaskB = Spawn(class'UIImage', self);
	FactionMaskB.bAnimateOnInit = false;
	FactionMaskB.InitImage('FactionMaskB');
	FactionMaskB.SetPosition(985, 55);
	FactionMaskB.SetSize(375, 185);
	FactionMaskB.Hide();
	FactionMasks.AddItem(FactionMaskB);

	FactionMaskC = Spawn(class'UIImage', self);
	FactionMaskC.bAnimateOnInit = false;
	FactionMaskC.InitImage('FactionMaskC');
	FactionMaskC.SetPosition(1405, 55);
	FactionMaskC.SetSize(375, 185);
	FactionMaskC.Hide();
	FactionMasks.AddItem(FactionMaskC);

	super.OnInit();

	if (AllFactions.Length > 3)
	{
		NextFactionButton = Spawn(class'UIButton', self);
		NextFactionButton.bAnimateOnInit = false;
		NextFactionButton.InitButton(, class'UIPhotoboothReview'.default.m_strNext, NextFactionPage);
		NextFactionButton.SetPosition(1770, 500);

		PrevFactionButton = Spawn(class'UIButton', self);
		PrevFactionButton.bAnimateOnInit = false;
		PrevFactionButton.InitButton(, class'UIPhotoboothReview'.default.m_strPrevious, PrevFactionPage);
		PrevFactionButton.SetPosition(0, 500);
		PrevFactionButton.SetDisabled(true);

		if (`ISCONTROLLERACTIVE)
		{
			PrevFactionButton.SetStyle(eUIButtonStyle_HOTLINK_WHEN_SANS_MOUSE);
			PrevFactionButton.SetGamepadIcon(class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.FXS_BUTTON_LBUMPER);
			NextFactionButton.SetStyle(eUIButtonStyle_HOTLINK_WHEN_SANS_MOUSE);
			NextFactionButton.SetGamepadIcon(class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.FXS_BUTTON_RBUMPER);
		}
	}
}

function InitializeDecks()
{
	super.InitializeDecks();
	InitializeFactions();
	RealizeCurrentPage();
}

function InitializeFactions()
{
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;

	History = `XCOMHISTORY;
	AllFactions.Length = 0;

	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		AllFactions.AddItem(FactionState.GetMyTemplateName());
	}
	AllFactions.Sort(SortFactionNames);
}

function RealizeCurrentPage()
{
	local int i;
	local XComGameState_ResistanceFaction FactionState;
	local StateObjectReference CardRef;
	local array<StateObjectReference> Cards;
	local int NumPlayedCards, NumTotalCards;

	ColumnNames.Length = 0;
	ColumnNames.AddItem('');

	for (i = 0; i < 3; i++)
	{
		ColumnNames.AddItem(AllFactions[FactionStartIndex + i]);
	}
	for (i = 1; i < 4; i ++)
	{
		MC.ChildFunctionString("screen" $ i, "gotoAndPlay", "_off");
		MC.ChildSetBool("screen" $ i $ ".StackingIcon", "_visible", KnowsFaction(ColumnNames[i]));
	}

	if (PrevFactions != none && NextFactions != none)
	{
		PrevFactions.ClearItems();
		NextFactions.ClearItems();

		i = FactionStartIndex - 1;
		while (i >= 0)
		{
			FactionState = GetFaction(i);
			Cards = FactionState.GetCardSlots();
			NumPlayedCards = 0;
			NumTotalCards = 0;
			foreach Cards(CardRef)
			{
				NumTotalCards++;
				if (CardRef.ObjectID > 0)
				{
					NumPlayedCards++;
				}
			}
			if (FactionState.bMetXCom)
			{
				UIText(PrevFactions.CreateItem(class'UIText')).InitText(, class'UIUtilities_Text'.static.GetColoredText(FactionState.GetFactionTitle() @ "-" @ NumPlayedCards $ "/" $ NumTotalCards, 
										NumPlayedCards == NumTotalCards ? eUIState_Good : eUIState_Warning, 16));
			}
			else
			{
				UIText(PrevFactions.CreateItem(class'UIText')).InitText(, class'UIUtilities_Text'.static.GetColoredText(UnknownFactionColumnLabel, eUIState_Bad, 16));
			}
			i--;
		}
		PrevFactions.RealizeItems();
		PrevFactions.RealizeMaskAndScrollbar();

		i = FactionStartIndex + 3;
		while (i < AllFactions.Length)
		{
			FactionState = GetFaction(i);
			Cards = FactionState.GetCardSlots();
			NumPlayedCards = 0;
			NumTotalCards = 0;
			foreach Cards(CardRef)
			{
				NumTotalCards++;
				if (CardRef.ObjectID > 0)
				{
					NumPlayedCards++;
				}
			}
			if (FactionState.bMetXCom)
			{
				UIText(NextFactions.CreateItem(class'UIText')).InitText(, class'UIUtilities_Text'.static.GetColoredText(FactionState.GetFactionTitle() @ "-" @ NumPlayedCards $ "/" $ NumTotalCards, 
										NumPlayedCards == NumTotalCards ? eUIState_Good : eUIState_Warning, 16));
			}
			else
			{
				UIText(NextFactions.CreateItem(class'UIText')).InitText(, class'UIUtilities_Text'.static.GetColoredText(UnknownFactionColumnLabel, eUIState_Bad, 16));
			}
			i++;
		}
		NextFactions.RealizeItems();
		NextFactions.RealizeMaskAndScrollbar();
	}
}

function NextFactionPage(UIButton btn_clicked)
{
	local int i;
	if (FactionStartIndex + 3 < AllFactions.Length)
	{
		`SOUNDMGR.PlaySoundEvent("Generic_Mouse_Click");
		FactionStartIndex++;
		RealizeCurrentPage();
		for (i = 1; i < 4; i ++)
		{
			MC.ChildSetBool("screen" $ i $ ".betosMC", "_visible", false);
			MC.ChildSetBool("screen" $ i $ ".volkMC", "_visible", false);
			MC.ChildSetBool("screen" $ i $ ".geistMC", "_visible", false);
			//MC.ChildFunctionString("screen" $ i, "gotoAndPlay", "_off");
		}
		RefreshAllDecks();

		if (FactionStartIndex + 3 >= AllFactions.Length)
		{
			FactionStartIndex = AllFactions.Length - 3;
			NextFactionButton.SetDisabled(true);
		}

		PrevFactionButton.SetDisabled(false);
	}
}

function PrevFactionPage(UIButton btn_clicked)
{
	local int i;
	if (FactionStartIndex > 0)
	{
		`SOUNDMGR.PlaySoundEvent("Generic_Mouse_Click");
		FactionStartIndex--;
		RealizeCurrentPage();
		for (i = 1; i < 4; i ++)
		{
			MC.ChildSetBool("screen" $ i $ ".betosMC", "_visible", false);
			MC.ChildSetBool("screen" $ i $ ".volkMC", "_visible", false);
			MC.ChildSetBool("screen" $ i $ ".geistMC", "_visible", false);
			//MC.ChildFunctionString("screen" $ i, "gotoAndPlay", "_off");
		}
		RefreshAllDecks();

		if (FactionStartIndex <= 0)
		{
			FactionStartIndex = 0;
			PrevFactionButton.SetDisabled(true);
		}

		NextFactionButton.SetDisabled(false);
	}
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
		return false;

	bHandled = true;

	switch( cmd )
	{
		case class'UIUtilities_Input'.const.FXS_MOUSE_5:
		case class'UIUtilities_Input'.const.FXS_KEY_TAB:
		case class'UIUtilities_Input'.const.FXS_BUTTON_RBUMPER:
			if (NextFactionButton != none)
			{
				NextFactionPage(NextFactionButton);
			}
			break;
		case class'UIUtilities_Input'.const.FXS_MOUSE_4:
		case class'UIUtilities_Input'.const.FXS_KEY_LEFT_SHIFT:
		case class'UIUtilities_Input'.const.FXS_BUTTON_LBUMPER:
			if (PrevFactionButton != none)
			{
				PrevFactionPage(PrevFactionButton);
			}
			break;
		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

function bool AreUnusedSlotsAndCardsAvailable()
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState_ResistanceFaction FactionState;
	local array<StateObjectReference> HandCards;

	ResHQ = GetResistanceHQ();

	if (ResHQ.HasEmptyWildCardSlot())
	{
		return true;
	}
	
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if( FactionState != none )
		{
			HandCards = FactionState.GetHandCards();
			if( HandCards.Length > 0 )
			{
				if( FactionState.HasEmptyCardSlot() )
				{
					return true;
				}
			}
		}
	}

	return false;
}

function RefreshAllDecks()
{
	local XComGameState_HeadquartersResistance ResHQ;
	local XComGameState_ResistanceFaction FactionState;
	local array<StateObjectReference> HandCards, ListCards;
	local int idx;

	ResHQ = GetResistanceHQ();
	HandCards = ResHQ.GetHandCards();

	Hand.ClearItems();
	Hand.ClearPagination();
	RealizeHand(HandCards);

	for( idx = 0; idx < 4; idx++ )
	{
		FactionState = GetColumnFaction(idx);
		Columns[idx].ClearItems();

		if( FactionState == none )
		{
			ListCards = ResHQ.GetWildCardSlots();
		}
		else
		{
			ActivatePolicyColumn(idx, FactionState.GetLeaderImage());
			switch(FactionState.GetMyTemplateName())
			{
				case 'Faction_Reapers':
				case 'Faction_Skirmishers':
				case 'Faction_Templars':
					FactionMasks[idx].Hide();
					break;
				default:
					if (FactionState.bMetXCom)
					{
						FactionMasks[idx].Show();
						FactionMasks[idx].LoadImage(FactionState.GetLeaderImage());
					}
					else
					{
						FactionMasks[idx].Hide();
					}
					break;
			}
			ListCards = FactionState.GetCardSlots();
		}

		RealizeColumn(Columns[idx], ListCards, idx);
	}

	RealizePolicyLabels();
	RealizePolicyTabs(HandCards);
	MC.BeginFunctionOp("LayoutPolicyTabs");
	MC.EndOp();
}

function XComGameState_ResistanceFaction GetFaction(int Index)
{
	local XComGameStateHistory History;
	local XComGameState_ResistanceFaction FactionState;

	if( Index < 0 || Index >= AllFactions.Length || AllFactions[Index] == '' )
	{
		return none;
	}

	History = `XCOMHISTORY;

	foreach History.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if( FactionState.GetMyTemplateName() == AllFactions[Index] )
		{
			return FactionState;
		}
	}

	return none;
}
