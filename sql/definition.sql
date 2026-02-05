-- =========================
-- Drop tables（テーブル削除）
-- =========================

DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS product_categories;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS regions;

-- =========================
-- Master tables
-- =========================

CREATE TABLE regions (
  region_id bigint GENERATED ALWAYS AS IDENTITY,
  name      text NOT NULL,
  CONSTRAINT pk_regions PRIMARY KEY (region_id),
  CONSTRAINT uq_regions_name UNIQUE (name)
);

CREATE TABLE companies (
  company_id   bigint GENERATED ALWAYS AS IDENTITY,
  region_id    bigint NOT NULL,
  name         text NOT NULL,

  postal_code  text NOT NULL,
  city         text NOT NULL,
  address_line text NOT NULL,

  CONSTRAINT pk_companies PRIMARY KEY (company_id),
  CONSTRAINT uq_companies_name UNIQUE (name),
  CONSTRAINT fk_companies_region_id
    FOREIGN KEY (region_id)
    REFERENCES regions (region_id)
);

CREATE TABLE departments (
  department_id bigint GENERATED ALWAYS AS IDENTITY,
  company_id    bigint NOT NULL,
  name          text NOT NULL,
  CONSTRAINT pk_departments PRIMARY KEY (department_id),
  CONSTRAINT uq_departments_company_id_name UNIQUE (company_id, name),
  CONSTRAINT uq_departments_department_id_company_id UNIQUE (department_id, company_id),
  CONSTRAINT fk_departments_company_id
    FOREIGN KEY (company_id)
    REFERENCES companies (company_id)
);

CREATE TABLE employees (
  employee_id   bigint GENERATED ALWAYS AS IDENTITY,
  department_id bigint NOT NULL,
  name          text NOT NULL,
  email         text,
  CONSTRAINT pk_employees PRIMARY KEY (employee_id),
  CONSTRAINT uq_employees_department_id_name UNIQUE (department_id, name),
  CONSTRAINT uq_employees_employee_id_department_id UNIQUE (employee_id, department_id),
  CONSTRAINT fk_employees_department_id
    FOREIGN KEY (department_id)
    REFERENCES departments (department_id)
);

CREATE TABLE product_categories (
  product_category_id bigint GENERATED ALWAYS AS IDENTITY,
  name                text NOT NULL,
  CONSTRAINT pk_product_categories PRIMARY KEY (product_category_id),
  CONSTRAINT uq_product_categories_name UNIQUE (name)
);

CREATE TABLE products (
  product_id          bigint GENERATED ALWAYS AS IDENTITY,
  product_category_id bigint NOT NULL,
  name                text NOT NULL,
  unit_price          numeric(12,2) NOT NULL DEFAULT 0,
  is_active           boolean NOT NULL DEFAULT true,
  CONSTRAINT pk_products PRIMARY KEY (product_id),
  CONSTRAINT uq_products_name UNIQUE (name),
  CONSTRAINT fk_products_product_category_id
    FOREIGN KEY (product_category_id)
    REFERENCES product_categories (product_category_id)
);

-- =========================
-- Transaction tables
-- =========================

CREATE TABLE orders (
  order_id      bigint GENERATED ALWAYS AS IDENTITY,
  department_id bigint NOT NULL,
  assigned_employee_id bigint,
  ordered_at    timestamptz NOT NULL DEFAULT now(),
  status        text NOT NULL DEFAULT 'draft',

  CONSTRAINT pk_orders PRIMARY KEY (order_id),

  CONSTRAINT fk_orders_department
    FOREIGN KEY (department_id)
    REFERENCES departments (department_id),

  CONSTRAINT fk_orders_assigned_employee_department
    FOREIGN KEY (assigned_employee_id, department_id)
    REFERENCES employees (employee_id, department_id)
);

CREATE TABLE order_items (
  order_item_id bigint GENERATED ALWAYS AS IDENTITY,
  order_id      bigint NOT NULL,
  line_no       integer NOT NULL,
  product_id    bigint NOT NULL,
  quantity      numeric(12,2) NOT NULL DEFAULT 0,
  unit_price    numeric(12,2) NOT NULL DEFAULT 0,

  CONSTRAINT pk_order_items PRIMARY KEY (order_item_id),
  CONSTRAINT uq_order_items_order_id_line_no UNIQUE (order_id, line_no),

  CONSTRAINT fk_order_items_order_id
    FOREIGN KEY (order_id)
    REFERENCES orders (order_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_order_items_product_id
    FOREIGN KEY (product_id)
    REFERENCES products (product_id)
);

-- =========================
-- Jobs table（ジョブテーブル）
-- =========================

CREATE TABLE jobs (
  id     bigint GENERATED ALWAYS AS IDENTITY,
  result bytea,
  status text NOT NULL DEFAULT 'pending',

  CONSTRAINT pk_jobs PRIMARY KEY (id),
  CONSTRAINT chk_jobs_status CHECK (status IN ('pending', 'running', 'completed', 'failed'))
);

-- =========================
-- Indexes
-- =========================

CREATE INDEX idx_companies_region_id ON companies (region_id);
CREATE INDEX idx_companies_postal_code ON companies (postal_code);
CREATE INDEX idx_departments_company_id ON departments (company_id);
CREATE INDEX idx_employees_department_id ON employees (department_id);
CREATE INDEX idx_orders_department_id ON orders (department_id);
CREATE INDEX idx_orders_assigned_employee_id ON orders (assigned_employee_id);
CREATE INDEX idx_order_items_order_id ON order_items (order_id);
CREATE INDEX idx_products_product_category_id ON products (product_category_id);

-- =========================
-- Comments（コメント）
-- =========================

-- regions（地域）
COMMENT ON TABLE regions IS '地域';
COMMENT ON COLUMN regions.region_id IS '地域ID';
COMMENT ON COLUMN regions.name IS '地域名';

-- companies（会社）
COMMENT ON TABLE companies IS '会社';
COMMENT ON COLUMN companies.company_id IS '会社ID';
COMMENT ON COLUMN companies.region_id IS '地域ID';
COMMENT ON COLUMN companies.name IS '会社名';
COMMENT ON COLUMN companies.postal_code IS '郵便番号';
COMMENT ON COLUMN companies.city IS '市区町村';
COMMENT ON COLUMN companies.address_line IS '住所';

-- departments（部署）
COMMENT ON TABLE departments IS '部署';
COMMENT ON COLUMN departments.department_id IS '部署ID';
COMMENT ON COLUMN departments.company_id IS '会社ID';
COMMENT ON COLUMN departments.name IS '部署名';

-- employees（従業員）
COMMENT ON TABLE employees IS '従業員';
COMMENT ON COLUMN employees.employee_id IS '従業員ID';
COMMENT ON COLUMN employees.department_id IS '部署ID';
COMMENT ON COLUMN employees.name IS '従業員名';
COMMENT ON COLUMN employees.email IS 'メールアドレス';

-- product_categories（商品カテゴリ）
COMMENT ON TABLE product_categories IS '商品カテゴリ';
COMMENT ON COLUMN product_categories.product_category_id IS '商品カテゴリID';
COMMENT ON COLUMN product_categories.name IS 'カテゴリ名';

-- products（商品）
COMMENT ON TABLE products IS '商品';
COMMENT ON COLUMN products.product_id IS '商品ID';
COMMENT ON COLUMN products.product_category_id IS '商品カテゴリID';
COMMENT ON COLUMN products.name IS '商品名';
COMMENT ON COLUMN products.unit_price IS '単価';
COMMENT ON COLUMN products.is_active IS '有効フラグ';

-- orders（注文）
COMMENT ON TABLE orders IS '注文';
COMMENT ON COLUMN orders.order_id IS '注文ID';
COMMENT ON COLUMN orders.department_id IS '部署ID';
COMMENT ON COLUMN orders.assigned_employee_id IS '担当従業員ID';
COMMENT ON COLUMN orders.ordered_at IS '注文日時';
COMMENT ON COLUMN orders.status IS 'ステータス';

-- order_items（注文明細）
COMMENT ON TABLE order_items IS '注文明細';
COMMENT ON COLUMN order_items.order_item_id IS '注文明細ID';
COMMENT ON COLUMN order_items.order_id IS '注文ID';
COMMENT ON COLUMN order_items.line_no IS '行番号';
COMMENT ON COLUMN order_items.product_id IS '商品ID';
COMMENT ON COLUMN order_items.quantity IS '数量';
COMMENT ON COLUMN order_items.unit_price IS '単価';

-- jobs（ジョブ）
COMMENT ON TABLE jobs IS 'ジョブ';
COMMENT ON COLUMN jobs.id IS 'ジョブID';
COMMENT ON COLUMN jobs.result IS '結果（バイナリ）';
COMMENT ON COLUMN jobs.status IS 'ステータス（pending/running/completed/failed）';
