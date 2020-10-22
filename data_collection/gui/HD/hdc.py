# definitions for hyperdimensional space and vectors for HDC

# For Vectors:
    # Read-only operations:
    # Pointwise addition of 2 vectors: 'A + B'
    # Pointwise multiplication of 2 vectors: 'A * B'
    # Weighting of a vector by a scalar: 'x * A' or 'A * x'
    # Permutation of a vector by a scalar: 'A >> x' or 'A << x' *note that direction doesn't matter...
    # Cosine similarity between two vectors: 'A % B' or 'B % A'
    # Bipolarized vector: 'abs(A)'

    # Writing operations:
    # Accumulation of A by B: 'A.accumulate(B)''
    # Multiplication of A by vector B or scalar x: 'A.multiply(B)' or 'A.multiply(x)' 
    # Permutation of a vector by a scalar: 'A.permute(x)'
    # Bipolarization of a vector: 'A.bipolarize()'

# For Spaces:
    # Add a new random vector labeled name: S.add(name)
    # Insert vector V a label name: S.insert(V,name)
    # Find closest vector in S to V: S.find(V)
    # Bipolarize all vectors in S: S.bipolarize()

import numpy as np
import random

random.seed()

class Vector:
    # init random HDC vector
    def __init__(self, dim):
        self.dim = dim    # dimension of vector
        self.value = np.random.choice([-1.0, 1.0], size=dim) # bipolar vector of random +1s and -1s

    # print vector
    def __repr__(self):
        return np.array2string(self.value)

    # print vector
    def __str__(self):
        return np.array2string(self.value)


    # Read-only operations:
    # addition of vectors
    def __add__(self, a):
        # addition only allowed between two vectors of same dimension
        if isinstance(a, self.__class__):
            if (a.dim == self.dim):
                b = Vector(self.dim)
                b.value = a.value + self.value
                return b
            else:
                raise TypeError("Vector dimensions do not agree")
        else:
            raise TypeError("Unsupported type for vector addition")

    # multiplication
    def __mul__(self, a):
        # multiplication allowed between two vectors of same dimension or vector and scalar
        if isinstance(a, self.__class__):
            if (a.dim == self.dim):
                b = Vector(self.dim)
                b.value = a.value * self.value
                return b
            else:
                raise TypeError("Vector dimensions do not agree")
        elif isinstance(a, (float,int)):
            b = Vector(self.dim)
            b.value = a * self.value
            return b
        else:
            raise TypeError("Unsupported type for vector multiplication")

    __rmul__ = __mul__

    # permutation
    def __rshift__(self,a):
        # rotation of the vector by a
        b = Vector(self.dim)
        b.value = np.roll(self.value,a)
        return b

    __lshift__ = __rshift__

    # cosine similarity
    def __mod__(self, a):
        # cosine similarity between two vectors of same dimension
        if isinstance(a, self.__class__):
            if (a.dim == self.dim):
                return np.dot(self.value, a.value)/(np.linalg.norm(self.value) * np.linalg.norm(a.value))
            else:
                raise TypeError("Vector dimensions do not agree")
        else:
            raise TypeError("Unsupported type for vector cosine similarity")

    def __abs__(self):
        b = Vector(self.dim)
        b.value = self.value
        z = b.value
        z[z > 0] = 1.0
        z[z < 0] = -1.0
        z[z == 0] = np.random.choice([-1.0, 1.0], size=len(z[z == 0]))
        b.value = z
        return b


    # Write functions
    # accumulate vector into other vector
    def accumulate(self, a):
        if isinstance(a, self.__class__):
            if (a.dim == self.dim):
                self.value = self.value + a.value
            else:
                raise TypeError("Vector dimensions do not agree")
        else:
            raise TypeError("Unsupported type for vector accumulation")

    # bind vector into other vector
    def multiply(self, a):
        if isinstance(a, self.__class__):
            if (a.dim == self.dim):
                self.value = self.value * a.value
            else:
                raise TypeError("Vector dimensions do not agree")
        elif isinstance(a, (float,int)):
            self.value = a * self.value
        else:
            raise TypeError("Unsupported type for vector binding")

    # permute vector by rotating n steps
    def permute(self, n):
        self.value = np.roll(self.value,n)

    # bipolarize an accumulated vector
    def bipolarize(self):
        z = self.value
        z[z > 0] = 1.0
        z[z < 0] = -1.0
        z[z == 0] = np.random.choice([-1.0, 1.0], size=len(z[z == 0]))
        self.value = z

    def clear(self):
        self.value = np.zeros(self.dim)


class Space:
    def __init__(self, dim=10000):
        self.dim = dim;
        self.vectors = {}

    def _random_name(self):
        return ''.join(random.choice('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ') for i in range(8))

    def __repr__(self):
        return ''.join("'%s' , %s\n" % (v, self.vectors[v]) for v in self.vectors)

    def __getitem__(self, x):
        return self.vectors[x]

    def add(self, name=None):
        if name == None:
            name = self._random_name()

        v = Vector(self.dim)

        self.vectors[name] = v
        return v

    def insert(self, v, name=None):
        if isinstance(v, Vector):
            if (v.dim == self.dim):
                if name == None:
                    name = self._random_name()
                newV = Vector(self.dim)
                newV.value = v.value
                self.vectors[name] = newV

                return name
        else:
            raise TypeError('Bad Type')

    def find(self, x):
        s = 0
        match = None

        for v in self.vectors:
            if self.vectors[v].cossim(x) > s:
                match = v
                s = self.vectors[v].cossim(x)
        return match, s

    def bipolarize(self):
        for v in self.vectors:
            v.bipolarize()

