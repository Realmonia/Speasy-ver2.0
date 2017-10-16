
text = ''
with open('dialogues_text.txt') as f:
    for line in f:
        #line = line.replace(' __eou__', '')
        line = line.replace(' ?', '')
        line = line.replace(' .', '')
        line = line.replace(' ,', '')
        line = line.replace(' !', '')
        text += line.lower()

with open('out.txt', 'w') as f:
    f.write(text)