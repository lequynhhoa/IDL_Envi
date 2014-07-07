# pixelExtract.py - pixel extraction script
# Chris Toney, christoney@fs.fed.us
# v. 1.1, 2008-11-24
#   - fixed bug in the mode statistic, now returns nodata if there is not a modal value for an n x n pixel block
# v. 1.0, 2007-06-27
#   - previously was internal version 8.1, this is v. 1.0 for public distribution

import sys
import os
import struct
import operator
import csv
import math
import gdal
from gdalconst import *
import Numeric
from Statistics import *

def usage():
  print
  print 'Usage: pixelExtract.py <rasterListFile> <pointFile> <maskValue> <statistic> <outputFile> <stats|nostats> [referenceRaster]'
  print
  print 'Writes a csv file containing pixel values at each pointX, pointY.'
  print
  print 'rasterListFile - one raster per line, full path to raster dataset'
  print 'pointFile - csv with no header: point id, x, y, optional class id'
  print 'maskValue - size of extraction mask,'
  print '    e.g., 3 for a 3x3 mask, 5 for 5x5 mask, ..., 1 for single-pixel'
  print 'statistic - statistic to return for pixels in mask:'
  print '    For mask = 1, use statistic = 1 (returns the pixel value)'
  print '    For multi-pixel masks, statistic can be sum, mean, median, mode,'
  print '    min, max, range, var, stddev, rsd (stddev relative to mean)'
  print '    Or, statistic = pixelblock will return individual pixels in mask'
  print 'outputFile - full path to file where output should be written'
  print 'stats - compute summary statistics by class id if present in pointFile'
  print 'referenceRaster - optional raster to use as reference for QA. If present,'
  print '    each raster in the input list will be checked against the reference'
  print '    raster for identical values of extent and cell size.'
  print
  return

def extractPixel(gd, band, pntX, pntY, mask, stat):
  if stat == '1' and mask != 1:
    print 'cannot extract single pixel for the specified mask'
    sys.exit()
    
  pntX = float(pntX)
  pntY = float(pntY)
  xSize = gd.RasterXSize
  ySize = gd.RasterYSize

  #get origin and cell size
  gt = gd.GetGeoTransform()
  if not gt is None:
    originX = float(gt[0])
    originY = float(gt[3])
    pixelXSize = abs(float(gt[1]))
    pixelYSize = abs(float(gt[5]))

  #check that point is inside extent rectangle
  maxX = (originX + (xSize * pixelXSize))
  if (pntX > maxX) or (pntX < originX):
    print 'point X value is outside raster extent'
    return 'nodata'
  minY = (originY - (ySize * pixelYSize))
  if (pntY > originY) or (pntY < minY):
    print 'point Y value is outside raster extent'
    return 'nodata'

  #get pixel (offset) that point is in - upper left corner pixel is 0,0
  offXUnits = pntX - originX
  offYUnits = originY - pntY
  offXPixels = int(offXUnits/pixelXSize)
  offYPixels = int(offYUnits/pixelYSize)

  #get data type and nodata value
  band = gd.GetRasterBand(int(band))
  dataType = gdal.GetDataTypeName(band.DataType)
  noDataValue = band.GetNoDataValue()
  if dataType[0:2] == 'Fl' or dataType[0:2] == 'CF':
    isFloat = True
  else:
    isFloat = False

  #get values of pixels defined by mask
  a = band.ReadAsArray((offXPixels - int(mask/2)), (offYPixels - int(mask/2)), mask, mask)
  a_rav = Numeric.ravel(a).tolist()
  values = []
  if operator.isNumberType(noDataValue):
    for x in a_rav:
      if x != float(noDataValue):
        values.append(x)
  else:
    values = a_rav
  
  if len(values) > 0:
    stats = Statistics(values,True)

  # calculate stats on the pixels defined by mask  
  if len(values) == 0:
    pixelValue = 'nodata'
  elif stat == '1':
    pixelValue = values[0]
  elif stat == 'pixelblock':
    pixelValue = str(a_rav) # a_rav is the (Numeric array) pixel block, converted to a list
    pixelValue = pixelValue.replace('[','').replace(']','')
  elif stat == 'sum':
    pixelValue = stats.sum
  elif stat == 'mean':
    pixelValue = stats.mean
  elif stat == 'median':
    pixelValue = stats.median
  elif stat == 'mode':
    if len(values) == 1:
      pixelValue = values[0]
    else:
      if len(stats.mode) > 0:
        pixelValue = stats.mode[0][0]
      else:
        # there is no mode
        pixelValue = 'nodata'
  elif stat == 'min':
    pixelValue = stats.min
  elif stat == 'max':
    pixelValue = stats.max
  elif stat == 'range':
    pixelValue = stats.range
  elif stat == 'var':
    pixelValue = stats.variance
  elif stat == 'stddev':
    pixelValue = stats.stddev
  elif stat == 'rsd' or stat == 'RSD':
    if stats.mean != 0.0:
      pixelValue = (100 * stats.stddev) / abs(stats.mean)
    else:
      pixelValue = 'divByZero'

  if not isFloat and pixelValue != 'nodata' and pixelValue != 'divByZero':
    if stat == '1':
      pixelValue = str(pixelValue)
    elif stat == 'mean' or stat == 'var' or stat == 'stddev' or stat == 'rsd' or stat == 'RSD':
      pixelValue = '%0.4f' % pixelValue
    else:
      pixelValue = str(pixelValue)
  else:
    pixelValue = str(pixelValue)
      
  gt = None
  gd = None
  return pixelValue

if (len(sys.argv) < 7) or (len(sys.argv) > 8):
  usage()
  sys.exit()

# column indices for point file
PE_PID = 0
PE_X = 1
PE_Y = 2
PE_MASKID = 3

# validate and open the raster list file, populate a raster list from file
if os.path.isfile(sys.argv[1]):
  rasterListFile = open(sys.argv[1], 'r')
else:
  print 'raster list file is not valid'
  sys.exit()
rasterList = []
line = rasterListFile.readline().replace('\n','')
if line == '':
  print 'raster list file is empty'
  sys.exit()
while line != '':
  rasterList.append(line)
  line = rasterListFile.readline().replace('\n','')

# validate and open point file
if os.path.isfile(sys.argv[2]):
  pfile = open(sys.argv[2], 'r')
else:
  print 'point file is not valid'
  sys.exit()

mask = int(sys.argv[3])

# validate the requested descriptive statistic for pixel values within mask
statsAvailable = ['1','pixelblock','sum','mean','median','mode','min','max','range','var','stddev','rsd']
statistic = str(sys.argv[4]).lower()
if statistic not in statsAvailable:
  print 'requested statistic is not valid'
  sys.exit()

# validate and open output file
if os.path.isdir(os.path.dirname(sys.argv[5])):
  outfile_name = sys.argv[5]
  outfile = open(outfile_name, 'wb')
else:
  print 'path to output file is not valid'
  sys.exit()

if sys.argv[6] == 'stats':
  outputStats = True
else:
  outputStats = False

# validate and open the reference raster
if len(sys.argv) == 8:
  checkRef = True
  gdata = gdal.Open(sys.argv[7], GA_ReadOnly)
  if gdata is None:
    print 'could not open the reference raster'
    sys.exit() 
  # get reference extent and cell size
  refXSize = gdata.RasterXSize
  refYSize = gdata.RasterYSize
  geotr = gdata.GetGeoTransform()
  if not geotr is None:
    refOriginX = float(geotr[0])
    refOriginY = float(geotr[3])
    refPixelXSize = abs(float(geotr[1]))
    refPixelYSize = abs(float(geotr[5]))
  geotr = None
  gdata = None
else:
  checkRef = False

# creater header row for output file - involves looping over each input raster, so check extent
# and cell size versus the reference raster if one was specified
header = ['ID']
varList = []
for raster in rasterList:
  # get output variable name from raster file name
  if os.path.splitext(raster)[1] == '.adf': # raster is an Arc GRID
    rastername = os.path.split(os.path.split(raster)[0])[1]
  else:
    rastername = os.path.splitext(os.path.split(raster)[1])[0]
  gdata = gdal.Open(raster, GA_ReadOnly)
  if gdata is None:
    print 'could not open raster dataset', raster
    sys.exit()
  if gdata.RasterCount > 1:
    if statistic == 'pixelblock':
        print 'pixelblock extraction not currently supported on multi-band rasters'
        gdata = None
        sys.exit()
    for n in range(1, (gdata.RasterCount + 1)):
      varname = rastername + '_b' + str(n)
      header.append(varname)
      varList.append(varname)
  else:
    if statistic == 'pixelblock':
      for n in range(1, (1+(len(rasterList)*mask*mask))):
        varname = rastername + '_' + str(n)
        header.append(varname)
        varList.append(varname)
    else:
      header.append(rastername)
      varList.append(rastername)

  if checkRef:
    # while we're going over each input raster, compare extent and cell size to the reference raster
    if (gdata.RasterXSize != refXSize) or (gdata.RasterYSize != refYSize):
      print 'raster size does not match reference', raster
      gdata = None
      sys.exit()
    geotr = gdata.GetGeoTransform()
    if not geotr is None:
      if (float(geotr[0]) != refOriginX) or (float(geotr[3]) != refOriginY):
        print 'raster origin does not match reference', raster
        gdata = None
        geotr = None
        sys.exit()
      if (abs(float(geotr[1])) != refPixelXSize) or (abs(float(geotr[5])) != refPixelYSize):
        print 'raster cell size does not match reference', raster
        gdata = None
        geotr = None
        sys.exit()
    else:
      print 'error getting geotransform', raster
      gdata = None
      sys.exit()
    geotr = None
    
  gdata = None

# initialize dictionary for output data matrix, with point id as the key
matrix = {}
statsMatrix = {}
reader = csv.reader(pfile)
for line in reader:
  if matrix.has_key(line[PE_PID]):
    print 'error: duplicate point ids are not supported:', line[PE_PID]
    sys.exit()
  matrix[line[PE_PID]] = []
  if outputStats:
    for varname in varList:
      statsMatrix[(varname,line[PE_MASKID])] = []

# populate output data matrix and optional summary stats matrix with pixel values
col = 0
for raster in rasterList:
  gdata = gdal.Open(raster, GA_ReadOnly)
  for n in range(1, (gdata.RasterCount + 1)):
    col = col + 1
    print raster,n,col
    pfile.seek(0)
    for line in reader:
      pval = extractPixel(gdata, n, line[PE_X], line[PE_Y], mask, statistic)
      if statistic == 'pixelblock':
        matrix[line[PE_PID]] = matrix[line[PE_PID]] + pval.replace(' ','').split(',')
      else:
        matrix[line[PE_PID]] = matrix[line[PE_PID]] + [pval]
      if outputStats:
        statsMatrix[(varList[col-1],line[PE_MASKID])] = statsMatrix[(varList[col-1],line[PE_MASKID])] + [float(pval)]
  gdata = None

pfile.close()

# write output data matrix to file
if statistic == 'pixelblock':
  col = col*mask*mask
writer = csv.writer(outfile)
writer.writerow(header)
pidList = matrix.keys()
pidList.sort()
for pid in pidList:
  outLine = [str(pid)]
  for x in range(0, col):
    outLine.append(matrix[pid][x])
  writer.writerow(outLine)

outfile.close()
print 'output data written to: ', outfile_name

if outputStats:
  outStatsFile = open(os.path.splitext(outfile_name)[0] + '_sta.csv', 'wb')
  writer = csv.writer(outStatsFile)
  varMaskList = statsMatrix.keys()
  varMaskList.sort()
  header = ['variable','maskid','N','median','mean','stddev','sem']
  writer.writerow(header)
  for varMask in varMaskList:
    sumStats = Statistics(statsMatrix[varMask])
    outLine = [varMask[0],varMask[1],str(sumStats.N),str(sumStats.median),str(sumStats.mean),str(sumStats.stddev),str((sumStats.stddev/math.sqrt(sumStats.N)))]
    writer.writerow(outLine)
  outStatsFile.close()
  print 'summary stats written to: ', os.path.splitext(outfile_name)[0] + '_sta.csv'
