# FioMorph.p
# v. 1.0.0
# Evgeniy Lepeshkin, 2026-01-13

@CLASS
FioMorph

#######################################
# $.surname[str] - фамилия
# $.first[str] - имя
# $.middle[str] - отчество
# $.gender(int) - пол 0/1 = женщина/мужчина
###
@create[param]
$self.surname[]
$self.first[]
$self.middle[]

^if($param is "string"){
	^_parseName[$param]
}{
	$self.surname[$param.surname]
	$self.first[$param.first]
	$self.middle[$param.middle]
}

^if($param is "hash"){
	^if(^param.gender.int(2) < 2){
		$self.sex($param.gender)
	}(def $self.surname && def $self.middle){
		$self.sex(^checkGender[$self.surname;$self.middle])
	}{
		$self.sex(2)
	}
}{
	$self.sex(^checkGender[$self.surname;$self.middle])
}
### End @create


#######################################
@fullName[case;position]
^switch[$position]{
	^case[r;R;right;справа]{
		$result[^firstName[$case]^if(def $self.middle){ ^middleName[$case]} ^surName[$case]]
	}
	^case[l;L;left;слева;DEFAULT]{
		$result[^surName[$case] ^firstName[$case]^if(def $self.middle){ ^middleName[$case]}]
	}
}
### End @fullName


#######################################
@shortName[case;position]
^switch[$position]{
	^case[l;L;left;слева]{
		$result[^self.first.left(1).^if(def $self.middle){^self.middle.left(1).} ^surName[$case]]
	}
	^case[r;R;right;справа;DEFAULT]{
		$result[^surName[$case] ^self.first.left(1).^if(def $self.middle){^self.middle.left(1).}]
	}
}
### End @fullName


#######################################
@surName[case][parts]
^if(def $self.surname && ^self.surname.pos[-] > 0){
	$parts[^self.surname.split[-;lv]]
	^if($parts){
		$result[^parts.menu{^_changeCase[$case;surname;$parts.piece]}[-]]
	}
}{
	$result[^_changeCase[$case;surname]]
}
### End @surName


#######################################
@firstName[case]
$result[^_changeCase[$case;first]]
### End @firstName


#######################################
@middleName[case]
$result[^if(def $self.middle){^_changeCase[$case;middle]}]
### End @middleName


#######################################
@gender[type]
^if(!def $type){
	$type[$DEFAULT.GENDER]
}

$result[$hGender.[^type.lower[]].[$self.sex]]
### End @gender


#######################################
@checkGender[surname;middleName][man;woman]
$result(2)
^if(def $middleName){
	$man(^middleName.match[(?:ич|\-огл[ыу]|\-ул[ыу]|\-уулу)^$][i])
	^if(!$man){
		$woman(^middleName.match[(?:на|\-[кг]ызы^$][i])
	}
}(def $surname){
	$man(^surname.match[(?:[еоё]в|[иы]н|[кхн]?ий|[оы]й)^$][i])
	^if(!$man){
		$woman(^surname.match[(?:[оеё]ва|[ыи]на|([сц]к)?ая?)^$][i])
	}
}

^if($man){$result(1)}($woman){$result(0)}
### End @checkGender


#######################################
@_changeCase[case;type;name]
^switch[^case.lower[]]{
	^case[r;gen;genitive;род;родительный]{
		$result[^_morph[r;$type;$name]]
	}
	^case[d;dat;dative;дат;дательный]{
		$result[^_morph[d;$type;$name]]
	}
	^case[v;acc;accusative;вин;винительный]{
		$result[^_morph[v;$type;$name]]
	}
	^case[t;ins;instrumental;тв;творительный]{
		$result[^_morph[t;$type;$name]]
	}
	^case[p;pre;prepositional;пр;предложный]{
		$result[^_morph[p;$type;$name]]
	}
	^case[i;nom;nominative;им;именительный;DEFAULT]{
		$result[^if(def $name){$name}{$self.[$type]}]
	}
}
### End @_changeCase


#######################################
@_morph[case;type;name][r;isMatched]
$result[^if(def $name){$name}{$self.[$type]}]
$isMatched(0)

^if($self.sex < 2){
	^if(def $hPr.[$type].exceptions){
		$r[^_matchRules[^hash::create[$hPr.[$type].exceptions.[$self.sex].rules];$result;$case]]
		^if(def $r){
			$isMatched(1)
		}
	}
	^if(!$isMatched){
		$r[^_matchRules[^hash::create[$hPr.[$type].suffixes.[$self.sex].rules];$result;$case]]
		^if(def $r){
			$isMatched(1)
		}
	}
}
^if(!$isMatched){
	^if(def $hPr.[$type].exceptions.2){
		$r[^_matchRules[^hash::create[$hPr.[$type].exceptions.2.rules];$result;$case]]
		^if(def $r){
			$isMatched(1)
		}
	}
	^if(!$isMatched){
		$r[^_matchRules[^hash::create[$hPr.[$type].suffixes.2.rules];$result;$case]]
	}
}

$result[^_apply[$result;$r]]
### End @_morph


#######################################
@_matchRules[h;str;case][r]
$result[]
^h.foreach[k;v]{
	$result[^_match[$v;$str;$case]]
	^if(def $result){
		^break[]
	}
}
### End @_matchRules


#######################################
@_match[h;str;case]
$result[]
$parts[^h.test.split[,;lv]]

^if($parts){
	^parts.menu{
		^if(^_prepareName[$str;^parts.piece.length[]] eq $parts.piece){
			$result[$h.repl.[$case]]
			^break[];
		}
	}
}
### End @_match


#######################################
@_apply[str;r][hyp]
$result[$str]
^if(def $r && ^r.left(1) eq "-"){
	$hyp[^r.match[^^(\-+)][']]
	^if($hyp){
		$result[^result.left(^result.length[] - ^hyp.match.length[])]
	}
	$result[${result}$hyp.postmatch]
}(def $r && $r ne "."){
	$result[${result}$r]
}
### End @_apply


#######################################
@_prepareName[str;length]
^if(def $str && ^length.int(0)){
	$result[^str.lower[]]
	$result[^result.right($length)]
}{
	$result[$str]
}
### End @_prepareName


#######################################
@_parseName[name][parts]
^if(def $name){
	$name[^name.trim[]]
	$name[^name.match[\s+][g]{ }]
	$parts[^name.split[ ;lh]]

	^if($parts){
		^if(def $parts.2 && !^parts.2.match[(?:ич|на)][i]){
			$self.surname[$parts.2]
			$self.first[$parts.0]
			$self.middle[$parts.1]
		}{
			$self.surname[$parts.0]
			$self.first[$parts.1]
			$self.middle[$parts.2]
		}
	}
}
### End @_parseName


#######################################
@auto[]
$DEFAULT[
	$.GENDER[full]
]

$hGender[
	$.full[
		$.0[Женский]
		$.1[Мужской]
		$.2[—]
	]
	$.short[
		$.0[Жен]
		$.1[Муж]
		$.2[—]
	]
	$.abbr[
		$.0[Ж]
		$.1[М]
		$.2[—]
	]
	$.default[
		$.0(0)
		$.1(1)
		$.2(2)
	]
]

$hPr[
	$.first[
		$.exceptions[
			$.1[
				$.rules[
					$.0[
						$.test[пётр]
						$.repl[^table::create{r	d	v	t	p^#0A---етра	---етру	---етра	---етром	---етре}]
					]
					$.1[
						$.test[шота]
						$.repl[^table::create{r	d	v	t	p}]
					]
					$.2[
						$.test[павел]
						$.repl[^table::create{r	d	v	t	p^#0A--ла	--лу	--ла	--лом	--ле}]
					]
					$.3[
						$.test[лев]
						$.repl[^table::create{r	d	v	t	p^#0A--ьва	--ьву	--ьва	--ьвом	--ьве}]
					]
				]
			]
		],
		$.suffixes[
			$.0[
				$.rules[
					$.0[
						$.test[ель,оль,эль,б,в,г,д,ж,з,й,к,л,м,н,п,р,с,т,ф,х,ц,ч,ш,щ,ъ]
						$.repl[^table::create{r	d	v	t	p^#0A.	.	.	.	.}]
					]
					$.1[
						$.test[ь]
						$.repl[^table::create{r	d	v	t	p^#0A-и	-и	.	ю	-и}]
					]
				]
			]
			$.1[
				$.rules[
					$.0[
						$.test[ь]
						$.repl[^table::create{r	d	v	t	p^#0A-я	-ю	-я	-ем	-е}]
					]
				]
			]
			$.2[
				$.rules[
					$.0[
						$.test[е,ё,и,о,у,ы,э,ю]
						$.repl[^table::create{r	d	v	t	p^#0A.	.	.	.	.}]
					]
					$.1[
						$.test[га,ка,ха,ча,ща,жа]
						$.repl[^table::create{r	d	v	t	p^#0A-и	-е	-у	-ой	-е}]
					]
					$.3[
						$.test[ша]
						$.repl[^table::create{r	d	v	t	p^#0A-и	-е	-у	-ей	-е}]
					]
					$.4[
						$.test[а]
						$.repl[^table::create{r	d	v	t	p^#0A-ы	-е	-у	-ой	-е}]
					]
					$.5[
						$.test[ия]
						$.repl[^table::create{r	d	v	t	p^#0A-и	-и	-ю	-ей	-и}]
					]
					$.6[
						$.test[я]
						$.repl[^table::create{r	d	v	t	p^#0A-и	-е	-ю	-ей	-е}]
					]
					$.7[
						$.test[ей]
						$.repl[^table::create{r	d	v	t	p^#0A-я	-ю	-я	-ем	-е}]
					]
					$.8[
						$.test[ий]
						$.repl[^table::create{r	d	v	t	p^#0A-я	-ю	-я	-ем	-и}]
					]
					$.9[
						$.test[й]
						$.repl[^table::create{r	d	v	t	p^#0A-я	-ю	-я	-ем	-е}]
					]
					$.10[
						$.test[б,в,г,д,ж,з,к,л,м,н,п,р,с,т,ф,х,ц,ч]
						$.repl[^table::create{r	d	v	t	p^#0Aа	у	а	ом	е}]
					]
				]
			]
		]
	]
	$.middle[
		$.suffixes[
			$.1[
				$.rules[
					$.0[
						$.test[ич]
						$.repl[^table::create{r	d	v	t	p^#0Aа	у	а	ем	е}]
					]
				]
			]
			$.0[
				$.rules[
					$.0[
						$.test[на]
						$.repl[^table::create{r	d	v	t	p^#0A-ы	-е	-у	-ой	-е}]
					]
				]
			]
		]
	]
	$.surname[
		$.exception[
			$.2[
				$.rules[
					$.0[
						$.test[дюма,тома,дега,люка,ферма,гамарра,петипа,шандра,гусь,ремень,камень,онук,богода,нечипас,долгопалец,маненок,рева,кива]
						$.repl[^table::create{r	d	v	t	p^#0A.	.	.	.	.}]
					]
					$.1[
						$.test[вий,сой,цой,хой]
						$.repl[^table::create{r	d	v	t	p^#0A-я	-ю	-я	-ем	-е}]
					]
				]
			]
		]
		$.suffixes[
			$.0[
				$.rules[
					$.0[
						$.test[ска,цка,ая,ская]
						$.repl[^table::create{r	d	v	t	p^#0A-ой	-ой	-ую	-ой	-ой}]
					]
					$.1[
						$.test[на]
						$.repl[^table::create{r	d	v	t	p^#0A-ой	-ой	-у	-ой	-ой}]
					]
					$.2[
						$.test[ай]
						$.repl[^table::create{r	d	v	t	p^#0A.	.	.	.	.}]
					]
					$.3[
						$.test[ова,ева]
						$.repl[^table::create{r	d	v	t	p^#0A-ой	-ой	-у	-ой	-ой}]
					]
					$.4[
						$.test[ца]
						$.repl[^table::create{r	d	v	t	p^#0A-ы	-е	-у	-ей	-е}]
					]
					$.5[
						$.test[б,в,г,д,ж,з,й,к,л,м,н,п,р,с,т,ф,х,ц,ч,ш,щ,ъ,ь,а,я]
						$.repl[^table::create{r	d	v	t	p^#0A.	.	.	.	.}]
					]
				]
			]
			$.2[
				$.rules[
					$.0[
						$.test[орн,слон,рих,ян,ан,йн,ах,ив,б,г,д,ж,з,к,л,м,п,р,с,т,ф,х]
						$.repl[^table::create{r	d	v	t	p^#0Aа	у	а	ом	е}]
					]
					$.1[
						$.test[иной,уй,ей,ай,ь]
						$.repl[^table::create{r	d	v	t	p^#0A-я	-ю	-я	-ем	-е}]
					]
					$.2[
						$.test[ца]
						$.repl[^table::create{r	d	v	t	p^#0A-ы	-е	-у	-ей	-е}]
					]
					$.3[
						$.test[ия,иа,аа,оа,уа,ыа,еа,юа,эа,их,ых,о,е,э,и,ы,у,ю]
						$.repl[^table::create{r	d	v	t	p^#0A.	.	.	.	.}]
					]
					$.4[
						$.test[ова,ева]
						$.repl[^table::create{r	d	v	t	p^#0A-ой	-ой	-у	-ой	-ой}]
					]
					$.5[
						$.test[га,ка,ха,ча,ща,жа]
						$.repl[^table::create{r	d	v	t	p^#0A-и	-е	-у	-ой	-е}]
					]
					$.6[
						$.test[ца]
						$.repl[^table::create{r	d	v	t	p^#0A-и	-е	-у	-ей	-е}]
					]
					$.7[
						$.test[а]
						$.repl[^table::create{r	d	v	t	p^#0A-ы	-е	-у	-ой	-е}]
					]
					$.8[
						$.test[ия]
						$.repl[^table::create{r	d	v	t	p^#0A-и	-и	-ю	-ей	-и}]
					]
					$.9[
						$.test[я]
						$.repl[^table::create{r	d	v	t	p^#0A-и	-е	-ю	-ей	-е}]
					]
					$.10[
						$.test[ынец,обец]
						$.repl[^table::create{r	d	v	t	p^#0A--ца	--цу	--ца	--цем	--це}]
					]
					$.11[
						$.test[онец,овец,ец]
						$.repl[^table::create{r	d	v	t	p^#0A--ца	--цу	--ца	--цом	--це}]
					]
					$.12[
						$.test[ц,ч,ш,щ]
						$.repl[^table::create{r	d	v	t	p^#0Aа	у	а	ем	е}]
					]
					$.13[
						$.test[гой,кой]
						$.repl[^table::create{r	d	v	t	p^#0A-го	-му	-го	--им	-м}]
					]
					$.14[
						$.test[ой]
						$.repl[^table::create{r	d	v	t	p^#0A-го	-му	-го	--ым	-м}]
					]
					$.15[
						$.test[ший,щий,жий,ний]
						$.repl[^table::create{r	d	v	t	p^#0A--его	--ему	--его	-м	--ем}]
					]
					$.16[
						$.test[кий,ый]
						$.repl[^table::create{r	d	v	t	p^#0A--ого	--ому	--ого	-м	--ом}]
					]
					$.17[
						$.test[ий]
						$.repl[^table::create{r	d	v	t	p^#0A-я	-ю	-я	-ем	-и}]
					]
					$.18[
						$.test[ок]
						$.repl[^table::create{r	d	v	t	p^#0A--ка	--ку	--ка	--ком	--ке}]
					]
					$.19[
						$.test[в,н]
						$.repl[^table::create{r	d	v	t	p^#0Aа	у	а	ым	е}]
					]
				]
			]
		]
	]
]
### End @auto
