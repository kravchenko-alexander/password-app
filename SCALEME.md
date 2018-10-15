## Puma

Сервіс має можливість масштабуватись у обчислювальній 
можливості сервера опрацьовувати запити за допомогою 
змін у файлі `config/puma.rb`

`threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }`

`threads threads_count, threads_count`

Достатньо додати змінну `RAILS_MAX_THREADS` в файл `.env`.
Наприклад:

`RAILS_MAX_THREADS=10`

Від цього залежить кількість процесів і потоків puma.

## PostgreSQL

У файлі `config/database.yml` можна побачити 

`pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>`

Достатньо долати змінну  `RAILS_MAX_THREADS` в файл `.env`.
Наприклад:

`RAILS_MAX_THREADS=10`

Від цього залежить кількість процесів СУБД PostgreSQL.
 