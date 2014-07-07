pro test_reproject_ocean
  compile_opt idl2
  
  fname = 'c:\Temp\create_idl_test\SST\A2013177064000.L2_LAC_SST'

  output_path = 'c:\Temp\create_idl_test\SST\'
  
  
  
 ; If origin file is UTM 84:
  ;proj = envi_proj_create(/utm, zone=48, datum='WGS-84')
  ;ps = [500.0d,500.0d] ; Do phan giai 500meters 
   
 PROJ = ENVI_PROJ_CREATE(/geographic, datum='WGS-84')
  PS = [ 0.004187D,0.004187D] ; tuong ung vs do phan giai 500m
  NO_BOWTIE = 0 ;SAME AS NOT SETTING THE KEYWORD
  NO_MSG = 1 ;SAME AS SETTING THE KEYWORD


  ;OUTPUT CHOICES
  ;0 -> standard product only
  ;1 -> georeferenced product only
  ;2 -> standard and georeferenced products
  output_choice = 2

  ;RETURNED VALUES
  ;r_fid -> ENVI FID for the standard product, if requested
  ;georef_fid -> ENVI FID for the georeferenced product, if requested
  convert_oc_l2_data, fname=fname, output_path=output_path, $
    proj=proj, ps=ps, output_choice=output_choice, r_fid=r_fid, $
    georef_fid=georef_fid, no_bowtie=no_bowtie, no_msg=no_msg   

  print, r_fid
  print, georef_fid
  
end