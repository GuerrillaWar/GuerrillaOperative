class GO_X2Effect_ThrowAndMove extends X2Effect_Persistent config(GO_Abilities);

var config array<name> ThrowAndMoveAbilities;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'GO_ThrowAndMove', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameStateHistory History;
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;
	local UnitValue UsedValue;
  local name UsedAbilityName;

  History = `XCOMHISTORY;
  UsedAbilityName = kAbility.GetMyTemplateName();

  if (default.ThrowAndMoveAbilities.Find(UsedAbilityName) != INDEX_NONE)
  {
    SourceUnit.GetUnitValue('UsedThrowAndMove', UsedValue);
    if (
      SourceUnit.NumActionPoints() == 0 &&
      PreCostActionPoints.Length > 0 &&
      UsedValue.fValue < 1
    )
    {
      AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
      if (AbilityState != none)
      {
        SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.MoveActionPoint);
        SourceUnit.SetUnitFloatValue('UsedThrowAndMove', 1, eCleanup_BeginTurn);

        EventMgr = `XEVENTMGR;
        EventMgr.TriggerEvent('GO_ThrowAndMove', AbilityState, SourceUnit, NewGameState);

        return true;
      }
    }
  }

	return false;
}
