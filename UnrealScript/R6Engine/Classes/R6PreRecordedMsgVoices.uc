class R6PreRecordedMsgVoices extends R6Voices;


var Array<Sound> m_sndPreRecordedMsg;


function Init(Actor aActor)
{
    Super.Init(aActor);
	aActor.AddSoundBankName("Voices_PreRecorded");
}


function PlayRecordedMsgVoices(R6Pawn aPawn,Pawn.EPreRecordedMsgVoices eRainbowVoices)
{
   aPawn.PlayVoices(m_sndPreRecordedMsg[eRainbowVoices], SLOT_HeadSet, 10, SSTATUS_SendToMPTeam);
}

defaultproperties
{
     m_sndPreRecordedMsg(0)=Sound'Voices_PreRecorded.1_1'
     m_sndPreRecordedMsg(1)=Sound'Voices_PreRecorded.1_2'
     m_sndPreRecordedMsg(2)=Sound'Voices_PreRecorded.1_3'
     m_sndPreRecordedMsg(3)=Sound'Voices_PreRecorded.1_4'
     m_sndPreRecordedMsg(4)=Sound'Voices_PreRecorded.1_5'
     m_sndPreRecordedMsg(5)=Sound'Voices_PreRecorded.1_6'
     m_sndPreRecordedMsg(6)=Sound'Voices_PreRecorded.1_7'
     m_sndPreRecordedMsg(7)=Sound'Voices_PreRecorded.1_8'
     m_sndPreRecordedMsg(8)=Sound'Voices_PreRecorded.1_9'
     m_sndPreRecordedMsg(9)=Sound'Voices_PreRecorded.2_1'
     m_sndPreRecordedMsg(10)=Sound'Voices_PreRecorded.2_2'
     m_sndPreRecordedMsg(11)=Sound'Voices_PreRecorded.2_3'
     m_sndPreRecordedMsg(12)=Sound'Voices_PreRecorded.2_4'
     m_sndPreRecordedMsg(13)=Sound'Voices_PreRecorded.2_5'
     m_sndPreRecordedMsg(14)=Sound'Voices_PreRecorded.2_6'
     m_sndPreRecordedMsg(15)=Sound'Voices_PreRecorded.2_7'
     m_sndPreRecordedMsg(16)=Sound'Voices_PreRecorded.2_8'
     m_sndPreRecordedMsg(17)=Sound'Voices_PreRecorded.2_9'
     m_sndPreRecordedMsg(18)=Sound'Voices_PreRecorded.3_1'
     m_sndPreRecordedMsg(19)=Sound'Voices_PreRecorded.3_2'
     m_sndPreRecordedMsg(20)=Sound'Voices_PreRecorded.3_3'
     m_sndPreRecordedMsg(21)=Sound'Voices_PreRecorded.3_4'
     m_sndPreRecordedMsg(22)=Sound'Voices_PreRecorded.3_6'
     m_sndPreRecordedMsg(23)=Sound'Voices_PreRecorded.3_7'
     m_sndPreRecordedMsg(24)=Sound'Voices_PreRecorded.3_5'
     m_sndPreRecordedMsg(25)=Sound'Voices_PreRecorded.3_8'
     m_sndPreRecordedMsg(26)=Sound'Voices_PreRecorded.3_9'
}
