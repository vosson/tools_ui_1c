#Область СлужебныеПроцедурыИФункции

// Возвращает соответствие имен "функциональных" подсистем и значения Истина.
// У "функциональной" подсистемы снят флажок "Включать в командный интерфейс".
//
Функция ИменаПодсистем() Экспорт

	ОтключенныеПодсистемы = Новый Соответствие;

	Имена = Новый Соответствие;
	ВставитьИменаПодчиненныхПодсистем(Имена, Метаданные, ОтключенныеПодсистемы);

	Возврат Новый ФиксированноеСоответствие(Имена);

КонецФункции

// Позволяет виртуально отключать подсистемы для целей тестирования.
// Если подсистема отключена, то функция ОбщегоНазначения.ПодсистемаСуществует вернет Ложь.
// В этой процедуре нельзя использовать функцию ОбщегоНазначения.ПодсистемСуществует, т.к. это приводит к рекурсии.
//
// Параметры:
//   ОтключенныеПодсистемы - Соответствие - в ключе указывается имя отключаемой подсистемы, 
//                                          в значении - установить в Истина.
//
Процедура ВставитьИменаПодчиненныхПодсистем(Имена, РодительскаяПодсистема, ОтключенныеПодсистемы,
	ИмяРодительскойПодсистемы = "")

	Для Каждого ТекущаяПодсистема Из РодительскаяПодсистема.Подсистемы Цикл

		Если ТекущаяПодсистема.ВключатьВКомандныйИнтерфейс Тогда
			Продолжить;
		КонецЕсли;

		ИмяТекущейПодсистемы = ИмяРодительскойПодсистемы + ТекущаяПодсистема.Имя;
		Если ОтключенныеПодсистемы.Получить(ИмяТекущейПодсистемы) = Истина Тогда
			Продолжить;
		Иначе
			Имена.Вставить(ИмяТекущейПодсистемы, Истина);
		КонецЕсли;

		Если ТекущаяПодсистема.Подсистемы.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;

		ВставитьИменаПодчиненныхПодсистем(Имена, ТекущаяПодсистема, ОтключенныеПодсистемы, ИмяТекущейПодсистемы + ".");
	КонецЦикла;

КонецПроцедуры

// Код основного языка.
// 
// Возвращаемое значение:
//  Строка - Код основного языка
Функция КодОсновногоЯзыка() Экспорт
	Возврат Метаданные.ОсновнойЯзык.КодЯзыка;
КонецФункции

// Возвращает соответствие имен предопределенных значений ссылкам на них.
//
// Параметры:
//  ПолноеИмяОбъектаМетаданных - Строка, например, "Справочник.ВидыНоменклатуры",
//                               Поддерживаются только таблицы
//                               с предопределенными элементами:
//                               - Справочники,
//                               - Планы видов характеристик,
//                               - Планы счетов,
//                               - Планы видов расчета.
// 
// Возвращаемое значение:
//  ФиксированноеСоответствие, Неопределено, где
//      * Ключ     - Строка - имя предопределенного,
//      * Значение - Ссылка, Null - ссылка предопределенного или Null, если объекта нет в ИБ.
//
//  Если ошибка в имени метаданных или неподходящий тип метаданного, то возвращается Неопределено.
//  Если предопределенных у метаданного нет, то возвращается пустое фиксированное соответствие.
//  Если предопределенный определен в метаданных, но не создан в ИБ, то для него в соответствии возвращается Null.
//
Функция СсылкиПоИменамПредопределенных(ПолноеИмяОбъектаМетаданных) Экспорт

	ПредопределенныеЗначения = Новый Соответствие;

	МетаданныеОбъекта = Метаданные.НайтиПоПолномуИмени(ПолноеИмяОбъектаМетаданных);
	
	// Если метаданных не существует.
	Если МетаданныеОбъекта = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	// Если не подходящий тип метаданных.
	Если Не Метаданные.Справочники.Содержит(МетаданныеОбъекта) И Не Метаданные.ПланыВидовХарактеристик.Содержит(
		МетаданныеОбъекта) И Не Метаданные.ПланыСчетов.Содержит(МетаданныеОбъекта)
		И Не Метаданные.ПланыВидовРасчета.Содержит(МетаданныеОбъекта) Тогда

		Возврат Неопределено;
	КонецЕсли;

	ИменаПредопределенных = МетаданныеОбъекта.ПолучитьИменаПредопределенных();
	
	// Если предопределенных у метаданного нет.
	Если ИменаПредопределенных.Количество() = 0 Тогда
		Возврат Новый ФиксированноеСоответствие(ПредопределенныеЗначения);
	КонецЕсли;
	
	// Заполнение по умолчанию признаком отсутствия в ИБ (присутствующие переопределятся).
	Для Каждого ИмяПредопределенного Из ИменаПредопределенных Цикл
		ПредопределенныеЗначения.Вставить(ИмяПредопределенного, Null);
	КонецЦикла;

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ТекущаяТаблица.Ссылка КАК Ссылка,
	|	ТекущаяТаблица.ИмяПредопределенныхДанных КАК ИмяПредопределенныхДанных
	|ИЗ
	|	&ТекущаяТаблица КАК ТекущаяТаблица
	|ГДЕ
	|	ТекущаяТаблица.Предопределенный";

	Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ТекущаяТаблица", ПолноеИмяОбъектаМетаданных);

	УстановитьОтключениеБезопасногоРежима(Истина);
	УстановитьПривилегированныйРежим(Истина);

	Выборка = Запрос.Выполнить().Выбрать();

	УстановитьПривилегированныйРежим(Ложь);
	УстановитьОтключениеБезопасногоРежима(Ложь);
	
	// Заполнение присутствующих в ИБ.
	Пока Выборка.Следующий() Цикл
		ПредопределенныеЗначения.Вставить(Выборка.ИмяПредопределенныхДанных, Выборка.Ссылка);
	КонецЦикла;

	Возврат Новый ФиксированноеСоответствие(ПредопределенныеЗначения);

КонецФункции

Функция ОписаниеТипаВсеСсылки() Экспорт

	МассивТипов = БизнесПроцессы.ТипВсеСсылкиТочекМаршрутаБизнесПроцессов().Типы();
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "Справочники", "Справочник");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "Документы", "Документ");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "ПланыВидовХарактеристик", "ПланВидовХарактеристик");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "ПланыВидовРасчета", "ПланВидовРасчета");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "ПланыСчетов", "ПланСчетов");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "БизнесПроцессы", "БизнесПроцесс");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "Задачи", "Задача");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "ПланыОбмена", "ПланОбмена");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "Перечисления", "Перечисление");
	
	Возврат Новый ОписаниеТипов(МассивТипов);

КонецФункции

Функция ОбщийМодуль(Имя) Экспорт
	Возврат УИ_ОбщегоНазначения.ОбщийМодуль(Имя);
КонецФункции

Функция ТипыОбъектовДоступныйДляРедактораОбъектовБазыДанных() Экспорт
	//Доступны к редактированию 
	//справочники,Документы,ПланыВидовХарактеристик,ПланыСчетов,ПланыВидовРасчетов, БизнесПроцессы, Задачи, планыОбмена

	МассивТипов=Новый Массив;
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "Справочники", "Справочник");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "Документы", "Документ");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "ПланыВидовХарактеристик", "ПланВидовХарактеристик");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "ПланыВидовРасчета", "ПланВидовРасчета");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "ПланыСчетов", "ПланСчетов");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "БизнесПроцессы", "БизнесПроцесс");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "Задачи", "Задача");
	ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, "ПланыОбмена", "ПланОбмена");

	Возврат МассивТипов;
КонецФункции

Процедура ДобавитьТипыПоВидуОбъектовМетаданных(МассивТипов, ИмяВидаОбъектовМетаданных, ИмяТипа)
	Для Каждого мдОбъекта Из Метаданные[ИмяВидаОбъектовМетаданных] Цикл
		МассивТипов.Добавить(Тип(СтрШаблон("%1Ссылка.%2", ИмяТипа, мдОбъекта.Имя)));
	КонецЦикла;
КонецПроцедуры

Функция ПолеHTMLПостроеноНаWebkit() Экспорт
	УИ_ОбщегоНазначенияКлиентСервер.ПолеHTMLПостроеноНаWebkit();
КонецФункции

#КонецОбласти