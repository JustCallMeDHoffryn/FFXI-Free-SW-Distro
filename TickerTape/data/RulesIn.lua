local AllRules = {

	--      CMD     {Offset    Format   Decode   Name  {Logic, Flag}  Table  Extra
	--                bit
	--                 #bits}

--	Standard Header -----------------------------------------------------------

[0xFFF] = {

	[1]  =  {  {},  {0},   'byte',    'raw',    'Packet ID'	},
	[2]  =  {  {},  {1},   'byte',    'raw',    'Data Size'	},
	[3]  =  {  {},  {2},   'rword',   'raw',    'Sync'	    },
	[4]  =  {  {'return' } },

	},	--	[[ COMPLETE ]]

--	NPC Update ----------------------------------------------------------------

[0x00E] = T{

	--	   	   Cmd	Offsets	  Format         Decode     Name            {Logic,flag} Table  Extra

	[1]   =	{  {},  {0},      'byte',        'raw',     'Packet ID',  },
	[2]   =	{  {},  {1},      'byte',        'raw',     'Size',       },
	[3]   =	{  {},  {2},      'rword',       'raw',     'Sync',       },
	[4]   =	{  {},  {4},      'rdword',      'entity',  'NPC ID',     },
	[5]   =	{  {},  {8},      'rword',       'raw',     'Index',      },
	[6]   =	{  {},  {10,1},   'bit',         'bool',    'Flag',         {'set', 1},  0,  '[Position, Rotation, Walk]' },
	[7]   =	{  {},  {12},     '12bytes',     'xyz',     'Position',     {'use', 1} },
	[8]   =	{  {},  {11},     'byte',        'dir',     'Direction',    {'use', 1} },
	[9]   =	{  {},  {24},     'rword',       'raw',     'Walk Count',   {'use', 1} },
	[10]  =	{  {},  {28},     'byte',        'raw',     'Speed',        {'use', 1} },
	[11]  =	{  {},  {29},     'byte',        'raw',     'S-Speed',      {'use', 1} },
	[12]  =	{  {},  {10,2},   'bit',         'bool',    'Flag',         {'set', 2},  0,  '[Claimer ID]' },
	[13]  =	{  {},  {44},     'rdword',      'player',  'Claimer',      {'use', 2} },
	[14]  =	{  {},  {10,4},   'bit',         'bool',    'Flag',         {'set', 3},  0,  '[HP, Status]' },
	[15]  =	{  {},  {30},     'byte',        'raw',     ' HP %%',       {'use', 3} },
	[16]  =	{  {},  {32},     'byte',        'raw',     'Status',       {'use', 3} },
	[17]  =	{  {},  {31},     'byte',        'raw',     'Animation',  },
	[18]  =	{  {},  {42},     'byte',        'raw',     'Anim Sub',   },
	[19]  =	{  {},  {41},     'byte',        'raw',     'Allegiance', },
	[20]  =	{  {},  {10,8},   'bit',         'bool',    'Flag',         {'set', 4},  0,  '[Name]' },
	[21]  =	{  {},  {50},     'rword',       'raw',     'Model ID',   },

	},	--[[ COMPLETE ]]

--	NPC Action ----------------------------------------------------------------

[0x028] = T{

	[1]  =  {  { 'call', 0xFFF }, 											},
	[2]  =	{  {}, {4},        'byte',    'raw',     'Data Size'			},
	[3]  =	{  {}, {5},        'rdword',  'entity',  'Actor'    			},
	[4]  =	{  {}, {9},        'byte',    'raw',     'Target Cnt'			},
	[5]  =	{  {}, {10,2,4},   'rword',   'bits',    'Category',   {},  1   },
	[6]  =	{  {}, {10,6,16},  'rword',   'bits',    'Action ID',  {},  2   },

	},	--	PART - Needs flag decode

--	Pet Status ----------------------------------------------------------------

[0x068] = {

	[1]  =  {  { 'call', 0xFFF }, 									},
	[2]  =	{  {}, {4,0,6},    'rword',    'bits',    'Type'		},
	[3]  =	{  {}, {4,6,10},   'rword',    'bits',    'Length'		},
	[4]  =	{  {}, {6},        'rword',    'player',  'Owner Index'	},
	[5]  =	{  {}, {8},        'rword',    'player',  'Owner ID'	},
	[6]  =	{  {}, {12},       'rword',    'raw',     'Pet Index'	},
	[7]  =	{  {}, {14},       'byte',     'raw',     ' HP %%'		},
	[8]  =	{  {}, {15},       'byte',     'raw',     ' HP %%'		},
	[9]  =	{  {}, {16},       'rword',    'raw',     'TP'			},
	[10] =	{  {}, {20},       'rdword',   'entity',  'Target ID'	},
	[11] =	{  {}, {24},       'byte',     'string',  'Pet Name'	},

	},	--	[[ COMPLETE ]]

--	Char Update ---------------------------------------------------------------

[0x0DF] = {

	[1]  =  {  { 'call', 0xFFF }, 							},
	[2]  =	{  {}, {4},   'rdword',  'raw',  'ID'           },
	[3]  =	{  {}, {8},   'rdword',  'raw',  'HP'           },
	[4]  =	{  {}, {12},  'rdword',  'raw',  'MP'           },
	[5]  =	{  {}, {16},  'rdword',  'raw',  'TP'           },
	[6]  =	{  {}, {20},  'rword',   'raw',  'Index'        },
	[7]  =	{  {}, {22},  'byte',    'raw',  ' HP %%'       },
	[8]  =	{  {}, {23},  'byte',    'raw',  ' MP %%'       },
	[9]  =	{  {}, {32},  'byte',    'job',  'Main Job'     },
	[10] =	{  {}, {33},  'byte',    'raw',  'Main Level'   },
	[11] =	{  {}, {34},  'byte',    'job',  'Sub Job'      },
	[12] =	{  {}, {35},  'byte',    'raw',  'Sub Level'    },

	},	--	[[ COMPLETE ]]

--	Ability Recasts -----------------------------------------------------------

[0x119] = {

	[1] =   {  { 'call', 0xFFF }, 							},
	[2] =   {  { 'loop', 30, 8, 0 },                        },
	[3] =	{  {},  {15},  'byte',    'raw',    'Ability',	{},  3,  '' },
	[4] =	{  {},  {12},  'rword',   'raw',    'Timer'		},
	[5] =   {  { 'end' },                                   },

},	--	[[ COMPLETE ]]

}

return AllRules
