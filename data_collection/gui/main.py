from PyQt4.QtGui import *
from mainwindow import *
from cmbackend import CMWorker
from cmdline import StdoutHandler, CmdInterp

if __name__ == '__main__':
    import sys
    app = QApplication(sys.argv)
    app.setApplicationName('HyperFlexEMG GUI')
    app.setOrganizationName('BWRC')

    stdout = StdoutHandler()
    worker = CMWorker()
    interp = CmdInterp()

    worker.moveToThread(worker)
    interp.moveToThread(interp)

    w = MainWindow()
    w.setWorker(worker)
    interp.setWorker(worker)
    w.cmdline.setInterp(interp)
    w.cmdline.setStdout(stdout)
    w.show()
    w.activateWindow()
    w.raise_()
    worker.start()
    interp.start()

    w.HyperFlexGUI.initImage()

    oldstderr = sys.stderr
    oldstdout = sys.stdout
    sys.stdout = stdout
    sys.stderr = stdout

    ret = app.exec_()

    sys.stdout = oldstdout
    sys.stderr = oldstderr
    
    # this avoids python hanging at exit due to garbage collection
    del w
    interp.quit()
    worker.quit()
    sys.exit(ret)
