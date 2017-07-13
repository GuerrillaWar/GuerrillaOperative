class GO_X2Effect_DefensivePosture extends X2Effect_CoveringFire config(GO_Abilities);

var config int DefensivePostureAimModifier;
var localized string DefensivePostureReason;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
  local ShotModifierInfo ModInfo;

	if (AbilityState.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef)
  {
    ModInfo.ModType = eHit_Success;
    ModInfo.Value = default.DefensivePostureAimModifier;
    ModInfo.Reason = default.DefensivePostureReason;
    ShotModifiers.AddItem(ModInfo);
  }
}

DefaultProperties
{
	EffectName = "GO_DefensivePosture"
	DuplicateResponse = eDupe_Ignore
	MaxPointsPerTurn = 10
	bDirectAttackOnly = true
	bPreEmptiveFire = false
	bOnlyDuringEnemyTurn = true
}
