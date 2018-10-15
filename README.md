# README

## Старт сервісу

    1. Docker встановлення:
    
        $ sudo docker-compose build
    
    2. Виконати команди для PostgreSQL:
    
        $ sudo docker-compose run web rake db:create
    
        $ sudo docker-compose run web rake db:migrate
    
    
    3. Для запуску додатку http://localhost:8080/
    
        $ docker-compose up
        
    4. Створити нового користувача:
        
        http://localhost:8080/api/docs/registration/create_new_user
        
    5. За допомогою отриманого Access-Token створити новий сет паролів
        
        Для масиву паролів
        http://localhost:8080/api/docs/password_sets/create_password_link_for_list_of_passwords
        
        Для одного паролю
        http://localhost:8080/api/docs/password_sets/create_password_link_for_single_password

    6. За допомогою отриманого посилання отримати паролі назад:
    
        Режим гостя:
            Для одного паролю
            http://localhost:8080/api/docs/password_sets/get_decrypted_password_set_for_single_password
            
            Для масиву паролів
            http://localhost:8080/api/docs/password_sets/get_decrypted_list_for_list_of_passwords
            
        Режим зареєстрованого користувача (будь-якого)
            Для одного паролю
            http://localhost:8080/api/docs/password_sets/get_decrypted_password_set_for_single_password_by_user_
            
            Для масиву паролів
            http://localhost:8080/api/docs/password_sets/get_decrypted_list_for_list_of_passwords_by_user
            
    7. Користувач, який створив сет, може переглянути історію цього сету
        http://localhost:8080/api/docs/password_views/get_list
        
    Також є ендпойнти для OAuth 2.0, з якими можна познайомитися
    в доках API
            
        
## Тестування

    $ sudo docker-compose run -e "RAILS_ENV=test" web rake db:migrate

    $ sudo docker-compose run -e "RAILS_ENV=test" web rspec spec/
    
    Code-style (Rubocop)
    
    $ sudo docker-compose run web rubocop

## API

1. Генерація API docs (інтеграційні тести)
    
    `$ sudo docker-compose run web rake docs:generate`
    
2. Переглянути `http://localhost:8080/api/docs`
  
## Методологія

- Користувачі реєструються в сервісі.
- Зареєстровані користувачі за допомогою (OAuth 2.0 password-way)
  отримують Access-Token.   
- Зареєстровані користувачі відправляють пароль (або масив паролів) і
  отримують від сервісу посилання, за допомогою якої вони
  едінаразово зможуть отримати свій пароль.
- За допомогою посилання можливо отримати пароль будь-якого
  незареєстрованим користувачам.

#### Структура БД:

    - файл db / schema.rb після проведення міграції БД

#### Алгоритм створення пароля

    1) Користувач дає пароль (password_body)
    2) Для користувача створюється
    новий сет з паролів (password_set),
    який має access_token (поле, яке
    буде використовуватися для отримання паролів)
    3) Для password_set створюється новий пароль (password),
    має поле encrypted_password (за допомогою
    OpenSSL :: Cipher.new ('aes-256-cbc') шифрується password_body)
    4) Шифруємо також password_set.access_token і віддаємо
    користувачеві посилання (шифрування необхідно, щоб не можна було легко
    зіставити посилання користувача і дані в базі даних)
    
#### Алгоритм отримання пароля
    
    1) Відбувається розшифрування і пошук
    password_set.access_token
    2) Пошук всіх passwords у password_set
    3) Розшифрування всіх passwords за допомогою дешифрування
    (Бібліотека OpenSSL :: Cipher.new ('aes-256-cbc'))
    
## Покращення

    1) Застосувати push_token для сесій користувача
    шляхом розсилки повідомлень про перегляди посилання (паролів)
    2) Застосувати 2 етапи шифрування, додавши нову бібліотеку
    3) Написати unit тести
    4) Застосувати патерни Repository, Query, Form objects