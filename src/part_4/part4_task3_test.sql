
-- Создание таблицы для журнала log_table
CREATE TABLE log_table (
    id serial PRIMARY KEY,
    event text
);

-- Создание таблицы для тестирования
CREATE TABLE test_table (
    id serial PRIMARY KEY,
    name text
);

-- Триггер для тестирования INSERT
CREATE OR REPLACE FUNCTION test_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Действия, выполняемые при вставке
    -- Например, можно записать данные в журнал
    INSERT INTO log_table (event) VALUES ('Row inserted');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER test_insert_trigger
AFTER INSERT ON test_table
FOR EACH ROW
EXECUTE FUNCTION test_insert_trigger();

-- Триггер для тестирования UPDATE
CREATE OR REPLACE FUNCTION test_update_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Действия, выполняемые при обновлении
    -- Например, можно записать данные в журнал
    INSERT INTO log_table (event) VALUES ('Row updated');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER test_update_trigger
AFTER UPDATE ON test_table
FOR EACH ROW
EXECUTE FUNCTION test_update_trigger();

-- Триггер для тестирования DELETE
CREATE OR REPLACE FUNCTION test_delete_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Действия, выполняемые при удалении
    -- Например, можно записать данные в журнал
    INSERT INTO log_table (event) VALUES ('Row deleted');
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER test_delete_trigger
AFTER DELETE ON test_table
FOR EACH ROW
EXECUTE FUNCTION test_delete_trigger();

INSERT INTO test_table (name) VALUES ('Test Record');

CALL prcdr_destroy_dml_triggers(0);

INSERT INTO test_table (name) VALUES ('Test Record');

DROP Table log_table;
DROP Table test_table;

DROP Function test_delete_trigger;
DROP Function test_insert_trigger;
DROP Function test_update_trigger;