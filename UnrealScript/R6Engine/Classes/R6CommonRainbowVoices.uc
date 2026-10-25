class R6CommonRainbowVoices extends R6Voices;

var Sound m_sndTerroristDown;
var Sound m_sndTakeWound;
var Sound m_sndGoesDown;
var Sound m_sndEntersSmoke;
var Sound m_sndEntersGas;
var Sound m_sndCoughOxygene;
var Sound m_sndSuffocation;

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
//            aPawn.PlayVoices(m_sndEntersSmoke, SLOT_Talk, 5, SSTATUS_SendToAll);
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
}
