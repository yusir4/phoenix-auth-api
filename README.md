# Authentication & Follow API

## Görev

1. Login - Register İşlemleri

-  Ad-Soyad, Email ve Şifre ile kayıt yapılabilen bir register api

> Burada kontrol edilmesi gereken tek şey aynı email'e sahip başka bir kullanıcının olup-olmayışı ve email-validation

- Email ve Şifre ile  giriş yapılabilen bir login api
      
     Login api'si iki aşamadan oluşacaktır

     > Kullanıcı Email ve Şifresini bir servise gönderir. Servis başarılı bir sonuç verirse bir refresh token ile response döner. Response ile gelen refresh token kullanım süresi 6 aydır.

     > Kullanıcı bu refresh token ile jwt-token talep eder. Bu jwt-token'in kullanım süresi sadece 15 dk'dır, kullanım süresi dolduğunda başka bir işlem yapılacaksa refresh token ile yeniden jwt-token talep edilir

2. Takipleşme Kurgusu için gerekli api

- Kayıtlı olan bir kullanıcı, kayıtlı olan bir başka kullanıcıya takip isteği gönderir.

> Takip edilen kullanıcıya RabbitMQ kullanılarak işlem kuyrugu convansiyonuna göre takip bilgisi için mail gönderimi sağlanır.


## Yapılandırma

* Elixir version = 1.11.2
* Phoenix version = 1.5.7
* Authentication: JWT
* Database = Postgresql

## Durum

Register API | Login API | JWT API | Follow API | RabbitMQ 
:------------ | :-------------| :-------------| :------------- | :-------------
:heavy_check_mark: | :heavy_check_mark: |  :clock3: | :clock3: | :clock3:

## Rotalar

      user_path  POST    /api/users/login        MainModuleWeb.UserController :sign_in
      user_path  POST    /api/users/register     MainModuleWeb.UserController :create
      user_path  GET     /api/users              MainModuleWeb.UserController :index
      user_path  GET     /api/users/:id          MainModuleWeb.UserController :show
      user_path  PATCH   /api/users/:id          MainModuleWeb.UserController :update
      PUT     /api/users/:id          MainModuleWeb.UserController :update
      user_path  DELETE  /api/users/:id          MainModuleWeb.UserController :delete

