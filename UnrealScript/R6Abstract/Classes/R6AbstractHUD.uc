//=============================================================================
//  R6AstractHUD.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/16 * Created by Guillaume Borgia
//=============================================================================
class R6AbstractHUD extends HUD
	native
    abstract;

#exec OBJ LOAD FILE=..\Textures\R6HudFonts.utx PACKAGE=R6HudFonts

var		INT				        m_iCycleHUDLayer;
var		BOOL		        	m_bToggleHelmet;

// HUD resolution
var     FLOAT                   m_fNewHUDResX;
var     FLOAT                   m_fNewHUDResY;
var     BOOL                    m_bGetRes;
var     string                  m_szStatusDetail;   // this string is displayed 5 sec. 

function PostRender( Canvas C )
{
    // If HUDRes exec function was called, resize the virtual canvas screen
    if( m_fNewHUDResX > 0 && m_fNewHUDResY > 0 )
    {
        C.SetVirtualSize( m_fNewHUDResX, m_fNewHUDResY );
        m_fNewHUDResX = 0;
        m_fNewHUDResY = 0;
    }

    if( m_bGetRes )
    {
        PlayerController(Owner).ClientMessage( C.SizeX @ "x" @ C.SizeY );
        m_bGetRes = false;
    }

    Super.PostRender( C );
}


//===========================================================================//
// DrawTextCenteredInBox()                                                   //
//===========================================================================//
function DrawTextCenteredInBox( Canvas C, string strText, FLOAT fPosX, FLOAT fPosY, FLOAT fWidth, FLOAT fHeight )
{
    local FLOAT fTextWidth;
    local FLOAT fTextHeight;

    local BOOL  bBackCenter;
    local FLOAT fBackOrgX;
    local FLOAT fBackOrgY;
    local FLOAT fBackClipX;
    local FLOAT fBackClipY;

    // Keep original canvas settings to restore them later
    bBackCenter = C.bCenter;
    fBackOrgX   = C.OrgX;
    fBackOrgY   = C.OrgY;
    fBackClipX  = C.ClipX;
    fBackClipY  = C.ClipY;

    C.bCenter = true;
    C.OrgX    = fPosX;
    C.OrgY    = fPosY;
    C.ClipX   = fWidth;
    C.ClipY   = fHeight;

    C.StrLen( strText, fTextWidth, fTextHeight );
    C.SetPos( 0, (fHeight-fTextHeight) / 2.0f );
    C.DrawText( strText );
    
    // Restore original canvas settings
    C.bCenter = bBackCenter;
    C.OrgX    = fBackOrgX;
    C.OrgY    = fBackOrgY;
    C.ClipX   = fBackClipX;
    C.ClipY   = fBackClipY;
}


//===========================================================================//
// DrawTexturePart()                                                         //
//===========================================================================//
function DrawTexturePart( Canvas C, Texture tex, FLOAT fUStart, FLOAT fVStart, FLOAT fSizeX, FLOAT fSizeY )
{
    C.DrawTile( tex, fSizeX, fSizeY, fUStart, fVStart, fSizeX, fSizeY );
}


//===========================================================================//
// HUDRes()                                                                  //
//  Change HUD resolution to make it appear bigger or smaller on screen.     //
//===========================================================================//
exec function HUDRes( String strRes )
{
    local INT iPos;
    local INT X, Y;

    iPos = InStr( strRes, "x" );

    X = INT(Left(strRes,iPos));
    Y = INT(Mid(strRes,iPos+1));
    
    if( X > 0 && Y > 0 )
    {
        m_fNewHUDResX = X;
        m_fNewHUDResY = Y;
    }
}


//===========================================================================//
// GetRes()                                                                  //
//  Display current resolution.                                              //
//===========================================================================//
exec function GetRes()
{
    m_bGetRes = true;
}


//===========================================================================//
// GetGoCodeStr()                                                            //
//===========================================================================//
function String GetGoCodeStr( eGoCode goCode )
{
	switch(goCode)
	{
	case GOCODE_Alpha:		return "A";
	case GOCODE_Bravo:		return "B";
	case GOCODE_Charlie:	return "C";
	case GOCODE_Zulu:		return "D";
	}
	
	return "";
}


exec function ToggleHelmet()
{
    m_bToggleHelmet = !m_bToggleHelmet;
}


exec function CycleHUDLayer()
{
    m_iCycleHUDLayer++;
	if (m_iCycleHUDLayer == 4)
		m_iCycleHUDLayer = 0;
}

function StartFadeToBlack( int iSec, int iPercentageOfBlack );
function StopFadeToBlack();
function UpdateHudFilter();
function ActivateNoDeathCameraMsg( bool bToggleOn );

defaultproperties
{
}
