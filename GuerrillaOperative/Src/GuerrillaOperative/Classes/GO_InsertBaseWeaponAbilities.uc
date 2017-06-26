class GO_InsertBaseWeaponAbilities extends Object;

static function AddBaseAbilitiesToWeapons()
{
  local array<name> AbilityList;
	local name AbilityName;

	// I thought this would work to add the abilities that classes come with
  // standard but its not enough Gremlin skills work but nothing else does.
  AbilityList.AddItem('LaunchGrenade');
  AbilityList.AddItem('GO_LoadGrenades');
  AddAbilitiesToItem('GrenadeLauncher_CV', AbilityList);
  AddAbilitiesToItem('GrenadeLauncher_MG', AbilityList);


  AbilityList.Length = 0;
  AbilityList.AddItem('AidProtocol');
  AbilityList.AddItem('IntrusionProtocol');
  AddAbilitiesToItem('Gremlin_CV', AbilityList);
  AddAbilitiesToItem('Gremlin_MG', AbilityList);
  AddAbilitiesToItem('Gremlin_BM', AbilityList);


  AbilityList.Length = 0;
  AbilityList.AddItem('PistolStandardShot');
  AddAbilitiesToItem('Pistol_CV', AbilityList);
  AddAbilitiesToItem('Pistol_MG', AbilityList);
  AddAbilitiesToItem('Pistol_BM', AbilityList);


  AbilityList.Length = 0;
  AbilityList.AddItem('GO_Sniper_Setup');
  AddAbilitiesToItem('SniperRifle_CV', AbilityList);
  AddAbilitiesToItem('SniperRifle_MG', AbilityList);
  AddAbilitiesToItem('SniperRifle_BM', AbilityList);


  AbilityList.Length = 0;
  AbilityList.AddItem('SwordSlice');
  AddAbilitiesToItem('Sword_CV', AbilityList);
  AddAbilitiesToItem('Sword_BM', AbilityList);
  AddAbilitiesToItem('Sword_MG', AbilityList);
}

static function AddAbilitiesToItem(name TemplateName, array<name> AbilitiesToAdd) {
	local X2ItemTemplateManager ItemManager;
  local array<X2DataTemplate> Templates;
  local X2DataTemplate Template;
  local X2EquipmentTemplate EquipTemplate;
	local name AbilityName;

	ItemManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
  ItemManager.FindDataTemplateAllDifficulties(TemplateName, Templates);

  foreach Templates(Template)
  {
    EquipTemplate = X2EquipmentTemplate(Template);
    foreach AbilitiesToAdd(AbilityName)
    {
      EquipTemplate.Abilities.AddItem(AbilityName);
    }
  }
}
