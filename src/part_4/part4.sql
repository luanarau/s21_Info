-- Active: 1686309345605@@127.0.0.1@5432@postgres
create database procedure_testing;

connect procedure_testing;
include part1.sql;
include part2.sql;
include part3.sql;