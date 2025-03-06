# LanguageFinder (demo version)

Find out which languages other than English are spoken in particular places.
Translations and interpretation services are key tools to increase accessibility to information. Access to information is especially important in relation to:

1) Disaster warnings and disaster response;
2) Healthcare, especially treatment options and recovery instructions;
3) Local government engagement;
4) Environmental justice; 
5) Workplace safety

See how many people speak a particular language in different places.

1) Understanding how speakers of a certain language are distributed across the U.S. can help organizations find collaborative partners in creating translations and interpretive services for that language.

2) Organizations that serve particular language communities can use this information to identify key service areas.

This project seeks to make data about languages spoken in the US accessible to decision-makers in social sector enterprises. Key variables for decision-makers include the detailed language spoken, ability to speak English, and potentially age, for organizations that serve specific age groups, e.g.: voting age population, K-12 children, seniors, etc. 

## About the data

The data comes from the [US Census Bureau](https://www.census.gov/) [American Community Survey](https://www.census.gov/programs-surveys/acs), 5-year estimates from 2019-2023. This is the most reliable and most recent data available on languages spoken at home in the US. This data is collected using the following questions:

![Image](/www/language_600_q14.avif)

The US Census Bureau reports 130 language categories, including 105 individual languages (e.g.: Spanish, Hawaiian) and 25 aggregated language categories (e.g. Other Malayo-Polynesian languages, Aleut languages. 

Where age information is given, ages were divided into three categories: Youth (age 5-17), Working Age (18-64), and Senior (65-99). Data for individuals under age 5 and above age 99 are not provided by the US Census Bureau. 

Where Ability to Speak English is given, this data is self-reported in part C of the question shown above.


## How to use the files in this repository to recreate our demo:
1) Use `tract_level_app_processing.R` with `tract_level_19_23_data.feather` (in the data folder) to generate the rather large `county_data.gpkg` and `tract_data.gpkg` files.

2) Use app.R to run the app. You will need to have the two `.gpkg` files from the previous step.

## Project funding

This project is funded under the National Science Foundation INCLUDES Alliance HRD-2217242
“Alliance Supporting Pacific Impact through Computational Excellence”
![Image](/www/SpiceLogo1.png)


