local replacements = {
	["des_m4"] = {
	chinese = "数据：控制性高：高精度：高射速：增伤6点： \n高射速，容易操控，精度高使得即使是略低一点的伤害也不妨碍其成为专业人员的第一选择。\n即使是没经过训练的菜鸟也能轻松使用。",
	english = "stats:high control:high accuracy:high firerate:gain 6 extra-damage:\nHigh firerate,easy to control and high accuracy makes it a professional's priority one, although it has a little low damage for its downside. \nEven an un-trained rookie can handle it easily.",
	},
	["des_ak47"] = {
	chinese = "数据：较难控制：精度略低：中等射速：大威力：增伤5点： \n可靠，便宜，威力大是它的标志性描述。相比起来，精准度和射速的不足反而不那么像是一种缺陷。\n威力的更强不意味着其对于你的使用要求不高。",
	english = "stats:low control:low accuracy:medium firerate:hi-power:gain 5 extra-damage:\nReliable, cheap, powerful is it's symbolic description. It's lack of accuracy and firerate is not really like a kind of downside. \nThe stronger firepower doesn't mean that you can shoot freely.",
	},
	["des_r870_shotgun"] = {
	chinese = "数据：威力巨大：中近距离：伤害衰减：低捡弹：强击退力：增伤50点：	\n这把问世于2011年犯罪狂潮的霰弹枪以在中近距离极强的火力而闻名。 \n装载五颗弹丸的超重型霰弹能毁灭一切敢于与它作对的敌人。 \n射速略慢，射击时尽可能保证一击必杀。",
	english = "stats:extreme-power:medium-close range:damage-falloff:low pickup:strong knockback:gain 50 extra-damage:\nThis shotgun born in 2011 crimefest is famous for its extreme-firepower in medium-close range. \nThe 5-pellet packed ultra heavy shells can destroy anyone against it."
	},
	["des_m14"] = {
	chinese = "数据：高爆头倍率：精度极高：盾牌穿透：增伤10点： \n精准，头盔穿透能力强使它成为对自己枪法有自信的家伙的首选。 \n盾牌在它眼中宛如纸片，但防爆特警的面甲于它难以穿透。\n远距离战斗是它的主场。 ",
	english = "stats:high headshot multiplier:extreme accuracy:shield penetration:gain 10 extra-damage:\nAccurate, and good penetration makes it the priority one for head-shooters, unluckily it's hard to shoot through bulldozer's visor for m308.",
	},
	["des_hk21"] = {
	chinese = "数据：精度较低：较高射速：强压制力：手持时减速：威力强大：增伤15点： \n不赖的精度，高射速与高威力让它变成了一头猛兽。近距离没有任何人可以抵挡得住这家伙的扫射。\n若有人敢来犯，就用90发大弹盒让他们瞧瞧厉害。",
	english = "stats:low accuracy:high firerate:high suppression ability:reduce movement speed while wielded:hi-power:gain 15 extra-damage: \nOkay accuracy, high firerate and high firepower makes it a beast. No one can live under it's strafing at close range. \nGive'em a lesson with your 90 rounds box magazine if they get near.",
	},
	["des_beretta92"] = {
	chinese = "数据：高精度：高射速：增伤7点： \n这把带着消音器的手枪终于迎来了春天。 \n改良以后的枪管和弹药现在能在不增加后坐力的前提下增加精度和威力。其具有的高射速让使用者能快速造成伤害。 \n不论是警察，特工，安保人员，甚至是劫匪都对其非常满意，适合新手使用。",
	english = "stats:high accuracy:high firerate:gain 7 extra-damage: \nBeing easy to control, great firepower, and best firerate makes it a great weapon for rookies.",
	},
	["des_c45"] = {
	chinese = "数据：威力大：精度略低：携弹量少：增伤10点： \n这把问世于2011年的.45口径手枪在现在推出了最新的改良版本。 \n它的威力和精度现在完全足够应付绝大多数敌人，代价是八发稀烂的弹匣。 \n这把改良型武器受到绝大多数群体的欢迎。",
	english = "stats:hi-power:low accuracy:low ammo:gain 10 extra-damage: \nCompared to The original one, this MK II pistol is more worth using.\nIt's firepower and accuracy now is enough for dealing with most enemies, but it has a only-8-round magazine. \nThis improved weapon now is now welcomed by the vast majority of shooters.",
	},
	["debug_c45"] = {
	chinese = "CROSSKILL .45 MK II手枪",
	english = "CROSSKILL .45 MK II PISTOL",
	},
	["des_raging_bull"] = {
	chinese = "数据：威力巨大：精度高：携弹量少：难以控制：增伤50点： \n.44MAGNUM弹药注定了这把枪将会非同凡响，这把枪原本用于对付大型动物。 \n巨大的威力让它所向披靡。",
	english = "stats:extreme-power:high accuracy:low ammo:hard to control:gain 50 extra-damage: \n.44MAGNUM rounds makes it will not be a common pistol. \nThis weapon is designed to deal with larger animals. \nExtreme firepower will make it unstoppable.",
	},
	["des_glock"] = {
	chinese = "数据：精度略低：极高射速：强压制力：增伤5点： \nSTRYK是一把采用大量聚合物制造的自动手枪，其因在近距离极强的爆发性输出而闻名。 \n军方在用，一些地区的警察在用，黑帮也在用，现在轮到你了。",
	english = "stats:low accuracy:extreme high firerate:high supression ability:gain 5 extra-damage: \nSTRYK is an automatic pistol made of large amount of polymer. It's famous for bursting lots of damage at close range. \nGive'em a pocket surprise.",
	},
	["des_m79"] = {
	chinese = "数据：威力巨大：只能从弹药包获取弹药：具有爆炸性： \n沃尔夫到底从哪里搞到的这东西？ \n从弹药包获取一发弹药会直接扣取75%的弹药量。爆炸范围非常宽广，可以炸死多数敌对单位，在需要的时候用吧。",
	english = "stats:extreme-power:gain ammo only from ammo-bag:explosive: \nObtaining a single round of grneade from an ammo bag will directly deduct 0.75 weapons' ammunition of the ammo amount which ammobag contains. \nExplode radious is very wide and can instantly kill most enemie unit.",
	},
	["des_mac11"] = {
	chinese = "数据：低精准度：强压制力：较难控制：续航偏弱：增伤15点： \n高射速，高伤害，大弹匣。\n拿上它，你就会让你的敌人后悔出生在这个世界上。",
	english = "stats:low accuarcy:high suppresion ability:hard to control:low endurance:gain 15 extra-damage:\nHigh firerate, High power, Big magazine. \nBecome a moster and let cops regret wake up this morning.",
	},
	["des_mp5"] = {
	chinese = "数据：高精度：高爆头倍率：低基础伤害：\n紧凑型-5冲锋枪因为其紧凑，优秀的的可控性和精准度受到反恐部队的喜爱。\n但是较差的护甲穿透力让这把枪对于使用者的操作水平要求较高。",
	english = "stats:high accuracy:high headshot multiplier:low firepower: \nCompact-5 machine gun is welcomed by anti-terriorst team for it's compactness, great control and accuracy. \nBut low armor penetration makes this weapon being more demanding for the user's shooting skill.",
	},
	["des_mossberg"] = {
	chinese = "数据：快速行动：威力巨大：伤害衰减：打击范围较大：强击退力：手持时速度增加： \n火车头 12G以更少的弹容量和更差的精准度为代价获得了极高的爆发能力。 \n使用装有9发弹丸的鹿弹，牺牲单颗弹丸火力，但容错率变得更高了。 \n务必在近距离使用。",
	english = "stats:quick action:extreme-power:damage falloff:wide spread:strong knockback:increase movement speed while wielded: \nLocomotive 12G gains terrific ability to burst damage in cost of lower capacity and worse accuracy. \nIt uses buckshot contains 9 pellets, missing one pellet will never be a deal.",
	},
	["debug_thick_skin"] = {
	chinese = "重型护甲",
	english = "heavy armor",
	},
	["des_thick_skin"] = {
	chinese = "重型护甲为玩家增加100点血量与30点护甲。\n代价是行走速度减慢15%,奔跑速度减慢10%，护甲回复时间延长一秒。\n这种护甲能让你近距离硬抗防爆特警一枪而不倒地。",	
	english = "Heavy armor provides 100 hp and 30 ap. \nFor what it costs, your walking speed is decreased by 15%, running speed decreased by 10%, and armor regen time is increased by 1 second. \nThis kind of armor can allow you to take a Bulldozer's shotgun shot without bleeding out.",
	},
	["des_extra_start_out_ammo"] = {
	chinese = "每把武器额外获得一个弹匣（GL40不享受该加成）。",
	english = "Provide a extra magazine per weapon.(In exception of GL40)",
	},
	["des_toolset"] = {
	chinese = "减少45%互动（包括援助他人）所需时长。",
	english = "Reduce interaction(including reviving someone) time by 45%.",
	},
	["debug_equipment_extra_cable_tie"] = {
	chinese = "诈降专家",
	english = "Fake surrender",
	},
	["des_extra_cable_tie"] = {
	chinese = "减少玩家携带的绑带数量至3。\n但你可以通过按下【用技能把自己绑起来/解绑】按键以将自己绑起来或者解绑自己，此时你不会被视作目标且不会受伤。\n把自己绑起来将会消耗一个绑带，不能在倒地，被电击，被制服或被铐住时使用，孤身一人时使用会导致劫案失败。",
	english = "Decrease player's cable tie amount to 3. \nHowever, you can press [Tie/Untie yourself with skill] button to tie or untie yourself.\nUsing this skill will cost a cable tie. You cannot use this skill on you downed. Use this skill while you are the last man standing will cause the failure of the heist.",
	},
	["des_protector"] = {
	chinese = "给所有队友提供9点护甲值。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Provide all teammates 9 armor points.",
	},
	["des_more_ammo"] = {
	chinese = "给所有队友提供捡弹率加成。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Provide all teammates ammo pickup multipliers.",
	},
	["des_more_blood_to_bleed"] = {
	chinese = "使队友的倒地血量增加50%，并使队友的可被援助时间与倒地的援助时间惩罚增加50%。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Your teammates' down timer along with down timer penalty and health point on downed will be increased by 50%.",
	},
	["debug_upgrade_aggressor"] = {
	chinese = "穿甲弹药",
	english = "AP rounds",
	},
	["des_aggressor"] = {
	chinese = "队友的武器非爆头伤害增加。具体数值请见武器介绍，且增加的伤害不会影响对防爆特警面甲的伤害。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Your teammates' non-headshot damage will be increased and the extra damage will not affect the actual damage against bulldozer's visor.",
	},
	["des_speed_reloaders"] = {
	chinese = "队友的换弹速度提升15%。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Your teammates' reload speed is increased by 15%.",
	},
	["des_sharpshooters"] = {
	chinese = "队友的武器精准度提升10%，且武器爆头倍率增加0.25。\n爆头倍率计算方式为：武器爆头倍率*敌人爆头倍率*难度爆头倍率。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Your teammates' weapon accuracy is increased by 10% and weapons' headshot multipliers are increased by 0.25.",
	},
	["des_mr_nice_guy"] = {
	chinese = "给队友提供现金加成。\n你的小组加成只能对你的队友生效，也就是说你只能享受你队友的小组加成。\n小组加成效果不随小组加成数量叠加，且被羁押会使小组加成失效。",
	english = "Provide your teammates extra cash multiplier.",
	},
	["des_trip_mine"] = {
	chinese = "激光绊雷可以用作阻挡敌人的陷阱使用。\n你也可以将其放在某个角落，需要的时候射一枪，就能解决不少麻烦。\n威力相对于GL40来说偏低，但幸运的是没有人阻止你把多个诡雷放在一起提升威力。\n玩家最多携带10个激光绊雷，其可以伴随捡弹和使用弹药包补充弹药补充，而且不会额外消耗弹药。",
	english = "Trip-mines can be used as traps for stopping these cops.\nThe explotion power is a bit low compared to GL40, but luckily nobody will stop you from stacking trip mines for increasing explotion power. \nA player can take 10 trip mines, and it can be refilled by picking up ammoboxes, or just interact with an ammo bag, without consuming ammo.",  
	},
	["des_ammo_bag"] = {
	chinese = "战斗时，弹药必不可少。带上两个弹药包可以有效缓解弹药压力，不是吗？ \n一个弹药包可以提供750%的武器弹药，并且一个玩家可以携带两个弹药包。",
	english = "Ammunition is necessary for combat. Two ammo bags are effective for reducing pressure of lacking of ammo, isn't it? \nAn ammo bag can fill 7.5 weapons' ammunition, and a player can carry 2 ammo bags.",
	},
	["des_sentry_gun"] = {
	chinese = "步哨机枪总是可以帮助你清理一大群敌人。什么，一个不够？那么三个呢？ \n布置下来以后，步哨机枪可以自动锁定并攻击敌人，直到它被破坏或子弹耗尽为止。",
	english = "Sentry guns can always help you to deal with a massive amounts of enemies. Wait, only one sentry is not enough? What about...three? \nOn deployed, the sentry gun can automatically lock then shoot the enemies, until it's destroyed or runs out of ammo.",
	},
	["des_doctor_bag"] = {
	chinese = "医疗包总是能让你满血复活，而且还能重置你的倒地次数。 \n一个医疗包只能用三次，一个玩家可以携带两个医疗包。",
	english = "A medic bag can always refill your health and reset your down times. \n A medic bag can be used for 3 times, a player can carry 2 medic bags.",
	},
	["mutator_combine_assault"] = {
	chinese = "联合进攻",
	english = "COMBINE ASSAULT",
	},
	["mutator_combine_assault_help"] = {
	chinese = "好消息，弟兄们，那些条子已经知道他们战胜不了我们了。\n\n\n坏消息，那帮条子摇来了一大号狗日的雇佣兵和FBI探员来干我们。\n\n\n\n突击时，会生成大量更难以对付的黑水雇佣兵与FBI探员。\n\n\n\n只在枪林弹雨，枪林弹雨145+或者枪林弹雨193+生效。",
	english = "Good news, gang, these cops already know they cannot defeat us. \n\n\nBad news, these cops' calling lots of stupid murkies and FBI agents to fuck us. \n\n\n\nMassive murkywater mercenaries and FBI agents will spawn during assault, they are way harder to handle. \n\n\n\nOnly avilable at Overkill, Overkill 145+ or Overkill 193+ difficulty.",
	},
	["mutator_combine_assault_motd"] = {
	chinese = "突变模式‘联合进攻’已开启，装备了更高级武器的黑水雇佣兵和FBI探员将会生成。",
	english = "mutator 'COMBINE ASSAULT' activated, murkywater mercenaries and FBI agents with better weapons will spawn.",
	},
	["mutator_exercised_cops"] = {
	chinese = "高级训练",
	english = "EXERCISED COPS",
	},
	["mutator_exercised_cops_help"] = {
	chinese = "弟兄们，大事不妙。\n\n\n这帮条子专门针对我们的战术进行了训练，我们以后做事得多加注意一点了。\n\n\n\n重甲水军生成量变多，射击水平变强且躲避水平变强。他们将会成为你的噩梦。\n\n\n\n只在枪林弹雨，枪林弹雨145+或者枪林弹雨193+生效。",
	english = "Gang, we got trouble. \n\n\nThese cops just trained aiming at our tactics, we gotta pay more caution for further moves. \n\n\n\nThe spawn rate of heavy swats is increased, they will shoot more accurately and dodge better. They sure will become your nightmare. \n\n\n\nOnly avilable at Overkill, Overkill 145+ or Overkill 193+ difficulty.",
	},
	["mutator_exercised_cops_motd"] = {
	chinese = "突变模式‘高级训练’已开启，准备好被重甲水军按着打吧。",
	english = "mutator 'EXERCISED COPS' activated, ready to get fucked by heavy swats.",
	},
	["mutator_full_speed"] = {
	chinese = "全速出击",
	english = "OUTRUN",
	},
	["mutator_full_speed_help"] = {
	chinese = "我怀疑条子们磕了点奇怪的东西，他们今天怎么跑这么快？\n\n\n不管了，既然他们先磕，那我们也磕点东西，要不然可不就输了！弟兄们，准备好心脏爆炸吧！\n\n\n\n玩家，敌人，与AI队友的移速乘以3。",
	english = "I doubt cops had something weird today, they just run too fast...\n\n\nOkay, fuck it. Let's just get some drugs and prepare for a heart attack!\n\n\n\nPlayer, enemies, and bot teammates' movement speed is multiplyed by 3.",
	},
	["mutator_full_speed_motd"] = {
	chinese = "突变模式‘全速出击’已开启，每一个人都会跑得非常快。",
	english = "GOTTA GO FAST",
	},
	["mutator_zhouji"] = {
	chinese = "肘击高手",
	english = "MELEE EXPERT",
	},
	["mutator_zhouji_help"] = {
	chinese = "我不需要太多子弹，子弹就留给那些重型单位吧。\n\n\n我要用枪托给那些傻逼点颜色瞧瞧。\n\n\n\n所有武器初始只有一个弹匣，所有难度的无敌帧增加0.3秒，所有武器的近战伤害锁定为150，击倒指数为10且捡弹率减少50%。\n\n和炸翻天与无暇搜刮冲突。",
	english = "I don't need too much rounds, they are for heavier ones. \n\n\nI'm gonna teach'em a lesson...with my gun stock! \n\n\n\nEvery weapon has only one magazine for default, each difficulty's grace period is increased by 0.3 seconds, every weapons' melee damage is locked to 150, knockback effect to 10 and has 50% penalty for ammo-pickup rate.\n\nConflicts with KABOOM and NO TIME FOR SEARCHING mutator.",
	},
	["mutator_zhouji_motd"] = {
	chinese = "突变模式‘肘击高手’已开启，用肘击肘死你的敌人吧。",
	english = "BULLETS ARE JUST FOR PUSSIES.",
	},
	["mutator_expert_mode"] = {
	chinese = "专家模式",
	english = "EXPERT MODE",
	},
	["mutator_expert_mode_help"] = {
	chinese = "专家模式仅供真正的专家游玩。\n\n\n\nGL40已禁用。\n\n\n换弹时会抛弃弹匣内剩余弹药，但换弹速度提高10%。\n\n\n泰瑟特警的电击不再自动换弹，且被电击到倒地的时间减少50%。\n\n\n携带霰弹枪的单位现在没有瞄准延迟了。\n\n\n幻影特工会在制服劫匪时留下烟雾弹。",
	english = "THE EXPERT MODE is only provided for real experts. \n\n\n\nGl40 is disabled.\n\n\nYou will lost your round remaining in clip when reloaded, but reload speed is increased by 10%. \n\n\nTasers' eletric shock no longer auto-reload, and getting shocked will let you get downed 50% faster. \n\n\nNo aim-delay for shotgunners. \n\n\nCloaker will drop a smoke grneade when he cloaked a heister. ",
	},
	["mutator_expert_mode_motd"] = {
	chinese = "突变模式‘专家模式’已开启。技术水平不过关的人不应该在这个大厅里呆着。",
	english = "mutator 'EXPERT MODE' activated, you should make sure that you are a professional.",
	},	
	["mutator_no_time_for_searching"] = {
	chinese = "无暇搜刮",
	english = "NO TIME FOR SEARCHING",
	},
	["mutator_no_time_for_searching_help"] = {
	chinese = "弟兄们，这次十万火急！\n\n\n这次应该没时间从条子身上搜刮弹药了，多带点！\n\n\n\n敌人死亡不会掉落可拾取的弹药盒，且玩家可携带弹药量增加。\n\n与炸翻天和肘击高手冲突。",
	english = "Gang, we got a situation! \n\n\nWe have no time for searching ammo from these dead cops, just carry more AMMO! \n\n\n\nAmmoclip will not spawn on enemies dead, and players' start out ammo is increased.\n\nConflicts with KABOOM and MELEE EXPERT mutator.",
	},
	["mutator_no_time_for_searching_motd"] = {
	chinese = "突变模式‘无暇搜刮’已开启。别指望从条子尸体身上捡到奇奇怪怪的子弹了。",
	english = "mutator 'NO TIME FOR SEARCHING' activated, cops will not spawn ammoclip on they get killed.",
	},
	["mutator_kaboom"] = {
	chinese = "炸翻天",
	english = "KABOOM",
	},
	["mutator_kaboom_help"] = {
	chinese = "“今天让那帮傻逼条子吃点好吃的！”\n\n\n“沃尔夫，你这个傻逼！这就是你他妈连其他弹药都不带的理由？都怪你，现在我们只有筒子和手枪能用的，你一个人滚去吃屎吧！”\n\n\n\nGL40可以捡弹，换弹更快，但以伤害更低为代价。\n\n\n只能使用手枪和GL40，其他武器全部没有子弹。\n\n与肘击高手和无暇搜刮冲突。",
	english = "What makes me a good demoman?\n\n\nWolf, you fucking moron! Is this the reason you don't carry other fucking ammunition? It's all your fault that we can only use Grenade launcher and a pistol now, go eat shit yourself!\n\n\n\nGL40 can now pickup ammo, reload faster in cost of lower damage.\n\n\nOnly pistols and GL40 are aviliable, No ammo for other weapons.\n\nConflicts with MELEE EXPERT and NO TIME FOR SEARCHING mutator.",
	},
	["mutator_kaboom_motd"] = {
	chinese = "突变模式‘炸翻天’已开启。把这些傻逼全炸死！",
	english = "KA BOOM",
	},
	["mutator_better_enemy_lmg"] = {
	chinese = "敌方机枪加强",
	english = "BETTER ENEMY LMG",
	},
	["mutator_better_enemy_lmg_help"] = {
	chinese = "啊，又是一个扛着破烂机枪的防爆特警——等等他今天怎么射这么快？！\n\n\n兄弟们快躲起来，随便找个掩体，快！\n\n\n\n敌方布伦纳-21的射速加快。简单难度不启用。",
	english = "Ah, another bulldozer with shitty machine gun----WAIT HOW CAN HE SHOOT THIS FAST TODAY?!\n\n\nTAKE COVER GANG, FIND ANYTHING TO HIDE, HURRY!\n\n\n\nEnemy Breener-21's fire rate is increased. Does not apply on Easy difficulty.",
	},
	["mutator_better_enemy_lmg_motd"] = {
	chinese = "突变模式‘敌方机枪加强’已开启。小心敌方携带机枪的单位。",
	english = "mutator 'BETTER ENEMY LMG' activated, watch out for these units who carring LMGs.",
	},
	["mutator_dozers_on_street"] = {
	chinese = "防爆特警过马路",
	english = "DOZERS ON STREET",
	},
	["mutator_dozers_on_street_help"] = {
	chinese = "啊，马特那个混账狗东西，这次就别想跑掉了......等等，那他妈是什么？\n\n\n那他妈是个防爆特警！！！！！\n\n\n\n防爆特警会在热火街头的防御阶段生成。\n\n\n\n只在枪林弹雨，枪林弹雨145+或者枪林弹雨193+生效。",
	english = "Ah, such a cock sucker matt is, he will NOT get away this time......wait a minute, WHAT THE FUCK IS THAT?\n\n\nIT'S A MOTHER FUCKING BULLDOZER!!!!!\n\n\n\nBulldozers will spawn during BLOCKADE stage.\n\n\n\nOnly avilable at Overkill, Overkill 145+ or Overkill 193+ difficulty.",
	},
	["mutator_dozers_on_street_motd"] = {
	chinese = "突变模式‘防爆特警过马路’已开启。过马路前看看有没有防爆特警！",
	english = "mutator 'DOZERS ON STREET' activated, check if there's dozers before crossing the road!",
	},
	["mutator_stealth_marksman"] = {
	chinese = "超隐蔽狙击手",
	english = "STEALTH MARKSMAN",
	},
	["mutator_stealth_marksman_help"] = {
	chinese = "沃尔夫，你他妈看见那傻逼从哪射的不？！\n\n\n我他妈看不见！看不见！看不见！！！！\n\n\n\n狙击手装备不产生红色轨迹的M308，更难以发现。\n\n在毫不留情劫案不可用。",
	english = "WOLF, DID YOU SEE THAT MOTHERFUCKER WHO JUST SNIPE US?!\n\n\nI CAN'T SEE! CAN'T SEE! CAN'T SEE!!!!\n\n\n\nSnipers will equip M308s which will not cause red traces.\n\nUnaviliable in NO MERCY heist.",
	},
	["mutaotr_stealth_marksman_motd"] = {
	chinese = "狙佬呢？！",
	english = "CAN YOU FIND THE SNIPERS?",
	},
	["dialog_mutator_conflictions"] = {
	chinese = "你启用了冲突的突变模式，请关闭可能引起冲突的突变模式后再开启游戏。",
	english = "You activated mutators that will cause conflictions, please set the mutator that may cause conflictions inactive then start the game.",
	},
}

for id, repl in pairs(replacements) do
	D.Localizer:add_localization_override(id, repl)
end
