import imp

def get_parameters(test=False):
    if test:
        f = open("100000-parameters.txt")
    else:
        f = open("247565-parameters.txt")
    d = imp.load_source('d', '', f)
    f.close()
    return d