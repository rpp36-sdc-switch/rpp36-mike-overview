/*
Execute this file from the command line by typing:
  psql postgres < db/schema.sql
*/

DROP DATABASE IF EXISTS overview;

CREATE DATABASE overview;

\c overview;

CREATE TABLE categories (
  category_id SERIAL,
  category VARCHAR(20),
  PRIMARY KEY (category_id)
);

CREATE TABLE products (
  product_id SERIAL,
  name VARCHAR(100) NOT NULL UNIQUE,
  slogan VARCHAR(255),
  description VARCHAR(255),
  default_price NUMERIC(10, 2),
  category_id INT,
  PRIMARY KEY (product_id),
  CONSTRAINT fk_category
    FOREIGN KEY (category_id)
      REFERENCES categories(category_id)
);

CREATE TABLE features (
  feature_id SERIAL,
  feature VARCHAR(50),
  value VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (feature_id),
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
  name VARCHAR(50) NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  original_price NUMERIC(10, 2),
  sale_price NUMERIC(10,2) DEFAULT NULL,
  product_id INT,
  PRIMARY KEY (style_id),
  CONSTRAINT fk_product
    FOREIGN KEY (product_id)
      REFERENCES products(product_id)
);

CREATE TABLE photos (
  photo_id SERIAL,
  url VARCHAR(255),
  thumbnail_url VARCHAR(255),
  style_id INT,
  PRIMARY KEY (photo_id),
  CONSTRAINT fk_style
    FOREIGN KEY (style_id)
      REFERENCES styles(style_id)
);

CREATE TABLE skus (
  sku_id SERIAL,
  size VARCHAR(10),
  style_id INT,
  PRIMARY KEY (sku_id),
  CONSTRAINT fk_style
    FOREIGN KEY (style_id)
      REFERENCES styles(style_id)
);

CREATE TABLE inventory (
  quantity INT DEFAULT 0,
  sku_id INT UNIQUE,
  CONSTRAINT fk_sku
    FOREIGN KEY (sku_id)
      REFERENCES skus(sku_id)
);

/*
After created, log list of relations and tables to a text file.

$ psql postgres
\c overview
\o overviewDB.txt
\dt
\d categories
\d products
\d features
\d product_features
\d styles
\d photos
\d skus
\d inventory
\q
*/
