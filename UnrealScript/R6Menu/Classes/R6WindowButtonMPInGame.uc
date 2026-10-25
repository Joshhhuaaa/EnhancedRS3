class R6WindowButtonMPInGame extends R6WindowButton;

var Texture                 m_TOverButton;

var Region                  m_ROverButtonFade;   
var Region                  m_ROverButton;

//var R6WindowPopUpBox     m_pJoinIP;

var enum eButInGameActionType
{    
	Button_AlphaTeam,
    Button_BravoTeam,
    Button_AutoTeam,
    Button_Spectator,
    Button_Play
} m_eButInGame_Action;

simulated function Click(float X, float Y) 
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	Super.Click(X,Y);
	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);

	if (bDisabled)
		return;

	switch(m_eButInGame_Action)
	{	
        case Button_Play:           // deathmatch
	    case Button_AlphaTeam :     // team deathmatch
            //log("AlphaTeam select");
            r6Root.m_R6GameMenuCom.PlayerSelection(r6Root.m_R6GameMenuCom.ePlayerTeamSelection.PTS_Alpha);
//            r6Root.ChangeCurrentWidget(WidgetID_None); // temp
   		    break;
	    case Button_BravoTeam:
            // log("BravoTeam select");
            r6Root.m_R6GameMenuCom.PlayerSelection(r6Root.m_R6GameMenuCom.ePlayerTeamSelection.PTS_Bravo);
//            r6Root.ChangeCurrentWidget(WidgetID_None); // temp
   		    break;
        case Button_AutoTeam :
            // log("AutoTeam select");
            r6Root.m_R6GameMenuCom.PlayerSelection(r6Root.m_R6GameMenuCom.ePlayerTeamSelection.PTS_AutoSelect);
//            r6Root.ChangeCurrentWidget(WidgetID_None); // temp
            break;
        case Button_Spectator :
            r6Root.m_R6GameMenuCom.PlayerSelection(r6Root.m_R6GameMenuCom.ePlayerTeamSelection.PTS_Spectator);
            // log("Spectator select");
//            r6Root.ChangeCurrentWidget(WidgetID_None); // temp
            break;
        default:
            // log("Button not supported");
            break;
    }
}

defaultproperties
{
     m_TOverButton=Texture'R6MenuTextures.Gui_BoxScroll'
     m_ROverButtonFade=(X=248,W=6,H=13)
     m_ROverButton=(X=253,W=2,H=13)
     bStretched=True
}
