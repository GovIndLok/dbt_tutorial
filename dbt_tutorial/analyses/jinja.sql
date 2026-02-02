{%- set f1_teams = ['Farrari', 'Mercedes', 'Red Bull', 'McLaren', 'Alpine', 'Aston Martin', 'Williams', 'VCARB', 'Haas', 'Audi', 'Cadillac'] -%}

{% for i in f1_teams %}
    {{ i }}
    {%- if i == "Cadillac" -%}
        {{ " - New Entry for 2026 Season!" }}
    {%- else -%}
        {{ " - Established Team" }}
    {%- endif -%}

{% endfor %}