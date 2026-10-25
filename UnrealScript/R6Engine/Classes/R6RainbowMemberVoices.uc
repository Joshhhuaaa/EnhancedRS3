class R6RainbowMemberVoices extends R6Voices;

var Sound m_sndContact;
var Sound m_sndContactRear;
var Sound m_sndContactAndEngages;
var Sound m_sndContactRearAndEngages;
var Sound m_sndTeamRegroupOnLead;
var Sound m_sndTeamReformOnLead;
var Sound m_sndTeamReceiveOrder;
var Sound m_sndTeamOrderFromLeadNil;
var Sound m_sndNoMoreFrag;
var Sound m_sndNoMoreSmoke;
var Sound m_sndNoMoreGas;
var Sound m_sndNoMoreFlash;
var Sound m_sndOnLadder;
var Sound m_sndMemberDown;
var Sound m_sndAmmoOut;
var Sound m_sndFragNear;
var Sound m_sndEntersGasCloud;
var Sound m_sndTakingFire;
var Sound m_sndTeamHoldUp;
var Sound m_sndTeamMoveOut;
var Sound m_sndHostageFollow;
var Sound m_sndHostageStay;
var Sound m_sndHostageSafe;
var Sound m_sndHostageSecured;
var Sound m_sndRainbowHitRainbow;
var Sound m_sndRainbowHitHostage;
var Sound m_sndDoorReform;


function Init(Actor aActor)
{
    Super.Init(aActor);
	aActor.AddSoundBankName("Voices_3rdPersonRainbow");
}

function PlayRainbowMemberVoices(R6Pawn aPawn, Pawn.ERainbowMembersVoices eRainbowVoices)
{

    switch(eRainbowVoices)
    {
        case RMV_Contact:
            aPawn.PlayVoices(m_sndContact, SLOT_HeadSet, 15);
            break;
        case RMV_ContactRear:
            aPawn.PlayVoices(m_sndContactRear, SLOT_HeadSet, 15);
            break;
        case RMV_ContactAndEngages:
            aPawn.PlayVoices(m_sndContactAndEngages, SLOT_HeadSet, 15);
            break;
        case RMV_ContactRearAndEngages:
            aPawn.PlayVoices(m_sndContactRearAndEngages, SLOT_HeadSet, 15);
            break;
        case RMV_TeamRegroupOnLead:
            aPawn.PlayVoices(m_sndTeamRegroupOnLead, SLOT_HeadSet, 15);
            break;
        case RMV_TeamReformOnLead:
            aPawn.PlayVoices(m_sndTeamReformOnLead, SLOT_HeadSet, 15);
            break;
        case RMV_TeamReceiveOrder:
            aPawn.PlayVoices(m_sndTeamReceiveOrder, SLOT_HeadSet, 15);
            break;
        case RMV_TeamOrderFromLeadNil:
            aPawn.PlayVoices(m_sndTeamOrderFromLeadNil, SLOT_HeadSet, 15);
            break;
        case RMV_NoMoreFrag:
            aPawn.PlayVoices(m_sndNoMoreFrag, SLOT_HeadSet, 15);
            break;
        case RMV_NoMoreSmoke:
            aPawn.PlayVoices(m_sndNoMoreSmoke, SLOT_HeadSet, 15);
            break;
        case RMV_NoMoreGas:
            aPawn.PlayVoices(m_sndNoMoreGas, SLOT_HeadSet, 15);
            break;
        case RMV_NoMoreFlash:
            aPawn.PlayVoices(m_sndNoMoreFlash, SLOT_HeadSet, 15);
            break;
        case RMV_OnLadder:
            aPawn.PlayVoices(m_sndOnLadder, SLOT_HeadSet, 15);
            break;
        case RMV_MemberDown:
            aPawn.PlayVoices(m_sndMemberDown, SLOT_HeadSet, 10, SSTATUS_SendToAll);
            break;
        case RMV_AmmoOut:
            aPawn.PlayVoices(m_sndAmmoOut, SLOT_HeadSet, 15);
            break;
        case RMV_FragNear:
            aPawn.PlayVoices(m_sndFragNear, SLOT_HeadSet, 15);
            break;
        case RMV_EntersGasCloud:
            aPawn.PlayVoices(m_sndEntersGasCloud, SLOT_HeadSet, 5, SSTATUS_SendToPlayer, true);
            break;
        case RMV_TakingFire:
            aPawn.PlayVoices(m_sndTakingFire, SLOT_HeadSet, 15);
            break;
        case RMV_TeamHoldUp:
            aPawn.PlayVoices(m_sndTeamHoldUp, SLOT_HeadSet, 15);
            break;
        case RMV_TeamMoveOut:
            aPawn.PlayVoices(m_sndTeamMoveOut, SLOT_HeadSet, 15);
            break;
        case RMV_HostageFollow:
            aPawn.PlayVoices(m_sndHostageFollow, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RMV_HostageSafe:
            aPawn.PlayVoices(m_sndHostageSafe, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RMV_HostageStay:
            aPawn.PlayVoices(m_sndHostageStay, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RMV_HostageSecured:
            aPawn.PlayVoices(m_sndHostageSecured, SLOT_HeadSet, 15);
            break;
        case RMV_RainbowHitRainbow:
            aPawn.PlayVoices(m_sndRainbowHitRainbow, SLOT_HeadSet, 15);
            break;
        case RMV_RainbowHitHostage:
            aPawn.PlayVoices(m_sndRainbowHitHostage, SLOT_HeadSet, 15);
            break;
        case RMV_DoorReform:
            aPawn.PlayVoices(m_sndDoorReform, SLOT_HeadSet, 15);
            break;
    }
}

defaultproperties
{
     m_sndContact=Sound'Voices_3rdPersonRainbow.Play_Terro_EntersView'
     m_sndContactRear=Sound'Voices_3rdPersonRainbow.Play_Terro_EntersViewRear'
     m_sndContactAndEngages=Sound'Voices_3rdPersonRainbow.Play_TerroView_Engage'
     m_sndContactRearAndEngages=Sound'Voices_3rdPersonRainbow.Play_TerroViewRear_Engage'
     m_sndTeamRegroupOnLead=Sound'Voices_3rdPersonRainbow.Play_LeadRegroup'
     m_sndTeamReformOnLead=Sound'Voices_3rdPersonRainbow.Play_TeamRegroup_OnLead'
     m_sndTeamReceiveOrder=Sound'Voices_3rdPersonRainbow.Play_Order_FromLead'
     m_sndTeamOrderFromLeadNil=Sound'Voices_3rdPersonRainbow.Play_Order_FromLead_Nil'
     m_sndOnLadder=Sound'Voices_3rdPersonRainbow.Play_Receive_Order_Ladder'
     m_sndMemberDown=Sound'Voices_3rdPersonRainbow.Play_MemberDown'
     m_sndAmmoOut=Sound'Voices_3rdPersonRainbow.Play_Ammo_Out'
     m_sndEntersGasCloud=Sound'Voices_3rdPersonRainbow.Play_GasCloud_In'
     m_sndTakingFire=Sound'Voices_3rdPersonRainbow.Play_TakingFire'
     m_sndTeamHoldUp=Sound'Voices_3rdPersonRainbow.Play_Team_HoldUp'
     m_sndTeamMoveOut=Sound'Voices_3rdPersonRainbow.Play_Team_MoveOut'
     m_sndHostageFollow=Sound'Voices_3rdPersonRainbow.Play_Tell_Hostage_Follow'
     m_sndHostageStay=Sound'Voices_3rdPersonRainbow.Play_Tell_Hostage_Stay'
     m_sndHostageSafe=Sound'Voices_3rdPersonRainbow.Play_Team_HostageSafe'
     m_sndHostageSecured=Sound'Voices_3rdPersonRainbow.Play_Team_HostageSecured'
     m_sndRainbowHitRainbow=Sound'Voices_3rdPersonRainbow.Play_Rainbow_HitRainbow'
     m_sndRainbowHitHostage=Sound'Voices_3rdPersonRainbow.Play_Rainbow_HitCivil'
     m_sndDoorReform=Sound'Voices_3rdPersonRainbow.Play_Rainbow_DoorReform'
}
