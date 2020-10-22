import sys
from PyQt4 import QtGui, QtCore
from PyQt4.QtCore import QObject, pyqtSignal, pyqtSlot
from PyQt4.QtGui import QDockWidget
from ui.ui_commandline import Ui_CommandLine
import code
import enum
import numpy as np
import scipy.io

# necessary for thread safe operation
# emits a signal
class StdoutHandler(QObject):
    written = pyqtSignal(str)

    def __init__(self, parent = None):
        QObject.__init__(self, parent)

    def write(self, data):
        self.written.emit(str(data))

class SysCtrl(QObject):
    # signals (to window)
    _clearLog = pyqtSignal()
    # signals to worker
    _cmd = pyqtSignal(int)
    _adcReq = pyqtSignal(int)

    class CmdType(enum.Enum):
        Reset = 0x01
        ClearErr = 0x02
        HVLoad = 0x03
        ImpStart = 0x04
        StimReset = 0x08
        StimStart = 0x09
        StimTransfer = 0x0A

    def __init__(self, parent=None):
        super().__init__(parent)
        self.data = None

    def setWorker(self, w):
        pass
        
    def clear(self):
        self._clearLog.emit()

    def saveMat(self, filename):
        if self.data is None:
            print("No data to save")
            return False
        data = []
        for ch in range(0,99):
            data.append((np.array([i[ch] for i in self.data])))
        data = np.array(data)
        scipy.io.savemat(filename, dict(chan_data=data))


# command interpreter object
# runs in its own thread
class CmdInterp(QtCore.QThread):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.ctrl = SysCtrl()
        cmddict = {'ctrl': self.ctrl}
        self.interp = code.InteractiveConsole(cmddict)
        self.cmdActive = False

    def __del__(self):
        # wait for thread to finish before garbage collecting
        self.wait()

    def setWorker(self, w):
        self.ctrl.setWorker(w)

    @pyqtSlot(str)
    def onCmd(self, cmd):
        cmd = str(cmd)
        if not self.cmdActive:
            print('>>> ', cmd)
        else:
            print(cmd)
        self.cmdActive = self.interp.push(cmd)
        if self.cmdActive:
            print('...',end='')

class CommandLineWidget(QDockWidget):
    commandPushed = pyqtSignal(str)
    filePicked = pyqtSignal(str)

    class KeyEventFilter(QObject):
        keyUp = pyqtSignal()
        keyDown = pyqtSignal()

        def eventFilter(self, object, event):
            if event.type() == QtCore.QEvent.KeyPress:
                if event.key() == QtCore.Qt.Key_Up:
                    self.keyUp.emit()
                    return True
                elif event.key() == QtCore.Qt.Key_Down:
                    self.keyDown.emit()
                    return True
            return False
    
    def __init__(self, parent = None):
        QDockWidget.__init__(self, parent)
        self.ui = Ui_CommandLine()
        self.ui.setupUi(self)
        self.ui.cmdHist.setLineWrapMode(QtGui.QTextEdit.WidgetWidth)
        self.filter = CommandLineWidget.KeyEventFilter(self)
        self.ui.cmdEntry.installEventFilter(self.filter)
        self._prevcmd = ''
        self.filter.keyUp.connect(self.prevCmd)

    def setStdout(self, stdout):
        stdout.written.connect(self.onWrite)

    def setInterp(self, interp):
        self.commandPushed.connect(interp.onCmd)
        interp.ctrl._clearLog.connect(self.ui.cmdHist.clear, QtCore.Qt.BlockingQueuedConnection)

    def closeEvent(self, event):
        event.accept()

    @pyqtSlot()
    def prevCmd(self):
        prev = self.ui.cmdEntry.text()
        self.ui.cmdEntry.setText(self._prevcmd)
        self._prevcmd = prev

    @pyqtSlot()
    def on_runButton_clicked(self):
        s = str(self.ui.cmdEntry.text())
        self._prevcmd = s
        self.commandPushed.emit(s)
        self.ui.cmdEntry.clear()
        
    @pyqtSlot()
    def on_clearButton_clicked(self):
        msgbox = QtGui.QMessageBox()
        msgbox.setWindowTitle("Confirm clear")
        msgbox.setText("Are you sure you want to clear the log?")
        msgbox.setStandardButtons(QtGui.QMessageBox.Yes | QtGui.QMessageBox.No)
        msgbox.setDefaultButton(QtGui.QMessageBox.No)
        ret = msgbox.exec_()
        if ret == QtGui.QMessageBox.Yes:
            self.ui.cmdHist.clear()

    def pickFile(self, write, script=False):
        filt = 'Text files (*.txt);;All files (*.*)' if not script else 'Python scripts (*.py);;All files (*.*)'
        if write:
            fn = QtGui.QFileDialog.getSaveFileName(parent=self,
                                               caption="Select File",
                                               filter=filt)
        else:
            fn = QtGui.QFileDialog.getOpenFileName(parent=self,
                                               caption="Select File",
                                               filter=filt)
        return fn
        
    @pyqtSlot()
    def on_saveButton_clicked(self):
        fn = self.pickFile(write=True)
        if fn:
            f = open(fn, 'w')
            f.write(self.ui.cmdHist.toPlainText())
            f.close()

    @pyqtSlot()
    def on_execButton_clicked(self):
        fn = self.pickFile(write=False, script=True)
        if fn:
            self.commandPushed.emit('exec(open(\'{}\').read())'.format(fn))

    @pyqtSlot(str)
    def onWrite(self, data):
        self.ui.cmdHist.moveCursor(QtGui.QTextCursor.End)
        self.ui.cmdHist.insertPlainText(data)