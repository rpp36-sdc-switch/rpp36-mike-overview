/*
Execute this file from the command line by typing:
  psql postgres < db/productQueries.sql
*/

\c overview
\timing
\o ../logs/productQueries.txt


-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create productInfo.get function
-- ////////////////////////////////////////////////////////////////////////////////////////////////

CREATE OR REPLACE FUNCTION get_product_info(prodId INT)
RETURNS json AS
$$
WITH
featuresCTE AS (
  SELECT
    json_build_object('feature', features.feature, 'value', features.value) AS features
  FROM features
  LEFT JOIN product_features ON features.feature_id = product_features.feature_id
  WHERE product_features.product_id = prodId
  GROUP BY features.feature_id
)
SELECT
  json_build_object(
    'id', products.product_id,
    'name', products.name,
    'slogan', products.slogan,
    'description', products.description,
    'category', (select category from categories where products.category_id = categories.category_id),
    'default_price', products.default_price,
    'features', (select json_agg(features) from featuresCTE)
  ) AS product_info
FROM products
WHERE products.product_id = prodId
GROUP BY products.product_id;
$$ LANGUAGE sql;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create productStyles.get function
-- ////////////////////////////////////////////////////////////////////////////////////////////////

CREATE OR REPLACE FUNCTION get_product_styles(prodId INT)
RETURNS json AS
$$
WITH
photosCTE AS (
  SELECT
    photos.style_id,
    json_agg(json_build_object('thumbnail_url', photos.thumbnail_url, 'url', photos.url)) AS photos
  FROM photos
  LEFT JOIN styles ON photos.style_id = styles.style_id
  GROUP BY photos.style_id
),
skusCTE AS (
  SELECT
    skus.style_id, skus.sku_id, skus.quantity, skus.size
  FROM skus
  LEFT JOIN styles ON skus.style_id = styles.style_id
)
SELECT
  json_build_object(
    'product_id', styles.product_id,
    'results', json_agg(json_build_object(
      'style_id', styles.style_id,
      'name', styles.name,
      'original_price', styles.original_price,
      'sale_price', styles.sale_price,
      'default?', styles.default_style,
      'photos', (select photos from photosCTE where photosCTE.style_id = styles.style_id),
      'skus', (SELECT json_agg(json_build_object(
        skusCTE.sku_id, json_build_object(
          'quantity', skusCTE.quantity,
          'size', skusCTE.size
        )))
      FROM skusCTE
      WHERE skusCTE.style_id = styles.style_id
      )
    ))
  ) AS product_styles
FROM styles
WHERE styles.product_id = prodId
GROUP BY styles.product_id;
$$ LANGUAGE sql;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create relatedProducts.get function
-- ////////////////////////////////////////////////////////////////////////////////////////////////

CREATE OR REPLACE FUNCTION get_related_products(prodId INT)
RETURNS json AS
$$
SELECT json_agg(related_product_id) as data
FROM related_products
WHERE related_products.current_product_id = prodId
$$ LANGUAGE sql;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Drop custom indexes to test query baseline without indexing
-- ////////////////////////////////////////////////////////////////////////////////////////////////

DROP INDEX IF EXISTS idx_products_name;
DROP INDEX IF EXISTS idx_products_category_id;
DROP INDEX IF EXISTS idx_styles_product_id;
DROP INDEX IF EXISTS idx_styles_name;
DROP INDEX IF EXISTS idx_photos_style_id;
DROP INDEX IF EXISTS idx_skus_style_id;
DROP INDEX IF EXISTS idx_product_features_feature_id;
DROP INDEX IF EXISTS idx_product_features_product_id;
DROP INDEX IF EXISTS idx_related_products_current_product_id;

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Get baseline measurements of productInfo.get query
-- ////////////////////////////////////////////////////////////////////////////////////////////////

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900030);
SELECT get_product_info(900030);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900031);
SELECT get_product_info(900031);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900032);
SELECT get_product_info(900032);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create indexes that may effect performance of productInfo.get query and measure performance
-- ////////////////////////////////////////////////////////////////////////////////////////////////

-- idx_products_name
-- CREATE INDEX idx_products_name
--   ON products(name);

-- \di idx_products_name

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900033);
-- SELECT get_product_info(900033);

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900034);
-- SELECT get_product_info(900034);

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900035);
-- SELECT get_product_info(900035);

-- DROP INDEX IF EXISTS idx_products_name;

-- idx_products_category_id
CREATE INDEX idx_products_category_id
  ON products(category_id);

\di idx_products_category_id

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900036);
SELECT get_product_info(900036);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900037);
SELECT get_product_info(900037);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900038);
SELECT get_product_info(900038);

DROP INDEX IF EXISTS idx_products_category_id;

-- idx_product_features_feature_id
-- CREATE INDEX idx_product_features_feature_id
--   ON product_features(feature_id);

-- \di idx_product_features_feature_id

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900039);
-- SELECT get_product_info(900039);

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900040);
-- SELECT get_product_info(900040);

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900041);
-- SELECT get_product_info(900041);

-- DROP INDEX IF EXISTS idx_product_features_feature_id;

-- idx_products_category_id
-- CREATE INDEX idx_product_features_product_id
--   ON product_features(product_id);

-- \di idx_product_features_product_id

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900042);
-- SELECT get_product_info(900042);

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900043);
-- SELECT get_product_info(900043);

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900044);
-- SELECT get_product_info(900044);

-- DROP INDEX IF EXISTS idx_product_features_product_id;

-- idx_products_name, idx_products_category_id, idx_product_features_feature_id, idx_product_features_product_id
-- CREATE INDEX idx_products_name
--   ON products(name);
CREATE INDEX idx_products_category_id
  ON products(category_id);
-- CREATE INDEX idx_product_features_feature_id
--   ON product_features(feature_id);
-- CREATE INDEX idx_product_features_product_id
--   ON product_features(product_id);

\di idx_product*

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900045);
SELECT get_product_info(900045);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900046);
SELECT get_product_info(900046);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_info(900047);
SELECT get_product_info(900047);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Get baseline measurements of productStyles.get query
-- ////////////////////////////////////////////////////////////////////////////////////////////////

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900030);
SELECT get_product_styles(900030);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900031);
SELECT get_product_styles(900031);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900032);
SELECT get_product_styles(900032);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create indexes that may effect performance of productStyles.get query and measure performance
-- ////////////////////////////////////////////////////////////////////////////////////////////////

-- idx_styles_product_id
CREATE INDEX idx_styles_product_id
  ON styles(product_id);

\di idx_styles_product_id

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900033);
SELECT get_product_styles(900033);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900034);
SELECT get_product_styles(900034);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900035);
SELECT get_product_styles(900035);

DROP INDEX IF EXISTS idx_styles_product_id;

-- idx_styles_name
-- CREATE INDEX idx_styles_name
--   ON styles(name);

-- \di idx_styles_name

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900036);
-- SELECT get_product_styles(900036);

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900037);
-- SELECT get_product_styles(900037);

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900038);
-- SELECT get_product_styles(900038);

-- DROP INDEX IF EXISTS idx_styles_name;

-- idx_photos_style_id
CREATE INDEX idx_photos_style_id
  ON photos(style_id);

\di idx_photos_style_id

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900039);
SELECT get_product_styles(900039);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900040);
SELECT get_product_styles(900040);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900041);
SELECT get_product_styles(900041);

DROP INDEX IF EXISTS idx_photos_style_id;

-- idx_skus_style_id
CREATE INDEX idx_skus_style_id
  ON skus(style_id);

\di idx_skus_style_id

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900042);
SELECT get_product_styles(900042);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900043);
SELECT get_product_styles(900043);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900044);
SELECT get_product_styles(900044);

DROP INDEX IF EXISTS idx_skus_style_id;

-- idx_styles_product_id, idx_styles_name, idx_photos_style_id and idx_skus_style_id
CREATE INDEX idx_styles_product_id
  ON styles(product_id);
-- CREATE INDEX idx_styles_name
--   ON styles(name);
CREATE INDEX idx_photos_style_id
  ON photos(style_id);
CREATE INDEX idx_skus_style_id
  ON skus(style_id);

\di idx_*style*

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900045);
SELECT get_product_styles(900045);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900046);
SELECT get_product_styles(900046);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_product_styles(900047);
SELECT get_product_styles(900047);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Get baseline measurements of relatedProducts.get query
-- ////////////////////////////////////////////////////////////////////////////////////////////////

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_related_products(900030);
SELECT get_related_products(900030);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_related_products(900031);
SELECT get_related_products(900031);

EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_related_products(900032);
SELECT get_related_products(900032);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Create indexes that may effect performance of relatedProducts.get query and measure performance
-- ////////////////////////////////////////////////////////////////////////////////////////////////

-- idx_related_products_current_product_id
-- CREATE INDEX idx_related_products_current_product_id
--   ON related_products(current_product_id);

-- \di idx_related_products_current_product_id

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_related_products(900033);
-- SELECT get_related_products(900033);

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_related_products(900034);
-- SELECT get_related_products(900034);

-- EXPLAIN (ANALYZE, VERBOSE TRUE) SELECT get_related_products(900035);
-- SELECT get_related_products(900035);

\q