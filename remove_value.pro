 ; Remove vaule based on conditional...Then export file .tiff
 ; Ngay 07/10/2013: fix- Hoa Le
 Pro remove_value
  envi_batch_init, log_file='batch_log.txt'
  
  files = DIALOG_PICKFILE(PATH='c:\Temp\Modis_test_idl\', filter='*.tif',/multiple_files)
  if files[0] eq '' then return
  
  for i=0, n_elements(files) -1 do begin
      envi_open_file,files[i], r_fid = fid
      if (fid eq -1) then begin
      envi_batch_exit
      return
      endif
      
      envi_file_query, fid, ns=ns, nl=nl 
      t_fid = [fid]
      dims = [-1, 0, ns-1, 0, nl-1]
      pos = [0]
      
      exp1='(float(b1) gt 13)*(float(b1))' ; hoac (exp1='float(b1)/(float (b1) gt 13)') ;  Loại bỏ những giá trị nhiệt độ nhỏ hơn 13 độ về NAN
     
      out_name = strmid(files[i],0,strlen(files[i])-4) + '_remove'
      
      envi_doit, 'math_doit', $
      fid=t_fid, pos=pos, dims=dims, exp=exp1, out_name=out_name, $
      r_fid=n_fid
      
      envi_output_to_external_format, /tiff, FID=N_FID, pos=pos, dims=dims,$
      out_name=out_name+'.tif'
      
    endfor
 envi_batch_exit
end