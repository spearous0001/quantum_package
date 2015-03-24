subroutine save_casino
 use bitmasks
 implicit none
 character*(128) :: message
 integer                        :: getUnitAndOpen, iunit
 integer, allocatable           :: itmp(:)
 integer                        :: n_ao_new
 real, allocatable              :: rtmp(:)
 PROVIDE ezfio_filename

 iunit = getUnitAndOpen('gwfn.data','w')
 print *, 'Title?'
 read(*,*) message
 write(iunit,'(A)') trim(message)
 write(iunit,'(A)') ''
 write(iunit,'(A)') 'BASIC_INFO'
 write(iunit,'(A)') '----------'
 write(iunit,'(A)') 'Generated by:'
 write(iunit,'(A)') 'Quantum package'
 write(iunit,'(A)') 'Method:'
 print *, 'Method?'
 read(*,*) message
 write(iunit,'(A)') trim(message)
 write(iunit,'(A)') 'DFT Functional:'
 write(iunit,'(A)') 'none'
 write(iunit,'(A)') 'Periodicity:'
 write(iunit,'(A)') '0'
 write(iunit,'(A)') 'Spin unrestricted:'
 write(iunit,'(A)') '.false.'
 write(iunit,'(A)') 'nuclear-nuclear repulsion energy (au/atom):'
 write(iunit,*) nuclear_repulsion
 write(iunit,'(A)') 'Number of electrons per primitive cell:'
 write(iunit,*) elec_num
 write(iunit,*) ''


 write(iunit,*) 'GEOMETRY'
 write(iunit,'(A)') '--------'
 write(iunit,'(A)') 'Number of atoms:'
 write(iunit,*) nucl_num
 write(iunit,'(A)') 'Atomic positions (au):'
 integer                        :: i
 do i=1,nucl_num
   write(iunit,'(3(1PE20.13))') nucl_coord(i,1:3)
 enddo
 write(iunit,'(A)') 'Atomic numbers for each atom:'
 ! Add 200 if pseudopotential
 allocate(itmp(nucl_num))
 do i=1,nucl_num
   itmp(i) = int(nucl_charge(i))
 enddo
 write(iunit,'(8(I10))') itmp(1:nucl_num)
 deallocate(itmp)
 write(iunit,'(A)') 'Valence charges for each atom:'
 write(iunit,'(4(1PE20.13))') nucl_charge(1:nucl_num)
 write(iunit,'(A)') ''


 write(iunit,'(A)') 'BASIS SET'
 write(iunit,'(A)') '---------'
 write(iunit,'(A)') 'Number of Gaussian centres'
 write(iunit,*) nucl_num
 write(iunit,'(A)') 'Number of shells per primitive cell'
 integer :: icount
 icount = 0
 do i=1,ao_num
  if (ao_l(i) == ao_power(i,1)) then
    icount += 1
  endif
 enddo
 write(iunit,*) icount
 write(iunit,'(A)') 'Number of basis functions (''AO'') per primitive cell'
 icount = 0
 do i=1,ao_num
  if (ao_l(i) == ao_power(i,1)) then
    icount += 2*ao_l(i)+1
  endif
 enddo
 n_ao_new = icount
 write(iunit,*) n_ao_new
 write(iunit,'(A)') 'Number of Gaussian primitives per primitive cell'
 allocate(itmp(ao_num))
 integer :: l
 l=0
 do i=1,ao_num
   if (ao_l(i) == ao_power(i,1)) then
     l += 1
     itmp(l) = ao_prim_num(i)
   endif
 enddo
 write(iunit,'(8(I10))') sum(itmp(1:l))
 write(iunit,'(A)') 'Highest shell angular momentum (s/p/d/f... 1/2/3/4...)'
 write(iunit,*) maxval(ao_l(1:ao_num))+1
 write(iunit,'(A)') 'Code for shell types (s/sp/p/d/f... 1/2/3/4/5...)'
 l=0
 do i=1,ao_num
   if (ao_l(i) == ao_power(i,1)) then
     l += 1
     if (ao_l(i) > 0) then
       itmp(l) = ao_l(i)+2
     else
       itmp(l) = ao_l(i)+1
     endif
   endif
 enddo
 write(iunit,'(8(I10))') itmp(1:l)
 write(iunit,'(A)') 'Number of primitive Gaussians in each shell'
 l=0
 do i=1,ao_num
   if (ao_l(i) == ao_power(i,1)) then
     l += 1
     itmp(l) = ao_prim_num(i)
   endif
 enddo
 write(iunit,'(8(I10))') itmp(1:l)
 deallocate(itmp)
 write(iunit,'(A)') 'Sequence number of first shell on each centre'
 allocate(itmp(nucl_num))
 l=0
 icount = 1
 itmp(icount) = 1
 do i=1,ao_num
  if (ao_l(i) == ao_power(i,1)) then
    l = l+1
    if (ao_nucl(i) == icount) then
      continue
    else if (ao_nucl(i) == icount+1) then
      icount += 1
      itmp(icount) = l
    else
      print *, 'Problem in order of centers of basis functions'
      stop 1
    endif
  endif
 enddo
 ! Check
 if (icount /= nucl_num) then
   print *,  'Error :'
   print *,  ' icount :', icount
   print *,  ' nucl_num:', nucl_num
   stop 2
 endif
 write(iunit,'(8(I10))') itmp(1:nucl_num)
 deallocate(itmp)
 write(iunit,'(A)') 'Exponents of Gaussian primitives'
 allocate(rtmp(ao_num))
 l=0
 do i=1,ao_num
   if (ao_l(i) == ao_power(i,1)) then
     do j=1,ao_prim_num(i)
       l+=1
       rtmp(l) = ao_expo(i,ao_prim_num(i)-j+1)
     enddo
   endif
 enddo
 write(iunit,'(4(1PE20.13))') rtmp(1:l)
 write(iunit,'(A)') 'Normalized contraction coefficients'
 l=0
 integer :: j
 do i=1,ao_num
   if (ao_l(i) == ao_power(i,1)) then
     do j=1,ao_prim_num(i)
       l+=1
       rtmp(l) = ao_coef(i,ao_prim_num(i)-j+1)
     enddo
   endif
 enddo
 write(iunit,'(4(1PE20.13))') rtmp(1:l)
 deallocate(rtmp)
 write(iunit,'(A)') 'Position of each shell (au)'
 l=0
 do i=1,ao_num
   if (ao_l(i) == ao_power(i,1)) then
     write(iunit,'(3(1PE20.13))') nucl_coord( ao_nucl(i), 1:3 )
   endif
 enddo
 write(iunit,'(A)') 
 

 write(iunit,'(A)') 'MULTIDETERMINANT INFORMATION'
 write(iunit,'(A)') '----------------------------'
 write(iunit,'(A)') 'GS'
 write(iunit,'(A)') 'ORBITAL COEFFICIENTS'
 write(iunit,'(A)') '------------------------'

 ! Transformation cartesian -> spherical
 double precision :: tf2(6,5), tf3(10,7), tf4(15,9)
 integer :: check2(3,6), check3(3,10),  check4(3,15)
 check2(:,1)  = (/ 2, 0, 0 /)
 check2(:,2)  = (/ 1, 1, 0 /)
 check2(:,3)  = (/ 1, 0, 1 /)
 check2(:,4)  = (/ 0, 2, 0 /)
 check2(:,5)  = (/ 0, 1, 1 /)
 check2(:,6)  = (/ 0, 0, 2 /)

 check3(:,1)  = (/ 3, 0, 0 /)
 check3(:,2)  = (/ 2, 1, 0 /)
 check3(:,3)  = (/ 2, 0, 1 /)
 check3(:,4)  = (/ 1, 2, 0 /)
 check3(:,5)  = (/ 1, 1, 1 /)
 check3(:,6)  = (/ 1, 0, 2 /)
 check3(:,7)  = (/ 0, 3, 0 /)
 check3(:,8)  = (/ 0, 2, 1 /)
 check3(:,9)  = (/ 0, 1, 2 /)
 check3(:,10) = (/ 0, 0, 3 /)

 check4(:,1)  = (/ 4, 0, 0 /)
 check4(:,2)  = (/ 3, 1, 0 /)
 check4(:,3)  = (/ 3, 0, 1 /)
 check4(:,4)  = (/ 2, 2, 0 /)
 check4(:,5)  = (/ 2, 1, 1 /)
 check4(:,6)  = (/ 2, 0, 2 /)
 check4(:,7)  = (/ 1, 3, 0 /)
 check4(:,8)  = (/ 1, 2, 1 /)
 check4(:,9)  = (/ 1, 1, 2 /)
 check4(:,10) = (/ 1, 0, 3 /)
 check4(:,11) = (/ 0, 4, 0 /)
 check4(:,12) = (/ 0, 3, 1 /)
 check4(:,13) = (/ 0, 2, 2 /)
 check4(:,14) = (/ 0, 1, 3 /)
 check4(:,15) = (/ 0, 0, 4 /)

! tf2 = (/
!    -0.5, 0, 0, -0.5, 0, 1.0, &
!    0, 0, 1.0, 0, 0, 0, &
!    0, 0, 0, 0, 1.0, 0, &
!    0.86602540378443864676, 0, 0, -0.86602540378443864676, 0, 0, &
!    0, 1.0, 0, 0, 0, 0, &
!  /)
!  tf3 = (/
!    0, 0, -0.67082039324993690892, 0, 0, 0, 0, -0.67082039324993690892, 0, 1.0, &
!    -0.61237243569579452455, 0, 0, -0.27386127875258305673, 0, 1.0954451150103322269, 0, 0, 0, 0, &
!    0, -0.27386127875258305673, 0, 0, 0, 0, -0.61237243569579452455, 0, 1.0954451150103322269, 0, &
!    0, 0, 0.86602540378443864676, 0, 0, 0, 0, -0.86602540378443864676, 0, 0, &
!    0, 0, 0, 0, 1.0, 0, 0, 0, 0, 0, &
!    0.790569415042094833, 0, 0, -1.0606601717798212866, 0, 0, 0, 0, 0, 0, &
!    0, 1.0606601717798212866, 0, 0, 0, 0, -0.790569415042094833, 0, 0, 0, &
!  /)
!  tf4 = (/
!    0.375, 0, 0, 0.21957751641341996535, 0, -0.87831006565367986142, 0, 0, 0, 0, 0.375, 0, -0.87831006565367986142, 0, 1.0, &
!    0, 0, -0.89642145700079522998, 0, 0, 0, 0, -0.40089186286863657703, 0, 1.19522860933439364, 0, 0, 0, 0, 0, &
!    0, 0, 0, 0, -0.40089186286863657703, 0, 0, 0, 0, 0, 0, -0.89642145700079522998, 0, 1.19522860933439364, 0, &
!    -0.5590169943749474241, 0, 0, 0, 0, 0.9819805060619657157, 0, 0, 0, 0, 0.5590169943749474241, 0, -0.9819805060619657157, 0, 0, &
!    0, -0.42257712736425828875, 0, 0, 0, 0, -0.42257712736425828875, 0, 1.1338934190276816816, 0, 0, 0, 0, 0, 0, &
!    0, 0, 0.790569415042094833, 0, 0, 0, 0, -1.0606601717798212866, 0, 0, 0, 0, 0, 0, 0, &
!    0, 0, 0, 0, 1.0606601717798212866, 0, 0, 0, 0, 0, 0, -0.790569415042094833, 0, 0, 0, &
!    0.73950997288745200532, 0, 0, -1.2990381056766579701, 0, 0, 0, 0, 0, 0, 0.73950997288745200532, 0, 0, 0, 0, &
!    0, 1.1180339887498948482, 0, 0, 0, 0, -1.1180339887498948482, 0, 0, 0, 0, 0, 0, 0, 0, &
!  /)
!
  

 allocate(rtmp(ao_num*mo_tot_num))
 l=0
 do i=1,mo_tot_num
   do j=1,ao_num
     l += 1
     rtmp(l) = mo_coef(j,i)
   enddo
 enddo
 write(iunit,'(4(1PE20.13))') rtmp(1:l)
 deallocate(rtmp)
 close(iunit) 
end

program prog_save_casino
  call save_casino
end
