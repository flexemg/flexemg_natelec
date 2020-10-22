import hdc
import numpy as np
import matplotlib.pyplot as plt

# class forming all of the memories needed for HDEMG classification:
# eM: electrode memory
# AM: gesture associative memory
# CiM: continuous item memory (if needed)
class HD_machine:
	def __init__(self,dim=10000,numElectrodes=64,numClasses=21,numLevels=10):
		self.dim = dim
		self.numElectrodes = numElectrodes
		self.numClasses = numClasses
		self.numLevels = numLevels
		self.eM = hdc.Space(self.dim)
		self.AM = hdc.Space(self.dim)
		self.CiM = hdc.Space(self.dim)

		# build electrode memory
		for i in range(0,numElectrodes):
			# add random vector representing electrode i
			self.eM.add(i)

		# build associative memory
		for i in range(0,numClasses):
			# add zeroed vector representing class i
			self.AM.add(i)
			self.AM[i].clear()

		# build continuous item memory
		updateVec = hdc.Vector(self.dim)
		randperm = np.random.permutation(self.dim)
		sp = np.floor(self.dim/2/self.numLevels)
		for i in range(0,numLevels+1):
			self.CiM.insert(updateVec,i)
			start = i*sp
			stop = (i+1)*sp
			flip = np.ones(self.dim)
			flip[randperm[start:stop]] = -1
			updateVec.value = updateVec.value*flip

	def dist_eM(self):
		dist = np.zeros((self.numElectrodes,self.numElectrodes))
		for i in range(0,self.numElectrodes):
			for j in range(0,self.numElectrodes):
				dist[i,j] = self.eM[i] % self.eM[j]
		# plt.imshow(dist, interpolation='nearest')
		# plt.show()
		return dist

	def dist_AM(self):
		dist = np.zeros((self.numClasses,self.numClasses))
		for i in range(0,self.numClasses):
			for j in range(0,self.numClasses):
				dist[i,j] = self.AM[i] % self.AM[j]
		# plt.imshow(dist, interpolation='nearest')
		# plt.show()
		return dist

	def dist_CiM(self):
		dist = np.zeros((self.numLevels+1,self.numLevels+1))
		for i in range(0,self.numLevels+1):
			for j in range(0,self.numLevels+1):
				dist[i,j] = self.CiM[i] % self.CiM[j]
		# plt.imshow(dist, interpolation='nearest')
		# plt.show()
		return dist