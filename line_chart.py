import matplotlib.pyplot as plt
import pandas as pd
from datetime import date
import datetime

today = date.today()
t1 = today.strftime("%m%d%Y")

path = 'C:\\Users\\605819\\Desktop\\ActiveThread\\' + t1
csv_path = path + '\\a.csv'



#Reading the input CSV
col_names= ['ExternalServerAT','InternalServerAT','Time','Total']
data = pd.read_csv(csv_path, names=col_names)

#Gathering the data from CSV to be plotted on the graph
internal_thread_count = list(map(int,data.InternalServerAT.tolist()[1:]))
external_thread_count= list(map(int,data.ExternalServerAT.tolist()[1:]))
total_thread_count=list(map(int,data.Total.tolist()[1:]))
x_axis = list(map(int,data.Time.tolist()[1:]))

'''
print (x_axis)
print(internal_thread_count)
print(external_thread_count)
print(total_thread_count)
'''

#Plotting the graph
plt.plot(x_axis, internal_thread_count,label='Internal Thread')
plt.plot(x_axis, external_thread_count,label='External Thread')
plt.plot(x_axis, total_thread_count,label='Total Thread')

#Labeling the x and y axis
plt.xlabel('Time (in hrs)')
plt.ylabel('Active Threads')
plt.title('Active Thread Counts')
plt.legend()

#Saving the graph(everytime it executes,it replaces existing png file)

image_path = path + '\ActiveThreadGraph.png'
plt.savefig(image_path)


