class GO_TacticalActivityTracker extends XComGameState_BaseObject;

struct GO_TacticalActivityEquipment {
  var name WeaponCat;
  var name ItemCat;
  var int Shots;
  var int Hits;
  var int Kills;
};

struct GO_TacticalActivityRecord {
  var StateObjectReference UnitRef;
  var int Shots;
  var int Hits;
  var int Kills;
  var array<GO_TacticalActivityEquipment> EquipmentRecords;
};

var array<GO_TacticalActivityRecord> ActivityRecords;

static function OnPreMission(XComGameState StartState, XComGameState_MissionSite MissionState)
{
  local GO_TacticalActivityTracker Tracker;
	local Object ListenerObj;
  local X2EventManager EventMgr;

  Tracker = GO_TacticalActivityTracker(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'GO_TacticalActivityTracker', true));

  if (Tracker == none) {
    Tracker = GO_TacticalActivityTracker(
      StartState.CreateStateObject(class'GO_TacticalActivityTracker')
    );
  }
  Tracker.InitData();
  StartState.AddStateObject(Tracker);

  ListenerObj = Tracker;
	if (ListenerObj == none)
	{
		`Redscreen("GO_TacticalActivityTracker: Failed to find Tracker when registering listener");
		return;
	}

	EventMgr = `XEVENTMGR;
  EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', Tracker.OnAbilityActivated, ELD_OnStateSubmitted, , , true);
  EventMgr.RegisterForEvent(ListenerObj, 'KillMail', Tracker.OnKillMail, ELD_OnStateSubmitted, , , true);
  EventMgr.RegisterForEvent(ListenerObj, 'WeaponKillType', Tracker.OnWeaponKillType, ELD_OnStateSubmitted, , , true);
}

static function OnPostMission()
{
  local XComGameState NewGameState;
	local Object ListenerObj;
  local GO_TacticalActivityTracker Tracker;

  Tracker = GO_TacticalActivityTracker(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'GO_TacticalActivityTracker', true));

  if (Tracker != none) {
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("IniitUnitDomainExperience");
    Tracker.ProcessDomainExperience(NewGameState);
    NewGameState.RemoveStateObject(Tracker.ObjectID);
    `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

    ListenerObj = Tracker;

    `XEVENTMGR.UnRegisterFromAllEvents(ListenerObj);
  }


}

function InitData ()
{
  `log("GO_TacticalActivityTracker:: InitData");
}


function ProcessDomainExperience (XComGameState NewGameState)
{
  local XComGameState_Unit Unit;
  local GO_GameState_UnitDomainExperience UnitExperience;
  local GO_TacticalActivityRecord ActivityRecord;
  local GO_TacticalActivityEquipment EquipmentRecord;
  local X2StrategyElementTemplateManager Manager;
  local array<X2StrategyElementTemplate> Templates;
  local X2StrategyElementTemplate Template;
  local GO_AbilityDomainTemplate DomainTemplate;
  local XComGameStateHistory History;
  local GO_UnitDomainStats DomainStats;
  local GO_DomainItemExperienceData ExperienceData;
  local int DomainIx, XPGained, EarnedRanks, StartingRanks;

  local XComGameState_Item InventoryItem;
  local array<XComGameState_Item> CurrentInventory;
  local name WeaponCat, ItemCat;

  `log("GO_TacticalActivityTracker:: ProcessDomainExperience");
  LogState();
  `log("GO_TacticalActivityTracker:: Processing...");

  History = `XCOMHISTORY;
  Manager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
  Templates = Manager.GetAllTemplatesOfClass(class'GO_AbilityDomainTemplate');


  foreach ActivityRecords(ActivityRecord)
  {
    Unit = XComGameState_Unit(
      History.GetGameStateForObjectID(ActivityRecord.UnitRef.ObjectID)
    );
    `log("Unit #" $ Unit.ObjectID);

    UnitExperience = class'GuerrillaOperativeUtilities'.static.GetOrCreateUnitDomainExperience(Unit, NewGameState);

    foreach Templates(Template)
    {
      DomainTemplate = GO_AbilityDomainTemplate(Template);
      DomainIx = UnitExperience.AllDomainStats.Find('DomainName', DomainTemplate.DataName);
      XPGained = 0;

      CurrentInventory = Unit.GetAllInventoryItems(NewGameState);
      foreach CurrentInventory(InventoryItem)
      {
        ItemCat = InventoryItem.GetMyTemplate().ItemCat;
        WeaponCat = InventoryItem.GetWeaponCategory();

        foreach DomainTemplate.ItemExperienceData(ExperienceData)
        {
          if (ExperienceData.ItemCat == ItemCat && ExperienceData.WeaponCat == WeaponCat)
          {
            XPGained += ExperienceData.XpForTakingOnMission;
          }
        }
      }

      foreach ActivityRecord.EquipmentRecords(EquipmentRecord)
      {
        foreach DomainTemplate.ItemExperienceData(ExperienceData)
        {
          if (ExperienceData.ItemCat == ItemCat && ExperienceData.WeaponCat == WeaponCat)
          {
            XPGained += (EquipmentRecord.Hits * ExperienceData.XpForHits);
            XPGained += ((EquipmentRecord.Shots - EquipmentRecord.Hits) * ExperienceData.XpForMisses);
            XPGained += (EquipmentRecord.Kills * ExperienceData.XpForKills);
          }
        }
      }

      `log("-" @ DomainTemplate.DataName $ ":" @ XPGained $ "+");
      UnitExperience.AllDomainStats[DomainIx].Experience += XPGained;
      `log("  Experience up to" @ UnitExperience.AllDomainStats[DomainIx].Experience);
      
      StartingRanks = (
        UnitExperience.AllDomainStats[DomainIx].EarnedAbilities.Length + 
        UnitExperience.AllDomainStats[DomainIx].RankPoints
      );
      EarnedRanks = 0;

      while (
        (StartingRanks + EarnedRanks < 7) &&
        (UnitExperience.AllDomainStats[DomainIx].Experience >= DomainTemplate.DomainRanks[StartingRanks + EarnedRanks].ExperienceRequired)
      )
      {
        UnitExperience.AllDomainStats[DomainIx].Experience -= DomainTemplate.DomainRanks[StartingRanks + EarnedRanks].ExperienceRequired;
        EarnedRanks += 1;
      }

      `log("  Ranks Earned:" $ EarnedRanks);
      UnitExperience.AllDomainStats[DomainIx].RankPoints += EarnedRanks;
      `log(
        "  Final Experience at " @
        UnitExperience.AllDomainStats[DomainIx].Experience @
        "with" @ UnitExperience.AllDomainStats[DomainIx].RankPoints @
        "ranks"
      );
    }
  }
}



// RECORDING






function RecordKill (XComGameState_Unit Killer) {
  local GO_TacticalActivityRecord ActivityRecord, NewActivityRecord;
  local StateObjectReference KillerRef;
  local int Ix, RecordIx;

  KillerRef = Killer.GetReference();
  RecordIx = INDEX_NONE;

  foreach ActivityRecords(ActivityRecord, Ix)
  {
    if (ActivityRecord.UnitRef.ObjectID == KillerRef.ObjectID)
    {
      RecordIx = Ix;
      break;
    }
  }

  if (RecordIx != INDEX_NONE)
  {
    ActivityRecords[RecordIx].Kills = ActivityRecords[RecordIx].Kills + 1;
  }
  else
  {
    NewActivityRecord.Kills = 1;
    NewActivityRecord.UnitRef = KillerRef;
    ActivityRecords.AddItem(NewActivityRecord);
  }
}

function RecordWeaponShot (XComGameState_Unit Killer, name ItemCat, name WeaponCat, bool bIsHit)
{
  local GO_TacticalActivityRecord ActivityRecord, NewActivityRecord;
  local GO_TacticalActivityEquipment EquipmentRecord, NewEquipmentRecord;
  local StateObjectReference KillerRef;
  local int Ix, RecordIx, EquipmentIx;

  KillerRef = Killer.GetReference();
  RecordIx = INDEX_NONE;
  EquipmentIx = INDEX_NONE;

  foreach ActivityRecords(ActivityRecord, Ix)
  {
    if (ActivityRecord.UnitRef.ObjectID == KillerRef.ObjectID)
    {
      RecordIx = Ix;
      break;
    }
  }

  if (RecordIx != INDEX_NONE)
  {
    foreach ActivityRecords[RecordIx].EquipmentRecords(EquipmentRecord, Ix)
    {
      if (
        EquipmentRecord.WeaponCat == WeaponCat &&
        EquipmentRecord.ItemCat == ItemCat
      )
      {
        EquipmentIx = Ix;
        break;
      }
    }

    ActivityRecords[RecordIx].Shots = ActivityRecords[RecordIx].Shots + 1;
    if (bIsHit)
    {
      ActivityRecords[RecordIx].Hits = ActivityRecords[RecordIx].Hits + 1;
    }

    if (EquipmentIx != INDEX_NONE)
    {
      ActivityRecords[RecordIx].EquipmentRecords[EquipmentIx].Shots = (
        ActivityRecords[RecordIx].EquipmentRecords[EquipmentIx].Shots + 1
      );

      if (bIsHit)
      {
        ActivityRecords[RecordIx].EquipmentRecords[EquipmentIx].Hits = (
          ActivityRecords[RecordIx].EquipmentRecords[EquipmentIx].Hits + 1
        );
      }
    }
    else
    {
      NewEquipmentRecord.ItemCat = ItemCat;
      NewEquipmentRecord.WeaponCat = WeaponCat;
      NewEquipmentRecord.Shots = 1;
      if (bIsHit)
      {
        NewEquipmentRecord.Hits = 1;
      }
      ActivityRecords[RecordIx].EquipmentRecords.AddItem(NewEquipmentRecord);
    }
  }
  else
  {
    NewActivityRecord.UnitRef = KillerRef;
    NewActivityRecord.Shots = 1;
    NewEquipmentRecord.ItemCat = ItemCat;
    NewEquipmentRecord.WeaponCat = WeaponCat;
    NewEquipmentRecord.Shots = 1;
    if (bIsHit)
    {
      NewActivityRecord.Hits = 1;
      NewEquipmentRecord.Hits = 1;
    }
    NewActivityRecord.EquipmentRecords.AddItem(NewEquipmentRecord);
    ActivityRecords.AddItem(NewActivityRecord);
  }
}

function RecordWeaponKill (XComGameState_Unit Killer, name ItemCat, name WeaponCat)
{
  local GO_TacticalActivityRecord ActivityRecord, NewActivityRecord;
  local GO_TacticalActivityEquipment EquipmentRecord, NewEquipmentRecord;
  local StateObjectReference KillerRef;
  local int Ix, RecordIx, EquipmentIx;

  KillerRef = Killer.GetReference();
  RecordIx = INDEX_NONE;
  EquipmentIx = INDEX_NONE;

  foreach ActivityRecords(ActivityRecord, Ix)
  {
    if (ActivityRecord.UnitRef.ObjectID == KillerRef.ObjectID)
    {
      RecordIx = Ix;
      break;
    }
  }

  if (RecordIx != INDEX_NONE)
  {
    foreach ActivityRecords[RecordIx].EquipmentRecords(EquipmentRecord, Ix)
    {
      if (
        EquipmentRecord.WeaponCat == WeaponCat &&
        EquipmentRecord.ItemCat == ItemCat
      )
      {
        EquipmentIx = Ix;
        break;
      }
    }

    if (EquipmentIx != INDEX_NONE)
    {
      ActivityRecords[RecordIx].EquipmentRecords[EquipmentIx].Kills = (
        ActivityRecords[RecordIx].EquipmentRecords[EquipmentIx].Kills + 1
      );
    }
    else
    {
      NewEquipmentRecord.ItemCat = ItemCat;
      NewEquipmentRecord.WeaponCat = WeaponCat;
      NewEquipmentRecord.Kills = 1;
      ActivityRecords[RecordIx].EquipmentRecords.AddItem(NewEquipmentRecord);
    }
  }
  else
  {
    NewActivityRecord.UnitRef = KillerRef;
    NewEquipmentRecord.ItemCat = ItemCat;
    NewEquipmentRecord.WeaponCat = WeaponCat;
    NewEquipmentRecord.Kills = 1;
    NewActivityRecord.EquipmentRecords.AddItem(NewEquipmentRecord);
    ActivityRecords.AddItem(NewActivityRecord);
  }
}

function LogState ()
{
  local GO_TacticalActivityRecord ActivityRecord;
  local GO_TacticalActivityEquipment EquipmentRecord;

  foreach ActivityRecords(ActivityRecord)
  {
    `log(
      "Unit #" $ ActivityRecord.UnitRef.ObjectID $ " - " $
      ActivityRecord.Kills $ " kills - " $ ActivityRecord.Hits $ "/" $
      ActivityRecord.Shots $ " shots"
    );
    foreach ActivityRecord.EquipmentRecords(EquipmentRecord)
    {
      `log(
        "- " $ EquipmentRecord.ItemCat $ ":" $ EquipmentRecord.WeaponCat $ " - " $
        EquipmentRecord.Kills $ " kills - " $ EquipmentRecord.Hits $ "/" $
        EquipmentRecord.Shots $ " shots"
      );
    }
  }
}


// EVENTS
function EventListenerReturn OnKillMail(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
  local XComGameState_Unit Killer, Target;
  local GO_TacticalActivityTracker Tracker;
  local XComGameState NewGameState;

  Killer = XComGameState_Unit(EventSource);
  Target = XComGameState_Unit(EventData);

  Tracker = GO_TacticalActivityTracker(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'GO_TacticalActivityTracker', true));
  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("IncrementFromKillMail");
  Tracker = GO_TacticalActivityTracker(NewGameState.CreateStateObject(class'GO_TacticalActivityTracker', Tracker.ObjectID));
  Tracker.RecordKill(Killer);
  Tracker.LogState();
  NewGameState.AddStateObject(Tracker);
  `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	return ELR_NoInterrupt;
}

function EventListenerReturn OnAbilityActivated(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
  local XComGameStateContext_Ability AbilityContext;
  local AbilityResultContext ResultContext;
  local XComGameState_Ability Ability;
  local X2AbilityTemplate AbilityTemplate;
  local XComGameState_Unit Shooter;
  local X2ItemTemplate ItemTemplate;
  local X2WeaponTemplate WeaponTemplate;
  local XComGameState_Item SourceWeapon;
  local GO_TacticalActivityTracker Tracker;
  local XComGameState NewGameState;
  local XComGameStateHistory History;
  local name ItemCat, WeaponCat;

  History = `XCOMHISTORY;
  if (GameState.GetContext().InterruptionStatus == eInterruptionStatus_Interrupt) return ELR_NoInterrupt;

  Shooter = XComGameState_Unit(EventSource);
  Ability = XComGameState_Ability(EventData);
  AbilityTemplate = Ability.GetMyTemplate();
  AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
  ResultContext = AbilityContext.ResultContext;

  if (AbilityTemplate.Hostility != eHostility_Offensive) { return ELR_NoInterrupt; }
  if (AbilityContext.InterruptionStatus == eInterruptionStatus_Interrupt) { return ELR_NoInterrupt; }
  if (Ability.SourceWeapon.ObjectID == 0) { return ELR_NoInterrupt; }

  SourceWeapon = XComGameState_Item(History.GetGameStateForObjectID(Ability.SourceWeapon.ObjectID));
  ItemTemplate = SourceWeapon.GetMyTemplate();
  ItemCat = ItemTemplate.ItemCat;
  WeaponTemplate = X2WeaponTemplate(ItemTemplate);
  if (WeaponTemplate != none)
  {
    WeaponCat = WeaponTemplate.WeaponCat;
  }

  Tracker = GO_TacticalActivityTracker(History.GetSingleGameStateObjectForClass(class'GO_TacticalActivityTracker', true));
  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("IncrementFromKillMail");
  Tracker = GO_TacticalActivityTracker(NewGameState.CreateStateObject(class'GO_TacticalActivityTracker', Tracker.ObjectID));
  Tracker.RecordWeaponShot(Shooter, ItemCat, WeaponCat, AbilityContext.IsResultContextHit());
  Tracker.LogState();
  NewGameState.AddStateObject(Tracker);
  `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	return ELR_NoInterrupt;
}

function EventListenerReturn OnWeaponKillType(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
  local XComGameState_Unit Killer;
  local XComGameState_Ability Ability;
  local X2ItemTemplate ItemTemplate;
  local X2WeaponTemplate WeaponTemplate;
  local XComGameState_Item SourceWeapon;
  local GO_TacticalActivityTracker Tracker;
  local XComGameState NewGameState;
  local XComGameStateHistory History;
  local name ItemCat, WeaponCat;

  History = `XCOMHISTORY;

  Killer = XComGameState_Unit(EventSource);
  Ability = XComGameState_Ability(EventData);
  SourceWeapon = XComGameState_Item(History.GetGameStateForObjectID(Ability.SourceWeapon.ObjectID));
  ItemTemplate = SourceWeapon.GetMyTemplate();
  ItemCat = ItemTemplate.ItemCat;
  WeaponTemplate = X2WeaponTemplate(ItemTemplate);
  if (WeaponTemplate != none)
  {
    WeaponCat = WeaponTemplate.WeaponCat;
  }

  Tracker = GO_TacticalActivityTracker(History.GetSingleGameStateObjectForClass(class'GO_TacticalActivityTracker', true));
  NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("IncrementFromKillMail");
  Tracker = GO_TacticalActivityTracker(NewGameState.CreateStateObject(class'GO_TacticalActivityTracker', Tracker.ObjectID));
  Tracker.RecordWeaponKill(Killer, ItemCat, WeaponCat);
  Tracker.LogState();
  NewGameState.AddStateObject(Tracker);
  `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	return ELR_NoInterrupt;
}
