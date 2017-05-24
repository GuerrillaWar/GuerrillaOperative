// Code largely adapted from GrimyBunyip's UtilitySlotSidearms

class GO_X2Effect_LoadGrenades extends X2Effect_Persistent;

simulated function bool OnEffectTicked(const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication) {
	local XComGameState_Unit UnitState;
	local array<XComGameState_Item> ItemStates;
	local XComGameState_Item InventoryItem, WeaponState;
	local X2AbilityTemplateManager AbilityManager;
	local X2AbilityTemplate AbilityTemplate;
			
	AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplate = AbilityManager.FindAbilityTemplate('LaunchGrenade');

	// Check all of the unit's inventory items
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	ItemStates = UnitState.GetAllInventoryItems(NewGameState);
	WeaponState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

	foreach ItemStates(InventoryItem) {
		if (InventoryItem.bMergedOut) 
			continue;

		if (X2GrenadeTemplate(InventoryItem.GetMyTemplate()) != none)
		{ 
			`LOG("GRENADE TEMPLATE FOUND WITH NAME: " $ InventoryItem.GetMyTemplate().DataName);
			`TACTICALRULES.InitAbilityForUnit(AbilityTemplate, UnitState, NewGameState, WeaponState.GetReference(), InventoryItem.GetReference());
		}
	}
	return false;
}
