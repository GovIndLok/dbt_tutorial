# dbt Core on Databricks – Retail Analytics & SCD Tutorial

This repository is a **hands-on tutorial project** built to learn how **dbt Core works on Databricks**, with a strong focus on **project structure, configuration precedence, environments, and Slowly Changing Dimensions (SCD Type 2)** using snapshots.

This is not a production template. It is intentionally opinionated and slightly verbose to make dbt concepts *visible and debuggable*.

---

## What This Project Demonstrates

- dbt Core integration with Databricks and Unity Catalog
- Practical dbt configuration precedence across project, folder, and model levels
- A structured Bronze → Silver → Gold analytics architecture
- SCD Type 2 dimensional modeling using dbt snapshots
- Multi-environment workflows using Unity Catalog–based dev and prod catalogs
- Local dbt execution using a modern Python environment powered by uv

---

## Tech Stack

* **Platform:** Databricks Data Intelligence Platform
* **dbt:** dbt Core with `dbt-databricks` adapter
* **Authentication:** Databricks Personal Access Token (PAT)
* **Catalogs:** Unity Catalog
* **Python Environment:** `uv` + virtualenv

---

## Repository Structure

```
.
├── dbt_tutorial/              # dbt project root (nested on purpose)
│   ├── models/
│   │   ├── bronze/
│   │   ├── silver/
│   │   └── gold/
│   ├── snapshots/
│   │   └── item_snapshot.sql
│   ├── dbt_project.yml
│   ├── profiles.yml.example
│   └── profiles.yml           # created in ~/.dbt just for referance
├── pyproject.toml
├── uv.lock
└── README.md
```

The dbt project lives inside `/dbt_tutorial` to reflect real-world mono-repo or data-platform layouts.

---

## Data Model Overview

### Source Data

Six CSV files are uploaded directly into Databricks and converted into **managed tables**:

* `fact_sales`
* `fact_returns`
* `dim_product`
* `dim_customer`
* `dim_store`
* `dim_date`

These act as raw sources for the Bronze layer.

Local copies of these CSV files are included in this repository under the folder:
```
dbt_tutorial/source_data/
```
Just create a 'source' schema to act like our source. After creating your Unity Catalog/catalog, upload the CSV files from `dbt_tutorial/source_data/` into 'source' schema (as managed or external tables). Once uploaded, the tables become available as the raw sources for the Bronze layer.

### Item Table (SCD Demo)

A dummy `item` table is used exclusively to demonstrate **Slowly Changing Dimension (Type 2)** behavior via dbt snapshots. Use the sql query below to create it or feel free to use your own.

(NOTE: change the appoperiate values in `dbt_tutorial/snapshots/gold_items.yml` file. We also need a timestamp column as we will be using it as our strategy to track changing dimension)
```
CREATE TABLE items (
  id INT,
  name STRING,
  category STRING,
  updateDate TIMESTAMP
);

INSERT INTO items
VALUES
(1, "item1","category1", current_timestamp()),
(2, "item2","category2", current_timestamp()),
(3, "item3","category3", current_timestamp()),
(4, "item4","category4", current_timestamp()),
(5, "item5","category5", current_timestamp());


SELECT * FROM gold.items;
```

---

## Environment Simulation

This project simulates multiple environments using **Unity Catalog catalogs**:

* `dbt_tutorial_dev`
* `dbt_tutorial_prod`

The same dbt code can target different catalogs by changing profile configuration, mimicking real-world deployment patterns.

---

## dbt Configuration Precedence (Key Learning Goal)

The project is intentionally structured to show how dbt resolves configuration conflicts:

1. **File-level config** – `{{ config() }}` inside model SQL files
   Example: `bronze_sales.sql` explicitly materialized as a `view`

2. **Folder-level config** – defined in `dbt_project.yml`

3. **Project-level defaults** – global fallback (default: `table`)

This makes it easy to see *which config wins and why*.

---

## Modeling Layers

### Bronze

* Raw staging models
* Minimal transformations
* Schema alignment and light cleanup

### Silver

* Business logic and joins
* Clean, reusable intermediate models

### Gold

* Final analytics-ready marts
* Designed for BI and reporting

---

## Snapshots (SCD Type 2)

Snapshots are used to track historical changes in the `item` table.

* Location: `snapshots/item_snapshot.sql`
* Strategy: **Timestamp-based SCD Type 2**
* Tracks row-level changes over time

This is the canonical dbt approach to dimensional history in analytics warehouses.

---

## Profiles & Authentication

### Profile Location

For tutorial clarity, the dbt profile is stored **inside the project**:

```
dbt_tutorial/profiles.yml
```

* This is the **tutorial way**
* The **professional way** is `~/.dbt/profiles.yml`

### Setup

A template is provided:

```
profiles.yml.example
```

It contains placeholders for:

* Databricks Host
* HTTP Path
* Personal Access Token (PAT)

Copy and fill it in locally:

```
cp profiles.yml.example profiles.yml
```

---

## Local Setup & Execution (Standard Operating Procedure)

From the repository root:

```bash
uv sync                   # Install and sync all Python dependencies into a local virtual environment
source .venv/bin/activate # Activate the virtual environment created by uv
```

Navigate to the dbt project:

```bash
cd dbt_tutorial           # Move into the dbt project directory
```

Configure your profile:

```bash
cp profiles.yml.example profiles.yml  # Create a local dbt profile configuration file
# fill in Databricks credentials        # Add your Databricks workspace, token, and HTTP path
```

Run dbt (step-by-step):

```bash
dbt debug     # Validate profiles.yml, test Databricks connectivity, and confirm environment setup
dbt run       # Execute dbt models (tables/views) defined in the project
dbt snapshot  # Run dbt snapshots to track slowly changing dimensions over time
```

---

## The One Command to Rule Them All: `dbt build`

Instead of running multiple commands during development, dbt provides a single command that orchestrates everything:

```bash
dbt build
```

What `dbt build` does:
- Runs models (`dbt run`)
- Executes tests (`dbt test`)
- Runs snapshots (`dbt snapshot`)
- Respects dependencies and execution order automatically

Think of it as **dbt’s full pipeline execution mode**.

---

## How `dbt build` Is Used in Production

In real-world production setups:
- CI/CD pipelines (GitHub Actions, GitLab CI, Azure DevOps, etc.) run one command
- Schedulers (Airflow, Databricks Workflows, cron) trigger one command
- Failures stop the pipeline early if tests or snapshots break

Example production pattern:

```bash
dbt build --target prod
```

This single command:
- Builds all models in the correct order
- Validates data quality via tests
- Updates historical snapshots
- Fails fast if anything is wrong

Mental model to keep:
- Development: run commands individually to learn and debug
- Production: use `dbt build` as the atomic, repeatable, one-line execution


---

## Important Notes

* This project prioritizes **learning over optimization**
* Security best practices (like centralized profiles) are intentionally relaxed for clarity
* All data is dummy or tutorial-grade

---

## Why This Project Exists

Databricks + dbt can feel opaque when learned only through docs. This project exists to:

* Make dbt behavior observable
* Show *why* configs behave the way they do
* Bridge the mental gap between Spark-native thinking and dbt-native workflows

If you understand this project end-to-end, you understand 80% of real-world dbt-on-Databricks work.

---

Happy modeling. Data is a story — dbt just forces you to write it clearly.
