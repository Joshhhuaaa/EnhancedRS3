//=============================================================================
//  R6WithWeaponReticule.uc : Simple cross reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6WithWeaponReticule extends R6Reticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

var (Textures) texture m_LineTexture;


var const int   c_iLineWidth;
var const int   c_iLineHeight; 


// Speed gives us the current speed.
simulated function PostRender( canvas C)
{
	// Draw the reticule
    local FLOAT fScale;
    local INT   iWidth;
    local INT   iHeight;
    local FLOAT fAjustedAccuracy;

    local FLOAT fPositionAjustment;
    // In 640x480, we offset the center by 1 pixel, the following variable are use to offset the center
    // of the reticule depending of the current resolution
    local FLOAT fCenterOffsetX;
    local FLOAT fCenterOffsetY;

    // height and width of recticule line draw
    iWidth  = c_iLineWidth;
    iHeight = c_iLineHeight;  //Init to Width, to get a dot at maximum precision 

    fAjustedAccuracy = m_fAccuracy - 0.25;
    if(fAjustedAccuracy < 0.0)
    {
        fAjustedAccuracy = 0.0;
    }
    
    iHeight += c_iLineHeight * fAjustedAccuracy * 0.02; //   fAjustedAccuracy / 50

	SetReticuleInfo(C);
    C.Style = ERenderStyle.STY_Normal;
    
    C.UseVirtualSize(false);

    // Reticule Offset from the center of the screen (based on 640x480)
    fCenterOffsetX = C.SizeX/640.0f;
    fCenterOffsetY = C.SizeY/480.0f;
    
    // the Dot
    C.SetPos(m_fReticuleOffsetX + fCenterOffsetX, m_fReticuleOffsetY + fCenterOffsetY);
	C.DrawRect(m_LineTexture, c_iLineWidth, c_iLineWidth);
    
    fPositionAjustment = m_fReticuleOffsetY * fAjustedAccuracy * 0.02; //   fAjustedAccuracy / 50    0 is middle 50 is on the edge of the screen

    // Top line
	C.SetPos(m_fReticuleOffsetX + fCenterOffsetX, m_fReticuleOffsetY - iHeight - fPositionAjustment + fCenterOffsetY);
	C.DrawRect(m_LineTexture, iWidth, iHeight );

    // Bottom line
	C.SetPos(m_fReticuleOffsetX + fCenterOffsetX, m_fReticuleOffsetY + fPositionAjustment + fCenterOffsetY + 1);
	C.DrawRect(m_LineTexture, iWidth, iHeight );

    // Left Line
	C.SetPos(m_fReticuleOffsetX - iHeight - fPositionAjustment + fCenterOffsetX, m_fReticuleOffsetY + fCenterOffsetY);
	C.DrawRect(m_LineTexture, iHeight, iWidth);

    // Right Line
	C.SetPos(m_fReticuleOffsetX + fPositionAjustment + fCenterOffsetX + 1, m_fReticuleOffsetY + fCenterOffsetY);
	C.DrawRect(m_LineTexture, iHeight, iWidth);
}

defaultproperties
{
     c_iLineWidth=1
     c_iLineHeight=8
     m_LineTexture=Texture'UWindow.WhiteTexture'
}
