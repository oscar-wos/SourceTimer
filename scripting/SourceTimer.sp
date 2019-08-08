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

// The following to be put into a Config
#define TEXT_DEFAULT "{white}"
#define TEXT_HIGHLIGHT "{lightred}"
#define TEXT_PREFIX "[{blue}Timer{white}] "
#define BOX_BOUNDRY 120.0
#define TIMER_INTERVAL 0.1
#define TIMER_ZONES 16

#define PLUGIN_NAME "Source Timer"
#define PLUGIN_VERSION "0.08"

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <sourcetimer>

Global g_Global;

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

public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] cError, int iError) {
	// CreateNative("Timer")
}

public void OnPluginStart() {
	g_Global = new Global();
	g_Global.Timer = CreateTimer(TIMER_INTERVAL, Timer_Global, _, TIMER_REPEAT);
	// Database.Connect(T_Connect, "sourcetimer");

	ServerCommand("sm_reload_translations");
	LoadTranslations("sourcetimer.phrases");

	RegConsoleCmd("sm_admin", Command_Admin);
	RegConsoleCmd("sm_zone", Command_Zone);
	RegConsoleCmd("sm_addzone", Command_AddZone);
	RegConsoleCmd("sm_test", Command_Test);

	for (int i = 1; i <= MaxClients; i++) {
		g_Global.Players.Resize(i + 1);

		if (!Misc_CheckPlayer(i, PLAYER_INGAME)) { continue; }
		g_Global.Players.Set(i, new Player());
	}
}

public Action Command_Test(int iClient, int iArgs) {
	for (int i = 0; i < 10000; i++) {
		Record rNewRecord = new Record();
		g_Global.Records.Push(rNewRecord);
	}

	PrintToChatAll("%i", g_Global.Records.Length);
}

public void OnMapStart() {
	Misc_PrecacheModels();
}

public void OnClientPostAdminCheck(int iClient) {
	g_Global.Players.Set(iClient, new Player());
}

public void OnClientDisconnect(int iClient) {
	Player pPlayer = g_Global.Players.Get(iClient); pPlayer.C(); delete pPlayer;
}

public Action OnPlayerRunCmd(int iClient, int& iButtons, int& iImpulse, float fVel[3], float fAngles[3], int& iWeapon, int& iSubtype, int& iCmd, int& iTick, int& iSeed, int iMouse[2]) {
	Run_Admin(iClient, iButtons);
}

public Action Timer_Global(Handle hTimer) {
	Timer_Zone();
	Timer_Admin();
}
