-- Создание скалярной функции с описанием, содержащим заданную строку
CREATE OR REPLACE FUNCTION scalar_function_with_description()
RETURNS integer AS $$
BEGIN
    -- Описание с заданной строкой
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION scalar_function_with_description() IS 'Это функция с описанием, содержащим строку для поиска';

-- Создание хранимой процедуры с описанием, содержащим заданную строку
CREATE OR REPLACE PROCEDURE procedure_with_description()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Описание с заданной строкой
    RETURN;
END;
$$;

COMMENT ON PROCEDURE procedure_with_description() IS 'Это хранимая процедура с описанием, содержащим строку для поиска';

-- Создание скалярной функции без описания
CREATE OR REPLACE FUNCTION scalar_function_without_description()
RETURNS integer AS $$
BEGIN
    RETURN 2;
END;
$$ LANGUAGE plpgsql;

-- Создание хранимой процедуры без описания
CREATE OR REPLACE PROCEDURE procedure_without_description()
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN;
END;
$$;

CALL prcdr_find_substr_in_obj('insert', 'rewrite');

drop PROCEDURE procedure_with_description;
drop PROCEDURE procedure_without_description;
drop FUNCTION scalar_function_with_description;
drop FUNCTION scalar_function_without_description;