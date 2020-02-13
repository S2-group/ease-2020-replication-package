import json
import glob, os
import sys
import random

if len(sys.argv) < 2:
    print "Not enough arguments. Indicate path of directory with json files."
    exit()

webpages = {}
webpages["Good"] = []
webpages["Average"] = []
webpages["Poor"] = []

os.chdir(sys.argv[1])

for file in glob.glob("*.json"):
    print(file)
    with open(file, 'r') as f:
        lighthouse_object = json.load(f)
    url = lighthouse_object['requestedUrl']
    score = lighthouse_object['categories']['performance']['score']
    if score is not None:
        if score >= 0.75:
            webpages["Good"].append((url,score))
        elif score < 0.75 and score >= 0.45:
            webpages["Average"].append((url,score))
        elif score < 0.45:
            webpages["Poor"].append((url,score))


categories = ["Good","Average","Poor"]

output_file = open("categories.txt","w")
for category in categories:
    output_file.write("Category: ")
    output_file.write(category)
    output_file.write("\n")
    print "Category ",category

    for webpage in webpages[category]:
        if webpage[1] is not None:
            output_file.write(webpage[0])
            output_file.write(",")
            output_file.write(str(webpage[1]))
            output_file.write("\n")
            print webpage[0],",",float(webpage[1])

    output_file.write("\n")

output_file.write("---------------------------------\n")

for category in categories:
    output_file.write("Category: ")
    output_file.write(category)
    output_file.write("\n")
    print "Category ",category
    for webpage in random.sample(webpages[category],7):
        if webpage[1] is not None:
            print webpage[0],",",float(webpage[1])
            output_file.write(webpage[0])
            output_file.write(",")
            output_file.write(str(webpage[1]))
            output_file.write("\n")
    print "\n"
output_file.close()
