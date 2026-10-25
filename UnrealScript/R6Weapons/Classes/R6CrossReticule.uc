//=============================================================================
//  R6CrossReticule.uc : Simple cross reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CrossReticule extends R6Reticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

var (Textures) texture m_LineTexture;


var const int   c_iLineWidth;
var const int   c_iLineHeight; 


// Speed gives us the current speed.
simulated function PostRender( canvas C)
{
	// Draw in the middle of the screen
    local FLOAT fScale;
    local int   iWidth;
    local int   iHeight;

    local FLOAT fPositionAjustment;
    
    // height and width of recticule line draw
    iWidth  = c_iLineWidth;    
    iHeight = c_iLineHeight;    

	SetReticuleInfo(C);

    C.Style = ERenderStyle.STY_Normal;

    C.UseVirtualSize(false);

    m_fAccuracy -= 0.14;
    if(m_fAccuracy < 0.0)
    {
        m_fAccuracy = 0.0;
    }

    fPositionAjustment = m_fReticuleOffsetY * m_fAccuracy * 0.02; //   m_fAccuracy / 25    0 is middle 25 is on the edge of the screen
    iHeight += c_iLineHeight * m_fAccuracy * 0.02; //   m_fAccuracy / 25
    
    // Top line
	C.SetPos(m_fReticuleOffsetX - 1.0, m_fReticuleOffsetY - iHeight - fPositionAjustment);
	C.DrawRect(m_LineTexture, iWidth, iHeight );

    // Bottom Line
	C.SetPos(m_fReticuleOffsetX - 1.0, m_fReticuleOffsetY + fPositionAjustment);
	C.DrawRect(m_LineTexture, iWidth, iHeight);

    // Left Line
	C.SetPos(m_fReticuleOffsetX - iHeight - fPositionAjustment, m_fReticuleOffsetY - 1.0);
	C.DrawRect(m_LineTexture, iHeight, iWidth);

    // Right Line
	C.SetPos(m_fReticuleOffsetX + fPositionAjustment, m_fReticuleOffsetY - 1.0);
	C.DrawRect(m_LineTexture, iHeight, iWidth);
}

defaultproperties
{
     c_iLineWidth=2
     c_iLineHeight=16
     m_LineTexture=Texture'UWindow.WhiteTexture'
}
