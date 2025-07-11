import urllib.request
from bs4 import BeautifulSoup
from xml.etree.ElementTree import Element, SubElement, ElementTree
import sys

search_term = (sys.argv[1])
base='https://eutils.ncbi.nlm.nih.gov/entrez/eutils/'
query_url=base+"esearch.fcgi?db=biosample&term={}&usehistory=y".format(search_term)

data = urllib.request.urlopen(query_url)
xml=data.read()
soup=BeautifulSoup(xml, "xml")

QueryKey=soup.find("QueryKey").text
WebEnv=soup.find("WebEnv").text

query_url=base+"esummary.fcgi?db=biosample&query_key={}&WebEnv={}&RetMax=10000&rettype=abstract&retmode=text&idtype=acc".format(QueryKey,WebEnv)
data = urllib.request.urlopen(query_url)
xml=data.read()
soup=BeautifulSoup(xml, "xml")
out = list(soup)
with open("SAMN_info_tmp", mode="w") as f:
    for i in out:
        f.write(str(i)+"\n")

