class GO_X2Effect_ConcentratedFire extends X2Effect_Persistent config(GO_Abilities);

var config array<name> ConcentratedFireAbilities;
var config int ConcentratedFireAimModifier;
var config int ConcentratedFireCritModifier;
var localized string ConcentratedFireReason;


function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
  local ShotModifierInfo ModInfo;
  local name UsedAbilityName;
	local UnitValue UsedValue;

	if (AbilityState.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
  {
    UsedAbilityName = AbilityState.GetMyTemplateName();
    Attacker.GetUnitValue('GO_ConcentratedFire', UsedValue);

    if (
      default.ConcentratedFireAbilities.Find(UsedAbilityName) != INDEX_NONE &&
      int(UsedValue.fValue) == Target.ObjectID
    )
    {
      if (default.ConcentratedFireAimModifier != 0)
      {
        ModInfo.ModType = eHit_Success;
        ModInfo.Value = default.ConcentratedFireAimModifier;
        ModInfo.Reason = default.ConcentratedFireReason;
        ShotModifiers.AddItem(ModInfo);
      }

      if (default.ConcentratedFireCritModifier != 0)
      {
        ModInfo.ModType = eHit_Crit;
        ModInfo.Value = default.ConcentratedFireCritModifier;
        ModInfo.Reason = default.ConcentratedFireReason;
        ShotModifiers.AddItem(ModInfo);
      }
    }
  }
}


function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
  local name UsedAbilityName;
	local XComGameState_Unit TargetUnit;

	//  match the weapon associated with Fire And Move to the attacking weapon
	if (kAbility.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
	{
		TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
    UsedAbilityName = kAbility.GetMyTemplateName();
    if (default.ConcentratedFireAbilities.Find(UsedAbilityName) != INDEX_NONE)
    {
      SourceUnit.SetUnitFloatValue('GO_ConcentratedFire', TargetUnit.ObjectID, eCleanup_BeginTurn);
    }
	}
	return false; // only return false, true breaks other handlers from firing
}
