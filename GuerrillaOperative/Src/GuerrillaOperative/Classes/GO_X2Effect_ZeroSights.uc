class GO_X2Effect_ZeroSights extends X2Effect_Persistent config(GO_Abilities);

var config array<int> ZeroSightsAimModifierRange;
var config array<int> ZeroSightsCritModifierRange;
var localized string ZeroSightsReason;


function int GetZeroDistanceFromEffectState(XComGameState_Effect EffectState)
{
  local int ZeroDistance;
  // local TTile ZeroTile;
	local XComWorldData WorldData;
  local XComGameStateHistory History;
  local XComGameState_Unit Shooter;
  local vector ShooterPosition;
  local vector ZeroTarget;

	WorldData = `XWORLD;
  History = `XCOMHISTORY;
  ZeroTarget = EffectState.ApplyEffectParameters.AbilityInputContext.TargetLocations[0];
  Shooter = XComGameState_Unit(History.GetGameStateForObjectID(
    EffectState.ApplyEffectParameters.AbilityInputContext.SourceObject.ObjectID
  ));
  ShooterPosition = WorldData.GetPositionFromTileCoordinates(Shooter.TileLocation);
  // ZeroTile = WorldData.GetTileCoordinatesFromPosition(ZeroTarget);
  ZeroDistance = VSize(ShooterPosition - ZeroTarget) / WorldData.WORLD_StepSize;

  return ZeroDistance;
}


function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
  local int ZeroDistance, TargetDistance, ZeroDiff;
  local int AimMod, CritMod;
  local ShotModifierInfo ModInfo;

  ZeroDistance = GetZeroDistanceFromEffectState(EffectState);
  TargetDistance = Attacker.TileDistanceBetween(Target);
  ZeroDiff = Round(Abs(float(ZeroDistance - TargetDistance)));

  AimMod = ZeroDiff >= (default.ZeroSightsAimModifierRange.Length - 1)
    ? default.ZeroSightsAimModifierRange[default.ZeroSightsAimModifierRange.Length - 1]
    : default.ZeroSightsAimModifierRange[ZeroDiff];

  CritMod = ZeroDiff >= (default.ZeroSightsCritModifierRange.Length - 1)
    ? default.ZeroSightsCritModifierRange[default.ZeroSightsCritModifierRange.Length - 1]
    : default.ZeroSightsCritModifierRange[ZeroDiff];

  ModInfo.ModType = eHit_Success;
  ModInfo.Value = AimMod;
  ModInfo.Reason = default.ZeroSightsReason $ " (" $ ZeroDistance $ ")";
  ShotModifiers.AddItem(ModInfo);

  ModInfo.ModType = eHit_Crit;
  ModInfo.Value = CritMod;
  ModInfo.Reason = default.ZeroSightsReason $ " (" $ ZeroDistance $ ")";
  ShotModifiers.AddItem(ModInfo);
}



// remove effect on movement
function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	if (AbilityContext.InputContext.MovementPaths[0].MovementTiles.Length > 0)
	{
		EffectState.RemoveEffect(NewGameState, NewGameState);
	}

	return false;
}
