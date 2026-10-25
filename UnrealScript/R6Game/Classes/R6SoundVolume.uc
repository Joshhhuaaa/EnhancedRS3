//=============================================================================
//  R6SoundVolume.uc : This class allow to have sound when the player enter 
//					   and leave a Volume.  All other volume should derive this
//                     class in order to allow sound designer to reuse other 
//                     volume already placed by a level designer
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/01/13 * Created by Eric Begin
//============================================================================//
class R6SoundVolume extends Volume
	native;

var (R6Sound) array<Sound> m_EntrySound;
var (R6Sound) array<Sound> m_ExitSound;
var (R6Sound) ESoundSlot   m_eSoundSlot; 




simulated event Touch(Actor Other)
{
    local INT iSoundIndex;
	local Controller C;
    local bool bMissionPack;

	Super.Touch(Other);

    if (Other.IsA('R6Pawn'))
        C = Pawn(Other).Controller;
    else if (Other.IsA('R6PlayerController'))
        C = Controller(Other);

    if (C != none)
    {
		C.m_CurrentAmbianceObject = self;
		C.m_CurrentVolumeSound = self;
		C.m_bUseExitSounds = FALSE;

        if ((PlayerController(C) != None)  && (Viewport(PlayerController(C).Player) != None))
        {
            bMissionPack = class'Actor'.static.GetModMgr().IsMissionPack();
            if ( !bMissionPack )
            {
			    for (iSoundIndex = 0; iSoundIndex < m_EntrySound.Length; iSoundIndex++)
			    {
				    PlaySound(m_EntrySound[iSoundIndex], m_eSoundSlot);
			    }
            }
            else
            {
			    for (iSoundIndex = 0; iSoundIndex < m_EntrySound.Length; iSoundIndex++)
			    {
				    //PlaySound(m_EntrySound[iSoundIndex], m_eSoundSlot);//MissionPack1
				    //////Begin MissionPack1
				    if(m_bPlayOnlyOnce)
				    {
					    if(!m_bSoundWasPlayed)
					    {
						    PlaySound(m_EntrySound[iSoundIndex], m_eSoundSlot);
						    m_bSoundWasPlayed = true;
					    }
				    }
				    else
					    PlaySound(m_EntrySound[iSoundIndex], m_eSoundSlot);
				    //////End MissionPack1
			    }
            }
	    }
     }
}

simulated event UnTouch(Actor Other)
{
    local INT iSoundIndex;
	local Controller C;

	Super.untouch(Other);

    if (Other.IsA('R6Pawn'))
        C = Pawn(Other).Controller;
    else if (Other.IsA('R6PlayerController'))
        C = Controller(Other);

    if (C != none)
	{		
		C.m_CurrentAmbianceObject = self;
		C.m_CurrentVolumeSound = self;
		C.m_bUseExitSounds = TRUE;
    
        if ((PlayerController(C) != None)  && (Viewport(PlayerController(C).Player) != None))
		{
			for (iSoundIndex = 0; iSoundIndex < m_ExitSound.Length; iSoundIndex++)
			{
				PlaySound(m_ExitSound[iSoundIndex], m_eSoundSlot);
			}
		}
	}
}

defaultproperties
{
     m_eSoundSlot=SLOT_Ambient
     m_b3DSound=False
     m_bSeeThrough=True
}
