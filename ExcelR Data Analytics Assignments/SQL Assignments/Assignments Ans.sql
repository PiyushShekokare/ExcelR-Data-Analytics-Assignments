use classicmodels;
/*Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
a.	Fetch the employee number, first name and last name of those employees who
 are working as Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)
*/
desc employees;
select * from employees;

select employeeNumber, firstName,lastName
from employees
where jobTitle='sales Rep' and reportsTo = 1102;

/*b. Show the unique productline values containing the word cars at the end from the products table.*/
Select distinct productline
from products
where productline like '%Cars';

/*Q2. CASE STATEMENTS for Segmentation
   a. Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)
                        "North America" for customers from USA or Canada
                        "Europe" for customers from UK, France, or Germany
                        "Other" for all remaining countries
     Select the customerNumber, customerName, and the assigned region as "CustomerSegment". */
     
     SELECT customerNumber,customerName,
	 CASE  WHEN country IN ('USA', 'Canada') THEN 'North America'
           WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
           ELSE 'Other'
	 END AS CustomerSegment
     FROM customers;

/*Q3. Group By with Aggregation functions and Having clause, Date and Time functions
a.	Using the OrderDetails table, identify the top 10 products (by productCode) 
	with the highest total order quantity across all orders.*/

SELECT productCode,
       SUM(quantityOrdered) AS TotalOrderQuantity
FROM OrderDetails
GROUP BY productCode
ORDER BY TotalOrderQuantity DESC
LIMIT 10;


/*b. Company wants to analyse payment frequency by month. 
     Extract the month name from the payment date to count the total number of
     payments for each month and include only those months with a payment count exceeding 20.
     Sort the results by total number of payments in descending order.  (Refer Payments table). */
 SELECT 
DATE_FORMAT(paymentDate, '%M') AS payment_month, 
COUNT(*) AS num_payments
FROM payments
GROUP BY payment_month
HAVING num_payments > 20
ORDER BY num_payments DESC;

/* Q4.CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
	  Create a new database named and Customers_Orders and add the following tables as per the description
A.Create a table named Customers to store customer information. Include the following columns:

customer_id: This should be an integer set as the PRIMARY KEY and AUTO_INCREMENT.
first_name: This should be a VARCHAR(50) to store the customer's first name.
last_name: This should be a VARCHAR(50) to store the customer's last name.
email: This should be a VARCHAR(255) set as UNIQUE to ensure no duplicate email addresses exist.
phone_number: This can be a VARCHAR(20) to allow for different phone number formats.

Add a NOT NULL constraint to the first_name and last_name columns to ensure they always have a value. */

create database Customers_Orders;
use Customers_Orders;
drop table Customers;
create table Customers (
customer_id int auto_increment primary key,
first_name varchar(50) not null,
last_name varchar(50)not null,
email varchar(255) unique,
phone_number varchar(20)
);

/* B. Create a table named Orders to store information about customer orders. Include the following columns:
order_id: This should be an integer set as the PRIMARY KEY and AUTO_INCREMENT.
customer_id: This should be an integer referencing the customer_id in the Customers table  (FOREIGN KEY).
order_date: This should be a DATE data type to store the order date.
total_amount: This should be a DECIMAL(10,2) to store the total order amount.
Constraints:
a)	Set a FOREIGN KEY constraint on customer_id to reference the Customers table.
b)	Add a CHECK constraint to ensure the total_amount is always a positive value.*/

drop table Orders;
create table Orders(
order_id int auto_increment primary key,
customer_id int,
order_date date,
total_amount decimal(10,2),
constraint cust_id01 foreign key(customer_id) references Customers(customer_id),
constraint chk_total_amount_positive CHECK (total_amount > 0)
);

desc orders;

 /*Q5. JOINS
a. List the top 5 countries (by order count) that Classic Models ships to. 
(Use the Customers and Orders tables)*/

SELECT Customers.country, COUNT(Orders.orderNumber) AS order_count
FROM Customers
JOIN Orders ON Customers.customerNumber = Orders.customerNumber
GROUP BY Customers.country
ORDER BY order_count DESC
LIMIT 5;

/* Q6. SELF JOIN
a. Create a table project with below fields.

●	EmployeeID : integer set as the PRIMARY KEY and AUTO_INCREMENT.
●	FullName: varchar(50) with no null values
●	Gender : Values should be only ‘Male’  or ‘Female’
●	ManagerID: integer
    Find out the names of employees and their related managers.*/

create Table Project
(EmployeeID int primary key auto_increment,
FullName Varchar(50) Not null,
Gender Enum("Male","Female"),
ManagerID Int );

Insert into Project values(1,'Pranaya', 'Male', 3),
                          (2,'Priyanka', 'Female', 1),
                          (3,'Preety', 'Female', NULL),
                          (4,'Anurag', 'Male', 1),
                          (5,'Sambit', 'Male', 1),
                          (6,'Rajesh', 'Male', 3),
                          (7,'Hina', 'Female', 3);
select * From Project;
Select e.FullName As Manager_Name,
	   m.FullName As Emp_Name
From Project e Join Project m
on m.ManagerID=e.EmployeeID;

/*Q7. DDL Commands: Create, Alter, Rename
a. Create table facility. Add the below fields into it.
●	Facility_ID
●	Name
●	State
●	Country

i) Alter the table by adding the primary key and auto increment to Facility_ID column.
ii) Add a new column city after name with data type as varchar which should not accept any null values.*/

Create Table Facility
(Facility_ID int,
Name Varchar(100),
State Varchar(100),
Country Varchar(100) );

Alter Table Facility Modify Column Facility_ID int auto_increment primary key ;
ALTER TABLE facility
ADD COLUMN City VARCHAR(100) NOT NULL AFTER Name;

Desc Facility;

/*Q8. Views in SQL
a. Create a view named product_category_sales that provides insights into sales performance by product category. 
This view should include the following information: 
productLine: The category name of the product (from the ProductLines table).
total_sales: The total revenue generated by products within that category 
             (calculated by summing the orderDetails.quantity * orderDetails.
             priceEach for each product in the category).
number_of_orders: The total number of orders containing products from that category.
(Hint: Tables to be used: Products, orders, orderdetails and productlines)*/
Select * From Productlines;
Select * From orders;
Select * From orderdetails;
Select * From Products;
CREATE VIEW product_category_sales AS
SELECT
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM Products p JOIN ProductLines pl 
ON p.productLine = pl.productLine JOIN OrderDetails od 
ON p.productCode = od.productCode JOIN Orders o 
ON od.orderNumber = od.orderNumber
GROUP BY pl.productLine;

Select * From product_category_sales;

/*Q9. Stored Procedures in SQL with parameters
a. Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, 
country wise total amount as an output. Format the total amount to nearest thousand unit (K)
Tables: Customers, Payments*/
/* PROCEDURE `Get_country_payments`(In InputYear int,in InputCountry Varchar(255))
BEGIN
Select Year(paymentDate) As Year,
	   Customers.Country As Country,
       CONCAT(FORMAT(SUM(Amount), 'N0'), 'K') As TotalAmountK
 From Payments
 Join Customers On Payments.CustomerNumber = Customers.CustomerNumber
 Where Year(PaymentDate)=InputYear And Customers.country=InputCountry
 group by Year,Country;
END; */
call Get_country_payments(2003, 'France');
Desc customers;
Desc Payments;

/* Q10. Window functions - Rank, dense_rank, lead and lag
a) Using customers and orders tables, rank the customers based on their order frequency */
SELECT 
    c.customerName,
	COUNT(o.orderNumber) AS order_Count,
    RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequency_rnk
FROM 
    Customers c
JOIN 
    Orders o ON c.customerNumber = o.customerNumber
GROUP BY 
    c.customerNumber, c.customerName
ORDER BY 
   order_frequency_rnk;
   
   
/*b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change.
     Format the YoY values in no decimals and show in % sign.
     Table: Orders */

Select * From Orders;

SHOW COLUMNS FROM Orders;
WITH YearMonthOrders AS (
  SELECT
    EXTRACT(YEAR FROM orderDate) AS year,
    DATE_FORMAT(orderDate, '%M') AS month,
    COUNT(*) AS Total_orders
  FROM
    Orders
  GROUP BY
    year, month
  ORDER BY
    year, month
),

YoYPercentageChange AS (
  SELECT
    a.year,
    a.month,
    a.Total_orders,
    b.Total_orders AS prev_year_order_count,
    CASE
      WHEN b.Total_orders IS NULL THEN 'N/A' -- Avoid division by zero
      ELSE
        CONCAT(
          ROUND(((a.Total_orders - b.Total_orders) / b.Total_orders) * 100),
          '%'
        )
    END AS yoy_percentage_change
  FROM
    YearMonthOrders a
  LEFT JOIN
    YearMonthOrders b
  ON
    a.year = b.year + 1
    AND a.month = b.month
)
SELECT
  year,
  month,
  Total_orders,
  yoy_percentage_change
FROM
  YoYPercentageChange;
  
  /*Q11.Subqueries and their applications
  
a.Find out how many product lines are there for which the buy price value is greater than the average of buy price value.
 Show the output as product line and its count. */
 
SELECT p.ProductLine,COUNT(*) AS Total
FROM Products AS p JOIN (SELECT AVG(BuyPrice) AS AvgBuyPrice
                          FROM Products) AS avg_prices
ON p.BuyPrice > avg_prices.AvgBuyPrice
GROUP BY p.ProductLine
ORDER BY Total DESC;

/*Q12. ERROR HANDLING in SQL
	 Create the table Emp_EH. Below are its fields.
●	EmpID (Primary Key)
●	EmpName
●	EmailAddress
Create a procedure to accept the values for the columns in Emp_EH. 
Handle the error using exception handling concept. Show the message as “Error occurred” in case of anything wrong.*/

Create Table Emp_EH
(EmpID int Primary key,
 EmpName Varchar(50),
 EmailAddress Varchar(50) );
 /*PROCEDURE `Emp_EH`(IN p_EmpID INT,
    IN p_EmpName VARCHAR(50),
    IN p_EmailAddress VARCHAR(50))
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred';
    END;
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);
END */
INSERT INTO Emp_EH VALUES (1,"Piyush", "p@gmail.com");
call Emp_EH(1, 'John Doe', 'john.doe@example.com');
select * from Emp_EH;

/*Q13. TRIGGERS
Create the table Emp_BIT. Add below fields in it.
●	Name
●	Occupation
●	Working_date
●	Working_hours

Insert the data as shown in below query.
INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);  

Create before insert trigger to make sure any new value of Working_hours, 
if it is negative,then it should be inserted as positive.*/

Create Table Emp_BIT
(Name Varchar(50),
Occupation Varchar(50),
Working_Date Date,
Working_Hours int );

Insert into Emp_BIT Values('Robin', 'Scientist', '2020-10-04', 12),  
						  ('Warner', 'Engineer', '2020-10-04', 10),  
                          ('Peter', 'Actor', '2020-10-04', 13),  
                          ('Marco', 'Doctor', '2020-10-04', 14),  
                          ('Brayden', 'Teacher', '2020-10-04', 12),  
                          ('Antonio', 'Business', '2020-10-04', 11);
                          
/* BEFORE INSERT ON `emp_bit` FOR EACH ROW BEGIN
If New.Working_Hours<0 Then
Set New.Working_Hours=-New.Working_Hours;
end if;
END*/

Select * From Emp_BIT;




















