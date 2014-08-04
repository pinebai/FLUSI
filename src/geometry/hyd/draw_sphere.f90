! Spherical obstacle
subroutine draw_sphere
  use mpi
  use fsi_vars
  implicit none

  integer :: ix, iy, iz
  real (kind=pr) :: x, y, z, tmp, R, N_smooth

  N_smooth = 1.5d0

  do ix=ra(1),rb(1)
    do iy=ra(2),rb(2)
      do iz=ra(3),rb(3)
        x=dble(ix)*dx
        y=dble(iy)*dy
        z=dble(iz)*dz
        R = dsqrt( (x-x0)**2 + (y-y0)**2 + (z-z0)**2 )
        if ( R <= 0.5d0*length+2.d0*N_smooth*max(dx,dy,dz) ) then
          call SmoothStep (tmp, R, 0.5d0*length , N_smooth*max(dx,dy,dz))
          mask (ix, iy, iz) = tmp

          ! assign color "1" where >0 indicates something "useful"
          if (tmp > 1.0e-12) mask_color(ix,iy,iz) = 1
        endif
      enddo
    enddo
  enddo
end subroutine draw_sphere



! cavity as used by romain for "open cavity" tests. the wall is from 
! -2 ... -1 and +1 ... +2
! xxxx------------xxxx
! constant in all other directions
subroutine romain_open_cavity
  use mpi
  use fsi_vars
  implicit none

  integer :: ix, iy, iz
  real (kind=pr) :: x, y, z

  do ix=ra(1),rb(1)
    do iy=ra(2),rb(2)
      do iz=ra(3),rb(3)
        x=dble(ix)*dx - 0.5*xl
        if (x<=-1.d0 .or. x>=+1.d0 ) then
          mask (ix, iy, iz) = 1.d0
          us (ix,iy,iz,1:3) = 0.d0
          ! assign color "1" where >0 indicates something "useful"
          mask_color(ix,iy,iz) = 1
        endif
      enddo
    enddo
  enddo
end subroutine romain_open_cavity


