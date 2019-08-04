#define PLAYER_VALID 0
#define PLAYER_INGAME 1
#define PLAYER_ALIVE 2

#define COLORS_MAX 19

// csgocolors.inc - Author: exvel, Editor: Popoklopsi, Powerlord, Zipcore, Bara
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
	{ 255, 255, 102, 255 }, // Admin Zoning In-Progress
	{ 0, 255, 102, 255 } // Admin Zoning Complete
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

methodmap Admin < StringMap {
	public Admin() {
		StringMap smMap = new StringMap();
		smMap.SetValue("setting", -1);
		smMap.SetValue("option", -1);

		return view_as<Admin>(smMap);
	}

	public void Clear() {
		this.SetValue("setting", -1);
		this.SetValue("option", -1);
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

	public void Clear() {
		this.SetArray("x", {0.0, 0.0, 0.0}, 3);
		this.SetArray("y", {0.0, 0.0, 0.0}, 3);

		this.SetValue("id", -1);
		this.SetValue("mid", -1);
		this.SetValue("type", -1);
		this.SetValue("group", -1);
	}

	public void SetX(const float[] fX) {
		this.SetArray("x", fX, 3);
	}

	public void SetY(const float[] fY) {
		this.SetArray("y", fY, 3);
	}

	public void GetX(float[] fX) {
		this.GetArray("x", fX, 3);
	}

	public void GetY(float[] fY) {
		this.GetArray("y", fY, 3);
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
}

methodmap Player < StringMap {
	public Player() {
		StringMap smMap = new StringMap();

		smMap.SetValue("admin", view_as<Admin>(new Admin()));
		smMap.SetValue("zone", view_as<Zone>(new Zone()));

		return view_as<Player>(smMap);
	}

	public void Clear() {
		Admin aAdmin;
		Zone zZone;

		if (this.GetValue("admin", aAdmin)) { aAdmin.Clear(); }
		if (this.GetValue("zone", zZone)) { zZone.Clear(); }
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
		alList.Resize(MaxClients + 1);

		return view_as<Players>(alList);
	}

	public void Init() {
		Player pPlayer = new Player();

		for (int i = 0; i <= MaxClients; i++) { this.Set(i, pPlayer); }
	}

	public void Clear() {
		Player pPlayer;

		for (int i = 0; i <= MaxClients; i++) {
			pPlayer = view_as<Player>(this.Get(i));
			pPlayer.Clear();
		}
	}

	public void InitClient(int iClient) {
		Player pPlayer = new Player();
		this.Set(iClient, pPlayer);
	}

	public void ClearClient(int iClient) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Clear();
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

	public int GetAdminSetting(int iClient) {
		Player pPlayer = view_as<Player>(this.Get(iClient));

		return pPlayer.Admin.Setting;
	}

	public int GetAdminOption(int iClient) {
		Player pPlayer = view_as<Player>(this.Get(iClient));

		return pPlayer.Admin.Option;
	}

	public void SetAdminZoneX(int iClient, float fX[3]) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone.SetX(fX);

		this.Set(iClient, pPlayer);
	}

	public void SetAdminZoneY(int iClient, float fY[3]) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone.SetY(fY);

		this.Set(iClient, pPlayer);
	}

	public void GetAdminZoneX(int iClient, float fX[3]) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone.GetX(fX);
	}

	public void GetAdminZoneY(int iClient, float fY[3]) {
		Player pPlayer = view_as<Player>(this.Get(iClient));
		pPlayer.Zone.GetY(fY);
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
		Models mModels = new Models();
		Players pPlayers = new Players();

		smMap.SetValue("models", mModels);

		pPlayers.Init();
		smMap.SetValue("players", pPlayers);
		return view_as<Global>(smMap);
	}

	public void Clear() {
		Handle hTimer;
		Players pPlayers;
		Zones zZones;

		this.GetValue("timer", view_as<Handle>(hTimer));
		delete hTimer;

		this.GetValue("players", view_as<Players>(pPlayers));
		pPlayers.Clear();

		this.GetValue("zones", view_as<Zones>(zZones));
		zZones.Clear();
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
}
