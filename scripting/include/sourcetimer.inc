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

methodmap Checkpoint < StringMap {
	public Checkpoint() {
		StringMap smMap = new StringMap();
		smMap.SetValue("id", -1);
		smMap.SetValue("time", -1.0);

		return view_as<Checkpoint>(smMap);
	}
}

methodmap Checkpoints < ArrayList {
	public Checkpoints() { return view_as<Checkpoints>(new ArrayList()); }

	public void Clear() {
		for (int i = 0; i < this.Length; i++) {
			Checkpoint cCheckpoint = this.Get(i);
			delete cCheckpoint;
		}
	}
}

methodmap Record < StringMap {
	public Record() {
		StringMap smMap = new StringMap();
		smMap.SetValue("checkpoints", new Checkpoints());
		smMap.SetValue("time", -1.0);
		smMap.SetValue("id", -1);

		return view_as<Record>(smMap);
	}

	public void Clear() {
		Checkpoints cCheckpoints;
		this.GetValue("checkpoints", cCheckpoints);
		cCheckpoints.Clear();

		delete cCheckpoints;
	}

	property Checkpoints Checkpoints {
		public get() {
			Checkpoints cCheckpoints;
			this.GetValue("checkpoints", cCheckpoints);

			return cCheckpoints;
		}

		public set(Checkpoints cCheckpoints) {
			this.SetValue("checkpoints", cCheckpoints);
		}
	}
}

methodmap Records < ArrayList {
	public Records() { return view_as<Records>(new ArrayList()); }

	public void Clear() {
		for (int i = 0; i < this.Length; i++) {
			Record rRecord = this.Get(i);
			rRecord.Clear();

			delete rRecord;
		}
	}
}

methodmap Style < StringMap {
	public Style() {
		StringMap smMap = new StringMap();
		smMap.SetValue("records", new Records());

		return view_as<Style>(smMap);
	}

	public void Clear() {
		Records rRecords;
		this.GetValue("records", rRecords);
		rRecords.Clear();

		delete rRecords;
	}

	property Records Records {
		public get() {
			Records rRecords;
			this.GetValue("records", rRecords);

			return rRecords;
		}

		public set(Records rRecords) {
			this.SetValue("records", rRecords);
		}
	}
}

methodmap Styles < ArrayList {
	public Styles() { return view_as<Styles>(new ArrayList()); }

	public void Clear() {
		for (int i = 0; i < this.Length; i++) {
			Style sStyle = this.Get(i);
			sStyle.Clear();

			delete sStyle;
		}
	}
}

methodmap Zone < StringMap {
	public Zone() {
		StringMap smMap = new StringMap();
		smMap.SetArray("x", {0.0, 0.0, 0.0}, 3);
		smMap.SetArray("y", {0.0, 0.0, 0.0}, 3);

		smMap.SetValue("type", -1);
		smMap.SetValue("group", -1);
		smMap.SetValue("entity", -1);

		return view_as<Zone>(smMap);
	}

	public void GetX(float[] xPos) {
		this.GetArray("x", xPos, 3);
	}

	public void SetX(const float[] xPos) {
		this.SetArray("x", xPos, 3);
	}

	public void GetY(float[] yPos) {
		this.GetArray("y", yPos, 3);
	}

	public void SetY(const float[] yPos) {
		this.SetArray("y", yPos, 3);
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

methodmap Zones < ArrayList {
	public Zones() { return view_as<Zones>(new ArrayList()); }

	public void Clear() {
		for (int i = 0; i < this.Length; i++) {
			Zone zZone = this.Get(i);
			delete zZone;
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
		smMap.SetValue("styles", new Styles());

		smMap.SetValue("zonetype", -1);
		smMap.SetValue("zonegroup", -1);
		smMap.SetValue("start", -1.0);
		smMap.SetValue("style", -1);

		return view_as<Player>(smMap);
	}

	public void ClearAdmin() {
		Admin aAdmin;
		this.GetValue("admin", aAdmin);
		aAdmin.Clear();

		delete aAdmin;
	}

	public void ClearStyles() {
		Styles sStyles;
		this.GetValue("styles", sStyles);
		sStyles.Clear();

		delete sStyles;
	}

	public void Clear() {
		this.ClearAdmin();
		this.ClearStyles();
	}

	property Admin Admin {
		public get() {
			Admin aAdmin;
			this.GetValue("admin", aAdmin));
			
			return aAdmin;
		}

		public set(Admin aAdmin) {
			this.SetValue("admin", aAdmin);
		}
	}

	property Styles Styles {
		public get() {
			Styles sStyles;
			this.GetValue("styles", sStyles);

			return sStyles;
		}

		public set(Styles sStyles) {
			this.SetValue("styles", sStyles);
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

	property float Start {
		public get() {
			float fStart;
			this.GetValue("start", fStart);

			return fStart;
		}

		public set(float fStart) {
			this.SetValue("start", fStart);
		}
	}

	property int Style {
		public get() {
			int iStyle;
			this.GetValue("style", iStyle);

			return iStyle;
		}

		public set(int iStyle) {
			this.SetValue("style", iStyle);
		}
	}
}

methodmap Players < ArrayList {
	public Players() { return view_as<Players>(new ArrayList()); }

	public void Clear() {
		for (int i = 0; i < this.Length; i++) {
			Player pPlayer = this.Get(i);
			pPlayer.Clear();

			delete pPlayer;
		}
	}
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

methodmap Queries < ArrayList {
	public Queries() { return view_as<Queries>(new ArrayList()); }
}

methodmap Global < StringMap {
	public Global() {
		StringMap smMap = new StringMap();
		smMap.SetValue("models", new Models());
		smMap.SetValue("queries", new Queries());
		smMap.SetValue("zones", new Zones());
		smMap.SetValue("styles", new Styles());
		smMap.SetValue("players", new Players());

		smMap.SetValue("storage", 0);
		smMap.SetValue("ismysql", 0);
		
		smMap.SetValue("zonegroups", 0);
		smMap.SetValue("renderedzone", 0);

		return view_as<Global>(smMap);
	}

	property Handle Timer {
		public get() {
			Handle hTimer;
			this.GetValue("timer", hTimer);

			return hTimer;
		}

		public set(Handle hTimer) {
			this.SetValue("timer", hTimer);
		}
	}

	property Models Models {
		public get() {
			Models mModels;
			this.GetValue("models", mModels);

			return mModels;
		}

		public set(Models mModels) {
			this.SetValue("models", mModels);
		}
	}

	property Queries Queries {
		public get() {
			Queries qQueries;
			this.GetValue("queries", qQueries);

			return qQueries;
		}

		public set(Queries qQueries) {
			this.SetValue("queries", qQueries);
		}
	}

	property Zones Zones {
		public get() {
			Zones zZones;
			this.GetValue("zones", zZones);

			return zZones;
		}

		public set(Zones zZones) {
			this.SetValue("zones", zZones);
		}
	}

	property Styles Styles {
		public get() {
			Styles sStyles;
			this.GetValue("styles", sStyles);

			return sStyles;
		}

		public set(Styles sStyles) {
			this.SetValue("styles", sStyles);
		}
	}

	property Players Players {
		public get() {
			Players pPlayers;
			this.GetValue("players", pPlayers);

			return pPlayers;
		}

		public set(Players pPlayers) {
			this.SetValue("players", pPlayers);
		}
	}

	property Database Storage {
		public get() {
			Database dStorage;
			this.GetValue("storage", dStorage);

			return dStorage;
		}

		public set(Database dStorage) {
			this.SetValue("storage", dStorage);
		}
	}

	property bool IsMySQL {
		public get() {
			bool bIsMySQL;
			this.GetValue("ismysql", bIsMySQL);

			return bIsMySQL;
		}

		public set(bool bIsMySQL) {
			this.SetValue("ismysql", bIsMySQL);
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