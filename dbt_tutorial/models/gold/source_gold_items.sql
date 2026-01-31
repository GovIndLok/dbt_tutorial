WITH deduplicate_query AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY id ORDER BY updateDate DESC) AS deduplicate_id
    FROM
        {{ source('source', 'items') }}
)

SELECT
    id,
    name,
    category,
    updateDate
FROM
    deduplicate_query
WHERE
    deduplicate_id = 1