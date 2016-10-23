/* use master_pickapart; */
use master_pickapart;
drop table if exists cars;
create table cars (
  date_added date default null,
  make varchar(15),
  model varchar(20),
  year int,
  body_style varchar(20),
  engine varchar(20),
  transmission varchar(20),
  description varchar(50),
  row varchar(7),
  stock varchar(10) primary key
);
