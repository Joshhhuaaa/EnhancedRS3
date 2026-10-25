//============================================================================//
//  R6SniperRifle.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//


Class R6SniperRifle extends R6Weapons
    Abstract;

// Joshua - A group package here breaks the texture paths with retail UCC
//#exec OBJ LOAD FILE=..\textures\Inventory_t.utx PACKAGE=Inventory_t.Scope
#exec OBJ LOAD FILE=..\textures\Inventory_t.utx PACKAGE=Inventory_t

defaultproperties
{
     m_eWeaponType=WT_Sniper
     m_eGripType=GRIP_LMG
     m_bBipod=True
     m_fMaxZoom=10.000000
     m_ScopeTexture=Texture'Inventory_t.Scope.ScopeBlurTex'
     m_ShellSingleFireSnd=Sound'CommonSniper.Play_Sniper_SingleShells'
     m_ShellEndFullAutoSnd=Sound'CommonSniper.Play_Sniper_EndShells'
     m_SniperZoomFirstSnd=Sound'CommonSniper.Play_Sniper_Zoom1rst'
     m_SniperZoomSecondSnd=Sound'CommonSniper.Play_Sniper_Zoom2nd'
     m_BipodSnd=Sound'Gadget_Bipod.Play_Bipod_Extraction'
     m_AttachPoint="TagRightHand"
     m_HoldAttachPoint="TagBack"
}
