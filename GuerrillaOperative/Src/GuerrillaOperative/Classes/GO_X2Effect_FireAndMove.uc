class GO_X2Effect_FireAndMove extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'GO_FireAndMove', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameStateHistory History;
	local XComGameState_Unit TargetUnit, PrevTargetUnit;
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;
	local UnitValue UsedValue;


	//  match the weapon associated with Fire And Move to the attacking weapon
	if (kAbility.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	{
		History = `XCOMHISTORY;
		//  check for a shot with open ground between target and shooter
		TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
		if (TargetUnit != None)
		{
			PrevTargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(TargetUnit.ObjectID));      //  get the most recent version from the history rather than our modified (attacked) version
			if (
        TargetUnit.IsFlanked(SourceUnit.GetReference()) &&
        SourceUnit.IsFlanked(TargetUnit.GetReference())
			)
      {
				//  if we have no standard actions left, but we had them before, then this obviously cost us something and we can refund an action point (provided we didn't trigger this yet this turn)
				if (
          SourceUnit.NumActionPoints() == 0 &&
          PreCostActionPoints.Length > 0 &&
          !SourceUnit.GetUnitValue('UsedFireAndMove', UsedValue)
        )
				{
					AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
					if (AbilityState != none)
					{
						SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
            SourceUnit.SetUnitFloatValue('UsedFireAndMove', 1, eCleanup_BeginTurn);

						EventMgr = `XEVENTMGR;
						EventMgr.TriggerEvent('GO_FireAndMove', AbilityState, SourceUnit, NewGameState);

						return true;
					}
				}
			}
		}
	}
	return false;
}
