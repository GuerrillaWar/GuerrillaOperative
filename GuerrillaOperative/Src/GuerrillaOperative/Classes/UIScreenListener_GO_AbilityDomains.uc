class UIScreenListener_GO_AbilityDomains extends UIScreenListener;

var UIArmory_MainMenu ArmoryMainMenu;
var UIListItemString WeaponAbilitiesButton;
var delegate<OnItemSelectedCallback> NextOnSelectionChanged;

var bool bRegisteredForEvents;

var localized string strWeaponAbilitiesMenuText;
var localized string strWeaponAbilitiesMenuDescription;

delegate OnItemSelectedCallback(UIList _list, int itemIndex);


private function bool IsInStrategy()
{
	return `HQGAME  != none && `HQPC != None && `HQPRES != none;
}

event OnInit(UIScreen Screen)
{
  `log("GO_ScreenListener: OnInit");
	//reset switch in tactical so we re-register back in strategy
	if(UITacticalHUD(Screen) == none)
	{
		RegisterForEvents();
		bRegisteredForEvents = false;
	}
	if(IsInStrategy() && !bRegisteredForEvents)
	{
		RegisterForEvents();
		bRegisteredForEvents = true;
	}
}

function RegisterForEvents()
{
	local X2EventManager EventManager;
	local Object ThisObj;

	ThisObj = self;

  `log("GO_ScreenListener: RegisterEvents");
	EventManager = `XEVENTMGR;
	EventManager.UnRegisterFromAllEvents(ThisObj);
	EventManager.RegisterForEvent(ThisObj, 'OnArmoryMainMenuUpdate', AddArmoryMainMenuItem,,,,true);
}


function EventListenerReturn AddArmoryMainMenuItem(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	local UIList List;
	local XComGameState_Unit Unit;

	`LOG("AddArmoryMainMenuItem: Starting.");

	List = UIList(EventData);
	if(List == none)
	{
		`REDSCREEN("Add Armory MainMenu event triggered with invalid event data.");
		return ELR_NoInterrupt;
	}
	ArmoryMainMenu = UIArmory_MainMenu(EventSource);
	if(ArmoryMainMenu == none)
	{
		`REDSCREEN("Add Armory MainMenu event triggered with invalid event source.");
		return ELR_NoInterrupt;
	}

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ArmoryMainMenu.UnitReference.ObjectID));

	// -------------------------------------------------------------------------------
	// Leader Abilities: 
  WeaponAbilitiesButton = ArmoryMainMenu.Spawn(class'UIListItemString', List.ItemContainer).InitListItem(CAPS(default.strWeaponAbilitiesMenuText));
  WeaponAbilitiesButton.ButtonBG.OnClickedDelegate = OnWeaponAbilitiesButton;
  if(NextOnSelectionChanged == none)
  {
    NextOnSelectionChanged = List.OnSelectionChanged;
    List.OnSelectionChanged = OnSelectionChanged;
  }
  List.MoveItemToBottom(FindDismissListItem(List));
	return ELR_NoInterrupt;
}


//callback handler for list button -- invokes the LW officer ability UI
simulated function OnWeaponAbilitiesButton(UIButton kButton)
{
	local XComHQPresentationLayer HQPres;
	local GO_UIArmory_AbilityDomains AbilityScreen;

	HQPres = `HQPRES;
	AbilityScreen = GO_UIArmory_AbilityDomains(HQPres.ScreenStack.Push(HQPres.Spawn(class'GO_UIArmory_AbilityDomains', HQPres), HQPres.Get3DMovie()));
	AbilityScreen.InitPromotion(ArmoryMainMenu.GetUnitRef(), false);
}




simulated function UIListItemString FindDismissListItem(UIList List)
{
	local int Idx;
	local UIListItemString Current;

	for (Idx = 0; Idx < List.ItemCount ; Idx++)
	{
		Current = UIListItemString(List.GetItem(Idx));
		if (Current.Text == ArmoryMainMenu.m_strDismiss)
			return Current;
	}
	return none;
}


//callback handler for list button info at bottom of screen
simulated function OnSelectionChanged(UIList ContainerList, int ItemIndex)
{
	if (ContainerList.GetItem(ItemIndex) == WeaponAbilitiesButton) 
	{
		ArmoryMainMenu.MC.ChildSetString("descriptionText", "htmlText", class'UIUtilities_Text'.static.AddFontInfo(default.strWeaponAbilitiesMenuDescription, true));
		return;
	}
	NextOnSelectionChanged(ContainerList, ItemIndex);
}


event OnRemoved(UIScreen Screen)
{
	if(UIArmory_MainMenu(Screen) != none)
	{
		ArmoryMainMenu = none;
	}
}

defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = none;
}
