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
#pragma dynamic 262144

// Config TODO
#define TEXT_DEFAULT "{white}"
#define TEXT_HIGHLIGHT "{lightred}"
#define TEXT_PREFIX "[{blue}Timer{white}] "
#define TIMER_INTERVAL 0.1
#define TIMER_ZONES 16
#define BOX_BOUNDRY 120.0
#define HUD_SHOWPREVIOUS 5.0
#define BOTS_MAX 2

#define PLUGIN_NAME "Source Timer"
#define PLUGIN_VERSION "0.21"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <SourceTimer>

Global g_Global;
Player gP_Player[MAXPLAYERS + 1];
Bot gB_Bot[BOTS_MAX];

#include "SourceTimer/Admin.sp"
#include "SourceTimer/Command.sp"
#include "SourceTimer/Event.sp"
#include "SourceTimer/Hook.sp"
#include "SourceTimer/Misc.sp"
#include "SourceTimer/Replay.sp"
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
	g_Global.Timer = CreateTimer(TIMER_INTERVAL, Timer_Global, _, TIMER_REPEAT && TIMER_FLAG_NO_MAPCHANGE);
	Database.Connect(T_Connect, "sourcetimer");

	ServerCommand("sm_reload_translations");
	LoadTranslations("sourcetimer.phrases");

	for (int i = 1; i <= MaxClients; i++) {
		if (!Misc_CheckPlayer(i, PLAYER_INGAME)) continue;
		gP_Player[i].Checkpoints = new Checkpoints();
		gP_Player[i].RecordCheckpoints = new Checkpoints();
		gP_Player[i].Records = new Records();
		gP_Player[i].Replay = new Replay();

		SDKHook(i, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	}

	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	AddCommandListener(Hook_JoinTeam, "jointeam");

	Admin_Start();
	Command_Start();
	Misc_Start();
	Replay_Start();

	RegConsoleCmd("sm_test", Command_Test);
}

public Action Command_Test(int iClient, int iArgs) {
	SetEntityMoveType(iClient, GetEntityMoveType(iClient) == MOVETYPE_NOCLIP ? MOVETYPE_WALK : MOVETYPE_NOCLIP);
}

public void OnMapStart() {
	Misc_Start();
	Sql_SelectZones();
}

public void OnMapEnd() {
	g_Global.Zones.Clear();
	g_Global.Records.Clear();
	g_Global.Checkpoints.Clear();

	for (int i = 1; i <= MaxClients; i++) {
		if (!Misc_CheckPlayer(i, PLAYER_INGAME)) continue;
		gP_Player[i].Checkpoints.Clear();
		gP_Player[i].RecordCheckpoints.Clear();
		gP_Player[i].Records.Clear();
	}
}

public bool OnClientConnect(int iClient) {
	if (IsFakeClient(iClient)) Replay_BotAdd(iClient);
	return true;
}

public void OnClientPostAdminCheck(int iClient) {
	if (!Misc_CheckPlayer(iClient, PLAYER_VALID)) return;

	gP_Player[iClient].Checkpoints = new Checkpoints();
	gP_Player[iClient].RecordCheckpoints = new Checkpoints();
	gP_Player[iClient].Records = new Records();
	gP_Player[iClient].Replay = new Replay();

	for (int i = 0; i < g_Global.Zones.Length; i++) {
		Zone zZone; g_Global.Zones.GetArray(i, zZone);

		switch (zZone.Type) {
			case ZONE_END: Sql_SelectRecord(iClient, i, zZone.Group);
			case ZONE_CHECKPOINT: Sql_SelectCheckpoint(iClient, i, zZone.Id);
		}
	}

	SDKHook(iClient, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

public void OnClientDisconnect(int iClient) {
	if (!Misc_CheckPlayer(iClient, PLAYER_VALID)) return;

	delete gP_Player[iClient].Checkpoints;
	delete gP_Player[iClient].RecordCheckpoints;
	delete gP_Player[iClient].Records;

	delete gP_Player[iClient].Replay.Frames;
	delete gP_Player[iClient].Replay;

	for (int i = 0; i < g_Global.Zones.Length; i++) {
		Zone zZone; g_Global.Zones.GetArray(i, zZone);
		zZone.RecordIndex[iClient] = -1;
		g_Global.Zones.SetArray(i, zZone);
	}

	SDKUnhook(iClient, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

public Action Timer_Global(Handle hTimer) {
	Admin_Timer();
	Sql_Timer();
	Zone_Timer();
}

public Action OnPlayerRunCmd(int iClient, int& iButtons, int& iImpulse, float fVel[3], float fAngle[3], int& iWeapon, int& iSubtype, int& iCmd, int& iTick, int& iSeed, int iMouse[2]) {
	Admin_Run(iClient, iButtons);
	Misc_Run(iClient);
	Replay_Run(iClient, iButtons, fVel, fAngle);
	Zone_Run(iClient, iButtons);
	return Plugin_Changed;
}