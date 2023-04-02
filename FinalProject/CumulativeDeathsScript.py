import csv

countries = [];
with open('countryIDs.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        countries.append(row['NAME'])

csvfile.close()

print()

i = 0
# while(i<len(countries)):
#     print(countries[i])
#     i+=1

count = dict()
yearprocessed = "1950";
newFile = []
country = ''
sum = 0
line = []

with open('Significant Earthquake Database.csv') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        if (row['Year']==yearprocessed): #counting year over year
           if(row['Earthquake : Deaths']!=""): #If there are deaths in that year
               country = row['Country']
               if(country in count.keys()): #If this is not the first death that occurred in that year
                   sum = count[country]
               else:
                   sum = 0
               count[country] = int(sum) + int(row["Earthquake : Deaths"])
        else: #Moved to new year
            for i in range(len(countries)):
                name = countries[i].upper()
                if name in count.keys():
                    newFile.append([yearprocessed, countries[i], count[name]])
                else:
                    newFile.append([yearprocessed, countries[i], 0])

            yearprocessed = row['Year']
        ##Process this entry so we don't miss it
            if (row['Earthquake : Deaths'] != ""):  # If there are deaths in that year
                country = row['Country']
                if (country in count.keys()):  # If this is not the first death that occurred in that year
                    sum = count[country]
                else:
                    sum = 0
                count[country] = int(sum) + int(row["Earthquake : Deaths"])

csvfile.close()

fields = ["Year", "Country", "CumulDeaths"]
output = 'CumDeathsbyCountry.csv'

with open(output, 'w', newline='') as csvfile:
    # creating a csv writer object
    csvwriter = csv.writer(csvfile)

    # writing the fields
    csvwriter.writerow(fields)

    # writing the data rows
    csvwriter.writerows(newFile)


csvfile.close()
