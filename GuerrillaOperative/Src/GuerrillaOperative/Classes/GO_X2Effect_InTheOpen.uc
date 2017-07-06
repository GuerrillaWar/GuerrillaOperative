class GO_X2Effect_InTheOpen extends X2Effect_Persistent config(GO_Abilities);

var localized string InTheOpenReason;
var config int InTheOpenAimModifier;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
  local ShotModifierInfo ModInfo;

  if (bFlanking) {
    ModInfo.ModType = eHit_Success;
    ModInfo.Value = default.InTheOpenAimModifier;
    ModInfo.Reason = default.InTheOpenReason;
    ShotModifiers.AddItem(ModInfo);
  }
}
