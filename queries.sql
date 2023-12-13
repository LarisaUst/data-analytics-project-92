--вывод в столбце customers_count общего количества покупателей из таблицы customers
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
------

--вспомогательная таблица для установки признака возрастной категории каждому возрасту
with tab as (
	select age,
			case 
				when age between 16 and 25 then '16-25'
				when age between 26 and 40 then '26-40'
				when age > 40 then '40+'
	           end
	as age_cat
from customers
)
--отчет по количеству покупателей в разных возрастных группах: 16-25, 26-40 и 40+
select tab.age_cat as age_category, count(tab.age_cat)as count
from tab
group by age_category
order by age_category
;
------
--отчет по количеству уникальных покупателей и выручке, которую они принесли, сгруппирован 
--по возрастанию даты
select to_char(s.sale_date, 'YYYY-MM') as date, count(distinct customer_id) as total_customers,
ROUND(sum(s.quantity * p.price)) as income 
from sales s
join products p on s.product_id = p.product_id
group by date
order by date
;

-----
--вспомогательная таблица с полем 'имя и фамилия' покупателя, используется в многотабличном запросе 
with custm_name as (
	select customer_id, first_name ||' '|| last_name as name from customers
),
--вспомогательная таблица с полем 'имя и фамилия' продавца, используется в многотабличном запросе 
empl_name as (
	select employee_id, first_name ||' '|| last_name as name from employees 
),
-- вспомогательный многотабличный запрос с оконной функцией, определяющей дату первой покупки
-- в партициях покупателей, определяет поля для итогового запроса
tab as(
select s.customer_id as id, c.name as customer, first_value(sale_date) 
    over(partition by s.customer_id order by sale_date)as first_date, p.price, e.name as seller
from sales s
left join custm_name c on s.customer_id = c.customer_id
left join products p on s.product_id = p.product_id
left join empl_name e on s.sales_person_id = e.employee_id
)
--отчет по покупателям,первая покупка которых была в ходе проведения акций
--(акционные товары отпускали со стоимостью равной 0)
select customer, first_date as sale_date, seller
from tab
where price = 0
group by id, customer, first_date, seller
order by id
;


