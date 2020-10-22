from PyQt4.QtCore import *
from PyQt4 import QtGui
import struct
import time
import datetime
import tables
from tables import *
from enum import Enum
from queue import Queue
import libusb1
from ctypes import byref, create_string_buffer, c_int, sizeof, POINTER, \
    cast, c_uint8, c_uint16, c_ubyte, string_at, c_void_p, cdll, addressof, \
    c_char
import os

datalen = 200

# CM register addresses
class Reg(Enum):
    ctrl = 0x00
    rst = 0x04
    n0d1 = 0x10
    n0d2 = 0x14
    n1d1 = 0x20
    n1d2 = 0x24
    req = 0xff
    mdlbl = 0x30 # 2 bits mode, 5 bits label

class stream_data(IsDescription):
    out = UInt16Col(int(datalen/2 - 1))
    time = FloatCol()

dataQueue = Queue()
timeQueue = Queue()

# CP2130 functions for reading, writing, and setting various SPI parameters

# change device to read priority
def cp2130_libusb_set_usb_config(handle):
	buf = c_ubyte * 10
	control_buf_out = buf(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80)
	usbTimeout = 500

	error_code = libusb1.libusb_control_transfer(handle, 0x40, 0x61, 0xA5F1, 0x000A, control_buf_out, sizeof(control_buf_out), usbTimeout)
	if error_code != sizeof(control_buf_out):
		print('Error in bulk transfer')
		return False
	return True

# this function always writes 5 bytes. if you want to write more than that, have to parametrize it
def cp2130_libusb_write(handle, value): # value should be a list of 5 bytes to write
    buf = c_ubyte * 13
    write_command_buf = buf(
    	0x00, 0x00,
    	0x01,
    	0x00,
    	0x01, 0x00, 0x00, 0x00)
    # populate command buffer with value to write
    write_command_buf[8:13] = value
    bytesWritten = c_int()
    usbTimeout = 500

    error_code = libusb1.libusb_bulk_transfer(handle, 0x02, write_command_buf, sizeof(write_command_buf), byref(bytesWritten), usbTimeout)
    if error_code:
        print('Error in bulk transfer (write command)! Error # {}'.format(error_code))
        return False
    return True

def cp2130_libusb_read(handle):
    buf = c_ubyte * 8
    read_command_buf = buf(
        0x00, 0x00,
        0x00,
        0x00,
        datalen, 0x00, 0x00, 0x00)
    bytesWritten = c_int()
    buf = c_ubyte * datalen
    read_input_buf = buf()
    bytesRead = c_int()
    usbTimeout = 500

    error_code = libusb1.libusb_bulk_transfer(handle, 0x02, read_command_buf, sizeof(read_command_buf), byref(bytesWritten), usbTimeout)
    if error_code:
        print('Error in bulk transfer (read command). Error # {}'.format(error_code))
        return False
    if bytesWritten.value != sizeof(read_command_buf):
        print('Error in bulk transfer write size')
        print(bytesWritten.value)
        return False
        
    error_code = libusb1.libusb_bulk_transfer(handle, 0x81, read_input_buf, sizeof(read_input_buf), byref(bytesRead), usbTimeout)
    if error_code:
        print('Error in bulk transfer (read buffer). Error # {}'.format(error_code))
        return False
    if bytesRead.value != sizeof(read_input_buf):
        print('Error in bulk transfer - returned {} out of {} bytes'.format(bytesRead.value, sizeof(read_input_buf)))
        return False

    return read_input_buf

def cp2130_libusb_set_spi_word(handle):
    buf = c_ubyte * 2
    control_buf_out = buf(0x00, 0x09)
    usbTimeout = 500

    error_code = libusb1.libusb_control_transfer(handle, 0x40, 0x31, 0x0000, 0x0000, control_buf_out, sizeof(control_buf_out), usbTimeout)
    if error_code != sizeof(control_buf_out):
        print('Error in bulk transfer')
        return False
    
    return True

class readFTDIFifoThread(QThread):
    def __init__(self):
        QThread.__init__(self)
        self._running = True
        self.mode = 0
        self.label = 0
        self.updateMdLbl = False

    def __del__(self):
        self.wait()

    def stop(self):
        self._running = False

    def setMdLbl(self,mode,label):
        if (self.mode != mode) or (self.label != label):
            self.mode = mode
            self.label = label
            self.updateMdLbl = True

    def run(self):
        # make sure serial device is open
        if not CMWorker.cp2130Handle:
            return

        # reset
        if not self._running:
            # CMWorker.ser.flush()
            self._running = True

        t_0 = time.time()
        while self._running:
            # time.sleep(0.0001)
            data = cp2130_libusb_read(CMWorker.cp2130Handle)
            if data == False:
                pass
            elif data[1] == 198:
                dataQueue.put(data)
                timeQueue.put(time.time() - t_0)
                if self.updateMdLbl:
                    self.updateMdLbl = False
                    CMWorker()._regWr(Reg.mdlbl, (self.mode<<5)+self.label)

        dataQueue.queue.clear()
        timeQueue.queue.clear()

class streamAdcThread(QThread):

    streamAdcData = pyqtSignal(list,list)
    experimentTick = pyqtSignal()
    experimentStop = pyqtSignal(str)
    filename = ''

    def __init__(self):
        QThread.__init__(self)
        self._running = True
        self.ftdiFIFO = readFTDIFifoThread()

    def __del__(self):
        self.wait()

    def setMdLbl(self,mdlbl):
        mode = mdlbl[0]
        label = mdlbl[1]
        self.ftdiFIFO.setMdLbl(mode,label)

    def stop(self):
        self._running = False
        return self.filename + '.txt'

    def setPlotCh(self,plotCh):
        self.plotCh = plotCh

    def run(self):
        # make sure serial device is open
        if not CMWorker.cp2130Handle:
            return

        # reset
        if not self._running:
            self._running = True

        os.makedirs('armPosData', exist_ok=True)
        os.makedirs('armPosData/hdfs', exist_ok=True)
        os.makedirs('armPosData/mat', exist_ok=True)
        self.filename = 'armPosData/' + 'hdfs/' + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        self.saveFile = tables.open_file(self.filename + '.hdf', mode="w", title="Stream")
        self.dataGroup = self.saveFile.create_group("/", name='dataGroup', title='Recorded Data Group')
        self.dataTable = self.saveFile.create_table(self.dataGroup, name='dataTable', title='Recorded Data Table', description=stream_data, expectedrows=60000*5*1)

        start = datetime.datetime.now()
        print("Stream started at: {}".format(start))

        CMWorker().startStream() # put CM into streaming mode for both NMs
        time.sleep(0.07)

        out = []
        hdout = []
        success = 0
        crcs = 0
        fail = 0
        samples = 0
        t_0 = time.time()

        # initialize ftdiFIFO thread and start it
        self.ftdiFIFO.start()

        timeout = False
        while self._running:
            try:
                data = dataQueue.get(timeout=5)
            except:
                timeout = True
                print('timeout reading from data queue at sample {}'.format(samples))
                self.streamAdcData.emit(out,hdout)
                out = []
                hdout = []
            if not timeout:
                try:
                    data_time = timeQueue.get(timeout=5)
                except:
                    timeout = True
                    print('timeout reading from time queue at sample {}'.format(samples))
            if not timeout:
                samples = samples + 1
                if data[0]==0x00: # no CRC
                    success += 1
                    data_point = self.dataTable.row
                    data_point['out'] = [data[0] if i == 0 else ((data[i + 1] << 8 | data[i]) & 0xFFFF if i < datalen - 7 else (data[i + 1] << 8 | data[i])) for i in list(range(0, datalen - 3, 2))]
                    self.values = [(data[2*(i+1) + 1] << 8 | data[2*(i+1)]) & 0xFFFF for i in range(0,67)]
                    # out.append(self.values)
                    out.append([self.values[i] for i in self.plotCh])
                    self.msbs = [(self.values[i] & 0x8000) >> 15 for i in range(0,64)]
                    hdout.append(self.msbs)
                    data_point['time'] = data_time
                    data_point.append()

                elif data[0] == 0xFF: # CRC
                    crcs += 1
                    success += 1
                    data_point = self.dataTable.row
                    data_point['out'] = [data[0] if i == 0 else ((data[i + 1] << 8 | data[i]) & 0xFFFF if i < datalen - 7 else (data[i + 1] << 8 | data[i])) for i in list(range(0, datalen - 3, 2))]
                    # out.append(self.values)
                    out.append([self.values[i] for i in self.plotCh])
                    hdout.append(self.msbs)
                    data_point['time'] = data_time
                    data_point.append()

                else: # should never get here?
                    fail += 1

                # flush the tables every 1000 samples (any speed up?)
                # if samples%1000 == 0:
                #     self.dataTable.flush()
                #     self.experimentTick.emit()
                #     # self.streamAdcData.emit(out, hdout)
                #     # out = []
                #     # hdout = []   
                if samples%40 == 0:
                    self.streamAdcData.emit(out, hdout)
                    out = []
                    hdout = []    

            timeout = False

        self.ftdiFIFO.stop() # turn off FTDI fifo reading thread
        print("Stream ended at: {}".format(datetime.datetime.now()))
        print("Received Samples: {}".format(samples))
        print("CRCs: {}".format(crcs))
        if samples != 0:
            print("Success: {}".format((samples - crcs)/samples))
            print("Error: {}".format(crcs/samples))
        time.sleep(0.5)

        CMWorker().stopStream() # turn off streaming mode
        print("End of Stream")

        self.saveFile.close()
        self.experimentStop.emit(self.filename + '.hdf')


class CMWorker(QThread):
    connStateChanged = pyqtSignal(bool)
    boardsChanged = pyqtSignal(list)

    # initializing libusb and device things
    context = libusb1.libusb_context_p()
    deviceList = libusb1.libusb_device_p_p()
    deviceCount = 0
    deviceDescriptor = libusb1.libusb_device_descriptor()
    device = libusb1.libusb_device_p()
    cp2130Handle = libusb1.libusb_device_handle_p()
    kernelAttached = 0

    if libusb1.libusb_init(byref(context)) != 0:
        print('Could not initialize libusb!')

    def __init__(self, parent=None):
        super().__init__(parent)

    def __del__(self):
        # wait for the thread to finish before destroying object
        self.wait()

    def _flushRadio(self):
        cp2130_libusb_write(CMWorker.cp2130Handle, [0xAA, *struct.pack('>I',0x00)])

    def _regWr(self, reg, value):
        cp2130_libusb_write(CMWorker.cp2130Handle, [reg.value, *struct.pack('>I', value)])

    def exit_cp2130(self):
        if self.cp2130Handle:
            libusb1.libusb_release_interface(self.cp2130Handle, 0)
        if self.kernelAttached:
            libusb1.libusb_attach_kernel_driver(self.cp2130Handle,0)
            if self.cp2130Handle:
                libusb1.libusb_close(self.cp2130Handle)
            if self.deviceList:
                libusb1.libusb_free_device_list(self.deviceList, 1)
            if self.context:
                libusb1.libusb_exit(self.context)

    @pyqtSlot()
    def refreshBoards(self):
        dev_list = []
        deviceCount = libusb1.libusb_get_device_list(self.context, byref(self.deviceList))
        if deviceCount <= 0:
            print('No devices found!')
        for i in range(0, deviceCount):
            if libusb1.libusb_get_device_descriptor(self.deviceList[i], byref(self.deviceDescriptor)) == 0:
                if (self.deviceDescriptor.idVendor == 0x10C4) and (self.deviceDescriptor.idProduct == 0x87A0):
                    dev_list.append(self.deviceList[i])
                    self.device = self.deviceList[i]
        # TODO: how to get device desciptor from libusb1?
        if dev_list:
            self.boardsChanged.emit(["cp2130"])
        else:
            self.boardsChanged.emit([])

    @pyqtSlot(str)
    def connectToBoard(self, board):
        # open device
        if libusb1.libusb_open(self.device, byref(self.cp2130Handle)) != 0:
            print('Could not open device!')
            return
        # See if a kernel driver is active already, if so detach it and store a flag so we can reattach when we are done
        if libusb1.libusb_kernel_driver_active(self.cp2130Handle, 0) != 0:
            libusb1.libusb_detach_kernel_driver(self.cp2130Handle, 0)
            self.kernelAttached = 1
        # claim the device
        if libusb1.libusb_claim_interface(self.cp2130Handle, 0) != 0:
            print('Could not claim interface!')
            return
        print("Connected to {}".format(board))
        cp2130_libusb_set_spi_word(self.cp2130Handle)
        cp2130_libusb_set_usb_config(self.cp2130Handle)
        self.connStateChanged.emit(True)

    @pyqtSlot(str)
    def disconnectBoard(self, board):
        self.exit_cp2130()
        print("Disconnected from {}".format(board))
        self.connStateChanged.emit(False)
        self.refreshBoards()

    def startStream(self):
        if not self.cp2130Handle:
            return
        self._regWr(Reg.req, 0x0020)

    def stopStream(self):
        if not self.cp2130Handle:
            return
        self._regWr(Reg.req, 0x0010)

    def regOp(self, addr, data, write):
        buf = c_ubyte*200
        d = buf()
        count = 0
        self._regWr(Reg.n0d1, 1 if write else 0)
        self._regWr(Reg.n0d2, addr << 16 | data)
        self._regWr(Reg.ctrl, 0x1000)
        if not write:
            self._flushRadio()
            self._regWr(Reg.req, 0x0100)
            time.sleep(0.05)
            while d[1] != 4 and count < 20:
                d = cp2130_libusb_read(CMWorker.cp2130Handle)
                count = count + 1
                time.sleep(0.0008)
            success = (d[1] == 4)
            add = d[2] + 256*d[3]
            val = d[4] + 256*d[5]
            return [success, add, val]

    def readRegister(self, addr):
        if not self.cp2130Handle:
            return
        ret = [False, 0, 0]
        tries = 0
        while(tries < 10) and not(ret[0] and addr == ret[1]):
            ret = self.regOp(addr, 0, False)
            tries = tries + 1
        if tries >= 10:
            ret[0] = False
        return ret

    def writeRegister(self, addr, value):
        if not self.cp2130Handle:
            return
        tries = 0
        while tries < 5:
            self.regOp(addr, value, True)
            ret = self.readRegister(addr)
            if ret[0] and (ret[2] == value):
                break
            tries = tries + 1
        if tries == 5:
            return False
        else:
            return True

    @pyqtSlot()
    def wideDisable(self):
        print('Testing reg read')
        ret = self.readRegister(0x00)
        if not ret[0]:
            print('Failed to read register!')
        else:
            value = ret[2]
            print("Register Value: {:04x}".format(value))
        # print('Wide Input Disable:')
        # ret = self.readRegister(0x0C)
        # if not ret[0]:
        #     print('Failed to read register!')
        # else:
        #     value = ret[2]
        #     print("Register Value: {:04x}".format(value))
        #     if not(value % 2):
        #         print('Wide In already disabled!')
        #     else:
        #         print('Wide In is enabled -- Disabling... ')
        #         value = value - 1
        #         tries = 0
        #         success = self.writeRegister(0x0C, value)
        #         if success:
        #             print('Wide In successfully disabled!')
        #         else:
        #             print('Unable to disable Wide In!')

    @pyqtSlot(list)
    def setMdLbl(self,mdlbl):
        mode = mdlbl[0]
        label = mdlbl[1]
        # print(mode)
        # print(label)
        # self._regWr(Reg.mdlbl, (mode<<5)+label)








