# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'ui/HyperFlexGUI.ui'
#
# Created by: PyQt4 UI code generator 4.11.4
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

class Ui_HyperFlexGUI(object):
    def setupUi(self, HyperFlexGUI):
        HyperFlexGUI.setObjectName(_fromUtf8("HyperFlexGUI"))
        
        # Data visualizer stuff
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(HyperFlexGUI.sizePolicy().hasHeightForWidth())
        HyperFlexGUI.setSizePolicy(sizePolicy)
        
        self.dockWidgetContents = QtGui.QWidget()
        self.dockWidgetContents.setObjectName(_fromUtf8("dockWidgetContents"))
        self.gridLayout = QtGui.QGridLayout(self.dockWidgetContents)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))

        # DATA VISUALIZATION:

        # main plot windows
        self.plot = GraphicsLayoutWidget(self.dockWidgetContents)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.plot.sizePolicy().hasHeightForWidth())
        self.plot.setSizePolicy(sizePolicy)
        self.plot.setFocusPolicy(QtCore.Qt.StrongFocus)
        self.plot.setObjectName(_fromUtf8("plot"))
        self.gridLayout.addWidget(self.plot, 0, 0, 10, 5)

        # button to start streaming
        self.streamBtn = QtGui.QPushButton(self.dockWidgetContents)
        self.streamBtn.setCheckable(True)
        self.streamBtn.setObjectName(_fromUtf8("streamBtn"))
        self.gridLayout.addWidget(self.streamBtn, 10, 0, 1, 1)
        
        # button to clear plots
        self.clearBtn = QtGui.QPushButton(self.dockWidgetContents)
        self.clearBtn.setObjectName(_fromUtf8("clearBtn"))
        self.gridLayout.addWidget(self.clearBtn, 10, 1, 1, 1)

        # check box to enable/disable autorange of plots
        self.autorange = QtGui.QCheckBox(self.dockWidgetContents)
        self.autorange.setObjectName(_fromUtf8("autorange"))
        self.gridLayout.addWidget(self.autorange, 10, 2, 1, 1)

        # # selection of plot x-axis range
        # self.xRangeLabel = QtGui.QLabel(self.dockWidgetContents)
        # self.xRangeLabel.setAlignment(QtCore.Qt.AlignRight|QtCore.Qt.AlignTrailing|QtCore.Qt.AlignVCenter)
        # self.xRangeLabel.setObjectName(_fromUtf8("xRangeLabel"))
        # self.gridLayout.addWidget(self.xRangeLabel, 10, 3, 1, 1)
        # self.xRange = QtGui.QSpinBox(self.dockWidgetContents)
        # self.xRange.setMinimum(1)
        # self.xRange.setMaximum(50000)
        # self.xRange.setSingleStep(1000)
        # self.xRange.setProperty("value", 2000)
        # self.xRange.setObjectName(_fromUtf8("xRange"))
        # self.gridLayout.addWidget(self.xRange, 10, 4, 1, 1)

        # enable plotting streamed data
        self.dispStream = QtGui.QCheckBox(self.dockWidgetContents)
        self.dispStream.setObjectName(_fromUtf8("dispStream"))
        self.gridLayout.addWidget(self.dispStream, 11, 0, 1, 1)

        # channels to display
        self.ch0 = QtGui.QSpinBox(self.dockWidgetContents)
        self.ch0.setMinimum(0)
        # self.ch0.setMaximum(68)
        self.ch0.setMaximum(66)
        self.ch0.setSingleStep(1)
        self.ch0.setProperty("value", 0)
        self.ch0.setObjectName(_fromUtf8("ch0"))
        self.gridLayout.addWidget(self.ch0, 11, 1, 1, 1)

        self.ch1 = QtGui.QSpinBox(self.dockWidgetContents)
        self.ch1.setMinimum(0)
        # self.ch0.setMaximum(68)
        self.ch0.setMaximum(66)
        self.ch1.setSingleStep(1)
        self.ch1.setProperty("value", 1)
        self.ch1.setObjectName(_fromUtf8("ch1"))
        self.gridLayout.addWidget(self.ch1, 11, 2, 1, 1)

        self.ch2 = QtGui.QSpinBox(self.dockWidgetContents)
        self.ch2.setMinimum(0)
        # self.ch0.setMaximum(68)
        self.ch0.setMaximum(66)
        self.ch2.setSingleStep(1)
        self.ch2.setProperty("value", 2)
        self.ch2.setObjectName(_fromUtf8("ch2"))
        self.gridLayout.addWidget(self.ch2, 11, 3, 1, 1)

        self.ch3 = QtGui.QSpinBox(self.dockWidgetContents)
        self.ch3.setMinimum(0)
        # self.ch0.setMaximum(68)
        self.ch0.setMaximum(66)
        self.ch3.setSingleStep(1)
        self.ch3.setProperty("value", 3)
        self.ch3.setObjectName(_fromUtf8("ch3"))
        self.gridLayout.addWidget(self.ch3, 11, 4, 1, 1)

        # effort level bar graph
        self.effortLabel = QtGui.QLabel(self.dockWidgetContents)
        self.effortLabel.setAlignment(QtCore.Qt.AlignRight|QtCore.Qt.AlignTrailing|QtCore.Qt.AlignVCenter)
        self.effortLabel.setObjectName(_fromUtf8("effortLabel"))
        self.gridLayout.addWidget(self.effortLabel, 12, 0, 1, 1) 
        self.effort = QtGui.QProgressBar(self.dockWidgetContents)
        self.effort.setObjectName(_fromUtf8("effort"))
        self.effort.setMinimum(0)
        self.effort.setMaximum(1000)
        self.effort.setValue(500)
        self.gridLayout.addWidget(self.effort, 12, 1, 1, 4)

        # target indicator for effort level
        self.targetLabel = QtGui.QLabel(self.dockWidgetContents)
        self.targetLabel.setAlignment(QtCore.Qt.AlignRight|QtCore.Qt.AlignTrailing|QtCore.Qt.AlignVCenter)
        self.targetLabel.setObjectName(_fromUtf8("targetLabel"))
        self.gridLayout.addWidget(self.targetLabel, 13, 0, 1, 1) 
        self.target = QtGui.QSlider(QtCore.Qt.Horizontal)
        self.target.setObjectName(_fromUtf8("target"))
        self.target.setTickPosition(QtGui.QSlider.TicksBelow)
        self.target.setMinimum(0)
        self.target.setMaximum(1000)
        self.target.setTickInterval(100)
        self.target.setValue(500)
        self.gridLayout.addWidget(self.target, 13, 1, 1, 4)

        # linear mapping for effort
        self.mLabel = QtGui.QLabel(self.dockWidgetContents)
        self.mLabel.setAlignment(QtCore.Qt.AlignRight|QtCore.Qt.AlignTrailing|QtCore.Qt.AlignVCenter)
        self.mLabel.setObjectName(_fromUtf8("mLabel"))
        self.gridLayout.addWidget(self.mLabel, 14, 1, 1, 1)
        self.m = QtGui.QSpinBox(self.dockWidgetContents)
        self.m.setMinimum(-10000)
        self.m.setMaximum(10000)
        self.m.setSingleStep(1)
        self.m.setProperty("value", 300)
        self.m.setObjectName(_fromUtf8("m"))
        self.gridLayout.addWidget(self.m, 14, 2, 1, 1)

        self.bLabel = QtGui.QLabel(self.dockWidgetContents)
        self.bLabel.setAlignment(QtCore.Qt.AlignRight|QtCore.Qt.AlignTrailing|QtCore.Qt.AlignVCenter)
        self.bLabel.setObjectName(_fromUtf8("bLabel"))
        self.gridLayout.addWidget(self.bLabel, 14, 3, 1, 1)
        self.b = QtGui.QSpinBox(self.dockWidgetContents)
        self.b.setMinimum(-10000)
        self.b.setMaximum(10000)
        self.b.setSingleStep(1)
        self.b.setProperty("value", -500)
        self.b.setObjectName(_fromUtf8("b"))
        self.gridLayout.addWidget(self.b, 14, 4, 1, 1)

        # GESTURE SETUP:

        # gesture instruction message
        self.message = QtGui.QLabel(self.dockWidgetContents)
        font = QtGui.QFont()
        font.setFamily(_fromUtf8("Helvetica"))
        font.setPointSize(40)
        self.message.setFont(font)
        self.message.setAlignment(QtCore.Qt.AlignLeft|QtCore.Qt.AlignVCenter)
        self.message.setObjectName(_fromUtf8("message"))
        self.gridLayout.addWidget(self.message, 0, 5, 2, 6)

        # gesture instruction image
        self.image = QtGui.QLabel(self.dockWidgetContents)
        self.image.setObjectName(_fromUtf8("image"))
        self.gridLayout.addWidget(self.image, 2, 7, 8, 4)

        # gesture instruction image
        self.posImage = QtGui.QLabel(self.dockWidgetContents)
        self.posImage.setObjectName(_fromUtf8("posImage"))
        self.gridLayout.addWidget(self.posImage, 2, 5, 8, 2)

        # gesture
        self.gestureSetsLabel = QtGui.QLabel(self.dockWidgetContents)
        self.gestureSetsLabel.setObjectName(_fromUtf8("gestureSetsLabel"))
        self.gridLayout.addWidget(self.gestureSetsLabel, 10, 5, 1, 1)
        self.gestureSets = QtGui.QComboBox(self.dockWidgetContents)
        self.gestureSets.setObjectName(_fromUtf8("gestureSets"))
        self.gridLayout.addWidget(self.gestureSets, 11, 5, 1, 1)

        # position
        self.positionLabel = QtGui.QLabel(self.dockWidgetContents)
        self.positionLabel.setObjectName(_fromUtf8("positionLabel"))
        self.gridLayout.addWidget(self.positionLabel, 10, 6, 1, 1)
        self.position = QtGui.QComboBox(self.dockWidgetContents)
        self.position.setObjectName(_fromUtf8("position"))
        self.gridLayout.addWidget(self.position, 11, 6, 1, 1)

        # gesture repetitions
        self.numRepsLabel = QtGui.QLabel(self.dockWidgetContents)
        self.numRepsLabel.setObjectName(_fromUtf8("numRepsLabel"))
        self.gridLayout.addWidget(self.numRepsLabel, 10, 7, 1, 1)
        self.numReps = QtGui.QSpinBox(self.dockWidgetContents)
        self.numReps.setMinimum(1)
        self.numReps.setMaximum(20)
        self.numReps.setSingleStep(1)
        self.numReps.setProperty("value", 5)
        self.numReps.setObjectName(_fromUtf8("numReps"))
        self.gridLayout.addWidget(self.numReps, 11, 7, 1, 1)

        # gesture length
        self.timeGestLabel = QtGui.QLabel(self.dockWidgetContents)
        self.timeGestLabel.setObjectName(_fromUtf8("timeGestLabel"))
        self.gridLayout.addWidget(self.timeGestLabel, 10, 8, 1, 1)
        self.timeGest = QtGui.QSpinBox(self.dockWidgetContents)
        self.timeGest.setMinimum(0)
        self.timeGest.setMaximum(50)
        self.timeGest.setSingleStep(1)
        self.timeGest.setProperty("value", 4)
        self.timeGest.setObjectName(_fromUtf8("timeGest"))
        self.gridLayout.addWidget(self.timeGest, 11, 8, 1, 1)

        # relax length
        self.timeRelaxLabel = QtGui.QLabel(self.dockWidgetContents)
        self.timeRelaxLabel.setObjectName(_fromUtf8("timeRelaxLabel"))
        self.gridLayout.addWidget(self.timeRelaxLabel, 10, 9, 1, 1)
        self.timeRelax = QtGui.QSpinBox(self.dockWidgetContents)
        self.timeRelax.setMinimum(0)
        self.timeRelax.setMaximum(10)
        self.timeRelax.setSingleStep(1)
        self.timeRelax.setProperty("value", 3)
        self.timeRelax.setObjectName(_fromUtf8("timeRelax"))
        self.gridLayout.addWidget(self.timeRelax, 11, 9, 1, 1)

        # transition length
        self.timeTransLabel = QtGui.QLabel(self.dockWidgetContents)
        self.timeTransLabel.setObjectName(_fromUtf8("timeTransLabel"))
        self.gridLayout.addWidget(self.timeTransLabel, 10, 10, 1, 1)
        self.timeTrans = QtGui.QSpinBox(self.dockWidgetContents)
        self.timeTrans.setMinimum(0)
        self.timeTrans.setMaximum(10)
        self.timeTrans.setSingleStep(1)
        self.timeTrans.setProperty("value", 2)
        self.timeTrans.setObjectName(_fromUtf8("timeTrans"))
        self.gridLayout.addWidget(self.timeTrans, 11, 10, 1, 1)

        # subject number
        self.subIndLabel = QtGui.QLabel(self.dockWidgetContents)
        self.subIndLabel.setObjectName(_fromUtf8("subIndLabel"))
        self.gridLayout.addWidget(self.subIndLabel, 12, 5, 1, 1)
        self.subInd = QtGui.QSpinBox(self.dockWidgetContents)
        self.subInd.setMinimum(1)
        self.subInd.setMaximum(100)
        self.subInd.setSingleStep(1)
        self.subInd.setProperty("value", 1)
        self.subInd.setObjectName(_fromUtf8("subInd"))
        self.gridLayout.addWidget(self.subInd, 12, 6, 1, 1)

        # experiment number
        self.expIndLabel = QtGui.QLabel(self.dockWidgetContents)
        self.expIndLabel.setObjectName(_fromUtf8("expIndLabel"))
        self.gridLayout.addWidget(self.expIndLabel, 12, 7, 1, 1)
        self.expInd = QtGui.QSpinBox(self.dockWidgetContents)
        self.expInd.setMinimum(1)
        self.expInd.setMaximum(100)
        self.expInd.setSingleStep(1)
        self.expInd.setProperty("value", 1)
        self.expInd.setObjectName(_fromUtf8("expInd"))
        self.gridLayout.addWidget(self.expInd, 12, 8, 1, 1)

        # enable saving data
        self.saveData = QtGui.QCheckBox(self.dockWidgetContents)
        self.saveData.setObjectName(_fromUtf8("saveData"))
        self.gridLayout.addWidget(self.saveData, 12, 9, 1, 1)
        self.saveData.setChecked(False)

        # disable wide-input mode
        self.wideDisable = QtGui.QPushButton(self.dockWidgetContents)
        self.wideDisable.setObjectName(_fromUtf8("wideDisable"))
        self.gridLayout.addWidget(self.wideDisable, 12, 10, 1, 1)

        # textbox for description of saved data
        self.descriptionLabel = QtGui.QLabel(self.dockWidgetContents)
        self.descriptionLabel.setObjectName(_fromUtf8("descriptionLabel"))
        self.gridLayout.addWidget(self.descriptionLabel, 13, 5, 1, 1)
        self.description = QtGui.QLineEdit(self.dockWidgetContents)
        self.description.setObjectName(_fromUtf8("description"))
        self.gridLayout.addWidget(self.description, 13, 6, 1, 5)

        # hdc mode
        self.hdModeLabel = QtGui.QLabel(self.dockWidgetContents)
        self.hdModeLabel.setObjectName(_fromUtf8("hdModeLabel"))
        self.gridLayout.addWidget(self.hdModeLabel, 14, 5, 1, 1)
        self.hdMode = QtGui.QComboBox(self.dockWidgetContents)
        self.hdMode.setObjectName(_fromUtf8("hdMode"))
        self.gridLayout.addWidget(self.hdMode, 14, 6, 1, 2)

        HyperFlexGUI.setWidget(self.dockWidgetContents)

        self.retranslateUi(HyperFlexGUI)
        QtCore.QMetaObject.connectSlotsByName(HyperFlexGUI)
        self.dispStream.setProperty("checked", True)

    def retranslateUi(self, HyperFlexGUI):
        HyperFlexGUI.setWindowTitle(_translate("HyperFlexGUI", "ADC Control", None))
        self.streamBtn.setText(_translate("HyperFlexGUI", "Stream Data", None))
        self.clearBtn.setText(_translate("HyperFlexGUI", "Clear plots", None))
        self.autorange.setText(_translate("HyperFlexGUI", "Autorange", None))
        # self.xRangeLabel.setText(_translate("HyperFlexGUI", "X-axis range (ms):", None))
        self.dispStream.setText(_translate("HyperFlexGUI", "Display stream data from Ch:", None))
        self.effortLabel.setText(_translate("HyperFlexGUI", "Effort Level: ", None))
        self.targetLabel.setText(_translate("HyperFlexGUI", "Target: ", None))
        self.mLabel.setText(_translate("HyperFlexGUI", "Multiplier: ", None))
        self.bLabel.setText(_translate("HyperFlexGUI", "Offset: ", None))

        self.gestureSetsLabel.setText(_translate("Experiment", "Gesture:", None))
        self.positionLabel.setText(_translate("Experiment", "Arm Position:", None))
        self.numRepsLabel.setText(_translate("Experiment", "Repetitions:", None))
        self.timeGestLabel.setText(_translate("Experiment", "Gesture Length (s):", None))
        self.timeRelaxLabel.setText(_translate("Experiment", "Relax Length (s):", None))
        self.timeTransLabel.setText(_translate("Experiment", "Transition Length (s):", None))
        self.subIndLabel.setText(_translate("Experiment", "Subject:", None))
        self.expIndLabel.setText(_translate("Experiment", "Experiment #:", None))
        self.descriptionLabel.setText(_translate("Experiment", "Description:", None))
        self.saveData.setText(_translate("Experiment", "Save Data", None))
        self.message.setText("Current gesture\nNext gesture in 5")
        self.wideDisable.setText(_translate("Experiment", "Disable Wide In", None))
        self.hdModeLabel.setText(_translate("Experiment", "HD Mode", None))


from pyqtgraph import GraphicsLayoutWidget
