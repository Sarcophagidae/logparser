# logparser

Парсер логов exim.

parse.pl - парсит лог и сохраняет результат в бд.
Лог передаётся посредство STDIN:
```
cat mail.log | perl parse.log
```

index.pl - осуществляет поиск логов содержащих указанный адрес.
Для работы необходимы Apache с настроеным CGI.
