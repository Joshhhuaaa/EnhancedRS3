//=============================================================================
//  R6WindowSimpleFramedWindow.uc : This provides a simple frame for a window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/19 * Created by Alexandre Dionne
//=============================================================================


class R6WindowSimpleFramedWindow extends UWindowWindow;

var float   m_fHBorderHeight, m_fVBorderWidth;    //Border size
var float   m_fHBorderPadding, m_fVBorderPadding; //Allow the borders not to start in corners
												  // to let for instance a space of 1 pixel
												  // between a corner and the begining of the border	
   
var float   m_fHBorderOffset, m_fVBorderOffset;    //Border offset if you want the borders to 
												   //Offsetted form the window limits
												   // The VOffset is for the side borders
//////////////////////////////
//Please make sure you set the
//Padding correctly if you use
//the offsets values
//////////////////////////////		

var Texture m_HBorderTexture, m_VBorderTexture;
var Region  m_HBorderTextureRegion, m_VBorderTextureRegion;
//var color   m_BorderColor;

var Region	m_topLeftCornerR;
var Texture m_topLeftCornerT;
var int                     m_DrawStyle;
var bool    bShowLog;

var enum eCornerType //To draw some corners
{
	No_Corners,
    Top_Corners,
	Bottom_Corners,       
	All_Corners
} m_eCornerType;


//This is to create the window that needs the frame
var class<UWindowWindow>    m_ClientClass;
var UWindowWindow           m_ClientArea;

//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow( class<UWindowWindow> clientClass)
{
	m_ClientClass = clientClass;
	m_ClientArea = CreateWindow(m_ClientClass, m_fVBorderWidth + m_fVBorderOffset, m_fHBorderHeight +m_fHBorderOffset, 
										WinWidth - ( 2* m_fVBorderWidth) - ( 2* m_fVBorderOffset), 
										WinHeight -  (2* m_fHBorderHeight) - ( 2* m_fHBorderOffset), OwnerWindow);   
    if(bShowLog)
    {
        log("Creating Client window");
        log("m_ClientClass"@m_ClientClass);
        log("x:"@m_fVBorderWidth + m_fVBorderOffset);
        log("y:"@m_fHBorderHeight +m_fHBorderOffset);
        log("w:"@WinWidth - ( 2* m_fVBorderWidth) - ( 2* m_fVBorderOffset));
        log("h:"@WinHeight -  (2* m_fHBorderHeight) - ( 2* m_fHBorderOffset));
        log("Done Creating Client window");
    }
}

function SetCornerType(eCornerType _eCornerType)
{
    m_eCornerType = _eCornerType;
}

function AfterPaint(Canvas C, float X, float Y)
{
	local float tempSpace;


	
	C.SetDrawColor(m_BorderColor.R,m_BorderColor.G,m_BorderColor.B);
    C.Style = m_DrawStyle;
	
	
	switch(m_eCornerType)
	{
		case Top_Corners:

            if(m_HBorderTexture != NONE)
	        {
		        //top
		        DrawStretchedTextureSegment( C, m_fHBorderPadding, m_fHBorderOffset, WinWidth  - (2* m_fHBorderPadding),
											        m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											        m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
		        //Bottom
		        DrawStretchedTextureSegment( C, m_fVBorderOffset, WinHeight - m_fHBorderHeight, 
											        WinWidth -  (2* m_fVBorderOffset), 
											        m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											        m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
	        }

	        if(m_VBorderTexture != NONE)
	        {
		        //Left
		        DrawStretchedTextureSegment( C, m_fVBorderOffset, m_fVBorderPadding, m_fVBorderWidth, 
											        WinHeight -  m_fVBorderPadding - m_fHBorderHeight, 
											        m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											        m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );
		        //Right
		        DrawStretchedTextureSegment( C, WinWidth - m_fVBorderWidth - m_fVBorderOffset, m_fVBorderPadding, m_fVBorderWidth, 
											        WinHeight -  m_fVBorderPadding - m_fHBorderHeight, 
											        m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											        m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );		
	        }

			//Corners
			
			if(m_topLeftCornerT != NONE)
			{
				DrawStretchedTextureSegment(C, 0, 0, m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerR.X, m_topLeftCornerR.Y, 
														m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerT);		
				DrawStretchedTextureSegment(C, WinWidth - m_topLeftCornerR.W, 0, m_topLeftCornerR.W, m_topLeftCornerR.H, 
														m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y, 
														-m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerT);
			}
			break;
		case Bottom_Corners:			
            if(m_HBorderTexture != NONE)
	        {
		        //top
		        DrawStretchedTextureSegment( C, m_fVBorderOffset, 0, WinWidth  - (2* m_fVBorderOffset),
											        m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											        m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
		        //Bottom
		        DrawStretchedTextureSegment( C, m_fHBorderPadding, WinHeight - m_fHBorderHeight -m_fHBorderOffset, 
											        WinWidth - (2* m_fHBorderPadding), 
											        m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											        m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
	        }

	        if(m_VBorderTexture != NONE)
	        {
		        //Left
		        DrawStretchedTextureSegment( C, m_fVBorderOffset, m_fHBorderHeight, m_fVBorderWidth, 
											        WinHeight -  m_fVBorderPadding - m_fHBorderHeight , 
											        m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											        m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );
		        //Right
		        DrawStretchedTextureSegment( C, WinWidth - m_fVBorderWidth - m_fVBorderOffset, m_fHBorderHeight, m_fVBorderWidth, 
											        WinHeight  - m_fVBorderPadding - m_fHBorderHeight, 
											        m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											        m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );		
	        }
            //Corners
			if(m_topLeftCornerT != NONE)
			{
				DrawStretchedTextureSegment(C, 0, WinHeight -  m_topLeftCornerR.H, m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerR.X, 
														m_topLeftCornerR.Y + m_topLeftCornerR.H, 
														m_topLeftCornerR.W, -m_topLeftCornerR.H, m_topLeftCornerT);		
				DrawStretchedTextureSegment(C, WinWidth - m_topLeftCornerR.W, WinHeight -  m_topLeftCornerR.H, m_topLeftCornerR.W, m_topLeftCornerR.H, 
														m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y + m_topLeftCornerR.H, 
														-m_topLeftCornerR.W, -m_topLeftCornerR.H, m_topLeftCornerT);
			}
			break;
		case All_Corners:
           	if(m_HBorderTexture != NONE)
	        {
		        //top
		        DrawStretchedTextureSegment( C, m_fHBorderPadding, m_fHBorderOffset, WinWidth  - (2* m_fHBorderPadding),
											        m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											        m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
		        //Bottom
		        DrawStretchedTextureSegment( C, m_fHBorderPadding, WinHeight - m_fHBorderHeight -m_fHBorderOffset, 
											        WinWidth - (2* m_fHBorderPadding), 
											        m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											        m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
	        }

	        if(m_VBorderTexture != NONE)
	        {
		        //Left
		        DrawStretchedTextureSegment( C, m_fVBorderOffset, m_fVBorderPadding, m_fVBorderWidth, 
											        WinHeight - (2 * m_fVBorderPadding) , 
											        m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											        m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );
		        //Right
		        DrawStretchedTextureSegment( C, WinWidth - m_fVBorderWidth - m_fVBorderOffset, m_fVBorderPadding, m_fVBorderWidth, 
											        WinHeight  - (2 * m_fVBorderPadding), 
											        m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											        m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );		
	        }
	
			//Corners
			if(m_topLeftCornerT != NONE)
			{
				DrawStretchedTextureSegment(C, 0, 0, m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerR.X, m_topLeftCornerR.Y, 
														m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerT);		
				DrawStretchedTextureSegment(C, WinWidth - m_topLeftCornerR.W, 0, m_topLeftCornerR.W, m_topLeftCornerR.H, 
														m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y, 
														-m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerT);
				DrawStretchedTextureSegment(C, 0, WinHeight -  m_topLeftCornerR.H, m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerR.X, 
														m_topLeftCornerR.Y + m_topLeftCornerR.H, 
														m_topLeftCornerR.W, -m_topLeftCornerR.H, m_topLeftCornerT);		
				DrawStretchedTextureSegment(C, WinWidth - m_topLeftCornerR.W, WinHeight -  m_topLeftCornerR.H, m_topLeftCornerR.W, m_topLeftCornerR.H, 
														m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y + m_topLeftCornerR.H, 
														-m_topLeftCornerR.W, -m_topLeftCornerR.H, m_topLeftCornerT);			
			}
			break;
	}
		
	C.Style = 1;
//	C.SetDrawColor(255,255,255);	

}

defaultproperties
{
     m_eCornerType=All_Corners
     m_DrawStyle=5
     m_fHBorderHeight=1.000000
     m_fVBorderWidth=1.000000
     m_fHBorderPadding=7.000000
     m_fVBorderPadding=8.000000
     m_fVBorderOffset=1.000000
     m_HBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_VBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_topLeftCornerT=Texture'R6MenuTextures.Gui_BoxScroll'
     m_ClientClass=Class'UWindow.UWindowClientWindow'
     m_HBorderTextureRegion=(X=64,Y=56,W=1,H=1)
     m_VBorderTextureRegion=(X=64,Y=56,W=1,H=1)
     m_topLeftCornerR=(X=12,Y=56,W=6,H=8)
}
