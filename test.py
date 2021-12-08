
import numpy

import ROOT

# test printing an empty canvas
#   ROOT can still be built but not have a fully functional graphics lib
ROOT.gROOT.SetBatch(1)
c = ROOT.TCanvas('c','Test Canvas')
c.SaveAs('/tmp/test.png')
import os, sys
if not os.path.exists('/tmp/test.png') :
    print('Could not print an empty canvas in ROOT.')
    sys.exit(1)

import uproot

import matplotlib
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import pyplot

import xgboost

import sklearn
from sklearn import datasets
from sklearn.datasets import make_blobs
from sklearn.naive_bayes import GaussianNB
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import LinearSVC
from sklearn.calibration import calibration_curve
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis

