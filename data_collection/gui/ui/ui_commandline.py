# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'commandline.ui'
#
# Created: Thu Aug 13 15:43:12 2015
#      by: PyQt4 UI code generator 4.10.4
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    def _fromUtf8(s):
        return s

try:
    _encoding = QtGui.QApplication.UnicodeUTF8
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)
except AttributeError:
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)

class Ui_CommandLine(object):
    def setupUi(self, CommandLine):
        CommandLine.setObjectName(_fromUtf8("CommandLine"))
        CommandLine.resize(577, 232)
        CommandLine.setFeatures(QtGui.QDockWidget.DockWidgetFloatable|QtGui.QDockWidget.DockWidgetMovable)

        self.dockWidgetContents = QtGui.QWidget()
        self.dockWidgetContents.setObjectName(_fromUtf8("dockWidgetContents"))
        self.verticalLayout = QtGui.QVBoxLayout(self.dockWidgetContents)
        self.verticalLayout.setObjectName(_fromUtf8("verticalLayout"))

        self.cmdHist = QtGui.QTextEdit(self.dockWidgetContents)
        self.cmdHist.setFocusPolicy(QtCore.Qt.WheelFocus)
        self.cmdHist.setLineWrapMode(QtGui.QTextEdit.NoWrap)
        self.cmdHist.setTextInteractionFlags(QtCore.Qt.TextBrowserInteraction)
        self.cmdHist.setObjectName(_fromUtf8("cmdHist"))
        self.verticalLayout.addWidget(self.cmdHist)

        self.gridLayout = QtGui.QGridLayout()
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))

        self.cmdEntry = QtGui.QLineEdit(self.dockWidgetContents)
        self.cmdEntry.setObjectName(_fromUtf8("cmdEntry"))
        self.gridLayout.addWidget(self.cmdEntry, 0, 0, 1, 4)

        self.runButton = QtGui.QPushButton(self.dockWidgetContents)
        self.runButton.setObjectName(_fromUtf8("runButton"))
        self.gridLayout.addWidget(self.runButton, 0, 4, 1, 1)

        self.execButton = QtGui.QPushButton(self.dockWidgetContents)
        self.execButton.setObjectName(_fromUtf8("execButton"))
        self.gridLayout.addWidget(self.execButton, 1, 4, 1, 1)

        self.saveButton = QtGui.QPushButton(self.dockWidgetContents)
        self.saveButton.setObjectName(_fromUtf8("saveButton"))
        self.gridLayout.addWidget(self.saveButton, 1, 3, 1, 1)

        self.clearButton = QtGui.QPushButton(self.dockWidgetContents)
        self.clearButton.setObjectName(_fromUtf8("clearButton"))
        self.gridLayout.addWidget(self.clearButton, 1, 2, 1, 1)

        spacerItem = QtGui.QSpacerItem(40, 20, QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Minimum)
        self.gridLayout.addItem(spacerItem, 1, 0, 1, 1)
        self.verticalLayout.addLayout(self.gridLayout)
        
        CommandLine.setWidget(self.dockWidgetContents)

        self.retranslateUi(CommandLine)
        QtCore.QObject.connect(self.cmdEntry, QtCore.SIGNAL(_fromUtf8("returnPressed()")), self.runButton.animateClick)
        QtCore.QMetaObject.connectSlotsByName(CommandLine)

    def retranslateUi(self, CommandLine):
        CommandLine.setWindowTitle(_translate("CommandLine", "Command Window", None))
        self.runButton.setText(_translate("CommandLine", "Run", None))
        self.execButton.setText(_translate("CommandLine", "Exec script", None))
        self.saveButton.setText(_translate("CommandLine", "Save Log", None))
        self.clearButton.setText(_translate("CommandLine", "Clear", None))

