create or replace procedure prcdr_find_substr_in_obj(
	sub in text,
	list out text
) as
$$
declare
	i record;
begin
	list := '';
	for i in
		select routine_name as name,
			'procedure' as object_type
		from information_schema.routines
		where routine_type = 'PROCEDURE'
			and routine_name ~ sub
		union all
		select proname as name,
			'function' as object_type
		from pg_catalog.pg_namespace n
				join pg_catalog.pg_proc p on p.pronamespace = n.oid
		where p.prokind = 'f' and n.nspname = 'public'
			and proname ~ sub
	loop
		list := (list || i.name || ' [type -> '
			|| i.object_type || ']' || E'\n');
	end loop;
end;
$$ language plpgsql;
