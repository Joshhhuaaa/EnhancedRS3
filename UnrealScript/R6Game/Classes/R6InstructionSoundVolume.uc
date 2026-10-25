//=============================================================================
//  R6SoundInstructionVolume.uc : Use for the player in the map training.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/06/20 * Created by Serge Dore
//============================================================================//
class R6InstructionSoundVolume extends R6SoundVolume
	native;

var (R6Sound) Sound m_sndIntructionSoundStop;
var (R6Sound) INT   m_iBoxNumber;
var INT     m_iSoundIndex;
var BOOL    m_bSoundIsPlaying;
var FLOAT   m_fTime;      // use for wait 1 sec to not call IsSoundPlaying at each trame

var FLOAT   m_fTimerSound;    // Currently time for the sound
var FLOAT   m_fTimeHud;       // Time get in the INT file.
var INT     m_iHudStep;       // Current Step hud for internal use only    
var INT     m_IDHudStep;      // ID for display many thing on the HUD.
var INT     m_fTimerStep;     // When no sound use the timer

var R6TrainingMgr m_TrainingMgr;
const TimeBetweenStep = 15;

native(2732) final function BOOL UseSound();


simulated function ResetOriginalData()
{
    m_bSoundIsPlaying = false;
    m_iSoundIndex = 0;
    m_fTime = 0;
    m_fTimerStep = 0;
}

simulated event Touch(Actor Other)
{
	local Controller C;
	
    if (Other.IsA('R6Pawn'))
    {
		Other.m_CurrentVolumeSound = self;
        C = Pawn(Other).Controller;
    }
    else if (Other.IsA('R6PlayerController'))
    {
        C = Controller(Other);
    }

    if (C != None)
    {
		C.m_CurrentAmbianceObject = self;
		C.m_CurrentVolumeSound = self;

		if(!m_bSoundIsPlaying && (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None))
		{
			m_iSoundIndex = 0;
            m_TrainingMgr = R6GameInfo(C.Level.Game).GetTrainingMgr(R6Pawn(C.Pawn));
			if (!R6Console(m_TrainingMgr.m_Player.Player.Console).m_bStartR6GameInProgress)
            {
                R6HUD(m_TrainingMgr.m_Player.myHUD).HudStep(m_iBoxNumber, 0);
                ChangeTextAndSound();
            }
        }
	}
}

simulated event UnTouch(Actor Other)
{
	local Controller C;

    if (Other.IsA('R6Pawn'))
    {
        C = Pawn(Other).Controller;
    }
    else if (Other.IsA('R6PlayerController'))
    {
        C = Controller(Other);
    }
    
    if (C != none)
    {
        C.m_CurrentAmbianceObject = self;
    }
}

function SkipToNextInstruction()
{
    PlaySound(m_sndIntructionSoundStop, SLOT_Instruction);

    for (m_iHudStep=0; m_iHudStep<4; m_iHudStep++)
    {
        SetHudStep();
        if (m_IDHudStep != 0)
            R6HUD(m_TrainingMgr.m_Player.myHUD).HudStep(m_iBoxNumber, m_IDHudStep, false);
    }
    
    m_iSoundIndex++;
    ChangeTextAndSound();
    

}

function StopInstruction()
{
    PlaySound(m_sndIntructionSoundStop, SLOT_Instruction);
    R6Console(m_TrainingMgr.m_Player.Player.Console).LaunchInstructionMenu(Self, false, 0, 0);

    m_iSoundIndex=m_EntrySound.Length;
    m_bSoundIsPlaying = false;
}

function ChangeTextAndSound()
{
    if( !m_TrainingMgr.CanChangeText( m_iBoxNumber ) )
        return;
    
    if (m_ExitSound.Length > m_iSoundIndex)
    {
        m_sndIntructionSoundStop = m_ExitSound[m_iSoundIndex];

        if (m_sndIntructionSoundStop != none)
        {
            m_bUseExitSounds = TRUE;
            PlaySound(m_sndIntructionSoundStop, SLOT_Instruction);
        }
    }

    if (m_EntrySound.Length > m_iSoundIndex)
    {
        m_bUseExitSounds = FALSE;
        m_bSoundIsPlaying = true;
        // Set the timer to zero before play a sound
        m_fTimerSound = 0;
        m_iHudStep = 0;
        SetHudStep();
        R6PlayerController(m_TrainingMgr.m_Player).m_bDisplayMessage = true;
        PlaySound(m_EntrySound[m_iSoundIndex], SLOT_Instruction);
        R6Console(m_TrainingMgr.m_Player.Player.Console).LaunchInstructionMenu(Self, true, m_iBoxNumber, m_iSoundIndex);
        m_TrainingMgr.LaunchAction(m_iBoxNumber, m_iSoundIndex);
    }
    else
    {
        R6PlayerController(m_TrainingMgr.m_Player).m_bDisplayMessage = false;
        R6Console(m_TrainingMgr.m_Player.Player.Console).LaunchInstructionMenu(Self, false, 0, 0);
    }
}

function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);   
    if (m_bSoundIsPlaying)
    {
        // Check if the timer
        if (m_fTimeHud > 0)
        {
            m_fTimerSound += DeltaTime;
            if (m_fTimerSound > m_fTimeHud)
            {
                R6HUD(m_TrainingMgr.m_Player.myHUD).HudStep(m_iBoxNumber, m_IDHudStep);
                m_iHudStep++;
                SetHudStep();
            }
        }

        // Ckeck for changing text and sound
        m_fTime += DeltaTime;
        if (m_fTime > 1.0f)
        {
            if (m_iSoundIndex < m_EntrySound.Length)
            {
                if (!UseSound() || m_EntrySound[m_iSoundIndex] == none)
                {
                    if (m_fTimerStep < TimeBetweenStep)
                    {
                        m_fTimerStep += 1;
                    }
                    else
                    {
                        m_fTimerStep=0;
                        ReadyToChangeText();
                    }
                }
                else if( !IsPlayingSound(Self, m_EntrySound[m_iSoundIndex]) )
                {
                    ReadyToChangeText();
                }
            }
            else
            {
                ReadyToChangeText();
            }

            m_fTime = m_fTime - 1.0f;
        }
    }
}

function ReadyToChangeText()
{
    m_bSoundIsPlaying = false;

    if (m_TrainingMgr.m_Player.m_CurrentVolumeSound == Self)
    {
        m_iSoundIndex++;
        ChangeTextAndSound();
    }
}

function SetHudStep()
{
    m_fTimeHud = 0;
    m_IDHudStep = 0;
    switch(m_iBoxNumber)
    {
        case 1:
            if ((m_iSoundIndex == 0) && (m_iHudStep == 0))
            {
                m_fTimeHud = FLOAT(Localize("BasicAreaBox1", "HUDStep0",  "R6Training"));
                m_IDHudStep = 1;
            }
            break;
        
        case 2:
            if ((m_iSoundIndex == 0) && (m_iHudStep == 0))
            {
                m_fTimeHud = FLOAT(Localize("BasicAreaBox2", "HUDStep0",  "R6Training"));
                m_IDHudStep = 2;
            }
            break;

        case 3:
            if ((m_iSoundIndex == 0) && (m_iHudStep == 0))
            {
                m_fTimeHud = FLOAT(Localize("BasicAreaBox3", "HUDStep0",  "R6Training"));
                m_IDHudStep = 3;
            }
            break;
        
        case 8:
            switch(m_iSoundIndex)
            {
                case 0:
                    switch(m_iHudStep)
                    {
                        case 0:
                            m_fTimeHud = FLOAT(Localize("ShootingAreaBox1", "HUDStep0",  "R6Training"));
                            m_IDHudStep = 4;
                            break;
                        case 1:
                            m_fTimeHud = FLOAT(Localize("ShootingAreaBox1", "HUDStep1",  "R6Training"));
                            m_IDHudStep = 5;
                            break;
                    }
                    break;
                case 1:
                    switch(m_iHudStep)
                    {
                        case 0:
                            m_fTimeHud = FLOAT(Localize("ShootingAreaBox1", "HUDStep2",  "R6Training"));
                            m_IDHudStep = 6;
                            break;
                        case 1:
                            m_fTimeHud = FLOAT(Localize("ShootingAreaBox1", "HUDStep3",  "R6Training"));
                            m_IDHudStep = 7;
                            break;
                        case 2:
                            m_fTimeHud = FLOAT(Localize("ShootingAreaBox1", "HUDStep4",  "R6Training"));
                            m_IDHudStep = 8;
                            break;
                    }
                    break;
            }
            break;
        
        case 21: // RoomClearing1Box1
            if (m_iSoundIndex == 0)
            {
                switch(m_iHudStep)
                {
                    case 0:
                        m_fTimeHud = FLOAT(Localize("RoomClearing1Box1", "HUDStep0",  "R6Training"));
                        m_IDHudStep = 9;
                        break;
                    case 1:
                        m_fTimeHud = FLOAT(Localize("RoomClearing1Box1", "HUDStep1",  "R6Training"));
                        m_IDHudStep = 10;
                        break;
                }
            }            
            break;
        
        case 22: // RoomClearing1Box
            switch(m_iSoundIndex)
            {
                case 0:
                    switch(m_iHudStep)
                    {
                        case 0:
                            m_fTimeHud = FLOAT(Localize("RoomClearing1Box2", "HUDStep0",  "R6Training"));
                            m_IDHudStep = 11;
                            break;
                    }
                    break;
                case 1:
                    switch(m_iHudStep)
                    {
                        case 0:
                            m_fTimeHud = FLOAT(Localize("RoomClearing1Box2", "HUDStep1",  "R6Training"));
                            m_IDHudStep = 12;
                            break;
                        case 1:
                            m_fTimeHud = FLOAT(Localize("RoomClearing1Box2", "HUDStep2",  "R6Training"));
                            m_IDHudStep = 13;
                            break;
                        case 2:
                            m_fTimeHud = FLOAT(Localize("RoomClearing1Box2", "HUDStep3",  "R6Training"));
                            m_IDHudStep = 14;
                            break;
                    }
                    break;
            }
            break;
        case 24: // RoomClearing2Box1
            if ((m_iSoundIndex == 0) && (m_iHudStep == 0))
            {
                m_fTimeHud = FLOAT(Localize("RoomClearing2Box1", "HUDStep0",  "R6Training"));
                m_IDHudStep = 15;
            }            

            break;

        default:
            break;
    }
}

defaultproperties
{
     m_eSoundSlot=SLOT_Instruction
     bStatic=False
     bNoDelete=False
}
