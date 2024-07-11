-- Active: 1698736012220@@127.0.0.1@5433@mydatabase

-- table name: 
-- TableName; TableName1; TableName2; TableNameAnother; 
-- PlusTableOne; PlusAnotherOneTableName; PlusAnother;
create table if not exists TableName(
	id bigint primary key,
	TNColumnVarchar varchar
);

create table if not exists TableName1(
	id bigint primary key,
	TN1ColumnVarchar varchar
);

create table if not exists TableName2(
	id bigint primary key,
	TN2ColumnVarchar varchar
);

create table if not exists TableNameAnother(
	id int,
	TNAColumnVarchar varchar,
	TNAColumnDate date
);

create table if not exists PlusTableOne(
	id int,
	PTOColumnVarchar varchar,
	PTOColumnTime time
);

create table if not exists PlusAnotherOneTableName(
	id int,
	PTNOTNColumnVarchar varchar,
	PTNOTNColumnTime time,
	PTNOTNColumnDate date
);

create table if not exists PlusAnother(
	id bigint primary key,
	PAColumnVarchar varchar,
	PAColumnTime time,
	PAColumnDate date
);

CALL drop_tables_with_prefix();
DROP Table PlusAnother;
DROP Table PlusAnotherOneTableName;
DROP Table PlusTableOne;