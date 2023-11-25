--вывод в столбце customers_count общее количество покупателей из таблицы customers
select COUNT(customer_id) as customers_count from customers;

------

--вспомогательная таблица с полем 'имя и фамилия' продавца, используется в многотабличном запросе 
with empl_name as (
	select employee_id, first_name ||' '|| last_name as name from employees 
)
-- выборка 10-ти лучших продавцов по выручке за все время в порядке убывания
select e.name, count(s.sale_date)as operations, ROUND(SUM(s.quantity * p.price)) as income   
from sales s
join empl_name e on s.sales_person_id = e.employee_id
join products p on s.product_id = p.product_id 
group by e.name
order by income desc limit 10
;
-------

--вспомогательная таблица с полем 'имя и фамилия' продавца, используется в многотабличном запросе 
with empl_name as (
	select employee_id, first_name ||' '|| last_name as name from employees 
)
-- выборка продавцов,чья средняя выручка ниже средней выручки по всем продавцам
select e.name, ROUND(AVG(s.quantity * p.price)) as average_income   
from sales s
join empl_name e on s.sales_person_id = e.employee_id
join products p on s.product_id = p.product_id 
group by e.name
having ROUND(AVG(s.quantity * p.price)) < (select ROUND(avg(s.quantity * p.price)) 
							from sales s join products p on s.product_id = p.product_id )
order by average_income
;
------

--вспомогательная таблица с полем 'имя и фамилия' продавца, используется в многотабличном запросе 
with empl_name as (
	select employee_id, first_name ||' '|| last_name as name from employees 
)
-- отчет по суммарной выручке каждого продавца за определенный день недели
select e.name, to_char(s.sale_date, 'day') as weekday, ROUND(SUM(s.quantity * p.price)) as income
from sales s
join empl_name e on s.sales_person_id = e.employee_id
join products p on s.product_id = p.product_id 
group by e.name, weekday, EXTRACT(isodow from s.sale_date)
order by EXTRACT(isodow from s.sale_date), e.name
;