//=============================================================================
//  R6WindowButtonOptions.uc : This is button for options menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/11 * Created by Yannick Joly
//=============================================================================
class R6WindowButtonOptions extends R6WindowButton;

var Texture                 m_TOverButton;

var Region                  m_ROverButtonFade;   
var Region                  m_ROverButton;

var enum eButtonActionType
{    
	Button_Game,
    Button_Sound,
    Button_Graphic,
    Button_Hud,
    Button_Multiplayer,
    Button_Controls,
// MPF - Yannick
    Button_MODS,
	Button_PatchService,
    Button_Return
} m_eButton_Action;

simulated function Click(float X, float Y) 
{
	local R6MenuRootWindow r6Root;

	if (bDisabled)
		return;

	Super.Click(X,Y);
	r6Root = R6MenuRootWindow(Root);


	switch(m_eButton_Action)
	{	
	    case Button_Game :
            // change window options to 
            R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection( R6MenuOptionsWidget(OwnerWindow).eOptionsWindow.OW_Game);
   		    break;
	    case Button_Sound:
            // change window options to 
            R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection( R6MenuOptionsWidget(OwnerWindow).eOptionsWindow.OW_Sound);
   		    break;
        case Button_Graphic :
            // change window options to 
            R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection( R6MenuOptionsWidget(OwnerWindow).eOptionsWindow.OW_Graphic);
            break;
        case Button_Hud :
            // change window options to 
            R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection( R6MenuOptionsWidget(OwnerWindow).eOptionsWindow.OW_Hud);
            break;
#ifndefSPDEMO
        case Button_Multiplayer:
            // change window options to 
            R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection( R6MenuOptionsWidget(OwnerWindow).eOptionsWindow.OW_Multiplayer);
            break;
#endif
        case Button_Controls:
            // change window options to 
            R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection( R6MenuOptionsWidget(OwnerWindow).eOptionsWindow.OW_Controls);
            break;
        // MPF - Yannick
        case Button_MODS:
            // change window options to 
            R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection( R6MenuOptionsWidget(OwnerWindow).eOptionsWindow.OW_MOD);
            break;
        case Button_PatchService:
            // change window options to 
            R6MenuOptionsWidget(OwnerWindow).ManageOptionsSelection( R6MenuOptionsWidget(OwnerWindow).eOptionsWindow.OW_PatchService);
            break;
        case Button_Return:
			R6MenuOptionsWidget(OwnerWindow).UpdateOptions();
            Root.ChangeCurrentWidget(PreviousWidgetID);
            break;
        default:
            log("Button not supported");
            break;
    }
}

defaultproperties
{
     m_TOverButton=Texture'R6MenuTextures.Gui_BoxScroll'
     m_ROverButtonFade=(X=248,W=6,H=13)
     m_ROverButton=(X=253,W=2,H=13)
     m_fFontSpacing=1.000000
     bStretched=True
}
