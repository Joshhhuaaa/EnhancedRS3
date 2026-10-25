class R6MenuMissionDescription extends UWindowBitmap;

//#exec OBJ LOAD FILE=..\Sounds\R6Briefing.uax PACKAGE=R6Briefing

var Texture m_Texture;
var sound m_MissionSound;
var Texture m_HBorderTexture, m_VBorderTexture;
var Region m_HBorderTextureRegion, m_VBorderTextureRegion;

var float m_fHBorderHeight, m_fVBorderWidth;
var float m_fHBorderPadding, m_fVBorderPadding;
//var color m_BorderColor;


function Created()
{
    Super.Created();
    m_Texture = Texture(DynamicLoadObject("R6BlackSnow.Mission.Wide_scr", class'Texture'));

//    GetPlayerOwner().PlaySound(m_MissionSound, SLOT_HeadSet);
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{

    C.Style = m_BorderStyle;    
	C.SetDrawColor(m_BorderColor.R,m_BorderColor.G,m_BorderColor.B);
    
	if(m_HBorderTexture != NONE)
	{
		//top
		DrawStretchedTextureSegment( C, m_fHBorderPadding, 0, WinWidth - (2* m_fHBorderPadding),
											m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
		//Bottom
		DrawStretchedTextureSegment( C, m_fHBorderPadding, WinHeight - m_fHBorderHeight, 
											WinWidth  - (2* m_fHBorderPadding), 
											m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
	}

	if(m_VBorderTexture != NONE)
	{
		//Left
		DrawStretchedTextureSegment( C, 0, m_fHBorderHeight + m_fVBorderPadding, m_fVBorderWidth, 
											WinHeight - (2 * m_fHBorderHeight) - (2 * m_fVBorderPadding) , 
											m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );
		//Right
		DrawStretchedTextureSegment( C, WinWidth - m_fVBorderWidth, m_fHBorderHeight + m_fVBorderPadding, m_fVBorderWidth, 
											WinHeight - (2 * m_fHBorderHeight) - (2 * m_fVBorderPadding), 
											m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );		
	}

	C.SetDrawColor(255,255,255);


    DrawStretchedTextureSegment(C, m_fVBorderWidth,m_fHBorderHeight,434,226,0, 0,434,226,    m_Texture);
}

defaultproperties
{
}
