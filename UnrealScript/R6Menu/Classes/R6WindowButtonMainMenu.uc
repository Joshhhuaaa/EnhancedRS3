//=============================================================================
//  R6WindowButtonMainMenu.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  This is the class for main men button
//  Because of it's fancy (Thanks to Adrian) look
//  It will not rely on the look and feel to display
//	And will be very specific
//
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6WindowButtonMainMenu extends UWindowButton;

var texture		m_OverAlphaTexture, m_OverScrollingTexture;
var Region		m_OverAlphaRegion, m_OverScrollingRegion;
var int		    m_iTextRightPadding;
var float		m_fProgressTime, m_TextWidth;
var int			m_iMinXPos, m_iMaxXPos, m_iTotalScroll;
var FLOAT		m_fLMarge;
var font		m_buttonFont;
var float		m_fFontSpacing;
var bool		m_bResizeToText;

var Color       m_DownTextColor;

var enum eButtonActionType
{
    Button_SinglePlayer,
	Button_CustomMission,       
	Button_MultiPlayer,
	Button_Training,
	Button_Options,
	Button_Replays,
	Button_Credits,
	Button_Quit,
    Button_UbiComQuit,
    Button_UbiComReturn
} m_eButton_Action;

function Created()
{
    Super.Created();
    
    m_OverTextColor         = Root.Colors.White;
    TextColor               = Root.Colors.White;
    m_DownTextColor         = Root.Colors.BlueLight;
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT W, H, ftextSize;	
	
	

	if(m_buttonFont != NONE)
		C.Font = m_buttonFont;
	else
		C.Font = Root.Fonts[Font];

	TextSize(C, Text, W, H);
	
	switch(Align)
	{
	case TA_Left:
		TextX = m_fLMarge;
		break;
	case TA_Right:
		TextX = WinWidth - W - (Len(Text) * m_fFontSpacing);
		break;
	case TA_Center:
		TextX = (WinWidth - W - (Len(Text) * m_fFontSpacing)) / 2;
		break;
	}
	
	TextY = (WinHeight - H) / 2;
    TextY = FLOAT(INT(TextY+0.5));
	
	//This Allows Button to resize to the text size
	//and keep the position where the button was
	//Created
	
	if( m_bResizeToText)
	{
		ftextSize = W + (Len(Text) * m_fFontSpacing);
		WinWidth = ftextSize + m_fLMarge +m_iTextRightPadding;
		
		if (Align != TA_LEFT)
			WinLeft += TextX - m_fLMarge;
		
		TextX = m_fLMarge;
		Align = TA_LEFT; // Hummm... ok I admit this is a hack!
		m_bResizeToText = false;
	}
	

}

function Paint(Canvas C, float X, float Y)
{
	local float  TH;			
	local int currentTextStyle;
	
	C.Font = Root.Fonts[Font];
	TextSize(C, Text, m_TextWidth, TH);	
	//TextX -=m_iTextRightPadding;	
	
	
	if(bDisabled) 
	{        
		if(DisabledTexture != None)
		{
			if(bUseRegion)
				DrawStretchedTextureSegment( C, ImageX, ImageY, DisabledRegion.W*RegionScale, DisabledRegion.H*RegionScale, 
				DisabledRegion.X, DisabledRegion.Y, 
				DisabledRegion.W, DisabledRegion.H, DisabledTexture );
			else if(bStretched)
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DisabledTexture );
			else
				DrawClippedTexture( C, ImageX, ImageY, DisabledTexture);			
		}
		DrawButtonText(C, m_DisabledTextColor, ERenderStyle.STY_Translucent);
	} 
	else 
	{
		if(bMouseDown)
		{			

			DrawButtonBackGround(C, Root.Colors.Blue , 3);			
			DrawButtonScrollEffect(C, Root.Colors.BlueLight , 3);	
            DrawButtonText(C, m_DownTextColor, ERenderStyle.STY_Normal);
			
			
		}
		else 
		{
			if(MouseIsOver()) 
			{										        

					DrawButtonBackGround(C, Root.Colors.Blue , 3);															
					DrawButtonScrollEffect(C, Root.Colors.BlueLight, 3);					
					DrawButtonText(C, m_OverTextColor, ERenderStyle.STY_Normal);
				
			}
			else 
			{
				if(UpTexture != None)
				{
					if(bUseRegion)
						DrawStretchedTextureSegment( C, ImageX, ImageY, UpRegion.W*RegionScale, UpRegion.H*RegionScale, 
						UpRegion.X, UpRegion.Y, 
						UpRegion.W, UpRegion.H, UpTexture );
					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, UpTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, UpTexture);					
				}
				DrawButtonText(C, TextColor, ERenderStyle.STY_Normal);
			}
		}
	}

}

function DrawButtonText(Canvas C, color currentTextColor, int currentStyle)
{
	if(Text != "")	
	{
		if(m_buttonFont != NONE)
			C.Font = m_buttonFont;
		else
			C.Font = Root.Fonts[Font];	

        C.SpaceX = 0;
		C.SetDrawColor(currentTextColor.R,currentTextColor.G,currentTextColor.B);	
		C.Style = currentStyle; 
		ClipText(C, TextX, TextY, Text, True);
	}
}

function DrawButtonBackGround(Canvas C, color currentDrawColor, int currentStyle)
{
	C.Style = currentStyle; 	
	C.SetDrawColor(currentDrawColor.R,currentDrawColor.G,currentDrawColor.B);
	
    //Draws the left apha part of the button
    
	if(m_OverAlphaTexture != NONE)
		DrawStretchedTextureSegment( C, 0, ImageY, m_OverAlphaRegion.W, m_OverAlphaRegion.H, 
		m_OverAlphaRegion.X, m_OverAlphaRegion.Y, 
		m_OverAlphaRegion.W, m_OverAlphaRegion.H, m_OverAlphaTexture );
        

    	//Draws the tiling lines behind the text
	if(OverTexture != NONE)
		DrawStretchedTextureSegment( C, m_OverAlphaRegion.W, ImageY, WinWidth - (2*m_OverAlphaRegion.W), OverRegion.H,
								OverRegion.X, OverRegion.Y, 
								OverRegion.W, OverRegion.H, OverTexture );		
    	//Draw the right alpha part of the button
	if(m_OverAlphaTexture != NONE)
		DrawStretchedTextureSegment( C, WinWidth - m_OverAlphaRegion.W, ImageY, m_OverAlphaRegion.W, m_OverAlphaRegion.H, 
								m_OverAlphaRegion.X + m_OverAlphaRegion.W, m_OverAlphaRegion.Y, 
								-m_OverAlphaRegion.W, m_OverAlphaRegion.H, m_OverAlphaTexture );	
	
	
}

function DrawButtonScrollEffect(Canvas C, color currentDrawColor, int currentStyle)
{
	local int targetPos, lastDisplayedPos;
	local int iDisplayXPos, iWidthModifier;
	local R6MenuRSLookAndFeel currentLookAndFeel;
	
	
	m_iMinXPos = TextX - (m_OverScrollingRegion.W /2);
	m_iMaxXPos = WinWidth - m_iTextRightPadding - (m_OverScrollingRegion.W /2);	
	m_iTotalScroll = m_iMaxXPos - m_iMinXPos;
	currentLookAndFeel = R6MenuRSLookAndFeel(LookAndFeel);
	
	if(currentLookAndFeel != NONE)
	{
		//Make sure that the progressive time stay in valide values	
		m_fProgressTime = FClamp(m_fProgressTime, 0, m_iTotalScroll / currentLookAndFeel.m_fScrollRate);
		
		//When we reach a limit let's go back
		if( (m_fProgressTime == 0.0) || (m_fProgressTime == m_iTotalScroll / currentLookAndFeel.m_fScrollRate))
			currentLookAndFeel.m_iMultiplyer *= -1;
		
		//Calculate where we will be displaying the scrollig texture
		targetPos = m_fProgressTime * currentLookAndFeel.m_fScrollRate;
		iDisplayXPos = Clamp(m_iMinXPos + targetPos , TextX -m_iTextRightPadding, m_iMaxXPos);
		iWidthModifier = 0;
		
		// To make the scrolling effect clip on the left
		if( m_iMinXPos + targetPos < TextX -m_iTextRightPadding)
		{
			iWidthModifier = TextX -m_iTextRightPadding - m_iMinXPos -targetPos;
		}
		
		//This is to keep a relative position in order to have
		//almost the same scrolling position when you switch to
		//another button
		currentLookAndFeel.m_fCurrentPct = float(targetPos) / m_iTotalScroll;
		
		
		C.Style = currentStyle; //STY_Translucent
		
		C.SetDrawColor(currentDrawColor.R,currentDrawColor.G,currentDrawColor.B);
		
		
		//Draws the scrolling texture
		DrawStretchedTextureSegment( C, iDisplayXPos, ImageY, m_OverScrollingRegion.W - iWidthModifier, 
			m_OverScrollingRegion.H*RegionScale, m_OverScrollingRegion.X + iWidthModifier, 
			m_OverScrollingRegion.Y, m_OverScrollingRegion.W - iWidthModifier, 
			m_OverScrollingRegion.H, m_OverScrollingTexture);		
		
		
	}
}

function ResizeToText()
{
	m_bResizeToText=true;
}

function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

	//We find out if we need to update the position of the scrolling texture
	if(MouseIsOver() || bMouseDown)
		m_fProgressTime += deltaTime * R6MenuRSLookAndFeel(LookAndFeel).m_iMultiplyer;
	else
		m_fProgressTime = 	R6MenuRSLookAndFeel(LookAndFeel).m_fCurrentPct * m_iTotalScroll / R6MenuRSLookAndFeel(LookAndFeel).m_fScrollRate;
}


simulated function Click(float X, float Y) 
{
	local R6MenuRootWindow  r6Root;    
    
    if(bDisabled)    
        return;
    
    Super.Click(X,Y);

	r6Root = R6MenuRootWindow(Root);

	switch(m_eButton_Action)
	{
	case Button_SinglePlayer :
		r6Root.ChangeCurrentWidget(SinglePlayerWidgetID);
		break;
	case Button_CustomMission :
		r6Root.ChangeCurrentWidget(CustomMissionWidgetID);
		break;
	case Button_MultiPlayer :
		r6Root.ChangeCurrentWidget(MultiPlayerWidgetID);
		break;
	case Button_Training :
        r6Root.ChangeCurrentWidget(TrainingWidgetID);
		break;        
	case Button_Options :
		r6Root.ChangeCurrentWidget(OptionsWidgetID);
		break;	
	case Button_Credits :
		r6Root.ChangeCurrentWidget(CreditsWidgetID);
		break;
	case Button_Quit :		
        Root.ChangeCurrentWidget(MenuQuitID);
		break;
	default :
		break;		
	}
}

defaultproperties
{
     m_iTextRightPadding=4
     m_fLMarge=4.000000
     m_OverAlphaTexture=Texture'R6MenuTextures.MainMenuMouseOver'
     m_OverScrollingTexture=Texture'R6MenuTextures.MainMenuMouseOver'
     m_OverAlphaRegion=(X=94,W=31,H=25)
     m_OverScrollingRegion=(W=87,H=25)
     bUseRegion=True
     ImageY=5.000000
     OverTexture=Texture'R6MenuTextures.MainMenuMouseOver'
     OverRegion=(X=89,W=2,H=25)
     Align=TA_Right
     Font=14
}
