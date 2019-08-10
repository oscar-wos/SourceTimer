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
	OPTION_SAVING = 4
}

Admin gA_Admin[MAXPLAYERS + 1];

public Action Command_AddZone(int iClient, int iArgs) {
	if (!Misc_CheckPlayer(iClient, PLAYER_INGAME)) return Plugin_Handled;
	gA_Admin[iClient].Option = OPTION_DRAWING;

	Admin_AddZone(iClient);
	return Plugin_Handled;
}

void Admin_AddZone(int iClient) {
	char[] cBuffer = new char[512];
	Menu mMenu = new Menu(Menu_AddZone);
	mMenu.ExitBackButton = true;

	switch (gA_Admin[iClient].Option) {
		case OPTION_DRAWING: {
			Format(cBuffer, 512, "%s (%s) - %t - %t\n \n", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", "menu_addzone");
			mMenu.SetTitle(cBuffer);

			Format(cBuffer, 512, "%t", "menu_addzone_editp1");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Zone.xPos[0] != 0.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_addzone_editp2");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Zone.yPos[0] != 0.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			mMenu.AddItem("", "", ITEMDRAW_SPACER);

			Format(cBuffer, 512, "%t", "menu_addzone_saveregion");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Zone.xPos[0] != 0.0 && gA_Admin[iClient].Zone.yPos[0] != 0.0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		} case OPTION_EDITP1, OPTION_EDITP2: {
			Format(cBuffer, 512, "%s (%s) - %t - %t\n \n", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", gA_Admin[iClient].Option == OPTION_EDITP1 ? "menu_addzone_editp1" : "menu_addzone_editp2");
			mMenu.SetTitle(cBuffer);

			Format(cBuffer, 512, "%t", "menu_addzone_editx");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Setting != 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_addzone_edity");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Setting != 1 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

			Format(cBuffer, 512, "%t", "menu_addzone_editz");
			mMenu.AddItem("", cBuffer, gA_Admin[iClient].Setting != 2 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
		} case OPTION_SAVING: {
			Format(cBuffer, 512, "%s (%s) - %t - %t\n \n", PLUGIN_NAME, PLUGIN_VERSION, "menu_zone", "menu_addzone_saveregion");
			mMenu.SetTitle(cBuffer);

			switch (gA_Admin[iClient].Zone.Type) {
				case 0: Format(cBuffer, 512, "%t: %t", "menu_addzone_type", "menu_addzone_checkpoint");
				case 1: Format(cBuffer, 512, "%t: %t", "menu_addzone_type", "menu_addzone_start");
				case 2: Format(cBuffer, 512, "%t: %t", "menu_addzone_type", "menu_addzone_end");
			}

			mMenu.AddItem("", cBuffer);

			if (gA_Admin[iClient].Zone.Group == 0) Format(cBuffer, 512, "%t: %t", "menu_addzone_group", "menu_addzone_normal");
			else if (gA_Admin[iClient].Zone.Group > g_Global.Zones.GetTotalZoneGroups()) Format(cBuffer, 512, "%t: %t", "menu_addzone_group", "menu_addzone_bonusnew");
			else Format(cBuffer, 512, "%t: %t %i", "menu_addzone_group", "menu_addzone_bonus", gA_Admin[iClient].Zone.Group);
					
			mMenu.AddItem("", cBuffer);
			mMenu.AddItem("", "", ITEMDRAW_SPACER);

			Format(cBuffer, 512, "%t", "menu_addzone_saveregion");
			mMenu.AddItem("", cBuffer);
		}
	}

	mMenu.Display(iClient, 0);
}

public int Menu_AddZone(Menu mMenu, MenuAction maAction, int iParam1, int iParam2) {
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
						Zone_NewZone(xPos, yPos, gA_Admin[iParam1].Zone.Type, gA_Admin[iParam1].Zone.Group);

						Admin_Clear(iParam1); return;
					}
				}
			}
		}

		Admin_AddZone(iParam1);
	}

	if (maAction == MenuAction_Cancel) {
		if (iParam2 == MenuCancel_ExitBack) {
			switch (gA_Admin[iParam1].Option) {
				case OPTION_DRAWING: Admin_Clear(iParam1);
				case OPTION_EDITP1, OPTION_EDITP2, OPTION_SAVING: { gA_Admin[iParam1].Option = OPTION_DRAWING; Admin_AddZone(iParam1); }
			}
		} else if (iParam2 != MenuCancel_Interrupted) Admin_Clear(iParam1);
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

				if (xPos[0] != 0.0 && yPos[0] != 0.0) {
					Zone_Draw(xPos, yPos, 4, TIMER_INTERVAL, false, i);
				} else if (xPos[0] != 0.0) {
					if (fPos[2] == xPos[2]) fPos[2] += BOX_BOUNDRY;
					Zone_Draw(xPos, fPos, 3, TIMER_INTERVAL, false, i);
				} else if (yPos[0] != 0.0) {
					if (fPos[2] == yPos[2]) fPos[2] += BOX_BOUNDRY;
					Zone_Draw(fPos, yPos, 3, TIMER_INTERVAL, false, i);
				} else {
					Zone_DrawSprite(fPos, 0, 0.1, false, i);
				}
			} case OPTION_SAVING: {
				int iColor = gA_Admin[i].Zone.Type + 5;
				if (gA_Admin[i].Zone.Group > 0) iColor += 3;
				Zone_Draw(xPos, yPos, iColor, TIMER_INTERVAL, false, i);
			}
		}
	}
}

void Admin_Run(int iClient, int iButtons) {
	if (!(iButtons & IN_ATTACK || iButtons & IN_ATTACK2)) return;

	switch (gA_Admin[iClient].Option) {
		case OPTION_EDITP1: gA_Admin[iClient].Zone.xPos[gA_Admin[iClient].Setting] += iButtons & IN_ATTACK ? 0.1 : -0.1;
		case OPTION_EDITP2: gA_Admin[iClient].Zone.yPos[gA_Admin[iClient].Setting] += iButtons & IN_ATTACK ? 0.1 : -0.1;
		case OPTION_DRAWING: {
			float fPos[3];
			Zone_RayTrace(iClient, fPos);

			if (iButtons & IN_ATTACK) gA_Admin[iClient].SetX(fPos);
			else gA_Admin[iClient].SetY(fPos);
			Admin_AddZone(iClient);
		}
	}
}

void Admin_Clear(int iClient) {
	float xPos[3], yPos[3];

	gA_Admin[iClient].Option = 0;
	gA_Admin[iClient].Setting = 0;
	gA_Admin[iClient].SetX(xPos);
	gA_Admin[iClient].SetY(yPos);
	gA_Admin[iClient].Zone.Type = 0;
}