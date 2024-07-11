
-- Task 1
create or replace procedure add_p2p(checking_peer char(8), checked_peer char(8), task_text text, check_status check_status, time_ time) as $$
BEGIN
    if check_status = 'Start' then 
        insert into checks(peer, task, date) values(checked_peer, task_text, CURRENT_DATE);
    end if;
    insert into p2p(check_id, checkingpeer, state, "time") values(
        (select id from checks where peer = checked_peer and date = CURRENT_DATE and checks.task = task_text limit 1), 
        checking_peer,
        check_status,
        time_);
end; $$ language plpgsql;

call add_p2p('luanarau', 'shaunnaa', 'Math', 'Start', '12:00:00');
call add_p2p('luanarau', 'shaunnaa', 'Math', 'Failure', '12:15:00');
call add_p2p('luanarau', 'shaunnaa', 'Math', 'Success', '12:15:00');


--Task 2
create or replace procedure add_verter(checked_peer char(8), task_text text, check_status check_status, time_ time) as $$
DECLARE check_status text;
begin 
    select state INTO check_status
    from p2p 
    join checks on p2p.check_id = checks.id 
    where checks.task = task_text and checks.peer = checked_peer 
    order by checks.id desc 
    limit 1;

    if check_status = 'Success' 
    then 
        insert into verter(check_id, state, time) values((select checks.id from p2p join checks on p2p.check_id = checks.id 
                                                            where p2p.state = 'Success' and checks.task = task_text), check_status, time_);
    else
        raise exception 'got some error';
    end if;
end; $$ language plpgsql;

select state
from p2p 
join checks on p2p.check_id = checks.id 
where checks.task = 'Math' and checks.peer = 'shaunnaa' 
order by checks.id desc 
limit 1;

call add_verter('shaunnaa', 'Math', 'Start', '18:00:00');

call add_verter('shaunnaa', 'Math', 'False', '18:00:00')

call add_verter('shaunnaa', 'Math', 'Success', '18:00:00')

-- exception test
call add_verter('sanddony', 'Linux', 'Success', '18:00:00')


-- Task 3
create or replace function update_trpnt() returns trigger as $$
begin 
    update transferredpoints set pointsamount = pointsamount + 1
    where checkingpeer = new.checkingpeer and checkedpeer = (select distinct peer from checks where checks.id = new.check_id);
    return new;
end; $$ language plpgsql;


create trigger change_transfered_points
    after insert on p2p
    for each row
    when (new.state = 'Start')
    execute function update_trpnt();


-- drop trigger change_transfered_points on p2p;


call add_p2p('luanarau', 'sanddony', 'Decimal', 'Success', '12:00:00');

call add_p2p('luanarau', 'katherng', 'Linux', 'Start', '10:00:00');


--Task 4
create or replace function checkXP() returns trigger as $$
begin
    if new.xpamount > (select maxxp from tasks join checks on tasks.title = checks.task where checks.id = new.check_id) THEN
        raise exception 'raise limit XP!';
    elseif (select distinct state from p2p join checks on p2p.check_id = checks.id where p2p.check_id = new.check_id) != 'Success' THEN
        raise exception 'raise not success!';
    end if;
    return new;
end; $$ language plpgsql;




create trigger checkXP
    before insert on XP
    for each row
    execute function checkXP();



insert into XP(check_id, xpamount) values(1, 100);

--exception test
insert into XP(check_id, xpamount) values(5, 1000);
