//=============================================================================
// UWindowButton - A button
//=============================================================================
class UWindowButton extends UWindowDialogControl;

var texture		UpTexture, DownTexture, DisabledTexture, OverTexture;
var Region		UpRegion,  DownRegion,  DisabledRegion,  OverRegion;
var float		RegionScale;
var float		ImageX, ImageY;

var INT			m_iButtonID;	         // Can be used to set a special Id to this button

var bool		bDisabled;
var bool		bStretched;
var bool		bUseRegion;

//Button is Selected
var bool		m_bSelected;

var bool		m_bDrawButtonBorders;
var bool		m_bUseRotAngle;
var FLOAT       m_fRotAngle;  // Rad
var FLOAT		m_fRotAngleWidth;
var FLOAT		m_fRotAngleHeight;

var sound		OverSound, DownSound;

//Different State TextColor
var Color   m_SelectedTextColor;
var Color   m_DisabledTextColor;
var Color   m_OverTextColor;

//R6CODE
var BOOL    m_bPlayButtonSnd;
var BOOL    m_bWaitSoundFinish;
var BOOL    m_bSoundStart;
//R6CODE END

function Created()
{
	Super.Created();   

    TextColor               = Root.Colors.ButtonTextColor[0];
    m_DisabledTextColor     = Root.Colors.ButtonTextColor[1];
    m_OverTextColor         = Root.Colors.ButtonTextColor[2];
    m_SelectedTextColor     = Root.Colors.ButtonTextColor[3];  
	
	m_fRotAngleWidth  = WinWidth;
	m_fRotAngleHeight = WinHeight;
}

function BeforePaint(Canvas C, float X, float Y)
{
	C.Font = Root.Fonts[Font];
}

function Paint(Canvas C, float X, float Y)
{
	C.Font = Root.Fonts[Font];

    C.Style = ERenderStyle.STY_Alpha;

	if(bDisabled) {
		if(DisabledTexture != None)
		{
			if(bUseRegion)
			{
				if (m_bUseRotAngle)
					DrawStretchedTextureSegmentRot( C, ImageX, ImageY, m_fRotAngleWidth, m_fRotAngleHeight,//WinWidth, WinHeight,//DisabledRegion.W*RegionScale, DisabledRegion.H*RegionScale, 
													   DisabledRegion.X, DisabledRegion.Y, 
													   DisabledRegion.W, DisabledRegion.H, DisabledTexture, m_fRotAngle);
				else
					DrawStretchedTextureSegment( C, ImageX, ImageY, Abs(DisabledRegion.W*RegionScale), Abs(DisabledRegion.H*RegionScale), 
													DisabledRegion.X, DisabledRegion.Y, 
													DisabledRegion.W, DisabledRegion.H, DisabledTexture);
			}
			else if(bStretched)
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DisabledTexture );
			else
				DrawClippedTexture( C, ImageX, ImageY, DisabledTexture);
		}
	} else {
		if(bMouseDown)
		{
			if(DownTexture != None)
			{
				if(bUseRegion)
				{
					if (m_bUseRotAngle)	
						DrawStretchedTextureSegmentRot( C, ImageX, ImageY, m_fRotAngleWidth, m_fRotAngleHeight,//WinWidth, WinHeight,//DownRegion.W*RegionScale, DownRegion.H*RegionScale, 
														   DownRegion.X, DownRegion.Y, 
														   DownRegion.W, DownRegion.H, DownTexture, m_fRotAngle);
					else
						DrawStretchedTextureSegment( C, ImageX, ImageY, Abs(DownRegion.W*RegionScale), Abs(DownRegion.H*RegionScale), 
												  	    DownRegion.X, DownRegion.Y, 
														DownRegion.W, DownRegion.H, DownTexture);					
				}
				else if(bStretched)
					DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DownTexture );
				else
					DrawClippedTexture( C, ImageX, ImageY, DownTexture);
			}
		} else {
			if(MouseIsOver()) {
				if(OverTexture != None)
				{
					if(bUseRegion)
					{
						if (m_bUseRotAngle)
							DrawStretchedTextureSegmentRot( C, ImageX, ImageY, m_fRotAngleWidth, m_fRotAngleHeight,//WinWidth, WinHeight,//OverRegion.W*RegionScale, OverRegion.H*RegionScale, 
															   OverRegion.X, OverRegion.Y, 
															   OverRegion.W, OverRegion.H, OverTexture, m_fRotAngle);
						else
							DrawStretchedTextureSegment( C, ImageX, ImageY, Abs(OverRegion.W*RegionScale), Abs(OverRegion.H*RegionScale), 
															OverRegion.X, OverRegion.Y, 
															OverRegion.W, OverRegion.H, OverTexture);						
					}						
					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, OverTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, OverTexture);
				}
			} else {
				if(UpTexture != None)
				{
					if(bUseRegion)
					{
						if (m_bUseRotAngle)
							DrawStretchedTextureSegmentRot( C, ImageX, ImageY, m_fRotAngleWidth, m_fRotAngleHeight,//WinWidth, WinHeight, //UpRegion.W*RegionScale, UpRegion.H*RegionScale, 
														    UpRegion.X, UpRegion.Y, 
															UpRegion.W, UpRegion.H, UpTexture, m_fRotAngle);
						else
							DrawStretchedTextureSegment( C, ImageX, ImageY, Abs(UpRegion.W*RegionScale), Abs(UpRegion.H*RegionScale), 
														    UpRegion.X, UpRegion.Y, 
															UpRegion.W, UpRegion.H, UpTexture);
					}						
					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, UpTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, UpTexture);
				}
			}
		}
	}

	if (m_bDrawButtonBorders)
	{
		DrawSimpleBorder( C);
	}

	if(Text != "")
	{		
	    if( bDisabled )         
			C.SetDrawColor(m_DisabledTextColor.R,m_DisabledTextColor.G,m_DisabledTextColor.B);		
        else if (m_bSelected)
            C.SetDrawColor(m_SelectedTextColor.R,m_SelectedTextColor.G,m_SelectedTextColor.B);
        else if(MouseIsOver())
            C.SetDrawColor(m_OverTextColor.R,m_OverTextColor.G,m_OverTextColor.B);
		else
			C.SetDrawColor(TextColor.R,TextColor.G,TextColor.B);

		ClipText(C, TextX, TextY, Text, True);
	}
}


function AfterPaint(Canvas C, float X, float Y)
{
    if (m_bSoundStart && !GetPlayerOwner().IsPlayingSound(GetPlayerOwner(), DownSound))
    {    
        Notify(DE_Click);
        m_bSoundStart = false;
    }
}

simulated function Click(float X, float Y) 
{
    if(bDisabled)
        return;

//R6CODE    
//    log("CLICK Sound =" @ DownSound);
    if (m_bPlayButtonSnd && DownSound != None)
    {
        GetPlayerOwner().PlaySound(DownSound, SLOT_Menu);
        if (m_bWaitSoundFinish)
        {
            m_bSoundStart = true;
            return;
        }
    }
//END R6CODE        

	Notify(DE_Click);
}

function DoubleClick(float X, float Y) 
{
    if(!bDisabled)
	    Notify(DE_DoubleClick);
}

function RClick(float X, float Y) 
{
    if(!bDisabled)
	    Notify(DE_RClick);
}

function MClick(float X, float Y) 
{
    if(!bDisabled)
	    Notify(DE_MClick);
}

defaultproperties
{
     m_bPlayButtonSnd=True
     RegionScale=1.000000
     m_fRotAngle=1.570000
     DownSound=Sound'SFX_Menus.Play_Button_Selection'
     bIgnoreLDoubleClick=True
     bIgnoreMDoubleClick=True
     bIgnoreRDoubleClick=True
}
