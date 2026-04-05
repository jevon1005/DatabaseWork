-- 不新增表：仅扩展列以匹配现有桌面程序（用户资料、长文本座席/时刻表、订单快照）

ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name VARCHAR(100) DEFAULT '';
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20) DEFAULT '';
ALTER TABLE users ADD COLUMN IF NOT EXISTS id_card VARCHAR(18) DEFAULT '';

-- 原 seat_config VARCHAR(500) 不足以存放时刻表+车厢 JSON
ALTER TABLE trains ALTER COLUMN seat_config TYPE TEXT;

ALTER TABLE orders ADD COLUMN IF NOT EXISTS timetable_snapshot TEXT;
