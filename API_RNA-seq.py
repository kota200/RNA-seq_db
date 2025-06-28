import urllib.request
from bs4 import BeautifulSoup
from xml.etree.ElementTree import Element, SubElement, ElementTree
import sys
    
name=sys.argv[1]
search_term = f'{name}[Organism] AND (RNA-seq[All Fields] AND transcriptome[All Fields])'
encoded_term = quote(search_term)
base='https://eutils.ncbi.nlm.nih.gov/entrez/eutils/'
query_url=base+"esearch.fcgi?db=sra&term={}&usehistory=y".format(encoded_term)

data = urllib.request.urlopen(query_url)
xml=data.read()
soup=BeautifulSoup(xml, "xml")

QueryKey=soup.find("QueryKey").text
WebEnv=soup.find("WebEnv").text

query_url=base+"esummary.fcgi?db=sra&query_key={}&WebEnv={}&RetMax=10000&rettype=abstract&retmode=text&idtype=acc".format(QueryKey,WebEnv)
data = urllib.request.urlopen(query_url)
xml=data.read()
soup=BeautifulSoup(xml, "xml")

out = soup.findAll("Item")
out = list(out)
with open("tmp", mode="w") as f:
    for i in out:
        f.write(str(i)+"\n")
