In VS code, create new project workspace folder.
In terminal, run ***meltano init meltano-ingestion***
In terminal, run ***cd meltano-ingestion***
In terminal. run ***meltano config set meltano python python3.11***
Create folder **data** in the **meltano-ingestion** folder
Download the csv files from Kapple Olist link
drag the cvs files from download folder into **data** folder
create .env file in the **meltano-ingestion** folder
Go to GCP and create a new project **DS6 module 2 olist analytics**
To create a service account for the project: Go to IAM & Admin > Service Accounts.Click the ➕ Create Service Account button at the top of the page.Fill in the Service account details:Service account name: Choose a descriptive name (e.g., dbt-bigquery-runner).Service account ID: This will auto-populate based on the name.Service account description: Optional, but good practice to describe what it does.Click Create and Continue.Grant this service account access to project (Optional): Click the Select a role dropdown to give it the necessary permissions.Choose Bigquery Data Editor, add another rolse for Bigquery job user and add service account token creator role (acts like digital key-card checks, when teammate runs Meltano/dbt fr their terminal, GCP checks their personal OAuth login and allow temporaily wear the service acc identity)
To give access to team members: Click on Principales with access tab and click on grant access, enter email address into new principals*
To set limit for budget: In GCP search for billing-> Set budget alert to $1-> click next
Go to meltano.yml file, key in the plugins line5 to line50
meltano add tap-github
meltano config set tap-github --interactive
Create new token in github->settings->developer settings->new token DS6 M2 project-> Ok
copy password
got to vs code-> key 3 to update TAP_GITHUB_AUTH_TOKEN-->copy password twice and save
key to update repositories--> paste ["pandas-dev/pandas"]
Paste nd run in terminal meltano config test tap-github
Paste and run in terminal meltano select tap-github --list --all
meltano add target-bigquery
meltano config set target-bigquery --interactive
New service account needs new JSON --> At the left sidebar menu on GCP-> click Service accounts.You will see a list of service accounts->Click on the email address link for ds6-module-2-project-team@://gserviceaccount.com.Once that details page opens, you will see a row of tabs running across the top center of the page: DETAILS, PERMISSIONS, KEYS, METRICS, LOGS-> Click on KEYS->Click the Add Key dropdown button, select Create new key, choose JSON, and click Create to download it.
Drag the ds6-module-2-olist-analytics-2f1692e19f87.json file from download folder into VS code meltano-ingestion folder
Rename ds6-module-2-olist-analytics-2f1692e19f87.json to gcpproject.key.json
Config with the following:
credentials_path: full path to the service account key file-->gcpproject.key.json
dataset: ingestion
denormalized: true
flattening_enabled: true
flattening_max_depth: 1
method: batch_job
project: your_gcp_project_id--> ds6-module-2-olist-analytics

meltano add tap-csv
meltano run tap-csv target-bigquery