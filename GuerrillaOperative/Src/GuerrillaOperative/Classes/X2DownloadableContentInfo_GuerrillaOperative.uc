class X2DownloadableContentInfo_GuerrillaOperative extends X2DownloadableContentInfo Config(Game);

static event OnPostTemplatesCreated()
{
	`log("GuerrillaOperative :: Present and Correct");
	UpdateTemplatesForGWT();
}

static function UpdateTemplatesForGWT()
{
	class'GO_InsertBaseWeaponAbilities'.static.AddBaseAbilitiesToWeapons();
}
