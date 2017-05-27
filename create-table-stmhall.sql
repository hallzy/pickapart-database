/* use master_pickapart; */
use stmhallc_cars;
drop table if exists pics;
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

create table pics (
  url varchar(100) not null,
  car_stock varchar(10) not null,
  primary key(url, car_stock),
  foreign key(car_stock) references cars(stock)
);

create view lot as select ifnull(group_concat(url separator ' '), "") as urls, date_added, make, model, year, body_style, engine, transmission, description, row, stock from cars c left join pics p on c.stock=p.car_stock group by stock;
