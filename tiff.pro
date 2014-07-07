
; idl mở file .img, (.hdr), sau do xuat file theo kieu select
pro tiff
; Select file anh, de cbi xuat ra tiff
ENVI_BATCH_INIT, LOG_FILE = 'batch_log.txt'

FNS=Dialog_pickfile(PATH='c:\Temp\Modis_test_idl\',filter='*.hdr', /MULTIPLE_FILES)

 for i=0, n_elements(FNS) -1 do begin
      envi_open_file,FNS[i], r_fid = fid
      if (fid eq -1) then begin
      envi_batch_exit
      return
      endif
      
      envi_file_query, fid, ns=ns, nl=nl, dims=dims 
      dims=dims
      pos
      out_name = strmid(FNS[i],0,strlen(FNS[i])-4) 

envi_select, dims=dims, pos=pos, fid=fid

envi_output_to_external_format,fid=fid,$
dims=dims,$
pos=pos,$
/tiff,$
out_name=out_name+'_abcd'+'.tif'

endfor
envi_batch_exit
END