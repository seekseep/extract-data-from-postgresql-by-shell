-- =========================
-- Drop procedure（プロシージャ削除）
-- =========================

DROP FUNCTION IF EXISTS insert_order_summary_job(date, date);

-- ==========================================================
-- ストアドプロシージャ: insert_order_summary_job
--
-- 注文テーブルを関連テーブルとジョインし、
-- 集計結果をCSV形式で jobs テーブルに挿入する
--
-- 引数:
--   p_start_date: 開始日
--   p_end_date:   終了日
--
-- 戻り値: 作成されたジョブのID
-- ==========================================================

CREATE OR REPLACE FUNCTION insert_order_summary_job(
  p_start_date date,
  p_end_date   date
)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
  v_job_id   bigint;
  v_result   text;
  v_row      record;
  v_header   text;
BEGIN
  -- ジョブを作成（running状態）
  INSERT INTO jobs (status)
  VALUES ('running')
  RETURNING id INTO v_job_id;

  BEGIN
    -- CSVヘッダー
    v_header := '注文ID,注文日,ステータス,地域名,会社名,部署名,担当者名,明細数,合計金額';
    v_result := v_header;

    -- 注文テーブルをジョインして集計
    FOR v_row IN
      SELECT
        o.order_id,
        TO_CHAR(o.ordered_at, 'YYYY-MM-DD') AS ordered_date,
        o.status,
        r.name AS region_name,
        c.name AS company_name,
        d.name AS department_name,
        COALESCE(e.name, '') AS employee_name,
        COUNT(oi.order_item_id) AS item_count,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_amount
      FROM orders o
      JOIN departments d ON o.department_id = d.department_id
      JOIN companies c ON d.company_id = c.company_id
      JOIN regions r ON c.region_id = r.region_id
      LEFT JOIN employees e ON o.assigned_employee_id = e.employee_id
      LEFT JOIN order_items oi ON o.order_id = oi.order_id
      WHERE o.ordered_at >= p_start_date
        AND o.ordered_at <  p_end_date + INTERVAL '1 day'
      GROUP BY o.order_id, o.ordered_at, o.status,
               r.name, c.name, d.name, e.name
      ORDER BY o.ordered_at, o.order_id
    LOOP
      v_result := v_result || E'\n'
        || v_row.order_id || ','
        || v_row.ordered_date || ','
        || v_row.status || ','
        || v_row.region_name || ','
        || v_row.company_name || ','
        || v_row.department_name || ','
        || v_row.employee_name || ','
        || v_row.item_count || ','
        || v_row.total_amount;
    END LOOP;

    -- 結果をジョブに保存（completed状態、UTF-8バイナリに変換）
    UPDATE jobs
    SET result = E'\\xEFBBBF'::bytea || convert_to(v_result, 'UTF8'),
        status = 'completed'
    WHERE id = v_job_id;

  EXCEPTION WHEN OTHERS THEN
    -- エラー時はfailed状態に更新
    UPDATE jobs
    SET result = convert_to(SQLERRM, 'UTF8'),
        status = 'failed'
    WHERE id = v_job_id;
  END;

  RETURN v_job_id;
END;
$$;

COMMENT ON FUNCTION insert_order_summary_job(date, date) IS '注文サマリーをジョブに挿入するストアドプロシージャ';
