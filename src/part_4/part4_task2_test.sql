-- Active: 1698736012220@@127.0.0.1@5433@mydatabase

-- func signature:
-- fnc_without_params() ; fnc_without_params1() ;
-- fnc_with_params_sum(number1 int,number2 int) ;
-- fnc_with_params_sub(number1 int,number2 int) ;
-- fwp_sum(number1 int,number2 int, number3 int); 
create or replace function fnc_without_params() returns bigint as
$$
begin
	return 0;
end;
$$ language plpgsql;

create or replace function fnc_without_params1() returns bigint as
$$
begin
	return "hello world";
end;
$$ language plpgsql;

create or replace function fnc_with_params_sum(
	number1 int,
	number2 int
) returns bigint as
$$
begin
	return (number1 + number2);
end;
$$ language plpgsql;

create or replace function fnc_with_params_sub(
	number1 int,
	number2 int
) returns bigint as
$$
begin
	return (number1 - number2);
end;
$$ language plpgsql;

create or replace function fwp_sum(
	number1 int,
	number2 int,
	number3 int
) returns bigint as
$$
begin
	return (number1 + number2 + number3);
end;
$$ language plpgsql;

call prcdr_funcs_with_arguments('', 0);

DROP function IF EXISTS fwp_sum;
DROP function IF EXISTS fnc_with_params_sub;
DROP function IF EXISTS fnc_with_params_sum;
DROP function IF EXISTS fnc_without_params1;
DROP function IF EXISTS fnc_without_params;
