      subroutine smwsas (smw, smw1, im)
      logical Memb(1)
      integer*2 Memc(1)
      integer*2 Mems(1)
      integer Memi(1)
      integer*4 Meml(1)
      real Memr(1)
      double precision Memd(1)
      complex Memx(1)
      equivalence (Memb, Memc, Mems, Memi, Meml, Memr, Memd, Memx)
      common /Mem/ Memd
      integer smw
      integer smw1
      integer im
      integer i
      integer pdim
      integer ldim
      integer paxis
      integer laxis
      integer nw
      integer dtype
      integer nspec
      integer slen(3)
      real smwc1r
      double precision w1
      double precision dw
      integer sp
      integer str
      integer axno
      integer axval
      integer r
      integer w
      integer cd
      integer mw
      integer ct
      integer smwscn
      integer mwstai
      integer sgeti
      logical fpequd
      logical xerpop
      logical xerflg
      common /xercom/ xerflg
      integer sw0001
      integer*2 st0001(55)
      integer*2 st0002(8)
      integer*2 st0003(55)
      integer*2 st0004(8)
      integer*2 st0005(9)
      integer*2 st0006(8)
      integer*2 st0007(6)
      integer*2 st0008(6)
      integer*2 st0009(6)
      integer*2 st0010(10)
      integer*2 st0011(6)
      integer*2 st0012(11)
      integer*2 st0013(1)
      integer*2 st0014(19)
      save
      integer iyy
      data (st0001(iyy),iyy= 1, 8) / 87, 65, 82, 78, 73, 78, 71, 58/
      data (st0001(iyy),iyy= 9,16) / 32, 68,105,115,112,101,114,115/
      data (st0001(iyy),iyy=17,24) /105,111,110, 32, 97,120,105,115/
      data (st0001(iyy),iyy=25,32) / 32, 37,100, 32,110,111,116, 32/
      data (st0001(iyy),iyy=33,40) /102,111,117,110,100, 46, 32, 85/
      data (st0001(iyy),iyy=41,48) /115,105,110,103, 32, 97,120,105/
      data (st0001(iyy),iyy=49,55) /115, 32, 37,100, 46, 10, 0/
      data st0002 / 68, 67, 45, 70, 76, 65, 71, 0/
      data (st0003(iyy),iyy= 1, 8) / 82,111,116, 97,116,101,100, 44/
      data (st0003(iyy),iyy= 9,16) / 32,100,105,115,112,101,114,115/
      data (st0003(iyy),iyy=17,24) /105,111,110, 32, 99, 97,108,105/
      data (st0003(iyy),iyy=25,32) / 98,114, 97,116,101,100, 32,115/
      data (st0003(iyy),iyy=33,40) /112,101, 99,116,114, 97, 32, 97/
      data (st0003(iyy),iyy=41,48) /114,101, 32,110,111,116, 32, 97/
      data (st0003(iyy),iyy=49,55) /108,108,111,119,101,100, 0/
      data st0004 /108,111,103,105, 99, 97,108, 0/
      data (st0005(iyy),iyy= 1, 8) /112,104,121,115,105, 99, 97,108/
      data (st0005(iyy),iyy= 9, 9) / 0/
      data st0006 / 68, 67, 45, 70, 76, 65, 71, 0/
      data st0007 /108, 97, 98,101,108, 0/
      data st0008 /117,110,105,116,115, 0/
      data st0009 /117,110,105,116,115, 0/
      data (st0010(iyy),iyy= 1, 8) / 97,110,103,115,116,114,111,109/
      data (st0010(iyy),iyy= 9,10) /115, 0/
      data st0011 /108, 97, 98,101,108, 0/
      data (st0012(iyy),iyy= 1, 8) / 87, 97,118,101,108,101,110,103/
      data (st0012(iyy),iyy= 9,11) /116,104, 0/
      data st0013 / 0/
      data (st0014(iyy),iyy= 1, 8) / 78,111, 32,100,105,115,112,101/
      data (st0014(iyy),iyy= 9,16) /114,115,105,111,110, 32, 97,120/
      data (st0014(iyy),iyy=17,19) /105,115, 0/
         if (.not.(smw1 .ne. 0)) goto 110
            call xstrcy(memc(memi(smw1+29) ), memc(memi(smw+29) ), 1023 
     *      )
            memi(smw+1) = memi(smw1+1)
            memi(smw+2) = memi(smw1+2)
            memi(smw+3) = memi(smw1+3)
            call amovi (memi(smw1+1+4) , memi(smw+1+4) , 3)
            memi(smw+8) = memi(smw1+8)
            call amovi (memi(smw1+1+8) , memi(smw+1+8) , 3)
            call amovi (memi(smw1+1+11) , memi(smw+1+11) , 3)
            call amovi (memi(smw1+1+14) , memi(smw+1+14) , 2)
            mw = memi(smw+0+34)
            memi(smw+4) = mwstai (mw, 1 )
            if (.not.(memi(smw+4) .gt. memi(smw1+4) )) goto 120
               do 130 i = memi(smw1+4) +1, memi(smw+4)
                  memi(smw+i+4) = i
130            continue
131            continue
120         continue
            goto 100
110      continue
         call smark (sp)
         call salloc (str, 1023 , 2)
         call salloc (axno, 3, 4)
         call salloc (axval, 3, 4)
         call aclri (memi(axno), 3)
         mw = memi(smw+0+34)
         pdim = mwstai (mw, 1 )
         ldim = memi(im+100)
         call mwgaxp (mw, memi(axno), memi(axval), pdim)
         slen(1) = memi(im+102)
         slen(2) = memi(im+103)
         slen(3) = memi(im+104)
         sw0001=(memi(smw) )
         goto 140
150      continue
            call salloc (r, pdim, 7)
            call salloc (w, pdim, 7)
            call salloc (cd, pdim*pdim, 7)
            memi(smw+3) = 0
            if (.not.(pdim .eq. 2)) goto 160
               call mwgltd (mw, memd(cd), memd(w), pdim)
               if (.not.(memd(cd) .eq. 0d0 .and. memd(cd+3) .eq. 0d0)) 
     *         goto 170
                  memd(cd) = memd(cd+1)
                  memd(cd+1) = 0.
                  memd(cd+3) = memd(cd+2)
                  memd(cd+2) = 0.
                  call mwsltd (mw, memd(cd), memd(w), pdim)
                  paxis = memi(smw+1+4)
                  if (.not.(paxis .eq. 1)) goto 180
                     memi(smw+1+4) = 2
                     goto 181
180               continue
                     memi(smw+1+4) = 1
181               continue
                  memi(smw+3) = 1
                  goto 171
170            continue
               if (.not.(memd(cd+1) .ne. 0d0 .or. memd(cd+2) .ne. 0d0)) 
     *         goto 190
                  memd(w) = 0
                  memd(w+1) = 0
                  memd(cd) = 1
                  memd(cd+1) = 0
                  memd(cd+2) = 0
                  memd(cd+3) = 1
                  call mwsltd (mw, memd(cd), memd(w), pdim)
190            continue
171            continue
160         continue
            paxis = memi(smw+1+4)
            i = max (1, min (pdim, paxis))
            laxis = max (1, memi(axno+i-1))
            if (.not.(slen(laxis) .eq. 1)) goto 200
               do 210 laxis = 1, ldim
                  if (.not.(slen(laxis) .ne. 1)) goto 220
                     goto 211
220               continue
210            continue
211            continue
200         continue
            nspec = 1
            do 230 i = 1, ldim
               if (.not.(i .ne. laxis)) goto 240
                  nspec = nspec * slen(i)
240            continue
230         continue
231         continue
            memi(smw+1) = nspec
            memi(smw+2) = 1
            i = paxis
            do 250 paxis = 1, pdim
               if (.not.(memi(axno+paxis-1) .eq. laxis)) goto 260
                  goto 251
260            continue
250         continue
251         continue
            if (.not.(i .ne. paxis .and. nspec .gt. 1)) goto 270
               call eprinf ( st0001)
               call pargi (i)
               call pargi (paxis)
270         continue
            call mwgwtd (mw, memd(r), memd(w), memd(cd), pdim)
            if (.not.(memi(smw+3) .eq. 1)) goto 280
               memd(cd) = memd(cd+1)
               memd(cd+1) = 0.
               memd(cd+3) = memd(cd+2)
               memd(cd+2) = 0.
280         continue
            if (.not.(pdim .eq. 2 .and. (memd(cd+1) .ne. 0d0 .or. memd(
     *      cd+2) .ne. 0d0))) goto 290
               call xerpsh
               dtype = sgeti (im, st0002)
               if (.not.xerpop()) goto 300
                  dtype = -1
300            continue
               if (.not.(dtype .ne. -1)) goto 310
                  call sfree (sp)
                  call xerror(1, st0003)
                  if (xerflg) goto 100
310            continue
               memd(r) = 0
               memd(r+1) = 0
               memd(w) = 0
               memd(w+1) = 0
               memd(cd) = 1
               memd(cd+1) = 0
               memd(cd+2) = 0
               memd(cd+3) = 1
290         continue
            do 320 i = 0, pdim-1 
               dw = memd(cd+i*(pdim+1))
               if (.not.(dw .eq. 0d0)) goto 330
                  memd(cd+i*(pdim+1)) = 1d0
330            continue
320         continue
321         continue
            call mwswtd (mw, memd(r), memd(w), memd(cd), pdim)
            dw = memd(cd+(paxis-1)*(pdim+1))
            w1 = memd(w+paxis-1) - (memd(r+paxis-1) - 1) * dw
            nw = slen(laxis)
            i = 2 ** (paxis - 1)
            ct = smwscn (smw, st0004, st0005, i)
            if (xerflg) goto 100
            nw = max (smwc1r (ct, 0.5), smwc1r (ct, nw+0.5))
            call smwcte (ct)
            call xerpsh
            dtype = sgeti (im, st0006)
            if (.not.xerpop()) goto 340
               if (.not.(fpequd (1d0, w1) .or. fpequd (1d0, dw))) goto 
     *         350
                  dtype = -1
                  goto 351
350            continue
                  dtype = 0
351            continue
340         continue
            if (.not.(dtype.eq.1)) goto 360
               if (.not.(abs(w1).gt.20. .or. abs(w1+(nw-1)*dw).gt.20.)) 
     *         goto 370
                  dtype = 0
                  goto 371
370            continue
                  w1 = 10d0 ** w1
                  dw = w1 * (10d0 ** ((nw-1)*dw) - 1) / (nw - 1)
371            continue
360         continue
            if (.not.(dtype .ne. -1)) goto 380
               call xerpsh
               call mwgwas (mw,paxis,st0007,memc(str),1023 )
               if (.not.xerpop()) goto 390
                  call xerpsh
                  call mwgwas(mw,paxis,st0008,memc(str),1023 )
                  if (.not.xerpop()) goto 400
                     call mwswas (mw, paxis, st0009, st0010)
                     call mwswas (mw, paxis, st0011, st0012)
400               continue
390            continue
380         continue
            memi(smw+17) = (-2147483647)
            call smwsws (smw, 1, 1, (-2147483647), (-2147483647), dtype,
     *       w1, dw, nw, 0d0, 1.6e38, 1.6e38, st0013)
         goto 141
410      continue
            paxis = 1
            i = memi(axno+1)
            if (.not.(i .eq. 0)) goto 420
               memi(smw+1) = 1
               goto 421
420         continue
               memi(smw+1) = slen(i)
421         continue
            i = memi(axno+2)
            if (.not.(i .eq. 0)) goto 430
               memi(smw+2) = 1
               goto 431
430         continue
               memi(smw+2) = slen(i)
431         continue
            goto 141
140      continue
            sw0001=sw0001+1
            if (sw0001.lt.1.or.sw0001.gt.3) goto 141
            goto (150,410,410),sw0001
141      continue
         laxis = memi(axno+paxis-1)
         if (.not.(laxis .eq. 0)) goto 440
            if (.not.(memi(axval+paxis-1) .eq. 0)) goto 450
               laxis = paxis
               goto 451
450         continue
               call xerror(1, st0014)
               if (xerflg) goto 100
451         continue
440      continue
         memi(smw+4) = pdim
         memi(smw+8) = ldim
         memi(smw+1+4) = paxis
         memi(smw+1+8) = laxis
         memi(smw+1+11) = slen(laxis)
         memi(smw+2+11) = 1
         memi(smw+3+11) = 1
         i = 2
         do 460 laxis = 1, ldim 
            if (.not.(laxis .ne. memi(smw+1+8) )) goto 470
               do 480 paxis = 1, pdim
                  if (.not.(memi(axno+paxis-1) .eq. laxis)) goto 490
                     goto 481
490               continue
480            continue
481            continue
               memi(smw+i+4) = paxis
               memi(smw+i+8) = laxis
               memi(smw+i+11) = slen(laxis)
               i = i + 1
470         continue
460      continue
461      continue
         call smwsad (smw, 0, 1, memc((((im+50)-1)*2+1)))
         call sfree (sp)
100      return
      end
c     mwgwtd  mw_gwtermd
c     mwsltd  mw_sltermd
c     mwstai  mw_stati
c     smwscn  smw_sctran
c     mwgaxp  mw_gaxmap
c     smwc1r  smw_c1tranr
c     smwsad  smw_sapid
c     mwswtd  mw_swtermd
c     smwsws  smw_swattrs
c     mwgwas  mw_gwattrs
c     eprinf  eprintf
c     smwcte  smw_ctfree
c     smwsas  smw_saxes
c     mwswas  mw_swattrs
c     fpequd  fp_equald
c     mwgltd  mw_gltermd
