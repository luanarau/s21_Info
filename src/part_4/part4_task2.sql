CREATE OR REPLACE PROCEDURE prcdr_funcs_with_arguments(funcs OUT TEXT, numb OUT INT) AS $$
DECLARE
    func_name TEXT;
BEGIN
    funcs := '';
    numb := 0;

    FOR func_name IN
        SELECT p.proname || ' (' || pg_get_function_arguments(p.oid) || ')' AS functions_list
        FROM pg_catalog.pg_namespace n
        JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid
        WHERE p.prokind = 'f'
          AND n.nspname = 'public'
          AND pg_get_function_arguments(p.oid) <> ''
    LOOP
        funcs := funcs || func_name || E'\n';
        numb := numb + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- create or replace procedure prcdr_funcs_with_arguments(
-- 	funcs out text,
-- 	numb out int
-- ) as
-- $$
-- declare
-- 	line record;
-- begin
-- 	funcs := '';
-- 	numb := 0;
-- 	for line in
-- 		select (
-- 				p.proname || ' (' || pg_get_function_arguments(p.oid) || ')'
-- 			) as functions_list
-- 		from pg_catalog.pg_namespace n
-- 			join pg_catalog.pg_proc p on p.pronamespace = n.oid
-- 		where p.prokind = 'f'
-- 			and n.nspname = 'public'
-- 			and (pg_get_function_arguments(p.oid) = '') is not true
-- 	loop
-- 		funcs := (funcs || line.functions_list || E'\n');
-- 		numb := numb + 1;
-- 	end loop;
-- end;
-- $$ language plpgsql;
