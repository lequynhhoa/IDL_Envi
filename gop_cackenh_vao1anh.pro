; Gop cac kênh từ nhiều ảnh vào 1 ảnh

pro gop_cackenh_vao1anh


ENVI_BATCH_INIT, LOG_FILE = 'batch_log.txt'

; Find file in working director G:\Backup\Hoa.lq\temp\Landsat
files = FINDFILE('G:\Backup\Hoa.lq\temp\Landsat\*.tif', count=count)

;Indentify parameters
fid = lonarr(count)
pos = lonarr(count)
dims = lonarr(5,count)
out_bname = strarr(count)

; Loop in files Landsat\
;FOR j= 0,6 DO BEGIN

j=0 ; 
  FOR i=0,count-1 DO BEGIN
    ;Open file
      envi_open_data_file, files(i), r_fid=layer_fid
      if (layer_fid eq -1) then begin
        envi_batch_exit
        return
      endif

    ; Querry informations from input
    ENVI_FILE_QUERY, layer_fid, NS = ns, NL = nl, NB = nb, sname=sname

    ; Parameters 
    fid[i] = layer_fid
    pos[i] = j
    dims[0,i] = [-1,0,ns-1,0,nl-1]
    out_bname[i] = STRMID(sname,STRPOS(sname,''),24)  
   Endfor
   
; Output file G:\Backup\Hoa.lq\temp\Landsat\
     out_name = 'G:\Backup\Hoa.lq\temp\Landsat\'+STRMID(sname,STRPOS(sname,''),16)+'_stacking';     + string((1*j+1))   ;+'.tif'  ;

; Setting parameter format (float, ...)
  out_dt = 4 ; 4 là định dạng kiểu float
  out_proj = envi_get_projection(fid=layer_fid, pixel_size=out_ps)

  ; Function layer stacking
envi_doit, 'envi_layer_stacking_doit', $
    fid=fid, pos=pos, dims=dims, $
    out_dt=out_dt, out_name=out_name, $
    out_bname = out_bname, $
    interp=2, out_ps=out_ps, $
    out_proj=out_proj, r_fid=r_fid

;Endfor  

ENVI_BATCH_EXIT

END