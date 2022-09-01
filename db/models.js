const db = require('./postgres.js');

module.exports = {
  productInfo: {
    get: function(productId, cb) {
      let query = `
      WITH
      featuresCTE AS (
        SELECT
          json_build_object('feature', features.feature, 'value', features.value) AS features
        FROM features
        LEFT JOIN product_features ON features.feature_id = product_features.feature_id
        WHERE product_features.product_id = ${productId}
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
      WHERE products.product_id = ${productId}
      GROUP BY products.product_id;`;
      db.query(query, (err, results) => {
        if (err) {
          cb(err);
        } else {
          if (results.rows.length === 0) {
            cb({status: 404, message: 'Product id does not exist'});
          } else {
            let data = results.rows[0].product_info;
            if (data.features === null) {
              data.features = [];
            }
            cb(null, data);
          }
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
          if (results.rows.length === 0) {
            cb(null, {'product_id': productId, results: []});
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
              let skusArr;
              if (styles.results[i].photos === null) {
                styles.results[i].photos = [ { 'thumbnail_url': null, url: null } ];
              }
              if (Array.isArray(styles.results[i].skus)) {
                skusArr = styles.results[i].skus;
              } else {
                skusArr = [ { null: { quantity: null, size: null } } ];
              }
              let skusObj = convertSkusArrayToObject(skusArr);
              styles.results[i].skus = skusObj;
            }
            cb(null, styles);
          }
        }
      });
    }
  },
  relatedProducts: {
    get: function(productId, cb) {
      let query = `
      SELECT json_agg(related_product_id) as data
      FROM related_products
      WHERE related_products.current_product_id = ${productId};`;
      db.query(query, (err, results) => {
        if (err) {
          cb(err);
        } else {
          if (results.rows[0].data === null) {
            cb(null, []);
          } else {
            cb(null, results.rows[0].data);
          }
        }
      });
    }
  },
};