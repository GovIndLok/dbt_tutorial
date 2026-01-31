{% set inc_flag = 1%}
{% set last_load = 3 %}

{% set cols_set = ["sales_id", "date_sk", "gross_amount"]%}

SELECT
    {% for i in cols_set %}
        {{ i }}
        {%- if not loop.last -%},{%- endif -%}
    {% endfor %}
FROM
    {{ ref('bronze_sales')}}

{% if inc_flag == 1%}
    WHERE date_sk > {{ last_load}}
{% endif %}