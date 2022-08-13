/*
Execute this file from the command line by typing:
  psql postgres < db/schemaTemp.sql
*/

\c overview;

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

/*
Record 48 of the photos.csv file was missing an ending quotation mark ("), so this file required some data cleansing. The process took about an hour, most of which was spent merging files back together.

1. Prior to loading, split source file into two files to be able to correct the issue. The first file was the first 100 rows, and the other was the remaining records.

  Save first (head) or last (tail) n lines of csv file into new csv file, from terminal.
  head --lines=10 data.csv >> saveToThisFile.csv  // or head -n 10 data.csv >> saveToThisFile.csv
  tail --lines=10 data.csv >> saveToThisFile.csv  // or tail -n 10 data.csv >> saveToThisFile.csv

  This would open the file saveToThisFile.csv and attach (>>, > would recreate/delete the file!) the first and the last 10 lines of data.csv at the "end" of saveToThisFile.csv.

  head -n 100 photos.csv >> photos_temp.csv
  tail -n 100 photos.csv >> photosLast100.csv // determined the source file has 5655719 records plus header row = 5655720 total rows

2. Added the missing quotation mark to the first file (still more errors somewhere else).

3. Merged the files back together. This process is what took time (30 - 45 minutes). Still had errors with data.

  tail -n 5655619 photos.csv >> photos_temp.csv

An alternative (quicker) process would be to split the source file into multiple files of 1,000,000 rows each. Splitting and then rejoining the files was very quick, a matter of seconds for each).

  split -l 1000000 photos.csv photos_ // 1st file has header, others don't

Regbuild to one file (optional) - Still had some errors in the first file. To correct, I opened that file in Excel, and resaved it as a csv file. Rather than merge files, loaded individuaaly into database.

  cat photos_a* > photos_temp.csv

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

/*
After created, load data from csv files.

$ psql postgres
\c overview

products.csv - expect COPY 1000011
COPY products_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/product.csv' DELIMITER ',' CSV HEADER;

features.csv - expect COPY 2219279
COPY features_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/features.csv' DELIMITER ',' CSV HEADER;

styles.csv - expect COPY 1958102
COPY styles_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/styles.csv' DELIMITER ',' NULL as 'null' CSV HEADER;

photos.csv - expect COPY 5655719 (initially, the data was not fully scrubbed, photos_aa needed more cleaning)
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos_temp.csv' DELIMITER ',' CSV HEADER;

Preferred:
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_aa_scrubbed.csv' DELIMITER ',' CSV HEADER;
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_ab' DELIMITER ',' CSV;
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_ac' DELIMITER ',' CSV;
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_ad' DELIMITER ',' CSV;
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_ae' DELIMITER ',' CSV;
COPY photos_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/photos/photos_af' DELIMITER ',' CSV;

skus.csv - expect COPY 11323917
COPY skus_temp FROM '/Users/mpmanzo/HackReactor/rpp36/SDC-Project/SDC-Application-Data/skus.csv' DELIMITER ',' CSV HEADER;

*/