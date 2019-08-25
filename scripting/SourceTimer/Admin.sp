enum struct Admin {
	int Option;
	int Setting;
	Zone Zone;

	void GetX(float fPos[3]) {
		for (int i = 0; i < 3; i++) fPos[i] = this.Zone.xPos[i];
	}

	void GetY(float fPos[3]) {
		for (int i = 0; i < 3; i++) fPos[i] = this.Zone.yPos[i];
	}

	void SetX(float fPos[3]) {
		for (int i = 0; i < 3; i++) this.Zone.xPos[i] = fPos[i];
	}

	void SetY(float fPos[3]) {
		for (int i = 0; i < 3; i++) this.Zone.yPos[i] = fPos[i];
	}
}

enum {
	OPTION_DRAWING = 1,
	OPTION_EDITP1 = 2,
	OPTION_EDITP2 = 3,
	OPTION_SAVING = 4,
	OPTION_EDITING = 5,
	OPTION_DELETING = 6
}

Admin gA_Admin[MAXPLAYERS + 1];

void Admin_Start() {
	RegAdminCmd("sm_admin", Command_Admin, ADMFLAG_ROOT);
	RegAdminCmd("sm_zone", Command_Zone, ADMFLAG_ROOT);
	RegAdminCmd("sm_addzone", Command_AddZone, ADMFLAG_ROOT);
	RegAdminCmd("sm_editzone", Command_EditZone, ADMFLAG_ROOT);
	RegAdminCmd("sm_deletezone", Command_DeleteZone, ADMFLAG_ROOT);
}

public Action Command_Admin(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_VALID)) return Plugin_Handled;

	Admin_Clear(iClient);
	Admin_Admin(iClient);
	return Plugin_Handled;
}

void Admin_Admin(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_Admin);

	Format(cBuffer, 512, "%s (%s) - %t\n \n", PLUGIN_NAME, PLUGIN_VERSION, "menu_admin");
	mMenu.SetTitle(cBuffer);

	Format(cBuffer, 512, "%t", "menu_zone");
	mMenu.AddItem("", cBuffer, Misc_CheckPlayer(iClient, PLAYER_INGAME) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	mMenu.Display(iClient, 0);
}

int Menu_Admin(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	if (maAction == MenuAction_Select) {
		switch (iParam2) {
			case 0: Admin_Zone(iParam1);
		}
	}

	if (maAction == MenuAction_End) delete mMenu;
}

public Action Command_Zone(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_INGAME)) return Plugin_Handled;

	Admin_Clear(iClient);
	Admin_Zone(iClient);
	return Plugin_Handled;
}

void Admin_Zone(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_Zone);
	mMenu.ExitBackButton = true;

	Format(cBuffer, 512, "%s (%s) - %t\n \n", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone");
	mMenu.SetTitle(cBuffer);

	Format(cBuffer, 512, "%t", "menu_addzone");
	mMenu.AddItem("", cBuffer);

	Format(cBuffer, 512, "%t", "menu_editzone");
	mMenu.AddItem("", cBuffer, g_Global.Zones.Length != 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	Format(cBuffer, 512, "%t", "menu_deletezone");
	mMenu.AddItem("", cBuffer, g_Global.Zones.Length != 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	mMenu.Display(iClient, 0);
}

int Menu_Zone(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	if (maAction == MenuAction_Select) {
		switch (iParam2) {
			case 0: { gA_Admin[iParam1].Option = OPTION_DRAWING; Admin_Zoning(iParam1); }
			case 1: { gA_Admin[iParam1].Option = OPTION_EDITING; Admin_Editing(iParam1); }
			case 2: { gA_Admin[iParam1].Option = OPTION_DELETING; Admin_Editing(iParam1); }
		}
	}

	if (maAction == MenuAction_Cancel) {
		if (iParam2 == MenuCancel_ExitBack) Admin_Admin(iParam1);
	}

	if (maAction == MenuAction_End) delete mMenu;
}

public Action Command_AddZone(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_ALIVE)) return Plugin_Handled;

	Admin_Clear(iClient);
	gA_Admin[iClient].Option = OPTION_DRAWING;
	Admin_Zoning(iClient);
	return Plugin_Handled;
}

void Admin_Zoning(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_Zoning);
	mMenu.ExitBackButton = true;

	switch (gA_Admin[iClient].Option) {
		case OPTION_DRAWING: {
			Format(cBuffer, 512, "%s (%s) - %t - %t\n \n", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", gA_Admin[iClient].Zone.Id == 0 ? "menu_addzone" : "menu_editzone");
			mMenu.SetTitle(cBuffer);

			Format(cBuffer, 512, "%t", "menu_zoning_editp1");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Zone.xPos[0] != 0.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_zoning_editp2");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Zone.yPos[0] != 0.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			mMenu.AddItem("", "", ITEMDRAW_SPACER);

			Format(cBuffer, 512, "%t", gA_Admin[iClient].Zone.Id == 0 ? "menu_saveregion" : "menu_updateregion");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Zone.xPos[0] != 0.0 && gA_Admin[iClient].Zone.yPos[0] != 0.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		} case OPTION_EDITP1, OPTION_EDITP2: {
			Format(cBuffer, 512, "%s (%s) - %t - %t\n \n", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", gA_Admin[iClient].Option == OPTION_EDITP1 ? "menu_zoning_editp1" : "menu_zoning_editp2");
			mMenu.SetTitle(cBuffer);

			Format(cBuffer, 512, "%t", "menu_zoning_editx");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Setting != 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_zoning_edity");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Setting != 1 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_zoning_editz");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Setting != 2 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		} case OPTION_SAVING: {
			Format(cBuffer, 512, "%s (%s) - %t - %t\n \n", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", gA_Admin[iClient].Zone.Id == 0 ? "menu_saveregion" : "menu_updateregion");
			mMenu.SetTitle(cBuffer);

			switch (gA_Admin[iClient].Zone.Type) {
				case ZONE_CHECKPOINT: Format(cBuffer, 512, "%t: %t", "menu_type", "menu_checkpoint");
				case ZONE_START: Format(cBuffer, 512, "%t: %t", "menu_type", "menu_start");
				case ZONE_END: Format(cBuffer, 512, "%t: %t", "menu_type", "menu_end");
			}

			mMenu.AddItem("", cBuffer);

			if (gA_Admin[iClient].Zone.Group == 0) Format(cBuffer, 512, "%t: %t", "menu_group", "menu_normal");
			else if (gA_Admin[iClient].Zone.Group > g_Global.Zones.GetTotalZoneGroups()) Format(cBuffer, 512, "%t: %t", "menu_group", "menu_newbonus");
			else Format(cBuffer, 512, "%t: %t %i", "menu_group", "menu_bonus", gA_Admin[iClient].Zone.Group);
			
			mMenu.AddItem("", cBuffer);
			mMenu.AddItem("", "", ITEMDRAW_SPACER);

			Format(cBuffer, 512, "%t", gA_Admin[iClient].Zone.Id == 0 ? "menu_saveregion" : "menu_updateregion");
			mMenu.AddItem("", cBuffer);
		}
	}

	mMenu.Display(iClient, 0);
}

int Menu_Zoning(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	if (maAction == MenuAction_Select) {
		if (gA_Admin[iParam1].Zone.xPos[2] == gA_Admin[iParam1].Zone.yPos[2]) gA_Admin[iParam1].Zone.yPos[2] += BOX_BOUNDRY;
		switch (gA_Admin[iParam1].Option) {
			case OPTION_EDITP1, OPTION_EDITP2: gA_Admin[iParam1].Setting = iParam2;
			case OPTION_DRAWING: {
				switch (iParam2) {
					case 0: gA_Admin[iParam1].Option = OPTION_EDITP1;
					case 1: gA_Admin[iParam1].Option = OPTION_EDITP2;
					case 3: gA_Admin[iParam1].Option = OPTION_SAVING;
				}
			} case OPTION_SAVING: {
				switch (iParam2) {
					case 0: gA_Admin[iParam1].Zone.Type = Misc_CalculateZoneType(gA_Admin[iParam1].Zone.Type + 1);
					case 1: gA_Admin[iParam1].Zone.Group = Misc_CalculateZoneGroup(gA_Admin[iParam1].Zone.Group + 1);
					case 3: {
						float xPos[3], yPos[3];

						gA_Admin[iParam1].GetX(xPos);
						gA_Admin[iParam1].GetY(yPos);
						Zone_New(xPos, yPos, gA_Admin[iParam1].Zone.Type, gA_Admin[iParam1].Zone.Group, gA_Admin[iParam1].Zone.Id);
						Admin_Clear(iParam1); return;
					}
				}
			}
		}
		Admin_Zoning(iParam1);
	}

	if (maAction == MenuAction_Cancel) {
		if (iParam2 == MenuCancel_ExitBack) {
			switch (gA_Admin[iParam1].Option) {
				case OPTION_EDITP1, OPTION_EDITP2, OPTION_SAVING: { gA_Admin[iParam1].Option = OPTION_DRAWING; Admin_Zoning(iParam1); }
				case OPTION_DRAWING: {
					int iZoneId = gA_Admin[iParam1].Zone.Id;
					Admin_Clear(iParam1);
					if (iZoneId == 0) Admin_Zone(iParam1);
					else {
						gA_Admin[iParam1].Option = OPTION_EDITING;
						Admin_Editing(iParam1);
					}
				} 
			}
		} else if (iParam2 != MenuCancel_Interrupted) Admin_Clear(iParam1);
	}

	if (maAction == MenuAction_End) delete mMenu;
}

public Action Command_EditZone(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_ALIVE)) return Plugin_Handled;
	if (!Admin_CheckZones(iClient)) return Plugin_Handled;

	Admin_Clear(iClient);
	gA_Admin[iClient].Option = OPTION_EDITING;
	Admin_Editing(iClient);
	return Plugin_Handled;
}

public Action Command_DeleteZone(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_ALIVE)) return Plugin_Handled;
	if (!Admin_CheckZones(iClient)) return Plugin_Handled;

	Admin_Clear(iClient);
	gA_Admin[iClient].Option = OPTION_DELETING;
	Admin_Editing(iClient);
	return Plugin_Handled;
}

void Admin_Editing(int iClient, int iDisplay = 0) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_Editing);
	mMenu.ExitBackButton = true;

	Format(cBuffer, 512, "%s (%s) - %t - %t\n \n", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", gA_Admin[iClient].Option == OPTION_EDITING ? "menu_editzone" : "menu_deletezone");
	mMenu.SetTitle(cBuffer);

	for (int i = 0; i < g_Global.Zones.Length; i++) {
		if ((i % 4) == 0) {
			Format(cBuffer, 512, "%t", gA_Admin[iClient].Option == OPTION_EDITING ? "menu_editselectzone" : "menu_deleteselectzone");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Zone.Id != 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
			mMenu.AddItem("", "", ITEMDRAW_SPACER);
		}

		Zone zZone;
		g_Global.Zones.GetArray(i, zZone);

		if (zZone.Group == 0) Format(cBuffer, 512, "%t: %t", "menu_group", "menu_normal");
		else Format(cBuffer, 512, "%t: %t %i", "menu_group", "menu_bonus", zZone.Group);

		switch (zZone.Type) {
			case ZONE_CHECKPOINT: Format(cBuffer, 512, "%s %t: %t", cBuffer, "menu_type", "menu_checkpoint");
			case ZONE_START: Format(cBuffer, 512, "%s %t: %t", cBuffer, "menu_type", "menu_start");
			case ZONE_END: Format(cBuffer, 512, "%s %t: %t", cBuffer, "menu_type", "menu_end");
		}

		Format(cBuffer, 512, "ID: %i - %s", zZone.Id, cBuffer);
		mMenu.AddItem("", cBuffer, gA_Admin[iClient].Zone.Id != zZone.Id ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	}

	mMenu.DisplayAt(iClient, (iDisplay / 6) * 6, 0);
}

int Menu_Editing(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	if (maAction == MenuAction_Select) {
		if (iParam2 % 6 == 0) {
			if (gA_Admin[iParam1].Option == OPTION_DELETING) Admin_DeleteZone(iParam1);
			else {
				gA_Admin[iParam1].Option = OPTION_DRAWING;
				Admin_Zoning(iParam1);
			}
		} else {
			float xPos[3], yPos[3], fCentre[3];
			int iIndex = ((iParam2 / 6) * 4) + ((iParam2 % 6) - 2);
			Zone zZone;

			g_Global.Zones.GetArray(iIndex, zZone);
			zZone.GetX(xPos);
			zZone.GetY(yPos);

			gA_Admin[iParam1].SetX(xPos);
			gA_Admin[iParam1].SetY(yPos);
			gA_Admin[iParam1].Zone.Type = zZone.Type;
			gA_Admin[iParam1].Zone.Group = zZone.Group;
			gA_Admin[iParam1].Zone.Id = zZone.Id;

			Misc_CalculateCentre(xPos, yPos, fCentre);
			TeleportEntity(iParam1, fCentre, NULL_VECTOR, NULL_VECTOR);
			Admin_Editing(iParam1, iParam2);
		}
	}

	if (maAction == MenuAction_Cancel) {
		if (iParam2 == MenuCancel_ExitBack) Admin_Zone(iParam1);
		Admin_Clear(iParam1);
	}

	if (maAction == MenuAction_End) delete mMenu;
}

void Admin_DeleteZone(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_Delete);

	Format(cBuffer, 512, "%s (%s) - %t - %t\n \n", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", "menu_deletezone");
	mMenu.SetTitle(cBuffer);

	Format(cBuffer, 512, "%t", "menu_no");
	mMenu.AddItem("", cBuffer);

	Format(cBuffer, 512, "%t", "menu_yes");
	mMenu.AddItem("", cBuffer);

	mMenu.Display(iClient, 0);
}

int Menu_Delete(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	if (maAction == MenuAction_Select) {
		if (iParam2 == 1) {
			Zone_DeleteZone(gA_Admin[iParam1].Zone.Id);
			Sql_DeleteZone(gA_Admin[iParam1].Zone.Id);
			Admin_Clear(iParam1);
			Zone_Reload();
		}
	}

	if (maAction == MenuAction_End) delete mMenu;
}

void Admin_Timer() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!Misc_CheckPlayer(i, PLAYER_INGAME)) continue;
		float xPos[3], yPos[3];
		gA_Admin[i].GetX(xPos);
		gA_Admin[i].GetY(yPos);

		if (xPos[0] != 0.0 && yPos[0] != 0.0) {
			if (xPos[2] == yPos[2]) yPos[2] += BOX_BOUNDRY;
			Zone_DrawSprite(xPos, 0, 0.5, false, i);
			Zone_DrawSprite(yPos, 1, 0.5, false, i);
		}

		switch (gA_Admin[i].Option) {
			case OPTION_EDITP1: Zone_DrawAdmin(i, xPos);
			case OPTION_EDITP2: Zone_DrawAdmin(i, yPos);
			case OPTION_DRAWING: {
				float fPos[3];
				Zone_RayTrace(i, fPos);
				Zone_DrawSprite(fPos, 0, 0.1, false, i);

				if (xPos[0] != 0.0 && yPos[0] != 0.0) {
					Zone_Draw(xPos, yPos, 4, TIMER_INTERVAL, false, i);
				} else if (xPos[0] != 0.0) {
					if (fPos[2] == xPos[2]) fPos[2] += BOX_BOUNDRY;
					Zone_Draw(xPos, fPos, 3, TIMER_INTERVAL, false, i);
				} else if (yPos[0] != 0.0) {
					if (fPos[2] == yPos[2]) fPos[2] += BOX_BOUNDRY;
					Zone_Draw(fPos, yPos, 3, TIMER_INTERVAL, false, i);
				}
			} case OPTION_SAVING: {
				int iColor = gA_Admin[i].Zone.Type + 5;
				if (gA_Admin[i].Zone.Group > 0) iColor += 3;
				Zone_Draw(xPos, yPos, iColor, TIMER_INTERVAL, false, i);
			}
		}
	}
}

Action Admin_Run(int iClient, int iButtons) {
	if (!(iButtons & IN_ATTACK || iButtons & IN_ATTACK2)) return;

	switch (gA_Admin[iClient].Option) {
		case OPTION_EDITP1: gA_Admin[iClient].Zone.xPos[gA_Admin[iClient].Setting] += iButtons & IN_ATTACK ? 0.1 : -0.1;
		case OPTION_EDITP2: gA_Admin[iClient].Zone.yPos[gA_Admin[iClient].Setting] += iButtons & IN_ATTACK ? 0.1 : -0.1;
		case OPTION_DRAWING: {
			float fPos[3];
			Zone_RayTrace(iClient, fPos);

			if (iButtons & IN_ATTACK) gA_Admin[iClient].SetX(fPos);
			else gA_Admin[iClient].SetY(fPos);
			Admin_Zoning(iClient);
		}
	}
}

void Admin_Clear(int iClient) {
	gA_Admin[iClient].Option = 0;
	gA_Admin[iClient].Setting = 0;
	gA_Admin[iClient].SetX(NULL_VECTOR);
	gA_Admin[iClient].SetY(NULL_VECTOR);
	gA_Admin[iClient].Zone.Type = 0;
	gA_Admin[iClient].Zone.Id = 0;
}

bool Admin_CheckZones(int iClient) {
	if (g_Global.Zones.Length > 0) return true;
	char[] cBuffer = new char[512];

	Format(cBuffer, 512, "%s%s%t", TEXT_PREFIX, TEXT_DEFAULT, "check_zones", TEXT_HIGHLIGHT, g_Global.Zones.Length, TEXT_DEFAULT);
	Timer_CommandReply(iClient, cBuffer);
	return false;
}