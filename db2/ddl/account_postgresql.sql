-- ============================================================
-- Script : account_postgresql.sql
-- Purpose: Create schema Z79583 and table ACCOUNT (PostgreSQL)
-- Author : Lorenzo David Diaz (with help from Claude)
-- Run    : psql -d <your_database> -f account_postgresql.sql
-- ============================================================

CREATE SCHEMA IF NOT EXISTS z79583;

-- Lets you write "account" instead of "z79583.account"
SET search_path TO z79583, public;

DROP TABLE IF EXISTS z79583.account;   -- allows re-running the script

CREATE TABLE z79583.account (
    account_number  DECIMAL(10,0)  NOT NULL,              -- PIC S9(10)    COMP-3  key
    name            CHAR(30)       NOT NULL,              -- PIC X(30)
    account_type    CHAR(1)        NOT NULL,              -- PIC X(01)  S=savings, C=checking
    balance         DECIMAL(11,2)  NOT NULL DEFAULT 0,    -- PIC S9(9)V99  COMP-3
    opening_date    DATE           NOT NULL,              -- PIC X(10)  'YYYY-MM-DD'
    status          CHAR(1)        NOT NULL DEFAULT 'A',  -- PIC X(01)  A/B/C
    CONSTRAINT pk_account       PRIMARY KEY (account_number),
    CONSTRAINT ck_account_type  CHECK (account_type IN ('S','C')),
    CONSTRAINT ck_status        CHECK (status IN ('A','B','C')),
    CONSTRAINT ck_balance       CHECK (balance >= 0)
);

COMMENT ON TABLE  z79583.account              IS 'Bank accounts - Db2 practice table';
COMMENT ON COLUMN z79583.account.account_type IS 'S=savings, C=checking';
COMMENT ON COLUMN z79583.account.status       IS 'A/B/C - account status';

-- Verify: list the table definition
\d z79583.account
