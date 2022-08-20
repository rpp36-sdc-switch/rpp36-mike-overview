/*
Execute this file from the command line by typing:
  psql postgres < db/schemaTemp.sql
*/

\c overview;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Load data into permanent tables
-- ////////////////////////////////////////////////////////////////////////////////////////////////

INSERT INTO categories (category)
  SELECT DISTINCT category FROM products_temp ORDER BY category ASC;

INSERT INTO products (product_id, name, slogan, description, category_id, default_price)
  SELECT products_temp.product_id, products_temp.name, products_temp.slogan, products_temp.description, categories.category_id, products_temp.default_price
  FROM products_temp, categories
  WHERE products_temp.category = categories.category;

INSERT INTO features (feature, value)
  SELECT DISTINCT feature, value FROM features_temp ORDER BY feature, value ASC;

INSERT INTO product_features (product_id, feature_id)
  SELECT DISTINCT features_temp.product_id, features.feature_id
  FROM features_temp, features
  WHERE features_temp.feature = features.feature AND features_temp.value = features.value;

INSERT INTO styles (style_id, product_id, name, default_style, original_price, sale_price)
  SELECT style_id, product_id, name, default_style, original_price, sale_price
  FROM styles_temp;

INSERT INTO photos (photo_id, style_id, url, thumbnail_url)
  SELECT photo_id, style_id, url, thumbnail_url
  FROM photos_temp;

INSERT INTO skus (sku_id, style_id, size, quantity)
  SELECT sku_id, style_id, size, quantity
  FROM skus_temp;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Remove temporary tables
-- ////////////////////////////////////////////////////////////////////////////////////////////////

DROP TABLE products_temp;
DROP TABLE features_temp;
DROP TABLE styles_temp;
DROP TABLE photos_temp;
DROP TABLE skus_temp;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Index tables
-- ////////////////////////////////////////////////////////////////////////////////////////////////

CREATE INDEX idx_products_name
  ON products(name);
CREATE INDEX idx_products_category_id
  ON products(category_id);
CREATE INDEX idx_styles_product_id
  ON styles(product_id);
CREATE INDEX idx_styles_name
  ON styles(name);
CREATE INDEX idx_photos_style_id
  ON photos(style_id);
CREATE INDEX idx_skus_style_id
  ON skus(style_id);