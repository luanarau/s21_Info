
insert into Peers values
    ('luanarau', '2002-01-04'),
    ('sanddony', '2002-06-21'),
    ('shaunnaa', '2001-12-01'),
    ('pipebomb', '2002-10-11'),
    ('katherng', '2003-10-18');

insert into timetracking(peer, date, time, state) values
    ('luanarau', '2023-08-24', '15:25:00', 1),
    ('luanarau', '2023-08-24', '16:01:00', 2),
    ('luanarau', '2023-08-24', '20:20:00', 1),
    ('luanarau', '2023-08-24', '20:29:00', 2),
    ('pipebomb', '2023-08-24', '10:00:00', 1),
    ('pipebomb', '2023-08-24', '12:31:00', 2);

insert into Tasks values
    ('C2', NULL, 350),
    ('C3', 'C2', 400),
    ('C4', 'C2', 250),
    ('C5', 'C2', 400),
    ('D', 'C3', 200);

insert into Checks(peer, task, "date") values
    ('luanarau', 'C2', '2023-05-10'),
    ('sanddony', 'C2', '2023-05-10'),
    ('katherng', 'C2', '2023-05-10'),
    ('luanarau', 'C5', '2023-05-10'),
    ('sanddony', 'C3', '2023-05-10'),
    ('katherng', 'C3', '2023-05-10'),
    ('shaunnaa', 'C5', '2023-05-10'),
    ('luanarau', 'D', '2023-05-10');


insert into XP(check_id, xpamount) values
    (1, 350),
    (2, 0),
    (3, 250),
    (4, 200),
    (5, 200),
    (6, 300);

insert into verter(check_id, state, time) values
    (1, 'Start', '15:00:00'),
    (1, 'Success', '15:05:00'),
    (3, 'Start', '10:00:00'),
    (3, 'Success', '10:05:00'),
    (4, 'Start', '11:00:00'),
    (4, 'Success', '11:05:00'),
    (8, 'Start', '12:00:00'),
    (8, 'Success', '13:05:00');

insert into p2p(check_id, checkingpeer, state, time) values
    (1, 'pipebomb', 'Start', '15:00:00'),
    (1, 'pipebomb', 'Success', '16:00:00'),
    (3, 'sanddony', 'Start', '17:00:00'),
    (2, 'luanarau', 'Start', '18:00:00'),
    (2, 'luanarau', 'Failure', '18:30:00'),
    (3, 'sanddony', 'Success', '19:00:00'),
    (4, 'pipebomb', 'Start', '20:00:00'),
    (4, 'pipebomb', 'Success', '21:00:00');

insert into transferredpoints(checkingpeer, checkedpeer, pointsamount) values
    ('luanarau', 'katherng', 15),
    ('katherng', 'luanarau', 3),
    ('luanarau', 'sanddony', 9),
    ('sanddony', 'luanarau', 0),
    ('luanarau', 'pipebomb', 3),
    ('pipebomb', 'luanarau', 4);

insert into recommendations(peer, recommendedpeer) values
    ('luanarau', 'katherng'),
    ('luanarau', 'sanddony'),
    ('luanarau', 'pipebomb'),
    ('pipebomb', 'katherng'),
    ('pipebomb', 'luanarau');

insert into friends(peer1, peer2) values
    ('luanarau', 'katherng'),
    ('luanarau', 'sanddony'),
    ('luanarau', 'pipebomb'),
    ('pipebomb', 'katherng'),
    ('pipebomb', 'luanarau');


-- call export_csv('peers', '/home/luanarau/luanarau_desktop/works/SQL2_Info21_v1.0-2/src/part_1/', ',');
-- call import_csv('peers', '/home/luanarau/luanarau_desktop/works/SQL2_Info21_v1.0-2/src/part_1/csv', ',');


