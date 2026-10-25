//=============================================================================
//  R6InteractionInventoryMnu.uc : Interaction associated with the inventory.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by Sébastien Lussier
//=============================================================================
class R6InteractionInventoryMnu extends R6InteractionRoseDesVents;


function ActionKeyPressed()
{
	if(m_Player.bOnlySpectator)
		return;

	DisplayMenu(true);
}

function BOOL IsValidMenuChoice( INT iChoice )
{
    if( iChoice < 0 || iChoice > 3 || 
        m_Player.m_Pawn.m_WeaponsCarried[iChoice] == None || 
        !m_Player.m_Pawn.m_WeaponsCarried[iChoice].HasAmmo())
    {
        return false;
    }

    return true;
}

function SetMenuChoice( INT iChoice )
{
    if( iChoice < 0 || iChoice > 3 )
    {
        m_iCurrentMnuChoice = -1;    // Invalid, don't display
    }
	// Validate for sub menu and main menu
	else if( m_Player.m_Pawn.m_WeaponsCarried[iChoice] != None &&
             m_Player.m_Pawn.m_WeaponsCarried[iChoice].HasAmmo())
    {
        m_iCurrentMnuChoice = iChoice;
    }
    else
    {
        SetMenuChoice( iChoice - 1 );
    }    
}

function ItemClicked( INT iItem )
{
    if( bShowLog ) log( "**** LeftMouse -> Change weapon ! ****" );

    if( iItem != -1 )
		m_Player.SwitchWeapon( iItem + 1 );
}

function PostRender( Canvas C )
{
    C.UseVirtualSize(true);

    //Super.PostRender( C );
    DrawInventoryMenu( C );

    C.UseVirtualSize(false);
}

//===========================================================================//
// DrawInventoryMenu()                                                       //
//===========================================================================//
function DrawInventoryMenu( Canvas C )
{
    local string        strWeapon[4];
    local Color         TextColor[4];
    local INT           iWeapon;
    local R6Rainbow     playerPawn;
    local Texture       weaponIcon;
    local FLOAT         fPosX;
    local FLOAT         fPosY;
    local FLOAT         fTextSizeX;
    local FLOAT         fTextSizeY;
    local FLOAT         fScaleX;
    local FLOAT         fScaleY;
    local BOOL          bPrimaryGadgetSet;
    local BOOL          bSecondaryGadgetSet;
    local R6EngineWeapon pWeapon;

    if( m_Player == None )
        return;

	if(m_Player.bOnlySpectator || m_Player.bCheatFlying)
		return;

    playerPawn = m_Player.m_Pawn;
    
    // If we don't need, or can't draw the inventory, exit now
    if( playerPawn == None || !bVisible )
        return;

    DrawRoseDesVents( C, m_iCurrentMnuChoice );

    fScaleX = C.SizeX / 800.0f;
    fScaleY = C.SizeY / 600.0f;

    fPosX     = C.SizeX / 2.0f + fScaleX;
    fPosY     = C.SizeY / 2.0f + fScaleY;

    for( iWeapon = 0; iWeapon < 2; iWeapon++ )
    {
        if( playerPawn.m_WeaponsCarried[iWeapon] != None )
        {
            strWeapon[iWeapon] = playerPawn.m_WeaponsCarried[iWeapon].m_WeaponShortName ;
            if (playerPawn.m_WeaponsCarried[iWeapon].HasAmmo())
                TextColor[iWeapon] = m_Player.m_TeamManager.Colors.HUDWhite;
            else
                TextColor[iWeapon] = m_Player.m_TeamManager.Colors.HUDGrey;
        }
        else
        {
            strWeapon[iWeapon] = Localize("MISC","ID_EMPTY","R6Common");
            TextColor[iWeapon] = m_Player.m_TeamManager.Colors.HUDGrey;
        }
    }

    // Check for the 1st gadget

    pWeapon = playerPawn.m_WeaponsCarried[2];
    if ((pWeapon != None) &&
        (pWeapon.HasAmmo()))
    {
        strWeapon[2] = Localize(pWeapon.m_NameID, "ID_NAME", "R6Gadgets");
        bPrimaryGadgetSet = true;
        TextColor[2] = m_Player.m_TeamManager.Colors.HUDWhite;
    }

    // Check for the 2nd gadget
    pWeapon = playerPawn.m_WeaponsCarried[3];

    if ((pWeapon != None) &&
        (pWeapon.HasAmmo()))
    {
        strWeapon[3] = Localize(pWeapon.m_NameID, "ID_NAME", "R6Gadgets");
        bSecondaryGadgetSet = true;
        TextColor[3] = m_Player.m_TeamManager.Colors.HUDWhite;
    }

    // Check for passive object
    if (playerPawn.m_bHasLockPickKit)
    {
        if (!bPrimaryGadgetSet)
        {
            strWeapon[2] = Localize("LOCKPICKKIT", "ID_NAME", "R6Gadgets");
            bPrimaryGadgetSet = true;
            TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;
        }
        else if (!bSecondaryGadgetSet)
        {
            strWeapon[3] = Localize("LOCKPICKKIT", "ID_NAME", "R6Gadgets");
            bSecondaryGadgetSet = true;
            TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
        }
    }

    if (playerPawn.m_bHasDiffuseKit)
    {
        if (!bPrimaryGadgetSet)
        {
            strWeapon[2] = Localize("DIFFUSEKIT", "ID_NAME", "R6Gadgets");
            bPrimaryGadgetSet = true;
            TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;
        }
        else if (!bSecondaryGadgetSet)
        {
            strWeapon[3] = Localize("DIFFUSEKIT", "ID_NAME", "R6Gadgets");
            bSecondaryGadgetSet = true;
            TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
        }
    }

    if (playerPawn.m_bHasElectronicsKit)
    {
        if (!bPrimaryGadgetSet)
        {
            strWeapon[2] = Localize("ELECTRONICKIT", "ID_NAME", "R6Gadgets");
            bPrimaryGadgetSet = true;
            TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;
        }
        else if (!bSecondaryGadgetSet)
        {
            strWeapon[3] = Localize("ELECTRONICKIT", "ID_NAME", "R6Gadgets");
            bSecondaryGadgetSet = true;
            TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
        }
    }

    if (playerPawn.m_bHaveGasMask)
    {
        if (!bPrimaryGadgetSet)
        {
            strWeapon[2] = Localize("GASMASK", "ID_NAME", "R6Gadgets");
            bPrimaryGadgetSet = true;
            TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;
        }
        else if (!bSecondaryGadgetSet)
        {
            strWeapon[3] = Localize("GASMASK", "ID_NAME", "R6Gadgets");
            bSecondaryGadgetSet = true;
            TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
        }
    }
    
    if (!bPrimaryGadgetSet)
    {
        strWeapon[2] = Localize("MISC","ID_EMPTY","R6Common");
        bPrimaryGadgetSet = true;
        TextColor[2] = m_Player.m_TeamManager.Colors.HUDGrey;
    }
    
    if (!bSecondaryGadgetSet)
    {
        strWeapon[3] = Localize("MISC","ID_EMPTY","R6Common");
        bSecondaryGadgetSet = true;
        TextColor[3] = m_Player.m_TeamManager.Colors.HUDGrey;
    }

    fTextSizeX = 75;
    fTextSizeY = 32;

    C.Style = 3; // STY_Translucent
    
    C.UseVirtualSize(false);
    
    for (iWeapon = 0; iWeapon < 4; iWeapon++)
    {
        C.SetDrawColor(TextColor[iWeapon].R,
            TextColor[iWeapon].G,
            TextColor[iWeapon].B,
            TextColor[iWeapon].A);

        switch( iWeapon )
        {
            case 0:
                DrawTextCenteredInBox( C, strWeapon[iWeapon], fPosX - (fTextSizeX * fScaleX / 2.0f), fPosY - (50 + fTextSizeY) * fScaleY,  fTextSizeX * fScaleX, fTextSizeY * fScaleY);
                break;
            case 1:
                DrawTextCenteredInBox( C, strWeapon[iWeapon], fPosX + 35 * fScaleX, fPosY - (fTextSizeY / 2) * fScaleY,  fTextSizeX * fScaleX, fTextSizeY * fScaleY);
                break;
            case 2:
                DrawTextCenteredInBox( C, strWeapon[iWeapon], fPosX - (fTextSizeX *fScaleX / 2.0f), fPosY + 50 * fScaleY,  fTextSizeX * fScaleX, fTextSizeY * fScaleY);
                break;
            case 3:
                DrawTextCenteredInBox( C, strWeapon[iWeapon], fPosX - (35 + fTextSizeX) * fScaleX, fPosY - (fTextSizeY / 2) * fScaleY,  fTextSizeX * fScaleX, fTextSizeY * fScaleY);
                break;
        }
    }

    C.OrgX = 0;
    C.OrgY = 0;
}

defaultproperties
{
     m_ActionKey="InventoryMenu"
}
