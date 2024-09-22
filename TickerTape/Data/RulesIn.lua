
local NewRules = {

--	Standard Header -----------------------------------------------------------

[0xFFF] = {

	[1]		=	{ {},	{0},		'Packet ID',					},
	[2]		=	{ {},	{1,1,1,7},	'Data Size',	{ 'psize' },	},
	[3]		=	{ {},	{2, 2},		'Sync',							},
	[4]		=	{ {'return' } 										},

	},	--	[[ COMPLETE ]]
	
--	Zone In -------------------------------------------------------------------

[0x00A] = {

	[1]		=	{ { 'call', 0xFFF }, 									},
	[2]		=	{ {},  {4,4},			'Unique ID',					},
	[3]		=	{ {},  {8,2},			'Actor ID',		{'eid', 'raw'},	},
	[4]		=	{ {},  {0x00B},			'Direction',	{'dir'},	    },
	[5]		=	{ {},  {0x00C},			'Position',		{'xyz'},		},
	[6]		=	{ {},  {0x018,4},		'Flags_1',						},
	[7]		=	{ {},  {0x01C},			'Speed',						},
	[8]		=	{ {},  {0x01D},			'Base Speed',					},
	[9]		=	{ {},  {0x01E},			' HP %%',						},
	[10]	=	{ {},  {0x01F},			'Animation',					},
	[11]	=	{ {},  {0x020},			'Mount ID',						},

	[12]	=	{ {},  {0x021,1,7,1},	'Gender',						},
	[13]	=	{ {},  {0x021,1,0,3},	'Size',							},
	[14]	=	{ {},  {0x084,16},		'Name',			{'string'},		},

	[15]	=	{ {},  {0x030},			'Zone ID',		{'zone'},		},
	[16]	=	{ {},  {0x056,2},		'Music 1',		{'music'}, 		},
	[17]	=	{ {},  {0x058,2},		'Music 2',		{'music'}, 		},
	[18]	=	{ {},  {0x05A,2},		'Music 3',		{'music'}, 		},
	[19]	=	{ {},  {0x05C,2},		'Music 4',		{'music'}, 		},
	[20]	=	{ {},  {0x05E,2},		'Music 5',		{'music'}, 		},

	[21]	=	{ {},  {0x068,2},		'Weather',		{'weather'},	},
	[22]	=	{ {},  {0x06A,4},		'Weather Time',					},

	[23]	=	{ {},  {0x064,2},		'Event ID',						},
	[24]	=	{ {},  {0x066,2},		'Event Flags',					},

	[25]	=	{ {},  {0x080},			'Valid MH ID'					},
	[26]	=	{ {},  {0x0A8,2},		'MH Floor 2',					},
	[27]	=	{ {},  {0x0AA,2},		'MH Model ID',	{'house'}		},
	[28]	=	{ {},  {0x0AC},			'In CS',						},
	[29]	=	{ {},  {0x0AF},			'MH Menu Opts',					},

	[30]	=	{ {},  {0x0A0,4},		'Play Time',	{'time', 'raw'}	},

	},	--[[ COMPLETE ]]

--	Zone Out ------------------------------------------------------------------
	
[0x00B] = {

	[1]		=	{ { 'call', 0xFFF }, 									},
	[2]		=	{ {},  {4,4},			'Type',							},
	[3]		=	{ {},  {8},				'Address',		{ 'ip'  },      },
	[4]		=	{ {},  {12,2},			'Port',							},
	
	},	--[[ COMPLETE ]]
		
--	NPC Update ----------------------------------------------------------------

[0x00E] = T{

	[1]		=	{ { 'call', 0xFFF }, 												},
	[2]		=	{ {},  {4,4},			'NPC ID',		{ 'entity', 'raw' },		},
	[3]		=	{ {},  {8,2},			'Index',		{ 'raw' },					},

	[4]		=	{ {},  {10,1,0,1},		'Position',    	{ 'bitflag' }				},
	[5]		=	{ {},  {10,1,1,1},   	'Claimer',     	{ 'bitflag' }				},
	[6]		=	{ {},  {10,1,2,1},   	'HP, Status',	{ 'bitflag' }				},
	[7]		=	{ {},  {10,1,3,1},   	'Name',			{ 'bitflag' }				},
	[8]		=	{ {},  {10,1,4,1},   	'Model',		{ 'bitflag' }				},
	[9]		=	{ {},  {10,1,5,1},   	'Despawn',		{ 'bitflag' }				},
	[10]	=	{ {},  {10,1,6,1},   	'Name 2',		{ 'bitflag' }				},
	[11]	=	{ {},  {10,1,7,1},   	'(unknown)',	{ 'bitflag' }				},
	
	[12]	=	{ {},  {0x0C},			'Position',		{ 'xyz' },					},
	[13]	=	{ {},  {0x0B},     		'Direction',    { 'dir' },					},
	[14]	=	{ {},  {0x18,2},		'Walk Count'								},
	[15]	=	{ {},  {0x1C},     		'Speed'										},
	[16]	=	{ {},  {0x1D},     		'S-Speed'									},
	[17]	=	{ {},  {0x2C,4},     	'Claimer',      { 'eid' }					},
	[18]	=	{ {},  {0x1E},     		' HP %%'									},
	[19]	=	{ {},  {0x20},     		'Status'									},

	[20]	=	{ {},  {0x1F},     		'Animation'									},
	[21]	=	{ {},  {0x2A},     		'Anim Sub'									},
	[22]	=	{ {},  {0x29},     		'Allegiance'								},
	[23]	=	{ {},  {0x32,2},		'Model ID'									},

	},	--[[ COMPLETE ]]

--	Inventory Finished ----------------------------------------------------

[0x01D] = {

	[1]		=	{ { 'call', 0xFFF }, 												},
	[2]		=	{ { 'if', 0 },	{4},	'Busy'										},
	[3]		=	{ { 'if', 1 },	{4},	'Finished'									},
	[4]		=	{ {}, {5},				'Location',		{ 'store' }					},

	[5]		=	{ {}, {8,1,0,1},		'Inventory',	{ 'bitflag' }				},
	[6]		=	{ {}, {8,1,1,1},		'Mog Safe',		{ 'bitflag' }				},
	[7]		=	{ {}, {8,1,2,1},		'Storage',		{ 'bitflag' }				},
	[8]		=	{ {}, {8,1,3,1},		'Temp Items',	{ 'bitflag' }				},
	[9]		=	{ {}, {8,1,4,1},		'Mog Locker',	{ 'bitflag' }				},
	[10]	=	{ {}, {8,1,5,1},		'Mog Satchel',	{ 'bitflag' }				},
	[11]	=	{ {}, {8,1,6,1},		'Mog Sack',		{ 'bitflag' }				},
	[12]	=	{ {}, {8,1,7,1},		'Mog Case',		{ 'bitflag' }				},

	[13]	=	{ {}, {9,1,0,1},		'Wardrobe 1',	{ 'bitflag' }				},
	[14]	=	{ {}, {9,1,1,1},		'Mog Safe 2',	{ 'bitflag' }				},
	[15]	=	{ {}, {9,1,2,1},		'Wardrobe 2',	{ 'bitflag' }				},
	[16]	=	{ {}, {9,1,3,1},		'Wardrobe 3',	{ 'bitflag' }				},
	[17]	=	{ {}, {9,1,4,1},		'Wardrobe 4',	{ 'bitflag' }				},
	[18]	=	{ {}, {9,1,5,1},		'Wardrobe 5',	{ 'bitflag' }				},
	[19]	=	{ {}, {9,1,6,1},		'Wardrobe 6',	{ 'bitflag' }				},
	[20]	=	{ {}, {9,1,7,1},		'Wardrobe 7',	{ 'bitflag' }				},

	[21]	=	{ {}, {10,1,0,1},		'Wardrobe 8',	{ 'bitflag' }				},
	[22]	=	{ {}, {10,1,1,1},		'Recycle Bin',	{ 'bitflag' }				},

	},	--[[ COMPLETE ]]

--	Item Assign ---------------------------------------------------------------

[0x01F] = {

	[1]		=	{ { 'call', 0xFFF }, 							   			},
	[2]		=	{ {},  {4,4},			'Quantity'							},
	[3]		=	{ {},  {8,2},   		'Item (ID)',	{ 'item', 'raw' }	},
	[4]		=	{ {},  {10},			'Location',		{ 'store' }			},
	[5]		=	{ {},  {11},			'Index'								},
	[6]		=	{ {'if', 0},  {12},		'Flag Normal'						},
	[7]		=	{ {'if', 5},  {12},		'No Drop'							},
	[8]		=	{ {'if', 15}, {12},		'No Select'							},
	[9]		=	{ {'if', 19}, {12},		'LinkShell'							},
	[10]	=	{ {'if', 27}, {12},		'On Puppet'							},

	},	--	[[ COMPLETE ]]

--	Item Update -----------------------------------------------------------

[0x020] = {

	[1]		=	{ { 'call', 0xFFF }, 									},
	[2]		=	{ {},  	{4,4},     	'Count'								},
	[3]		=	{ {},  	{8,4},      'Bazaar Price'						},
	[4]		=	{ {},  	{0x0C,2},	'Item (ID)',	{ 'item', 'raw'	} 	},
	[5]		=	{ {},  	{0x0E},		'Location',		{ 'store' }			},
	[6]		= 	{ {},  	{0x0F},		'Index'								},

	[7]		=	{ {'if', 0},  {16},	'Flag Normal'						},
	[8]		=	{ {'if', 5},  {16},	'No Drop'							},
	[9]		=	{ {'if', 15}, {16},	'No Select'							},
	[10]	=	{ {'if', 19}, {16},	'LinkShell'							},
	[11]	=	{ {'if', 27}, {16},	'On Puppet'							},

	},	--[[ COMPLETE ]]


--	NPC Action ----------------------------------------------------------------

[0x028] = {

	[1]		=	{ { 'call', 0xFFF },														},
	[2]		=	{ {}, {4},			'Data Size'												},
	[3]		=	{ {}, {5,4},      	'Actor',		{'entity'}								},
	[4]		=	{ {}, {9},			'Target Cnt'											},
	[5]		=	{ {}, {10,1,2,4},	'Category',  	{'raw'},	{'set', 1}					},

	[6]		=	{ { 'fswitch', 1 } },

	[10]	=	{ { 'case', 1 }, },
	[11]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Basic Attack (or RA)'			},
	[12]	=	{ { 'break' }, },  

	[20]	=	{ { 'case', 2 }, },
	[21]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'RA has Finished' 				},
	[22]	=	{ { 'break' }, },  

	[30]	=	{ { 'case', 3 }, },
	[31]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'WS has Finished' 				},
	[32]	=	{ { 'break' }, },  

	[40]	=	{ { 'case', 4 }, },
	[41]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'MA has Finished' 				},
	[42]	=	{ { 'break' }, },  

	[50]	=	{ { 'case', 5 }, },
	[51]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Item Use has Finished' 		},
	[52]	=	{ { 'break' }, },  

	[60]	=	{ { 'case', 6 }, },
	[61]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'JA has Finished' 				},
	[62]	=	{ { 'break' }, },  

	[70]	=	{ { 'case', 7 }, },
	[71]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Start of WS' 					},
	[72]	=	{ { 'break' }, },  

	[80]	=	{ { 'case', 8 }, },
	[81]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Start of MA' 					},
	[82]	=	{ { 'break' }, },  

	[90]	=	{ { 'case', 9 }, },
	[91]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Start of Item Use'		 		},
	[92]	=	{ { 'break' }, },  

	[100]	=	{ { 'case', 10 }, },
	[101]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Start of JA' 					},
	[102]	=	{ { 'break' }, },  

	[110]	=	{ { 'case', 11 }, },
	[111]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Mob Ability has Finished'		},
	[112]	=	{ { 'break' }, },  

	[120]	=	{ { 'case', 12 }, },
	[121]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Start of RA' 					},
	[122]	=	{ { 'break' }, },  

	[130]	=	{ { 'case', 13 }, },
	[131]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Pet Mob Ability has Finished'	},
	[132]	=	{ { 'break' }, },  

	[140]	=	{ { 'case', 14 }, },
	[141]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Dance'							},
	[142]	=	{ { 'break' }, },  

	[150]	=	{ { 'case', 15 }, },
	[151]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Ward Effusion'					},
	[152]	=	{ { 'break' }, },  

	[210]	=	{ { 'case', 21 }, },
	[211]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Quarry'						},
	[212]	=	{ { 'break' }, },  

	[220]	=	{ { 'case', 22 }, },
	[221]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Sprint'						},
	[222]	=	{ { 'break' }, },  

	[310]	=	{ { 'case', 31 }, },	--	LSB ONLY
	[311]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Magic (MA) Interrupted'		},
	[312]	=	{ { 'break' }, },  

	[320]	=	{ { 'case', 32 }, },	--	LSB ONLY
	[321]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Ranged (RA) Interrupted'		},
	[322]	=	{ { 'break' }, },  

	[330]	=	{ { 'case', 33 }, },	--	LSB ONLY
	[331]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Mob Ability Start'				},
	[332]	=	{ { 'break' }, },  

	[350]	=	{ { 'case', 35 }, },	--	LSB ONLY
	[351]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Mob Ability Interrupted'		},
	[352]	=	{ { 'break' }, },  

	[370]	=	{ { 'case', 37 }, },	--	LSB ONLY
	[371]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Raise Menu Selection'			},
	[372]	=	{ { 'break' }, },  

	[380]	=	{ { 'case', 38 }, },	--	LSB ONLY
	[381]	=	{ {}, {10},  		'Type', 		{'info'},	{}, 	'Job Ability (JA) Interrupted'	},
	[382]	=	{ { 'break' }, },  
	
	[999]	=	{ { 'end' } },

	},	--	PART - Needs flag decode


--	Action Message ------------------------------------------------------------

[0x029] = {

	[1]		=	{ { 'call', 0xFFF }, 						},
	[2]		=	{ {}, {4,4},   'Actor'						},
	[3]		=	{ {}, {8,4},   'Target'						},
	[4]		=	{ {}, {12,4},  'Param 1'					},
	[5]		=	{ {}, {16,4},  'Value'						},
	[6]		=	{ {}, {20,2},  'Actor Index', {'eid'}		},
	[7]		=	{ {}, {22,2},  'Target Index', {'eid'}		},
	[8]		=	{ {}, {24,2},  'Message'					},

	},	--[[ COMPLETE ]]

--	Update Char ---------------------------------------------------------------

[0x037] = {

	[1]		=	{ { 'call', 0xFFF }, 												},
	[2]		=	{ {}, {36,4},		'Player ID'										},
	[3]		=	{ {}, {42},			' HP %%'										},
	[4]		=	{ {}, {40,1,0,1},	'Hide Flag',			{'bitflag'}  			},
	[5]		=	{ {}, {40,1,1,1},	'Sleep Flag',			{'bitflag'}  			},
	[6]		=	{ {}, {40,1,2,1},	'Ground Flag',			{'bitflag'}  			},
	[7]		=	{ {}, {40,1,3,1},	'CLI Pos Init',			{'bitflag'}  			},
	[8]		=	{ {}, {40,1,4,1},	'LFG Flag',				{'bitflag'}  			},
	[9]		=	{ {}, {40,1,5,1},	'Anonymous',			{'bitflag'}  			},
	[10]	=	{ {}, {40,1,6,1},	'CFH Flag',				{'bitflag'}  			},
	[11]	=	{ {}, {40,1,7,1},	'Away Flag',			{'bitflag'}  			},
	
	[20]	=	{ {}, {41,1,0,1},	'Gender Flag',			{'bitflag'}  			},
	[21]	=	{ {}, {41,1,5,3},	'Choco Index'									},
	
	[30]	=	{ {}, {43,1,0,1},	'POL Flag',				{'bitflag'}  			},
	[31]	=	{ {}, {43,1,1,1},	'Link Shell',			{'bitflag'}  			},
	[32]	=	{ {}, {43,1,2,1},	'Link Dead',			{'bitflag'}  			},
	[33]	=	{ {}, {43,1,3,1},	'Target Off',			{'bitflag'}  			},
	[34]	=	{ {}, {43,1,5,3},	'GM Level'										},
	
	[40]	=	{ {}, {91},      	'Mount ID'    									},
	[41]	=	{ {}, {44,2,0,12},	'Speed', 										},
	[42]	=	{ {}, {45,1,4,1},	'Wall Hack',			{'bitflag'}  			},
	[43]	=	{ {}, {45,1,5,1},	'Freeze Flag',			{'bitflag'}  			},
	[44]	=	{ {}, {45,1,7,1},	'Invisible',			{'bitflag'}  			},
	[45]	=	{ {}, {46,1,0,1},	'Gate Breach',			{'bitflag'}  			},

	[46]	=	{ {}, {46,2,1,8},	'Speed Base'									},
	[47]	=	{ {}, {47,1,5,1},	'Bazaar Flag',			{'bitflag'}  			},
	[48]	=	{ {}, {47,1,6,1},	'Charm Flag',			{'bitflag'}  			},
	[49]	=	{ {}, {47,1,7,1},	'GM Icon Flag',			{'bitflag'}  			},

	[50]	=	{ {}, {0x30,4,3,16},'Pet Index'										},
	[51]	=	{ {}, {0x30,4,20,1},'TERROR',				{'bitflag'}  			},

	[60]	=	{ {}, {0x38,1,3,1},	'New Player',			{'bitflag'}  			},
	[61]	=	{ {}, {0x38,1,4,1},	'Mentor Flag',			{'bitflag'}  			},
	[62]	=	{ {}, {0x39},		'Ballista Team'									},

	[70]	=	{ {}, {0x58,1,0,4},	'GEO Element',			{'geo'}					},
	[71]	=	{ {}, {0x58,1,4,2},	'GEO Size'										},
	[72]	=	{ {}, {0x58,1,6,1},	'GEO Flag',				{'bitflag'}  			},
	[73]	=	{ {}, {0x58,1,7,1},	'Job Master',			{'bitflag'}  			},

	},	--[[ COMPLETE ]]


--	Shop List -----------------------------------------------------------------

[0x03C] = {

	[1]		=	{ { 'call', 0xFFF }, 					},
	[2]		=	{ {},  {4,2},	'Offset Index'			},
	[3]		=	{ {},  {6},		'Internal Index'		},
	
	[10]	=	{ {'calc', '#1=#A-8'}					},
	[11]	=	{ {'calc', '#2=#1/12'}					},
	[12]	=	{ {'useflag'},  {'#2'},	'Items',		},
	
	[20]	=	{ { 'loop', '#2', 12, 0 },				},

	[24]	=	{ {},  {8,4},	'Item Price'			},
	[25]	=	{ {},  {12,2},	'Item',		{'item'}	},
	[26]	=	{ {},  {14},	'Shop Index'			},
	[27]	=	{ {},  {16,2},	'Skill'					},
	[28]	=	{ {},  {18,2},	'Guild',				},

	[30]	=	{ { 'end' },                            },

	},	--	[[ COMPLETE ]]

--	Job Info Extra ------------------------------------------------------------

[0x044] = {

	[1]		=	{ { 'call', 0xFFF } },

	[2]		=	{ { 'switch', 4, 1} },

	[3]		=	{ { 'case', 16 },	     											},
	[4]		=	{ {}, {4},					'Mode (BLU)'							},

	[5]		=	{ { 'loop', 20, 1, 0 },                        						},
	[6]		=	{ { 'ifnot', 0 },  {8},  	'BLU Spell',    {'bluspell'}			},
	[7]		=	{ { 'end' },                                   						},

	[8]		=	{ { 'break' },          											},

	[9]		= 	{ { 'case', 18 },	     											},
	[10]	=	{ {}, {4},					'Mode (PUP)'							},
	[11]	=	{ {}, {8}, 	 				'Puppet Head',  	{'puppet'}			},
	[12]	=	{ {}, {9},  				'Puppet Body',  	{'puppet'}			},

	[13]	=	{ { 'loop', 12, 1, 0 } },
	[14]	=	{ { 'ifnot', 0 },  {10},	'Attachment',		{'attach'}			},
	[15]	=	{ { 'end' } },

	[16]	=	{ {}, {0x68,2}, 			'Puppet HP'								},
	[17]	=	{ {}, {0x6A,2},				'Max HP'								},
	[18]	=	{ {}, {0x6C,2}, 			'Puppet MP'								},
	[19]	=	{ {}, {0x6E,2}, 			'Max MP'								},
	[20]	=	{ {}, {0x70,2}, 			'Melee Min'								},
	[21]	=	{ {}, {0x72,2}, 			'Melee Max'								},
	[22]	=	{ {}, {0x74,2}, 			'RA Min'								},
	[23]	=	{ {}, {0x76,2}, 			'RA Max'								},
	[24]	=	{ {}, {0x78,2}, 			'Magic Min'								},
	[25]	=	{ {}, {0x7A,2}, 			'Magic Max'								},

	[30]	=	{ {}, {0x80,2}, 			'Basic STR'								},
	[31]	=	{ {}, {0x82,2}, 			'STR MOD'								},
	[32]	=	{ {}, {0x84,2}, 			'Basic DEX'								},
	[33]	=	{ {}, {0x86,2}, 			'DEX MOD'								},
	[34]	=	{ {}, {0x88,2}, 			'Basic VIT'								},
	[35]	=	{ {}, {0x8A,2}, 			'VIT MOD'								},
	[36]	=	{ {}, {0x8C,2}, 			'Basic AGI'								},
	[37]	=	{ {}, {0x8E,2}, 			'AGI MOD'								},
	[38]	=	{ {}, {0x90,2}, 			'Basic INT'								},
	[39]	=	{ {}, {0x92,2}, 			'INT MOD'								},
	[40]	=	{ {}, {0x94,2}, 			'Basic MND'								},
	[41]	=	{ {}, {0x96,2}, 			'MND MOD'								},
	[42]	=	{ {}, {0x98,2}, 			'Basic CHR'								},
	[43]	=	{ {}, {0x9A,2}, 			'CHR MOD'								},
	[44]	=	{ {}, {0x9C,2}, 			'Elem Capacity'							},

	[89]	=	{ { 'break' } },

	[90]	=	{ { 'default' } },
	[91]	=	{ {}, {4},  'Mode (Var)' },
	[92]	=	{ {}, {8}, 	'MON Species' },
	[93]	=	{ { 'loop', 12, 2, 0 } },
	[94]	=	{ { 'ifnot', 0 },  {12,2},	'Instinct'								},
	[95]	=	{ { 'end' } },
	[96]	=	{ { 'break' } },

	[99]	=	{ { 'end' } },

	},

--	Auction House Menu --------------------------------------------------------

[0x04C] = {

	[1]		=	{ { 'call', 0xFFF }, 					},
	[2]		=	{ {},  {4},  	'Command'				},
	[3]		=	{ {},  {5},  	'AucWorkIndex'			},
	[4]		=	{ {},  {6},  	'Result'				},
	[5]		=	{ {},  {7},  	'ResultStatus'			},

	},	--[[ COMPLETE ]]

--	Quest / Mission Log -------------------------------------------------------

[0x056] = {

	[1]		=	{ { 'call', 0xFFF } },

	[2]		=	{ { 'switch', 0x24, 2} },

	[3]		=	{ { 'case', 0xFFFF } },
	[4]		=	{ {}, {0x24,2},   'Type', 		{'info'},  {}, 'Current Mission' },
	[5]		=	{ { 'break' } },

	[6]		=	{ { 'case', 0x00D0 } },
	[7]		=	{ {}, {0x24,2},   'Type', 		{'info'},  {}, 'Completed Mission' },
	[8]		=	{ { 'break' } },

	[9]		=	{ { 'case', 0x0080 } },
	[10]	=	{ {}, {0x24,2},   'Type', 		{'info'},  {}, 'Active ToaU/WotG Mission' },
	[11]	=	{ { 'break' } },

	[12]	=	{ { 'case', 0x00D8 } },
	[13]	=	{ {}, {0x24,2},   'Type', 		{'info'},  {}, 'Completed ToaU/WotG Mission' },
	[14]	=	{ { 'break' } },

	[15]	=	{ { 'case', 0x00C0 } },
	[16]	=	{ {}, {0x24,2},   'Type', 		{'info'},  {}, 'Completed Assault Mission' },
	[17]	=	{ { 'break' } },

	[18]	=	{ { 'case', 0x0030 } },
	[19]	=	{ {}, {0x24,2},   'Type', 		{'info'},  {}, 'Campaign - One' },
	[20]	=	{ { 'break' } },

	[21]	=	{ { 'case', 0x0038 } },
	[22]	=	{ {}, {0x24,2},   'Type', 		{'info'},  {}, 'Campaign - Two' },
	[23]	=	{ { 'break' } },

	[24]	=	{ { 'default' } },
	[25]	=	{ {}, {0x24,2},   'Type', 		{'info'},  {}, 'General Missions' },
	[26]	=	{ { 'break' } },

	[27]	=	{ { 'end' } },

	},

--	Weather Change ------------------------------------------------------------

[0x057] = {

	[1]		=	{ { 'call', 0xFFF }, 							},
	[2]		=	{ {}, {-1},		'NOTE',			{'info'},	{},	'This date seems to be wrong'	},
	[3]		=	{ {}, {4,4},	'Change Time',	{'vdate'}		},
	[4]		=	{ {}, {8,2},	'New Weather',	{'weather'}		},
	[5]		=	{ {}, {10,2},	'Transition'					},

	},	--[[ COMPLETE ]]

--	Lock Target ---------------------------------------------------------------

[0x058] = {

	[1]		=	{ { 'call', 0xFFF }, 						},
	[2]		=	{ {}, {4,4},   'ID',    	{'eid'}			},
	[3]		=	{ {}, {12.2},  'Index'                   	},
	[4]		=	{ {}, {8,4},   'Target',    {'entity'}		},
	[5]		=	{ {}, {14,2},  'Target Index'            	},

	},	--[[ COMPLETE ]]

	
--	Skills Update -------------------------------------------------------------

[0x062] = {

	[1]		=	{  { 'call', 0xFFF }, 					},

	[2]		=	{  {}, {-1},		'WEAPONS', 	{'info'},  {},	'Values >= 0x8000 Are Capped' },

	[3]		=	{  {}, {0x82,2},	'H-2-H'            	},
	[4]		=	{  {}, {0x84,2},	'Dagger' 	        },
	[5]		=	{  {}, {0x86,2},	'Sword'		        },
	[6]		=	{  {}, {0x88,2},	'G-Sword'           },
	[7]		=	{  {}, {0x8A,2},	'Axe'		        },
	[8]		=	{  {}, {0x8C,2},	'G-Axe' 		    },
	[9]		=	{  {}, {0x8E,2},	'Scythe'            },
	[10]	=	{  {}, {0x90,2},	'Polearm'           },
	[11]	=	{  {}, {0x92,2},	'Katana'            },
	[12]	=	{  {}, {0x94,2},	'G-Katana'          },
	[13]	=	{  {}, {0x96,2},	'Club'            	},
	[14]	=	{  {}, {0x98,2},	'Staff'           	},

	[15]	=	{  {}, {-1},		'PUPPETS', 	{'info'},  {},	'Values >= 0x8000 Are Capped' },

	[16]	=	{  {}, {0xAC,2},	'Auto Melee'     	},
	[17]	=	{  {}, {0xAE,2},	'Auto Ranged'     	},
	[18]	=	{  {}, {0xB0,2},	'Auto Magic'      	},

	[19]	=	{  {}, {-1},		'SKILLS', 	{'info'},  {},	'Values >= 0x8000 Are Capped' },

	[20]	=	{  {}, {0xB2,2},	'Archery'      		},
	[21]	=	{  {}, {0xB4,2},	'Marksmanship'    	},
	[22]	=	{  {}, {0xB6,2},	'Throwing'      	},
	[23]	=	{  {}, {0xB8,2},	'Guarding'      	},
	[24]	=	{  {}, {0xBA,2},	'Evasion'      		},
	[25]	=	{  {}, {0xBC,2},	'Shield'      		},
	[26]	=	{  {}, {0xBE,2},	'Parrying'      	},

	[27]	=	{  {}, {-1},		'MAGIC', 	{'info'},  {},	'Values >= 0x8000 Are Capped' },

	[28]	=	{  {}, {0xC0,2},	'Divine'      		},
	[29]	=	{  {}, {0xC2,2},	'Healing'      		},
	[30]	=	{  {}, {0xC4,2},	'Enhancing'      	},
	[31]	=	{  {}, {0xC6,2},	'Enfeebling'      	},
	[32]	=	{  {}, {0xC8,2},	'Elemental'      	},
	[33]	=	{  {}, {0xCA,2},	'Dark'      		},
	[34]	=	{  {}, {0xCC,2},	'Summoning'      	},
	[35]	=	{  {}, {0xCE,2},	'Ninjutsu'      	},
	[36]	=	{  {}, {0xD6,2},	'Blue'      		},

	[37]	=	{  {}, {-1},		'MUSIC', 	{'info'},  {},	'Values >= 0x8000 Are Capped' },

	[38]	=	{  {}, {0xD0,2},	'Singing'      		},
	[39]	=	{  {}, {0xD2,2},	'String'      		},
	[40]	=	{  {}, {0xD4,2},	'Wind'      		},

	[41]	=	{  {}, {-1},   		'CRAFT', 	{'info'},  {},	'Contains Cap / Rank / Level' },

	[42]	=	{  {}, {0xE0,2},	'Fishing'      		},
	[43]	=	{  {}, {0xE2,2},	'Woodworking'      	},
	[44]	=	{  {}, {0xE4,2},	'Smithing'      	},
	[45]	=	{  {}, {0xE6,2},	'Goldsmithing'     	},
	[46]	=	{  {}, {0xE8,2},	'Clothcraft'      	},
	[47]	=	{  {}, {0xEA,2},	'Leathercraft'     	},
	[48]	=	{  {}, {0xEC,2},	'Bonecraft'      	},
	[49]	=	{  {}, {0xEE,2},	'Alchemy'      		},
	[50]	=	{  {}, {0xF0,2},	'Cooking'      		},

	[51]	=	{  {}, {-1},		'MISC', 	{'info'},  {},	'Values >= 0x8000 Are Capped' },

	[52]	=	{  {}, {0xF2,2},	'Synergy'      		},
	[53]	=	{  {}, {0xF4,2},	'Riding'      		},

	},	--[[ COMPLETE ]]


--	Set Update ----------------------------------------------------------------

[0x063] = {

	[1]		=	{ { 'call', 0xFFF } },

	[2]		=	{ { 'switch', 4, 1} },

	--	Merit Points ----------------------------------------------------------

	[20]	=	{ { 'case', 2 } },
	[21]	=	{ {}, {-1},   		'Mode', 		{'info'},  	{}, 	'Merits' 	},
	[22]	=	{ {}, {8,2},   		'Limit Points'	},
	[23]	=	{ {}, {10,2,0,6},  	'Merit Points'	},
	[24]	=	{ {}, {11,1,5,1}, 	'Lv 75+, Has KI',	{'bitflag'}	},
	[25]	=	{ {}, {11,1,6,1}, 	'Merit Mode',		{'bitflag'}	},
	[26]	=	{ {}, {11,1,7,1}, 	'Enabled',			{'bitflag'}	},
	[27]	=	{ {}, {12},   		'Max Merits'	},
	[28]	=	{ { 'break' } },

	---------------------------------------------------------------------------

	[30]	=	{ { 'case', 3 } },
	[31]	=	{ {}, {-1},   		'Mode', 		{'info'},  	{}, 	'Monstrosity 1' 	},
	[32]	=	{ { 'break' } },

	[40]	=	{ { 'case', 4 } },
	[41]	=	{ {}, {-1},   		'Mode', 		{'info'},  	{}, 	'Monstrosity 2' 	},
	[42]	=	{ { 'break' } },

	--	Job Points ------------------------------------------------------------

	[50]	=	{ { 'case', 5 } },
	[51]	=	{ {}, {-1},   		'Mode', 		{'info'},  	{}, 	'Job Points (listed per Job)' 	},
	[52]	=	{ {}, {8,1,0,1},	'Has Access',	{'bitflag'}	},

	[53]	= 	{ { 'loop', 24, 6, 0 } },
	[54]	=	{ { 'useflag' },  {'#C'}, 	'Job',	{'job'}		},
	[55]	=	{ { },  {12,2}, 			'Cap Points'		},
	[56]	=	{ { },  {14,2}, 			'Current JP'		},
	[57]	=	{ { },  {16,2}, 			'JP Spent'			},
	[58]	=	{ { 'end' } },

	[59]	=	{ { 'break' } },

	---------------------------------------------------------------------------

	[77]	=	{ { 'case', 6 } },
	[78]	=	{ {}, {-1},   		'Mode', 		{'info'},  	{}, 	'Homepoints' 	},
	[79]	=	{ { 'break' } },

	[80]	=	{ { 'case', 7 } },
	[81]	=	{ {}, {-1},   		'Mode', 		{'info'},  	{}, 	'Unity' 	},
	[82]	=	{ { 'break' } },

	--	Status Icons ----------------------------------------------------------

	[90]	= 	{ { 'case', 9 } },
	[91]	=	{ {}, {-1},   		'Mode', 		{'info'},  	{}, 	'Status Icons' 	},

	[92]	= 	{ { 'loop', 32, 2, 0 } },
	[93]	=	{ { 'ifnot', 255 },  {0x08,2}, 		'Status',	{'status'}				},
	[94]	=	{ { 'end' } },

	[95]	= 	{ { 'loop', 32, 4, 0 } },
	[96]	=	{ { 'ifnot', 0 },    {0x48,4},      'Timestamp'		},
	[97]	=	{ { 'end' } },

	[98]	=	{ { 'break' } },

	---------------------------------------------------------------------------

	[100]	=	{ { 'case', 10 } },
	[101]	=	{ {}, {-1},   		'Mode', 		{'info'},  	{}, 	'Unknown' 	},
	[102]	=	{ { 'break' } },

	[110]	=	{ { 'default', 2 } },
	[111]	=	{ {}, {-1},   		'Mode', 		{'info'},  	{}, 	'Invalid' 	},
	[112]	=	{ { 'break' } },

	[999]	=	{ { 'end' } },

},

--	Job Info Extra ------------------------------------------------------------

[0x067] = {

	[1]		=	{ { 'call', 0xFFF }, 														},
	[2]		=	{ {}, {4,1,0,6},	'Mode',  			{'raw'},	{'set', 1}				},
	[3]		=	{ { 'fswitch', 1},						   									},

	[20]	=	{ { 'case', 2 },	     													},
	[21]	=	{ {}, {-1},			'Contents',			{'info'},   {}, 'Mode 2 (Player)'	},
	[22]	=	{ {}, {6,2},		'Target ID' 	         								},
	[23]	=	{ {}, {8,4},		'Player ID' 	         								},
	[24]	=	{ {}, {0x0C,2},		'Fellow ID' 	         								},
	[25]	=	{ {}, {0x10,1,1,1},	'Camp. Battle',		{ 'bitflag' }						},
	[26]	=	{ {}, {0x10,1,2,1},	'Level Sync',		{ 'bitflag' }						},
	[27]	=	{ {}, {0x26},		'Lvl Restrict' 		   									},
	[28]	=	{ {}, {0x13,2},		'Mount Sub'     										},
	[29]	=	{ {}, {0x18,4},		'Field Choco'   	  									},
	[30]	=	{ {}, {0x18},		'Choco Head'											},
	[31]	=	{ {}, {0x19},  		'Choco Feet'											},
	[32]	=	{ {}, {0x1A},  		'Choco Tail'											},
	[33]	=	{ {}, {0x1B},  		'Choco Colour'											},
	[34]	=	{ {}, {0x27},		'Floor Change'  	  									},
	[35]	=	{ { 'break' },          													},

	[60]	=	{ { 'case', 3 },	     							},
	[61]	=	{ {}, {-1},			'Contents',			{'info'},  {}, 'Mode 3 (NPC/Trust)'	},
	[62]	=	{ {}, {6,2},		'Actor ID' 	         									},
	[63]	=	{ {}, {8,4},		'Unique ID' 	         								},
	[64]	=	{ {}, {0x0C,2},		'Trust Owner' 	         								},
	[65]	=	{ {}, {0x14,4},		'Name Flags' 	         								},
	[66]	=	{ {}, {0x18,24},	'Name',				{'string'}							},
	[67]	=	{ { 'break' },          							},

	[80]	=	{ { 'case', 4 },	     							},
	[81]	=	{ {}, {4},			'Mode (Pet)'          			},
	[82]	=	{ { 'break' },          							},

	[90]	=	{ { 'default' },	     							},
	[91]	=	{ {}, {4},			'Mode (???)'	   				},
	[92]	=	{ { 'break' },          							},

	[999]	=	{ { 'end' },          								},

	},

--	Pet Status ----------------------------------------------------------------

[0x068] = {

	[1]		=	{ { 'call', 0xFFF }, 											},
	[2]		=	{ {}, {4,2,0,6},  'Type'										},
	[3]		=	{ {}, {4,2,6,10}, 'Length'										},
	[4]		=	{ {}, {6,2},      'Owner Index',	{ 'eid' }  					},
	[5]		=	{ {}, {8,2},      'Owner ID',				 					},
	[6]		=	{ {}, {12,2},     'Pet Index'									},
	[7]		=	{ {}, {14},		  ' HP %%'										},
	[8]		=	{ {}, {15},		  ' HP %%'										},
	[9]		=	{ {}, {16,2},     'TP'											},
	[10]	=	{ { 'ifnot', 0}, {20,4}, 'Target ID',	{ 'entity', 'raw' }		},
	[11]	=	{ { 'if',    0}, {20,4}, 'No Target',							},
	[12]	=	{ {}, {24,20},	  'Pet Name',			{ 'string' }			},

	},	--	[[ COMPLETE ]]

--	Merits --------------------------------------------------------------------

[0x08C] = {

	[1]		=	{ { 'call', 0xFFF }, 									},
	[2]		=	{ {}, {0x04,2},				'Point Count'	    		},
	[3]		=	{ { 'loop', 31, 4, 0 },                		        	},
	[4]		=	{ {}, {0x08,2},				'Merit ID',  	{'merit'}	},
	[5]		=	{ { 'ifnot', 0 }, {0x0B},	'Level'	    				},
	[6]		=	{ { 'ifnot', 0 }, {0x0A},	'Next'	    				},
	[7]		=	{ { 'end' },                                   			},

	},	--	[[ COMPLETE ]]

--	Job Points ----------------------------------------------------------------

[0x08D] = {

	[1]		=	{ { 'call', 0xFFF }, 								},
	[2]		=	{ { 'loop', 10, 4, 0 },                		        },
	[3]		=	{ {}, {4},		'Job Point',	{'jpoint'}		    },
	[4]		=	{ { 'end' },                                   		},
	[5]		=	{ { 'loop', 10, 4, 0 },                		        },
	[6]		=	{ {}, {0x54},	'Job Point',	{'jpoint'}			},
	[7]		=	{ { 'end' },                                   		},

	},	--	[[ COMPLETE ]]

--	Mount List ----------------------------------------------------------------

[0x0AE] = {

	[1]		=	{ { 'call', 0xFFF }, 										},

	[2]		=	{ {}, {4,1,0,1},		'Chocobo',			{ 'bitflag' }	},
	[3]		=	{ {}, {4,1,1,1},		'Raptor',			{ 'bitflag' }	},
	[4]		=	{ {}, {4,1,2,1},		'Tiger',			{ 'bitflag' }	},
	[5]		=	{ {}, {4,1,3,1},		'Crab',				{ 'bitflag' }	},
	[6]		=	{ {}, {4,1,4,1},		'Red Crab',			{ 'bitflag' }	},
	[7]		=	{ {}, {4,1,5,1},		'Bomb',				{ 'bitflag' }	},
	[8]		=	{ {}, {4,1,6,1},		'Sheep',			{ 'bitflag' }	},
	[9]		=	{ {}, {4,1,7,1},		'Morbol',			{ 'bitflag' }	},

	[12]	=	{ {}, {5,1,0,1},		'Crawler',			{ 'bitflag' }	},
	[13]	=	{ {}, {5,1,1,1},		'Fenrir',			{ 'bitflag' }	},
	[14]	=	{ {}, {5,1,2,1},		'Beetle',			{ 'bitflag' }	},
	[15]	=	{ {}, {5,1,3,1},		'Moogle',			{ 'bitflag' }	},
	[16]	=	{ {}, {5,1,4,1},		'Magic Pot',		{ 'bitflag' }	},
	[17]	=	{ {}, {5,1,5,1},		'Tulfaire',			{ 'bitflag' }	},
	[18]	=	{ {}, {5,1,6,1},		'Warmachine',		{ 'bitflag' }	},
	[19]	=	{ {}, {5,1,7,1},		'Xzomit',			{ 'bitflag' }	},

	[22]	=	{ {}, {6,1,0,1},		'Hippogryph',		{ 'bitflag' }	},
	[23]	=	{ {}, {6,1,1,1},		'Spectral Chair',	{ 'bitflag' }	},
	[24]	=	{ {}, {6,1,2,1},		'Spheroid',			{ 'bitflag' }	},
	[25]	=	{ {}, {6,1,3,1},		'Omega',			{ 'bitflag' }	},
	[26]	=	{ {}, {6,1,4,1},		'Coeurl',			{ 'bitflag' }	},
	[27]	=	{ {}, {6,1,5,1},		'Goobbue',			{ 'bitflag' }	},
	[28]	=	{ {}, {6,1,6,1},		'Raaz',				{ 'bitflag' }	},
	[29]	=	{ {}, {6,1,7,1},		'Levitus',			{ 'bitflag' }	},

	[32]	=	{ {}, {7,1,0,1},		'Adamantoise',		{ 'bitflag' }	},
	[33]	=	{ {}, {7,1,1,1},		'Dhalmel',			{ 'bitflag' }	},
	[34]	=	{ {}, {7,1,2,1},		'Doll',				{ 'bitflag' }	},
	[35]	=	{ {}, {7,1,3,1},		'Golden Bomb',		{ 'bitflag' }	},
	[36]	=	{ {}, {7,1,4,1},		'Buffalo',			{ 'bitflag' }	},
	[37]	=	{ {}, {7,1,5,1},		'Wivre',			{ 'bitflag' }	},
	[38]	=	{ {}, {7,1,6,1},		'Red Raptor',		{ 'bitflag' }	},
	[39]	=	{ {}, {7,1,7,1},		'Iron Giant',		{ 'bitflag' }	},

	[42]	=	{ {}, {8,1,0,1},		'Byakko',			{ 'bitflag' }	},
	[43]	=	{ {}, {8,1,1,1},		'Noble Chocobo',	{ 'bitflag' }	},
	[44]	=	{ {}, {8,1,2,1},		'Ixion',			{ 'bitflag' }	},
	[45]	=	{ {}, {8,1,3,1},		'Phuabo',			{ 'bitflag' }	},

	},	--	[[ COMPLETE ]]

--	Char Update ---------------------------------------------------------------

[0x0DF] = {

	[1]		=	{ { 'call', 0xFFF }, 								},
	[2]		=	{ {}, {4,4},		'ID'           					},
	[3]		=	{ {}, {8,4},		'HP'           					},
	[4]		=	{ {}, {12,4},		'MP'           					},
	[5]		=	{ {}, {16,4},		'TP'           					},
	[6]		=	{ {}, {20,2},		'Index'        					},
	[7]		=	{ {}, {22},			' HP %%'       					},
	[8]		=	{ {}, {23},			' MP %%'						},
	[9]		=	{ {}, {32},			'Main Job', {'job'}				},
	[10]	=	{ {}, {33},			'Main Level'					},
	[11]	=	{ {}, {34},			'Sub Job', {'job'}				},
	[12]	=	{ {}, {35},			'Sub Level'						},
	[13]	=	{ {}, {0x25,1,0,1},	'JM Unlocked',  {'bitflag'}		},
	[14]	=	{ {}, {0x25,1,1,1},	'Job Capped',  	{'bitflag'}		},
	[15]	=	{ {}, {0x24}, 		'Master Level' 					},

	},	--	[[ COMPLETE ]]

--	Data Download 4  ----------------------------------------------------------

[0x105] = {

	[1]		=	{ { 'call', 0xFFF }, 								},
	[2]		=	{ {}, {4,4},		'Price'        					},
	[3]		=	{ {}, {8,4},		'Count'        					},
	[4]		=	{ {}, {12,2},		'Tax Rate'     					},
	[5]		=	{ {}, {14,2},		'Item',			{'item', 'raw'}	},
	[6]		=	{ {}, {16},			'Item Index'					},

	},	--	[[ COMPLETE ]]


--	Ability Recasts -----------------------------------------------------------

[0x119] = {

	[1]		=	{ { 'call', 0xFFF }, 						},
	[2]		=	{ { 'loop', 30, 8, 0 },                     },
	[3]		=	{ {},  {15},  	'Ability'					},
	[4]		=	{ {},  {12,3},  'Timer'						},
	[5]		=	{ { 'end' },                                },

},	--	[[ COMPLETE ]]

}

return NewRules
