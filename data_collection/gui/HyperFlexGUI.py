from PyQt4.QtCore import *
from PyQt4 import QtCore, QtGui
from PyQt4.QtGui import *
from ui.ui_HyperFlexGUI import Ui_HyperFlexGUI
import numpy as np
import scipy.io as sio
from enum import Enum
import pyqtgraph as pg
import tables
from tables import *
from datetime import datetime
import time
# import QThread
import cmbackend
import csv
from scipy import signal, stats
from gestureDef import gestureNames, gestureGroupNames, gestureGroupMembers, gestureIndices, positionNames
import os

class HyperFlexGUI(QDockWidget):
    
    streamAdc = pyqtSignal()
    wideDisable = pyqtSignal()
    setMdLbl = pyqtSignal(list)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.ui = Ui_HyperFlexGUI()
        self.ui.setupUi(self)

        # plotting variables
        self.data = []  # current set of data to show
        self.numPlots = 4
        # self.xRange = self.ui.xRange.value() # number of ms (samples) over which to plot continuous data
        self.xRange = 2000
        self.plotStart = 0

        # self.dataPlot = np.zeros((self.numPlots, self.ui.xRange.maximum())) # aggregation of data to plot (scrolling style)
        self.dataPlot = np.zeros((self.numPlots, self.xRange)) 
        self.plotPointer = 0 # pointer to current x position in plot (for plotting scrolling style)

        self.plots = [] # stores pyqtgraph objects
        self.plotColors = []
        self.target = 50

        self.plotCh = np.arange(self.numPlots)
        self.plotCh[0] = self.ui.ch0.value()
        self.plotCh[1] = self.ui.ch1.value()
        self.plotCh[2] = self.ui.ch2.value()
        self.plotCh[3] = self.ui.ch3.value()

        # populate arrays
        for i in range(0,self.numPlots):
            self.plots.append(pg.PlotItem().plot())
            self.plotColors.append(pg.intColor(i%16,16))

        self.updatePlotDisplay()

        self.ui.autorange.clicked.connect(self.updatePlotStream)
        # self.ui.xRange.valueChanged.connect(self.updatePlotDisplay)
        self.ui.clearBtn.clicked.connect(self.clearPlots)

        self.ui.ch0.valueChanged.connect(self.updateCh)
        self.ui.ch1.valueChanged.connect(self.updateCh)
        self.ui.ch2.valueChanged.connect(self.updateCh)
        self.ui.ch3.valueChanged.connect(self.updateCh)
        self.ui.target.valueChanged.connect(self.updateTarget)

        # set some defaults
        self.ui.autorange.setChecked(True)

        self.raw = np.zeros((200,64))

        # gestures
        self.gestureList = []
        for key, value in gestureGroupNames.items():
            self.gestureList.append(value)
        self.ui.gestureSets.addItems(self.gestureList)

        # positions
        self.positionList = []
        for key, value in positionNames.items():
            self.positionList.append(value)
        self.ui.position.addItems(self.positionList)

        self.hdModeList = ['Predict','Train','Update']
        self.ui.hdMode.addItems(self.hdModeList)

        self.messages = []
        self.numMessages = 0
        self.messageIdx = 0

        self.images = []
        self.imageDir = os.getcwd() + "/GesturesComp/"
        # self.imageDir = "~/Research/hyperflexemg/GUI/Gestures/"
        self.ui.wideDisable.clicked.connect(self.emitWideDisable)

        self.setWindowTitle("HyperFlexEMG GUI")

        # initialize streaming mode thread
        self.streamAdcThread = cmbackend.streamAdcThread()
        self.streamAdcThread.streamAdcData.connect(self.streamAdcData)
        self.streamAdcThread.experimentTick.connect(self.tick)
        self.streamAdcThread.experimentStop.connect(self.stop)
        self.streamAdcThread.setPlotCh(self.plotCh)

    def initImage(self):
        print(self.imageDir)
        self.ui.image.setPixmap(QPixmap(self.imageDir + "Rest.png").scaledToWidth(self.ui.image.geometry().width()))
        self.ui.posImage.setPixmap(QPixmap(self.imageDir + "POS0.png").scaledToWidth(self.ui.posImage.geometry().width()))
    
    @pyqtSlot()
    def updateCh(self):
        self.plotCh[0] = self.ui.ch0.value()
        self.plotCh[1] = self.ui.ch1.value()
        self.plotCh[2] = self.ui.ch2.value()
        self.plotCh[3] = self.ui.ch3.value()
        for i in range(0, self.numPlots):
            self.plots[i].setLabel('left', text="Ch {}".format(self.plotCh[i]))
        self.streamAdcThread.setPlotCh(self.plotCh)

    @pyqtSlot()
    def updateTarget(self):
        self.target = self.ui.target.value()
        print(self.target)

    @pyqtSlot(list,list)
    def streamAdcData(self, data, hdout):
        if data:
            self.data = data
            # label = hdout[0][59:64]
            # self.labelout = 0
            # for bit in label:
            #     self.labelout = (self.labelout << 1) | bit
            # distance = hdout[0][49:59]
            # self.distanceout = 0
            # for bit in distance:
            #     self.distanceout = (self.distanceout << 1) | bit

            if self.ui.dispStream.isChecked():
                self.updatePlotStream()

            # # UPDATE EFFORT LEVEL BAR HERE!
            # numSamples = len(data)
            # dataNp = np.asarray(data)
            # dataNp = dataNp[:,0:64]
            # self.raw = np.delete(self.raw, slice(0,numSamples), 0)
            # self.raw = np.append(self.raw, dataNp, axis=0)
            # effort = np.mean(np.std(signal.detrend(self.raw, axis=0),axis=0))
            # effort = int((effort + self.ui.b.value())*self.ui.m.value())
            # effort = max(min(self.ui.effort.maximum(), effort), self.ui.effort.minimum())
            # self.ui.effort.setValue(effort)

    @pyqtSlot()
    def on_streamBtn_clicked(self):
        if self.ui.streamBtn.isChecked():
            self.plotStart = 0
            self.start()
        else:
            filename = self.streamAdcThread.stop()

    @pyqtSlot()
    def clearPlots(self):
        self.plotPointer = 0
        self.dataPlot = np.zeros(
            # (self.numPlots, self.ui.xRange.maximum()))  # aggregation of data to plot (scrolling style)
            (self.numPlots, self.xRange))
        for ch in range(0, self.numPlots):
            self.plots[ch].clear()

        effort = self.ui.effort.value()


    @pyqtSlot()
    def updatePlotDisplay(self):
        for j in reversed(range(0,self.numPlots)):
            plotToDelete = self.ui.plot.getItem(j,0)
            if plotToDelete is not None:
                self.ui.plot.removeItem(plotToDelete)

        # self.xRange = self.ui.xRange.value()
        for i in range(0, self.numPlots):
            viewBox = pg.ViewBox(enableMouse=False)
            viewBox.setRange(xRange=[0,self.xRange])
            self.plots[i] = self.ui.plot.addPlot(row=i, col=0, viewBox=viewBox)
            self.plots[i].setLabel('left', text="Ch {}".format(self.plotCh[i]))

        # need to also replot the data
        self.updatePlotStream()

    @pyqtSlot()
    def updatePlotStream(self):
        if self.data:
            x = np.arange(self.plotStart,(self.plotStart + len(self.data)))
            if self.plotStart == 0:
                for ch in range(0,self.numPlots):
                    self.plots[ch].clear()
            self.plotStart = self.plotStart + len(self.data)
            if self.plotStart == self.xRange:
                self.plotStart = 0
                

            self.data = np.array(self.data)
            for ch in range(0,self.numPlots):
                
                self.plots[ch].plot(x=x, y=self.data[:,ch], pen=self.plotColors[ch])

                # self.plots[ch].getViewBox().setMouseEnabled(x=True, y=True)
                # self.plots[ch].getViewBox().setMouseMode(self.plots[ch].getViewBox().RectMode)
                self.plots[ch].getViewBox().setLimits(xMin=0, xMax=self.xRange, yMin=-32768, yMax=32768)

                # self.plots[ch].getViewBox().setRange(yRange=(avg-(sd*2),avg+(sd*2)),update=True)
                # self.plots[ch].setLabel('left', text="Ch {}".format(self.plotCh[ch]))
                # if self.ui.autorange.isChecked():
                #     self.plots[ch].getViewBox().enableAutoRange(axis='y', enable=True)

            # # loop through samples
            # for t in range(0, len(self.data)):
            #     if self.plotPointer == self.xRange:
            #         self.plotPointer = 0
            #     # grab specific sample
            #     temp = self.data[t]

            #     for ch in range(0, self.numPlots):
            #         # if self.plotCh[ch] == 67:
            #         #     # self.dataPlot[ch][self.plotPointer] = self.labelout
            #         #     self.dataPlot[ch][self.plotPointer] = 0
            #         # elif self.plotCh[ch] == 68:
            #         #     # self.dataPlot[ch][self.plotPointer] = self.distanceout
            #         #     self.dataPlot[ch][self.plotPointer] = 0
            #         # elif self.plotCh[ch] > 63 and self.plotCh[ch] < 67:
            #         #     if temp[self.plotCh[ch]] < 32768:
            #         #         self.dataPlot[ch][self.plotPointer] = temp[self.plotCh[ch]]
            #         #     else:
            #         #         self.dataPlot[ch][self.plotPointer] = -(temp[self.plotCh[ch]] ^ 0xFFFF) - 1
            #         # else:
            #         #     self.dataPlot[ch][self.plotPointer] = temp[self.plotCh[ch]] & 0x7FFF
                
            #         self.dataPlot[ch][self.plotPointer] = temp[ch] & 0x7FFF
            #     self.plotPointer += 1
            # self.data = []

        # for ch in range(0, self.numPlots):
        #     dp = self.dataPlot[ch][0:self.xRange]

        #     avg = np.mean(dp)
        #     sd = np.std(dp)
        #     if sd < 10:
        #         sd = 10

        #     self.plots[ch].clear()
        #     self.plots[ch].plot(y=dp, pen=self.plotColors[ch])

        #     self.plots[ch].getViewBox().setMouseEnabled(x=True, y=True)
        #     self.plots[ch].getViewBox().setMouseMode(self.plots[ch].getViewBox().RectMode)
        #     self.plots[ch].getViewBox().setLimits(xMin=0, xMax=self.xRange, yMin=-32768, yMax=32768)
        #     self.plots[ch].getViewBox().setRange(yRange=(avg-(sd*2),avg+(sd*2)),update=True)
        #     self.plots[ch].setLabel('left', text="Ch {}".format(self.plotCh[ch]))
            
        #     if self.ui.autorange.isChecked():
        #         self.plots[ch].getViewBox().autoRange()

    def start(self):
        self.gestGroup = self.ui.gestureSets.currentIndex()
        self.gestGroupName = gestureGroupNames[self.gestGroup]
        self.gestLabels = gestureGroupMembers[self.gestGroup]
        self.gestNames = []
        for label in self.gestLabels:
            self.gestNames.append(gestureNames[label])

        self.numGest = len(self.gestNames)
        self.reps = self.ui.numReps.value()
        self.gestSecs = self.ui.timeGest.value()
        self.transSecs = self.ui.timeTrans.value()
        self.relaxSecs = self.ui.timeRelax.value()

        self.position = self.ui.position.currentIndex()
        self.positionName = positionNames[self.position]

        self.bufferRelaxSecs = 5

        self.hdMode = self.ui.hdMode.currentIndex()
        if self.hdMode == 2:
            self.hdMode = 3

        # build sequence of messages
        self.messages = []
        self.images = []
        self.posImages = []
        self.modes = []
        self.labels = []

        # fill in start messages
        for x in range(self.bufferRelaxSecs,0,-1):
            self.messages.append('Relax\nBegin with ' + self.gestNames[0] + ' in ' + self.positionName + ' in ' + str(x))
            self.images.append('Rest')
            self.posImages.append('POS0')
            self.modes.append(0)
            self.labels.append(0)

        for i,g in enumerate(self.gestNames):
            for x in range(1,self.reps+1):
                # reach to position
                for s in range(self.transSecs,0,-1):
                    self.messages.append('Move to ' + self.positionName + ' in ' + str(s) + ' seconds \nTrial #' + str(x))
                    self.images.append('Rest')
                    self.posImages.append(self.positionName.replace(" ",""))
                    self.modes.append(0)
                    self.labels.append(0)
                # reach to gesture
                for s in range(self.transSecs,0,-1):
                    self.messages.append('Reach ' + g + ' while in ' + self.positionName + ' in ' + str(s) + ' seconds \nTrial #' + str(x))
                    self.images.append(g.replace(" ",""))
                    self.posImages.append(self.positionName.replace(" ",""))
                    self.modes.append(0)
                    self.labels.append(0)
                # hold gesture
                for s in range(self.gestSecs,0,-1):
                    self.messages.append('Hold ' + g + ' while in ' + self.positionName + ' for ' + str(s) + ' seconds \nTrial #' + str(x))
                    self.images.append(g.replace(" ",""))
                    self.posImages.append(self.positionName.replace(" ",""))
                    self.modes.append(self.hdMode)
                    # self.labels.append(i)
                    self.labels.append(gestureIndices[self.gestLabels[i]])
                # relax gesture
                for s in range(self.transSecs,0,-1):
                    self.messages.append('Relax ' + g + ' while in ' + self.positionName + ' in ' + str(s) + ' seconds \nTrial #' + str(x))
                    self.images.append('Rest')
                    self.posImages.append(self.positionName.replace(" ",""))
                    self.modes.append(0)
                    self.labels.append(0)
                # relax arm position
                for s in range(self.transSecs,0,-1):
                    self.messages.append('Return to POS 0 in ' + str(s) + ' seconds \nTrial #' + str(x))
                    self.images.append('Rest')
                    self.posImages.append('POS0')
                    self.modes.append(0)
                    self.labels.append(0)
                # relax in between gestures
                if x != self.reps:
                    for s in range(self.relaxSecs,0,-1):
                        self.messages.append('Relax\n' + g + ' in ' + self.positionName + ' in ' + str(s) + ' seconds')
                        self.images.append('Rest')
                        self.posImages.append('POS0')
                        self.modes.append(0)
                        self.labels.append(0)
                else:
                    if i != len(self.gestNames)-1:
                        for s in range(self.relaxSecs,0,-1):
                            self.messages.append('Relax\n' + self.gestNames[i+1] + ' in ' + self.positionName + ' in ' + str(s) + ' seconds')
                            self.images.append('Rest')
                            self.posImages.append('POS0')
                            self.modes.append(0)
                            self.labels.append(0)

        # fill in end messages
        for x in range(self.bufferRelaxSecs,0,-1):
            self.messages.append('Relax\nDone in ' + str(x))
            self.images.append('Rest')
            self.posImages.append('POS0')
            self.modes.append(0)
            self.labels.append(0)

        self.messages.append('Done!\n')
        self.images.append('Rest')
        self.posImages.append('POS0')
        self.modes.append(0)
        self.labels.append(0)

        self.numMessages = len(self.messages)
        # print(self.numMessages)
        self.ui.message.setText('Experiment Begin\n' + self.gestGroupName)
        self.messageIdx = 0
        self.ui.image.setPixmap(QPixmap(self.imageDir + "Rest.png").scaledToWidth(self.ui.image.geometry().width()))
        self.ui.posImage.setPixmap(QPixmap(self.imageDir + "POS0.png").scaledToWidth(self.ui.posImage.geometry().width()))
        # print(self.images)

        self.streamAdcThread.start()

    @pyqtSlot()
    def tick(self):
        self.ui.image.setPixmap(QPixmap(self.imageDir + self.images[self.messageIdx] + ".png").scaledToWidth(self.ui.image.geometry().width()))
        self.ui.posImage.setPixmap(QPixmap(self.imageDir + self.posImages[self.messageIdx] + ".png").scaledToWidth(self.ui.posImage.geometry().width()))
        self.ui.message.setText(self.messages[self.messageIdx])
        # self.streamAdcThread.setMdLbl([self.modes[self.messageIdx], self.labels[self.messageIdx]])
        # print(self.modes[self.messageIdx])
        # print(self.labels[self.messageIdx])
        if self.messageIdx < self.numMessages - 1:
            self.messageIdx += 1

    @pyqtSlot(str)
    def stop(self,file):
        if self.ui.saveData.isChecked():
            start = file.find('hdfs/') + 5
            end = file.find('.hdf',start)
            timeStamp = file[start:end]

            hdfFile = tables.open_file(file, mode='r')
            dataTable = hdfFile.root.dataGroup.dataTable
            raw = np.asarray([x['out'] for x in dataTable.iterrows()])
            
            # crcs
            crc = raw[:,0]
            raw = raw[:,1:97]

            for i,s in enumerate(crc):
                if s==0xff and i!=0:
                    for ch in range(96):
                        raw[i,ch] = raw[i-1,ch]


            # plt.plot(raw)
            # plt.show()

            subInd = self.ui.subInd.value()
            expInd = self.ui.expInd.value()

            saveDir = 'armPosData/mat/' + str(subInd).zfill(3) + '/' + str(expInd).zfill(3) + '/' + timeStamp + '/'
            os.makedirs(saveDir, exist_ok=True)

            trialLen = self.gestSecs + 2*2*self.transSecs + self.relaxSecs
            # print('trialLen: ' + str(trialLen))
            if len(raw) >= self.numMessages*1000:
                # create matlab file for each repetition of each gesture
                for i,g in enumerate(self.gestLabels):
                    for x in range(self.reps):
                        fileStart = (self.bufferRelaxSecs + 1.5 - self.relaxSecs/2 + x*trialLen + i*self.reps*trialLen)*1000
                        fileEnd = fileStart + trialLen*1000

                        posStart = (self.relaxSecs/2)*1000
                        gestStart = posStart + (self.transSecs)*1000
                        holdStart = gestStart + (self.transSecs)*1000
                        holdEnd = holdStart + (self.gestSecs)*1000
                        gestEnd = holdEnd + (self.transSecs)*1000
                        posEnd = gestEnd + (self.transSecs)*1000

                        # create data
                        emg = raw[int(fileStart):int(fileEnd),0:63]
                        acc = raw[int(fileStart):int(fileEnd),64:67]
                        # create gesture label with correct value
                        gest = np.zeros(trialLen*1000)
                        gest[int(gestStart):int(gestEnd)] = g
                        # create position label
                        pos = np.zeros(trialLen*1000)
                        pos[int(posStart):int(posEnd)] = self.position
                        # create hold label
                        gestHold = np.zeros(trialLen*1000)
                        gestHold[int(holdStart):int(holdEnd)] = 1
                        # create info struct
                        streamInfo = {'subject': subInd, 'description': str(self.ui.description.text()), 'rep': x+1, 'timeGest': self.gestSecs*1000, 'timeRelax': self.relaxSecs*1000, 'timeTrans': self.transSecs*1000, 'lsbmV': 0.0031, 'bufferRelaxSecs': self.bufferRelaxSecs*1000, 'timeStamp': timeStamp, 'gestNum': g, 'posNum': self.position}
                        
                        matfile = saveDir + str(subInd).zfill(3) + '_' + str(expInd).zfill(3) + '_' + str(g).zfill(3) + '_' + str(self.position).zfill(2) + '_' + timeStamp + '_' + str(x+1) + '.mat'
                        sio.savemat(matfile, {'emg':emg, 'acc':acc, 'gest':np.transpose(gest), 'pos':np.transpose(pos), 'gestHold':np.transpose(gestHold), 'streamInfo':streamInfo})
            hdfFile.close()
        else:
            os.remove(file)

    @pyqtSlot()
    def emitWideDisable(self):
        self.wideDisable.emit()

