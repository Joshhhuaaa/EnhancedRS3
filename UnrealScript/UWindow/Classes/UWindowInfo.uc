//=============================================================================
//  UWindowInfo.uc : Additionnal official informations for mission pack, publicity, etc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/24  * Create by Yannick Joly
//=============================================================================
class UWindowInfo extends Object
	Config(R6Info);

// mod/mission pack publicity
var config Array<string>				m_AModsInfo;

defaultproperties
{
     m_AModsInfo(0)="RavenShield"
     m_AModsInfo(1)="AthenaSword"
}
