-- ==========================================================
-- E-TICKETING HELPDESK
-- Database Export
-- PostgreSQL (Supabase)
-- Version : 2.0.0
-- ==========================================================

-- ==========================================
-- DROP TABLE (SAFE)
-- ==========================================

DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS histories CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- ==========================================
-- PROFILES
-- ==========================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL CHECK(role IN ('admin','helpdesk','user')),
    notification_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE profiles IS 'Data pengguna aplikasi';

-- ==========================================
-- TICKETS
-- ==========================================

CREATE TABLE tickets (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'OPEN'
        CHECK(status IN ('OPEN','IN_PROGRESS','CLOSE')),
    image_url TEXT,
    assigned_helpdesk TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE tickets IS 'Data tiket helpdesk';

-- ==========================================
-- COMMENTS
-- ==========================================

CREATE TABLE comments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    author TEXT NOT NULL,
    role TEXT NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_comments_ticket
    FOREIGN KEY(ticket_id)
    REFERENCES tickets(id)
    ON DELETE CASCADE
);

COMMENT ON TABLE comments IS 'Komentar pada tiket';

-- ==========================================
-- HISTORIES
-- ==========================================

CREATE TABLE histories (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    activity TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_histories_ticket
    FOREIGN KEY(ticket_id)
    REFERENCES tickets(id)
    ON DELETE CASCADE
);

COMMENT ON TABLE histories IS 'Riwayat aktivitas tiket';

-- ==========================================
-- INDEX
-- ==========================================

CREATE INDEX idx_ticket_status
ON tickets(status);

CREATE INDEX idx_ticket_created
ON tickets(created_at DESC);

CREATE INDEX idx_comment_ticket
ON comments(ticket_id);

CREATE INDEX idx_history_ticket
ON histories(ticket_id);

-- ==========================================
-- SAMPLE USERS
-- ==========================================

INSERT INTO profiles
(id,full_name,email,role,notification_enabled)
VALUES

(
gen_random_uuid(),
'Admin',
'admin@eticketing.com',
'admin',
TRUE
),

(
gen_random_uuid(),
'Helpdesk',
'helpdesk@eticketing.com',
'helpdesk',
TRUE
),

(
gen_random_uuid(),
'User',
'user@eticketing.com',
'user',
TRUE
);

-- ==========================================
-- SAMPLE TICKET
-- ==========================================

INSERT INTO tickets
(title,description,status,image_url,assigned_helpdesk)
VALUES

(
'Server Down',
'Server tidak dapat diakses',
'CLOSE',
NULL,
'Helpdesk 1'
),

(
'Printer Error',
'Printer tidak dapat mencetak',
'OPEN',
NULL,
NULL
),

(
'Email Tidak Masuk',
'Email client tidak diterima',
'IN_PROGRESS',
NULL,
'Helpdesk 1'
);

-- ==========================================
-- SAMPLE COMMENT
-- ==========================================

INSERT INTO comments
(ticket_id,author,role,message)
VALUES

(
1,
'User',
'user',
'Server tidak bisa diakses.'
),

(
1,
'Admin',
'admin',
'Tiket telah diterima.'
),

(
1,
'Helpdesk',
'helpdesk',
'Sedang dilakukan pengecekan.'
);

-- ==========================================
-- SAMPLE HISTORY
-- ==========================================

INSERT INTO histories
(ticket_id,activity)
VALUES

(
1,
'[Server Down] Tiket dibuat'
),

(
1,
'[Server Down] Admin melakukan assign Helpdesk'
),

(
1,
'[Server Down] Status berubah menjadi IN_PROGRESS'
),

(
1,
'[Server Down] Helpdesk menambahkan komentar'
),

(
1,
'[Server Down] Status berubah menjadi CLOSE'
);

-- ==========================================
-- VIEW
-- ==========================================

CREATE VIEW vw_ticket_summary AS

SELECT

t.id,
t.title,
t.status,
t.assigned_helpdesk,

COUNT(c.id) AS total_comments,

MAX(h.created_at) AS last_activity

FROM tickets t

LEFT JOIN comments c
ON c.ticket_id=t.id

LEFT JOIN histories h
ON h.ticket_id=t.id

GROUP BY

t.id,
t.title,
t.status,
t.assigned_helpdesk;

-- ==========================================
-- END OF DATABASE
-- ==========================================