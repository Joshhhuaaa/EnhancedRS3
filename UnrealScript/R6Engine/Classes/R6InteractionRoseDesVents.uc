//=============================================================================
//  R6InteractionRoseDesVents.uc : Basic interaction for the rose des vents
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by Sébastien Lussier
//=============================================================================
class R6InteractionRoseDesVents extends Interaction abstract;


#exec OBJ LOAD FILE=..\Textures\R6HUD.utx PACKAGE=R6HUD
#exec OBJ LOAD FILE=..\Textures\R6HudFonts.utx PACKAGE=R6HudFonts


var R6PlayerController  m_Player;
var string              m_ActionKey;

var BOOL                m_bActionKeyDown;
var BOOL                m_bIgnoreNextActionKeyRelease;
var BOOL                bShowLog;

var INT                 m_iCurrentMnuChoice;
var INT                 m_iCurrentSubMnuChoice;

var Texture             m_TexMNU;
var Texture             m_TexMNUItemNormalTop;
var Texture             m_TexMNUItemNormalLeft;
var Texture             m_TexMNUItemNormalSubTop;
var Texture             m_TexMNUItemNormalSubLeft;
var Texture             m_TexMNUItemSelectedSubTop;
var Texture             m_TexMNUItemSelectedSubLeft;
var Texture             m_TexMNUItemSelectedTop;
var Texture             m_TexMNUItemSelectedLeft;

var FLOAT               m_iTextureWidth;
var FLOAT               m_iTextureHeight;

var Font                m_Font;
var Color               m_Color;

var const INT           C_iMouseDelta;
const C_RoseDesVentSize = 150;

var Sound               m_RoseOpenSnd;
var Sound               m_RoseSelectSnd;

//===========================================================================//
// Initialized()                                                             //
//===========================================================================//
event Initialized()
{
    Super.Initialized();
    m_Player = R6PlayerController(ViewportOwner.Actor);
}

//===========================================================================//
// Override these
function GotoSubMenu();
function BOOL IsValidMenuChoice( INT iChoice );
function SetMenuChoice( INT iChoice );
function NoItemSelected();
function ItemRightClicked( INT iItem );
function ItemClicked( INT iItem );
function ActionKeyPressed();
function ActionKeyReleased();
function BOOL ItemHasSubMenu(INT iItem);


//===========================================================================//
// MenuItemEnabled()                                                         //
//===========================================================================//
function BOOL MenuItemEnabled( INT iItem )
{
    return true;
}


//===========================================================================//
// CurrentItemHasSubMenu()                                                   //
//===========================================================================//
function BOOL CurrentItemHasSubMenu()
{
    return false;
}


//===========================================================================//
// GetCurrentMenuChoice()                                                    //
//===========================================================================//
function INT GetCurrentMenuChoice()
{
    return m_iCurrentMnuChoice;
} 


//===========================================================================//
// GetCurrentSubMenuChoice()                                                 //
//===========================================================================//
function INT GetCurrentSubMenuChoice()
{
	return m_iCurrentSubMnuChoice;
}


//===========================================================================//
// DisplayMenu()                                                             //
//===========================================================================//
function DisplayMenu( BOOL bDisplay, optional BOOL bOpen )
{
    bVisible                = bDisplay;

    m_iCurrentMnuChoice     = -1;
    m_iCurrentSubMnuChoice  = -1;

    m_Player.m_bAMenuIsDisplayed = bDisplay;
    
    if( !bVisible )
    {
        GotoState('');
    }
    else
    {
        m_Player.PlaySound(m_RoseOpenSnd, SLOT_Menu);
        GotoState('MenuDisplayed');
        SetMenuChoice(0);
    }
}


//===========================================================================//
// KeyEvent()                                                                //
//===========================================================================//
function BOOL KeyEvent( EInputKey eKey, EInputAction eAction, FLOAT fDelta )
{
	if( eKey == m_Player.GetKey(m_ActionKey) ) 
	{
		if( eAction == IST_Press && !m_bActionKeyDown ) // Only send ActionKeyPressed() once
		{
			m_bActionKeyDown = true;
			ActionKeyPressed();
			return true;
		}
    
		if( eAction == IST_Release && m_bActionKeyDown )
		{
			if( !m_bIgnoreNextActionKeyRelease )
			{
				ActionKeyReleased();
			}
			else
			{
				m_bIgnoreNextActionKeyRelease = false;
			}

			m_bActionKeyDown = false;
			return true;
		}    
	}
    
    return Super.KeyEvent(eKey, eAction, fDelta);
}


//===========================================================================//
// MenuDisplayed()                                                           //
//===========================================================================//
state MenuDisplayed
{
    function bool KeyEvent( EInputKey eKey, EInputAction eAction, FLOAT fDelta )
    {
        local INT iCurrentMnuChoice;
        
        // Action key release, quit this state
        if( eKey == m_Player.GetKey(m_ActionKey) && eAction == IST_Release )
        {
			NoItemSelected();
            DisplayMenu(false);
            m_bActionKeyDown = false;
            m_bIgnoreNextActionKeyRelease=false;
            return true;
        }

        if( eKey == IK_LeftMouse && eAction == IST_Press )
        {
            // If this menu item is disabled
            if( !MenuItemEnabled(m_iCurrentMnuChoice) )
            {
            	return true;    // Ignore the mouse click   
            }
			// If the current menu selection has a sub menu,
			// open it.
			else if( CurrentItemHasSubMenu() )
			{
                m_Player.PlaySound(m_RoseSelectSnd, SLOT_Menu);
				GotoSubMenu();
				if( bShowLog ) log( "**** LeftMouse -> Move to sub menu ! ****" );
			}
			// Perform the action.
			else
			{
                m_Player.PlaySound(m_RoseSelectSnd, SLOT_Menu);
				ItemClicked(m_iCurrentMnuChoice);
                DisplayMenu(false);
                m_bIgnoreNextActionKeyRelease=true;
			}
            return true;
        }

        if( eKey == IK_RightMouse && eAction == IST_Press )
        {
            // If this menu item is disabled
            if( !MenuItemEnabled(m_iCurrentMnuChoice) )
            {
               	return true;    // Ignore the mouse click
            }
            // If the current menu selection has a sub menu,
		    // open it.
			else if( CurrentItemHasSubMenu() )
			{
                m_Player.PlaySound(m_RoseSelectSnd, SLOT_Menu);
    			GotoSubMenu();
			}
			// Perform the action.
			else
			{
                m_Player.PlaySound(m_RoseSelectSnd, SLOT_Menu);
                ItemRightClicked(m_iCurrentMnuChoice);
                DisplayMenu(false);
                m_bIgnoreNextActionKeyRelease=true;
			}
            return true;
        }
        
        // Change the menu selection with the mouse axis
        if( eAction == IST_Axis )
        {
            switch( eKey )
            {
            case EInputKey.IK_MouseX:
                // Don't take small mouse movements into account
                if( Abs(fDelta) > C_iMouseDelta )      // Potential problem with high FPS ? (is mouse polling dependant of FPS ?)
                {
                    if( fDelta > 0 )
                    {						
                        SetMenuChoice(1);
                    }
                    else
                    {
                        SetMenuChoice(3);
                    }
                }                
                return true;
                break;

            case EInputKey.IK_MouseY:
                // Don't take small mouse movements into account
                if( Abs(fDelta) > C_iMouseDelta )      // Potential problem with high FPS ? (is mouse polling dependant of FPS ?)
                {
                    if( fDelta > 0 )
                    {
                        SetMenuChoice(0);
                    }
                    else
                    {
                        SetMenuChoice(2);
                    }
                }                
                return true;
                break;
            }
        }

        // Change the menu selection with the mouse wheel
        if( eKey == IK_MouseWheelUp && eAction == IST_Press )
        {
            SetMenuChoice( m_iCurrentMnuChoice + 1 );

            if( m_iCurrentMnuChoice == -1 )
                SetMenuChoice(0);

            return true;
        }

        // Change the menu selection with the mouse wheel
        if( eKey == IK_MouseWheelDown && eAction == IST_Press )
        {
            SetMenuChoice( m_iCurrentMnuChoice - 1 );
            
            if( m_iCurrentMnuChoice == -1 )
                SetMenuChoice(3);

            return true;
        }
        
         return Super.KeyEvent(eKey, eAction, fDelta);
    }
}


//===========================================================================//
// DrawRoseDesVents                                                          //
//===========================================================================//
function DrawRoseDesVents( Canvas C, INT iMnuChoice )
{
    local INT   iItem;
    local INT   iUStart, iUEnd;
    local FLOAT fPosX, fPosY, fCenterX, fCenterY;
    local color TeamColor;
    local FLOAT fScaleX;
    local FLOAT fScaleY;
    local Texture CurrentTexture;
    local BOOL  bFlip;
    local BOOL  bHasSubMenu;
    local BOOL  bIsCurrent;

    TeamColor = m_Color;

    C.UseVirtualSize(false);

    fScaleX = C.SizeX / 800.0f;
    fScaleY = C.SizeY / 600.0f;

    fCenterX     = C.SizeX / 2.0f + fScaleX;
    fCenterY     = C.SizeY / 2.0f + fScaleY;

    C.Font          = m_Font;
    C.SetDrawColor(TeamColor.R, TeamColor.G, TeamColor.B, 255);

    C.Style = 5;    // STY_Alpha

    C.SetPos( fCenterX - (C_RoseDesVentSize + 5) * fScaleX, fCenterY - (C_RoseDesVentSize + 5) * fScaleY);
    C.DrawTile( m_TexMNU, (C_RoseDesVentSize * 2 + 10) * fScaleX, (C_RoseDesVentSize * 2 + 10) * fScaleY, 0, 0, 512, 512 );

    for( iItem = 0; iItem < 4; iItem++ )
    {
        if (iItem == iMnuChoice)
            bIsCurrent = true;
        else
            bIsCurrent = false;

        bHasSubMenu = ItemHasSubMenu(iItem);

        switch( iItem )
        {
        case 0: 
            fPosX = fCenterX - (C_RoseDesVentSize / 2) * fScaleX;    
            fPosY = fCenterY - (C_RoseDesVentSize) * fScaleY; 
            if (MenuItemEnabled(iItem))
            {
                if (!bHasSubMenu)
                {
                    if (bIsCurrent)

                        CurrentTexture = m_TexMNUItemSelectedTop;
                    else
                        CurrentTexture = m_TexMNUItemNormalTop;
                    
                }
                else
                {
                    if (bIsCurrent)
                        CurrentTexture = m_TexMNUItemSelectedSubTop;
                    else
                        CurrentTexture = m_TexMNUItemNormalSubTop;
                }
            }
            else
            {
                CurrentTexture = m_TexMNUItemNormalTop;
            }
            break;

        case 1: 
            fPosX = fCenterX;  
            fPosY = fCenterY - (C_RoseDesVentSize / 2) * fScaleY; 
                        
            if (MenuItemEnabled(iItem))
            {
                if (!bHasSubMenu)
                {
                    if (bIsCurrent)
                        CurrentTexture = m_TexMNUItemSelectedLeft;
                    else
                        CurrentTexture = m_TexMNUItemNormalLeft;
                    
                }
                else
                {
                    if (bIsCurrent)
                        CurrentTexture = m_TexMNUItemSelectedSubLeft;
                    else
                        CurrentTexture = m_TexMNUItemNormalSubLeft;
                }
            }
            else
            {
                CurrentTexture = m_TexMNUItemNormalLeft;
            }
            break;
        case 2: 
            fPosX = fCenterX - (C_RoseDesVentSize / 2) * fScaleX;    
            fPosY = fCenterY; 
            bFlip = true;
                                    
            if (MenuItemEnabled(iItem))
            {
                if (!bHasSubMenu)
                {
                    if (bIsCurrent)
                        CurrentTexture = m_TexMNUItemSelectedTop;
                    else
                        CurrentTexture = m_TexMNUItemNormalTop;
                    
                }
                else
                {
                    if (bIsCurrent)
                        CurrentTexture = m_TexMNUItemSelectedSubTop;
                    else
                        CurrentTexture = m_TexMNUItemNormalSubTop;
                }
            }
            else
            {
                CurrentTexture = m_TexMNUItemNormalTop;
            }
            break;

        case 3: 
            fPosX = fCenterX - (C_RoseDesVentSize) * fScaleX;    
            fPosY = fCenterY - (C_RoseDesVentSize / 2) * fScaleY; 
            bFlip = true;
                                    
            if (MenuItemEnabled(iItem))
            {
                if (!bHasSubMenu)
                {
                    if (bIsCurrent)
                        CurrentTexture = m_TexMNUItemSelectedLeft;
                    else
                        CurrentTexture = m_TexMNUItemNormalLeft;
                    
                }
                else
                {
                    if (bIsCurrent)
                        CurrentTexture = m_TexMNUItemSelectedSubLeft;
                    else
                        CurrentTexture = m_TexMNUItemNormalSubLeft;
                }
            }
            else
            {
                CurrentTexture = m_TexMNUItemNormalLeft;
            }
            break;
            
        }
    
        C.SetPos( fPosX, fPosY);
    
        if (bFlip)
        {
            C.DrawTile( CurrentTexture, C_RoseDesVentSize * fScaleX, C_RoseDesVentSize * fScaleY, m_iTextureWidth, m_iTextureHeight, -m_iTextureWidth, -m_iTextureHeight);
        }
        else
        {
            C.DrawTile( CurrentTexture, C_RoseDesVentSize * fScaleX, C_RoseDesVentSize  * fScaleY, 0, 0, m_iTextureWidth, m_iTextureHeight);
        }
    }
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

/* Uncomment this to display in red a box in which the text is displayed
    C.SetPos(0, 0);
    C.DrawRect(Texture'Color.Color.Red', fWidth, fHeight);
*/
    
    // Restore original canvas settings
    C.bCenter = bBackCenter;
    C.OrgX    = fBackOrgX;
    C.OrgY    = fBackOrgY;
    C.ClipX   = fBackClipX;
    C.ClipY   = fBackClipY;
}

defaultproperties
{
     m_iCurrentMnuChoice=-1
     m_iCurrentSubMnuChoice=-1
     C_iMouseDelta=5
     m_iTextureWidth=256.000000
     m_iTextureHeight=256.000000
     m_TexMNU=Texture'R6HUD.QuadDisplay_back'
     m_TexMNUItemNormalTop=Texture'R6HUD.QuadDisplay_01_Ver'
     m_TexMNUItemNormalLeft=Texture'R6HUD.QuadDisplay_01_Hori'
     m_TexMNUItemNormalSubTop=Texture'R6HUD.QuadDisplay_02_Ver'
     m_TexMNUItemNormalSubLeft=Texture'R6HUD.QuadDisplay_02_Hori'
     m_TexMNUItemSelectedSubTop=Texture'R6HUD.QuadDisplay_03_Ver'
     m_TexMNUItemSelectedSubLeft=Texture'R6HUD.QuadDisplay_03_Hori'
     m_TexMNUItemSelectedTop=Texture'R6HUD.QuadDisplay_04_Ver'
     m_TexMNUItemSelectedLeft=Texture'R6HUD.QuadDisplay_04_Hori'
     m_Font=Font'R6Font.Rainbow6_14pt'
     m_RoseOpenSnd=Sound'SFX_Menus.Play_Rose_Open'
     m_RoseSelectSnd=Sound'SFX_Menus.Play_Rose_Select'
}
