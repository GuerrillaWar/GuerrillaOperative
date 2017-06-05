class GuerrillaOperativeUtilities extends Object;

static function GO_GameState_UnitDomainExperience GetUnitDomainExperienceComponent(XComGameState_Unit Unit)
{
	if (Unit != none) 
		return GO_GameState_UnitDomainExperience(
      Unit.FindComponentObject(class'GO_GameState_UnitDomainExperience')
    );
	return none;
}

static function GO_GameState_UnitDomainExperience GetOrCreateUnitDomainExperience(
  XComGameState_Unit Unit,
  optional XComGameState NewGameState = none
)
{
  local GO_GameState_UnitDomainExperience DomainExperienceState;
	local XComGameStateHistory History;
	local bool bSubmitGameState;

  DomainExperienceState = GetUnitDomainExperienceComponent(Unit);

  if (DomainExperienceState != none)
  {
    return DomainExperienceState;
  }

	History = `XCOMHISTORY;
	bSubmitGameState = false;

	if(NewGameState == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("IniitUnitDomainExperience");
		bSubmitGameState = true;
	}

  DomainExperienceState = GO_GameState_UnitDomainExperience(
    NewGameState.CreateStateObject(class'GO_GameState_UnitDomainExperience')
  );
  DomainExperienceState.InitDomains();
  Unit.AddComponentObject(DomainExperienceState);
  NewGameState.AddStateObject(DomainExperienceState);

	if(bSubmitGameState)
	{
		if(NewGameState.GetNumGameStateObjects() > 0)
		{
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		}
		else
		{
			History.CleanupPendingGameState(NewGameState);
		}
	}

  return DomainExperienceState;
}
