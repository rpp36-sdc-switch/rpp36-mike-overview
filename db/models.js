const db = require('./postgres.js');

module.exports = {
  productInfo: {
    get: function(productId, cb) {
      let query =
        `SELECT products.product_id, products.name, products.slogan, products.description, categories.category, products.default_price, features.feature, features.value
         FROM products, categories, features, product_features
         WHERE products.product_id=${productId} AND products.category_id = categories.category_id AND products.product_id = product_features.product_id AND product_features.feature_id = features.feature_id;`;
      db.query(query, (err, results) => {
        if (err) {
          cb(err);
        } else {
          let data = {
            'id': results.rows[0].product_id,
            'name': results.rows[0].name,
            'slogan': results.rows[0].slogan,
            'description': results.rows[0].description,
            'category': results.rows[0].category,
            'default_price': results.rows[0].default_price,
            'features': []
          };

          for (var i = 0; i < results.rows.length; i++) {
            let feature = {
              'feature': results.rows[i].feature,
              'value': results.rows[i].value
            };
            data.features.push(feature);
          }
          cb(null, data);
        }
      });
    },
    post: function(productId, cb) {
      let query =
        `SELECT products.product_id, products.name, products.slogan, products.description, categories.category, products.default_price, features.feature, features.value
         FROM products, categories, features, product_features
         WHERE products.product_id=${productId} AND products.category_id = categories.category_id AND products.product_id = product_features.product_id AND product_features.feature_id = features.feature_id;`;
      db.query(query, (err, results) => {
        if (err) {
          cb(err);
        } else {
          let data = {
            'id': results.rows[0].product_id,
            'name': results.rows[0].name,
            'slogan': results.rows[0].slogan,
            'description': results.rows[0].description,
            'category': results.rows[0].category,
            'default_price': results.rows[0].default_price,
            'features': []
          };

          for (var i = 0; i < results.rows.length; i++) {
            let feature = {
              'feature': results.rows[i].feature,
              'value': results.rows[i].value
            };
            data.features.push(feature);
          }
          cb(null, data);
        }
      });
    }
  },
  productStyles: {
    get: function(productId, cb) {
      let query = `
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
        WHERE styles.product_id = ${productId}
        GROUP BY styles.product_id;`;

      db.query(query, (err, results) => {
        if (err) {
          cb(err);
        } else {
          let styles = results.rows[0].product_styles;
          let convertSkusArrayToObject = function(skusArr) {
            let skusObj = {};
            for (var i = 0; i < skusArr.length; i++) {
              for (const [key, value] of Object.entries(skusArr[i])) {
                skusObj[key] = value;
              }
            }
            return skusObj;
          };
          for (var i = 0; i < styles.results.length; i++) {
            let skusArr = styles.results[i].skus;
            let skusObj = convertSkusArrayToObject(skusArr);
            styles.results[i].skus = skusObj;
          }
          cb(null, styles);
        }
      });
    },
    post: function(productId, cb) {
      let query = `
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
        WHERE styles.product_id = ${productId}
        GROUP BY styles.product_id;`;

      db.query(query, (err, results) => {
        if (err) {
          cb(err);
        } else {
          let styles = results.rows[0].product_styles;
          let convertSkusArrayToObject = function(skusArr) {
            let skusObj = {};
            for (var i = 0; i < skusArr.length; i++) {
              for (const [key, value] of Object.entries(skusArr[i])) {
                skusObj[key] = value;
              }
            }
            return skusObj;
          };
          for (var i = 0; i < styles.results.length; i++) {
            let skusArr = styles.results[i].skus;
            let skusObj = convertSkusArrayToObject(skusArr);
            styles.results[i].skus = skusObj;
          }
          cb(null, styles);
        }
      });
    },
  },
};