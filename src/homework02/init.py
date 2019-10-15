import imp
f = open("247565-parameters.txt")
imp.load_source('', '', f)
f.close()