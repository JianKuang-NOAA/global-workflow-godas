C          DATA SET PLOTVPAP   AT LEVEL 002 AS OF 02/21/97
C$$$  MAIN PROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C MAIN PROGRAM: PLOTVPAP
C   PRGMMR: SAGER            ORG: NP12        DATE: 2002-02-06
C
C ABSTRACT: SELECTS UPPER AIR DATA FOR PLOTTING AND OUTPUTS IT TO
C   FT55 WHICH IS THEN PASSED TO A CODE USING BEDIENT'S CONTOURING
C   PACKAGE.  DATA CAN BE PLOTTED AT VARIOUS SCALES AND UTILIZING A
C   NUMBER OF INPUT FILES.  OPTIONS ARE EXTERNALLY CONTROLLED AND
C   WHILE SOME FLEXIBILITY EXISTS, WITHIN A GIVEN OPTION THE CODE
C   ANTICIPATES THAT AN OPERATIONAL-TYPE PRODUCT IS DESIRED.
C   WHEN THE AFOS PARAMENTER IS TURNED ON IN THE PARM FIELD AFOS
C   PLOTFILE PRODUCTS ARE OUTPUT TO FT24F001.
C
C PROGRAM HISTORY LOG:
C   YY-MM-DD  ORIGINAL AUTHOR UNKNOWN.
C   88-07-22  GLORIA DENT CHANGE THE AFOS ZOOM THRESHOLD OF 72273 (FT.
C               HUACHUCA) FROM ZOOM 1 TO ZOOM 16. CHANGE THE AFOS ZOOM
C               THRESHOLD OF 76458 (MAZATLAN,MX) FROM ZOOM 3 TO ZOOM 1
C   88-07-27  GLORIA DENT CHANGE THE W3FK00-W3FK11 TO W3FK41-W3FK51..
C   88-08-11  GLORIA DENT MOVE SOME OF THE PLOTTED DATA OF STATION
C               72273 (FT. HUACHUA) SO THAT IT WILL NOT OVERPLOT
C               STATION 72274 (TUCSON) ON THE VARIAN CHART.
C   88-12-14  GLORIA DENT  PUT IN LOGIC FOR ADPUPA FILE(FT19) TO ALLOW
C              ONLY + OR - 2 HOURS OFFTIME FOR REPORTS OF TYPE 11,TYPE
C              21,TYPE 22, TYPE 23
C   89-05-10  HENRICHSEN CLEAN UP PARM FIELD, ADD NEW SUBS.,
C                        CLEAN UP AND DOCUMENT SOME OLD SUBS,
C                        ADD DUMP TIME TO TILE OF AFOS PLOTFILE MAPS.
C   89-05-23  HENRICHSEN FIX AN ERROR IN SUB CKPARM.
C   89-05-31  DENT   CHANGE SUB AFORMT TO INCLUDE MINUTE IN
C                 IN AFOS COMMS HEADER ( 2-DOT PLOTFILE ONLY).
C   89-07-20  GLORIA DENT CHANGE THE AFOS ZOOM THRESHOLD OF 74732
C               (HOLLOMAN A.F. BASE,N.M.)FROM ZOOM 4-1 TO ZOOM 16-1.
C   89-07-20  STEVE LILLY ADD LAT/LONG FOR STATIONS WHICH ARE MOVED
C   89-07-21  STEVE LILLY ADD SUB TRUIJ TO PROGRAM
C   89-11-03  STEVE LILLY ADD SUB MOVOBS TO PROGRAM AND
C                ADD LOGIC WHICH PREVENTS SPECIFIED MILITARY UPPER
C                AIR REPORTS FROM BEING PLOTTED AT THE TOP OF THE
C                VARIAN PRODUCT.
C   89-12-26  GLORIA DENT  INITIALIZE RETURN EXIT BEFORE THE FIRST
C              STATEMENT TO PREVENT FALSE PLOTTING OF NON-PIBAL
C              REPORTS.
C   90-04-23  STEVE LILLY FIX AN ERROR IN SUB B4PLOT.  ADD
C              LOGIC WHICH WILL PREVENT REPEATING PREVIOUS OBS
C              FOR LEVELS WHICH ARE MISSING.
C   90-09-16  RALPH JONES   BYPASS TIME CHECK ON 21Z CANTON SOUNDING.
C   90-10-02  HENRICHSEN  FIX AN ERROR IN SUB GETPIL.
C   90-11-02  HENRICHSEN  LINK IN NEW W3FQ06 THAT WILL SAVE A COPY
C                         OF THE AFOS PLOT FILE FOR CONVERTING TO
C                         AWIPS FORMAT.
C                         ADD CONSOL MESSAGE INDICATING NUMBER AND
C                         NAMES OF AFOS PLOTFILE MAPS MADE.
C                         LINK IN NEW W3FQ06 THAT HAS NEW OPTIONS
C                         TO MAKE A COPY OF THE AFOS PLOTFILE PRIOR
C                         POSTING FOR TRANSMISSION AVAILABILITY.
C   93-05-10  LILLY CONVERTED SUB. TO FORTRAN 77.
C   95-07-12  LILLY    MOVES THE LOCATION OF THE "DATA CUT OFF TIME"
C               FROM THE YUCATAN TO THE LOWER LEFT HAND CORNER.  THIS
C               MOVE PREVENTS THE "DATA CUT OFF TIME" FROM OVER-
C               WRITING STATION 76595 (CANCUM).
C   97-01-28  LIN   CONVERTED TO CFT-77
C   97-02-11  LIN   FIX THE BUGS AND PLOT NH AND SH OBS.
C   97-02-21  LIN   ADD TROPIC AREA PLOTS INTO THE CODE.
C   97-03-04  LIN   ADD AIR CRAFT AND SAT. WIND INTO THE PLOTS.
C   97-03-36  LIN   MODIFY TO PLOT 250MB PLOTTED DATA ON NH2003.
C   98-04-17  SAGER CONVERT TO F90.  ADD Y2K SUBROUTINES.
C                   ADD TEMPS TO AIRCRAFT REPORTS ON 1:20 MILLION
C   99-07-25  SAGER CONVERT TO IBM SP 
C
C USAGE:
C   INPUT FILES:
C     PARM     - THE PARM DIRECTS THE PLOT OPTIONS.
C              - SAMPLE PARM FIELD:
C              - ('NUMF=XX,ACAR=ON,MIDC=ON,TSW1=ON,TSW2=ON,'
C              -  'AFOS=ON,SEND=ON,CARD=ON,MARG=ON')
C              - THE INDICATED FLAGS HAVE THESE MEANINGS:
C              - NUMF=XX WHERE XX DEFINE A TWO-DIGET NUMBER USED TO
C              - OVERRIDE THE OPERATIONAL CONVENTIONS  SEE REMARKS.
C              - ACAR=ON SIGNALS THE ACAR OPTION
C              - MIDC=ON ACTIVATES THE MID-CYCLE OPTION
C              - TSW1=ON TELLS RDSOLD TO BYPASS SOME DATE/TIME CHECKS.
C              - TSW2=ON TELLS RDSOLD TO BYPASS SOME DATE/TIME CHECKS.
C              - AFOS=ON MAKES THE AFOS PLOTFILE.
C              - SEND=ON SENDS THE AFOS PLOTFILE.
C              - CARD=ON TELLS W3FQ06 TO READ A DATA CARD
C              - MARG=ON TURN ON MARGEN PLOTTING OF SOME SELECTED
C              - STATIONS SO AS TO AVOID OVER PLOTTING.
C              - THIS IS A FAX/VARION OPTION ONLY.
C     FT05F001 - DATA CARDS, INPUT TO DETERMINE PLOTTING OPTION.
C              - SEE REMARKS.
C     FT42F001 - USUALLY AIRCFT DATA ...PARM VALUE TO FORCE PLOT IS 2.
C     FT44F001 - USUALLY TIROS DATA ...PARM VALUE TO FORCE PLOT IS 8.
C     FT18F001 - USUALLY BOGUS DATA ...PARM VALUE TO FORCE PLOT IS 16.
C     FT41F001 - USUALLY ADPUPA DATA ...PARM VALUE TO FORCE PLOT IS 1.
C     FT20F001 - USUALLY ACAR DATA ... PARM VALUE TO FORCE PLOT IS 32.
C     FT43F001 - USUALLY SATWND DATA ... PARM VALUE TO FORCE PLOT IS 4.
C     FT26F001 - A LIST OF STATIONS FOR POSSIBLE MARGIN PLOTTING AT TOP.
C     FMANL    - PROVIDES 1000MB HTS FOR TIROS PLOT ON LFM MAPS.
C     ANL1     - PROVIDES 1000MB HTS FOR TIROS PLOT AT 1:40M OVER NH.
C     ANL5     - PROVIDES 1000MB HTS FOR TIROS PLOT AT 1:40M OVER SH.
C     GES      - PROVIDES BACKUP 1000MB HTS FOR TIROS AT 1:40M OVER NH.
C     NEWPAP   - PROVIDES ADDITIONAL UPPER-AIR DATA (OPTION DEPENDENT).
C     OLDPAP   - 12-HR OLD NEWPAP ... USED TO COMPUTE HT CHANGES.
C     FT50F001 -  USED TO DETERMINE AFOS PIL NOS. FOR PLOTFILE OUTPUT.
C              - THE ABOVE FILES WILL NOT ALL BE USED IN ANY GIVEN
C              - EXECUTION OF THIS PROGRAM.
C
C
C   OUTPUT FILES:
C     FT06F001 - PRINT FILE.
C     FT24F001 - HOLDS PLOTFILE OUTPUT FOR AFOS.
C     FT28F001 - HOLDS A COPY OF PLOTFILE OUTPUT THAT WILL BE
C              - CONVERTED TO AWIPS FORMAT BY ANOTHER JOB STEP.
C     FT55F001 - HOLDS PLOTTED DATA PRINT FOR ASSIMILATION BY BEDIENT.
C     GRANPA   - TEMPORARY STORAGE AREA, SERVES AS INPUT FILE TOO.
C     BACKUP   - USED ALSO TO SEND THE AFOS PLOTFILE MAPS.
C
C   SUBPROGRAMS CALLED:
C     UNIQUE:    - ACPROC  AFPLTF  AFORMT  APLGND  AFZOOM  B4PLOT
C                - CKPARM  DATIT   DEWPT   DIXIE   FRMSG1  GEOHGT
C                - GLSYLO  GOESXY  IDTITL  INIDRA  INTERP
C                - KIRK    KNIT    OPTIN   LGNDID  LKTBLS  MAPLOP
C                - MERCXY  MFIELD  MOVEID  MOVOBS  OPOINT
C                - PACKOB  PLTDAT  PNANIJ  PRESOR  PUTLAB  READPA
C                - REDADP  REPORT  DRAFIL  RDCAR1  RDCAR2  RDDATE
C                - RDSIRS  RDSOLD  SETCAR  SETFLG  SETUP   SKEIL
C                - SORTEM  TBOUND  TEMPER  TITLED  TITLEJ  TITLEN
C                - TITLES  WIND
C     LIBRARY:
C       COMMON   - CONSOL  FFA2I
C       W3LIB    - W3AI01  W3AI02  W3AI14  W3AI15  W3AI24  W3AI35
C                - W3AI39  W3AG09  W3AG15  W3AK19  W3AQ03  W3AQ09
C                - W3AQ13  W3AS00  W3AS02  W3AS03  W3FB00  W3FB02
C                - W3FB04  W3FK40  W3UTCDATW3FQO3  W3FQ06  W3FQ09
C                - W3FA15  W3FT01  W3TAGB  W3TAGE
C       GRAPHICS - DAYOWK  DSHIFT  EB2ASC  ICALCU  ISP2EB
C                - MOVCH   TRANSA  TRUIJ   TRULL   UPDATR
C                - WNDBRK  INT2CH
C
C   EXIT STATES:
C     COND =   0 - SUCCESSFUL RUN
C          =   1 - AFOS PLOTFILE DATA NOT SENT.
C          =   2 - INPUT DATA CARDS COULD NOT BE DECIPHERED.
C
C REMARKS: NOTE BE SURE THAT IVERSN ARRAY IS UPDATED WHEN CODE IS
C   UPDATED.
C     INTEGER    IVERSN(9)   /'1600',',145','0,00','000Z',
C    1                        ',WD4','12/D','KPH/','9.L0',
C    2                        ZF25E0D0A/
C   THE NUMF=XX FLAGS ARE DESCRIBED BELOW:
C   XX DEFINE A TWO-DIGIT NUMBER USED TO OVERRIDE THE OPERATIONAL
C   CONVENTIONS REGARDING WHICH FILES ARE PLOTTED UNDER A GIVEN
C   KRUN OPTION.  IF THESE POSITIONS ARE '00' OR MISSING,
C   KRUN ALONE WILL MAKE THIS DETERMINATION.  OTHERWISE THESE
C   NUMBERS ARE INTERPRETED THUSLY:
C     1   PLOT FT19 (ADPUPA)
C     2   PLOT FT14 (AIRCFT)
C     4   PLOT FT22 (SATWND)
C     8   PLOT FT15 (TIROS)
C    16   PLOT FT18 (BOGUS)
C    32   PLOT FT20 (ACAR)
C
C   THESE VALUES ARE ADDITIVE.  FOR EXAMPLE, 13 MEANS PLOT FT19,
C   FT22, AND FT15.
C   THIS PROGRAM HAS MANY OPTIONS, CONTROLLED BY DATA CARDS, EACH WITH
C   A PRE-DETERMINED SET OF INPUT FILES FROM WHICH TO PLOT DATA.  THE
C   CODE ALSO RECOGNIZES THE ABOVE-INDICATED PARM VALUES (WHICH ARE
C   ADDITIVE) AS PARTIAL OVERRIDES TO THOSE DATA CARDS.  FOR EXAMPLE,
C   THE 2-DOT OPTION WITH NO PARM VALUE SET WILL YIELD A PLOT OF FT14,
C   FT19, AND FT22 DATA.  IF ONE DESIRED TO PLOT TIROS DATA AS WELL, ONE
C   SHOULD SET A PARM VALUE OF 15 (1+2+4+8).  SETTING THE PARM SWITCH
C   OVERRIDES THE FILE SELECTION BASED ON THE DATA CARDS, AND THIS
C   SETTING PLOTS DATA FROM ALL FOUR DESIRED FILES.
C   THIS PROGRAM DOES NOT BY ITSELF DISPLAY FAX DATA.  IT
C   MUST BE FOLLOWED BY A DISPLAY PROGRAM UTILIZING BEDIENT'S CNTR
C   PACKAGE.  THE COMMONLY USED FOLLOW-UP PROGRAM IS SCHNURR'S
C   PEPFAX.
C   MODIFIED JAN., 1984 TO ADD ACAR (FT20) FILE PLOTTING OPTION.
C   MODIFIED DEC., 1984 TO ADD 2 MORE MANDITORY LEVELS FOR PLOTTING.
C   400 AND 150 MB CAN NOW BE PLOTTED--150MB WILL BE RUNNING
C   OPERATIONALLY 1/9/85 IN THE 2-DOT PACKAGE.
C   MODIFIED MAY 1986 TO RID CODE OF ASYNCHRONOUS I/O.
C   MODIFIED JULY 1987 TO SET ZOOM THRESHOLD 4:1 AT STATION 72402
C   (WALLOPS ISLAND). SEE SUB B4PLOT.
C   MODIFIED SEPTEMBER 1987 TO INCLUDE THE BLOCK DATA SUBPROGRAM
C   TO INITIALIZE LABELED COMMON /LKTLBS/ THUS ELIMINATING THE
C   NEED TO "EXPLICITLY" LINK EDIT WITH ANY CONTOUR(CNTR) PACKAGE.
C   SEE SUB PUTLAB IN THIS SOURCE. G.R. DENT...09/09/87...
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 90
C   MACHINE:  IBM SP
C
C$$$
C
      COMMON  /BOBIN / LOCT(256),IDTBL(1539)
      COMMON  /CHKOUT/ NITEM
      COMMON  /CIDOBS/ RIDOBS(200)
      COMMON  / DATE / NYR,NMO,NDA,NHR
      COMMON  /IAFOS /NUMAFS,NAMPIL(10),LVERSN,AFOS,SEND,CARD,MARG,PNCH
C*    COMMON  /ISPACE/ IDREC(6),NDATA(3,10001)
      COMMON  /JSPACE/ IDREC(6),NDATA(3,10001)
      COMMON  /KPLOT / LABEL(2,1024),LABIX,NOBUF,IDRA(50)
      COMMON  /LEVEL / NLEVEL,LCNTR
      COMMON  /PACKRA/ DBLPKD(6)
      COMMON  /ROBIN / LCT1(256),IDTB1(1539)
      COMMON  /SOBIN / LCT2(256),IDTB2(1539)
      COMMON  /TIMES / NANJI(12)
      COMMON  /TIMET / NANJK(2)
C     COMMON  /      / SDATA(3,10001)
C
      CHARACTER*8  AFSMSG(07)
      DATA         AFSMSG    /'NWS,MADE', ' AND SEN', 'T XX OF ',
     1                        'XX AFOS ', '2-DOT PL', 'OTFILE M',
     1                        'APS:    '/
      CHARACTER*8  AFSPIL(07)
      DATA         AFSPIL    /'NWS,THEY', ' ARE    ', '        ',
     1                        '        ', '        ', '        ',
     1                        '       :'/
      CHARACTER*8  DHMBS (29)
      DATA         DHMBS     /'SURFACE ', '1000MB  ', '850MB   ',
     1                        '700MB   ', '500MB   ', '400MB   ',
     2                        '300MB   ', '250MB   ', '200MB   ',
     3                        '150MB   ', '100MB   ', '70MB    ',
     4                        '50MB    ', '30MB    ', '20MB    ',
     5                        '10MB    ', '7MB     ', '5MB     ',
     6                        '3MB     ', '2MB     ', '1MB     ',
     7                        '0.4MB   ', 'TROPO   ', 'SIGL    ',
     8                        'FRZG LVL', 'REL HUM ', '  INDEX ',
     9                        'PRECIP-W', 'SFC ANL '/
      CHARACTER*8  DHVRBL(3)
      DATA         DHVRBL     /'KRUN    ', 'NLVLS   ', 'IOPTN   ' /
      CHARACTER*12 IBCD
C
      CHARACTER*1  LA
      DATA         LA          /'A'/
      CHARACTER*1  LPARM(100)
      CHARACTER*100  NPARM
      EQUIVALENCE (LPARM(1),NPARM)
C
      REAL*8  DBLPKD
      REAL*8  NDATA
      REAL*8  RIDOBS
      REAL*8  SDATA
      REAL*8  WATPAP
C
C???  INTEGER    JBCD(3)
      INTEGER    ILVLTS(10)
      INTEGER    IDUMPT(2)
      INTEGER    IVALRA(3)
      INTEGER    IVERSN(10) 
      DATA       IVERSN   /8H    1600,8H    ,028,8H    0,10,8H    012Z,
     1                     8H    ,NP1,8H    12/J,8H    LIN/,8H    0.L0,
     2                     Z'F25E0D0A',Z'0000000000'/
      INTEGER    KNAM(10)
      INTEGER    KNUMB(10)
      INTEGER    LBLTAP
      DATA       LBLTAP      /55/
      INTEGER    LVLSAL(10)
      INTEGER    MAXDFE 
      DATA       MAXDFE      /255/
      INTEGER    MXMBS   
      DATA       MXMBS       /29/
      CHARACTER*12  NAME(10)
      CHARACTER*12  NUMBS(10)
      INTEGER    NVRBLS
      DATA       NVRBLS      /3/
C
      LOGICAL    AFOS
      LOGICAL    CARD
      LOGICAL    FLAGS(9)
      CHARACTER*1  LVERSN(40)
      CHARACTER*1  CVERSN(40)
      LOGICAL    MARG
      LOGICAL    PNCH
      LOGICAL    SEND
      LOGICAL    LDZDTQ
      LOGICAL    LDZNEW
C
C???   EQUIVALENCE(JBCD(1),IBCD)
C
      CALL W3TAGB('PLOTVPAP',2002,0037,0068,'NP12')
      AFOS = .FALSE.
        
C
C        READ IN PARM FIELD FLAGS
C
      CALL W3AS00(NF,NPARM,IERR)
C     PRINT *,' NF=', NF
C
      REWIND LBLTAP
C???  ENDFILE LBLTAP
C     ...TO ENSURE THEY WON,T USE TAPE IF ABNORMAL END...
      REWIND LBLTAP
      NITEM = 0
C
      LDZDTQ = .FALSE.
      LDZNEW = .FALSE.
      CALL SBYTESCCS(CVERSN,IVERSN,0,32,0,10)
C
C     READ THE CONTROLLING DATA CARDS.
C
      CALL RDCAR1(NVRBLS,DHVRBL,IVALRA,IERR,KNAM,NAME,KNUMB,NUMBS)
      IF(IERR .NE. 0) THEN
         PRINT *, ' RDCAR1 FAILS. IERR=',IERR
         GO TO 900
      ENDIF
      KRUN = IVALRA(1)
      NOLVSR = IVALRA(2)
      IOPTN = IVALRA(3)
C
      WRITE(6,100)KRUN,NOLVSR,IOPTN
  100 FORMAT(1X,/,10X,'AFTER RDCAR1 ... KRUN = ',I4,5X,
     1       'NOLVSR = ',I4,5X,'IOPTN = ',I4)
C
      NLEVEL = NOLVSR
      LCNTR  = 0
C
      CALL RDCAR2(NOLVSR,DHMBS,MXMBS,ILVLTS,IERR,KNAM,NAME,KNUMB,NUMBS)
      IF(IERR .NE. 0) THEN
         PRINT *, ' RDCAR2 FAILS. IERR=',IERR
      ENDIF
      CALL RDCAR3(IERRS)
      IF(IERR .NE. 0) THEN
         PRINT *, ' RDCAR3 FAILS. IERR=',IERR
      ENDIF
      IF(NOLVSR .LT. 2) GO TO 160
      IMAX = NOLVSR - 1
          DO 150 I=1,IMAX
              INNER = I + 1
            DO 150 J=INNER,NOLVSR
               IF(ILVLTS(I) .LE. ILVLTS(J)) GO TO 150
               ITEM = ILVLTS(I)
               ILVLTS(I) = ILVLTS(J)
               ILVLTS(J) = ITEM
  150     CONTINUE
C
C     THE ABOVE LOOP SORTS THE REQUESTED LEVELS INTO ASCENDING ORDER.
C
  160 CONTINUE
      WRITE(6,200)(ILVLTS(I),I=1,NOLVSR)
  200 FORMAT(1H , 10X, 'ILVLTS ARE ...', 10I5)
C
C       CHECK PARM FLAGS.
C
      CALL CKPARM(LPARM,NF,NUMFIL,FLAGS)
C
C       SET FLAGS IN COMMON BLOCKS.
C
      CALL SETFLG(NUMFIL,KRUN,FLAGS)
C
C       IF THIS IS AN AFOS RUN LOAD AFOS VERSION INTO COMMON.
C
       IF(AFOS) CALL MOVCH(36,IVERSN,1,LVERSN,1)
         DO 300 I=1,10
            LVLSAL(I) = 0
  300    CONTINUE
C
         DO 400 I=1,NOLVSR
             IF(ILVLTS(I) .LE. 0) GO TO 400
             LVLSAL(I) = ILVLTS(I) - 1
  400    CONTINUE
C
         DO 500 I=1,200
           RIDOBS(I) = 0.0
  500    CONTINUE
C
      CALL KOPTN(KRUN,IOPTN,NOLVSR,LVLSAL,LDZDTQ,LDZNEW,ITOUT,WATPAP,
     X           IDUMPT)
      PRINT *,' *** ITOUT=', ITOUT
      PRINT *,' *** KRUN=',KRUN
C     CALL W3FK40(WATPAP,LOCT,MAXDFE)
C     ...WHICH OPENS THE INPUT OBS PAP FILE...
C??   CALL TESRDUUPA
      CALL MAPLOP(NOLVSR,ILVLTS,WATPAP,ITOUT,LDZDTQ,LDZNEW,IOPTN,DHMBS,
     X            KRUN,IDUMPT,IERR)
C???  ENDFILE LBLTAP
C     ...TO MARK THE PHYSICAL END OF FILE ON TAPE55
      GO TO 999
C
  900 CONTINUE
      PRINT  905
  905 FORMAT(1H0, 10X, 'ERROR STOP IN PROGRAM PLOTVPAP.  TROUBLE IS IN
     1 CONTROLLING DATA CARDS ON FT05F001')
C     CALL CONSOL('NWS,TROUBLE READING DATA CARDS FOR PLOTVPAP:')
      ISTOP = 2
      GO TO 2000
  999 CONTINUE
      ISTOP = 0
C
C       CHECK TO SEE IF AFOS PLOTFILE MAPS WERE MADE.
C
      IF(.NOT. AFOS) GO TO 2000
C
C       CHECK TO SEE IF AFOS PLOTFILE IS TO BE SENT
C
      IF(.NOT. SEND) GO TO 2000
      REWIND 24
C
C      CHECK TO SEE FLAGS TO SEND AFOS PLOTFILE ARE TO COME FROM CARD.
C
      IF(.NOT. CARD) GO TO 1000
      NC = 80
      LPARM(5) = LA
C1000 CALL W3FQ06(LPARM,NC,1,KRTN)
      KRTN = 0
 1000  ISTOP = KRTN
      IF(KRTN .NE. 0) GO TO 1500
C
C      GET AFSMSG READY
C
CB?   CALL BIN2EB(NUMAFS,IBCD,2,'A99')
      CALL INT2CH(NUMAFS,IBCD,2,'A999')
      CALL MOVCH(2,IBCD,1,AFSMSG,19)
C
CB?   CALL BIN2EB(NOLVSR,IBCD,2,'A99')
      CALL INT2CH(NOLVSR,IBCD,2,'A999')
      CALL MOVCH(2,IBCD,1,AFSMSG,25)
C
C      GET AFSPIL READY
C
        NBYTES = NUMAFS*4
C
      CALL MOVCH(NBYTES,NAMPIL,1,AFSPIL,14)
C
C      CALL CONSOL(AFSMSG)
C      CALL CONSOL(AFSPIL)
      WRITE(6,1010)AFSMSG
 1010 FORMAT(1H ,7A8)
      WRITE(6,1010)AFSPIL
C
      GO TO 2000
 1500 IF(KRTN .NE. 1) GO TO 1800
 1600 CALL CONSOL('NWS,*** 2-DOT PLOTFILE NOT POSTED, COPY MADE ***:')
        NBYTES = NUMAFS*4
       CALL MOVCH(NBYTES,NAMPIL,1,AFSPIL,14)
C      CALL CONSOL(AFSPIL)
C
 1800 IF(KRTN .NE. 3) GO TO 2000
 1900 CONTINUE  
C1900 CALL CONSOL('NWS,*** 2-DOT PLOTFILE NOT POSTED, TEST ****:')
 2000 CONTINUE
      CALL W3TAGE('PLOTVPAP')
       CALL ERREXIT(ISTOP)
      STOP
      END
