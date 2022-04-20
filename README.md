# Armagedon2022

Для запуска приложения нужно установить репозиторий и просто запустить так как сторонних бибилиотек использовано не было. iOS - 15.

# Основные Экраны

1) Экран Астериды - Список всех Астероидов, которые подгружаются порциями. Для подгрузки дополнительных астероидов нужно пролистать ленту до конца и свайпнуть вверх.

![Снимок экрана 2022-04-20 в 13 21 52](https://user-images.githubusercontent.com/44827871/164208136-d7980c8b-0767-4aad-ab28-ce7c9c15a142.png)

Так же стоит отметить картинки, которые отображаются в ячейке с конкретным астероидом.




![zelen](https://user-images.githubusercontent.com/44827871/164206379-2b38f03d-4993-427e-9c65-56d368da8b8d.png)

Данная картинка показывает, что астероид находится далеко и до его подлета остается более двух лет.

![zelen2](https://user-images.githubusercontent.com/44827871/164206679-f0a01230-ad67-4de0-8085-b7c5827a5d60.png)

Данная картинка показывает, что астероид находится на средней дистанции и до его подлета остается не менее 3 месяцев и не более двух лет.

![red](https://user-images.githubusercontent.com/44827871/164206779-2cfa5417-7c9f-4930-aad7-eaa16edcfe55.png)

Данная картинка показывает, что астероид находится очень близко и до его подлета остается менее 3 месяцев.

Так же конкретный астероид можно отпривть в корзину на уничтожение нажав кнопку "уничтожить".
![Снимок экрана 2022-04-20 в 13 21 28](https://user-images.githubusercontent.com/44827871/164207890-8aa7f00a-970a-4cb0-9c10-b6b6affadbc5.png)


2) Экран фильтры - Список настроек.

![Снимок экрана 2022-04-20 в 13 22 31](https://user-images.githubusercontent.com/44827871/164208534-46861d35-1c39-4ab0-8e31-b2defee68615.png)

На данном экране можно изменить изменить единицу измерения расстояний, а так же включить фильтр "Показывать только опасные", который будет показывать в ленте астеродиов только опасные астероиды. Для того что бы изменные поля в списке настроек применить нужно нажать на кнопку "Применить". Стоит отметить, что настройки сохранятся в телефоне и при перезаходе в приложение настройки останутся такими же какими и были при выходе из него (использовано хранилище - UserDefaults)

3) Экран подрбобная информация.

![Снимок экрана 2022-04-20 в 13 28 16](https://user-images.githubusercontent.com/44827871/164211599-d906ac4a-fa9e-4777-8f80-364d7524091b.png)

Если нажать на конкретный астероид который интересует. То откроется подробный список подлетов астероида.

4) Экран корзина.

![Снимок экрана 2022-04-20 в 13 29 45](https://user-images.githubusercontent.com/44827871/164211872-47c08208-6eba-461f-bb02-9b7cfc6bc1ca.png)

На данном экране можно увидеть список всех астеродиов и подлетов которые были выбраны для уничтожения. Если пльзователь решит изменить свое решение по какому-то подлету астероида его можно убрать из списка на уничтожение. Так же стоит отметить что все подлеты астероидов сохраняются в телефоне с и при перезеаходе в приложение список останется таким, каким был до выхода (было использование хранилище - Core Data).












