; Use to for Ocean product
PRO Reproject_ocean_folder
  COMPILE_OPT IDL2
  
  ENVI, /RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT, LOG_FILE='BATCH.LOG'
        starttimes = SYSTIME()
        PRINT, 'START : ', starttimes
      
        FNS = File_search('z:\Hoa.lq\IMAGE SATELLITE\@original data\MODIS\SST\27.08-09\','*.L2_LAC_SST',COUNT = COUNT)
     
  
        output_location = 'z:\Hoa.lq\IMAGE SATELLITE\@original data\MODIS\SST\27.08-09\'

  
  ; Neu project theo UTM 84 thi:
  ;proj = envi_proj_create(/utm, zone=48, datum='WGS-84')
  ;ps = [500.0d,500.0d] ; Do phan giai 500meters 
  
  PROJ = ENVI_PROJ_CREATE(/geographic, datum='WGS-84')
  PS = [ 0.004187D,0.004187D] ; tuong ung vs do phan giai 500m
  NO_BOWTIE = 0 ;SAME AS NOT SETTING THE KEYWORD
  NO_MSG = 1 ;SAME AS SETTING THE KEYWORD

  ;OUTPUT CHOICES
  ;0 -> STANDARD PRODUCT ONLY
  ;1 -> GEOREFERENCED PRODUCT ONLY
  ;2 -> STANDARD AND GEOREFERENCED PRODUCTS
  OUTPUT_CHOICE = 2

FOR i = 0, COUNT-1  DO BEGIN
            FILENAME = FNS[i]     

  ;RETURNED VALUES
  ;R_FID -> ENVI FID FOR THE STANDARD PRODUCT, IF REQUESTED
  ;GEOREF_FID -> ENVI FID FOR THE GEOREFERENCED PRODUCT, IF REQUESTED
  CONVERT_OC_L2_DATA, FNAME=FNAME, OUTPUT_PATH=output_location , $
    PROJ=PROJ, PS=PS, OUTPUT_CHOICE=OUTPUT_CHOICE, R_FID=R_FID, $
    GEOREF_FID=GEOREF_FID, NO_BOWTIE=NO_BOWTIE, NO_MSG=NO_MSG   
       endfor
        endtimes =  SYSTIME()
        PRINT, 'END : ', endtimes
        
      end