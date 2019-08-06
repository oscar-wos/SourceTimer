public Action Command_Admin(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_INGAME, true)) { return Plugin_Handled; }
	Player pPlayer = g_Global.Players.Get(iClient);
	pPlayer.Admin.Clear();

	Admin_Menu(iClient);
	return Plugin_Handled;
}

void Admin_Menu(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_Admin);

	Format(cBuffer, 512, "%s (%s)", PLUGIN_NAME, PLUGIN_VERSION);
	mMenu.SetTitle(cBuffer);

	mMenu.AddItem("", "", ITEMDRAW_SPACER);

	Format(cBuffer, 512, "%t", "menu_zone");
	mMenu.AddItem("", cBuffer);

	mMenu.Display(iClient, 0);
}

public int Menu_Admin(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	if (maAction == MenuAction_Select) {
		switch (iParam2) {
			case 1: {
				Admin_Zone(iParam1);
			}
		}
	}

	if (maAction == MenuAction_End) { delete mMenu; }
}

public Action Command_Zone(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_INGAME, true)) { return Plugin_Handled; }
	Player pPlayer = g_Global.Players.Get(iClient);
	pPlayer.Admin.Clear();

	Admin_Zone(iClient);
	return Plugin_Handled;
}

void Admin_Zone(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_Zone);
	mMenu.ExitBackButton = true;

	Format(cBuffer, 512, "%s (%s) - %t", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone");
	mMenu.SetTitle(cBuffer);

	mMenu.AddItem("", "", ITEMDRAW_SPACER);

	Format(cBuffer, 512, "%t", "menu_addzone");
	mMenu.AddItem("", cBuffer, Misc_CheckPlayer(iClient, PLAYER_ALIVE) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	Format(cBuffer, 512, "%t", "menu_editzone");
	mMenu.AddItem("", cBuffer, ITEMDRAW_DISABLED);

	Format(cBuffer, 512, "%t", "menu_delzone");
	mMenu.AddItem("", cBuffer, ITEMDRAW_DISABLED);

	mMenu.Display(iClient, 0);
}

public int Menu_Zone(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	if (maAction == MenuAction_Select) {
		Player pPlayer = g_Global.Players.Get(iParam1);

		switch (iParam2) {
			case 1: {
				pPlayer.Admin.Setting = 0;
				pPlayer.Admin.Option = 0;

				Admin_AddZone(iParam1);
			}
			case 2: { }
			case 3: { }
		}
	} else if (maAction == MenuAction_Cancel) {
		if (iParam2 == MenuCancel_ExitBack) Admin_Menu(iParam1);
	}

	if (maAction == MenuAction_End) { delete mMenu; }
}

public Action Command_AddZone(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_ALIVE, true)) { return Plugin_Handled; }
	Player pPlayer = g_Global.Players.Get(iClient);
	pPlayer.Admin.Clear();

	pPlayer.Admin.Setting = 0;
	pPlayer.Admin.Option = 0;

	Admin_AddZone(iClient);
	return Plugin_Handled;
}

void Admin_AddZone(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_AddZone);
	mMenu.ExitBackButton = true;

	Player pPlayer = g_Global.Players.Get(iClient);

	float xPos[3], yPos[3];
	pPlayer.Admin.Zone.GetX(xPos);
	pPlayer.Admin.Zone.GetY(yPos);

	mMenu.AddItem("", "", ITEMDRAW_SPACER);

	switch (pPlayer.Admin.Setting) {
		case 0: {
			Format(cBuffer, 512, "%s (%s) - %t - %t", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", "menu_addzone");
			mMenu.SetTitle(cBuffer);

			Format(cBuffer, 512, "%t", "menu_addzone_editp1");
			mMenu.AddItem("", cBuffer, xPos[0] != 0.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_addzone_editp2");
			mMenu.AddItem("", cBuffer, yPos[0] != 0.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			mMenu.AddItem("", "", ITEMDRAW_SPACER);

			Format(cBuffer, 512, "%t", "menu_addzone_saveregion");
			mMenu.AddItem("", cBuffer, (xPos[0] != 0.0 && yPos[0] != 0.0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		} case 1: {
			Format(cBuffer, 512, "%s (%s) - %t - %t", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", "menu_addzone_saveregion");
			mMenu.SetTitle(cBuffer);

			switch (pPlayer.Admin.Zone.Type) {
				case 0: { Format(cBuffer, 512, "%t: %t", "menu_addzone_type", "menu_addzone_checkpoint"); }
				case 1: { Format(cBuffer, 512, "%t: %t", "menu_addzone_type", "menu_addzone_start"); }
				case 2: { Format(cBuffer, 512, "%t: %t", "menu_addzone_type", "menu_addzone_end"); }
			}

			mMenu.AddItem("", cBuffer);

			if (pPlayer.Admin.Zone.Group == 0) { Format(cBuffer, 512, "%t: %t", "menu_addzone_group", "menu_addzone_normal"); }
			else { Format(cBuffer, 512, "%t: %t %i", "menu_addzone_group", "menu_addzone_bonus", pPlayer.Admin.Zone.Group); }

			mMenu.AddItem("", cBuffer, g_Global.ZoneGroups != 1 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			mMenu.AddItem("", "", ITEMDRAW_SPACER);

			Format(cBuffer, 512, "%t", "menu_addzone_saveregion");
			mMenu.AddItem("", cBuffer);

			Format(cBuffer, 512, "%t", "menu_addzone_bonusnew");
			mMenu.AddItem("", cBuffer);
		} case 2, 3: {
			Format(cBuffer, 512, "%s (%s) - %t - %t", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", pPlayer.Admin.Setting == 2 ? "menu_addzone_editp1" : "menu_addzone_editp2");
			mMenu.SetTitle(cBuffer);

			Format(cBuffer, 512, "%t", "menu_addzone_editx");
			mMenu.AddItem("", cBuffer, pPlayer.Admin.Option != 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_addzone_edity");
			mMenu.AddItem("", cBuffer, pPlayer.Admin.Option != 1 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_addzone_editz");
			mMenu.AddItem("", cBuffer, pPlayer.Admin.Option != 2 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		}
	}

	mMenu.Display(iClient, 0);
}

public int Menu_AddZone(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
	Player pPlayer = g_Global.Players.Get(iParam1);

	if (maAction == MenuAction_Select) {
		float xPos[3], yPos[3];

		pPlayer.Admin.Zone.GetX(xPos);
		pPlayer.Admin.Zone.GetY(yPos);

		if (xPos[2] == yPos[2]) { yPos[2] += BOX_BOUNDRY; pPlayer.Admin.Zone.SetY(yPos); }
		switch (pPlayer.Admin.Setting) {
			case 0: {
				switch (iParam2) {
					case 1: { pPlayer.Admin.Setting = 2;}
					case 2: { pPlayer.Admin.Setting = 3; }
					case 4: { pPlayer.Admin.Setting = 1; pPlayer.Admin.Zone.Type = 0; pPlayer.Admin.Zone.Group = g_Global.ZoneGroups - 1; }
				}
			} case 1: {
				switch (iParam2) {
					case 1: { pPlayer.Admin.Zone.Type = Misc_CalculateZoneType(pPlayer.Admin.Zone.Type + 1); }
					case 2: { pPlayer.Admin.Zone.Group = Misc_CalculateZoneGroup(pPlayer.Admin.Zone.Group + 1); }
					case 4: { Zone_SaveZone(iParam1); pPlayer.Admin.Clear(); return; }
					case 5: { pPlayer.Admin.Zone.Group = g_Global.ZoneGroups++; }
				}
			} case 2, 3: { pPlayer.Admin.Option = iParam2 - 1; }
		}

		Admin_AddZone(iParam1);
	}

	if (maAction == MenuAction_Cancel) {
		if (iParam2 == MenuCancel_ExitBack) {
			switch (pPlayer.Admin.Setting) {
				case 0: { pPlayer.Admin.Setting = -1; pPlayer.Admin.Option = -1; Admin_Zone(iParam1); }
				case 1, 2, 3: { pPlayer.Admin.Setting = 0; pPlayer.Admin.Option = 0; Admin_AddZone(iParam1);}
			}
		} else if (iParam2 == MenuCancel_Exit) { pPlayer.Admin.Clear(); }
	}

	if (maAction == MenuAction_End) { delete mMenu; }
}

void Timer_Admin() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!Misc_CheckPlayer(i, PLAYER_INGAME)) { continue; }

		Player pPlayer = g_Global.Players.Get(i);
		if (pPlayer.Admin.Setting == -1) { continue; }

		float xPos[3], yPos[3];

		pPlayer.Admin.Zone.GetX(xPos);
		pPlayer.Admin.Zone.GetY(yPos);

		if (xPos[0] != 0.0 && yPos[0] != 0.0) {
			if (xPos[2] == yPos[2]) { yPos[2] += BOX_BOUNDRY; }
			Zone_DrawSprite(xPos, 0, 0.5, false, i);
			Zone_DrawSprite(yPos, 1, 0.5, false, i);
		}

		switch (pPlayer.Admin.Setting) {
			case 0: {
				float fPos[3];
				Zone_RayTrace(i, fPos);

				if (xPos[0] != 0.0 && yPos[0] != 0.0) {
					if (xPos[2] == yPos[2]) { yPos[2] += BOX_BOUNDRY; }
					Zone_Draw(xPos, yPos, 4, TIMER_INTERVAL, false, i);
				} else if (xPos[0] != 0.0) {
					if (fPos[2] == xPos[2]) { fPos[2] += BOX_BOUNDRY; }
					Zone_Draw(xPos, fPos, 3, TIMER_INTERVAL, false, i);
				} else if (yPos[0] != 0.0) {
					if (fPos[2] == yPos[2]) { fPos[2] += BOX_BOUNDRY; }
					Zone_Draw(fPos, yPos, 3, TIMER_INTERVAL, false, i);
				} else {
					Zone_DrawSprite(fPos, 0, 0.1, false, i);
				}
			} case 1: {
				int iColor = pPlayer.Admin.Zone.Type + 5;
				if (pPlayer.Admin.Zone.Group > 0) { iColor += 3; }

				Zone_Draw(xPos, yPos, iColor, TIMER_INTERVAL, false, i);
			}
			case 2: { Zone_DrawAdmin(i, xPos); }
			case 3: { Zone_DrawAdmin(i, yPos); }
		}
	}
}
