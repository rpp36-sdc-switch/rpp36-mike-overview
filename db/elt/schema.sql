/*
Execute this file from the command line by typing:
  psql postgres < db/schema.sql
*/

/*
DROP DATABASE IF EXISTS overview;

CREATE DATABASE overview;
*/

\c overview;

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
