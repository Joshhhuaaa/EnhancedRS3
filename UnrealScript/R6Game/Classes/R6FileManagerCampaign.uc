class R6FileManagerCampaign extends R6FileManager
	native;

//native(1003) final function R6PlayerCampaign LoadCampaign(string szFileName);
native(1003) final function BOOL LoadCampaign(R6PlayerCampaign myCampaign);
native(1004) final function BOOL SaveCampaign(R6PlayerCampaign myCampaign);

defaultproperties
{
}
