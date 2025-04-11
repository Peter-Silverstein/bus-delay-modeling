# Evaluating RapidRide Reliability
Repository for my master's thesis for Quantitative Methods in the Social Sciences at Columbia University.

## Background
The RapidRide system is a set of upgraded metro bus routes in and around Seattle, WA, applied to bus routes with intense ridership in high-traffic corridors of the city. Some of these upgrades are designed to improve the frequency of service (through managed headway) and speed of travel (fewer stops along route, similar to an express route), but one of the desired outcomes for the program is increased reliability of service. For this project, I defined reliability of service as average absolute deviation from schedule (i.e., how many seconds early/late a bus is, compared to the scheduled arrival time). Arriving early or late has serious implications for riders, especially when transfers across routes are involved. In this project, I seek to estimate overall treatment effects in addition to treatment effects for subgroups of the data (such as day of the week, hour of the day, and by individual route).

## Methodology
The project relies on various regression models, culminating in a hierarchical regression using a Bayesian Additive Regression Tree component to estimate nonlinearities, interaction effects, and varying treatment effects by subgroup, all while sharing information across partitions within the data.

## Repository Components

### data-setup-scripts
The data-setup-scripts folder contains .Rmd files that I have used to load and clean my data, as well as some code for exploratory data analysis and modeling results.

### cloud-scripts
The cloud-scripts folder contains scripts and data specifically used while training my stan4bart model via Google Cloud Vertex AI. You can also find the raw data for the project in this folder.

### python-scripts
The Python Scripts folder contains the scripts I used to pull GTFS Real-Time data from the OneBusAway API. Pulls were made every 15 minutes via AWS Lambda. This code is not in a state where it's ready to be put into AWS Lambda directly, but the bones of how I made the API requests and structured the resulting data are in there.

### Old R Scripts
The Old R Scripts folder contains old R code and scratch files I used to mess around before finalizing code that exists in the data-setup-scripts folder.

## Future Directions
This project will culminate in a final paper, which will be uploaded here when done.
