Select * from Salaries;
/* 1. You're a Compensation analyst employed by a multinational corporation. 
Your Assignment is to Pinpoint Countries who give work fully remotely, for the title 'managers’ Paying salaries Exceeding $90,000 USD*/
 
 Select distinct(Company_location)from salaries where Remote_ratio =100 and job_title like "%manager%" and salary_in_usd >90000;
 
 /*2. AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms.
 you're tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies.*/
 
select company_location,count(company_size) as Count_of_large_companies 
from salaries where company_size ="L" group by 1 
order by Count_of_large_companies desc 
Limit 5;
 
/*3 Picture yourself AS a data scientist Working for a workforce management platform. 
Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness 
of high-paying remote positions IN today's job market.*/

Set @fullyremote = (select count(*) from salaries where salary_in_usd>100000 and remote_ratio =100);
 set @Total = (select count(*) from salaries where salary_in_usd>100000);
 set @percentage = round((((select @fullyremote)/(select @total))*100),2);
 
 select @percentage as '%  of people workINg remotly and havINg salary >100,000 USD';
 
 /* 4. Imagine you're a data analyst Working for a global recruitment agency. 
 Your Task is to identify the Locations where entry-level average salaries exceed the average salary for that job title 
 IN market for entry level, helping your agency guide candidates towards lucrative opportunities.*/
 
 with T1 as
 (select Company_location, job_title, avg(salary_in_usd) as 'Average_Salary_of_each_countries'from salaries where experience_level ="EN"
 group by 1,2)
 
select * from T1 where
 Average_Salary_of_each_countries > (select avg(salary_in_usd) from salaries where Job_title = T1.job_title AND experience_level ="EN");

 
 select * from 
 (select Company_location, job_title, avg(salary_in_usd) as 'Average_Salary_of_each_countries'from salaries where experience_level ="EN"
 group by 1,2) as TB1 LEFT JOIN 
(SELECT JOB_TITLE, AVG(salary_in_usd) as 'Avg_of_Job' FROM salaries WHERE experience_level ="EN" GROUP BY 1) AS Tb2 
on TB1.Job_title=tb2.job_title 
where Tb1.Average_Salary_of_each_countries > tb2.Avg_of_Job;

/*You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. 
Your job is to Find out for each job title which. Country pays the maximum average salary.
 This helps you to place your candidates IN those countries.*/
 
 with cte as (
select job_title, company_location, avg(salary_in_usd) "Average Salary",
 dense_rank() over (partition by job_title order by avg(salary_in_usd) desc) as Rnk from salaries
group by 1,2
)
select * from cte where Rnk = 1

 
 /* 5.AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 3 years Only(present year as  and pst two years) 
 providing Insights into Locations experiencing Sustained salary growth. */


with cte_1 as ( 
 with cte as (
select company_location,work_year,avg(salary_in_usd) as "Avg_sal" 
from salaries 
where work_year>=year(curdate())-2
group by 1,2
)
  select company_location , round(ifnull(max(case when work_year=2022 then avg_sal end),0),0) as "2022_Avg_sal",
 round(ifnull( max(case when work_year=2023 then avg_sal end),0),0) as "2023_Avg_sal",
 round(ifnull(max(case when work_year=2024 then avg_sal end),0),0) as "2024_Avg_sal"
 from cte group by 1
 )
 
 select * from cte_1  where 2022_Avg_sal<2023_Avg_sal and 2023_Avg_sal<2024_Avg_sal;
 
  /* 7.	Picture yourself AS a workforce strategist employed by a global HR tech startup. Your missiON is to determINe the percentage of  fully remote work for each 
 experience level IN 2021 and compare it WITH the correspONdINg figures for 2024, highlightINg any significant INcreASes or decreASes IN remote work adoptiON
 over the years.*/
 
WITH t1 AS 
 (
		SELECT a.experience_level, total_remote ,total_2021, concat(ROUND((((total_remote)/total_2021)*100),2),"%") AS '2021_remote_Prcnt' FROM
		( 
		   SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2021 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		  SELECT  experience_level, COUNT(experience_level) AS total_2021 FROM salaries WHERE work_year=2021 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ),
  t2 AS
     (
		SELECT a.experience_level, total_remote ,total_2024, concat(ROUND((((total_remote)/total_2024)*100),2),"%") AS '2024_remote_Prcnt' FROM
		( 
		SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2024 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		SELECT  experience_level, COUNT(experience_level) AS total_2024 FROM salaries WHERE work_year=2024 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ) 
  
 SELECT t1.experience_level,2024_remote_Prcnt,2021_remote_Prcnt FROM t1 INNER JOIN t2 ON t1.experience_level = t2.experience_level;
 
 /* 8. AS a compensatiON specialist at a Fortune 500 company, you're tASked WITH analyzINg salary trends over time. Your objective is to calculate the average 
salary INcreASe percentage for each experience level and job title between the years 2023 and 2024, helpINg the company stay competitive IN the talent market.*/

WITH CTE_1 AS (
WITH CTE AS (
select job_title,experience_level,work_year , avg(salary_in_usd) as AVG_SAL from salaries where work_year in (2023,2024)
GROUP BY 1,2,3
)
SELECT job_title,experience_level,IFNULL(Max(case when work_year=2023 then AVG_SAL END),0) as "2023_AVG_SAL",
IFNULL(Max(case when work_year=2024 then AVG_SAL END),0) AS "2024_AVG_SAL" FROM CTE GROUP BY 1,2
)

SELECT *,concat(round(((2024_AVG_SAL-2023_AVG_SAL)/2023_AVG_SAL)*100,2),"%") as "%_change_over_year" from cte_1 
where 2023_AVG_SAL<2024_AVG_SAL;

/* 9. You're a database administrator tasked with role-based access control for a company's employee database. Your goal is to implement a security measure where employees
 in different experience level (e.g.Entry Level, Senior level etc.) can only access details relevant to their respective experience_level, ensuring data 
 confidentiality and minimizing the risk of unauthorized access.*/
 select * from salaries;
 Show privileges;
 
CREATE USER 'Entry_level'@'%' IDENTIFIED BY 'EN';
CREATE USER 'Junior_Mid_level'@'%' IDENTIFIED BY ' MI '; 
CREATE USER 'Intermediate_Senior_level'@'%' IDENTIFIED BY 'SE';
CREATE USER 'Expert Executive-level '@'%' IDENTIFIED BY 'EX ';


CREATE VIEW entry_level AS
SELECT * FROM salaries where experience_level='EN';

GRANT SELECT ON sql_project.entry_level TO 'Entry_level'@'%'

/* 10.	You are working with an consultancy firm, your client comes to you with certain data and preferences such as 
( their year of experience , their employment type, company location and company size )  and want to make an transaction into different domain in data industry
(like  a person is working as a data analyst and want to move to some other domain such as data science or data engineering etc.)
your work is to  guide them to which domain they should switch to base on  the input they provided, so that they can now update thier knowledge as  per the suggestion/.. 
The Suggestion should be based on average salary.*/

DELIMITER //
create PROCEDURE GetAverageSalary(IN exp_lev VARCHAR(2), IN emp_type VARCHAR(3), IN comp_loc VARCHAR(2), IN comp_size VARCHAR(2))
BEGIN
    SELECT job_title, experience_level, company_location, company_size, employment_type, ROUND(AVG(salary), 2) AS avg_salary 
    FROM salaries 
    WHERE experience_level = exp_lev AND company_location = comp_loc AND company_size = comp_size AND employment_type = emp_type 
    GROUP BY experience_level, employment_type, company_location, company_size, job_title order by avg_salary desc ;
END//
DELIMITER ;

call GetAverageSalary