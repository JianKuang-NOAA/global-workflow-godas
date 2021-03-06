      SUBROUTINE GETGRP(GRPMAP,LUGRB,LUGRBIX,IFCSTHR)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM:    GETGRP      GET GRPMAP FROM INPUT CONTROLS.
C   PRGMMR: KRISHNA KUMAR         ORG: W/NP12    DATE: 1999-08-01
C
C ABSTRACT: GET CONSTANTS FROM INPUT CONTROLS.
C
C PROGRAM HISTORY LOG:
C   96-03-01  ORIGINAL AUTHOR  LUKE LIN
C   96-08-25  LUKE LIN      MODIFY FOR READING IL CONSTANTS.
C 1999-08-01  KRISHNA KUMAR CONVERTED THIS CODE FROM CRAY TO IBM
C                           RS/6000. 
C
C USAGE:    CALL GETGRP(GRPMAP,LUGRB,LUGRBIX,IFCSTHR)
C   OUTPUT ARGUMENT LIST:
C     GRPMAP   - NUMBER OF MAPS TO BE MADE IN THIS FORECAST GROUP
C     LUGRB    - GRIB FILE UNIT NUMBER FOR THIS FORECAST GROUP
C     LUGRBIX  - GRIB INDEX FILE UNIT NUMBER FOR THIS FORECAST GROUP
C     IFCSTHR  - FORECAST HOUR FOR THIS GROUP
C
C ATTRIBUTES:
C   LANGUAGE: F90
C   MACHINE:  IBM
C
C$$$
C
C
      COMMON / ILCON / MAP(15)
      INTEGER       MAP
C
      INTEGER       GRPMAP
      INTEGER       LUGRB
      INTEGER       LUGRBIX
      INTEGER       IFCSTHR
      CHARACTER*1   COMENT
      CHARACTER*5   CGRPMP
      CHARACTER*5   COPTION
C
      CHARACTER*80  CARD
C
      CHARACTER*5   CILCON1
      CHARACTER*5   CILCON2
      CHARACTER*5   CILCON3
      CHARACTER*5   CILCON4
      CHARACTER*6   BGNAME
      CHARACTER*8   BG2NAME
C
      LOGICAL       FLAGGET
C
       integer       iacc
       character*8   cacc
       equivalence  (iacc,cacc)
C
      DATA          CGRPMP    /'GRPM:'/
      DATA          COMENT    /'!'/
C
      DATA          CILCON1   /'ILC1:'/
      DATA          CILCON2   /'ILC2:'/
      DATA          CILCON3   /'ILC3:'/
      DATA          CILCON4   /'ILC4:'/

C
C ------------ STARTS ----------------------------------
C
      FLAGGET = .FALSE.
C
  100 CONTINUE
C
C     .... READ ONE INPUT CARD
C
         READ(15,FMT='(A)')CARD(1:80)
         WRITE(6,FMT='('' '',A)')CARD(1:80)
C        IF ( CARD(1:1) .EQ. COMENT ) GOTO 100
C        ... IT IS A COMMENT CARD
         COPTION = CARD(3:7)
C
         IF (COPTION .EQ. CGRPMP) THEN
C
C            READ THIS GROUP FORECAST MAPS
C
             FLAGGET = .TRUE.
C
             READ (CARD,105)GRPMAP,LUGRB,LUGRBIX,IFCSTHR
  105          FORMAT(15X,I2,9X,I2,9X,I2,9X,I3)
               PRINT *, ' '
               PRINT *, ' PROCESSING FORECAST HOUR:',IFCSTHR
               PRINT *, ' NO OF MAP OF THIS FCST HOUR:',GRPMAP
               PRINT *, ' GRIB FILE AND INDEX FILE:',LUGRB,LUGRBIX
C
         ELSE IF (COPTION .EQ. CILCON1) THEN
             READ(CARD,FMT='(8X,A6,9(1X,I4))')BGNAME,(MAP(NN),NN=2,10)
             CACC(1:6)=BGNAME
             MAP(1) = IACC
             PRINT *, ' BACKGROUND=',CACC
         ELSE IF (COPTION .EQ. CILCON2) THEN
             READ(CARD,FMT='(14X,5(1X,I4))')(MAP(NN),NN=11,15)
             RETURN
C
         ELSE IF (COPTION .EQ. CILCON3) THEN
             READ(CARD,FMT='(8X,A8,1X,I4,2(2(1X,I6),2(1X,I4)))')
     1            BG2NAME,(MAP(NN),NN=2,10)
             CACC=BG2NAME
             MAP(1) = IACC
             PRINT *, ' BACKGROUND=',CACC
         ELSE IF (COPTION .EQ. CILCON4) THEN
             READ(CARD,FMT='(14X,5(1X,I6))')(MAP(NN),NN=11,15)
             RETURN
         ELSE IF (CARD(1:1) .EQ. COMENT) THEN
             IF (FLAGGET) RETURN
         ELSE
            PRINT *, ' ***FATAL ERROR: UNRECOGNIZE OPTION:',COPTION
         ENDIF
C
      GO TO 100
C
      RETURN
      END
