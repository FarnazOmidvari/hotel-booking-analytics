# 📑 Data Dictionary – Hotel Booking Analytics

## 📌 Overview
This **Data Dictionary** describes the data warehouse schema used for the *Hotel Booking Analytics* project.  
The schema follows a **Star Schema** design, including **Fact Tables** that store business events (bookings, searches, traffic) and **Dimension Tables** that provide descriptive context.  

---

## 🟦 Dimension Tables  

### 1. `Dim_date`
| Column     | Data Type | Description               |
|------------|-----------|---------------------------|
| `id`       | INT (PK)  | Unique surrogate key      |
| `log_date` | DATE      | Actual date               |
| `year`     | INT       | Year component            |
| `month`    | INT       | Month (1–12)              |
| `day`      | INT       | Day of the month          |

---

### 2. `Dim_time`
| Column     | Data Type | Description               |
|------------|-----------|---------------------------|
| `id`       | CHAR(4) PK| Surrogate key (HHMM)      |
| `log_time` | TIME      | Actual time value         |

---

### 3. `Dim_origin`
| Column       | Data Type   | Description                          |
|--------------|-------------|--------------------------------------|
| `id`         | INT (PK)    | Surrogate key                        |
| `origin`     | NVARCHAR(5) | Country/source code                  |
| `origin_name`| NVARCHAR(50)| Descriptive name                     |

---

### 4. `Dim_currency`
| Column        | Data Type  | Description              |
|---------------|------------|--------------------------|
| `id`          | INT (PK)   | Surrogate key            |
| `currency_code` | CHAR(5)  | Currency code (USD, EUR) |

---

### 5. `Dim_page_type`
| Column          | Data Type  | Description            |
|-----------------|------------|------------------------|
| `id`            | INT (PK)   | Surrogate key          |
| `page_type_name`| NVARCHAR(50)| Page name (search, booking, etc.) |

---

### 6. `Dim_destination_geo`
| Column     | Data Type   | Description        |
|------------|-------------|--------------------|
| `id`       | INT (PK)    | Surrogate key      |
| `city_name`| NVARCHAR(30)| Destination city   |

---

### 7. `Dim_country`
| Column       | Data Type   | Description        |
|--------------|-------------|--------------------|
| `id`         | INT (PK)    | Surrogate key      |
| `country_name`| NVARCHAR(30)| Destination country|

---

### 8. `Dim_hotel_country`
| Column        | Data Type   | Description          |
|---------------|-------------|----------------------|
| `id`          | INT (PK)    | Surrogate key        |
| `hotel_country`| NVARCHAR(10)| Hotel country code  |

---

## 🟩 Fact Tables  

### 1. `fact_bookingtransaction`
| Column               | Data Type | Description                           |
|----------------------|-----------|---------------------------------------|
| `booking_id`         | INT (PK) | Unique booking ID                     |
| `booking_date_id`    | INT (FK) | Ref → `Dim_date` (booking date)       |
| `booking_time_id`    | CHAR(4)  | Ref → `Dim_time` (booking time)       |
| `checkin_date_id`    | INT (FK) | Ref → `Dim_date` (check-in date)      |
| `checkout_date_id`   | INT (FK) | Ref → `Dim_date` (check-out date)     |
| `cancellation_date_id`| INT (FK)| Ref → `Dim_date` (cancellation date) |
| `origin_id`          | INT (FK) | Ref → `Dim_origin` (user origin)      |
| `hotel_id`           | INT (FK) | Ref → `Dim_hotel_country`             |

---

### 2. `fact_traffictransaction`
| Column                | Data Type  | Description                        |
|-----------------------|------------|------------------------------------|
| `id_trafictransaction`| INT (PK)  | Unique traffic transaction ID      |
| `traffic_logdate_id`  | INT (FK)  | Ref → `Dim_date` (traffic date)    |
| `traffic_logtime_id`  | CHAR(4)   | Ref → `Dim_time` (traffic time)    |
| `origin_id`           | INT (FK)  | Ref → `Dim_origin`                 |
| `hotel_id`            | INT (FK)  | Ref → `Dim_hotel_country`          |
| `city_id`             | INT (FK)  | Ref → `Dim_destination_geo`        |
| `country_id`          | INT (FK)  | Ref → `Dim_country`                |
| `page_type_id`        | INT (FK)  | Ref → `Dim_page_type`              |
| `browser`             | NVARCHAR(50)| Browser used                     |
| `operating_system`    | NVARCHAR(50)| Operating system                  |

---

### 3. `fact_searchtransaction`
| Column            | Data Type  | Description                          |
|-------------------|------------|--------------------------------------|
| `id`              | CHAR(36) PK| Unique search transaction ID         |
| `search_logdate_id`| INT (FK)  | Ref → `Dim_date` (search date)       |
| `search_logtime_id`| CHAR(4)   | Ref → `Dim_time` (search time)       |
| `origin_id`       | INT (FK)   | Ref → `Dim_origin`                   |
| `city_id`         | INT (FK)   | Ref → `Dim_destination_geo`          |
| `length_of_stay`  | TINYINT    | Nights requested                     |
| `adults`          | TINYINT    | Adults in search                     |
| `room`            | TINYINT    | Rooms requested                      |
| `children`        | TINYINT    | Children in search                   |
| `checkin_date_id` | INT (FK)   | Ref → `Dim_date` (planned check-in)  |
| `checkout_date_id`| INT (FK)   | Ref → `Dim_date` (planned check-out) |
| `currency_id`     | INT (FK)   | Ref → `Dim_currency`                 |

---

## 📊 Schema Overview  

The schema follows a **Star Schema** with three Fact tables (`fact_bookingtransaction`, `fact_traffictransaction`, `fact_searchtransaction`) connected to multiple shared Dimension tables (`Dim_date`, `Dim_time`, `Dim_origin`, `Dim_currency`, etc.).  

📌 Schema diagram: `docs/schema-diagram.png`  
