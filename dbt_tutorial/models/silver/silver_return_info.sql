WITH sale_returns AS (
    SELECT
        sales_id,
        product_sk,
        date_sk,
        store_sk,
        refund_amount,
        return_reason
    FROM
        {{ ref('bronze_returns') }}
),

products AS (
    SELECT
        product_sk,
        category
    FROM 
        {{ ref('bronze_product') }}
),

stores AS (
    SELECT
        store_sk,
        store_name,
        state_province,
        country
    FROM
        {{ ref('bronze_store') }}
),

joined_query AS (
    SELECT
        sale_returns.refund_amount,
        sale_returns.return_reason,
        products.category,
        stores.state_province,
        stores.store_name,
        stores.country
    FROM
        sale_returns
    JOIN 
        products ON sale_returns.product_sk = products.product_sk
    JOIN
        stores ON sale_returns.store_sk = stores.store_sk
)

SELECT
    store_name,
    ANY_VALUE(state_province) AS state_province,
    ANY_VALUE(country) AS country,
    category,
    return_reason,
    sum(refund_amount) AS total_refund_amount
FROM
    joined_query
GROUP BY
    store_name,
    return_reason,
    category
ORDER BY
    total_refund_amount DESC  