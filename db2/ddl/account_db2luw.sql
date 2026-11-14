-- ============================================================
-- Script : account_db2luw.sql
-- Purpose: Create schema Z79583 and table ACCOUNT on
--          Db2 Community Edition (Db2 for Linux/Windows)
-- Author : Lorenzo David Diaz (with help from Claude)
-- Run    : in a Db2 Command Window (run as administrator):
--              db2 -tvf account_db2luw.sql
-- Needs  : database BANKDB already created
--              db2 CREATE DATABASE BANKDB
-- ============================================================

CONNECT TO BANKDB;

CREATE SCHEMA Z79583;

CREATE TABLE Z79583.ACCOUNT (
    ACCOUNT_NUMBER  DECIMAL(10,0)  NOT NULL,             -- PIC S9(10)    COMP-3  key
    NAME            CHAR(30)       NOT NULL,             -- PIC X(30)
    ACCOUNT_TYPE    CHAR(1)        NOT NULL,             -- PIC X(01)  S=savings, C=checking
    BALANCE         DECIMAL(11,2)  NOT NULL DEFAULT 0,   -- PIC S9(9)V99  COMP-3
    OPENING_DATE    DATE           NOT NULL,             -- PIC X(10)  'YYYY-MM-DD'
    STATUS          CHAR(1)        NOT NULL DEFAULT 'A', -- PIC X(01)  A/B/C
    CONSTRAINT PK_ACCOUNT       PRIMARY KEY (ACCOUNT_NUMBER),
    CONSTRAINT CK_ACCOUNT_TYPE  CHECK (ACCOUNT_TYPE IN ('S','C')),
    CONSTRAINT CK_STATUS        CHECK (STATUS IN ('A','B','C')),
    CONSTRAINT CK_BALANCE       CHECK (BALANCE >= 0)
);

COMMENT ON TABLE  Z79583.ACCOUNT              IS 'Bank accounts - Db2 practice table';
COMMENT ON COLUMN Z79583.ACCOUNT.ACCOUNT_TYPE IS 'S=savings, C=checking';
COMMENT ON COLUMN Z79583.ACCOUNT.STATUS       IS 'A/B/C - account status';

COMMIT;

-- Verify: show the columns Db2 stored
DESCRIBE TABLE Z79583.ACCOUNT;

CONNECT RESET;
