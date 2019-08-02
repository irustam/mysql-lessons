-- Выводим список основных категорий для меню http://prntscr.com/oncfo2 с сортировкой по соответствующему полю
-- Аналогично, меняя parent_id, можно вывести любые подкатегории
SELECT c.id, c.name, c.url 
  FROM catalogs AS c
    JOIN catalogs_links AS cl
      ON c.id = cl.daughter_id
  WHERE cl.parent_id = 1 
  ORDER BY c.sort_id
;

-- Выводим список товаров определенной категории (на примере id 18) http://prntscr.com/ondgdz. В запросе я получил все варианты товара,
-- а дальше уже на стороне приложения мы должны определить, по какому принципу выводить данные в каталоге о товаре.
-- Т.е. должны выбрать тот вариант товара, из которого выводить имя, прайс, короткое описание.
-- Чтобы не усложнять запрос, я отдельными запросами получу фото товара, его рейтинг и кол-во отзывов
SELECT pv.product_id, pv.id AS product_variant_id, pv.name, pv.price, pv.price_offer, pv.short_desription, p.url
  FROM products_links AS pl
    JOIN catalogs AS c
      ON c.id = pl.catalog_id
    JOIN products AS p
      ON pl.product_id = p.id
    JOIN products_variants AS pv
      ON pv.product_id = p.id
  WHERE c.id = 18
  ORDER BY p.sort_id
;

-- Получаю фото товаров категории. Я добавил вложенным предущий запрос. По идее, там уже должен быть конкретный список id тех вариантов поставки,
-- которые выводим в каталог.
SELECT m.id, m.product_variant_id
  FROM mediafiles AS m
    JOIN mediafiles_types AS mt
      ON m.mediatype_id = mt.id
  WHERE mt.id = 1 
    AND m.product_variant_id IN 
      (SELECT pv.id AS product_variant_id
  FROM products_links AS pl
    JOIN catalogs AS c
      ON c.id = pl.catalog_id
    JOIN products AS p
      ON pl.product_id = p.id
    JOIN products_variants AS pv
      ON pv.product_id = p.id
  WHERE c.id = 18
  ORDER BY p.sort_id)
;

-- Получаю рейтинг товара, используя хранимую функцию и передавая значение id товара:
SELECT product_common_rate(1);

-- Получаю кол-во отзывов товаров категории 18 с группировкой по значению рейтинга, используя представление products_rates:
SELECT * 
  FROM products_rates AS pr
    JOIN products_links AS pl
    ON pr.product_id = pl.product_id
  WHERE pl.catalog_id = 18
;

-- Получаю общее кол-во отзывов на товар в определенном каталоге:
SELECT r.product_id, COUNT(*) AS reviews_count
  FROM reviews AS r
    JOIN products_links AS pl
      ON r.product_id = pl.product_id
  WHERE pl.catalog_id = 18
  GROUP BY r.product_id
;

-- Получаю характеристики всех вариантов товара для конкретного товара, используя представление:
SELECT product_variant_id,
  name,
  value
  FROM products_options_value 
  WHERE product_id = 1
;