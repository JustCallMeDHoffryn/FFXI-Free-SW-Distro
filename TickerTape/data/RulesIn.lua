local AllRulesIn = {

--	NPC Update
	
	[0x00E] = T	{			--		Offset	bit		Name		format		logic		flag		decode		Info
					[1]		=	{	0,		0,	 	'ID',		'byte',		'none',		0,			'raw',		''},
					[2]		=	{	1,		0,	 	'Size',		'byte',		'none',		0,			'raw',		''},
					[3]		=	{	2,		0,	 	'Sync',		'rword',	'none',		0,			'raw',		''},
					[4]		=	{	4,		0,	 	'NPC',		'rdword',	'none',		0,			'entity',	''},
					[5]		=	{	8,		0,	 	'Index',	'rword',	'none',		0,			'raw',		''},
					[6]		=	{	10,		1,	 	'Flag',		'bit',		'set',		1,			'bool',		'[Position, Rotation, Walk]'	},
					[7]		=	{	12,		0,	 	'Position',	'special',	'use',		1,			'xyz',		''},
					[8]		=	{	10,		2,	 	'Flag',		'bit',		'set',		2,			'bool',		'[Claimer ID]'	},
					[9]		=	{	44,		0,	 	'Claimer',	'rdword',	'use',		2,			'player',	''				},
					[10]	=	{	10,		4,	 	'Flag',		'bit',		'set',		3,			'bool',		'[HP, Status]'	},
					[11]	=	{	30,		0,	 	'HP %%',	'byte',		'use',		3,			'raw',		''				},
					[12]	=	{	10,		8,	 	'Flag',		'bit',		'set',		4,			'bool',		'[Name]'		},
				},

--	Char Update
	
	[0x0DF] = T	{			--		Offset	bit		Name		format		logic		flag		decode		Info
					[1]		=	{	0,		0,	 	'ID',		'byte',		'none',		0,			'raw',		''	},
					[2]		=	{	1,		0,	 	'Size',		'byte',		'none',		0,			'raw',		''	},
					[3]		=	{	2,		0,	 	'Sync',		'rword',	'none',		0,			'raw',		''	},
					[4]		=	{	4,		0,	 	'ID',		'rdword',	'none',		0,			'raw',		''	},
					[5]		=	{	8,		0,	 	'HP',		'rdword',	'none',		0,			'raw',		''	},
					[6]		=	{	12,		0,	 	'MP',		'rdword',	'none',		0,			'raw',		''	},
					[7]		=	{	16,		0,	 	'TP',		'rdword',	'none',		0,			'raw',		''	},
					[8]		=	{	20,		0,	 	'Index',	'rword',	'none',		0,			'raw',		''	},
					[9]		=	{	22,		0,	 	'HP %%',	'byte',		'none',		0,			'raw',		''	},
					[10]	=	{	23,		0,	 	'HP %%',	'byte',		'none',		0,			'raw',		''	},
				},

	}

return AllRulesIn
