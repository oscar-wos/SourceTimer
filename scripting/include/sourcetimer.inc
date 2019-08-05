#define PLAYER_VALID 0
#define PLAYER_INGAME 1
#define PLAYER_ALIVE 2

#define ZONES_TOTAL 3

#define COLORS_MAX 19

// csgocolors.inc - Author: exvel, Editor: Popoklopsi, Powerlord, Zipcore, Bara
#define MAX_MESSAGE_LENGTH 250

char C_Tags[][] = {
	"{default}",
	"{white}",
	"{darkred}",
	"{green}",
	"{lightyellow}",
	"{lightblue}",
	"{olive}",
	"{lime}",
	"{red}",
	"{purple}",
	"{grey}",
	"{yellow}",
	"{orange}",
	"{silver}",
	"{blue}",
	"{darkblue}",
	"{bluegrey}",
	"{magenta}",
	"{lightred}"
}

char C_TagCodes[][] = {
	"\x01",
	"\x01",
	"\x02",
	"\x04",
	"\x03",
	"\x03",
	"\x05",
	"\x06",
	"\x07",
	"\x03",
	"\x08",
	"\x09",
	"\x10",
	"\x0A",
	"\x0B",
	"\x0C",
	"\x0D",
	"\x0E",
	"\x0F"
}

int C_Colors[][] = {
	{ 255, 0, 0, 255 }, // Red
	{ 0, 255, 0, 255 }, // Green
	{ 0, 0, 255, 255 }, // Blue
	{ 255, 255, 127, 255 }, // Admin Zoning In-Progress
	{ 0, 255, 127, 255 }, // Admin Zoning Complete
	{ 255, 127, 0, 255 }, // N Checkpoint
	{ 0, 255, 0, 255 }, // N Start
	{ 255, 0, 0, 255 }, // N End
	{ 200, 100, 0, 255 }, // B Checkpoint
	{ 23, 150, 102, 255 }, // B Start
	{ 153, 0, 153, 255 } // B End
}

stock void Timer_CommandReply(int iClient, const char[] cMessage, any ...) {
	char[] cCMessage = new char[MAX_MESSAGE_LENGTH];

	SetGlobalTransTarget(iClient);
	VFormat(cCMessage, MAX_MESSAGE_LENGTH, cMessage, 3);
	ChangeTags(cCMessage, MAX_MESSAGE_LENGTH);

	if (iClient == 0 || GetCmdReplySource() == SM_REPLY_TO_CONSOLE) { RemoveTags(cCMessage, MAX_MESSAGE_LENGTH); }

	if (iClient == 0) { PrintToServer(cCMessage); }
	else if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE) { PrintToConsole(iClient, cCMessage); }
	else { PrintToChat(iClient, cCMessage); }
}

void ChangeTags(char[] cMessage, int iLength) {
	for (int i = 0; i < COLORS_MAX; i++) { ReplaceString(cMessage, iLength, C_Tags[i], C_TagCodes[i]); }
}

void RemoveTags(char[] cMessage, int iLength) {
	for (int i = 0; i < COLORS_MAX; i++) { ReplaceString(cMessage, iLength, C_TagCodes[i], ""); }
}

methodmap Models < StringMap {
	public Models() {
		StringMap smMap = new StringMap();
		smMap.SetValue("blueglow", PrecacheModel("sprites/blueglow1.vmt"));
		smMap.SetValue("redglow", PrecacheModel("sprites/purpleglow1.vmt"));
		smMap.SetValue("laser", PrecacheModel("materials/sprites/laserbeam.vmt"));
		smMap.SetValue("glow", PrecacheModel("materials/sprites/glow01.vmt"));
		smMap.SetValue("zone", PrecacheModel("models/error.mdl"));

		return view_as<Models>(smMap);
	}

	property int BlueGlow {
		public get() {
			int iIndex;
			this.GetValue("blueglow", iIndex);

			return iIndex;
		}
	}

	property int RedGlow {
		public get() {
			int iIndex;
			this.GetValue("redglow", iIndex);

			return iIndex;
		}
	}

	property int Laser {
		public get() {
			int iIndex;
			this.GetValue("laser", iIndex);

			return iIndex;
		}
	}

	property int Glow {
		public get() {
			int iIndex;
			this.GetValue("glow", iIndex);

			return iIndex;
		}
	}

	property int Zone {
		public get() {
			int iZone;
			this.GetValue("zone", iZone);

			return iZone;
		}
	}
}

methodmap Zone < StringMap {
	public Zone() {
		StringMap smMap = new StringMap();
		smMap.SetArray("x", {0.0, 0.0, 0.0}, 3);
		smMap.SetArray("y", {0.0, 0.0, 0.0}, 3);

		smMap.SetValue("id", -1);
		smMap.SetValue("type", -1);
		smMap.SetValue("group", -1);

		return view_as<Zone>(smMap);
	}

	public void GetX(float[] xPos) {
		this.GetArray("x", xPos, 3);
	}

	public void GetY(float[] yPos) {
		this.GetArray("y", yPos, 3);
	}

	public void SetX(const float[] xPos) {
		this.SetArray("x", xPos, 3);
	}

	public void SetY(const float[] yPos) {
		this.SetArray("y", yPos, 3);
	}

	property int Id {
		public get() {
			int iId;
			this.GetValue("id", iId);

			return iId;
		}

		public set(int iId) {
			this.SetValue("id", iId);
		}
	}

	property int Type {
		public get() {
			int iType;
			this.GetValue("type", iType);

			return iType;
		}

		public set(int iType) {
			this.SetValue("type", iType);
		}
	}

	property int Group {
		public get() {
			int iGroup;
			this.GetValue("group", iGroup);

			return iGroup;
		}

		public set(int iGroup) {
			this.SetValue("group", iGroup);
		}
	}

	property int Entity {
		public get() {
			int iEntity;
			this.GetValue("entity", iEntity);

			return iEntity;
		}

		public set(int iEntity) {
			this.SetValue("entity", iEntity);
		}
	}
}

methodmap Admin < StringMap {
	public Admin() {
		StringMap smMap = new StringMap();
		smMap.SetValue("zone", new Zone());

		smMap.SetValue("setting", -1);
		smMap.SetValue("option", -1);

		return view_as<Admin>(smMap);
	}

	public void Clear() {
		Zone zZone;
		this.GetValue("zone", zZone);

		this.SetValue("zone", new Zone());
		this.SetValue("setting", -1);
		this.SetValue("option", -1);

		delete zZone;
	}

	property Zone Zone {
		public get() {
			Zone zZone;
			this.GetValue("zone", zZone);

			return zZone;
		}

		public set(Zone zZone) {
			this.GetValue("zone", zZone);
		}
	}

	property int Setting {
		public get() {
			int iSetting;
			this.GetValue("setting", iSetting);

			return iSetting;
		}

		public set(int iSetting) {
			this.SetValue("setting", iSetting);
		}
	}

	property int Option {
		public get() {
			int iOption;
			this.GetValue("option", iOption);

			return iOption;
		}

		public set(int iOption) {
			this.SetValue("option", iOption);
		}
	}
}

methodmap Player < StringMap {
	public Player() {
		StringMap smMap = new StringMap();
		smMap.SetValue("admin", new Admin());

		smMap.SetValue("starttime", -1);
		smMap.SetValue("zonetype", -1);
		smMap.SetValue("zonegroup", -1);

		return view_as<Player>(smMap);
	}

	public void ClearAdmin() {
		Admin aAdmin;
		this.GetValue("admin", aAdmin);
		aAdmin.Clear();

		this.SetValue("admin", new Admin());
		delete aAdmin;
	}

	public void Clear() {
		this.ClearAdmin();

		this.SetValue("starttime", -1);
		this.SetValue("zonetype", -1);
		this.SetValue("zonegroup", -1);
	}

	property Admin Admin {
		public get() {
			Admin aAdmin;
			this.GetValue("admin", view_as<Admin>(aAdmin));

			return aAdmin;
		}

		public set(Admin aAdmin) {
			this.SetValue("admin", aAdmin);
		}
	}

	property float StartTime {
		public get() {
			float fStartTime;
			this.GetValue("starttime", fStartTime);

			return fStartTime;
		}

		public set(float fStartTime) {
			this.SetValue("starttime", fStartTime);
		}
	}

	property int ZoneType {
		public get() {
			int iZoneType;
			this.GetValue("zonetype", iZoneType);

			return iZoneType;
		}

		public set(int iZoneType) {
			this.SetValue("zonetype", iZoneType);
		}
	}

	property int ZoneGroup {
		public get() {
			int iZoneGroup;
			this.GetValue("zonegroup", iZoneGroup);

			return iZoneGroup;
		}

		public set(int iZoneGroup) {
			this.SetValue("zonegroup", iZoneGroup);
		}
	}
}

methodmap Zones < ArrayList {
	public Zones() { return view_as<Zones>(new ArrayList()); }

	public void CalculateCentre(float xPos[3], float yPos[3], float fCentre[3]) {
		for (int i = 0; i < 3; i++) { fCentre[i] = (xPos[i] + yPos[i]) / 2; }
	}

	public void CalculateSpawn(float xPos[3], float yPos[3], float fSpawn[3]) {
		for (int i = 0; i < 3; i++) { fSpawn[i] = (xPos[i] + yPos[i]) / 2; }

		if (xPos[2] <= yPos[2]) { fSpawn[2] = xPos[2] + 100.0; }
		else { fSpawn[2] = yPos[2] + 100.0; }
	}
}

methodmap Players < ArrayList {
	public Players() {
		ArrayList alList = new ArrayList();
		for (int i = 1; i <= MaxClients; i++) { alList.Push(new Player()); }

		return view_as<Players>(alList);
	}
}

methodmap Global < StringMap {
	public Global() {
		StringMap smMap = new StringMap();
		smMap.SetValue("models", new Models());
		smMap.SetValue("players", new Players());
		smMap.SetValue("zones", new Zones());
		smMap.SetValue("zonegroups", 1);
		smMap.SetValue("renderedzone", 0);

		return view_as<Global>(smMap);
	}

	property Handle Timer {
		public get() {
			Handle hTimer;
			this.GetValue("timer", view_as<Handle>(hTimer));

			return hTimer;
		}

		public set(Handle hTimer) {
			this.SetValue("timer", hTimer);
		}
	}

	property Models Models {
		public get() {
			Models mModels;
			this.GetValue("models", view_as<Models>(mModels));

			return mModels;
		}

		public set(Models mModels) {
			this.SetValue("models", mModels);
		}
	}

	property Players Players {
		public get() {
			Players pPlayers;
			this.GetValue("players", view_as<Players>(pPlayers));

			return pPlayers;
		}

		public set(Players pPlayers) {
			this.SetValue("players", pPlayers);
		}
	}

	property Zones Zones {
		public get() {
			Zones zZones;
			this.GetValue("zones", view_as<Zones>(zZones));

			return zZones;
		}

		public set(Zones zZones) {
			this.SetValue("zones", zZones);
		}
	}

	property int ZoneGroups {
		public get() {
			int iZoneGroups;
			this.GetValue("zonegroups", iZoneGroups);

			return iZoneGroups;
		}

		public set(int iZoneGroups) {
			this.SetValue("zonegroups", iZoneGroups);
		}
	}

	property int RenderedZone {
		public get() {
			int iRenderedZone;
			this.GetValue("renderedzone", iRenderedZone);

			return iRenderedZone;
		}

		public set(int iRenderedZone) {
			this.SetValue("renderedzone", iRenderedZone);
		}
	}
}
