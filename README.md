#  EASE 2020 - Replication package
This repository contains the replication package of the paper titled **Investigating the correlation between performance scores and energy consumption of mobile web apps** published at [EASE 2020](https://www.ntnu.edu/web/ease2020)

This study has been designed, developed, and reported by the following investigators: 
- Kwame Chan-Jong-Chu (Vrije Universiteit Amsterdam)
- Tanjina Islam (Vrije Universiteit Amsterdam)
- Miguel Morales Exposito (Vrije Universiteit Amsterdam)
- Sanjay Sheombar (Vrije Universiteit Amsterdam)
- Christian Valladares (Vrije Universiteit Amsterdam)
- Olivier Philippot (Greenspector)
- Eoin Martino Grua (Vrije Universiteit Amsterdam)
- Ivano Malavolta (Vrije Universiteit Amsterdam)

For any information, interested researchers can contact [Ivano Malavolta](https://www.ivanomalavolta.com).
The full dataset including raw data, mining scripts, and analysis scripts produced during the study are available below.

## How to cite us
The scientific article describing design, execution, and main results of this study is available [here](./EASE_2020.pdf). 
If this study is helping your research, consider to cite it is as follows, thanks!

```
@inproceedings{EASE_2020,
  url = { http://www.ivanomalavolta.com/files/papers/EASE_2020.pdf },
  year = { 2020 },
  publisher = { ACM },
  pages = { to appear },
  number = { Preprint },
  booktitle = { Proceedings of the International Conference on Evaluation and Assessment on Software Engineering (EASE) },
  author = { Kwame {Chan Jong Chu} and Tanjina Islam {Miguel Morales} Exposito and Sanjay Sheombar and Christian Valladares and Olivier Philippot and {Eoin Martino} Grua and Ivano Malavolta },
  title = { Investigating the correlation between performance scores and energy consumption of mobile web apps },
}
```

## Overview of the replication package

### Subjects selection

For the subject selection we picked the first 100 web apps from the top 1 million Alexa list: (`Alexa-top-1m.csv`) with different domain extensions. To do it we used the script `random_website.py`, which can be executed by running the following command in the terminal: 
`python2 random_website.py` 

The file `Alexa-top-1m.csv` must be in the same directory as the script. The output of this script is in `websites.txt`.

We used Lighthouse-batch to get the JSON files with the report of Lighthouse from the `websites.txt` list. These JSON files are in the folder called *Lighthouse JSON*. 

From those 100 web apps we obtained the 21 web apps we were going to finally use for our experiment. We used the script: `get_categories.py` for achieving this, which can be executed by running the following command in the terminal: 
`python2 get_categories.py <directory_with_JSON_files>`

The script categorizes the web apps into *good*, *poor*, or *average* based on the performance score, and randomly picks 7 subjects from each category. The outcome of this script that we used is in `categories.txt`. 

### Energy measurement

To measure the energy consumption of web apps we use a power and performance profiling solution called Greenspector. Thanks to the energy-related information provided by the Android system, Greenspector can provide energy metrics and other information such as CPU usage, data usage, etc. For each device managed by Greenspector, a calibration process is run to give a probe trust level. This level takes into account the stability of the measure and the frequency. For the HTC Nexus 9 used in our study, the trust level is 8 on 10 (Calibration on a small range and precise measure). To get a better indication of the energy consumed by each web app, we consider the reference power consumption value provided by Greenspector, which removes the battery drainage caused by the Android operating system and the Trepn profiler itself. The reference Power consumption is obtained by measuring the system with a browser opened on a blank screen.

For orchestrating the execution of all the runs of the experiment we make use of Android Tests developed in [UIAUtomator](https://developer.android.com/training/testing/ui-automator). Greenspector is integrated as an API in these tests. Tests are run with Greenspector Testrunner, wich permit to communicate via ADB over WiFI with the Nexus 9 tablet running Android 7.1.1. In our experiment, Testrunner is executed on a laptop with Linux Mint 19 Cinnamon 3.8.9, Intel i5-5200U and 16GB RAM. Web apps are run within the Google Chrome browser (version 54.0.2840.85). 

With the laptop connected to the Nexus 9, all the web apps are automatically loaded by the test in the Google Chrome app running on the device, while their energy consumption is measured via Greenspector. Both the laptop and the Nexus 9 tablet run under the same WiFi network with a speed of 100 Mbps. To ensure that the WiFi conditions do not alter the results of the experiment, the Nexus 9 and the laptop are always placed 5 meters from the WiFi router. Further, we take special care in keeping the execution environment as clean as possible, Greenspector Testrunner permit to manage this environment, specifically: the Nexus 9 is loaded with a clean installation of the Android OS, it has been configured so to do not perform any OS updates, Google services have been disabled, all third-party apps have been uninstalled, a whitelist permit to only autorize minimum applications, and push notifications have been disabled. 

In order to take into account the intrinsic variability of energy measurement, we take the following precautions: 
- the measurement of each web app is repeated 30 times 
- between each run the Nexus 9 remains idle for 2 minutes so to take into account tail energy usage, i.e., the phenomenon where where certain hardware components of mobile devices are optimistically kept active by the OS to avoid startup energy costs
- the Google Chrome app is cleared before each run so to reset its cache and persisted data.

### Data Analysis

The input to this phase is the data produced by the Greenspector tool in the file 'energy_measurements.xlsx'. To make the load of information in our R scripts easier, we copied the energy consumption values of each iteration into a CSV file called `measured_energy.csv`.

The data analysis is performed by running the `Experiment_green_inspector.R` R script. To load the energy data, it is needed to specify the absolute path to the `measured_energy_.csv` file in line 104: 
`data <- get_energy_data<(path_to_measured_energy.csv>)`

## License

This software is licensed under the MIT License.

