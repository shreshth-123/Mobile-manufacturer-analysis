--SQL Advance Case Study
--Q1--BEGIN 
	
	select distinct state from FACT_TRANSACTIONS as a
	inner join DIM_LOCATION as b
	on a.IDLocation=b.IDLocation
	where a.date >= '2007'
	
--Q1--END

--Q2--BEGIN
	
	select top 1  State from FACT_TRANSACTIONS as x
	inner join DIM_LOCATION as y
	on x.IDLocation=y.IDLocation
	inner join DIM_MODEL as z
	inner join DIM_MANUFACTURER as a
	on z.IDManufacturer=a.IDManufacturer
	on x.IDModel=z.IDModel
	where country =  'US' and Manufacturer_Name='Samsung'
	group by state
	order by sum(quantity) desc
	
--Q2--END

--Q3--BEGIN      
	
	
	select state, model_name,ZipCode,count(y.IDModel) as no_of_transaction
	from FACT_TRANSACTIONS as x
	inner join  DIM_MODEL as y
	on x.IDModel=y.IDModel
	inner join DIM_LOCATION as z
	on x.IDLocation=z.IDLocation 
	group by zipcode ,state,Model_Name

	


--Q3--END

--Q4--BEGIN

    select top 1 Manufacturer_Name,Model_Name,  unit_price from DIM_MODEL as x
    inner join DIM_MANUFACTURER as y
    on x.IDManufacturer=y.IDManufacturer
    order by Unit_price asc



--Q4--END

--Q5--BEGIN

    select top 5 Manufacturer_Name,model_name ,avg(totalprice) as avg_price,
	sum(totalprice) as tot_sales ,sum(quantity) as tot_quantity 
    from FACT_TRANSACTIONS as x
    inner join DIM_MODEL as y
    on x.IDModel=y.IDModel
    inner join DIM_MANUFACTURER as z
    on y.IDManufacturer=z.IDManufacturer
    group by Manufacturer_Name, Model_Name
    order by  avg_price desc


--Q5--END

--Q6--BEGIN

  with cte as 
      (
      select Customer_Name,avg(totalprice) as avg_spent ,
	  DATEPART(Year,date) as yr from FACT_TRANSACTIONS as x
      inner join DIM_CUSTOMER as z
      on x.IDCustomer=z.IDCustomer
      group by Customer_Name ,DATEPART(Year,date)
       ),
         cte2 as
        (
        select yr, customer_name,avg_spent
        from cte where yr='2009' and avg_spent>'500'
       )
           select Customer_Name , avg_spent from cte2 as c



--Q6--END
	
--Q7--BEGIN  
	
	SELECT(
	       SELECT TOP 5 Model_Name FROM FACT_TRANSACTIONS AS X
	       INNER JOIN DIM_MODEL AS Y
	       ON X.IDModel=Y.IDModel
	       INNER JOIN DIM_DATE AS Z
	       ON X.DATE=Z.DATE
	       WHERE YEAR IN ('2008')
	       GROUP BY Model_Name
	       ORDER BY SUM(Quantity) DESC
	   INTERSECT
	       SELECT TOP 5 Model_Name FROM FACT_TRANSACTIONS AS X
	       INNER JOIN DIM_MODEL AS Y
	       ON X.IDModel=Y.IDModel
	       INNER JOIN DIM_DATE AS Z
	       ON X.DATE=Z.DATE
	       WHERE YEAR IN ('2009')
	       GROUP BY Model_Name
	       ORDER BY SUM(Quantity) DESC
	    INTERSECT
	       SELECT TOP 5 Model_Name FROM FACT_TRANSACTIONS AS X
	       INNER JOIN DIM_MODEL AS Y
	       ON X.IDModel=Y.IDModel
	       INNER JOIN DIM_DATE AS Z
	       ON X.DATE=Z.DATE
	       WHERE YEAR IN ('2010')
	       GROUP BY Model_Name
	       ORDER BY SUM(Quantity) DESC
	    ) AS MODEL_NAME



--Q7--END	
--Q8--BEGIN


    WITH RANK1 AS 
    ( 
       SELECT MANUFACTURER_NAME,YEAR(DATE) AS YEAR,
	   DENSE_RANK()OVER (PARTITION BY YEAR(DATE) ORDER BY SUM(TOTALPRICE) DESC) AS RANK
       FROM FACT_TRANSACTIONS AS X
       INNER JOIN 
       DIM_MODEL AS Y 
       ON X.IDModel=Y.IDModel
       INNER JOIN DIM_MANUFACTURER AS Z
       ON Y.IDManufacturer=Z.IDManufacturer
       GROUP BY Manufacturer_Name,YEAR(DATE)
    )
    
        SELECT YEAR, MANUFACTURER_NAME  FROM RANK1
        WHERE YEAR IN ('2009','2010') AND RANK='2'
    



--Q8--END
--Q9--BEGIN
	
 select distinct manufacturer_name from FACT_TRANSACTIONS as x
 inner join DIM_MODEL as y on x.IDModel=y.IDModel
 inner join DIM_MANUFACTURER as z on y.IDManufacturer=z.IDManufacturer
 inner join DIM_DATE as a on a.DATE=x.Date
 where a.YEAR = '2010'
	except
	     select distinct Manufacturer_Name from FACT_TRANSACTIONS as x
	     inner join DIM_MODEL as y
	     on x.IDModel=y.IDModel
	     inner join DIM_MANUFACTURER as z
	     on y.IDManufacturer=z.IDManufacturer
	     inner join DIM_DATE as a
	     on a.DATE=x.Date
	     where a.YEAR='2009'
	     
--Q9--END

--Q10--BEGIN
	

	with top10 as
	(
	   select top 10 Customer_Name from FACT_TRANSACTIONS t1
	   inner join DIM_CUSTOMER t2
	   on t1.IDCustomer=t2.IDCustomer
	   group by Customer_Name
	   order by sum(TotalPrice) desc
	),
	yr_wise_spend as
	(
	   select  Customer_Name,avg(totalprice) as avg_spent,avg(quantity) as avg_qty,SUM(TOTALPRICE) AS TOT_PRICE,
	   lag(AVG(TOTALPRICE),1) over(partition by b.customer_name order by c.year) AS LAG,C.YEAR AS YEAR
	   from FACT_TRANSACTIONS as a
	   inner join DIM_CUSTOMER as b
	   on a.IDCustomer=b.IDCustomer
	   inner join DIM_DATE  as c
	   on a.Date=c.date
	   WHERE Customer_Name IN ( SELECT Customer_Name FROM top10)
	   GROUP BY CUSTOMER_NAME,C.YEAR

	)
	   SELECT Customer_Name ,AVG_SPENT,AVG_QTY,YEAR,((avg_spent-LAG)/avg_spent*100) AS PERCENTAGE_CHANGE_IN_SPEND
	   FROM yr_wise_spend AS A
	
--Q10--END
	