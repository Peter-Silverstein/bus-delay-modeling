# bus-delay-modeling
Repository for my QMSS master's thesis: modeling bus delay in Seattle, WA. This is still a work in progress.

## General Information
The purpose of this project is to model bus arrival delay in Seattle in order to better understand differences across routes. I am using General Transit Feed Specification (GTFS) data alongside various predictors and an indicator variable for RapidRide routes to assess whether delay and variability of delay differs between RapidRide and non-RapidRide routes. Part of my methodology is using multilevel modeling to allow regression coefficients to vary by route.

## Python Scripts
The Python Scripts folder contains the scripts I used to pull GTFS Real-Time data from the OneBusAway API. Pulls were made every 15 minutes via AWS Lambda. This code is not in a state where it's ready to be put into AWS Lambda directly, but the bones of how I made the API requests and structured the resulting data are in there.

## data-setup-scripts
The data-setup-scripts folder contains .Rmd files that I have used to load, clean, and set up my data. There are separate scripts for my Stop-level predictors dataset and my Route-level predictors dataset. Additionally, I have an initial (and currently very incomplete) exploratory data visualization script.

## Old R Scripts
The Old R Scripts folder currently just contains an attempt I made at clipping routes based on which stop I was looking at.

## Future Directions
In the future, I will of course finish this out with the final report, but also hope to update this README with comprehensive data links as well as more detail on the modeling I will do.
