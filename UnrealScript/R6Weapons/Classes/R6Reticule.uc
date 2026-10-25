//=============================================================================
//  R6Reticule.uc : Base class of R6 reticules
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/02 * Aristomenis Kolokathis	- Creation
//    2001/08/26 * Eric Begin				- New reticule system
//=============================================================================
class R6Reticule extends actor
    native
	config(user)
    abstract;

var FLOAT m_fAccuracy; // accuracy adjustement: only used for to modifie the view

// Those variables are use to place the non-functionnal (Fixed) part of the reticule
var () INT m_iNonFunctionnalX;
var () INT m_iNonFunctionnalY;

var config Color    m_Color;
var     FLOAT       m_fZoomScale;  // the scale to apply when zooming (helmet camera)

var     FLOAT       m_fReticuleOffsetX;
var     FLOAT       m_fReticuleOffsetY;

var		BOOL		m_bIdentifyCharacter;
var		BOOL		m_bAimingAtFriendly;
var		BOOL		m_bShowNames;
var		string		m_CharacterName;
var		font		m_SmallFont_14pt;


// Speed gives us the current speed.
simulated function PostRender( canvas C)
{
    // Draw in the middle of the screen
	m_iNonFunctionnalX = C.HalfClipX;
	m_iNonFunctionnalY = C.HalfClipY;

	C.SetDrawColor(m_Color.R, m_Color.G, m_Color.B);

	C.SetPos(m_iNonFunctionnalX, m_iNonFunctionnalY);
	C.DrawText("(NO RETICULE)");
}

simulated function SetReticuleInfo(Canvas C)
{
    local color aColor;
    local R6GameOptions GameOptions;

	C.SetDrawColor(m_Color.R, m_Color.G, m_Color.B);

    GameOptions = GetGameOptions();	

    if(m_bAimingAtFriendly)
    {
        aColor = GameOptions.m_reticuleFriendColour;
        C.SetDrawColor(aColor.R, aColor.G, aColor.B ); 
    }
}

simulated function SetIdentificationReticule(Canvas C)
{
	local FLOAT fStrSizeX, fStrSizeY;
	local INT X, Y;

    if(m_bIdentifyCharacter && m_bShowNames)
    {
        C.UseVirtualSize(true, 640, 480);
	    X = C.HalfClipX;
	    Y = C.HalfClipY;
	    C.Font = m_SmallFont_14pt; 
	    C.StrLen( m_CharacterName, fStrSizeX, fStrSizeY );
	    C.SetPos( X - fStrSizeX/2, Y + 24 );
	    C.DrawText( m_CharacterName );
    }
}

/*
////////////////////////////////////////////////////////////////////////////////
// UpdateReticule( R6PlayerController r6Pawn, FLOAT fNewAccuracy )
//  - update the reticule accuracy and 
//  - set the zoom scale of the reticule
//  R6PlayerController ThePlayerController   : the controller who owns the reticule
//  FLOAT fNewAccuracy                       : the new accuracy absolute (not adjusted)
////////////////////////////////////////////////////////////////////////////////
simulated function UpdateReticule( R6PlayerController ThePlayerController, FLOAT fNewAccuracy )
{
    if(ThePlayerController != none)
    {
        // helmet camera not activated && not yet at the desired FOV value
        if ( (!ThePlayerController.m_bHelmetCameraOn && 
              ThePlayerController.default.desiredFOV == ThePlayerController.FOVangle) ||
             (ThePlayerController.Pawn.EngineWeapon.IsSniperRifle() == TRUE ))
        {
            m_fZoomScale = 1;   // 1 = default scale
        }
        else
        {
            // set the reticule scale based on the interpolation of the FOV
            m_fZoomScale = ThePlayerController.default.desiredFOV / ThePlayerController.FOVangle;
        }
        m_bIsFlashing = R6Weapons(ThePlayerController.Pawn.EngineWeapon).m_bIsStable;
		m_fAccuracy = fNewAccuracy * m_fZoomScale;
    }
}
*/

defaultproperties
{
     m_fZoomScale=1.000000
     m_SmallFont_14pt=Font'R6Font.Rainbow6_14pt'
     m_color=(R=255)
     RemoteRole=ROLE_None
     bHidden=True
}
