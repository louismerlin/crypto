import imp

def get_parameters():
    f = open("247565-parameters.txt")
    d = imp.load_source('d', '', f)
    f.close()
    return d