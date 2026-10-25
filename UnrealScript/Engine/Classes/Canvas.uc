//=============================================================================
// Canvas: A drawing canvas.
// This is a built-in Unreal class and it shouldn't be modified.
//
// Notes.
//   To determine size of a drawable object, set Style to STY_None,
//   remember CurX, draw the thing, then inspect CurX and CurYL.
//=============================================================================
class Canvas extends Object
	native
	noexport;

// Modifiable properties.
var font    Font;            // Font for DrawText.
var float   SpaceX, SpaceY;  // Spacing for after Draw*.
var float   OrgX, OrgY;      // Origin for drawing.
var float   ClipX, ClipY;    // Bottom right clipping region.
//R6CODE
var float   HalfClipX, HalfClipY; //Half clip value, to save all the /2 done on all clip values
//end R6Code
var float   CurX, CurY;      // Current position for drawing.
var float   Z;               // Z location. 1=no screenflash, 2=yes screenflash.
var byte    Style;           // Drawing style STY_None means don't draw.
var float   CurYL;           // Largest Y size since DrawText.
var color   DrawColor;       // Color for drawing.
var bool    bCenter;         // Whether to center the text.
var bool    bNoSmooth;       // Don't bilinear filter.
var const int SizeX, SizeY;  // Zero-based actual dimensions.

// Stock fonts.
var font SmallFont;          // Small system font.
var font MedFont;           // Medium system font.

// Internal.
var const viewport Viewport; // Viewport that owns the canvas.

//R6VIDEO
var int m_hBink;
var bool m_bPlaying;
var int m_iPosX;
var int m_iPosY;
//END R6VIDEO

//R6NewRendererFeatures
var BOOL	m_bForceMul2x;

// R6STRETCHHUD
var FLOAT   m_fStretchX;
var FLOAT   m_fStretchY;
var FLOAT   m_fVirtualResX;
var FLOAT   m_fVirtualResY;
var FLOAT   m_fNormalClipX;
var FLOAT   m_fNormalClipY;

// R6CHANGERES
var BOOL    m_bDisplayGameOutroVideo;
var BOOL    m_bChangeResRequested;
var INT     m_iNewResolutionX;
var INT     m_iNewResolutionY;

//R6CODE
var BOOL    m_bFading;
var BOOL    m_bFadeAutoStop;
var COLOR   m_FadeStartColor;
var COLOR   m_FadeEndColor;
var FLOAT   m_fFadeTotalTime;
var FLOAT   m_fFadeCurrentTime;

var Material m_pWritableMapIconsTexture;

// native functions.
native(464) final function StrLen( coerce string String, out float XL, out float YL );
native(465) final function DrawText( coerce string Text, optional bool CR );

//R6DRAWTILEROTATED
native(466) final function DrawTile( material Mat, float XL, float YL, float U, float V, float UL, float VL, optional float fRotationAngle );
//ELSE
//native(466) final function DrawTile( material Mat, float XL, float YL, float U, float V, float UL, float VL );
//END R6DRAWTILEROTATED
native(467) final function DrawActor( Actor A, bool WireFrame, optional bool ClearZ, optional float DisplayFOV );
native(468) final function DrawTileClipped( Material Mat, float XL, float YL, float U, float V, float UL, float VL );
native(469) final function DrawTextClipped( coerce string Text, optional bool bCheckHotKey );
//R6CODE
native(470) final function string TextSize( coerce string String, out float XL, out float YL , optional INT TotalWidth, optional INT SpaceWidth);
//ELSE
//native(470) final function TextSize( coerce string String, out float XL, out float YL);
//END //R6CODE
native(480) final function DrawPortal( int X, int Y, int Width, int Height, actor CamActor, vector CamLocation, rotator CamRotation, optional int FOV, optional bool ClearZ );

//R6MOTIONBLUR
native(2005) final function SetMotionBlurIntensity(INT iIntensityValue);
//END R6MOTIONBLUR

// R6AUTOTARGET
native(2400) final function BOOL GetScreenCoordinate( out FLOAT fScreenX, out FLOAT fScreenY, vector v3DCoordinate, vector vCamLocation, rotator rCamRotation, optional FLOAT fFOV );
// END R6AUTOTARGET

// R6DRAW3DLINE
native(2403) final function Draw3DLine( vector vStart, vector vEnd, color cLineColor );
// END R6DRAW3DLINE

// #ifdef R6VIDEO
native(2601) final function VideoOpen(string Name, INT bDisplayDoubleSize);
native(2602) final function VideoClose();
native(2603) final function VideoPlay(INT iPosX, INT iPosY, INT bCentered);
native(2604) final function VideoStop();
// #endif//R6VIDEO

// #ifdef R6WRITABLEMAP
native(2800) final function DrawWritableMap(LevelInfo info);
// #endif//R6WRITABLEMAP

// #ifdef R6STRETCHHUD
native(1606) final function UseVirtualSize( BOOL bUse, Optional FLOAT X, Optional FLOAT Y);
native(1607) final function SetVirtualSize( FLOAT X, FLOAT Y );
// #endif R6STRETCHHUD

// R6CODE
native(2623) final function SetPos(float X, float Y);
native(2624) final function SetOrigin(float X, float Y);
native(2625) final function SetClip(float X, float Y);
native(2626) final function SetDrawColor(byte R, byte G, byte B, optional byte A);
native(2627) final function DrawStretchedTextureSegmentNative(float X, float Y, float W, float H, float tX, float tY, float tW, float tH, float GUIScale, Region ClipRegion, texture Tex);
native(2628) final function ClipTextNative(float X, float Y, coerce string S, float GUIScale, Region ClipRegion, optional bool bCheckHotkey);

// UnrealScript functions.
event Reset()
{
//#ifndef R6CODE
//	Font        = Default.Font;
//#else
    Font = Font(DynamicLoadObject("R6Font.SmallFont",class'Font'));
    SmallFont=Font;
    MedFont=Font(DynamicLoadObject("R6Font.MediumFont",class'Font'));
//#endif
	SpaceX      = Default.SpaceX;
	SpaceY      = Default.SpaceY;
	OrgX        = Default.OrgX;
	OrgY        = Default.OrgY;
	CurX        = Default.CurX;
	CurY        = Default.CurY;
	Style       = Default.Style;
	DrawColor   = Default.DrawColor;
	CurYL       = Default.CurYL;
	bCenter     = false;
	bNoSmooth   = false;
	Z           = 1.0;
}

/* R6CODE
final function SetPos( float X, float Y )
{
	CurX = X;
	CurY = Y;
}
final function SetOrigin( float X, float Y )
{
	OrgX = X;
	OrgY = Y;
}

final function SetClip( float X, float Y )
{
	ClipX = X;
	ClipY = Y;
    //R6CODE
    HalfClipX = ClipX * 0.5;
    HalfClipY = ClipY * 0.5;
    //EndR6CODE
}
*/
final function DrawPattern( texture Tex, float XL, float YL, float Scale )
{
	DrawTile( Tex, XL, YL, (CurX-OrgX)*Scale, (CurY-OrgY)*Scale, XL*Scale, YL*Scale );
}
final function DrawIcon( texture Tex, float Scale )
{
	if ( Tex != None )
		DrawTile( Tex, Tex.USize*Scale, Tex.VSize*Scale, 0, 0, Tex.USize, Tex.VSize );
}
final function DrawRect( texture Tex, float RectX, float RectY )
{
	DrawTile( Tex, RectX, RectY, 0, 0, Tex.USize, Tex.VSize );
}

/* R6CODE
final function SetDrawColor(byte R, byte G, byte B, optional byte A)
{
	local Color C;
	
	C.R = R;
	C.G = G;
	C.B = B;
	if ( A == 0 )
		A = 255;
	C.A = A;
	DrawColor = C;
}*/

static final function Color MakeColor(byte R, byte G, byte B, optional byte A)
{
	local Color C;
	
	C.R = R;
	C.G = G;
	C.B = B;
	if ( A == 0 )
		A = 255;
	C.A = A;
	return C;
}

// Draw a vertical line
final function DrawVertical(float X, float height)
{
    SetPos( X, CurY);
    DrawRect(Texture'engine.WhiteSquareTexture', 2, height);
}

// Draw a horizontal line
final function DrawHorizontal(float Y, float width)
{
    SetPos(CurX, Y);
    DrawRect(Texture'engine.WhiteSquareTexture', width, 2);
}

// Draw Line is special as it saves it's original position

final function DrawLine(int direction, float size)
{
    local float X, Y;

    // Save current position
    X = CurX;
    Y = CurY;

    switch (direction) 
    {
      case 0:
		  SetPos(X, Y - size);
		  DrawRect(Texture'engine.WhiteSquareTexture', 2, size);
		  break;
    
      case 1:
		  DrawRect(Texture'engine.WhiteSquareTexture', 2, size);
		  break;

      case 2:
		  SetPos(X - size, Y);
		  DrawRect(Texture'engine.WhiteSquareTexture', size, 2);
		  break;
		  
	  case 3:
		  DrawRect(Texture'engine.WhiteSquareTexture', size, 2);
		  break;
    }
    // Restore position
    SetPos(X, Y);
}

final simulated function DrawBracket(float width, float height, float bracket_size)
{
    local float X, Y;
    X = CurX;
    Y = CurY;

	Width  = max(width,5);
	Height = max(height,5);
	
    DrawLine(3, bracket_size);
    DrawLine(1, bracket_size);
    SetPos(X + width, Y);
    DrawLine(2, bracket_size);
    DrawLine(1, bracket_size);
    SetPos(X + width, Y + height);
    DrawLine(0, bracket_size);
    DrawLine(2, bracket_size);
    SetPos(X, Y + height);
    DrawLine(3, bracket_size);
    DrawLine( 0, bracket_size);

    SetPos(X, Y);
}

final simulated function DrawBox(canvas canvas, float width, float height)
{
	local float X, Y;
	X = canvas.CurX;
	Y = canvas.CurY;
	canvas.DrawRect(Texture'engine.WhiteSquareTexture', 2, height);
	canvas.DrawRect(Texture'engine.WhiteSquareTexture', width, 2);
	canvas.SetPos(X + width, Y);
	canvas.DrawRect(Texture'engine.WhiteSquareTexture', 2, height);
	canvas.SetPos(X, Y + height);
	canvas.DrawRect(Texture'engine.WhiteSquareTexture', width+1, 2);
	canvas.SetPos(X, Y);
}

// R6STRETCHHUD
/*
final function SetStretch( FLOAT fStretchX, FLOAT fStretchY )
{
    m_fStretchX = fStretchX;
    m_fStretchY = fStretchY;
}


final function SetVirtualSize( FLOAT X, FLOAT Y )
{
    if( m_fNormalClipX != ClipX || m_fNormalClipY != ClipY )
    {
        UseVirtualSize( true, X, Y );
    }
    else
    {
        m_fVirtualResX = X;
        m_fVirtualResY = Y;
    }
}*/


final function FLOAT GetVirtualSizeX()
{
    return m_fVirtualResX;
}


final function FLOAT GetVirtualSizeY()
{
    return m_fVirtualResY;
}

/*
final function UseVirtualSize( BOOL bUse, Optional FLOAT X, Optional FLOAT Y )
{
    if( bUse )
    {
        m_fNormalClipX = ClipX;
        m_fNormalClipY = ClipY;

        if( X != 0 && Y != 0 )
        {
            SetVirtualSize( X, Y );
        }
    
        SetStretch( SizeX / m_fVirtualResX, SizeY / m_fVirtualResY );

        ClipX = m_fVirtualResX;
        ClipY = m_fVirtualResY; 
    }
    else
    {
        if( m_fNormalClipX > 0 && m_fNormalClipY > 0 )
        {
            ClipX = m_fNormalClipX;
            ClipY = m_fNormalClipY;
        }
        else
        {
            ClipX = SizeX;
            ClipY = SizeY;
        }

        SetStretch( 1.0f, 1.0f );
    }
    //R6CODE
    HalfClipX = ClipX * 0.5;
    HalfClipY = ClipY * 0.5;
    //EndR6CODE
}
*/
// END R6STRETCHHUD

defaultproperties
{
     Z=1.000000
     Style=1
     DrawColor=(B=127,G=127,R=127,A=255)
     m_fStretchX=1.000000
     m_fStretchY=1.000000
     m_fVirtualResX=800.000000
     m_fVirtualResY=600.000000
     m_fNormalClipX=-1.000000
     m_fNormalClipY=-1.000000
}
