-- Active: 1698736012220@@127.0.0.1@5433@mydatabase


--CREATE DATABASE mydatabase;
CREATE OR REPLACE PROCEDURE drop_tables_with_prefix()
LANGUAGE plpgsql
AS $$
DECLARE
    table_name text;
BEGIN
    FOR table_name IN
        SELECT tablename
        FROM pg_tables
        WHERE tablename LIKE 'tablename%'
    LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || table_name;
    END LOOP;
END;
$$;

--DROP PROCEDURE drop_tables_with_prefix;