/* Source Timer
*
* Copyright (C) 2019 Oscar Wos // github.com/OSCAR-WOS | theoscar@protonmail.com
*
* This program is free software: you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the Free
* Software Foundation, either version 3 of the License, or (at your option)
* any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this program. If not, see http://www.gnu.org/licenses/.
*/

// Compiler Info: Pawn 1.10 - build 6434
#pragma semicolon 1
#pragma newdecls required

// Config TODO
#define TEXT_DEFAULT "{white}"
#define TEXT_HIGHLIGHT "{lightred}"
#define TEXT_PREFIX "[{blue}Timer{white}] "
#define TIMER_INTERVAL 0.1
#define TIMER_ZONES 16
#define BOX_BOUNDRY 120.0
#define HUD_SHOWPREVIOUS 5.0

#define PLUGIN_NAME "Source Timer"
#define PLUGIN_VERSION "0.15"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <SourceTimer>

Global g_Global;
Player gP_Player[MAXPLAYERS + 1];

#include "SourceTimer/Admin.sp"
#include "SourceTimer/Misc.sp"
#include "SourceTimer/Sql.sp"
#include "SourceTimer/Zone.sp"

public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = "Oscar Wos (OSWO)",
	description = "A timer used for recording player times on skill based maps",
	version = PLUGIN_VERSION,
	url = "https://github.com/OSCAR-WOS/SourceTimer / https://steamcommunity.com/id/OSWO",
}

public void OnPluginStart() {
	g_Global = new Global();
	g_Global.Timer = CreateTimer(TIMER_INTERVAL, Timer_Global, _, TIMER_REPEAT);
	Database.Connect(T_Connect, "sourcetimer");

	ServerCommand("sm_reload_translations");
	LoadTranslations("sourcetimer.phrases");

	RegConsoleCmd("sm_addzone", Command_AddZone);
	RegConsoleCmd("sm_editzone", Command_EditZone);
	RegConsoleCmd("sm_deletezone", Command_DeleteZone);
	RegConsoleCmd("sm_test", Command_Test);

	for (int i = 1; i <= MaxClients; i++) {
		if (!Misc_CheckPlayer(i, PLAYER_INGAME)) continue;
		gP_Player[i].Checkpoints = new Checkpoints();
		gP_Player[i].RecordCheckpoints = new Checkpoints();
		gP_Player[i].Records = new Records();

		if (!Misc_CheckPlayer(i, PLAYER_ALIVE)) continue;
	}
}

public Action Command_Test(int iClient, int iArgs) {

}

public void OnMapStart() {
	Misc_PrecacheModels();
}

public void OnClientPostAdminCheck(int iClient) {
	gP_Player[iClient].Checkpoints = new Checkpoints();
	gP_Player[iClient].RecordCheckpoints = new Checkpoints();
	gP_Player[iClient].Records = new Records();
}

public void OnClientDisconnect(int iClient) {
	delete gP_Player[iClient].Checkpoints;
	delete gP_Player[iClient].RecordCheckpoints;
	delete gP_Player[iClient].Records;
}

public Action Timer_Global(Handle hTimer) {
	Admin_Timer();
	Sql_Timer();
	Zone_Timer();
}

public Action OnPlayerRunCmd(int iClient, int& iButtons, int& iImpulse, float fVel[3], float fAngles[3], int& iWeapon, int& iSubtype, int& iCmd, int& iTick, int& iSeed, int iMouse[2]) {
	Admin_Run(iClient, iButtons);
	Zone_Run(iClient, iButtons);
	return Plugin_Changed;
}