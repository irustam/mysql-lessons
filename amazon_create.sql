-- Создаем БД и таблицы
CREATE DATABASE amazon;
USE amazon;

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  url VARCHAR(255) UNIQUE NOT NULL COMMENT 'УРЛ раздела, типа clothes',
  photo VARCHAR(255) DEFAULT '/img/default_catalog.png' COMMENT 'Картинка для раздела. Если не указана, ставим заглушку',
  sort_id MEDIUMINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Поле, по которому категории будем сортировать при выводе.'
) COMMENT = 'Разделы интернет-магазина';

DROP TABLE IF EXISTS catalogs_links;
CREATE TABLE catalogs_links (
  parent_id MEDIUMINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'id родительского раздела из таблицы catalogs. У главных разделов будет 1, т.е. в таблице catalogs под 1 будет псевдо раздел Главная',
  daughter_id MEDIUMINT UNSIGNED NOT NULL UNIQUE COMMENT 'id подраздела',
  PRIMARY KEY (parent_id, daughter_id),
  CONSTRAINT catalogs_links_parent_id_fk FOREIGN KEY (parent_id) REFERENCES catalogs(id),
  CONSTRAINT catalogs_links_daughter_id_fk FOREIGN KEY (daughter_id) REFERENCES catalogs(id)
) COMMENT = 'Связи между разделами (какой раздел в какой раздел входит)';

DROP TABLE IF EXISTS brands;
CREATE TABLE brands (
  id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  url VARCHAR(255) UNIQUE NOT NULL COMMENT 'УРЛ бренда, типа philips',
  photo VARCHAR(255) DEFAULT '/img/default_brand.png' COMMENT 'Картинка для бренда. Если не указана, ставим заглушку'
) COMMENT = 'Бренды товаров';

DROP TABLE IF EXISTS shops;
CREATE TABLE shops (
  id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  url VARCHAR(255) UNIQUE NOT NULL COMMENT 'УРЛ страницы продавца, типа super-shop',
  photo VARCHAR(255) DEFAULT '/img/default_shop.png' COMMENT 'Картинка для продавца. Если не указана, ставим заглушку',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT = 'Продавцы';

DROP TABLE IF EXISTS authors;
CREATE TABLE authors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  url VARCHAR(255) UNIQUE NOT NULL COMMENT 'УРЛ страницы автора, типа pushkin',
  photo VARCHAR(255) DEFAULT '/img/default_author.png' COMMENT 'Картинка для автора. Если не указана, ставим заглушку'
) COMMENT = 'Авторы';

DROP TABLE IF EXISTS products_types;
CREATE TABLE products_types (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'id типа товара',
  name VARCHAR(255) NOT NULL COMMENT 'Название'
) COMMENT = 'Таблица с типами товаров';

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  url VARCHAR(255) UNIQUE NOT NULL COMMENT 'УРЛ товара, типа pen-123',
  product_type_id TINYINT UNSIGNED NOT NULL COMMENT 'id типа товара',
  brand_id MEDIUMINT UNSIGNED NOT NULL COMMENT 'id бренда',
  author_id BIGINT UNSIGNED NOT NULL COMMENT 'id автора. Для упрощения у одной книги только 1 автор возможен.',
  shop_id MEDIUMINT UNSIGNED NOT NULL COMMENT 'id продавца',
  sort_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Поле, по которому товары будем сортировать при выводе.',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT products_product_type_id_fk FOREIGN KEY (product_type_id) REFERENCES products_types(id),
  CONSTRAINT products_brand_id_fk FOREIGN KEY (brand_id) REFERENCES brands(id),  
  CONSTRAINT products_author_id_fk FOREIGN KEY (author_id) REFERENCES authors(id),
  CONSTRAINT products_shop_id_fk FOREIGN KEY (shop_id) REFERENCES shops(id)
) COMMENT = 'Карточки товаров';

DROP TABLE IF EXISTS products_links;
CREATE TABLE products_links (
  product_id BIGINT UNSIGNED NOT NULL COMMENT 'id товара',
  catalog_id MEDIUMINT UNSIGNED NOT NULL COMMENT 'id раздела',
  PRIMARY KEY (product_id, catalog_id),
  CONSTRAINT products_links_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT products_links_catalog_id_fk FOREIGN KEY (catalog_id) REFERENCES catalogs(id)
) COMMENT = 'Связи между товарами и разделами';

DROP TABLE IF EXISTS products_variants;
CREATE TABLE products_variants (
  id SERIAL PRIMARY KEY COMMENT 'id варианта товара',
  product_id BIGINT UNSIGNED NOT NULL COMMENT 'id товара, к которому привязан данный вариант',
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  short_desription TEXT COMMENT 'Короткое описание',
  desription TEXT COMMENT 'Описание',
  url VARCHAR(255) UNIQUE NOT NULL COMMENT 'УРЛ варианта товара, типа pen-123',
  price INT UNSIGNED NOT NULL COMMENT 'Цена',
  weight INT UNSIGNED NOT NULL COMMENT 'Вес товара',
  used BOOLEAN NOT NULL DEFAULT 0 COMMENT 'Если ноль, то товар новый. Если не 0 - то б/у',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT products_variants_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id)
) COMMENT = 'Таблица с вариантами товаров';

DROP TABLE IF EXISTS products_price_log;
CREATE TABLE products_price_log (
  product_variant_id BIGINT UNSIGNED NOT NULL COMMENT 'id варианта товара',
  old_price INT UNSIGNED COMMENT 'Старая цена',
  new_price INT UNSIGNED NOT NULL COMMENT 'Новая цена',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=Archive COMMENT = 'Лог изменения цен на варианты товаров';

DROP TABLE IF EXISTS `options`;
CREATE TABLE `options` (
  id SERIAL PRIMARY KEY COMMENT 'id характеристики',
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  catalog_id MEDIUMINT UNSIGNED NOT NULL COMMENT 'id раздела',
  CONSTRAINT options_catalog_id_fk FOREIGN KEY (catalog_id) REFERENCES catalogs(id)
) COMMENT = 'Все возможные характеристики товаров c привязкой к каталогу';

DROP TABLE IF EXISTS products_options;
CREATE TABLE products_options (
  option_id BIGINT UNSIGNED NOT NULL COMMENT 'id характеристики',
  product_variant_id BIGINT UNSIGNED NOT NULL COMMENT 'id варианта товара',
  `value` VARCHAR(255) NOT NULL COMMENT 'Значение характеристики для данного товара',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (option_id, product_variant_id),
  CONSTRAINT products_options_option_id_fk FOREIGN KEY (option_id) REFERENCES options(id),
  CONSTRAINT products_options_product_variant_id_fk FOREIGN KEY (product_variant_id) REFERENCES products_variants(id)
) COMMENT = 'Значения характеристик для вариантов товаров';

DROP TABLE IF EXISTS mediafiles_types;
CREATE TABLE mediafiles_types (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'id типа медиафайла',
  name VARCHAR(255) NOT NULL COMMENT 'Название'
) COMMENT = 'Таблица с типами медиафайлов';

DROP TABLE IF EXISTS mediafiles;
CREATE TABLE mediafiles (
  id SERIAL PRIMARY KEY COMMENT 'id медиафайла',
  link VARCHAR(255) NOT NULL COMMENT 'Ссылка на картинку на сервере',
  shop_id MEDIUMINT UNSIGNED NOT NULL COMMENT 'id продавца, который добавил этот медиафайл',
  product_variant_id BIGINT UNSIGNED NOT NULL COMMENT 'id варианта товара',
  mediatype_id TINYINT UNSIGNED NOT NULL COMMENT 'id варианта медиафайла',
  sort_id TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Поле, по которому медиафайлы будем сортировать при выводе в рамках товара.',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT mediafiles_shop_id_fk FOREIGN KEY (shop_id) REFERENCES shops(id),
  CONSTRAINT mediafiles_product_variant_id_fk FOREIGN KEY (product_variant_id) REFERENCES products_variants(id),
  CONSTRAINT mediafiles_mediatype_id_fk FOREIGN KEY (mediatype_id) REFERENCES mediafiles_types(id)
) COMMENT = 'Медиафайлы товаров';

DROP TABLE IF EXISTS regions;
CREATE TABLE regions (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL COMMENT 'Название'
) COMMENT = 'Регионы доставки';

DROP TABLE IF EXISTS regions_links;
CREATE TABLE regions_links (
  parent_id BIGINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'id родительского региона из таблицы regions. У главных разделов будет 1, т.е. в таблице regions под 1 будет псевдорегион Весь мир',
  daughter_id BIGINT UNSIGNED NOT NULL UNIQUE COMMENT 'id подрегиона',
  PRIMARY KEY (parent_id, daughter_id),
  CONSTRAINT regions_links_parent_id_fk FOREIGN KEY (parent_id) REFERENCES regions(id),
  CONSTRAINT regions_links_daughter_id_fk FOREIGN KEY (daughter_id) REFERENCES regions(id)
) COMMENT = 'Связи между регионами';

DROP TABLE IF EXISTS warehouses;
CREATE TABLE warehouses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  shop_id MEDIUMINT UNSIGNED NOT NULL COMMENT 'id продавца - владельца склада',
  region_id BIGINT UNSIGNED NOT NULL COMMENT 'id региона, к которому привязан склад',
  price INT UNSIGNED COMMENT 'Цена самовывоза',
  pickup_point BOOLEAN COMMENT 'Если не ноль, то склад является пунктом самовывоза. Если 0 - то не является',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT warehouses_shop_id_fk FOREIGN KEY (shop_id) REFERENCES shops(id),
  CONSTRAINT warehouses_region_id_fk FOREIGN KEY (region_id) REFERENCES regions(id)
) COMMENT = 'Склады продавцов';

DROP TABLE IF EXISTS warehouses_stock;
CREATE TABLE warehouses_stock (
  warehouse_id BIGINT UNSIGNED NOT NULL COMMENT 'id склада',
  product_variant_id BIGINT UNSIGNED NOT NULL COMMENT 'id варианта товара',
  qauntity INT UNSIGNED NOT NULL COMMENT 'кол-во товара на складе',
  PRIMARY KEY (warehouse_id, product_variant_id),
  CONSTRAINT warehouses_stock_warehouse_id_fk FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
  CONSTRAINT warehouses_stock_product_variant_id_fk FOREIGN KEY (product_variant_id) REFERENCES products_variants(id)
) COMMENT = 'Кол-во вариантов товаров на складе продавца';

DROP TABLE IF EXISTS delyvery_types;
CREATE TABLE delyvery_types (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'id типа доставки',
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  desription TEXT COMMENT 'Описание'
) COMMENT = 'Варианты доставки от Амазона';

DROP TABLE IF EXISTS delyvery_prices;
CREATE TABLE delyvery_prices (
  delyvery_type_id TINYINT UNSIGNED NOT NULL COMMENT 'id типа доставки',
  region_id BIGINT UNSIGNED NOT NULL COMMENT 'id региона',
  shop_id MEDIUMINT UNSIGNED NOT NULL COMMENT 'id продавца - владельца склада',
  price INT UNSIGNED NOT NULL COMMENT 'Цена доставки',
  PRIMARY KEY (delyvery_type_id, region_id, shop_id),
  CONSTRAINT delyvery_prices_delyvery_type_id_fk FOREIGN KEY (delyvery_type_id) REFERENCES delyvery_types(id),
  CONSTRAINT delyvery_prices_region_id_fk FOREIGN KEY (region_id) REFERENCES regions(id),
  CONSTRAINT delyvery_prices_shop_id_fk FOREIGN KEY (shop_id) REFERENCES shops(id)
) COMMENT = 'Стоимость доставки по типам доставки и региона';

DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'id типа оплаты',
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  desription TEXT COMMENT 'Описание'
) COMMENT = 'Варианты оплаты от Амазона';

DROP TABLE IF EXISTS offers_types;
CREATE TABLE offers_types (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'id типа акции',
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  desription TEXT COMMENT 'Описание'
) COMMENT = 'Типы акций';

DROP TABLE IF EXISTS offers;
CREATE TABLE offers (
  id SERIAL PRIMARY KEY COMMENT 'id акции',
  offer_type_id TINYINT UNSIGNED NOT NULL COMMENT 'id типа акции',
  shop_id MEDIUMINT UNSIGNED NOT NULL COMMENT 'id продавца - владельца акции',
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  desription TEXT COMMENT 'Описание',
  url VARCHAR(255) UNIQUE NOT NULL COMMENT 'УРЛ акции, типа black-friday',
  photo VARCHAR(255) DEFAULT '/img/default_offer.png' COMMENT 'Картинка для акции. Если не указана, ставим заглушку',
  is_active BOOLEAN NOT NULL COMMENT '1-акция активна, 0-акция выключена',
  priority TINYINT UNSIGNED NOT NULL COMMENT 'Приоритет акций',
  start_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  finish_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT offers_offer_type_id_fk FOREIGN KEY (offer_type_id) REFERENCES offers_types(id),
  CONSTRAINT offers_shop_id_fk FOREIGN KEY (shop_id) REFERENCES shops(id)
) COMMENT = 'Акции';

DROP TABLE IF EXISTS products_offers_price;
CREATE TABLE products_offers_price (
  offer_id BIGINT UNSIGNED NOT NULL COMMENT 'id акции',
  priority TINYINT UNSIGNED NOT NULL COMMENT 'Приоритет акций',
  region_id BIGINT UNSIGNED NOT NULL COMMENT 'id региона',
  product_variant_id BIGINT UNSIGNED NOT NULL COMMENT 'id варианта товара',
  discount_price INT UNSIGNED NOT NULL COMMENT 'Цена',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (offer_id, region_id, product_variant_id),
  CONSTRAINT products_offers_price_offer_id_fk FOREIGN KEY (offer_id) REFERENCES offers(id),
  CONSTRAINT products_offers_price_region_id_fk FOREIGN KEY (region_id) REFERENCES regions(id),
  CONSTRAINT products_offers_price_product_variant_id_fk FOREIGN KEY (product_variant_id) REFERENCES products_variants(id)
) COMMENT = 'Значения скидок на товары';

DROP TABLE IF EXISTS offers_conditions;
CREATE TABLE offers_conditions (
  offer_id BIGINT UNSIGNED NOT NULL COMMENT 'id акции',
  region_id BIGINT UNSIGNED NOT NULL COMMENT 'id региона',
  delyvery_type_id TINYINT UNSIGNED COMMENT 'id типа доставки',
  payment_id TINYINT UNSIGNED COMMENT 'id типа оплаты',
  warehouse_id BIGINT UNSIGNED COMMENT 'id склада',
  min_product_price INT UNSIGNED COMMENT 'Условие для акции по цене товара от',
  max_product_price INT UNSIGNED COMMENT 'Условие для акции по цене товара до',
  min_product_weight INT UNSIGNED COMMENT 'Условие для акции по весу товара от',
  max_product_weight INT UNSIGNED COMMENT 'Условие для акции по весу товара до',
  min_order_price INT UNSIGNED COMMENT 'Условие для акции по сумме заказа от',
  max_order_price INT UNSIGNED COMMENT 'Условие для акции по сумме заказа до',
  min_order_weight INT UNSIGNED COMMENT 'Условие для акции по весу заказа от',
  max_order_weight INT UNSIGNED COMMENT 'Условие для акции по весу заказа до',
  sale_product_price INT UNSIGNED COMMENT 'Скидочная стоимость товара в валюте',
  sale_product_price_percent INT UNSIGNED COMMENT 'Скидочная стоимость товара в процентах',
  bonus BIGINT UNSIGNED COMMENT 'id товара бонуса. Если указан, то он будет подарком в данной акции',
  CONSTRAINT offers_conditions_offer_id_fk FOREIGN KEY (offer_id) REFERENCES offers(id),
  CONSTRAINT offers_conditions_region_id_fk FOREIGN KEY (region_id) REFERENCES regions(id),
  CONSTRAINT offers_conditions_delyvery_type_id_fk FOREIGN KEY (delyvery_type_id) REFERENCES delyvery_types(id),
  CONSTRAINT offers_conditions_payment_id_fk FOREIGN KEY (payment_id) REFERENCES payments(id),
  CONSTRAINT offers_conditions_warehouse_id_fk FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
  CONSTRAINT offers_bonus_fk FOREIGN KEY (bonus) REFERENCES products_variants(id)
) COMMENT = 'Все общие условия акции';

DROP TABLE IF EXISTS rates;
CREATE TABLE rates (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'id курса валюты',
  name VARCHAR(255) NOT NULL COMMENT 'Название',
  usd_rate FLOAT COMMENT 'Курс валюты к доллару',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Курсы валют Амазона';

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY COMMENT 'id пользователя',
  email VARCHAR(255) NOT NULL COMMENT 'Емейл для входа',
  password VARCHAR(255) NOT NULL COMMENT 'Пароль',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Пользователи и их данные доступа';

DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
  user_id BIGINT UNSIGNED NOT NULL UNIQUE PRIMARY KEY COMMENT 'id пользователя',
  name VARCHAR(255) NOT NULL COMMENT 'Имя пользователя',
  phone VARCHAR(30) COMMENT 'Телефон',
  region_id BIGINT UNSIGNED NOT NULL COMMENT 'id региона',
  photo VARCHAR(255) COMMENT 'Ссылка на фотографию',
  birthday_at DATETIME,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT profiles_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT profiles_region_id_fk FOREIGN KEY (region_id) REFERENCES regions(id)
) COMMENT = 'Пользователи и их данные доступа';

DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
  id SERIAL PRIMARY KEY COMMENT 'id отзыва',
  product_id BIGINT UNSIGNED NOT NULL COMMENT 'id товара, на который сделан отзыв',
  desription TEXT COMMENT 'Текст отзыва',
  review_rate TINYINT UNSIGNED NOT NULL COMMENT 'Рейтинг от пользователя',
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'id пользователя',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT reviews_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT reviews_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT = 'Отзывы на товары';

DROP TABLE IF EXISTS reviews_photos;
CREATE TABLE reviews_photos (
  id SERIAL PRIMARY KEY COMMENT 'id фото',
  review_id BIGINT UNSIGNED NOT NULL COMMENT 'id отзыва',
  link VARCHAR(255) NOT NULL COMMENT 'Ссылка на картинку на сервере',
  CONSTRAINT reviews_photos_review_id_fk FOREIGN KEY (review_id) REFERENCES reviews(id)
) COMMENT = 'Отзывы на товары';

DROP TABLE IF EXISTS users_video;
CREATE TABLE users_video (
  id SERIAL PRIMARY KEY COMMENT 'id видео',
  product_id BIGINT UNSIGNED NOT NULL COMMENT 'id товара',
  link VARCHAR(255) NOT NULL COMMENT 'Ссылка на видео на сервере',
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'id пользователя',
  CONSTRAINT users_video_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT users_video_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT = 'Видео от пользователей к товарам';

DROP TABLE IF EXISTS faq;
CREATE TABLE faq (
  id SERIAL PRIMARY KEY COMMENT 'id вопроса/ответа',
  product_id BIGINT UNSIGNED NOT NULL COMMENT 'id товара',
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'id пользователя',
  desription TEXT NOT NULL COMMENT 'Текст вопроса/ответа',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT faq_product_id_fk FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT faq_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT = 'Вопросы и ответы от пользователей к товарам';

DROP TABLE IF EXISTS faq_links;
CREATE TABLE faq_links (
  answer_id BIGINT UNSIGNED NOT NULL COMMENT 'id ответа',
  to_faq_id BIGINT UNSIGNED NOT NULL COMMENT 'id вопроса, на который дан ответ',
  PRIMARY KEY (answer_id, to_faq_id),
  CONSTRAINT faq_links_answer_id_fk FOREIGN KEY (answer_id) REFERENCES faq(id),
  CONSTRAINT faq_links_to_faq_id_fk FOREIGN KEY (to_faq_id) REFERENCES faq(id)
) COMMENT = 'Связи между вопросами и ответами';

DROP TABLE IF EXISTS users_payments;
CREATE TABLE users_payments (
  id SERIAL PRIMARY KEY COMMENT 'id способа оплаты',
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'id пользователя',
  card_data TEXT NOT NULL COMMENT 'данные банковской карты в каком-то зашифрованном виде',
  payment_id TINYINT UNSIGNED COMMENT 'id типа оплаты',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT users_payments_payment_id_fk FOREIGN KEY (payment_id) REFERENCES payments(id),
  CONSTRAINT users_payments_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT = 'Профили оплаты пользователей (данные карт)';

DROP TABLE IF EXISTS users_delivery;
CREATE TABLE users_delivery (
  id SERIAL PRIMARY KEY COMMENT 'id способа доставки',
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'id пользователя',
  region_id BIGINT UNSIGNED NOT NULL COMMENT 'id региона',
  delyvery_type_id TINYINT UNSIGNED COMMENT 'id типа доставки',
  warehouse_id BIGINT UNSIGNED COMMENT 'id склада, если пользователь заказывал доставку в пункт самовывоза',
  address TEXT COMMENT 'Не буду здесь приводить весь набор полей доставки. Ограничусь этим',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT users_delivery_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT users_delivery_region_id_fk FOREIGN KEY (region_id) REFERENCES regions(id),
  CONSTRAINT users_delivery_delyvery_type_id_fk FOREIGN KEY (delyvery_type_id) REFERENCES delyvery_types(id),
  CONSTRAINT users_delivery_warehouse_id_fk FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
) COMMENT = 'Профили доставки';

DROP TABLE IF EXISTS pets_type;
CREATE TABLE pets_type (
  id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'id типа питомца',
  name VARCHAR(255) NOT NULL COMMENT 'название питомца',
  photo VARCHAR(255) COMMENT 'Картинка для типа питомца'
) COMMENT = 'Типы питомцев пользователей';

DROP TABLE IF EXISTS users_pets;
CREATE TABLE users_pets (
  id SERIAL PRIMARY KEY COMMENT 'id питомца',
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'id пользователя',
  pet_type_id SMALLINT UNSIGNED NOT NULL COMMENT 'id типа питомца',
  name VARCHAR(255) NOT NULL COMMENT 'имя питомца',
  photo VARCHAR(255) COMMENT 'Фото питомца пользователя',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT users_pets_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT users_pets_pet_type_id_fk FOREIGN KEY (pet_type_id) REFERENCES pets_type(id)
) COMMENT = 'Профили питомцев пользователей';

DROP TABLE IF EXISTS lists_types;
CREATE TABLE lists_types (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY COMMENT 'id типа списка',
  name VARCHAR(255) NOT NULL COMMENT 'название списка'
  product_type_id TINYINT UNSIGNED NOT NULL COMMENT 'id типа товаров, которые могут быть в этом списке',
  CONSTRAINT lists_types_product_type_id_fk FOREIGN KEY (product_type_id) REFERENCES products_types(id)
) COMMENT = 'Типы списков товаров пользователей';

DROP TABLE IF EXISTS users_lists;
CREATE TABLE users_lists (
  id SERIAL PRIMARY KEY COMMENT 'id списка',
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'id пользователя',
  list_type_id TINYINT UNSIGNED NOT NULL COMMENT 'id типа списка',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT wish_lists_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT wish_lists_list_type_id_fk FOREIGN KEY (list_type_id) REFERENCES lists_types(id)
) COMMENT = 'Списки товаров пользователей, в т.ч. и корзина, и заказы';

DROP TABLE IF EXISTS lists_products;
CREATE TABLE lists_products (
  list_id BIGINT UNSIGNED NOT NULL COMMENT 'id списка',
  product_variant_id BIGINT UNSIGNED NOT NULL COMMENT 'id товара',
  qauntity INT UNSIGNED NOT NULL COMMENT 'кол-во товара в списке',
  price INT UNSIGNED NOT NULL COMMENT 'цена товара в списке',
  CONSTRAINT lists_products_list_id_fk FOREIGN KEY (list_id) REFERENCES users_lists(id),
  CONSTRAINT lists_products_product_variant_id_fk FOREIGN KEY (product_variant_id) REFERENCES products_variants(id)
) COMMENT = 'Товары в списках';

-- Добавляю индексы
-- В авторах, брендах, разделах, акциях, магазинах прежде всего имя и урл, то что чаще всего заправшивается:
ALTER TABLE authors ADD INDEX authors_name_idx (name);
ALTER TABLE authors ADD INDEX authors_url_idx (url);

ALTER TABLE brands ADD INDEX brands_name_idx (name);
ALTER TABLE brands ADD INDEX brands_url_idx (url);

ALTER TABLE catalogs ADD INDEX catalogs_name_idx (name);
ALTER TABLE catalogs ADD INDEX catalogs_url_idx (url);

ALTER TABLE offers ADD INDEX offers_name_idx (name);
ALTER TABLE offers ADD INDEX offers_url_idx (url);

ALTER TABLE shops ADD INDEX shops_name_idx (name);
ALTER TABLE shops ADD INDEX shops_url_idx (url);

-- В медиафайлах ссылка на медиафайл
ALTER TABLE mediafiles ADD INDEX mediafiles_link_idx (link);

-- В таблице со списком характеристик их названия
ALTER TABLE `options` ADD INDEX options_name_idx (name);

-- УРЛ товара в таблице товаров
ALTER TABLE products ADD INDEX products_url_idx (url);

-- Значения характеристик товаров:
ALTER TABLE products_options ADD INDEX products_options_value_idx (value);

-- Имя, урл и цена в вариантах товаров
ALTER TABLE products_variants ADD INDEX products_variants_name_idx (name);
ALTER TABLE products_variants ADD INDEX products_variants_url_idx (url);
ALTER TABLE products_variants ADD INDEX products_variants_price_idx (price);

-- Имя пользователя из профайлов
ALTER TABLE profiles ADD INDEX profiles_name_idx (name);

-- Регионы
ALTER TABLE regions ADD INDEX regions_name_idx (name);

-- В отзывах пользователей:
ALTER TABLE reviews ADD INDEX reviews_review_rate_idx (review_rate);

-- Емейл в пользователях:
ALTER TABLE users ADD INDEX users_email_idx (email);

-- Название и стоимость в складах (пункт самовывоза)
ALTER TABLE warehouses ADD INDEX warehouses_name_idx (name);
ALTER TABLE warehouses ADD INDEX warehouses_price_idx (price);


- Представления
-- 1. Создадим представление с агрегированными данными о рейтингах товаров.
-- В дальнейшем это поможет быстро получать для страниц эти данные
DROP VIEW IF EXISTS products_rates;
CREATE VIEW products_rates AS 
  SELECT r.product_id, 
    r.review_rate, 
    COUNT(*) AS reviews_count
    FROM reviews AS r
    GROUP BY r.product_id, 
      r.review_rate
;

-- 2. Представление с характеристиками и их значениями по товарам и вариантам товаров.
-- Это поможет дальше быстро вывести в карточке товара нужные характеристики
DROP VIEW IF EXISTS products_options_value;
CREATE VIEW products_options_value AS 
  SELECT pv.product_id, 
    po.product_variant_id, 
    o.name, 
    po.value
    FROM products_options AS po
      JOIN `options` AS o
      ON po.option_id = o.id
      JOIN products_variants AS pv
      ON po.product_variant_id = pv.id
;

- Функции и процедуры
-- Также сделаем функцию получения суммарного рейтинга товара по его id
DELIMITER //
DROP FUNCTION IF EXISTS product_common_rate//
CREATE FUNCTION product_common_rate (product_id_val BIGINT)
RETURNS FLOAT READS SQL DATA
BEGIN
  DECLARE product_rate FLOAT;
  SET product_rate = 
    (SELECT SUM(r.review_rate) / COUNT(*)
      FROM reviews AS r
      WHERE r.product_id = product_id_val
      GROUP BY r.product_id
    )
  ;
  RETURN product_rate;
END//
DELIMITER ;


-- Процедура пересчета скидки на товары
-- При таком кол-ве товаров, Амазон наверняка хранит и обсчитывает скидки на товары раз в какой-то период (один раз в день или в час...)
-- Для подсчета скидки я получу данные о том, в каких акциях какие скидки применяются,
-- и сохраню их в специально созданной таблице для хранения скидок products_offers_price.
DROP PROCEDURE IF EXISTS products_discounts_count;
DELIMITER //
CREATE PROCEDURE products_discounts_count ()
  BEGIN
    INSERT INTO products_offers_price (offer_id, 
      priority, 
      region_id, 
      product_variant_id, 
      discount_price)
      SELECT o.id AS offer_id, 
        o.priority, 
        oc.region_id, 
        ws.product_variant_id, 
        ((1 - oc.sale_product_price_percent/100) * pv.price) AS discount_price
        FROM offers AS o
          JOIN offers_types AS ot
          ON o.offer_type_id = ot.id
          JOIN offers_conditions AS oc
          ON o.id = oc.offer_id
          JOIN warehouses_stock AS ws
          ON oc.warehouse_id = ws.warehouse_id
          JOIN products_variants AS pv
          ON ws.product_variant_id = pv.id
        WHERE o.is_active = 1
          AND o.start_at <= NOW()
          AND o.finish_at > NOW()
          AND ot.id = 1
          AND oc.delyvery_type_id IS NULL
          AND oc.payment_id IS NULL
          AND oc.warehouse_id IS NOT NULL
      UNION ALL
      SELECT o.id AS offer_id, 
        o.priority, 
        oc.region_id, 
        ws.product_variant_id, 
        (pv.price - oc.sale_product_price) AS discount_price
        FROM offers AS o
          JOIN offers_types AS ot
          ON o.offer_type_id = ot.id
          JOIN offers_conditions AS oc
          ON o.id = oc.offer_id
          JOIN warehouses_stock AS ws
          ON oc.warehouse_id = ws.warehouse_id
          JOIN products_variants AS pv
          ON ws.product_variant_id = pv.id
        WHERE o.is_active = 1
          AND o.start_at <= NOW()
          AND o.finish_at > NOW()
          AND ot.id = 2
          AND oc.delyvery_type_id IS NULL
          AND oc.payment_id IS NULL
          AND oc.warehouse_id IS NOT NULL
      ON DUPLICATE KEY UPDATE
        priority = VALUES (priority),
        discount_price = VALUES (discount_price)
;
  END//
DELIMITER ;
CALL products_discounts_count();



-- Триггеры
-- 1. Если удаляем картинку у раздела, бренда, продавца, автора, акции, то ставим заглушку.
-- В каждом случае буду использовать BEFORE UPDATE. Покажу на примере раздела:
DELIMITER //
DROP TRIGGER IF EXISTS catalogs_photo_default//
CREATE TRIGGER catalogs_photo_default BEFORE UPDATE ON catalogs
FOR EACH ROW
BEGIN
  SET NEW.photo = COALESCE(NEW.photo, '/img/default_catalog.png');
END//

-- 2. При изменении цены варианта товара, записываем в архивную таблицу лог изменений
DELIMITER //
DROP TRIGGER IF EXISTS add_to_price_log_update//
CREATE TRIGGER add_to_price_log_update AFTER UPDATE ON products_variants
FOR EACH ROW
BEGIN
  INSERT INTO products_price_log (product_variant_id, old_price, new_price) VALUES (NEW.id, OLD.price, NEW.price);
END//

DELIMITER //
DROP TRIGGER IF EXISTS add_to_price_log_insert//
CREATE TRIGGER add_to_price_log_insert AFTER INSERT ON products_variants
FOR EACH ROW
BEGIN
  INSERT INTO products_price_log (product_variant_id, old_price, new_price) VALUES (NEW.id, NULL, NEW.price);
END//
