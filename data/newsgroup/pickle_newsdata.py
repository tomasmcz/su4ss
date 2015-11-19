import numpy as np
from scipy.sparse import lil_matrix, vstack
import joblib
import sys

feature_count = 4000
X = []
X_bin = []
y = []
f_data = open('newsgroup.data')

i = 0
for line in f_data:
    tokenized_line = line.split(",")
    i += 1
    sys.stdout.write(str(i)+"\r")
    x = lil_matrix((1,feature_count))
    x_bin = lil_matrix((1,feature_count))
    for t in tokenized_line[:-2]:
        index, count = t.split(":")
        x_bin[0,int(index)] = 1
        x[0,int(index)] = count
    X_bin.append(x_bin)
    X.append(x)
    y.append(tokenized_line[-2])
f_data.close()
sys.stdout.write("Pickling ... ")

X_bin_train = vstack(X_bin[:15000]).tolil()
X_train = vstack(X[:15000]).tolil()
y_train = y[:15000]

X_bin_test = vstack(X_bin[15000:]).tolil()
X_test = vstack(X[15000:]).tolil()
y_test = y[15000:]

joblib.dump((X_bin_train, y_train, X_bin_test, y_test), 
            "newsgroup-bin.pickle", compress=3)
joblib.dump((X_train, y_train, X_test, y_test), 
            "newsgroup.pickle", compress=3)
sys.stdout.write("done\n")
