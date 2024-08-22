local AllRulesIn = {

--	NPC Update
	
	[0x015] = T	{			--		Offset	bit		Name		format		decode		Info
					[1]		=	{	0,		0,	 	'ID',		'byte',		'raw',		''},
					[2]		=	{	2,		0,	 	'Sync',		'rword',	'raw',		''},
					[3]		=	{	4,		0,	 	'Position',	'special',	'xyz',		''},
				},
	}

return AllRulesIn
