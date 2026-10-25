class R6MultiCommonVoices extends R6Voices;

var Sound m_sndFragThrow;
var Sound m_sndFlashThrow;
var Sound m_sndGasThrow;
var Sound m_sndSmokeThrow;
var Sound m_sndActivatingBomb;
var Sound m_sndBombActivated;
var Sound m_sndDeactivatingBomb;
var Sound m_sndBombDeactivated;

function Init(Actor aActor)
{
    Super.Init(aActor);
	aActor.AddSoundBankName("Voices_Multi_Common");
}

function PlayMultiCommonVoices(R6Pawn aPawn, Pawn.EMultiCommonVoices eVoices)
{
    switch(eVoices)
    {
        case MCV_FragThrow:
            aPawn.PlayVoices(m_sndFragThrow, SLOT_HeadSet, 10, SSTATUS_SendToMPTeam);
            break;
        case MCV_FlashThrow:
            aPawn.PlayVoices(m_sndFlashThrow, SLOT_HeadSet, 10, SSTATUS_SendToMPTeam);
            break;
        case MCV_GasThrow:
            aPawn.PlayVoices(m_sndGasThrow, SLOT_HeadSet, 10, SSTATUS_SendToMPTeam);
            break;
        case MCV_SmokeThrow:
            aPawn.PlayVoices(m_sndSmokeThrow, SLOT_HeadSet, 10, SSTATUS_SendToMPTeam);
            break;
        case MCV_ActivatingBomb:
            aPawn.PlayVoices(m_sndActivatingBomb, SLOT_HeadSet, 10, SSTATUS_SendToMPTeam);
            break;
        case MCV_BombActivated:
            aPawn.PlayVoices(m_sndBombActivated, SLOT_HeadSet, 10, SSTATUS_SendToMPTeam);
            break;
        case MCV_DeactivatingBomb:
            aPawn.PlayVoices(m_sndDeactivatingBomb, SLOT_HeadSet, 10, SSTATUS_SendToMPTeam);
            break;
        case MCV_BombDeactivated:
            aPawn.PlayVoices(m_sndBombDeactivated, SLOT_HeadSet, 10, SSTATUS_SendToMPTeam);
            break;
    }
}

defaultproperties
{
     m_sndFragThrow=Sound'Voices_Multi_Common.Play_Common_FragThrow'
     m_sndFlashThrow=Sound'Voices_Multi_Common.Play_Common_FlashThrow'
     m_sndGasThrow=Sound'Voices_Multi_Common.Play_Common_GasThrow'
     m_sndSmokeThrow=Sound'Voices_Multi_Common.Play_Common_SmokeThrow'
     m_sndActivatingBomb=Sound'Voices_Multi_Common.Play_Common_ActivatingBomb'
     m_sndBombActivated=Sound'Voices_Multi_Common.Play_Common_BombActivated'
     m_sndDeactivatingBomb=Sound'Voices_Multi_Common.Play_Common_DeactivatingBomb'
     m_sndBombDeactivated=Sound'Voices_Multi_Common.Play_Common_BombDeactivated'
}
