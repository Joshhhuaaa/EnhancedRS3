class R6TerroristVoices extends R6Voices;

var Sound m_sndWounded;
var Sound m_sndTaunt;
var Sound m_sndSurrender;
var Sound m_sndSeesTearGas;
var Sound m_sndRunAway;
var Sound m_sndGrenade;
var Sound m_sndCoughsSmoke;
var Sound m_sndCoughsGas;
var Sound m_sndBackup;

var Sound m_sndSeesSurrenderedHostage;
var Sound m_sndSeesRainbow_LowAlert;
var Sound m_sndSeesRainbow_HighAlert;
var Sound m_sndSeesFreeHostage;
var Sound m_sndHearsNoize;

function PlayTerroristVoices(R6Pawn aPawn, Pawn.ETerroristVoices eTerroSound)
{
    if (aPawn != none)
    {
        switch(eTerroSound)
        {
            case TV_Wounded:
                aPawn.PlayVoices(m_sndWounded, SLOT_Talk, 5, SSTATUS_SendToAll);
                break;
            case TV_Taunt  :// Taunt not used - gborgia
                aPawn.PlayVoices(m_sndTaunt, SLOT_Talk, 10);
                break;
            case TV_Surrender:
                aPawn.PlayVoices(m_sndSurrender, SLOT_Talk, 10);
                break;
            case TV_SeesTearGas:
                aPawn.PlayVoices(m_sndSeesTearGas, SLOT_Talk, 10);
                break;
            case TV_RunAway:
                aPawn.PlayVoices(m_sndRunAway, SLOT_Talk, 10);
                break;
            case TV_Grenade:
                aPawn.PlayVoices(m_sndGrenade, SLOT_Talk, 10);
                break;
            case TV_CoughsSmoke:
//                aPawn.PlayVoices(m_sndCoughsSmoke, SLOT_Talk, 10, SSTATUS_SendToAll);
                break;
            case TV_CoughsGas:
                aPawn.PlayVoices(m_sndCoughsGas, SLOT_Talk, 10, SSTATUS_SendToAll);
                break;
            case TV_Backup:
                aPawn.PlayVoices(m_sndBackup, SLOT_Talk, 10);
                break;
            case TV_SeesSurrenderedHostage:
                aPawn.PlayVoices(m_sndSeesSurrenderedHostage, SLOT_Talk, 10);
                break;
            case TV_SeesRainbow_LowAlert:
                aPawn.PlayVoices(m_sndSeesRainbow_LowAlert, SLOT_Talk, 10);
                break;
            case TV_SeesRainbow_HighAlert:
                aPawn.PlayVoices(m_sndSeesRainbow_HighAlert, SLOT_Talk, 10);
                break;
            case TV_SeesFreeHostage:
                aPawn.PlayVoices(m_sndSeesFreeHostage, SLOT_Talk, 10);
                break;
            case TV_HearsNoize:
                aPawn.PlayVoices(m_sndHearsNoize, SLOT_Talk, 10);
                break;
        }
    }
}

defaultproperties
{
}
