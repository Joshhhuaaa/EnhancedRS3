//=============================================================================
//  R6MenuWidget.uc : Base class for our game menus
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuWidget extends UWindowDialogClientWindow;

var float m_fLeftMouseXClipping;
var float m_fLeftMouseYClipping;
var float m_fRightMouseXClipping;
var float m_fRightMouseYClipping;

function Reset()
{
    //Implemented in child
}

//-----------------------------------------------------------//
//                      Mouse functions                      //
//-----------------------------------------------------------//

function SetMousePos(FLOAT X, FLOAT Y)
{
    Root.Console.MouseX = X;
    Root.Console.MouseY = Y;
}

function KeyDown(int Key, float X, float Y)
{
	if (Key == Root.Console.EInputKey.IK_Escape)
	{
		switch(Root.m_eCurWidgetInUse)
		{
			case Root.eGameWidgetID.SinglePlayerWidgetID:
			case Root.eGameWidgetID.CustomMissionWidgetID:
			case Root.eGameWidgetID.TrainingWidgetID:
			case Root.eGameWidgetID.MultiPlayerWidgetID:
				Root.ChangeCurrentWidget(MainMenuWidgetID);
				break;

			case Root.eGameWidgetID.MPCreateGameWidgetID:
				if(R6Console(Root.Console).m_bStartedByGSClient)
				{
					Root.ChangeCurrentWidget(UbiComWidgetID);
					class'Actor'.static.GetGameManager().StopGSClientProcedure();
				}
				else
				{
					Root.ChangeCurrentWidget(MultiPlayerWidgetID);
				}
				break;

			case Root.eGameWidgetID.OptionsWidgetID:
				R6MenuOptionsWidget(self).m_ButtonReturn.Click( 0, 0);
				// the Root.ChangeCurrentWidget(PreviousWidgetID) is does by the button itself!!!
				break;

			case Root.eGameWidgetID.ExecuteWidgetID:
				Root.ChangeCurrentWidget(PreviousWidgetID);
				break;

			case Root.eGameWidgetID.IntelWidgetID:    
			case Root.eGameWidgetID.GearRoomWidgetID:
			case Root.eGameWidgetID.PlanningWidgetID:
				R6MenuLaptopWidget(self).m_NavBar.m_MainMenuButton.Click( 0, 0);
				break;

			case Root.eGameWidgetID.MainMenuWidgetID:
			default:
				break;
		}
	}
}

defaultproperties
{
     m_fRightMouseXClipping=640.000000
     m_fRightMouseYClipping=480.000000
     bAcceptsFocus=True
     bAlwaysAcceptsFocus=True
}
