class GO_X2Ability_ExplosiveAbilities extends X2Ability config(GO_Abilities);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

  // COMPETENCY

  // EXPERTISE
  Templates.AddItem(CreateThrowAndMoveAbility());

  // MASTERY

	return Templates;
}


static function X2AbilityTemplate CreateThrowAndMoveAbility()
{
	local X2AbilityTemplate						Template;
	local GO_X2Effect_ThrowAndMove               ThrowEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'GO_Explosive_ThrowAndMove');
	Template.IconImage = "img:///XPerkIconPack.UIPerk_grenade_move2";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bCrossClassEligible = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ThrowEffect = new class'GO_X2Effect_ThrowAndMove';
	ThrowEffect.BuildPersistentEffect(1, true, false, false);
	ThrowEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(ThrowEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	Template.bCrossClassEligible = true;

	return Template;
}

