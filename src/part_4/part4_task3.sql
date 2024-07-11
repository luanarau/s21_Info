CREATE OR REPLACE PROCEDURE prcdr_destroy_DML_triggers(num OUT INT) AS
$$
DECLARE
    trigger_info RECORD;
BEGIN
    num := 0;

    FOR trigger_info IN
        SELECT trigger_name, event_object_table
        FROM information_schema.triggers
        WHERE event_manipulation IN ('DELETE', 'UPDATE', 'INSERT')
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || trigger_info.trigger_name || ' ON ' || trigger_info.event_object_table || ' CASCADE';
        num := num + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
