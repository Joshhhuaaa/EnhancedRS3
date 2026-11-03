class MP2CommonRainbowMemberVoices extends R6CommonRainbowMemberVoices;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Sounds\Voices_1rstMP2PersonRainbow.uax PACKAGE=Voices_1rstMP2PersonRainbow

var Sound m_sndCoughOxygene;
var Sound m_sndSuffocation;

function Init(Actor aActor)
{
    super.Init(aActor);
    aActor.AddSoundBankName("Voices_1rstMP2PersonRainbow");
}

function PlayCommonRainbowVoices(R6Pawn aPawn, Pawn.ECommonRainbowVoices eRainbowVoices)
{
    switch(eRainbowVoices)
    {
        case CRV_TerroristDown:
            aPawn.PlayVoices(m_sndTerroristDown, SLOT_HeadSet, 10, SSTATUS_SendToMPTeam);
            break;
        case CRV_TakeWound:
            aPawn.PlayVoices(m_sndTakeWound, SLOT_Talk, 5, SSTATUS_SendToAll);
            break;
        case CRV_GoesDown:
            aPawn.PlayVoices(m_sndGoesDown, SLOT_Talk, 5, SSTATUS_SendToAll);
            break;
        case CRV_EntersSmoke:
            break;
        case CRV_EntersGas:
            aPawn.PlayVoices(m_sndEntersGas, SLOT_Talk, 5, SSTATUS_SendToAll);
            break;
        case CRV_Cough:
            aPawn.PlayVoices(m_sndCoughOxygene, SLOT_Talk, 5, SSTATUS_SendToAll);
            break;
        case CRV_Suffocation:
            aPawn.PlayVoices(m_sndSuffocation, SLOT_Talk, 5, SSTATUS_SendToAll);
            break;
    }
}

defaultproperties
{
    m_sndCoughOxygene=Sound'Voices_1rstMP2PersonRainbow.Play_Cough'
    m_sndSuffocation=Sound'Voices_1rstMP2PersonRainbow.Play_Player_Suffocated'
}
