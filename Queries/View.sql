select  age_group, count([CUSTOMER_NUMBER]) as total_customers, sum([TOTAL_SALES]) as total_sales
from [gold].[report_customers]
group by age_group
order by age_group

select  [CUSTOMER_SEGMENT], count([CUSTOMER_NUMBER]) as total_customers, sum([TOTAL_SALES]) as total_sales
from [gold].[report_customers]
group by [CUSTOMER_SEGMENT]

SELECT * FROM gold.report_products