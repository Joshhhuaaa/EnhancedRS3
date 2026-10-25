//=============================================================================
//  R6WindowListBoxAnchorButton.uc : These button will allow us 
//                                      to make a list box automaticly
//                                      scroll to a AnchoredElement element
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/22 * Created by Alexandre Dionne
//=============================================================================


class R6WindowListBoxAnchorButton extends R6WindowButton;


var R6WindowListBoxItem AnchoredElement;

defaultproperties
{
     bUseRegion=True
     UpTexture=Texture'R6MenuTextures.Tab_Icon00'
     DownTexture=Texture'R6MenuTextures.Tab_Icon00'
     DisabledTexture=Texture'R6MenuTextures.Tab_Icon00'
     OverTexture=Texture'R6MenuTextures.Tab_Icon00'
}
