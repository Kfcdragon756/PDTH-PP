local replacements = {
	["tie_yourself_keybind"] = {
		english = "Tie/Untie yourself with skill",
		chinese = "用技能把自己绑起来/解绑",
		spanish = "Habilidad para Atarte/Desatarte a ti mismo",
	},
	["tie_yourself_help"] = {
		english = "Once you equpped fake surrender in game, you can Tie/Untie yourself with skill when pressed this key.",
		chinese = "在装备诈降专家技能时，点击该按键用技能把自己绑起来/解绑。",
		spanish = "Una vez tengas equipado la habilidad 'Rendición Teatral' en la partida, puedes atarte/desarte a voluntad cuando presionas esta tecla.",
	},
	["change_308_fov_zoom_keybind"] = {
		english = "Change M308 scope zoom",
		chinese = "M308倍镜倍率切换",
		spanish = "[M308] Cambiar el zoom de la mira",
	},
	["change_308_fov_zoom_help"] = {
		english = "You can press this button while handling M308, then you can change the M308's fov zoom.\n\n\nIndependent aiming setting is required to use this function.",
		chinese = "手持M308时轻击该按钮即可改变倍镜倍率。\n\n\n需要开启独立瞄准设置以生效。",
		spanish = "Cuando pulsas esta tecla mientras tienes el rifle M308 equipado, puedes cambiar el zoom del FOV.\n\n\nPara usar esta función necesitas configurar el FOV deseado en la opción de abajo.",
	},
	["m308_fov_zoom_set_keybind"] = {
		english = "M308 zoomed fov set",
		chinese = "M308高倍FOV设置",
		spanish = "[M308] Ajuste de zoom del FOV",
	},
	["m308_fov_zoom_set_help"] = {
		english = "The fov when M308 is zoomed.",
		chinese = "M308高倍镜的FOV。",
		spanish = "El zoom del FOV que tiene la mira del rifle M308 cuando estás apuntando.",
	},
	["m308_fov_zoom_sens"] = {
        english = "M308 zoomed sensitivity",
        chinese = "M308高倍灵敏度设置",
        spanish = "[M308] Ajuste de la sensibilidad del zoom",
    },
    ["m308_fov_zoom_sens_help"] = {
        english = "The sensitivity when M308 is zoomed.",
        chinese = "M308开镜时的灵敏度",
        spanish = "La sensibilidad que tienes cuando haces zoom con el M308.",
    },
	["des_m4"] = {
	chinese = "数据：控制性高：高精度：高射速：增伤6点： \n高射速，容易操控，精度高使得即使是略低一点的伤害也不妨碍其成为专业人员的第一选择。\n即使是没经过训练的菜鸟也能轻松使用。",
	english = "stats:high control:high accuracy:high firerate:gain 6 extra-damagee:\nHigh firerate,easy to control and high accuracy makes it a professional's priority one, although it has a little low damagee for its downside. \nEven an un-trained rookie can handle it easily.",
	spanish = "Estadísticas: Daño bajo : Retroceso bajo : Precisión alta : Candecia de fuego alta. \nSus buenas estadísticas hacen que los profesionales la elijan sobre otras armas. \nEl perk 'Munición AP' añade 6 de daño extra al cuerpo.",
	},
	["des_ak47"] = {
	chinese = "数据：较难控制：精度略低：中等射速：大威力：增伤5点： \n可靠，便宜，威力大是它的标志性描述。相比起来，精准度和射速的不足反而不那么像是一种缺陷。\n无需瞄准头部，只需命中即可获得不小收益。",
	english = "stats:low control:low accuracy:medium firerate:hi-power:gain 5 extra-damagee:\nReliable, cheap, powerful is it's symbolic description. It's lack of accuracy and firerate is not really like a kind of downside. \nNo need to aim for heads, hit their bodies can also earn much.",
	spanish = "Estadísticas: Daño medio : Mucho retroceso : Precisión baja : Cadencia de fuego intermedia. \nSu cadencia y precisión baja no son un problema, disparar al cuerpo es más eficiente. \nEl perk 'Munición AP' añade 5 de daño extra al cuerpo.",
	},
	["des_r870_shotgun"] = {
	chinese = "数据：威力巨大：中近距离：伤害衰减：低捡弹：增伤24点：	\n这把问世于2011年犯罪狂潮的霰弹枪以在中近距离极强的火力而闻名。 \n装载六颗弹丸的超重型霰弹能毁灭一切敢于与它作对的敌人。 \n射速略慢，射击时尽可能保证一击必杀。",
	english = "stats:extreme-power:medium-close range:damagee-falloff:low pickup:gain 24 extra-damagee:\nThis shotgun born in 2011 crimefest is famous for its extreme-firepower in medium-close range. \nThe 6-pellet packed ultra heavy shells can destroy anyone against it.",
	spanish = "Estadísticas: Daño alto : Arma de corto-medio alcance : El daño disminuye con la distancia : Recogida de munición escasa \nDispara cartuchos cargados con 6 perdigones muy pesados. \nEl perk 'Munición AP' añade 24 de daño extra al cuerpo.",
	},
	["des_m14"] = {
	chinese = "数据：高爆头倍率：精度极高：盾牌穿透：增伤30点： \n精准，头盔穿透能力强使它成为对自己枪法有自信的家伙的首选。 \n盾牌在它眼中宛如纸片，但防爆特警的面甲于它难以穿透。\n远距离战斗是它的主场。 ",
	english = "stats:high headshot multiplier:extreme accuracy:shield penetration:gain 30 extra-damagee:\nAccurate, and good penetration makes it the priority one for head-shooters, unluckily it's hard to shoot through bulldozer's visor for m308.",
	spanish = "Estadísticas: Daño medio : Multiplicador por disparo a la cabeza alto : Precisión casi perfecta : Perfora el Escudo de los policias : NO puede perforar el visor de los bulldozers. \nEl arma perfecta para esa gente que sabe buscar cabezas. \nEl perk 'Munición AP' añade 30 de daño extra al cuerpo.",
	},
	["des_hk21"] = {
	chinese = "数据：精度较低：较高射速：强压制力：手持与射击时减速：威力强大：增伤15点： \n不赖的精度，高射速与高威力让它变成了一头猛兽。近距离没有任何人可以抵挡得住这家伙的扫射。\n若有人敢来犯，就用80发大弹盒让他们瞧瞧厉害。",
	english = "stats:low accuracy:high firerate:high suppression ability:reduce movement speed while wielded and shooting:hi-power:gain 15 extra-damagee: \nOkay accuracy, high firerate and high firepower makes it a beast. No one can live under it's strafing at close range. \nGive'em a lesson with your 80 rounds box magtazine if they get near.",
	spanish = "Estadísticas: Daño alto : Precisión baja : Cadencia de fuego alta : Supresión alta : Sostenerlo y disparar ralentiza la velocidad de movimiento : Cargador enorme de 80 rondas. \nNadie sobrevive estando cerca de esta bestia. \nEl perk 'Munición AP' añade 15 de daño extra al cuerpo.",
	},
	["des_beretta92"] = {
	chinese = "数据：高精度：高射速：增伤7点： \n这把带着消音器的手枪终于迎来了春天。 \n改良以后的枪管和弹药现在能在不增加后坐力的前提下增加精度和威力。其具有的高射速让使用者能快速造成伤害。 \n不论是警察，特工，安保人员，甚至是劫匪都对其非常满意，适合新手使用。",
	english = "stats:high accuracy:high firerate:gain 7 extra-damagee: \nBeing easy to control, great firepower, and best firerate makes it a great weapon for rookies.",
	spanish = "Estadísticas: Daño bajo : Precisión alta : Cadencia de fuego alta. \nEstadísticas exelentes para una pistola, el arma ideal para los novatos. \nEl perk 'Munición AP' añade 7 de daño extra al cuerpo.",
	},
	["des_c45"] = {
	chinese = "数据：威力大：精度略低：携弹量少：增伤10点： \n这把问世于2011年的.45口径手枪在现在推出了最新的改良版本。 \n它的威力和精度现在完全足够应付绝大多数敌人，代价是八发稀烂的弹匣。 \n这把改良型武器受到绝大多数群体的欢迎。",
	english = "stats:hi-power:low accuracy:low ammo:gain 10 extra-damagee: \nCompared to The original one, this MK II pistol is more worth using.\nIt's firepower and accuracy now is enough for dealing with most enemies, but it has a only-8-round magazine. \nThis improved weapon now is now welcomed by the vast majority of shooters.",
	spanish = "Estadísticas: Daño alto : Precisión baja : Poca munición : Cargador pequeño de solo 8 rondas. \nSu daño y precisión ahora son suficientes para lidiar con la mayoría de enemigos. \nEl perk 'Munición AP' añade 10 de daño extra al cuerpo.",
	},
	["debug_c45"] = {
	chinese = "CROSSKILL .45 MK II手枪",
	english = "CROSSKILL .45 MK II PISTOL",
	spanish = "PISTOLA CROSSKILL .45 MK II",
	},
	["des_raging_bull"] = {
	chinese = "数据：威力巨大：精度高：携弹量少：难以控制：增伤50点： \n.44MAGNUM弹药注定了这把枪将会非同凡响，这把枪原本用于对付大型动物。 \n巨大的威力让它所向披靡。",
	english = "stats:extreme-power:high accuracy:low ammo:hard to control:gain 50 extra-damagee: \n.44MAGNUM rounds makes it will not be a common pistol. \nThis weapon is designed to deal with larger animals. \nExtreme firepower will make it unstoppable.",
	spanish = "Estadísticas: Daño descomunal : Precisión casi perfecta : Poca munición : Difícil de controlar : EL calibre .44 MAGNUM hace que no sea común encontrarse con munición. \nEste arma está diseñada para cazar animales grandes. \nEl perk 'Munición AP' añade 50 de daño extra al cuerpo.",
	},
	["des_glock"] = {
	chinese = "数据：精度略低：极高射速：强压制力：增伤5点： \nSTRYK是一把采用大量聚合物制造的自动手枪，其因在近距离极强的爆发性输出而闻名。 \n军方在用，一些地区的警察在用，黑帮也在用，现在轮到你了。",
	english = "stats:low accuracy:extreme high firerate:high supression ability:gain 5 extra-damagee: \nSTRYK is an automatic pistol made of large amount of polymer. It's famous for bursting lots of damagee at close range. \nGive'em a pocket surprise.",
	spanish = "Estadísticas: Daño medio : Precisión baja : Cadencia de fuego demasiado alta : Supresión alta. \nPistola automática hecha de una grán cantidad de polímero. \nEs la ideal para inligir mucho daño a cortas distancias. \nEl perk 'Munición AP' añade 5 de daño extra al cuerpo.",
	},
	["des_m79"] = {
	chinese = "数据：威力巨大：只能从弹药包获取弹药：具有爆炸性： \n沃尔夫到底从哪里搞到的这东西？ \n从弹药包获取一发弹药会直接扣取75%的弹药量。爆炸范围非常宽广，可以炸死多数敌对单位，在需要的时候用吧。",
	english = "stats:extreme-power:gain ammo only from ammo-bag:explosive: \nObtaining a single round of grneade from an ammo bag will directly deduct 0.75 weapons' ammunition of the ammo amount which ammobag contains. \nExplode radious is very wide and can instantly kill most enemie units.",
	spanish = "Estadísticas: Daño descomunal : Solo puedes reponer tus granadas con bolsas de munición. \nAl interactuar con una bolsa de munición obtienes una sola granada y vas a cosumir el 0.75 de la munición totál. \nEl radio de explosión ahora es más ámplio y mata a la mayoría de enemigos.",
	},
	["des_mac11"] = {
	chinese = "数据：低精准度：强压制力：较难控制：续航偏弱：增伤15点： \n高射速，高伤害，大弹匣。\n拿上它，你就会让你的敌人后悔出生在这个世界上。",
	english = "stats:low accuarcy:high suppresion ability:hard to control:low endurance:gain 15 extra-damagee:\nHigh firerate, High power, Big magazine. \nBecome a moster and let cops regret wake up this morning.",
	spanish = "Estadísticas: Daño alto : Precisión baja : Supresión alta : Difícil de controlar : Estabilidad baja : Cargador grande. \nEl arma por excelencia para eliminar Bulldozers. \nEl perk 'Munición AP' añade 15 de daño extra al cuerpo.",
	},
	["des_mp5"] = {
	chinese = "数据：高精度：高爆头倍率：低基础伤害：\n紧凑型-5冲锋枪因为其紧凑，优秀的的可控性和精准度受到反恐部队的喜爱。\n但是较差的护甲穿透力让这把枪对于使用者的操作水平要求较高。",
	english = "stats:high accuracy:high headshot multiplier:low firepower: \nCompact-5 machine gun is welcomed by anti-terriorst team for it's compactness, great control and accuracy. \nBut low armor penetration makes this weapon being more demanding for the user's shooting skill.",
	spanish = "Estadísticas: Daño medio : Precisión alta : Multiplicador por disparo a la cabeza alto : Cadencia de fuego baja. \nEl subfusíl favorito de las fuerzas del órden. \nLa penetración de armadura corporal es baja por lo que se recomienda apuntar a la cabeza.",
	},
	["des_mossberg"] = {
	chinese = "数据：快速行动：威力巨大：伤害衰减：打击范围较大：极强击退力：手持时速度增加： \n火车头 12G以更少的弹容量和更差的精准度为代价获得了极高的爆发能力。 \n使用装有14发弹丸的鹿弹，牺牲单颗弹丸火力，但容错率变得更高了。 \n务必在近距离使用。",
	english = "stats:quick action:extreme-power:damagee falloff:wide spread:strong knockback:increase movement speed while wielded: \nLocomotive 12G gains terrific ability to burst damagee in cost of lower capacity and worse accuracy. \nIt uses buckshot contains 14 pellets, missing one pellet will never be a deal.",
	spanish = "Estadísticas: Daño descomunal : Arma de corto alcance : El daño disminuye con la distancia : Precisión mediocre : Cadencia de fuego alta : Dispara en forma de cono amplio : Retroceso fuerte : Tenerla equipada incrementa tu velocidad de movimiento un 5%. \nDispara cartuchos buckshot cargados con 14 perdigones.",
	},
	["debug_thick_skin"] = {
	chinese = "重型护甲",
	english = "heavy armor",
	spanish = "Armadura Robusta",
	},
	["des_thick_skin"] = {
	chinese = "重型护甲为玩家增加100点血量与30点护甲。\n代价是行走速度减慢15%,奔跑速度减慢10%，护甲回复时间延长一秒。\n这种护甲能让你近距离硬抗防爆特警一枪而不倒地。",	
	english = "Heavy armor provides 100 hp and 30 ap. \nFor what it costs, your walking speed is decreased by 15%, running speed decreased by 10%, and armor regen time is increased by 1 second. \nThis kind of armor can allow you to take a Bulldozer's shotgun shot without bleeding out.",
	spanish = "Llevar la Armadura Robusta te provee 100HP y 30AP. \n¿Pero a qué costo? Tu velocidad al caminar se reduce en un 15%, la de correr un 10% y el tiempo de regeneración es incrementado por 1 segundo. \nEste tipo de armadura te permite aguantar un disparo de escopeta de los Bulldozers y seguir vivo.",
	},
	["des_extra_start_out_ammo"] = {
	chinese = "每把武器额外获得一个弹匣（GL40不享受该加成）。",
	english = "Provide a extra magazine per weapon.(In exception of GL40)",
	spanish = "Le da un cargador extra a cada arma que tengas. \nEl GL40 no se beneficia de esta habilidad.",
	},
	["des_toolset"] = {
	chinese = "减少45%互动（包括援助他人）所需时长。",
	english = "Reduce interaction(including reviving someone) time by 45%.",
	spanish = "Reduce el tiempo de interacción en un 45%. \nTambién aplica cuando revives a alguien.",
	},
	["debug_equipment_extra_cable_tie"] = {
	chinese = "诈降专家",
	english = "Fake surrender",
	spanish = "Rendición Teatral",
	},
	["des_extra_cable_tie"] = {
	chinese = "减少玩家携带的绑带数量至3。\n但你可以通过按下【用技能把自己绑起来/解绑】按键以将自己绑起来或者解绑自己，此时你不会被视作目标且不会受伤。\n把自己绑起来将会消耗一个绑带，不能在倒地，被电击，被制服或被铐住时使用，孤身一人时使用会导致劫案失败。",
	english = "Decrease player's cable tie amount to 3. \nHowever, you can press [Tie/Untie yourself with skill] button to tie or untie yourself.\nUsing this skill will cost a cable tie. You cannot use this skill on you downed. Use this skill while you are the last man standing will cause the failure of the heist.",
	spanish = "Disminuye las bridas del jugador a 3. \nPuedes [Atarte/Desatarte] a voluntad pulsando la tecla asignada, hacerlo te cuesta una brida. \nNo puedes usar ésta habilidad cuando estás abatido/sangrando \nUsar ésta habilidad mientras eres el último con vida causará que falles la misión.",
	},
	["des_protector"] = {
	chinese = "给所有队友提供9点护甲值。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Provide all teammates 9 armor points.",
	spanish = "Aumenta en 9 los puntos de armadura para tus compeñeros de equipo.",
	},
	["des_more_ammo"] = {
	chinese = "给所有队友提供捡弹率加成。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Provide all teammates ammo pickup multipliers.",
	spanish = "Aumenta la recogida de munición para tus compañeros de equipo.",
	},
	["des_more_blood_to_bleed"] = {
	chinese = "使队友的倒地血量增加50%，并使队友的可被援助时间与倒地的援助时间惩罚增加50%。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Your teammates' down timer along with down timer penalty and health point on downed will be increased by 50%.",
	spanish = "Aumenta el tiempo y la vida de tus compañeros de equipo en un 50% cuando están desangrándose.",
	},
	["debug_upgrade_aggressor"] = {
	chinese = "穿甲弹药",
	english = "AP rounds",
	spanish = "Munición AP",
	},
	["des_aggressor"] = {
	chinese = "队友的武器非爆头伤害增加。具体数值请见武器介绍，且增加的伤害不会影响对防爆特警面甲的伤害。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Your teammates' non-headshot damagee will be increased and the extra damagee will not affect the actual damagee against bulldozer's visor.",
	spanish = "Tus compañeros de equipo infligen más daño al cuerpo de los enemigos, NO aplica al daño a la cabeza ni al visor de los bulldozers. \n\nEl daño adicional que ofrece este perk está en las descripciones de las armas.",
	},
	["des_speed_reloaders"] = {
	chinese = "队友的换弹速度提升15%。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Your teammates' reload speed is increased by 15%.",
	spanish = "Aumenta el tiempo de recarga en un 15% para los compañeros de equipo.",
	},
	["des_sharpshooters"] = {
	chinese = "队友的武器精准度提升10%，且武器爆头倍率增加0.25。\n爆头倍率计算方式为：武器爆头倍率*敌人爆头倍率*难度爆头倍率。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Your teammates' weapon accuracy is increased by 10% and weapons' headshot multipliers are increased by 0.25.",
	spanish = "Para tus compañeros de equipo aumenta la precisión de sus armas en un 10% y el multiplicador por disparo a la cabeza en 0.25.",
	},
	["des_mr_nice_guy"] = {
	chinese = "给队友提供现金加成。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Provide your teammates extra cash multiplier.",
	spanish = "Proporciona a tus compañeros de equipo un multiplicador adicional de dinero/xp.",
	},
	["des_trip_mine"] = {
	chinese = "激光绊雷可以用作阻挡敌人的陷阱使用。\n你也可以将其放在某个角落，需要的时候射一枪，就能解决不少麻烦。\n威力相对于GL40来说略高，用来对付防爆特警的面甲是不错的选择。\n玩家最多携带10个激光绊雷，其可以伴随捡弹和使用弹药包补充弹药补充，而且不会额外消耗弹药。",
	english = "Trip-mines can be used as traps for stopping these cops.\nThe explotion power is a bit high compared to GL40, It's a good choice dealing with bulldozer's visors. \nA player can take 10 trip mines, and it can be refilled by picking up ammoboxes, or just interact with an ammo bag, without consuming ammo.",  
	spanish = "Las Minas con Sensor son trampas letales. \nLa explosión es más fuerte en comparación con el GL40. \nPuedes llevar hasta 10 minas simultáneamente. \nPueden reabastecerse agarrando la munición que dejan los enemigos muertos, o interactuando con una bolsa de munición sin consumir cargas.",
	},
	["des_ammo_bag"] = {
	chinese = "战斗时，弹药必不可少。带上两个弹药包可以有效缓解弹药压力，不是吗？ \n一个弹药包可以提供750%的武器弹药，并且一个玩家可以携带两个弹药包。",
	english = "Ammunition is necessary for combat. Two ammo bags are effective for reducing pressure of lacking of ammo, isn't it? \nAn ammo bag can fill 7.5 weapons' ammunition, and a player can carry 2 ammo bags.",
	spanish = "La munición es necesaria para poder seguir en combate. Dos bolsas son suficientes para combatir la falta de munición ¿Verdad? \nEl jugador lleva 2 bolsas de munición y cada una tiene una carga del 750%.",
	},
	["des_sentry_gun"] = {
	chinese = "步哨机枪总是可以帮助你清理一大群敌人。什么，一个不够？那么三个呢？ \n布置下来以后，步哨机枪可以自动锁定并攻击敌人，直到它被破坏或子弹耗尽为止。",
	english = "Sentry guns can always help you to deal with a massive amounts of enemies. Wait, only one sentry is not enough? What about...three? \nOn deployed, the sentry gun can automatically lock then shoot the enemies, until it's destroyed or runs out of ammo.",
	spanish = "Las Torretas Sentinelas pueden ayudarte a combatir grandes grupos de enemigos. \n¿Una torreta no es suficiente? ¿¡Que te parecen... Tres!? \nUna vez desplegada la torreta automáticamente apuntará y disparará a los enemigos hasta que se quede sin munición o sea destruída.",
	},
	["des_doctor_bag"] = {
	chinese = "医疗包总是能让你满血复活，而且还能重置你的倒地次数。 \n一个医疗包只能用三次，一个玩家可以携带两个医疗包。",
	english = "A medic bag can always refill your health and reset your down times. \nA medic bag can be used for 3 times, a player can carry 2 medic bags.",
	spanish = "Las bolsas médicas pueden abastecerte de vida y reiniciar tu contador de caídas/bajas. \nPuedes llevar 2 bolsas médicas y cada una tiene 3 usos.",
	},
	["mutator_combine_assault"] = {
	chinese = "联合进攻",
	english = "COMBINE ASSAULT",
	spanish = "ASALTO COMBINE",
	},
	["mutator_combine_assault_help"] = {
	chinese = "好消息，弟兄们，那些条子已经知道他们战胜不了我们了。\n\n\n坏消息，那帮条子摇来了一大号狗日的雇佣兵和FBI探员来干我们。\n\n\n\n突击时，会生成大量更难以对付的黑水雇佣兵与FBI探员。\n\n\n\n只在枪林弹雨，枪林弹雨145+或者枪林弹雨193+生效。",
	english = "Good news, gang, these cops already know they cannot defeat us. \n\n\nBad news, these cops' calling lots of stupid murkies and FBI agents to fuck us. \n\n\n\nMassive murkywater mercenaries and FBI agents will spawn during assault, they are way harder to handle. \n\n\n\nOnly avilable at Overkill, Overkill 145+ or Overkill 193+ difficulty.",
	spanish = "Pandilla buenas noticias, los policias se han dado por vencido y saben que no pueden atraparnos. \n\n\n¡Las malas son que ahora solicitaron apoyo de los putos Mercenarios Murky y agentes del FBI para jodernos! \n\n\n\nLos Mercenarios de Murkywater y Agentes del FBI van a spawnear masivamente durante el asalto, también son más duros de combatir. \n\n\n\nSolo disponible en la dificultad Overkill, Overkill 145+ y Overkill 193+.",
	},
	["mutator_combine_assault_motd"] = {
	chinese = "突变模式‘联合进攻’已开启，装备了更高级武器的黑水雇佣兵和FBI探员将会生成。",
	english = "mutator 'COMBINE ASSAULT' activated, murkywater mercenaries and FBI agents with better weapons will spawn.",
	spanish = "El mutador 'ASALTO COMBINE' está activado, los Mercenarios de Murkywater y los Agentes del FBI tienen mejores armas y van a spawnear.",
	},
	["mutator_exercised_cops"] = {
	chinese = "高级训练",
	english = "EXERCISED COPS",
	spanish = "POLICIAS DOPADOS",
	},
	["mutator_exercised_cops_help"] = {
	chinese = "弟兄们，大事不妙。\n\n\n这帮条子专门针对我们的战术进行了训练，我们以后做事得多加注意一点了。\n\n\n\n重甲水军生成量变多，射击水平变强且躲避水平变强。他们将会成为你的噩梦。\n\n\n\n只在枪林弹雨，枪林弹雨145+或者枪林弹雨193+生效。",
	english = "Gang, we got trouble. \n\n\nThese cops just trained aiming at our tactics, we gotta pay more caution for further moves. \n\n\n\nThe spawn rate of heavy swats is increased, they will shoot more accurately and dodge better. They sure will become your nightmare. \n\n\n\nOnly avilable at Overkill, Overkill 145+ or Overkill 193+ difficulty.",
	spanish = "Pandilla estámos en apuros. \n\n\nEstos policias entrenaron demasiado y nos tienen fichados, tenémos que ser más precavidos en cuanto a nuestros movimientos. \n\n\n\nEl spawn de los Heavy SWATS está incrementado, ahora apuntan y esquivan mucho mejor. Se van a convertir en tu pesadilla. \n\n\n\nSolo disponible en la dificultad Overkill, Overkill 145+ y Overkill 193+.",
	},
	["mutator_exercised_cops_motd"] = {
	chinese = "突变模式‘高级训练’已开启，准备好被重甲水军按着打吧。",
	english = "mutator 'EXERCISED COPS' activated, ready to get fucked by heavy swats.",
	spanish = "El mutador 'POLICIAS DOPADOS' está activado, prepárate ser cogido por Heavy SWATS (rico)",
	},
	["mutator_full_speed"] = {
	chinese = "全速出击",
	english = "OUTRUN",
	spanish = "AZUCARADO",
	},
	["mutator_full_speed_help"] = {
	chinese = "我怀疑条子们磕了点奇怪的东西，他们今天怎么跑这么快？\n\n\n不管了，既然他们先磕，那我们也磕点东西，要不然可不就输了！弟兄们，准备好心脏爆炸吧！\n\n\n\n玩家，敌人，与AI队友的移速乘以3。",
	english = "I doubt cops had something weird today, they just run too fast...\n\n\nOkay, fuck it. Let's just get some drugs and prepare for a heart attack!\n\n\n\nPlayer, enemies, and bot teammates' movement speed is multiplyed by 3.",
	spanish = "No creo que esos policias tenga algo raro hoy, simplemente corren demasiado rápido...\n\n\nBueno, no hay otra opción más que... ¡Pincharse y estár preparado para tener un atáque cardíaco!\n\n\n\nLa velocidad de los jugadores, enemigos y los bots aliados está multiplicada por 3.",
	},
	["mutator_full_speed_motd"] = {
	chinese = "突变模式‘全速出击’已开启，每一个人都会跑得非常快。",
	english = "GOTTA GO FAST",
	spanish = "YIPPEE-KI-YAY MOTHERFUCKER",
	},
	["mutator_zhouji"] = {
	chinese = "肘击高手",
	english = "MELEE EXPERT",
	spanish = "EXPERTO EN COMBATE CUERPO A CUERPO",
	},
	["mutator_zhouji_help"] = {
	chinese = "我不需要太多子弹，子弹就留给那些重型单位吧。\n\n\n我要用枪托给那些傻逼点颜色瞧瞧。\n\n\n\n所有武器初始只有一个弹匣，所有难度的无敌帧增加0.3秒，所有武器的近战伤害锁定为150，击倒指数为10且捡弹率减少50%。\n\n和炸翻天与无暇搜刮冲突。",
	english = "I don't need too much rounds, they are for heavier ones. \n\n\nI'm gonna teach'em a lesson...with my gun stock! \n\n\n\nEvery weapon has only one magazine for default, each difficulty's grace period is increased by 0.3 seconds, every weapons' melee damagee is locked to 150, knockback effect to 10 and has 50% penalty for ammo-pickup rate.\n\nConflicts with KABOOM and NO TIME FOR SEARCHING mutator.",
	spanish = "No necesito munición, eso es para maricas. \n\n\nVoy a enseñarles una lección que nunca olvidarán... ¡La culata de mi arma es suficiente! \n\n\n\nCada arma solo tiene un cargador por defecto, el periodo de gracia de cada dificultad se incrementa en 0.3 segundos, el daño que infligen todas las culatas está bloqueado a 150, el efecto de aturdimiento a 10 y tienes una penalización del 50% al recoger munición.\n\nEste mutador tiene conflicto con los mutadores '¡KABOOM!' y 'NO HAY TIEMPO QUE PERDER'.",
	},
	["mutator_zhouji_motd"] = {
	chinese = "突变模式‘肘击高手’已开启，用肘击肘死你的敌人吧。",
	english = "BULLETS ARE JUST FOR PUSSIES.",
	spanish = "LAS BALAS SON PARA LOS MARICONES.",
	},
	["mutator_expert_mode"] = {
	chinese = "专家模式",
	english = "EXPERT MODE",
	spanish = "MODO EXPERTO",
	},
	["mutator_expert_mode_help"] = {
	chinese = "专家模式仅供真正的专家游玩。\n\n\n\nGL40已禁用。\n\n\n换弹时会抛弃弹匣内剩余弹药，但换弹速度提高10%。\n\n\n泰瑟特警的电击不再自动换弹，且被电击到倒地的时间减少50%。\n\n\n携带霰弹枪的单位现在没有瞄准延迟了。\n\n\n幻影特工会在制服劫匪时留下烟雾弹。",
	english = "THE EXPERT MODE is only provided for real experts. \n\n\n\nGl40 is disabled.\n\n\nYou will lost your round remaining in clip when reloaded, but reload speed is increased by 10%. \n\n\nTasers' eletric shock no longer auto-reload, and getting shocked will let you get downed 50% faster. \n\n\nNo aim-delay for shotgunners. \n\n\nCloaker will drop a smoke grneade when he cloaked a heister. ",
	spanish = "EL MODO EXPERTO está diseñado para verdaderos jugadores. \n\n\n\nEl GL40 está deshabilitado.\n\n\nVas a perder las rondas restantes de tu cargador, pero tu velocidad de recarga incrementa un 10%. \n\n\nLos Tasers ya no recargan tu arma automáticamente cuando te electrocutan y te incapacitan un 50% más rápido. \n\n\nEl apuntado de los escopeteros es instantáneo. \n\n\nLos Cloakers sueltan una granada de humo cuando patean a un jugador.",
	},
	["mutator_expert_mode_motd"] = {
	chinese = "突变模式‘专家模式’已开启。技术水平不过关的人不应该在这个大厅里呆着。",
	english = "mutator 'EXPERT MODE' activated, you should make sure that you are a professional.",
	spanish = "El mutador 'MODO EXPERTO' está activado, ¡WOW! ¡Débes ser un profesional!",
	},	
	["mutator_no_time_for_searching"] = {
	chinese = "无暇搜刮",
	english = "NO TIME FOR SEARCHING",
	spanish = "NO HAY TIEMPO QUE PERDER",
	},
	["mutator_no_time_for_searching_help"] = {
	chinese = "弟兄们，这次十万火急！\n\n\n这次应该没时间从条子身上搜刮弹药了，多带点！\n\n\n\n敌人死亡不会掉落可拾取的弹药盒，且玩家可携带弹药量增加。\n\n与炸翻天和肘击高手冲突。",
	english = "Gang, we got a situation! \n\n\nWe have no time for searching ammo from these dead cops, just carry more AMMO! \n\n\n\nAmmoclip will not spawn on enemies dead, and players' start out ammo is increased.\n\nConflicts with KABOOM and MELEE EXPERT mutator.",
	spanish = "Pandilla ¡Estámos en problemas! \n\n\nNo tenemos tiempo para buscar munición de esos cadáveres ¡Simplemente llevemos más munición! \n\n\n\nLos enemigos muertos no dejarán caér munición y la munición con la que aparecen los jugadores está incrementada.\n\nEste mutador tiene conflicto con los mutadores '¡KABOOM!' y 'EXPERTO EN COMBATE CUERPO A CUERPO'.",
	},
	["mutator_no_time_for_searching_motd"] = {
	chinese = "突变模式‘无暇搜刮’已开启。别指望从条子尸体身上捡到奇奇怪怪的子弹了。",
	english = "mutator 'NO TIME FOR SEARCHING' activated, cops will not spawn ammoclip on they get killed.",
	spanish = "El mutador 'NO HAY TIEMPO QUE PERDER' está activado, los policias no dejaran caér cajas de munición al morir.",
	},
	["mutator_kaboom"] = {
	chinese = "炸翻天",
	english = "KABOOM",
	spanish = "¡KABOOM!",
	},
	["mutator_kaboom_help"] = {
	chinese = "“今天让那帮傻逼条子吃点好吃的！”\n\n\n“沃尔夫，你这个傻逼！这就是你他妈连其他弹药都不带的理由？都怪你，现在我们只有筒子和手枪能用的，你一个人滚去吃屎吧！”\n\n\n\nGL40可以捡弹，换弹更快，但以伤害更低为代价。\n\n\n只能使用手枪和GL40，其他武器全部没有子弹。\n\n与肘击高手和无暇搜刮冲突。",
	english = "What makes me a good demoman?\n\n\nWolf, you fucking moron! Is this the reason you don't carry other fucking ammunition? It's all your fault that we can only use Grenade launcher and a pistol now, go eat shit yourself!\n\n\n\nGL40 can now pickup ammo, reload faster in cost of lower damagee.\n\n\nOnly pistols and GL40 are availiable, No ammo for other weapons.\n\nConflicts with MELEE EXPERT and NO TIME FOR SEARCHING mutator.",
	spanish = "¿Que es lo que me hace un buen demoledor?\n\n\n¡Wolf, psicótico de mierda! ¿Ésta es la razón por la que no trajiste otro tipo de munición? Por tu culpa solo podemos usar el Lanzagranadas y la Pistola, si no morimos por esto ¡Te mataré con propias mis manos!\n\n\n\nEl GL40 puede recoger munición del suelo, ahora recarga más rápido a costa de que su daño es menor.\n\n\nSolo las pistolas y el GL40 están disponibles. No hay munición para otras armas.\n\nEste mutador tiene conflicto con los mutadores 'NO HAY TIEMPO QUE PERDER' y 'EXPERTO EN COMBATE CUERPO A CUERPO'.",
	},
	["mutator_kaboom_motd"] = {
	chinese = "突变模式‘炸翻天’已开启。把这些傻逼全炸死！",
	english = "KA BOOM",
	spanish = "MICHAEL BAY",
	},
	["mutator_better_enemy_lmg"] = {
	chinese = "敌方机枪加强",
	english = "BETTER ENEMY LMG",
	spanish = "AMETRELLADORAS ENEMIGAS SUPERIORES",
	},
	["mutator_better_enemy_lmg_help"] = {
	chinese = "啊，又是一个扛着破烂机枪的防爆特警——等等他今天怎么射这么快？！\n\n\n兄弟们快躲起来，随便找个掩体，快！\n\n\n\n敌方布伦纳-21的射速加快。简单难度不启用。",
	english = "Ah, another bulldozer with shitty machine gun----WAIT HOW CAN HE SHOOT THIS FAST TODAY?!\n\n\nTAKE COVER GANG, FIND ANYTHING TO HIDE, HURRY!\n\n\n\nEnemy Breener-21's fire rate is increased. Does not apply on Easy difficulty.",
	spanish = "Ah que bien... otro Bulldozer con una LMG de juguete nada nuevo--- ¿¡QUÉ!? ¿¡PORQUÉ HOY ESTÁN DISPARANDO DEMASIADO RÁPIDO!?\n\n\n¡CÚBRANSE, APÚRENSE, ENCUENTREN UN LUGAR SEGURO!\n\n\n\nLa cadencia del arma Brenner-21 enemiga está aumentada. \n\nNo aplica a la dificultad Fácil.",
	},
	["mutator_better_enemy_lmg_motd"] = {
	chinese = "突变模式‘敌方机枪加强’已开启。小心敌方携带机枪的单位。",
	english = "mutator 'BETTER ENEMY LMG' activated, watch out for these units who carring LMGs.",
	spanish = "El mutador 'AMETRELLADORAS ENEMIGAS SUPERIORES' está activado, ten cuidado si ves a alguien con una LMG.",
	},
	["mutator_dozers_on_street"] = {
	chinese = "防爆特警过马路",
	english = "DOZERS ON STREET",
	spanish = "¡BULLDOZERS, POR FAVOR FRENE!";
	},
	["mutator_dozers_on_street_help"] = {
	chinese = "啊，马特那个混账狗东西，这次就别想跑掉了......等等，那他妈是什么？\n\n\n那他妈是个防爆特警！！！！！\n\n\n\n防爆特警会在热火街头的防御阶段生成。\n\n\n\n只在枪林弹雨，枪林弹雨145+或者枪林弹雨193+生效。",
	english = "Ah, such a cock sucker matt is, he will NOT get away this time......wait a minute, WHAT THE FUCK IS THAT?\n\n\nIT'S A MOTHER FUCKING BULLDOZER!!!!!\n\n\n\nBulldozers will spawn during BLOCKADE stage.\n\n\n\nOnly avilable at Overkill, Overkill 145+ or Overkill 193+ difficulty.",
	spanish = "Otra vez el hijo de puta de Matt, ésta vez no se escapará... espera ¿¡QUÉ MIERDA FUÉ ESO!?\n\n\n¡¡¡ES OTRO PUTO BULLDOZER!!!\n\n\n\nLos Bulldozers pueden spawnear durante la fase de BLOQUEO.\n\n\n\nSolo disponible en la dificultad Overkill, Overkill 145+ y Overkill 193+.",
	},
	["mutator_dozers_on_street_motd"] = {
	chinese = "突变模式‘防爆特警过马路’已开启。过马路前看看有没有防爆特警！",
	english = "mutator 'DOZERS ON STREET' activated, check if there's dozers before crossing the road!",
	spanish = "El mutador '¡BULLDOZERS, POR FAVOR FRENE!' está activado ¡Recuerde mirar hacia los lados antes de cruzar la calle!",
	},
	["mutator_stealth_marksman"] = {
	chinese = "超隐蔽狙击手",
	english = "STEALTH MARKSMAN",
	spanish = "TIRADOR ENCUBIERTO",
	},
	["mutator_stealth_marksman_help"] = {
	chinese = "沃尔夫，你他妈看见那傻逼从哪射的不？！\n\n\n我他妈看不见！看不见！看不见！！！！\n\n\n\n狙击手装备不产生红色轨迹的M308，更难以发现。\n\n在毫不留情劫案不可用。",
	english = "WOLF, DID YOU SEE THAT MOTHERFUCKER WHO JUST SNIPE US?!\n\n\nI CAN'T SEE! CAN'T SEE! CAN'T SEE!!!!\n\n\n\nSnipers will equip M308s which will not cause red traces.\n\nUnavailiable in NO MERCY heist.",
	spanish = "¿¡WOLF, VISTE AL BASTARDO QUE NOS ACABA DE DISPARAR!?\n\n\n¡NO LO VEO! ¿¡DONDE ESTÁ!?\n\n\n\nLos Snipers enemigos ahora están equipados con un M308 que no causa trazados rojos/naranjas.\n\nNo disponible en 'NO MERCY' (xd)",
	},
	["mutaotr_stealth_marksman_motd"] = {
	chinese = "狙佬呢？！",
	english = "CAN YOU FIND THE SNIPERS?",
	spanish = "¿PUEDES ENCONTRAR ALGÚN SNIPER?",
	},
	["mutator_agents_vs_fbi"] = {
    chinese = "面具特工大战FBI探员",
    english = "PAYDAY GANG AGENTS VS. FBI AGENTS",
    spanish = "AGENTES PAYDAY VS. AGENTES DEL FBI",
    },
    ["mutator_agents_vs_fbi_help"] = {
    chinese = "探员们，虽然我不想让各位兄弟受苦，但是不可否认的是为了轻便起见，各位探员只能带上手枪。\n\n\n不过好处就是对面也不会派太多重火力——吧？\n\n\n\n非地图事件的敌人只会生成幻影特工与FBI探员。\n\n\n防爆特警面甲血量大幅度降低。\n\n\n\n不可在枪林弹雨193+难度下启用。\n与肘击高手，高级训练，联合进攻，炸翻天，无暇搜刮突变模式冲突。",
    english = "Agents, I don't wanna let you suffer, but for lightness, I think you guys can only carry a pistol.\n\n\nAnd they won't send heavy firepower to you...right?\n\n\n\nNon-map-scripted spawned enemies will only be Cloakers and FBI agents.\n\n\n Bulldozer's visor Health massively decreased.\n\n\n\nUnavailiable on Overkill 193+ difficulty.\nConflicts with MELEE EXPERT, EXERCISED COPS, COMBINE ASSAULT, KABOOM, and NO TIME FOR SEARCHING mutators.",
    spanish = "Agentes, que tierno... No quiero que sufran. Para estar ligeros iremos solo con nuestras pistolas.\n\n\nNo enviarán artillería pesada... ¿Verdad?\n\n\n\nLos únicos enemigos 'No-Scripteados' que pueden spawnear son los Cloakers y Agentes del FBI.\n\n\n La vida del visor de los Bulldozers se disminuye considerablemente.\n\n\n\nNo disponible en Overkill 193+.\n\nEste mutador tiene conflicto con los mutadores 'EXPERTO EN COMBATE CUERPO A CUERPO', 'POLICIAS DOPADOS', 'ASALTO COMBINE', '¡KABOOM!' y 'NO HAY TIEMPO QUE PERDER'.",
    },
    ["mutator_agents_vs_fbi_motd"] = {
    chinese = "007",
    english = "JAMES BOND",
    spanish = "JAMES BOND",
    },
}

for id, repl in pairs(replacements) do
	D.Localizer:add_localization_override(id, repl)
end
