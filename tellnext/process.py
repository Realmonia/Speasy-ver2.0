import sys
text = ''
with open(sys.argv[1]) as f:
    for line in f:
        #line = line.replace(' __eou__', '')
        line = line.replace('?', '')
        line = line.replace('.', '')
        line = line.replace(',', '')
        line = line.replace('!', '')
        text += line.lower()

with open(sys.argv[1]+'out.txt', 'w') as f:
    f.write(text)