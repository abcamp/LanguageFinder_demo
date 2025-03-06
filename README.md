# LanguageFinder (demo version)

The purpose of this project is to build a LanguageFinder web application that will be free to access and easy to use. 

## Find out which languages other than English are spoken in particular places.
Translations and interpretation services are key tools to increase accessibility to information. Access to information is especially important in relation to:

1) Disaster warnings and disaster response;
2) Healthcare, especially treatment options and recovery instructions;
3) Local government engagement;
4) Environmental justice; 
5) Workplace safety


## See how many people speak a particular language in different places.
1) Understanding how speakers of a certain language are distributed across the U.S. can help organizations find collaborative partners in creating translations and interpretive services for that language.

2) Organizations that serve particular language communities can use this information to identify key service areas.


## How to use the files in this repository to recreate our demo:
1) Use `tract_level_app_processing.R` with `tract_level_19_23_data.feather` (in the data folder) to generate the rather large `county_data.gpkg` and `tract_data.gpkg` files.

2) Use app.R to run the app. You will need to have the two `.gpkg` files from the previous step. 
