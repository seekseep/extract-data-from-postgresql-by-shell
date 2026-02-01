COPY (
  SELECT
    c.name AS 会社名,
    d.name AS 部署名,
    pc.name AS 商品分類,
    o.ordered_at AS 日付,
    p.name AS 商品名,
    oi.quantity AS 数量,
    oi.unit_price AS 単価,
    oi.quantity * oi.unit_price AS 合計
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  JOIN products p ON oi.product_id = p.product_id
  JOIN product_categories pc ON p.product_category_id = pc.product_category_id
  JOIN departments d ON o.department_id = d.department_id
  JOIN companies c ON d.company_id = c.company_id
  JOIN regions r ON c.region_id = r.region_id
  WHERE r.name = :'region'
    AND o.ordered_at >= :'start_date'
    AND o.ordered_at <= :'end_date'
  ORDER BY
    c.name,
    d.name,
    pc.name,
    o.ordered_at,
    p.name
) TO STDOUT WITH CSV HEADER
