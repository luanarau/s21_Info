-- Active: 1692597007429@@127.0.0.1@5433@info

## Task1

CREATE OR REPLACE FUNCTION GET_TRANSFERRED_POINTS() 
RETURNS TABLE(PEER1 CHAR(8), PEER2 CHAR(8), POINTSAMOUNT 
INT) AS $$ 
	begin
    return query
	select
	    tp1.checkingpeer as Peer1,
	    tp1.checkedpeer as Peer2,
	    case
	        when tp1.pointsamount >= tp2.pointsamount then tp1.pointsamount
	        else tp1.pointsamount * -1
	    end as PointsAmount
	from
	    transferredpoints tp1
	    join transferredpoints tp2 on tp1.checkingpeer = tp2.checkedpeer
	    and tp1.checkedpeer = tp2.checkingpeer;
end; $$ language plpgsql;

SELECT * FROM get_transferred_points();

## Task2

CREATE OR REPLACE FUNCTION GET_XP_PER_TASK() RETURNS 
TABLE(PEER CHAR(8), TASK TEXT, XP INT) AS $$ 
	begin
    return query
	with successful_checks as (
        select check_id
        from Verter
        where State = 'Success'
    )
	select
	    peers.nickname as Peer,
	    checks.task as Task,
	    xp.xpamount as XP
	from xp
	    join checks on xp.check_id = checks.id
	    join peers on checks.peer = peers.nickname
	    join successful_checks on checks.id = successful_checks.check_id;
end; $$ language plpgsql;

SELECT * FROM get_xp_per_task();

## Task3

CREATE OR REPLACE FUNCTION NOT_LEFT_PEERS(VISIT_DATE 
DATE) RETURNS TABLE(PEER CHAR(8)) AS $$ 
	begin
    return query
	with peer_id_table as (
        select
            distinct timetracking.peer as Peer
        from timetracking
        where
            date = visit_date
            and state = 1
        except
        select
            distinct timetracking.peer as Peer
        from timetracking
        where
            date = visit_date
            and state = 2
    )
	select * from peer_id_table;
end; $$ language plpgsql;

select * from not_left_peers('2023-08-24');

## Task4

## В задании не написано что должна быть функция, поэтому должна быть процедура, а я сделал функцию. Не ебу как возвращать результат процедуры таблицей

CREATE OR REPLACE FUNCTION TRANSFERED_PEER_POINTS() 
RETURNS TABLE(PEER CHAR(8), POINTSCHANGE BIGINT) AS $$ 
	begin
    return query
	with temp_peers as (
        select
            tp1.checkingpeer as Peer1,
            tp1.checkedpeer as Peer2,
            tp1.pointsamount as pam
        from
            transferredpoints tp1
            join transferredpoints tp2 on tp1.checkingpeer = tp2.checkedpeer
            and tp1.checkedpeer = tp2.checkingpeer
    )
	select
	    tp1.Peer1 as Peer,
	    SUM(tp1.pam - tp2.pam) as PointsChange
	from temp_peers tp1
	    join temp_peers tp2 on tp1.Peer1 = tp2.Peer2 and tp1.Peer2 = tp2.Peer1
	group by Peer
	order by
	    PointsChange desc;
end; $$ language plpgsql;

select * from transfered_peer_points();

## Task5

## Результаты рознятся с прошлым таском потому что в первом есть какое то ебанутое условие, которое я не понимаю (зачем оно вообще там нужно) 

CREATE OR REPLACE FUNCTION TRANSFERED_PEER_POINTS_WITH_1_TASK()
RETURNS TABLE(PEER CHAR(8), POINTSCHANGE BIGINT) AS $$ 
	begin return query
	with task_1_function as (
	        select *
	        from
	            get_transferred_points()
	    )
	select
	    tp1.Peer1 as Peer,
	    SUM(
	        tp1.PointsAmount - tp2.PointsAmount
	    ) as PointsChange
	from task_1_function tp1
	    join task_1_function tp2 on tp1.Peer1 = tp2.Peer2 and tp1.Peer2 = tp2.Peer1
	group by Peer
	order by
	    PointsChange desc;
end; $$ language plpgsql;

select * from transfered_peer_points_with_1_task() 

## Task6

CREATE OR REPLACE FUNCTION MOST_CHECKING_TASKS()
RETURNS TABLE(DAY DATE, TASK TEXT) AS $$ 
	begin
    return query
	with temp_temp as (
	        with
	            temp_with_count as (
	                select
	                    checks.date,
	                    checks.task,
	                    count(checks.task) as cc
	                from checks
	                group by
	                    checks.date,
	                    checks.task
	            )
	        select
	            temp_with_count.date,
	            max(temp_with_count.cc) as max_count
	        from temp_with_count
	        group by
	            temp_with_count.date
	    )
	select
	    temp_temp.date,
	    t1.task
	from temp_temp
	    join (
	        select
	            checks.date,
	            checks.task,
	            count(checks.task) as cc
	        from checks
	        group by
	            checks.date,
	            checks.task
	    ) as t1 on temp_temp.date = t1.date
	    and temp_temp.max_count = t1.cc;
end; $$ language plpgsql;

select * from most_checking_tasks() 

## Task7

CREATE OR REPLACE FUNCTION GET_FULL_BRANCH_STUDENTS(BLOCK VARCHAR) 
RETURNS TABLE(PEER CHAR(8), DATE DATE) AS $$ 
	begin 
    return query
	with all_tasks as (
	        SELECT title
	        FROM Tasks
	        WHERE
	            title LIKE block || '%'
	        ORDER BY title DESC
	        limit 1
	    )
	SELECT
	    Checks.peer as Peer,
	    Checks.date as Day
	FROM Checks
	    JOIN P2P ON Checks.id = P2P.check_id
	    JOIN Verter ON Checks.id = Verter.check_id
	    left join all_tasks on all_tasks.title = Checks.task
	WHERE
	    Checks.task = all_tasks.title
	    AND P2P.state = 'Success'
	    AND Verter.state = 'Success';
end; $$ language plpgsql;

SELECT * FROM get_full_branch_students('C');


#Task8