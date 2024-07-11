DROP TABLE IF EXISTS Peers, Tasks, P2P, Verter, Checks, TransferredPoints, Friends, Recommendations, XP, TimeTracking CASCADE;

CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');

create type if not exists check_status as enum('Start', 'Success', 'Failure');
=======
create type check_status as enum('Start', 'Success', 'Failure'); 

create table if not exists Peers(
    Nickname char(8) PRIMARY KEY,
    Birthday date
);

create table if not exists Tasks(
    Title text PRIMARY KEY,
    ParentTask text,
    MaxXP int NOT NULL,
    constraint check_cnst check (Title != ParentTask),
    constraint fk_ParentTask foreign key (ParentTask) references Tasks(Title)
);

create table if not exists Checks(
    ID serial PRIMARY KEY,
    Peer char(8) NOT NULL,
    Task text NOT NULL,
    Date date NOT NULL,
    constraint fk_Peer foreign key (Peer) references Peers(Nickname),
    constraint fk_Task foreign key (Task) references Tasks(Title)
);

create table if not exists P2P(
    ID serial PRIMARY KEY,
    Check_id int,
    CheckingPeer char(8) not null,
    State check_status not null,
    Time time not null,
    constraint fk_Check_id foreign key (Check_id) references Checks(ID),
    constraint fk_CheckingPeer foreign key (CheckingPeer) references Peers(Nickname)
);


create table if not exists Verter(
    ID serial PRIMARY KEY,
    Check_id int not null,
    State check_status not null,
    time time not null,
    constraint fk_Check_id foreign key (Check_id) references Checks(ID)
);

create table if not exists TransferredPoints(
    ID serial PRIMARY KEY,
    CheckingPeer char(8) not null,
    CheckedPeer char(8) not null,
    PointsAmount int not null,
    constraint check_cnst check (CheckingPeer != CheckedPeer),
    constraint fk_CheckingPeer foreign key (CheckingPeer) references Peers(Nickname),
    constraint fk_CheckedPeer foreign key (CheckedPeer) references Peers(Nickname)
);

create table if not exists Friends(
    ID serial PRIMARY KEY,
    Peer1 char(8) not null,
    Peer2 char(8) not null,
    constraint check_cnst check (Peer1 != Peer2),
    constraint fk_Peer1 foreign key (Peer1) references Peers(Nickname),
    constraint fk_Peer2 foreign key (Peer2) references Peers(Nickname)
);

create table if not exists Recommendations(
    ID serial PRIMARY KEY,
    Peer char(8) not null,
    RecommendedPeer char(8),
    constraint check_cnst check (Peer != RecommendedPeer),
    constraint fk_Peer_id foreign key (Peer) references Peers(Nickname),
    constraint fk_RecommendedPeer foreign key (RecommendedPeer) references Peers(Nickname)
);

create table if not exists XP(
    ID serial PRIMARY KEY,
    Check_id int not null,
    XPAmount int not null,
    constraint fk_Check_id foreign key (Check_id) references Checks(ID)
);

create table if not exists TimeTracking(
    ID serial PRIMARY KEY,
    Peer char(8) not null,
    Date date not null,
    Time time not null,
    State int not null,
    constraint check_cnst check (State in (1, 2)),
    constraint fk_Peer foreign key (Peer) references Peers(Nickname)
);


create or replace procedure import_csv(tablename varchar(20), csv text, del char(1) ) as $$ begin
    execute format('copy %s FROM %L WITH DELIMITER %L CSV HEADER ;', tablename, csv, del);
end; $$ language plpgsql;


create or replace procedure export_csv(tablename varchar(20), csv text, del char(1) ) as $$ begin
    execute format('copy %s TO %L WITH DELIMITER %L CSV HEADER;', tablename, csv, del);
end; $$ language plpgsql;


-- This function and trigger check single null in table tasks
CREATE OR REPLACE FUNCTION single_null_in_tasks()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Parenttask is NULL THEN
        IF EXISTS (
            SELECT * FROM tasks
            WHERE parenttask IS NULL
        )
        THEN RAISE EXCEPTION 'The first task is already there';
        END IF;
    END IF;
    RETURN NEW;
END; $$ 
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER trg_tasks
BEFORE INSERT on tasks
FOR EACH ROW
EXECUTE FUNCTION single_null_in_tasks();

-- This function and trigger check the data that is entered in p2p
CREATE OR REPLACE FUNCTION exception_p2p()
RETURNS TRIGGER AS $$
DECLARE check_row text;
BEGIN
    SELECT state INTO check_row
    FROM p2p
    WHERE NEW.check_id = p2p.check_id
    ORDER BY id DESC
    LIMIT 1;

    IF NEW.state = 'Start' THEN
        IF check_row = 'Start'
        THEN RAISE EXCEPTION 'Check has already start status';
        END IF;
    END IF;
    IF NEW.state IN ('Success', 'Failure') THEN
        IF check_row != 'Start'
        THEN RAISE EXCEPTION 'The check has not started';
        END IF;
        IF check_row IN ('Success', 'Failure')
        THEN RAISE EXCEPTION 'The check is already finished';
        END IF;
        IF NEW.time <= (
            SELECT time FROM p2p
            WHERE NEW.check_id = p2p.check_id
            ORDER BY id DESC
            LIMIT 1
        )
        THEN RAISE EXCEPTION 'The check cannot be completed before the start';
        END IF;
    END IF;
    RETURN NEW;
END; $$ 
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER trg_p2p
BEFORE INSERT on p2p
FOR EACH ROW
EXECUTE FUNCTION exception_p2p();      

-- This function and trigger check the data that is entered in verter
CREATE OR REPLACE FUNCTION exception_verter()
RETURNS TRIGGER AS $$
DECLARE check_row text;
BEGIN
    SELECT state INTO check_row
    FROM verter
    WHERE New.check_id = verter.check_id
    ORDER BY id DESC
    LIMIT 1;

    IF (
        SELECT state FROM p2p
        WHERE New.check_id = p2p.check_id
        ORDER BY id DESC
        LIMIT 1
    ) != 'Success'
    THEN RAISE EXCEPTION 'p2p check failed or is missing';
    END IF;
    IF NEW.state = 'Start' THEN
        IF check_row = 'Start'
        THEN RAISE EXCEPTION 'Check has already start status';
        END IF;
    END IF;
    IF NEW.state IN ('Success', 'Failure') THEN
        IF check_row = 'Start'
        THEN RAISE EXCEPTION 'The check has not started';
        END IF;
        IF check_row IN ('Success', 'Failure')
        THEN RAISE EXCEPTION 'The check is already finished';
        END IF;
        IF NEW.time <= (
            SELECT time FROM verter
            WHERE NEW.check_id = verter.check_id
            LIMIT 1
        )
        THEN RAISE EXCEPTION 'The check cannot be completed before the start';
        END IF;
    END IF;
    RETURN NEW;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER trg_verter
BEFORE INSERT on verter
FOR EACH ROW
EXECUTE FUNCTION exception_verter();

-- This function and trigger ensure the transfer of points at the end of the check
CREATE OR REPLACE FUNCTION transfer_points()
RETURNS TRIGGER AS $$
DECLARE peer_value char(8);
BEGIN
  IF NEW.state IN ('Success', 'Failure') THEN
    BEGIN
      SELECT peer INTO peer_value FROM checks
      WHERE checks.id = NEW.check_id
      LIMIT 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'The corresponding node was not found';
        RETURN NEW;
    END;
	IF EXISTS (
		SELECT * FROM transferredpoints as tp
		WHERE NEW.checkingpeer = tp.checkingpeer AND peer_value = tp.checkedpeer
	) THEN 
    	UPDATE transferredpoints as tp
    	SET pointsamount = pointsamount + 1
    	WHERE NEW.checkingpeer = tp.checkingpeer AND peer_value = tp.checkedpeer;
	ELSE 
		INSERT INTO transferredpoints (checkingpeer, checkedpeer, pointsamount)
		VALUES(NEW.checkingpeer, peer_value, 1);
	END IF;
  END IF;
    RETURN NEW;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER trg_p2p_update_points
AFTER INSERT ON p2p
FOR EACH ROW
EXECUTE FUNCTION transfer_points();

-- This function and trigger are responsible for  mutual friendship
CREATE or REPLACE FUNCTION mutual_friendship()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT peer1, peer2 FROM friends
        WHERE (peer1 = NEW.peer1 AND peer2 = NEW.peer2) OR (peer1 = NEW.peer2 AND peer2 = NEW.peer1)
    )
    THEN
        RAISE EXCEPTION 'They are already friends!';
    END IF;

    RETURN NEW;
END; $$
LANGUAGE PLPGSQL;


CREATE or REPLACE TRIGGER trg_friends
AFTER INSERT on friends
FOR EACH ROW
EXECUTE FUNCTION mutual_friendship();

-- This function and trigger are responsible for timetracking
CREATE OR REPLACE FUNCTION timetracking()
RETURNS TRIGGER AS $$
	DECLARE last_state INT;
	DECLARE last_time TIME WITHOUT TIME ZONE;
	DECLARE last_date DATE;
BEGIN
	 WITH last_record AS(
	 	 SELECT state, time, date
		 FROM timetracking
		 WHERE peer = New.peer
		 ORDER BY date DESC, time DESC
		 LIMIT 1
	 ) SELECT state, time, date INTO last_state, last_time, last_date FROM last_record;
	 IF (NEW.state = last_state) THEN
	  	RAISE EXCEPTION 'New state cannot be the same as the previous one';
	 END IF;
     IF (NEW.date = last_date AND NEW.time <= last_time) OR (NEW.date < last_date) THEN
	  	RAISE EXCEPTION 'New time cannot be earlier than the last state';
	 END IF;
	 IF (NEW.state = '2' AND last_date != NEW.date) THEN
	  	INSERT INTO timetracking (peer, date, time, state)
	  	VALUES (NEW.peer, last_date, TIME '23:59:59', '2'),
			 (NEW.peer, NEW.date, TIME '00:00:01', '1');
	 END IF;
	 RETURN NEW;
END; $$ 
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER trg_timetracking
BEFORE INSERT ON timetracking
FOR EACH ROW
EXECUTE FUNCTION timetracking();

-- This function and trigger are responsible for access to tasks
CREATE OR REPLACE FUNCTION checking_access_task()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT parenttask FROM tasks WHERE new.task = tasks.title) IS NOT NULL THEN
        IF NOT EXISTS(
            SELECT title FROM tasks 
            JOIN checks ON checks.task = tasks.title
            WHERE NEW.peer = checks.peer AND (SELECT parenttask FROM tasks WHERE new.task = tasks.title) = checks.task
        ) 
        THEN RAISE EXCEPTION 'Peer does not have access to this task!';
        END IF;
    END IF;
    RETURN NEW;
END; $$ 
LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER trg_for_checks
BEFORE INSERT ON checks
FOR EACH ROW
EXECUTE FUNCTION checking_access_task();



