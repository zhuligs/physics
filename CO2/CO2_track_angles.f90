!       program CO2_track_angles.f90
!***********************************************************
!       Calculates CO2 bond angles from .mol file and
!       tracks them over time for individual molecules
!***********************************************************
        implicit none
        
        integer maxSteps, maxAtoms, maxBins, i, j, k, f
        parameter (maxSteps=100000,maxAtoms=1024, maxBins=1000)
        integer natom, nC, nO, nSteps, bin, norm, nn(maxAtoms,2), pbc_round(3)
        real*8 X(maxAtoms), Y(maxAtoms), Z(maxAtoms)
        real*8 ax, ay, az, dx, dy, dz, r, tstep
        real*8 A(3), B(3), Amag, Bmag, dot, angle
        real*8 input_value(3), angles(maxAtoms,maxSteps)
        character*8 typat(maxAtoms), d1, d2, d3
        character*532 fmol, fmt

        ! Retrieve user input
        write(*,*) 'Name of .mol file'
        read(*,*) fmol
        write(*,*) 'Time step in fs'
        read(*,*) tstep

        ! Open .cnn and output files
        open(1,file=fmol,status='old',ERR=90)
        open(2,file='CO2_tracked_angles.dat')

        ! Read in .cnn header
        read(1,*,END=100) d1, d2, d3, natom
        read(1,*) d1, d2, d3, nC
        read(1,*) d1, d2, d3, nO
        read(1,*) 
        read(1,*) d1, d2, d3, ax
        read(1,*) d1, d2, d3, ay
        read(1,*) d1, d2, d3, az
        read(1,*) 
        read(1,*) 
        read(1,*) 

        ! Perform analysis
        do i=1,maxSteps

          do j=1,natom
            read(1,*,END=110) typat(j), X(j), Y(j), Z(j), nn(j,1), nn(j,2)
          enddo

          do j=1,nC
            if ((nn(j,1).ne.0).and.(nn(j,2).ne.0)) then

              dx = X(j) - X(nn(j,1))
              dy = Y(j) - Y(nn(j,1))
              dz = Z(j) - Z(nn(j,1))
              input_value(1) = dx/ax
              input_value(2) = dy/ay
              input_value(3) = dz/az
              pbc_round(1) = int(input_value(1))
              pbc_round(2) = int(input_value(2))
              pbc_round(3) = int(input_value(3))
              if (abs(input_value(1)-pbc_round(1)).ge.0.5) then
                if (input_value(1).gt.0) pbc_round(1) = pbc_round(1) + 1
                if (input_value(1).lt.0) pbc_round(1) = pbc_round(1) - 1
              endif
              if (abs(input_value(2)-pbc_round(2)).ge.0.5) then
                if (input_value(2).gt.0) pbc_round(2) = pbc_round(2) + 1
                if (input_value(2).lt.0) pbc_round(2) = pbc_round(2) - 1
              endif
              if (abs(input_value(3)-pbc_round(3)).ge.0.5) then
                if (input_value(3).gt.0) pbc_round(3) = pbc_round(3) + 1
                if (input_value(3).lt.0) pbc_round(3) = pbc_round(3) - 1
              endif
              A(1) = dx - ax*pbc_round(1)
              A(2) = dy - ay*pbc_round(2)
              A(3) = dz - az*pbc_round(3)
              r = ( A(1)**2 + A(2)**2 + A(3)**2 )**0.5  
              if (r.gt.((ax**2+ay**2+az**2)**0.5)/2.0) then
                write(*,*) "WARNING --- PROBLEM WITH PBC"
                goto 100
              endif

              dx = X(j) - X(nn(j,2))
              dy = Y(j) - Y(nn(j,2))
              dz = Z(j) - Z(nn(j,2))
              input_value(1) = dx/ax
              input_value(2) = dy/ay
              input_value(3) = dz/az
              pbc_round(1) = int(input_value(1))
              pbc_round(2) = int(input_value(2))
              pbc_round(3) = int(input_value(3))
              if (abs(input_value(1)-pbc_round(1)).ge.0.5) then
                if (input_value(1).gt.0) pbc_round(1) = pbc_round(1) + 1
                if (input_value(1).lt.0) pbc_round(1) = pbc_round(1) - 1
              endif
              if (abs(input_value(2)-pbc_round(2)).ge.0.5) then
                if (input_value(2).gt.0) pbc_round(2) = pbc_round(2) + 1
                if (input_value(2).lt.0) pbc_round(2) = pbc_round(2) - 1
              endif
              if (abs(input_value(3)-pbc_round(3)).ge.0.5) then
                if (input_value(3).gt.0) pbc_round(3) = pbc_round(3) + 1
                if (input_value(3).lt.0) pbc_round(3) = pbc_round(3) - 1
              endif
              B(1) = dx - ax*pbc_round(1)
              B(2) = dy - ay*pbc_round(2)
              B(3) = dz - az*pbc_round(3)
              r = ( B(1)**2 + B(2)**2 + B(3)**2 )**0.5  
              if (r.gt.((ax**2+ay**2+az**2)**0.5)/2.0) then
                write(*,*) "WARNING --- PROBLEM WITH PBC"
                goto 100
              endif

              ! Calculate the angle
              dot = A(1)*B(1) + A(2)*B(2) + A(3)*B(3)
              Amag = (A(1)**2+A(2)**2+A(3)**2)**0.5
              Bmag = (B(1)**2+B(2)**2+B(3)**2)**0.5
              angle = acos(dot/(Amag*Bmag)) * (180.0/3.141592653590)

              angles(j,i) = angle

            endif
          enddo
        enddo

 110    continue

        nSteps = i - 1

        ! Create the format string
        fmt = '('
        f = 1
        do j=1,nC
          fmt = fmt(1:f) // 'f10.6,x,'
          f = f + 8
        enddo
        fmt = fmt(1:f) // 'f10.6)'

        ! Write angular trajectories to file
        do i=1,nSteps
          write(2,fmt) (i-1)*tstep/1000.0, (angles(j,i),j=1,nC)
        enddo

 100    continue

        close(1)
        close(2)

 90     continue

        END
