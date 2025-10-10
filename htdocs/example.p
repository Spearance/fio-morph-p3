@USE
FioMorph.p

#######################################
# Поддерживаемая запись падежей
#
# i, I, nom, nominative, им, именительный
# r, R, gen, genitive, род, родительный
# d, D, dat, dative, дат, дательный
# v, V, acc, accusative, вин, винительный
# t, T, ins, instrumental, тв, творительный
# p, P, pre, prepositional, пр, предложный

$fio[^FioMorph::create[
	^rem{ фамилия }
	$.surname[Иванов]
	^rem{ имя }
	$.first[Иван]
	^rem{ отчество }
	$.middle[Иванович]
	^rem{ 1/0 -> мужчина/женщина }
	$.gender(1)
]]

# или
$fio[^FioMorph::create[Иванов Иван Иванович]]
# или
$fio[^FioMorph::create[Иван Иванович Иванов]]

# Полное ФИО по падежам
# Именительный, фамилия справа
^fio.fullName[i;r]
# Родительный
^fio.fullName[R]
# Дательный
^fio.fullName[dat]
# Винительный
^fio.fullName[accusative]
# Творительный
^fio.fullName[тв]
# Предложный
^fio.fullName[предложный]

# Короткая запись Фамилия род. + инициалы слева
^fio.shortName[r;l]
# Короткая запись Фамилия дат. + инициалы справа
^fio.shortName[дательный;r]

# Фамилия
^fio.surName[предложный]

# Имя
^fio.firstName[V]

# Отчество 
^fio.middleName[ins]

# Пол
# full | short | abbr
^fio.gender[full]
