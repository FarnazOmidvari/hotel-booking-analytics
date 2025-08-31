CREATE DATABASE Booking_Hotel;

USE Booking_Hotel;

/* Create Table Booking Transaction*/

CREATE TABLE BookingTransaction(
    booking_id INT,
    Booking_datetime DATETIME,
    Checkin_date DATETIME,
    Checkout_date DATETIME,
    Cancellation_date DATETIME  NULL,
    Origin CHAR(2),
    Hotel_id INT,
    Hotel_Country NVARCHAR(10),
    Cookie_id CHAR(36),
    Session_id NVARCHAR(36)
);

BULK INSERT BookingTransaction
FROM '/var/opt/mssql/booking-transaction.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2  -- اگر فایل شما هدر دارد
);


/* Create Table Traffic Transaction*/


CREATE TABLE TrafficTransaction(
    traffic_logtime DATETIME,
    Cookie_id CHAR(36),
    Session_id NVARCHAR(36),
    Origin NVARCHAR(2),
    Hotel_id INT NULL,
    City_id INT,
    City_name NVARCHAR(30),
    Country_id INT,
    Country_name NVARCHAR(30),
    Page_tape_name NVARCHAR(50),
    Browser NVARCHAR(50),
    Operating_system NVARCHAR(50)
);



BULK INSERT TrafficTransaction
FROM '/var/opt/mssql/traffic-transaction.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2  -- اگر فایل شما هدر دارد
);


/*EXEC sp_rename 'TrafficTransaction.page_tape_name' , 'page_type_name' , 'COLUMN'*/


/* Create Table Search Transaction*/

CREATE TABLE SearchTransaction(
    id CHAR(36),
    Search_logtime DATETIME,
    Search_date DATE,
    Cookie_id CHAR(36),
    Session_id VARCHAR(36),
	Member_id INT NULL,
    Device_type	NVARCHAR(10),
    Origin CHAR(2),
    City_id	INT,
    Language_id	TINYINT,
    Length_of_stay	TINYINT,
    Adults TINYINT,
    Room TINYINT,
    Children TINYINT,
    Checkin DATE,
    Checkout DATE,
    Currency_code CHAR(3)
);

BULK INSERT SearchTransaction
FROM '/var/opt/mssql/search-transaction.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2  -- اگر فایل شما هدر دارد
);


/* Create Table Origin*/
DROP TABLE Origin;

CREATE TABLE Origin(
    Origin  CHAR(2),
    Origin_name NVARCHAR(50)
);

BULK INSERT Origin
FROM '/var/opt/mssql/origin.csv'
WITH(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

/*---------------Create_Dimention_Tables-----------------------*/

/*-------Create Dim_origin------*/

TRUNCATE TABLE Dim_origin;

DROP TABLE Dim_origin;


CREATE TABLE Dim_origin(
    id INT IDENTITY(1,1) PRIMARY KEY,
    origin NVARCHAR(5),
    origin_name NVARCHAR(50)
);




            /*------------------------------*/

INSERT INTO dim_origin (origin, origin_name)
SELECT DISTINCT
    ISNULL(all_origins.origin, '-1') AS origin,
    ISNULL(o.origin_name, 'Unknown') AS origin_name
FROM (
    SELECT origin FROM BookingTransaction
    UNION
    SELECT origin FROM SearchTransaction
) all_origins
LEFT JOIN origin o ON all_origins.origin = o.origin;



SELECT * from Dim_origin;



/*-------Create Dim_date------*/
DROP TABLE Dim_date;

TRUNCATE TABLE Dim_date;

DELETE FROM Dim_date;

CREATE TABLE Dim_date(
    id INT PRIMARY KEY NOT NULL,
    log_date DATE,
    year INT,
    Month INT,
    day INT
);

INSERT INTO Dim_date(id , log_date , [year] , [Month] , [day])
SELECT 
    ISNULL(CAST(REPLACE(CONVERT(varchar(10) , all_date.alldate , 111 ) , '/' , '') AS INT) ,'10101010' ) AS id,
    ISNULL(all_date.alldate , '1010/10/10') AS log_date,
    year (ISNULL (all_date.alldate , '1010/10/10') ),
    month (ISNULL (all_date.alldate , '1010/10/10')),
    day (ISNULL (all_date.alldate , '1010/10/10'))
FROM (
    SELECT  CAST(Booking_datetime AS DATE) AS alldate FROM BookingTransaction
    UNION
    SELECT  CAST(Checkin_date AS DATE)  FROM BookingTransaction
    UNION 
    SELECT  CAST(Checkout_date AS DATE)  FROM BookingTransaction
    UNION
    SELECT  CAST(Cancellation_date AS DATE) FROM BookingTransaction
    UNION
    SELECT  CAST(Search_logtime AS DATE)  FROM SearchTransaction
    UNION
    SELECT DISTINCT CAST(traffic_logtime AS DATE)  FROM TrafficTransaction

) all_date
    


SELECT * from Dim_date


/*

SELECT all_date.alldate , 
    RIGHT('0' + CAST(REPLACE(CONVERT(varchar(8) , all_date.alldate , 108 ) , ':' , '')  AS INT) , 2) +


FROM (
    SELECT  CAST(Booking_datetime AS TIME) AS alldate FROM BookingTransaction
    UNION
    SELECT  CAST(Search_logtime AS TIME) AS alldate FROM SearchTransaction
) all_date
*/


/*-------Create Dim_time------*/
TRUNCATE TABLE Dim_time;

DROP TABLE Dim_time;

CREATE TABLE Dim_time(
    id CHAR(4) PRIMARY KEY NOT NULL,
    log_time TIME
);


INSERT INTO Dim_time (id, log_time)
SELECT 
    RIGHT('0' + CAST(DATEPART(HOUR, all_time.alltime) AS VARCHAR), 2) +
    RIGHT('0' + CAST(DATEPART(MINUTE, all_time.alltime) AS VARCHAR), 2) AS id,
    ISNULL(alltime, '00:00:00') AS log_time
FROM (
    SELECT DISTINCT CAST(Booking_datetime AS TIME) AS alltime FROM BookingTransaction
    UNION
    SELECT DISTINCT CAST(Search_logtime AS TIME) AS alltime FROM SearchTransaction
    UNION
    SELECT DISTINCT CAST(traffic_logtime AS TIME) AS alltime FROM TrafficTransaction
) AS all_time;




SELECT * FROM Dim_time;




/*-------Create Dim_currency------*/

TRUNCATE TABLE Dim_currency;

CREATE TABLE Dim_currency(
    id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    currency_code CHAR(5)
);


INSERT INTO Dim_currency(currency_code)
SELECT DISTINCT 
    ISNULL(Currency_code, 'unknown') FROM SearchTransaction;


            /*------------------------------*/

SELECT * FROM Dim_currency;

SELECT DISTINCT Currency_code FROM SearchTransaction;


/*-------Create Dim_page_type------*/

CREATE TABLE Dim_page_type(
    id INT IDENTITY(1,1) PRIMARY KEY,
    page_type_name NVARCHAR(50)
);


INSERT INTO Dim_page_type(page_type_name)
SELECT DISTINCT 
    ISNULL(page_type_name , 'unknown') FROM TrafficTransaction;


SELECT DISTINCT Page_type_name FROM TrafficTransaction;

select * FROM Dim_page_type;


/*-------Create Dim_destination_geo------*/

DROP TABLE Dim_destination_geo;

TRUNCATE TABLE Dim_destination_geo;

CREATE TABLE Dim_destination_geo(
    id INT PRIMARY KEY NOT NULL,
    City_name NVARCHAR(30)
);



            /*------------------------------*/

INSERT INTO Dim_destination_geo(id , City_name)
SELECT DISTINCT
    ISNULL(all_city.city_id , -1) AS id,
    ISNULL(tt.city_name , 'unknown') AS City_name
FROM (
    SELECT city_id FROM TrafficTransaction
    UNION
    SELECT city_id FROM SearchTransaction
) all_city
LEFT JOIN TrafficTransaction tt ON tt.city_id = all_city.city_id




/*------------Creat Dim_country-------------*/

TRUNCATE Table Dim_country;

DROP TABLE Dim_country;

CREATE TABLE Dim_country(
    id INT PRIMARY KEY NOT NULL,
    country_name NVARCHAR(30) 
);


INSERT INTO Dim_country(id , country_name)
SELECT DISTINCT
    ISNULL(Country_id , -1) AS id,
    ISNULL(Country_name , 'unknown') AS country_name
FROM
    TrafficTransaction ;


select * from Dim_country;

/*------------Creat Dim_hotel_country-------------*/


CREATE TABLE Dim_hotel_country(
    id INT PRIMARY KEY NOT NULL,
    hotel_country NVARCHAR(10)
);

INSERT INTO Dim_hotel_country(id , hotel_country)
SELECT DISTINCT
    ISNULL(all_hotel_id.Hotel_id , -1) AS id,
    ISNULL(bt.Hotel_Country , 'unknown') AS hotel_country
FROM (
    SELECT hotel_id FROM BookingTransaction
    UNION
    SELECT hotel_id FROM TrafficTransaction
) all_hotel_id
LEFT JOIN BookingTransaction bt ON bt.Hotel_id = all_hotel_id.Hotel_id



SELECT * from Dim_hotel_country 
where id = 185945


SELECT distinct hotel_country FROM Dim_hotel_country


/*--------------Create Fact Transaction-------------*/



/*---------Create fact_bookingTransaction---------*/
TRUNCATE TABLE fact_bookingtransaction;

DROP TABLE fact_bookingTransaction;

CREATE TABLE fact_bookingtransaction(
    booking_id INT PRIMARY KEY NOT NULL,
    booking_date_id INT FOREIGN KEY REFERENCES Dim_date(id),
    booking_time_id  CHAR(4) FOREIGN KEY REFERENCES Dim_time(id),
    checkin_date_id INT FOREIGN KEY REFERENCES Dim_date(id),
    checkout_date_id INT FOREIGN KEY REFERENCES Dim_date(id),
    cancellation_date_id INT FOREIGN KEY REFERENCES Dim_date(id),
    origin_id INT FOREIGN KEY REFERENCES Dim_origin(id),
    hotel_id INT FOREIGN KEY REFERENCES Dim_hotel_country(id),

);


INSERT INTO fact_bookingtransaction (
    booking_id ,
    booking_date_id ,
    booking_time_id ,
    checkin_date_id ,
    checkout_date_id ,
    cancellation_date_id ,
    origin_id ,
    hotel_id 
    )
select
    bt.booking_id,
    dd.id AS booking_date_id ,
    dt.id AS booking_time_id,
    dd2.id AS checkin_date_id,
    dd3.id AS checkout_date_id,
    dd4.id AS cancellation_date_id,
    do.id AS origin_id,
    dh.id AS hotel_id 
FROM 
    BookingTransaction bt
LEFT JOIN Dim_date dd ON ISNULL( CAST(bt.Booking_datetime AS DATE) , '1010/10/10') = dd.log_date
LEFT JOIN Dim_time dt ON  ISNULL( CAST(bt.Booking_datetime AS TIME) , '1010/10/10' ) = dt.log_time
LEFT JOIN Dim_date dd2 ON ISNULL( CAST(bt.Checkin_date AS DATE ) , '1010/10/10' ) = dd2.log_date
LEFT JOIN Dim_date dd3 ON ISNULL( CAST(bt.checkout_date AS DATE) , '1010/10/10' ) = dd3.log_date
LEFT JOIN Dim_date dd4 ON ISNULL(CAST (bt.Cancellation_date AS DATE) , '10101010') = dd4.log_date
LEFT JOIN Dim_origin do ON   ISNULL(bt.origin , -1)  = do.origin
LEFT JOIN Dim_hotel_country dh ON ISNULL( bt.hotel_id , -1 ) = dh.id






SELECT * FROM fact_bookingTransaction
where hotel_id = -1;

SELECT distinct cancellation_date_id from fact_bookingTransaction;
SELECT distinct booking_date_id from fact_bookingTransaction;


/*---------Create fact_trafficTransaction---------*/
TRUNCATE TABLE fact_traffictransaction;

DROP TABLE fact_traffictransaction;



CREATE TABLE fact_traffictransaction(
    id_trafictransaction INT IDENTITY(1,1) PRIMARY KEY ,
    traffic_logdate_id INT FOREIGN KEY REFERENCES Dim_date(id),
    traffic_logtime_id char(4) FOREIGN KEY REFERENCES Dim_time(id),
    origin_id INT FOREIGN KEY REFERENCES Dim_origin(id),
    hotel_id INT FOREIGN KEY REFERENCES Dim_hotel_country(id) ,
    city_id INT FOREIGN KEY REFERENCES Dim_destination_geo(id),
    country_id INT FOREIGN KEY REFERENCES Dim_country(id),
    page_type_id INT FOREIGN KEY REFERENCES Dim_page_type(id),
    browser NVARCHAR(50),
    operating_system NVARCHAR(50)

);

INSERT INTO fact_traffictransaction (
    traffic_logdate_id ,
    traffic_logtime_id ,
    origin_id,
    hotel_id ,
    city_id ,
    country_id ,
    page_type_id ,
    browser ,
    operating_system 

)
SELECT 
    dd.id AS traffic_logdate_id,
    dt.id AS traffic_logtime_id,
    do.id AS origin_id,
    dh.id AS hotel_id,
    dg.id AS city_id,
    dc.id AS country_id,
    dp.id as page_type_id,
    tt.Browser ,
    tt.Operating_system
FROM
    TrafficTransaction tt 
LEFT JOIN Dim_date dd ON  ISNULL(CAST(tt.traffic_logtime AS DATE) , '1010/10/10') = dd.log_date
LEFT JOIN Dim_time dt ON  ISNULL(CAST(tt.traffic_logtime AS TIME) , '2525' ) = dt.log_time
LEFT JOIN Dim_origin do ON ISNULL(tt.origin  , -1) = do.origin 
LEFT JOIN Dim_hotel_country dh ON ISNULL(tt.Hotel_id , -1 ) = dh.id
LEFT JOIN Dim_destination_geo dg ON ISNULL(tt.city_name , 'unknown' ) = dg.city_name
LEFT JOIN Dim_country dc ON ISNULL(tt.Country_name , 'unknown' ) = dc.country_name
LEFT JOIN Dim_page_type dp ON ISNULL(tt.page_type_name , 'unknown' ) = dp.page_type_name 




SELECT * FROM fact_traffictransaction
where traffic_logtime_id is NULL;

/*---------Create fact_searchTransaction---------*/

CREATE TABLE fact_searchtransaction(
    id CHAR(36) PRIMARY KEY NOT NULL,
    search_logdate_id INT FOREIGN KEY REFERENCES Dim_date(id),
    search_logtime_id char(4) FOREIGN KEY REFERENCES Dim_time(id),
    origin_id INT FOREIGN KEY REFERENCES Dim_origin(id),
    city_id INT FOREIGN KEY REFERENCES Dim_destination_geo(id),
    length_of_stay TINYINT,
    adults TINYINT ,
    room TINYINT,
    children TINYINT,
    checkin_date_id INT FOREIGN KEY REFERENCES Dim_date(id),
    checkout_date_id INT FOREIGN KEY REFERENCES Dim_date(id),
    currency_id  INT FOREIGN KEY REFERENCES Dim_currency(id)

)

INSERT INTO fact_searchtransaction (
    id ,
    search_logdate_id ,
    search_logtime_id ,
    origin_id ,
    city_id ,
    length_of_stay ,
    adults  ,
    room ,
    children ,
    checkin_date_id ,
    checkout_date_id ,
    currency_id  
)

SELECT 
    st.id ,
    dd.id AS search_logdate_id ,
    dt.id AS search_logtime_id ,
    do.id AS origin_id ,
    dg.id AS city_id ,
    st.length_of_stay ,
    st.adults  ,
    st.room ,
    st.children ,
    dd.id AS checkin_date_id ,
    dd.id AS checkout_date_id ,
    dc.id AS currency_id  

FROM
    SearchTransaction st
LEFT JOIN Dim_date dd ON ISNULL(CAST( st.Search_logtime  AS DATE) , '1010/10/10' ) = dd.log_date
LEFT JOIN Dim_time dt ON ISNULL(CAST( st.Search_logtime  AS TIME) , '2525' ) = dt.log_time
LEFT JOIN Dim_origin do ON ISNULL(st.origin  , '-1' ) = do.origin 
LEFT JOIN Dim_destination_geo dg ON ISNULL(st.City_id , -1 ) = dg.id
LEFT JOIN Dim_currency dc ON ISNULL(st.Currency_code , -1)  = dc.currency_code


SELECT top 2 * FROM fact_searchtransaction;
SELECT top 2 * FROM fact_bookingtransaction;

/*--------------------------*/
