import csv
import random

class Random_website:

	filename = "Alexa-top-1m.csv"
	websites = []
	selected_websites = []

	def __init__(self):
		with open(self.filename) as input_csv:
			csv_reader = csv.reader(input_csv, delimiter=",")

			count = 0
			for row in csv_reader:
				element = row[1].split('.')

				if len(self.websites) is 0:
					self.websites.append(element)
					count = count + 1
				else:
					isDuplicate = False
					for site in self.websites:
						if site[0] == element[0]:
							isDuplicate = True
							break

					if isDuplicate is False:
						self.websites.append(element)
						count = count + 1

				if count is 100:
					break

	def getRandomNumbers(self):
		random_numbers = []
		while len(random_numbers) != 20:
			r = random.randint(0, len(self.websites) - 1)

			isDuplicate = False
			for element in random_numbers:
				if element == r:
					isDuplicate = True
					break

			if isDuplicate is False:
				random_numbers.append(r)

		return random_numbers

	def generateList(self):
		random_numbers = self.getRandomNumbers()
		f = open('randomly_picked_websites.txt', 'w')
		for r in random_numbers:
			s = "http://www." + self.websites[r][0] + "." + self.websites[r][1]
			print(s)
			f.write(s + "\n")
		f.close()

	def write_list_to_textfile(self):
		f = open('websites.txt', 'w')
		for element in self.websites:
			web_string = "www." + str(element[0]) + "." + str(element[1]) + "\n"
			f.write(web_string)

website_picker = Random_website()
website_picker.write_list_to_textfile()