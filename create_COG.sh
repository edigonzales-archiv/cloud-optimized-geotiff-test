#!/bin/bash

BASEPATH=/vagrant/12_5cm/
OUTPATH=/vagrant/12_5cm/cot/
OUTPATH_TMP=/vagrant/12_5cm/tmp/

for FILE in ${BASEPATH}*.tif
do
  echo $FILE
  BASENAME=$(basename $FILE .tif)
  OUTFILE=${OUTPATH}/${BASENAME}.tif
  OUTFILE_TMP=${OUTPATH_TMP}/${BASENAME}.tif
  
  echo "Processing: ${BASENAME}.tif"
  if [ -f $OUTFILE ] #skip if exists
  then
    echo "Skipping: $OUTFILE"
  else    
    gdaladdo -clean $FILE
    gdal_translate -of GTiff -co 'TILED=YES' -of GTiff -co 'COPY_SRC_OVERVIEWS=YES' -co 'PROFILE=GeoTIFF' -co 'COMPRESS=DEFLATE' -co 'BLOCKXSIZE=256' -co 'BLOCKYSIZE=256' -a_srs epsg:2056 $FILE $OUTFILE_TMP
    gdaladdo -r average --config COMPRESS_OVERVIEW DEFLATE --config BLOCKXSIZE 256 --config BLOCKXSIZE 256 $OUTFILE_TMP 2 4 8 16 32
    gdal_translate -of GTiff -co 'COPY_SRC_OVERVIEWS=YES' -co 'TILED=YES' -co 'PROFILE=GeoTIFF' -co 'COMPRESS=JPEG' -co 'PHOTOMETRIC=YCBCR' -co 'BLOCKXSIZE=256' -co 'BLOCKYSIZE=256' -a_srs epsg:2056 $OUTFILE_TMP $OUTFILE
    rm $OUTFILE_TMP
  fi
done

#-co 'PHOTOMETRIC=YCBCR' 
#gdalbuildvrt ${OUTPATH}/swissalti3dgrau.vrt ${OUTPATH}swiss_1.tif