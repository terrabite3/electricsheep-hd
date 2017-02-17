from lxml import html
import requests
import os
import re

base_addr = 'http://v3d0.sheepserver.net/'

page = requests.get(base_addr + 'cgi/best.cgi?p=0&menu=best')
tree = html.fromstring(page.content)

generation = tree.findtext('.//title')

for row in range(1, 33):
    for col in range(1, 9):
        sheep = tree.xpath('/html/body/table/tr[2]/td/table/tr[2]/td/table[2]/tr[' + str(row) + ']/td[' + str(col) + ']/a')
        href = sheep[0].attrib['href']

        sheep_id = re.search('\d+', href).group(0)

        filename = 'electricsheep.{0}.{1:05}.flam3'.format(generation, int(sheep_id))
        file_href = 'gen/' + generation + '/' + sheep_id + '/' + filename

        flam3_file = requests.get(base_addr + file_href)

        with open(filename, 'wb') as f:
            f.write(flam3_file.content)



