/*
Execute this file from the command line by typing:
  psql postgres < db/elt/ELTScript.sql
*/

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create overview database and connect to it
-- ////////////////////////////////////////////////////////////////////////////////////////////////

DROP DATABASE IF EXISTS overview;

CREATE DATABASE overview;

\c overview
\timing

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create temporary tables
-- ////////////////////////////////////////////////////////////////////////////////////////////////

CREATE TABLE products_temp (
  product_id SERIAL,
  name VARCHAR(50),
  slogan VARCHAR(255),
  description VARCHAR(1000),
  category VARCHAR(20),
  default_price NUMERIC(10, 2),
  PRIMARY KEY (product_id)
);

CREATE TABLE features_temp (
  feature_id SERIAL,
  product_id INT,
  feature VARCHAR(50),
  value VARCHAR(50),
  PRIMARY KEY (feature_id)
);

CREATE TABLE styles_temp (
  style_id SERIAL,
  product_id INT,
  name VARCHAR(50),
  sale_price NUMERIC(11,2) DEFAULT NULL,
  original_price NUMERIC(11, 2),
  default_style INT,
  PRIMARY KEY (style_id)
);

CREATE TABLE photos_temp (
  photo_id SERIAL,
  style_id INT,
  url text,
  thumbnail_url text,
  PRIMARY KEY (photo_id)
);

CREATE TABLE skus_temp (
  sku_id SERIAL,
  style_id INT,
  size VARCHAR(10),
  quantity INT,
  PRIMARY KEY (sku_id)
);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Load source data into temporary tables
-- ////////////////////////////////////////////////////////////////////////////////////////////////

COPY products_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/product.csv' DELIMITER ',' NULL as 'null' CSV HEADER;

COPY features_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/features.csv' DELIMITER ',' NULL as 'null' CSV HEADER;

COPY styles_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/styles.csv' DELIMITER ',' NULL as 'null' CSV HEADER;

COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_aa_scrubbed.csv' DELIMITER ',' CSV HEADER;
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_ab' DELIMITER ',' NULL as 'null' CSV;
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_ac' DELIMITER ',' NULL as 'null' CSV;
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_ad' DELIMITER ',' NULL as 'null' CSV;
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_ae' DELIMITER ',' NULL as 'null' CSV;
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_af' DELIMITER ',' NULL as 'null' CSV;

COPY skus_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/skus.csv' DELIMITER ',' NULL as 'null' CSV HEADER;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Alter temporary tables if necessary
-- ////////////////////////////////////////////////////////////////////////////////////////////////

ALTER TABLE styles_temp ALTER COLUMN default_style DROP DEFAULT;
ALTER TABLE styles_temp ALTER default_style TYPE BOOLEAN USING CASE WHEN default_style=1 THEN TRUE ELSE FALSE END;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create permanent tables
-- ////////////////////////////////////////////////////////////////////////////////////////////////

CREATE TABLE categories (
  category_id SERIAL,
  category TEXT,

  PRIMARY KEY (category_id),
  CONSTRAINT chk_category
    CHECK (char_length(category) <= 20)
);

CREATE TABLE products (
  product_id SERIAL,
  name TEXT NOT NULL,
  slogan TEXT,
  description TEXT,
  category_id INT,
  default_price NUMERIC(11, 2),

  PRIMARY KEY (product_id),
  CONSTRAINT chk_name
    CHECK (char_length(name) <= 30),
  CONSTRAINT chk_slogan
    CHECK (char_length(slogan) <= 120),
  CONSTRAINT chk_description
    CHECK (char_length(description) <= 500),
  CONSTRAINT fk_category
    FOREIGN KEY (category_id)
      REFERENCES categories(category_id)
);

CREATE TABLE features (
  feature_id SERIAL,
  feature TEXT,
  value TEXT DEFAULT NULL,

  PRIMARY KEY (feature_id),
  CONSTRAINT chk_feature
    CHECK (char_length(feature) <= 30),
  CONSTRAINT chk_value
    CHECK (char_length(value) <= 30),
  UNIQUE (feature, value)
);

CREATE TABLE product_features (
  product_id INT NOT NULL,
  feature_id INT NOT NULL,

  CONSTRAINT fk_product
    FOREIGN KEY (product_id)
      REFERENCES products(product_id),
  CONSTRAINT fk_feature
    FOREIGN KEY (feature_id)
      REFERENCES features(feature_id),
  UNIQUE (product_id, feature_id)
);

CREATE TABLE styles (
  style_id SERIAL,
  product_id INT,
  name TEXT NOT NULL,
  default_style BOOLEAN NOT NULL DEFAULT FALSE,
  original_price NUMERIC(11, 2),
  sale_price NUMERIC(11,2) DEFAULT NULL,

  PRIMARY KEY (style_id),
  CONSTRAINT chk_name
    CHECK (char_length(name) <= 30),
  CONSTRAINT fk_product
    FOREIGN KEY (product_id)
      REFERENCES products(product_id)
);

CREATE TABLE photos (
  photo_id SERIAL,
  style_id INT,
  url TEXT,
  thumbnail_url TEXT,

  PRIMARY KEY (photo_id),
  CONSTRAINT chk_url
    CHECK (char_length(url) <= 180),
  CONSTRAINT chk_thumbnail_url
    CHECK (char_length(thumbnail_url) <= 180),
  CONSTRAINT fk_style
    FOREIGN KEY (style_id)
      REFERENCES styles(style_id)
);

CREATE TABLE skus (
  sku_id SERIAL,
  style_id INT,
  size TEXT,
  quantity INT,

  PRIMARY KEY (sku_id),
  CONSTRAINT chk_size
    CHECK (char_length(size) <= 10),
  CONSTRAINT fk_style
    FOREIGN KEY (style_id)
      REFERENCES styles(style_id)
);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Load data from temporary tables into permanent tables
-- ////////////////////////////////////////////////////////////////////////////////////////////////

-- Expect 28 records in categories table
INSERT INTO categories (category)
  SELECT DISTINCT category FROM products_temp ORDER BY category ASC;

-- Expect 1,000,011 records in products table
INSERT INTO products (product_id, name, slogan, description, category_id, default_price)
  SELECT products_temp.product_id, products_temp.name, products_temp.slogan, products_temp.description, categories.category_id, products_temp.default_price
  FROM products_temp, categories
  WHERE products_temp.category = categories.category;

-- Expect 46 records in features table
INSERT INTO features (feature, value)
  SELECT DISTINCT feature, value FROM features_temp ORDER BY feature, value ASC;

-- Expect 2,132,016 records in product_features table (2,219,279 records in source data includes 87,263 duplicates)
INSERT INTO product_features (product_id, feature_id)
  SELECT DISTINCT features_temp.product_id, features.feature_id
  FROM features_temp, features
  WHERE features_temp.feature = features.feature AND (features_temp.value = features.value OR features.value IS NULL);

-- Expect 1,958,102 records in styles table
INSERT INTO styles (style_id, product_id, name, default_style, original_price, sale_price)
  SELECT style_id, product_id, name, default_style, original_price, sale_price
  FROM styles_temp;

-- Expect 5,655,656 records in photos table
INSERT INTO photos (photo_id, style_id, url, thumbnail_url)
  SELECT photo_id, style_id, url, thumbnail_url
  FROM photos_temp;

-- Expect 11,323,917 records in skus table (should sku_id 5 and 6 be combined or is sku_id 6 really XXL?)
INSERT INTO skus (sku_id, style_id, size, quantity)
  SELECT sku_id, style_id, size, quantity
  FROM skus_temp;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Remove temporaty tables
-- ////////////////////////////////////////////////////////////////////////////////////////////////

DROP TABLE products_temp;
DROP TABLE features_temp;
DROP TABLE styles_temp;
DROP TABLE photos_temp;
DROP TABLE skus_temp;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create indexes that may have measurable effect on database performance
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

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create file demonstrating results of the ELT process
-- ////////////////////////////////////////////////////////////////////////////////////////////////

\o overviewDB.txt
\dt
\d categories
\d products
\d features
\d product_features
\d styles
\d photos
\d skus

select count(*) from categories;
select count(*) from products;
select count(*) from features;
select count(*) from product_features;
select count(*) from styles;
select count(*) from photos;
select count(*) from skus;

\q