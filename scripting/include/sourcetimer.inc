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

methodmap Zone < StringMap {
	public Zone() {
		StringMap smMap = new StringMap();
		smMap.SetArray("x", {0.0, 0.0, 0.0}, 3);
		smMap.SetArray("y", {0.0, 0.0, 0.0}, 3);

		smMap.SetValue("id", -1);
		smMap.SetValue("mid", -1);
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

	property int Mid {
		public get() {
			int iMid;
			this.GetValue("mid", iMid);

			return iMid;
		}

		public set(int iMid) {
			this.SetValue("mid", iMid);
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
}

methodmap Zones < ArrayList {
	public Zones() { return view_as<Zones>(new ArrayList()); }

	public void CalculateCentre(float xPos[3], float yPos[3], float fCentre[3]) {

	}

	public void CalculateSpawn(float xPos[3], float yPos[3], float fSpawn[3]) {

	}
}

methodmap Admin < StringMap {
	public Admin() {
		StringMap smMap = new StringMap();
		smMap.SetValue("setting", -1);
		smMap.SetValue("option", -1);

		return view_as<Admin>(smMap);
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
		smMap.SetValue("admin", view_as<Admin>(new Admin()));
		smMap.SetValue("zone", view_as<Zone>(new Zone()));

		return view_as<Player>(smMap);
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

	property Zone Zone {
		public get() {
			Zone zZone;
			this.GetValue("zone", zZone);

			return zZone;
		}

		public set(Zone zZone) {
			this.SetValue("zone", zZone);
		}
	}
}

methodmap Players < ArrayList {
	public Players() {
		ArrayList alList = new ArrayList();
		for (int i = 1; i <= MaxClients; i++) { alList.Push(new Player()); }

		return view_as<Players>(alList);
	}

	public Admin GetAdmin(int iClient) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		return view_as<Admin>(pPlayer.Admin);
	}

	public void SetAdmin(int iClient, Admin aAdmin) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Admin = aAdmin;

		this.Set(iClient, pPlayer);
	}

	public Zone GetZone(int iClient) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		return view_as<Zone>(pPlayer.Zone);
	}

	public void SetZone(int iClient, Zone zZone) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone = zZone;

		this.Set(iClient, pPlayer);
	}

	public int GetAdminSetting(int iClient) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		return pPlayer.Admin.Setting;
	}

	public int GetAdminOption(int iClient) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		return pPlayer.Admin.Option;
	}

	public void SetAdminSetting(int iClient, int iSetting) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Admin.Setting = iSetting;

		this.Set(iClient, pPlayer);
	}

	public void SetAdminOption(int iClient, int iOption) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Admin.Option = iOption;

		this.Set(iClient, pPlayer);
	}

	public void GetAdminZoneX(int iClient, float xPos[3]) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone.GetX(xPos);
	}

	public void GetAdminZoneY(int iClient, float yPos[3]) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone.GetY(yPos);
	}

	public void SetAdminZoneX(int iClient, float xPos[3]) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone.SetX(xPos);

		this.Set(iClient, pPlayer);
	}

	public void SetAdminZoneY(int iClient, float yPos[3]) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone.SetY(yPos);

		this.Set(iClient, pPlayer);
	}

	public int GetAdminZoneType(int iClient) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		return pPlayer.Zone.Type;
	}

	public void SetAdminZoneType(int iClient, int iType) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone.Type = iType;

		this.Set(iClient, pPlayer);
	}

	public int GetAdminZoneGroup(int iClient) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		return pPlayer.Zone.Group;
	}

	public void SetAdminZoneGroup(int iClient, int iGroup) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone.Group = iGroup;

		this.Set(iClient, pPlayer);
	}

	public void ClearAdmin(int iClient) {
		delete this.GetAdmin(iClient);
		delete this.GetZone(iClient);

		this.SetAdmin(iClient, new Admin());
		this.SetZone(iClient, new Zone());
	}

	public void Clear(int iClient) {
		this.ClearAdmin(iClient);
	}
}

methodmap Models < StringMap {
	public Models() {
		StringMap smMap = new StringMap();
		smMap.SetValue("blueglow", PrecacheModel("sprites/blueglow1.vmt"));
		smMap.SetValue("redglow", PrecacheModel("sprites/purpleglow1.vmt"));
		smMap.SetValue("laser", PrecacheModel("materials/sprites/laserbeam.vmt"));
		smMap.SetValue("glow", PrecacheModel("materials/sprites/glow01.vmt"));

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

	public int CalculateZoneType(int iType) {
		return iType % ZONES_TOTAL;
	}

	public int CalculateZoneGroup(int iGroup) {
		int iZoneGroups;
		this.GetValue("zonegroups", iZoneGroups);

		return iGroup % iZoneGroups;
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
