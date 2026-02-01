COPY (
  SELECT
    o.order_id AS 注文ID,
    o.ordered_at AS 注文日,
    o.status AS ステータス,
    r.name AS 地域名,
    c.name AS 会社名,
    d.name AS 部署名,
    e.name AS 担当者名,
    COUNT(oi.order_item_id) AS 明細数,
    SUM(oi.quantity * oi.unit_price) AS 合計金額
  FROM orders o
  JOIN departments d ON o.department_id = d.department_id
  JOIN companies c ON d.company_id = c.company_id
  JOIN regions r ON c.region_id = r.region_id
  LEFT JOIN employees e ON o.assigned_employee_id = e.employee_id
  LEFT JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.ordered_at >= :'start_date'
    AND o.ordered_at <= :'end_date'
  GROUP BY o.order_id, o.ordered_at, o.status, r.name, c.name, d.name, e.name
  ORDER BY o.ordered_at, o.order_id
) TO STDOUT WITH CSV HEADER
