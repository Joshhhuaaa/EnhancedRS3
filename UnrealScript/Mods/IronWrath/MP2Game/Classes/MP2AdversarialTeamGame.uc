class MP2AdversarialTeamGame extends R6AdversarialTeamGame
    config;

event PostBeginPlay()
{
    super.PostBeginPlay();
    AddSoundBankName("Voices_Control_MP2GameModes");
}

function Object GetCommonRainbowPlayerVoicesMgr()
{
    if(m_CommonRainbowPlayerVoicesMgr == none)
    {
        m_CommonRainbowPlayerVoicesMgr = new Class'MP2SFX.MP2CommonRainbowMemberVoices';
        m_CommonRainbowPlayerVoicesMgr.Init(self);
    }
    return m_CommonRainbowPlayerVoicesMgr;
}
