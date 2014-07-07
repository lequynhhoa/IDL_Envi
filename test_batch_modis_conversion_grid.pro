;Level 3 grid example
pro test_batch_modis_conversion_grid
  compile_opt idl2
  
  ENVI, /RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT, LOG_FILE='BATCH.LOG'
  starttimes = SYSTIME()
  PRINT, 'START : ', starttimes

  ROOT_DIR =  'C:\Users\Hoa\Desktop\Thieu\'
  FNS = FILE_SEARCH(ROOT_DIR,'*.HDF',COUNT = COUNT)
  PRINT, 'There ara totally', COUNT,' images.'

  output_location = 'C:\Users\Hoa\Desktop\Thieu\Output\'
  

  grid_name = 'MODIS_MONTHLY_0.05DEG_CMG_LST' ; view in MCTK
  sd_names = ['LST_Day_CMG']
  
  ;Output method schema is:
  ;0 = Standard, 1 = Reprojected, 2 = Standard and reprojected
  out_method = 0
  output_projection = envi_proj_create(/geographic)

  out_ps_x = 0.008370d
  out_ps_y = 0.008370d

  interpolation_method = 6
  FOR i = 0, COUNT-1  DO BEGIN
    FILENAME = FNS[i]
    key = STRPOS(FILENAME,'M') ; search key character

    output_rootname = STRMID(FILENAME,key+0,16)   ;

  
  convert_modis_data, in_file=FILENAME, $
    out_path=output_location, out_root=output_rootname, $
    /higher_product, /grid, gd_name=grid_name, sd_names=sd_names, $
    out_method=out_method, out_proj=output_projection, $
    out_ps_x=out_ps_x, out_ps_y=out_ps_y, num_x_pts=50, $
    num_y_pts=50, interp_method=interpolation_method, $
    background=-999, fill_replace_value=-999, $
    r_fid_array=r_fid_array, r_fname_array=r_fname_array
    endfor
endtimes =  SYSTIME()
PRINT, 'END : ', endtimes
end