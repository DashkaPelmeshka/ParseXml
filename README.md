# ParseXml
 
Напишите скрипт, получающий в качестве параметра путь к XML-файлу и выдающий на STDOut следующее:

* Суммарное число букв внутри тегов, не включая пробельные символы (`<aaa dd="ddd">text</aaa>` - четыре буквы);

* Суммарное число букв нормализованного текста внутри тегов, включая и пробелы;

* Число внутренних ссылок (теги `<a href="#id">`);
 
* Число битых внутренних ссылок (ссылки на несуществующие ID элементов).
