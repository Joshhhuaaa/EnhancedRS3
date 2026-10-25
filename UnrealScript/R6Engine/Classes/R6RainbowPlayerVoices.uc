class R6RainbowPlayerVoices extends R6Voices;

var Sound m_sndTeamRegroup;
var Sound m_sndTeamMove;
var Sound m_sndTeamHold;
var Sound m_sndAllTeamsHold;
var Sound m_sndAllTeamsMove;
var Sound m_sndTeamMoveAndFrag;
var Sound m_sndTeamMoveAndGas;
var Sound m_sndTeamMoveAndSmoke;
var Sound m_sndTeamMoveAndFlash;
var Sound m_sndTeamOpenDoor;
var Sound m_sndTeamCloseDoor;
var Sound m_sndTeamOpenShudder;
var Sound m_sndTeamCloseShudder;
var Sound m_sndTeamOpenAndClear;
var Sound m_sndTeamOpenAndFrag;
var Sound m_sndTeamOpenAndGas;
var Sound m_sndTeamOpenAndSmoke;
var Sound m_sndTeamOpenAndFlash;
var Sound m_sndTeamOpenFragAndClear;
var Sound m_sndTeamOpenGasAndClear;
var Sound m_sndTeamOpenSmokeAndClear;
var Sound m_sndTeamOpenFlashAndClear;
var Sound m_sndTeamFragAndClear;
var Sound m_sndTeamGasAndClear;
var Sound m_sndTeamSmokeAndClear;
var Sound m_sndTeamFlashAndClear;
var Sound m_sndTeamUseLadder;
var Sound m_sndTeamSecureTerrorist;
var Sound m_sndTeamGoGetHostage;
var Sound m_sndTeamHostageStayPut;
var Sound m_sndTeamStatusReport;
var Sound m_sndTeamUseElectronic;
var Sound m_sndTeamUseDemolition;
var Sound m_sndAlphaGoCode;
var Sound m_sndBravoGoCode;
var Sound m_sndCharlieGoCode;
var Sound m_sndZuluGoCode;
var Sound m_sndOrderTeamWithGoCode;
var Sound m_sndHostageFollow;
var Sound m_sndHostageStay;
var Sound m_sndHostageSafe;
var Sound m_sndHostageSecured;
var Sound m_sndMemberDown;
var Sound m_sndSniperFree;
var Sound m_sndSniperHold;



function Init(Actor aActor)
{
    Super.Init(aActor);

    AActor.AddSoundBankName("Voices_1rstPersonRainbow");
}

function PlayRainbowPlayerVoices(R6Pawn aPawn, Pawn.ERainbowPlayerVoices eRainbowVoices)
{
    switch(eRainbowVoices)
    {
        case RPV_TeamRegroup:
            aPawn.PlayVoices(m_sndTeamRegroup, SLOT_HeadSet, 10);
                break;
        case RPV_TeamMove:
            aPawn.PlayVoices(m_sndTeamMove, SLOT_HeadSet, 10);
            break;
        case RPV_TeamHold:
            aPawn.PlayVoices(m_sndTeamHold, SLOT_HeadSet, 10);
            break;
        case RPV_AllTeamsHold:
            aPawn.PlayVoices(m_sndAllTeamsHold, SLOT_HeadSet, 10);
            break;
        case RPV_AllTeamsMove:
            aPawn.PlayVoices(m_sndAllTeamsMove, SLOT_HeadSet, 10);
            break;
        case RPV_TeamMoveAndFrag:
            aPawn.PlayVoices(m_sndTeamMoveAndFrag, SLOT_HeadSet, 10);
            break;
        case RPV_TeamMoveAndGas:
            aPawn.PlayVoices(m_sndTeamMoveAndGas, SLOT_HeadSet, 10);
            break;
        case RPV_TeamMoveAndSmoke:
            aPawn.PlayVoices(m_sndTeamMoveAndSmoke, SLOT_HeadSet, 10);
            break;
        case RPV_TeamMoveAndFlash:
            aPawn.PlayVoices(m_sndTeamMoveAndFlash, SLOT_HeadSet, 10);
            break;
        case RPV_TeamOpenDoor:
            aPawn.PlayVoices(m_sndTeamOpenDoor, SLOT_HeadSet, 10);
            break;
        case RPV_TeamCloseDoor:
            aPawn.PlayVoices(m_sndTeamCloseDoor, SLOT_HeadSet, 10);
            break;
		case RPV_TeamOpenShudder:
			aPawn.PlayVoices(m_sndTeamOpenShudder, SLOT_HeadSet, 10);
			break;
		case RPV_TeamCloseShudder:
			aPawn.PlayVoices(m_sndTeamCloseShudder, SLOT_HeadSet, 10);
			break;
        case RPV_TeamOpenAndClear:
            aPawn.PlayVoices(m_sndTeamOpenAndClear, SLOT_HeadSet, 10);
            break;
        case RPV_TeamOpenAndFrag:
            aPawn.PlayVoices(m_sndTeamOpenAndFrag, SLOT_HeadSet, 10);
            break;
        case RPV_TeamOpenAndGas:
            aPawn.PlayVoices(m_sndTeamOpenAndGas, SLOT_HeadSet, 10);
            break;
        case RPV_TeamOpenAndSmoke:
            aPawn.PlayVoices(m_sndTeamOpenAndSmoke, SLOT_HeadSet, 10);
            break;
        case RPV_TeamOpenAndFlash:
            aPawn.PlayVoices(m_sndTeamOpenAndFlash, SLOT_HeadSet, 10);
            break;
        case RPV_TeamOpenFragAndClear:
            aPawn.PlayVoices(m_sndTeamOpenFragAndClear, SLOT_HeadSet, 10);
            break;
        case RPV_TeamOpenGasAndClear:
            aPawn.PlayVoices(m_sndTeamOpenGasAndClear, SLOT_HeadSet, 10);
            break;
        case RPV_TeamOpenSmokeAndClear:
            aPawn.PlayVoices(m_sndTeamOpenSmokeAndClear, SLOT_HeadSet, 10);
            break;
        case RPV_TeamOpenFlashAndClear:
            aPawn.PlayVoices(m_sndTeamOpenFlashAndClear, SLOT_HeadSet, 10);
            break;
        case RPV_TeamFragAndClear:
            aPawn.PlayVoices(m_sndTeamFragAndClear, SLOT_HeadSet, 10);
            break;
        case RPV_TeamGasAndClear:
            aPawn.PlayVoices(m_sndTeamGasAndClear, SLOT_HeadSet, 10);
            break;
        case RPV_TeamSmokeAndClear:
            aPawn.PlayVoices(m_sndTeamSmokeAndClear, SLOT_HeadSet, 10);
            break;
        case RPV_TeamFlashAndClear:
            aPawn.PlayVoices(m_sndTeamFlashAndClear, SLOT_HeadSet, 10);
            break;
        case RPV_TeamUseLadder:
            aPawn.PlayVoices(m_sndTeamUseLadder, SLOT_HeadSet, 10);
            break;
        case RPV_TeamSecureTerrorist:
            aPawn.PlayVoices(m_sndTeamSecureTerrorist, SLOT_HeadSet, 10);
            break;
        case RPV_TeamGoGetHostage:
            aPawn.PlayVoices(m_sndTeamGoGetHostage, SLOT_HeadSet, 10);
            break;
        case RPV_TeamHostageStayPut:    
            aPawn.PlayVoices(m_sndTeamHostageStayPut, SLOT_HeadSet, 10);
            break;
        case RPV_TeamStatusReport:
            aPawn.PlayVoices(m_sndTeamStatusReport, SLOT_HeadSet, 10);
            break;
        case RPV_TeamUseDemolition:
            aPawn.PlayVoices(m_sndTeamUseDemolition, SLOT_HeadSet, 10);
            break;
        case RPV_TeamUseElectronic:
            aPawn.PlayVoices(m_sndTeamUseElectronic, SLOT_HeadSet, 10);
            break;
        case RPV_AlphaGoCode:
            aPawn.PlayVoices(m_sndAlphaGoCode, SLOT_HeadSet, 10);
            break;
        case RPV_BravoGoCode:
            aPawn.PlayVoices(m_sndBravoGoCode, SLOT_HeadSet, 10);
            break;
        case RPV_CharlieGoCode:
            aPawn.PlayVoices(m_sndCharlieGoCode, SLOT_HeadSet, 10);
            break;
        case RPV_ZuluGoCode:
            aPawn.PlayVoices(m_sndZuluGoCode, SLOT_HeadSet, 10);
            break;
        case RPV_OrderTeamWithGoCode:
            aPawn.PlayVoices(m_sndOrderTeamWithGoCode, SLOT_HeadSet, 15, SSTATUS_SendToPlayer, true);
            break;
        case RPV_HostageFollow:
            aPawn.PlayVoices(m_sndHostageFollow, SLOT_HeadSet, 10);
            break;
        case RPV_HostageStay:
            aPawn.PlayVoices(m_sndHostageStay, SLOT_HeadSet, 10);
            break;
        case RPV_HostageSafe:
            aPawn.PlayVoices(m_sndHostageSafe, SLOT_HeadSet, 10);
            break;
        case RPV_HostageSecured:
            aPawn.PlayVoices(m_sndHostageSecured, SLOT_HeadSet, 10);
            break;
        case RPV_MemberDown:
            aPawn.PlayVoices(m_sndMemberDown, SLOT_HeadSet, 10);
            break;
        case RPV_SniperFree:
            aPawn.PlayVoices(m_sndSniperFree, SLOT_HeadSet, 10);
            break;
        case RPV_SniperHold:
            aPawn.PlayVoices(m_sndSniperHold, SLOT_HeadSet, 10);
            break;
    }
}

defaultproperties
{
     m_sndTeamRegroup=Sound'Voices_1rstPersonRainbow.Play_Team_Regroup_Order'
     m_sndTeamMove=Sound'Voices_1rstPersonRainbow.Play_Team_Move_Order'
     m_sndTeamHold=Sound'Voices_1rstPersonRainbow.Play_Team_Hold_Up'
     m_sndAllTeamsHold=Sound'Voices_1rstPersonRainbow.Play_All_Team_Hold_Up'
     m_sndAllTeamsMove=Sound'Voices_1rstPersonRainbow.Play_All_Team_Move_Out'
     m_sndTeamMoveAndFrag=Sound'Voices_1rstPersonRainbow.Play_Move_Frag'
     m_sndTeamMoveAndGas=Sound'Voices_1rstPersonRainbow.Play_Move_Gas'
     m_sndTeamMoveAndSmoke=Sound'Voices_1rstPersonRainbow.Play_Move_Smoke'
     m_sndTeamMoveAndFlash=Sound'Voices_1rstPersonRainbow.Play_Move_Flash'
     m_sndTeamOpenDoor=Sound'Voices_1rstPersonRainbow.Play_Open_Door'
     m_sndTeamCloseDoor=Sound'Voices_1rstPersonRainbow.Play_Close_Door'
     m_sndTeamOpenShudder=Sound'Voices_1rstPersonRainbow.Play_Open_Window'
     m_sndTeamCloseShudder=Sound'Voices_1rstPersonRainbow.Play_Close_Window'
     m_sndTeamOpenAndClear=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Clear'
     m_sndTeamOpenAndFrag=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Frag'
     m_sndTeamOpenAndGas=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Gas'
     m_sndTeamOpenAndSmoke=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Smoke'
     m_sndTeamOpenAndFlash=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Flash'
     m_sndTeamOpenFragAndClear=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Frag_Clear'
     m_sndTeamOpenGasAndClear=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Gas_Clear'
     m_sndTeamOpenSmokeAndClear=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Smoke_Clear'
     m_sndTeamOpenFlashAndClear=Sound'Voices_1rstPersonRainbow.Play_Open_Door_Flash_Clear'
     m_sndTeamFragAndClear=Sound'Voices_1rstPersonRainbow.Play_Team_Frag_Clear'
     m_sndTeamGasAndClear=Sound'Voices_1rstPersonRainbow.Play_Team_Gas_Clear'
     m_sndTeamSmokeAndClear=Sound'Voices_1rstPersonRainbow.Play_Team_Smoke_Clear'
     m_sndTeamFlashAndClear=Sound'Voices_1rstPersonRainbow.Play_Team_Flash_Clear'
     m_sndTeamUseLadder=Sound'Voices_1rstPersonRainbow.Play_Team_Ladder'
     m_sndTeamSecureTerrorist=Sound'Voices_1rstPersonRainbow.Play_Team_Secure_Terro'
     m_sndTeamGoGetHostage=Sound'Voices_1rstPersonRainbow.Play_Team_Get_Hostage'
     m_sndTeamHostageStayPut=Sound'Voices_1rstPersonRainbow.Play_Team_Hostage_Order'
     m_sndTeamStatusReport=Sound'Voices_1rstPersonRainbow.Play_Call_Team_Status'
     m_sndTeamUseElectronic=Sound'Voices_1rstPersonRainbow.Play_Use_Electronic'
     m_sndTeamUseDemolition=Sound'Voices_1rstPersonRainbow.Play_Use_Demolition'
     m_sndAlphaGoCode=Sound'Voices_1rstPersonRainbow.Play_Give_AlphaGo'
     m_sndBravoGoCode=Sound'Voices_1rstPersonRainbow.Play_Give_BravoGo'
     m_sndCharlieGoCode=Sound'Voices_1rstPersonRainbow.Play_Give_CharlieGo'
     m_sndZuluGoCode=Sound'Voices_1rstPersonRainbow.Play_Give_ZuluGo'
     m_sndOrderTeamWithGoCode=Sound'Voices_1rstPersonRainbow.Play_Give_Order_TeamGo'
     m_sndHostageFollow=Sound'Voices_1rstPersonRainbow.Play_Hostage_Follow'
     m_sndHostageStay=Sound'Voices_1rstPersonRainbow.Play_Hostage_Stay'
     m_sndHostageSafe=Sound'Voices_1rstPersonRainbow.Play_Player_HostageSafe'
     m_sndHostageSecured=Sound'Voices_1rstPersonRainbow.Play_Player_HostageSecured'
     m_sndMemberDown=Sound'Voices_1rstPersonRainbow.Play_RainbowDown'
     m_sndSniperFree=Sound'Voices_1rstPersonRainbow.Play_Player_Sniper_Shoot'
     m_sndSniperHold=Sound'Voices_1rstPersonRainbow.Play_Player_Sniper_NotShoot'
}
