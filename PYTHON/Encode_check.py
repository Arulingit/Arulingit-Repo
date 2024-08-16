import chardet
with open (r'C:\Users\akubendran\AWS\T011.csv', 'rb') as f:
    result = chardet.detect(f.read())
    encoding1 = result['encoding']
print("Detected Encoding :",encoding1)

with open(r'C:\Users\akubendran\AWS\T011.csv', 'r', encoding=encoding1,errors='replace') as f:
    content = f.read()
print ("Readed")  
with open (r'C:\Users\akubendran\AWS\T011w.csv', 'w', encoding='utf-16') as f:
    f.write(content)
print ("writed")

with open (r'C:\Users\akubendran\AWS\T011w.csv', 'rb') as f:
    result = chardet.detect(f.read())
    encoding1 = result['encoding']
print("Detected Encoding :",encoding1)
