//=============================================================================
//  R6WithWeaponDotReticule.uc : Simple cross reticule with dot in the middle when zooming
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6WithWeaponDotReticule extends R6WithWeaponReticule;

simulated function PostRender( canvas C)
{
	local	R6PlayerController  player;
	local	Pawn				pawnOwner;

    // In 640x480, we offset the center by 1 pixel, the following variable are use to offset the center
    // of the reticule depending of the current resolution
    local FLOAT fCenterOffsetX;
    local FLOAT fCenterOffsetY;
    
	// Draw in the middle of the screen
    super.PostRender(C);

	pawnOwner = Pawn(Owner);
	if(pawnOwner == none || pawnOwner.controller == none)
		return;

	player = R6PlayerController(pawnOwner.controller);
    if(player != none && player.m_bHelmetCameraOn)
    {        
		SetReticuleInfo(C);
        C.Style = ERenderStyle.STY_Normal;

        // Reticule Offset from the center of the screen (based on 640x480)
        fCenterOffsetX = C.SizeX/640.0f;
        fCenterOffsetY = C.SizeY/480.0f;

        // the Dot
	    C.SetPos(m_fReticuleOffsetX - 1.0 + fCenterOffsetX, m_fReticuleOffsetY - 2.0 + fCenterOffsetY);
	    C.DrawRect(m_LineTexture, 3 , 1 );
	    C.SetPos(m_fReticuleOffsetX - 2.0 + fCenterOffsetX, m_fReticuleOffsetY - 1.0 + fCenterOffsetY);
	    C.DrawRect(m_LineTexture, 5 , 3 );
	    C.SetPos(m_fReticuleOffsetX - 1.0 + fCenterOffsetX, m_fReticuleOffsetY + 2.0 + fCenterOffsetY);
	    C.DrawRect(m_LineTexture, 3 , 1 );
    }

}

defaultproperties
{
}
