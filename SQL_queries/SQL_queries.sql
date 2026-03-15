CREATE DATABASE bank_churn;
USE bank_churn;


CREATE TABLE bank(
					customer_id INT PRIMARY KEY,
                    surname VARCHAR(50),
                    credit_score INT,
                    country VARCHAR(15),
                    gender varchar(10),
                    age INT,
                    tenure INT,
                    account_balance DOUBLE,
                    number_of_bank_products INT,
                    credit_card VARCHAR(6),
                    activity_status VARCHAR(10),
                    estimated_salary DOUBLE,
                    churned_status VARCHAR(10) 
                    );
                    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Bank_Churn_01.csv'
INTO TABLE bank
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SELECT * FROM bank;

SELECT COUNT(*) FROM BANK; -- 10000 Rows and 13 Columns imported , correct

SELECT COUNT(*) FROM bank
GROUP BY customer_id
HAVING COUNT(*) >1 ; -- 0 rows returned , no duplicate values


SELECT * FROM bank
WHERE 
	customer_id IS NULL OR 
	surname IS NULL OR 
	credit_score IS NULL OR 
	country IS NULL OR 
	gender IS NULL OR 
	age IS NULL OR 
	tenure IS NULL OR 
	account_balance IS NULL OR 
	number_of_bank_products IS NULL OR 
	credit_card IS NULL OR 
	activity_status IS NULL OR 
	estimated_salary IS NULL OR 
	churned_status IS NULL 
    ; -- 0 rows returned , no blank values



-- KPI Validation Of Overview Page

-- 1. Total Customers
SELECT COUNT(customer_id) AS Total_customers FROM bank ; -- 10,000

-- 2. Total Retained customers
SELECT COUNT(*) AS Total_retained_customers FROM bank
WHERE churned_status = 'Retained';

-- 3. Total Churned customers
SELECT COUNT(*) AS Total_retained_customers FROM bank
WHERE churned_status = 'Churned';

-- 4. Avg credit score 
SELECT ROUND(AVG(credit_score),0) AS Avg_credit_score FROM bank;

-- 5. Avg balance
SELECT ROUND(AVG(account_balance),0) AS Avg_Balance FROM bank;

-- 6. Avg Estimated salary
SELECT ROUND(AVG(estimated_salary),0) AS Avg_estimated_salary FROM bank;


/* **************   ADDING AGE BUCKET , TENURE BUCKET, ACCOUNT BALANCE BUCKET , 
								SALARY BUCKET COLUMNS */

ALTER TABLE bank
ADD COLUMN age_bucket VARCHAR(15);

UPDATE bank
SET age_bucket = 
				CASE 
					WHEN age BETWEEN 18 AND 25 THEN '18-25'
                    WHEN age BETWEEN 26 AND 35 THEN '26-35'
                    WHEN age BETWEEN 36 AND 45 THEN '36-45'
                    WHEN age BETWEEN 46 AND 55 THEN '46-55'
                    WHEN age BETWEEN 56 AND 65 THEN '56-65'
                    ELSE '65+'
                    END ;
                    

ALTER TABLE bank
ADD COLUMN tenure_bucket VARCHAR(10);

UPDATE bank
SET tenure_bucket = 
				CASE 
					WHEN tenure BETWEEN 0 AND 2 THEN '0-2 Years'
                    WHEN tenure BETWEEN 3 AND 5 THEN '3-5 Years'
                    WHEN tenure BETWEEN 6 AND 8 THEN '6-8 Years'
                    ELSE '9-10 Years'
                    END ;


ALTER TABLE bank
ADD COLUMN salary_bucket VARCHAR(10);

SELECT * FROM BANK;


UPDATE  bank
SET salary_bucket = CASE 
						WHEN estimated_salary <= 50000 THEN '0K-50K' 
						WHEN estimated_salary <= 100000 THEN '50K-100K' 
                        WHEN estimated_salary <= 150000 THEN '100K-150K'
                        WHEN estimated_salary <= 200000 THEN '150K-200K'
                        ELSE '200K+'
                        END;

SELECT * FROM BANK;


ALTER TABLE bank
ADD COLUMN balance_bucket varchar(10);


UPDATE bank
SET balance_bucket = CASE
						WHEN account_balance = 0 THEN '0'
                        WHEN account_balance <= 20000 THEN '1K-20K'
                        WHEN account_balance <= 40000 THEN '20K-40K'
                        WHEN account_balance <= 60000 THEN '40K-60K'
                        WHEN account_balance <= 80000 THEN '60K-80K'
                        ELSE '80K+'
                        END;

SELECT * FROM BANK;


-- Visual validation

-- 1. Total customers by age bucket

SELECT 
	age_bucket AS Age_Bucket , 
	COUNT(customer_id) AS Total_customers 
FROM bank 
	GROUP BY age_bucket
	ORDER BY age_bucket ASC ;


-- 2. Total customers country wise And based on activity status

SELECT 
	country, 
	COUNT(*) AS Total_customers 
FROM bank
		GROUP BY country
		ORDER BY Total_customers DESC ;

SELECT 
	country, 
	COUNT(*) AS Total_customers 
FROM bank
	WHERE activity_status = 'Active'
		GROUP BY country
		ORDER BY Total_customers DESC;

SELECT 
	country, 
	COUNT(*) AS Total_customers 
FROM bank
	WHERE activity_status = 'Inactive'
		GROUP BY country
		ORDER BY Total_customers DESC ;

-- 3. Total customers and no.of bank products

SELECT 
	number_of_bank_products AS Bank_products ,
	COUNT(*) AS Total_customers 
FROM bank
	GROUP BY number_of_bank_products
	ORDER BY Total_customers DESC ; 

-- 4. Total customers by Gender

SELECT 
	gender ,
	COUNT(*) AS Total_customers 
FROM bank
	WHERE gender = 'Male'
		GROUP BY gender
		ORDER BY Total_customers DESC ; 

SELECT 
	gender ,
	COUNT(*) AS Total_customers 
FROM bank
	WHERE gender = 'Female'
		GROUP BY gender
		ORDER BY Total_customers DESC ; 

-- 5. Churned Rate
 


SELECT 
    country,
    total_customers,
    churned_customers,
    ROUND(churned_customers * 100.0 / total_customers,2) AS churn_rate
FROM
(
    SELECT 
        country,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN churned_status='Churned' THEN 1 ELSE 0 END) AS churned_customers 
    FROM bank
    GROUP BY country
) t;



-- 6. Country wise summary 

SELECT country , 
		ROUND(AVG(age),0) AS Avg_age,
        ROUND(AVG(credit_score),0) AS Avg_credit_score,
        ROUND(AVG(estimated_salary),0) AS Avg_salary
FROM bank
	GROUP BY country;




-- KPI VALIDATION OF Churn Analysis page

-- 1. Total Customers
SELECT COUNT(customer_id) AS Total_customers FROM bank ; -- 10,000

-- 2. Total Retained customers
SELECT COUNT(*) AS Total_retained_customers FROM bank
WHERE churned_status = 'Retained';

-- 3. Total Churned customers
SELECT COUNT(*) AS Total_retained_customers FROM bank
WHERE churned_status = 'Churned';

-- 4. Churn rate


SELECT 
    SUM(CASE WHEN churned_status = 'Churned' THEN 1 ELSE 0 END) AS churned_customers,
    COUNT(*) AS total_customers,
    (SUM(CASE WHEN churned_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate
FROM bank;

-- VISUALS VALIDATION 

	-- 1. Churned customers count by activity status
 

SELECT 
	activity_status, 
	COUNT(*) AS Total_churned_customers 
FROM bank
	WHERE activity_status = 'Inactive' 
		AND churned_status = 'churned'
			GROUP BY activity_status ;
			
SELECT 
	activity_status, 
	COUNT(*) AS Total_churned_customers 
FROM bank
	WHERE activity_status = 'Active' 
		AND churned_status = 'churned'
			GROUP BY activity_status ;


-- 2. GENDER WISE CHURNED CUSTOMERS


SELECT
	gender, 
	COUNT(*) AS Total_chruned_customers 
FROM bank
		WHERE gender = 'Female' AND churned_status = 'Churned'
		GROUP BY gender;

SELECT
	gender, 
	COUNT(*) AS Total_chruned_customers 
FROM bank
		WHERE gender = 'Male' AND churned_status = 'Churned'
		GROUP BY gender ;


-- 3. Age wise churned customers

SELECT 
	age_bucket , 
	COUNT(*) AS Total_churned_customers 
FROM bank
	WHERE churned_status = 'Churned'
		GROUP BY age_bucket
			ORDER BY age_bucket ASC;



-- AGE WISE CHURN RATE 

SELECT 
	age_bucket,
    Total_customers,Churned_customers,
    ROUND(Churned_customers *100 / total_customers,2) AS Churned_rate
    from 
		(SELECT 
			age_bucket , 
			COUNT(*) AS Total_customers ,
			SUM(CASE WHEN churned_status = 'Churned' THEN 1 ELSE 0 END) AS Churned_customers
		FROM bank
				GROUP BY age_bucket
				ORDER BY age_bucket ASC) t ;


-- 4. Estimated salary bucket wise churned customers


SELECT 
		salary_bucket,
        Total_customers,
        Churned_customers,
        ROUND(Churned_customers*100/Total_customers,2) AS Churn_Rate
        FROM
			(SELECT 
					salary_bucket,
                    COUNT(*) AS Total_customers,
                    SUM(CASE WHEN churned_status = 'Churned' THEN 1 ELSE 0 END) AS Churned_customers
			FROM bank
				GROUP BY salary_bucket
               ) t ;
                    

-- 5. Tenure wise churn analysis

SELECT 
	tenure_bucket, 
    Total_customers,
    Churned_customers,
    Churned_customers *100 / Total_customers AS Churned_Rate
FROM 
	( SELECT 
			tenure_bucket,
			COUNT(*) AS Total_customers,
            SUM(CASE WHEN churned_status = 'Churned' THEN 1 ELSE 0 END) AS Churned_customers
	FROM bank
			GROUP BY tenure_bucket) t ;
 


-- 6. Country wise customer churn analsis

SELECT country,
		Total_customers,
        Churned_customers,
        Churned_customers*100/Total_customers AS Churn_Rate
FROM 	
		(SELECT 
				country,
                COUNT(*) AS Total_customers,
                SUM(CASE WHEN churned_status ='Churned' THEN 1 ELSE 0 END) AS Churned_customers
			FROM bank	
				GROUP BY country ) t;



-- Validation of Financial Analysis Page

	-- Visuals validation
    
    -- 1. Country wise average estimated salary and average balance analysis


SELECT 
		country AS Country,
		ROUND(AVG(estimated_salary),0) AS Avg_Est_Salay,
        ROUND(AVG(account_balance),0) AS Avg_Balance
FROM bank
		GROUP BY country
;
        


-- 2. Age group wise average estimated salary and average balance analysis


SELECT 
		age_bucket AS Age,
		ROUND(AVG(estimated_salary),0) AS Avg_Est_Salay,
        ROUND(AVG(account_balance),0) AS Avg_Balance
FROM bank
		GROUP BY age_bucket
        ORDER BY age_bucket DESC ;


-- 3. Average balance by churned status

SELECT 
	churned_status,
    ROUND(AVG(account_balance),0) AS Avg_balance 
FROM bank
		GROUP BY churned_status;


-- 4. Average balance by Tenure 

SELECT 
	tenure_bucket,
    ROUND(AVG(account_balance),0) AS Avg_balance 
FROM bank
		GROUP BY tenure_bucket
        ORDER BY tenure_bucket DESC;


-- 5. Average balance by Estimated salary 

SELECT 
	salary_bucket,
    ROUND(AVG(account_balance),0) AS Avg_balance 
FROM bank
		GROUP BY salary_bucket
        ORDER BY salary_bucket DESC;


-- 6. Average balance by Bank products

SELECT 
	number_of_bank_products,
    ROUND(AVG(estimated_salary),0) AS Avg_salary
FROM bank
		GROUP BY number_of_bank_products
        ORDER BY number_of_bank_products DESC;



-- Validation of Bank Products Analysis Page

	-- Visuals validation
    
    -- 1. Percentage Credit Card Holders

SELECT COUNT(*) AS credit_card_holders from bank
where credit_card = 'Yes';


SELECT 
		
        Total_customers,
        Total_Credit_Card_holders,
        ROUND(Total_Credit_Card_holders*100/Total_customers,2) AS Percentage_cc_holders
FROM
( SELECT 
	
	COUNT(*) AS Total_customers,
	SUM(CASE WHEN credit_card = 'Yes' THEN 1 ELSE 0 END) AS Total_Credit_Card_holders
FROM bank
    ) t;
    
-- 2. Total customers and no.of bank products

SELECT
		number_of_bank_products AS Bank_products,
		COUNT(*) AS Total_customers 
FROM bank
			GROUP BY number_of_bank_products
			ORDER BY number_of_bank_products DESC;
        

-- 3. Inactive and active customers by no.of bank products

SELECT 
	number_of_bank_products AS Bank_products,
    activity_status AS Activity_status,
    COUNT(*) AS Total_customers
FROM bank
		GROUP BY number_of_bank_products ,activity_status 
        ORDER BY number_of_bank_products DESC;


-- 4. Tenure wise Products ownership analysis

SELECT 
	number_of_bank_products AS Bank_products,
    tenure_bucket AS Tenure,
    COUNT(*) AS Total_customers
FROM bank
		GROUP BY number_of_bank_products ,tenure_bucket 
        ORDER BY tenure_bucket DESC ;


-- 5. Churned Customers and Churned Rate by Credit card holders

SELECT 
	churned_status AS Ch_Status,
    credit_card AS Credit_Card,
    COUNT(*) AS Total_customers
FROM bank
		GROUP BY churned_status ,credit_card 
        HAVING churned_status = 'Churned'
        ORDER BY churned_status DESC ;

-- below is the query for findidng the churn rate

SELECT 
    credit_card AS Credit_Card,
    COUNT(*) AS Total_customers,
    SUM(CASE WHEN churned_status = 'Churned' THEN 1 ELSE 0 END) AS Churned_customers,
    ROUND(SUM(CASE WHEN churned_status = 'Churned' THEN 1 ELSE 0 END) * 100.0 
    / COUNT(*),2) AS Churn_rate
FROM bank
GROUP BY credit_card;


-- 6. Average balance by number of bank products

SELECT 
	number_of_bank_products AS Bank_products,
    ROUND(AVG(account_balance),0) AS Avg_balance    
FROM bank
		GROUP BY number_of_bank_products 
        ORDER BY number_of_bank_products DESC ;


-- 7. Average number of bank products by Churn status

SELECT 
		churned_status AS Statuss,
		ROUND(AVG(number_of_bank_products),0) AS Bank_products
FROM bank
			GROUP BY churned_status
;
        
-- 8. Product ownership distribution by gender

SELECT
	gender,
    number_of_bank_products AS Bank_Products,
    COUNT(*) AS Total_customers
FROM bank
		GROUP BY gender,number_of_bank_products;


-- Validation of Customers Analys Page 


	-- KPI VALIDATION
			
            -- 1. Total Active and Inactive Customers
            
				SELECT 
					activity_status AS Statuss, 
					COUNT(*) AS Total_customers
                FROM bank
						GROUP BY activity_status;

	-- Visual validation


-- 1. Country wise total customers

SELECT 
		country AS Country,
        COUNT(*) AS Total_customers
FROM bank
		GROUP BY country
        ORDER BY COUNT(*) DESC;

-- 2. TOTAL INACTIVE CUSTOMERS BY BALANCE BUCKET

SELECT
	balance_bucket AS Balance,
    activity_status AS Statuss,
    COUNT(*) AS Total_customers
FROM bank
		GROUP BY balance_bucket, activity_status
        HAVING activity_status = 'Inactive'
        ORDER BY balance_bucket DESC ;


-- 3. Churned Rate by activity status

SELECT 
		activity_status AS Statuss , 
		COUNT(*) AS Total_customers,
		SUM(CASE WHEN churned_status = 'Churned' THEN 1 ELSE 0 END ) AS Churned_customers,
		ROUND(SUM(CASE WHEN churned_status = 'Churned' THEN 1 ELSE 0 END )*100/COUNT(*),2) AS Churned_Rate
FROM BANK
			GROUP BY activity_status
;


-- 4. Inactive customers by salary bucket

SELECT 
	salary_bucket AS Salary,
    activity_status AS Statuss,
    COUNT(*) AS Total_customers
FROM bank
		GROUP BY salary_bucket,activity_status
        HAVING activity_status = 'Inactive'
        ORDER BY salary_bucket DESC ;


-- 5. Customer profile summary by activity status and Country 


SELECT 
	country AS Country,
    activity_status AS Statuss,
    gender,
    COUNT(*) AS Customers,
    ROUND(AVG(tenure),0) AS AVG_Tenure,
    ROUND(AVG(credit_score),0) AS Avg_credit_score
FROM bank
		GROUP BY country , activity_status, gender;


-- 6. credit card holders vs activity status country wise

SELECT 
		country , 
        activity_status, 
        credit_card,
		COUNT(*) AS Total_customers

FROM bank
			GROUP BY 
				country , 
				activity_status, 
				credit_card ;