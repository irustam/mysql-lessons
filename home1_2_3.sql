INSERT INTO sample.catalogs (id, name) SELECT id, name FROM shop.catalogs ON DUPLICATE KEY UPDATE sample.catalogs.name = shop.catalogs.name;
