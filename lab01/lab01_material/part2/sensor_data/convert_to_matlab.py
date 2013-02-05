#!/usr/bin/env python

import numpy, os, sys
from PIL import Image
import scipy.io

def read_shuo_format(stream):
    shape = stream.readline().split()
    assert len(shape) == 2
    height = int(shape[0]) 
    width = int(shape[1]) 
    XYZ = numpy.zeros((height,width,3))
    print('Reading image of shape %s' % str(XYZ.shape))
    for k in range(3):
        for i in range(height):
            line = stream.readline()
            assert line
            row = line.split()
            assert len(row) == width
            for j in range(width):
                XYZ[i,j,k] = float(row[j])
                
    # check no other data in the file
    rest = stream.read()
    assert not rest.strip()
    return XYZ
    
    
def convert(filename):
    
    for ext in ['','.jpg','.png','.pgm']:
        image = os.path.splitext(filename)[0] + ext
        if os.path.exists(image):
            break
    else: 
        print('Could not find image %r' % filename)
        sys.exit(-1)
    data = os.path.splitext(image)[0] + '.xyz'

    mat = os.path.splitext(image)[0] + '.mat'
    sol = os.path.splitext(image)[0] + '.sol'

    print('Loading XYZ      from %r' % data)
    print('Loading image    from %r' % image)
    print('Loading solution from %r' % sol)
    
    dtype =[('position', ('int',2)), ('id', ('S', 10))]
    if not os.path.exists(sol):
        print('WARNING: no solution file found.')
        objects = numpy.zeros((0,), dtype)
    else:
        def read_ground_truth(f):
            while True:
                line = f.readline()
                if not line: break
                position = numpy.array([int(x) for x in line.split()])
                id = f.readline().strip()
                yield id, position
        found = list(read_ground_truth(open(sol)))
        objects = numpy.zeros((len(found),), dtype)
        for i, ob in enumerate(found):
            id, position = ob
            objects[i]['position'][:] = position
            objects[i]['id'] = id
            print('Object %s at position %s' % (objects[i]['id'],objects[i]['position'],))
        

    with open(data) as f:
        XYZ = read_shuo_format(f)

    print('Read XYZ of shape {0}'.format(XYZ.shape))

    RGB  = numpy.array(Image.open(image))
    
    print('Read image of shape {0}'.format(RGB.shape))
        
    if RGB.shape != XYZ.shape:
        print('Resize needed -- not implemented yet')
        sys.exit(-1)
    
    data = {'rgb': RGB, 
            'XYZ': XYZ, 
            'objects': objects,
            # 'object_id': object# _id,
            #             'object_position': object_position
            }
    
    print('Saving data to  %r' % mat)
    scipy.io.savemat(mat, data, oned_as='row')
    
if __name__ == '__main__':
    params = sys.argv[1:]
    assert len(params) == 1
    convert(params[0])
    