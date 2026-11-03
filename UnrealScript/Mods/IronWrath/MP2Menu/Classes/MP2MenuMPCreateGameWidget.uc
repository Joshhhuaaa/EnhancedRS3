class MP2MenuMPCreateGameWidget extends R6MenuMPCreateGameWidget;

function KeyDown(int Key, float X, float Y)
{
    if(R6Console(Root.Console).m_bStartedByGSClient && Key == int(Root.Console.EInputKey.IK_Escape))
    {
        switch(Root.m_eCurWidgetInUse)
        {
            case Root.eGameWidgetID.WidgetID_None:
            case Root.eGameWidgetID.MPCreateGameWidgetID:
                Root.ChangeCurrentWidget(UbiComWidgetID);
                class'Actor'.static.GetGameManager().m_bReturnToGSClient = true;
                break;
            default:
                break;
        }
    }
    else
    {
        super(R6MenuWidget).KeyDown(Key, X, Y);
    }
}
