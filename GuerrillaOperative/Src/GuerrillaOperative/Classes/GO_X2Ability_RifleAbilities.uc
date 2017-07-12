class GO_X2Ability_RifleAbilities extends X2Ability config(GO_Abilities);

/* var localized string SetupAbilityFlyover; */
/* var localized string ZeroSightsFlyover; */
/* var localized string ZeroSightsEffectName; */
/* var localized string ZeroSightsEffectDesc; */

/* var config int RECON_BY_SCOPE_DURATION; */
/* var config float RECON_BY_SCOPE_RADIUS; */

/* var config int SETUP_DEFENSE_MODIFIER; */

/* var config int VITAL_POINT_AIM_MODIFIER; */
/* var config int VITAL_POINT_CRIT_MODIFIER; */

/* var config int LOCKDOWN_AIM_MODIFIER; */
/* var config int LOCKDOWN_CRIT_MODIFIER; */

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

  // COMPETENCY
  Templates.AddItem(CreateConcentratedFireAbility());
  Templates.AddItem(CreateFireAndMoveAbility());

  // EXPERTISE

  // MASTERY

	return Templates;
}


static function X2AbilityTemplate CreateConcentratedFireAbility()
{
	local X2AbilityTemplate						Template;
	local GO_X2Effect_ConcentratedFire               FireEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Rifle_ConcentratedFire');
	Template.IconImage = "img:///XPerkIconPack.UIPerk_rifle_chevron_x2";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bCrossClassEligible = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	FireEffect = new class'GO_X2Effect_ConcentratedFire';
	FireEffect.BuildPersistentEffect(1, true, false, false);
	FireEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(FireEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}


static function X2AbilityTemplate CreateFireAndMoveAbility()
{
	local X2AbilityTemplate						Template;
	local GO_X2Effect_FireAndMove               FireEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Rifle_FireAndMove');
	Template.IconImage = "img:///XPerkIconPack.UIPerk_rifle_move2";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bCrossClassEligible = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	FireEffect = new class'GO_X2Effect_FireAndMove';
	FireEffect.BuildPersistentEffect(1, true, false, false);
	FireEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(FireEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}


static function StatModVisualizationApplied(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

static function StatModVisualizationRemoved(XComGameState VisualizeGameState, out VisualizationTrack BuildTrack, const name EffectApplyResult)
{
	class'X2StatusEffects'.static.UpdateUnitFlag(BuildTrack, VisualizeGameState.GetContext());
}

