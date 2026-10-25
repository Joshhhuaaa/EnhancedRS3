//=============================================================================
//  R6IODevice : This should allow action moves on a Recon type device
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6IODevice extends R6IOObject
	placeable;

var(Debug)  bool		bShowLog;

var vector m_vOffset;

var(R6ActionObject) FLOAT m_fPlantTimeMin;   // Base time required to disarmed the bomb if they have 100%, will be affected by the kit later (Must be higher then 2 seconds)
var(R6ActionObject) FLOAT m_fPlantTimeMax;   // Base time required to disarmed the bomb if they have 0%
var(R6ActionObject) array<Material> m_ArmedTextures;
var(R6ActionObject) Texture m_InteractionIcon;

var Sound  m_PhoneBuggingSnd;
var Sound  m_PhoneBuggingStopSnd;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    if(Role == ROLE_Authority)
    {
        if (m_eAnimToPlay == BA_Keyboard || m_eAnimToPlay == BA_PlantDevice)
        {
            AddSoundBankName("SFX_Penthouse_Single");
            if (m_eAnimToPlay == BA_PlantDevice)
            {
                m_StartSnd = m_PhoneBuggingSnd;
                m_InterruptedSnd = m_PhoneBuggingStopSnd;
                m_CompletedSnd = m_PhoneBuggingStopSnd;
            }
        }

    }
}
simulated event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{
    local BOOL      bDisplayBombIcon;
	local vector	vActorDir;
	local vector    vFacingDir;
    
    if (CanToggle() == false || !m_bRainbowCanInteract )
        return;

	if(m_bIsActivated)
	{
		Query.iHasAction = 1;
	}
	else
	{
		Query.iHasAction = 0;
		return;
	}

    Query.textureIcon = m_InteractionIcon;    
    Query.iPlayerActionID      = eDeviceCircumstantialAction.DCA_Device;
    Query.iTeamActionID        = eDeviceCircumstantialAction.DCA_Device;
    Query.iTeamActionIDList[0] = eDeviceCircumstantialAction.DCA_Device;
    Query.iTeamActionIDList[1] = eDeviceCircumstantialAction.DCA_None;
    Query.iTeamActionIDList[2] = eDeviceCircumstantialAction.DCA_None;
    Query.iTeamActionIDList[3] = eDeviceCircumstantialAction.DCA_None;
	
    // check if player is within interaction range
    if( fDistance < m_fCircumstantialActionRange )           
    {
    	vFacingDir = vector(rotation);
        vFacingDir.Z = 0;
		vActorDir = Normal(location - playerController.Pawn.Location);
        vActorDir.Z = 0;
		if((vActorDir dot vFacingDir) > 0.85) 
            Query.iInRange = 1;
        else
            Query.iInRange = 0;
    }
    else
    {
        Query.iInRange = 0;
    }

    Query.bCanBeInterrupted = true;
    Query.fPlayerActionTimeRequired = GetTimeRequired(R6PlayerController(playerController).m_pawn);
}

simulated function string R6GetCircumstantialActionString( INT iAction )
{
	switch(iAction)
	{
		case eDeviceCircumstantialAction.DCA_Device:
			switch(m_eAnimToPlay)
			{
				case BA_Keyboard:	
					return Localize("RDVOrder", "Order_Computer", "R6Menu");
				case BA_Keypad:
					return Localize("RDVOrder", "Order_KeyPad", "R6Menu");
				case BA_PlantDevice:		
					return Localize("RDVOrder", "Order_PlantDevice", "R6Menu");
				default:					    
					return "";
			}
		default:	
			return "";
	}

}

simulated function ToggleDevice(R6Pawn aPawn)
{
	local INT iSkinCount;

    if (CanToggle() == false)
        return;

	Super.ToggleDevice(aPawn);

    if (bShowLog) log("Set Device"@Self@"by pawn"@aPawn@"and his controller"@aPawn.controller);
    
    m_bIsActivated = false;

	for (iSkinCount = 0; iSkinCount < m_ArmedTextures.Length; iSkinCount++)
	{
		SetSkin( m_ArmedTextures[iSkinCount], iSkinCount );
	}

    R6AbstractGameInfo(Level.Game).IObjectInteract(aPawn, Self);
}

simulated function BOOL HasKit(R6Pawn aPawn)
{
    return R6Rainbow(aPawn).m_bHasElectronicsKit;       
}

simulated function FLOAT GetMaxTimeRequired()
{
    return m_fPlantTimeMax;
}

simulated function FLOAT GetTimeRequired(R6Pawn aPawn)
{
    local FLOAT fPlantingTime;

    if (bShowLog) log("GetTimeRequired"@ m_fPlantTimeMin @ aPawn @ aPawn.GetSkill(SKILL_Electronics));
    fPlantingTime = m_fPlantTimeMin + ((1 - aPawn.GetSkill(SKILL_Electronics)) * (m_fPlantTimeMax-m_fPlantTimeMin));

    if ( HasKit(aPawn) && ( fPlantingTime - m_fGainTimeWithElectronicsKit > 0))
        fPlantingTime -= m_fGainTimeWithElectronicsKit;

    return fPlantingTime;
}

defaultproperties
{
     m_fPlantTimeMin=4.000000
     m_fPlantTimeMax=12.000000
     m_InteractionIcon=Texture'R6ActionIcons.InteractiveDevice'
     m_PhoneBuggingSnd=Sound'SFX_Penthouse_Single.Play_PhoneBugging'
     m_PhoneBuggingStopSnd=Sound'SFX_Penthouse_Single.Stop_PhoneBugging_Go'
     m_bIsActivated=True
     m_StartSnd=Sound'SFX_Penthouse_Single.Play_seq_random_CompType'
     m_InterruptedSnd=Sound'SFX_Penthouse_Single.Stop_seq_random_CompType_Go'
     m_CompletedSnd=Sound'SFX_Penthouse_Single.Stop_seq_random_CompType_Go'
}
