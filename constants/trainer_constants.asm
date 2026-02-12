__trainer_class__ = 0

trainerclass: MACRO
\1 EQU __trainer_class__
__trainer_class__ += 1
	const_def 1
ENDM

; trainer class ids
; `trainerclass` indexes are for:
; - TrainerClassNames (see data/trainers/class_names.asm)
; - TrainerClassAttributes (see data/trainers/attributes.asm)
; - TrainerClassDVs (see data/trainers/dvs.asm)
; - TrainerGroups (see data/trainers/party_pointers.asm)
; - TrainerEncounterMusic (see data/trainers/encounter_music.asm)
; - TrainerPicPointers (see data/trainers/pic_pointers.asm)
; - TrainerPalettes (see data/trainers/palettes.asm)
; - BTTrainerClassSprites (see data/trainers/sprites.asm)
; - BTTrainerClassGenders (see data/trainers/genders.asm)
; trainer constants are Trainers indexes, for the sub-tables of TrainerGroups (see data/trainers/parties.asm)
CHRIS EQU __trainer_class__
	trainerclass TRAINER_NONE ; 0
	const PHONECONTACT_MOM
	const PHONECONTACT_BIKESHOP
	const PHONECONTACT_BILL
	const PHONECONTACT_ELM
	const PHONECONTACT_BUENA
NUM_NONTRAINER_PHONECONTACTS EQU const_value - 1

KRIS EQU __trainer_class__
	trainerclass FALKNER ; 1
	const FALKNER1
	const FALKNER2
	const FALKNER3
	const FALKNER4 ; rematch

	trainerclass WHITNEY ; 2
	const WHITNEY1
	const WHITNEY2
	const WHITNEY3
	const WHITNEY4 ; rematch

	trainerclass BUGSY ; 3
	const BUGSY1
	const BUGSY2
	const BUGSY3
	const BUGSY4 ; rematch

	trainerclass MORTY ; 4
	const MORTY1
	const MORTY2
	const MORTY3
	const MORTY4 ; rematch

	trainerclass PRYCE ; 5
	const PRYCE1  ; tier 1 variant A
	const PRYCE2  ; tier 1 variant B
	const PRYCE3  ; tier 1 variant C
	const PRYCE4  ; tier 2 variant A
	const PRYCE5  ; tier 2 variant B
	const PRYCE6  ; tier 2 variant C
	const PRYCE7  ; tier 3 variant A
	const PRYCE8  ; tier 3 variant B
	const PRYCE9  ; tier 3 variant C
	const PRYCE10 ; rematch

	trainerclass JASMINE ; 6
	const JASMINE1  ; tier 1 variant A
	const JASMINE2  ; tier 1 variant B
	const JASMINE3  ; tier 1 variant C
	const JASMINE4  ; tier 2 variant A
	const JASMINE5  ; tier 2 variant B
	const JASMINE6  ; tier 2 variant C
	const JASMINE7  ; tier 3 variant A
	const JASMINE8  ; tier 3 variant B
	const JASMINE9  ; tier 3 variant C
	const JASMINE10 ; rematch

	trainerclass CHUCK ; 7
	const CHUCK1  ; tier 1 variant A
	const CHUCK2  ; tier 1 variant B
	const CHUCK3  ; tier 1 variant C
	const CHUCK4  ; tier 2 variant A
	const CHUCK5  ; tier 2 variant B
	const CHUCK6  ; tier 2 variant C
	const CHUCK7  ; tier 3 variant A
	const CHUCK8  ; tier 3 variant B
	const CHUCK9  ; tier 3 variant C
	const CHUCK10 ; rematch

	trainerclass CLAIR ; 8
	const CLAIR1
	const CLAIR2
	const CLAIR3
	const CLAIR4 ; rematch

	trainerclass RIVAL1 ; 9
	; encounter 1 (Cherrygrove) - 8 variants by player starter
	const RIVAL1_1_CHIKORITA
	const RIVAL1_1_TOTODILE
	const RIVAL1_1_CYNDAQUIL
	const RIVAL1_1_AIPOM
	const RIVAL1_1_SUDOWOODO
	const RIVAL1_1_SMEARGLE
	const RIVAL1_1_SWINUB
	const RIVAL1_1_MAREEP
	; encounter 2 (Azalea) - 8 variants
	const RIVAL1_2_CHIKORITA
	const RIVAL1_2_TOTODILE
	const RIVAL1_2_CYNDAQUIL
	const RIVAL1_2_AIPOM
	const RIVAL1_2_SUDOWOODO
	const RIVAL1_2_SMEARGLE
	const RIVAL1_2_SWINUB
	const RIVAL1_2_MAREEP
	; encounter 3 (Burned Tower) - 8 variants
	const RIVAL1_3_CHIKORITA
	const RIVAL1_3_TOTODILE
	const RIVAL1_3_CYNDAQUIL
	const RIVAL1_3_AIPOM
	const RIVAL1_3_SUDOWOODO
	const RIVAL1_3_SMEARGLE
	const RIVAL1_3_SWINUB
	const RIVAL1_3_MAREEP
	; encounter 4 (Goldenrod Underground) - 8 variants
	const RIVAL1_4_CHIKORITA
	const RIVAL1_4_TOTODILE
	const RIVAL1_4_CYNDAQUIL
	const RIVAL1_4_AIPOM
	const RIVAL1_4_SUDOWOODO
	const RIVAL1_4_SMEARGLE
	const RIVAL1_4_SWINUB
	const RIVAL1_4_MAREEP
	; encounter 5 (Victory Road) - 8 variants
	const RIVAL1_5_CHIKORITA
	const RIVAL1_5_TOTODILE
	const RIVAL1_5_CYNDAQUIL
	const RIVAL1_5_AIPOM
	const RIVAL1_5_SUDOWOODO
	const RIVAL1_5_SMEARGLE
	const RIVAL1_5_SWINUB
	const RIVAL1_5_MAREEP

	trainerclass POKEMON_PROF ; a

	trainerclass WILL ; b
	const WILL1

	trainerclass CAL ; c
	const CAL1 ; unused
	const CAL2
	const SMITH
	const CRAIG

	trainerclass BRUNO ; d
	const BRUNO1

	trainerclass KAREN ; e
	const KAREN1

	trainerclass KOGA ; f
	const KOGA1

	trainerclass CHAMPION ; 10
	const LANCE

	trainerclass BROCK ; 11
	const BROCK1

	trainerclass MISTY ; 12
	const MISTY1

	trainerclass LT_SURGE ; 13
	const LT_SURGE1

	trainerclass SCIENTIST ; 14
	const ROSS
	const MITCH
	const JED
	const MARC
	const RICH

	trainerclass ERIKA ; 15
	const ERIKA1

	trainerclass YOUNGSTER ; 16
	const JOEY1
	const MIKEY
	const ALBERT
	const GORDON
	const SAMUEL
	const IAN
	const JOEY2
	const JOEY3
	const WARREN
	const JIMMY
	const OWEN
	const JASON
	const JOEY4
	const JOEY5
	const JOEY1_V1
	const JOEY1_V2
	const MIKEY_V1
	const MIKEY_V2
	const ALBERT_V1
	const ALBERT_V2
	const GORDON_V1
	const GORDON_V2
	const SAMUEL_V1
	const SAMUEL_V2
	const IAN_V1
	const IAN_V2

	trainerclass SCHOOLBOY ; 17
	const JACK1
	const KIPP
	const ALAN1
	const JOHNNY
	const DANNY
	const TOMMY
	const DUDLEY
	const JOE
	const BILLY
	const CHAD1
	const NATE
	const RICKY
	const JACK2
	const JACK3
	const ALAN2
	const ALAN3
	const CHAD2
	const CHAD3
	const JACK4
	const JACK5
	const ALAN4
	const ALAN5
	const CHAD4
	const CHAD5
	const JACK1_V1
	const JACK1_V2
	const ALAN1_V1
	const ALAN1_V2
	const CHAD1_V1
	const CHAD1_V2

	trainerclass BIRD_KEEPER ; 18
	const ROD
	const ABE
	const BRYAN
	const THEO
	const TOBY
	const DENIS
	const VANCE1
	const HANK
	const ROY
	const BORIS
	const BOB
	const JOSE1
	const PETER
	const JOSE2
	const PERRY
	const BRET
	const JOSE3
	const VANCE2
	const VANCE3
	const PETER_V1
	const PETER_V2
	const BRYAN_V1
	const BRYAN_V2
	const THEO_V1
	const THEO_V2
	const TOBY_V1
	const TOBY_V2
	const DENIS_V1
	const DENIS_V2
	const VANCE1_V1
	const VANCE1_V2

	trainerclass LASS ; 19
	const CARRIE
	const BRIDGET
	const ALICE
	const KRISE
	const CONNIE1
	const LINDA
	const LAURA
	const SHANNON
	const MICHELLE
	const DANA1
	const ELLEN
	const CONNIE2 ; unused
	const CONNIE3 ; unused
	const DANA2
	const DANA3
	const DANA4
	const DANA5
	const CARRIE_V1
	const CARRIE_V2
	const BRIDGET_V1
	const BRIDGET_V2
	const KRISE_V1
	const KRISE_V2
	const DANA1_V1
	const DANA1_V2
	const CONNIE1_V1
	const CONNIE1_V2

	trainerclass JANINE ; 1a
	const JANINE1

	trainerclass COOLTRAINERM ; 1b
	const NICK
	const AARON
	const PAUL
	const CODY
	const MIKE
	const GAVEN1
	const GAVEN2
	const RYAN
	const JAKE
	const GAVEN3
	const BLAKE
	const BRIAN
	const ERICK ; unused
	const ANDY ; unused
	const TYLER ; unused
	const SEAN
	const KEVIN
	const STEVE ; unused
	const ALLEN
	const DARIN
	const NICK_V1
	const NICK_V2
	const AARON_V1
	const AARON_V2
	const ALLEN_V1
	const ALLEN_V2
	const RYAN_V1
	const RYAN_V2

	trainerclass COOLTRAINERF ; 1c
	const GWEN
	const LOIS
	const FRAN
	const LOLA
	const KATE
	const IRENE
	const KELLY
	const JOYCE
	const BETH1
	const REENA1
	const MEGAN
	const BETH2
	const CAROL
	const QUINN
	const EMMA
	const CYBIL
	const JENN
	const BETH3
	const REENA2
	const REENA3
	const CARA
	const IRENE_V1
	const IRENE_V2
	const JENN_V1
	const JENN_V2
	const KATE_V1
	const KATE_V2
	const GWEN_V1
	const GWEN_V2
	const EMMA_V1
	const EMMA_V2
	const LOIS_V1
	const LOIS_V2

	trainerclass BEAUTY ; 1d
	const VICTORIA
	const SAMANTHA
	const JULIE ; unused
	const JACLYN ; unused
	const BRENDA ; unused
	const CASSIE
	const CAROLINE ; unused
	const CARLENE ; unused
	const JESSICA ; unused
	const RACHAEL ; unused
	const ANGELICA ; unused
	const KENDRA ; unused
	const VERONICA ; unused
	const JULIA
	const THERESA ; unused
	const VALERIE
	const OLIVIA
	const VICTORIA_V1
	const VICTORIA_V2
	const SAMANTHA_V1
	const SAMANTHA_V2
	const VALERIE_V1
	const VALERIE_V2
	const OLIVIA_V1
	const OLIVIA_V2

	trainerclass POKEMANIAC ; 1e
	const LARRY
	const ANDREW
	const CALVIN
	const SHANE
	const BEN
	const BRENT1
	const RON
	const ETHAN
	const BRENT2
	const BRENT3
	const ISSAC
	const DONALD
	const ZACH
	const BRENT4
	const MILLER
	const LARRY_V1
	const LARRY_V2
	const ANDREW_V1
	const ANDREW_V2
	const CALVIN_V1
	const CALVIN_V2
	const SHANE_V1
	const SHANE_V2
	const BEN_V1
	const BEN_V2
	const BRENT1_V1
	const BRENT1_V2
	const RON_V1
	const RON_V2
	const ISSAC_V1
	const ISSAC_V2
	const DONALD_V1
	const DONALD_V2
	const MILLER_V1
	const MILLER_V2
	const ZACH_V1
	const ZACH_V2

	trainerclass GRUNTM ; 1f
	const GRUNTM_1
	const GRUNTM_2
	const GRUNTM_3
	const GRUNTM_4
	const GRUNTM_5
	const GRUNTM_6
	const GRUNTM_7
	const GRUNTM_8
	const GRUNTM_9
	const GRUNTM_10
	const GRUNTM_11
	const GRUNTM_12 ; unused
	const GRUNTM_13
	const GRUNTM_14
	const GRUNTM_15
	const GRUNTM_16
	const GRUNTM_17
	const GRUNTM_18
	const GRUNTM_19
	const GRUNTM_20
	const GRUNTM_21
	const GRUNTM_22 ; unused
	const GRUNTM_23 ; unused
	const GRUNTM_24
	const GRUNTM_25
	const GRUNTM_26 ; unused
	const GRUNTM_27 ; unused
	const GRUNTM_28
	const GRUNTM_29
	const GRUNTM_30 ; unused
	const GRUNTM_31

	trainerclass GENTLEMAN ; 20
	const PRESTON
	const EDWARD
	const GREGORY
	const VIRGIL ; unused
	const ALFRED
	const PRESTON_V1
	const PRESTON_V2
	const ALFRED_V1
	const ALFRED_V2

	trainerclass SKIER ; 21
	const ROXANNE
	const CLARISSA
	const ROXANNE_V1
	const ROXANNE_V2
	const CLARISSA_V1
	const CLARISSA_V2

	trainerclass TEACHER ; 22
	const COLETTE
	const HILLARY
	const SHIRLEY

	trainerclass SABRINA ; 23
	const SABRINA1

	trainerclass BUG_CATCHER ; 24
	const DON
	const ROB
	const ED
	const WADE1
	const BUG_CATCHER_BENNY
	const AL
	const JOSH
	const ARNIE1
	const KEN
	const WADE2
	const WADE3
	const DOUG
	const ARNIE2
	const ARNIE3
	const WADE4
	const WADE5
	const ARNIE4
	const ARNIE5
	const WAYNE
	const DON_V1
	const DON_V2
	const WADE1_V1
	const WADE1_V2
	const BUG_CATCHER_BENNY_V1
	const BUG_CATCHER_BENNY_V2
	const AL_V1
	const AL_V2
	const JOSH_V1
	const JOSH_V2
	const ARNIE1_V1
	const ARNIE1_V2
	const WAYNE_V1
	const WAYNE_V2

	trainerclass FISHER ; 25
	const JUSTIN
	const RALPH1
	const ARNOLD
	const KYLE
	const HENRY
	const MARVIN
	const TULLY1
	const ANDRE
	const RAYMOND
	const WILTON1
	const EDGAR
	const JONAH
	const MARTIN
	const STEPHEN
	const BARNEY
	const RALPH2
	const RALPH3
	const TULLY2
	const TULLY3
	const WILTON2
	const SCOTT
	const WILTON3
	const RALPH4
	const RALPH5
	const TULLY4
	const JUSTIN_V1
	const JUSTIN_V2
	const RALPH1_V1
	const RALPH1_V2
	const HENRY_V1
	const HENRY_V2
	const TULLY1_V1
	const TULLY1_V2
	const MARVIN_V1
	const MARVIN_V2
	const ANDRE_V1
	const ANDRE_V2
	const RAYMOND_V1
	const RAYMOND_V2
	const WILTON1_V1
	const WILTON1_V2
	const EDGAR_V1
	const EDGAR_V2

	trainerclass SWIMMERM ; 26
	const HAROLD
	const SIMON
	const RANDALL
	const CHARLIE
	const GEORGE
	const BERKE
	const KIRK
	const MATHEW
	const HAL ; unused
	const PATON ; unused
	const DARYL ; unused
	const WALTER ; unused
	const TONY ; unused
	const JEROME
	const TUCKER
	const RICK ; unused
	const CAMERON
	const SETH
	const JAMES ; unused
	const LEWIS ; unused
	const PARKER
	const SIMON_V1
	const SIMON_V2
	const RANDALL_V1
	const RANDALL_V2
	const CHARLIE_V1
	const CHARLIE_V2
	const GEORGE_V1
	const GEORGE_V2
	const BERKE_V1
	const BERKE_V2
	const KIRK_V1
	const KIRK_V2
	const MATHEW_V1
	const MATHEW_V2

	trainerclass SWIMMERF ; 27
	const ELAINE
	const PAULA
	const KAYLEE
	const SUSIE
	const DENISE
	const KARA
	const WENDY
	const LISA ; unused
	const JILL ; unused
	const MARY ; unused
	const KATIE ; unused
	const DAWN
	const TARA ; unused
	const NICOLE
	const LORI
	const JODY ; unused
	const NIKKI
	const DIANA
	const BRIANA
	const ELAINE_V1
	const ELAINE_V2
	const PAULA_V1
	const PAULA_V2
	const KAYLEE_V1
	const KAYLEE_V2
	const SUSIE_V1
	const SUSIE_V2
	const DENISE_V1
	const DENISE_V2
	const KARA_V1
	const KARA_V2
	const WENDY_V1
	const WENDY_V2

	trainerclass SAILOR ; 28
	const EUGENE
	const HUEY1
	const TERRELL
	const KENT
	const ERNEST
	const JEFF
	const GARRETT
	const KENNETH
	const STANLY
	const HARRY
	const HUEY2
	const HUEY3
	const HUEY4
	const EUGENE_V1
	const EUGENE_V2
	const HUEY1_V1
	const HUEY1_V2
	const TERRELL_V1
	const TERRELL_V2
	const KENT_V1
	const KENT_V2
	const ERNEST_V1
	const ERNEST_V2
	const HARRY_V1
	const HARRY_V2

	trainerclass SUPER_NERD ; 29
	const STAN
	const ERIC
	const GREGG ; unused
	const JAY ; unused
	const DAVE ; unused
	const SAM
	const TOM
	const PAT
	const SHAWN
	const TERU
	const RUSS ; unused
	const NORTON ; unused
	const HUGH
	const MARKUS
	const ERIC_V1
	const ERIC_V2
	const TERU_V1
	const TERU_V2
	const MARKUS_V1
	const MARKUS_V2
	const HUGH_V1
	const HUGH_V2

	trainerclass RIVAL2 ; 2a
	; encounter 6 (Mt. Moon) - 8 variants
	const RIVAL2_1_CHIKORITA
	const RIVAL2_1_TOTODILE
	const RIVAL2_1_CYNDAQUIL
	const RIVAL2_1_AIPOM
	const RIVAL2_1_SUDOWOODO
	const RIVAL2_1_SMEARGLE
	const RIVAL2_1_SWINUB
	const RIVAL2_1_MAREEP
	; encounter 7 (Indigo Plateau) - 8 variants
	const RIVAL2_2_CHIKORITA
	const RIVAL2_2_TOTODILE
	const RIVAL2_2_CYNDAQUIL
	const RIVAL2_2_AIPOM
	const RIVAL2_2_SUDOWOODO
	const RIVAL2_2_SMEARGLE
	const RIVAL2_2_SWINUB
	const RIVAL2_2_MAREEP

	trainerclass GUITARIST ; 2b
	const CLYDE
	const VINCENT

	trainerclass HIKER ; 2c
	const ANTHONY1
	const RUSSELL
	const PHILLIP
	const LEONARD
	const ANTHONY2
	const BENJAMIN
	const ERIK
	const MICHAEL
	const PARRY1
	const TIMOTHY
	const BAILEY
	const ANTHONY3
	const TIM
	const NOLAND
	const SIDNEY
	const KENNY
	const JIM
	const DANIEL
	const PARRY2
	const PARRY3
	const ANTHONY4
	const ANTHONY5
	const RUSSELL_V1
	const RUSSELL_V2
	const DANIEL_V1
	const DANIEL_V2
	const ANTHONY1_V1
	const ANTHONY1_V2
	const PHILLIP_V1
	const PHILLIP_V2
	const LEONARD_V1
	const LEONARD_V2
	const BENJAMIN_V1
	const BENJAMIN_V2
	const ERIK_V1
	const ERIK_V2
	const MICHAEL_V1
	const MICHAEL_V2
	const TIMOTHY_V1
	const TIMOTHY_V2

	trainerclass BIKER ; 2d
	const BIKER_BENNY ; unused
	const KAZU ; unused
	const DWAYNE
	const HARRIS
	const ZEKE
	const CHARLES
	const RILEY
	const JOEL
	const GLENN

	trainerclass BLAINE ; 2e
	const BLAINE1

	trainerclass BURGLAR ; 2f
	const DUNCAN
	const EDDIE
	const COREY
	const DUNCAN_V1
	const DUNCAN_V2
	const EDDIE_V1
	const EDDIE_V2

	trainerclass FIREBREATHER ; 30
	const OTIS
	const DICK ; unused
	const NED ; unused
	const BURT
	const BILL
	const WALT
	const RAY
	const LYLE
	const BILL_V1
	const BILL_V2
	const WALT_V1
	const WALT_V2
	const RAY_V1
	const RAY_V2

	trainerclass JUGGLER ; 31
	const IRWIN1
	const FRITZ
	const HORTON
	const IRWIN2 ; unused
	const IRWIN3 ; unused
	const IRWIN4 ; unused
	const IRWIN1_V1
	const IRWIN1_V2

	trainerclass BLACKBELT_T ; 32
	const KENJI1 ; unused
	const YOSHI
	const KENJI2 ; unused
	const LAO
	const NOB
	const KIYO
	const LUNG
	const KENJI3
	const WAI
	const YOSHI_V1
	const YOSHI_V2
	const LAO_V1
	const LAO_V2
	const NOB_V1
	const NOB_V2
	const LUNG_V1
	const LUNG_V2
	const KENJI3_V1
	const KENJI3_V2

	trainerclass EXECUTIVEM ; 33
	const EXECUTIVEM_1
	const EXECUTIVEM_2
	const EXECUTIVEM_3
	const EXECUTIVEM_4

	trainerclass PSYCHIC_T ; 34
	const NATHAN
	const FRANKLIN
	const HERMAN
	const FIDEL
	const GREG
	const NORMAN
	const MARK
	const PHIL
	const RICHARD
	const GILBERT
	const JARED
	const RODNEY
	const GREG_V1
	const GREG_V2
	const NORMAN_V1
	const NORMAN_V2
	const MARK_V1
	const MARK_V2
	const PHIL_V1
	const PHIL_V2

	trainerclass PICNICKER ; 35
	const LIZ1
	const GINA1
	const BROOKE
	const KIM
	const CINDY
	const HOPE
	const SHARON
	const DEBRA
	const GINA2
	const ERIN1
	const LIZ2
	const LIZ3
	const HEIDI
	const EDNA
	const GINA3
	const TIFFANY1
	const TIFFANY2
	const ERIN2
	const TANYA
	const TIFFANY3
	const ERIN3
	const LIZ4
	const LIZ5
	const GINA4
	const GINA5
	const TIFFANY4
	const LIZ1_V1
	const LIZ1_V2
	const GINA1_V1
	const GINA1_V2
	const BROOKE_V1
	const BROOKE_V2
	const KIM_V1
	const KIM_V2
	const TIFFANY1_V1
	const TIFFANY1_V2
	const ERIN1_V1
	const ERIN1_V2

	trainerclass CAMPER ; 36
	const ROLAND
	const TODD1
	const IVAN
	const ELLIOT
	const BARRY
	const LLOYD
	const DEAN
	const SID
	const HARVEY ; unused
	const DALE ; unused
	const TED
	const TODD2
	const TODD3
	const THOMAS ; unused
	const LEROY ; unused
	const DAVID ; unused
	const JOHN ; unused
	const JERRY
	const SPENCER
	const TODD4
	const TODD5
	const QUENTIN
	const ROLAND_V1
	const ROLAND_V2
	const TODD1_V1
	const TODD1_V2
	const IVAN_V1
	const IVAN_V2
	const ELLIOT_V1
	const ELLIOT_V2
	const SPENCER_V1
	const SPENCER_V2
	const TED_V1
	const TED_V2
	const QUENTIN_V1
	const QUENTIN_V2

	trainerclass EXECUTIVEF ; 37
	const EXECUTIVEF_1
	const EXECUTIVEF_2

	trainerclass SAGE ; 38
	const CHOW
	const NICO
	const JIN
	const TROY
	const JEFFREY
	const PING
	const EDMOND
	const NEAL
	const LI
	const GAKU
	const MASA
	const KOJI
	const CHOW_V1
	const CHOW_V2
	const NICO_V1
	const NICO_V2
	const EDMOND_V1
	const EDMOND_V2
	const JIN_V1
	const JIN_V2
	const TROY_V1
	const TROY_V2
	const NEAL_V1
	const NEAL_V2
	const LI_V1
	const LI_V2
	const JEFFREY_V1
	const JEFFREY_V2
	const PING_V1
	const PING_V2

	trainerclass MEDIUM ; 39
	const MARTHA
	const GRACE
	const BETHANY ; unused
	const MARGRET ; unused
	const ETHEL ; unused
	const REBECCA
	const DORIS
	const MARTHA_V1
	const MARTHA_V2
	const GRACE_V1
	const GRACE_V2

	trainerclass BOARDER ; 3a
	const RONALD
	const BRAD
	const DOUGLAS
	const RONALD_V1
	const RONALD_V2
	const BRAD_V1
	const BRAD_V2
	const DOUGLAS_V1
	const DOUGLAS_V2

	trainerclass POKEFANM ; 3b
	const WILLIAM
	const DEREK1
	const ROBERT
	const JOSHUA
	const CARTER
	const TREVOR
	const BRANDON
	const JEREMY
	const COLIN
	const DEREK2 ; unused
	const DEREK3 ; unused
	const ALEX
	const REX
	const ALLAN
	const WILLIAM_V1
	const WILLIAM_V2
	const DEREK1_V1
	const DEREK1_V2
	const BRANDON_V1
	const BRANDON_V2

	trainerclass KIMONO_GIRL ; 3c
	const NAOKO_UNUSED ; unused
	const NAOKO
	const SAYO
	const ZUKI
	const KUNI
	const MIKI

	trainerclass TWINS ; 3d
	const AMYANDMAY1
	const ANNANDANNE1
	const ANNANDANNE2
	const AMYANDMAY2
	const JOANDZOE1
	const JOANDZOE2
	const MEGANDPEG1
	const MEGANDPEG2
	const LEAANDPIA1
	const LEAANDPIA2 ; unused
	const AMYANDMAY1_V1
	const AMYANDMAY1_V2
	const ANNANDANNE1_V1
	const ANNANDANNE1_V2

	trainerclass POKEFANF ; 3e
	const BEVERLY1
	const RUTH
	const BEVERLY2 ; unused
	const BEVERLY3 ; unused
	const GEORGIA
	const JAIME
	const BEVERLY1_V1
	const BEVERLY1_V2
	const RUTH_V1
	const RUTH_V2

	trainerclass RED ; 3f
	const RED1

	trainerclass BLUE ; 40
	const BLUE1

	trainerclass OFFICER ; 41
	const KEITH
	const DIRK

	trainerclass GRUNTF ; 42
	const GRUNTF_1
	const GRUNTF_2
	const GRUNTF_3
	const GRUNTF_4
	const GRUNTF_5

	trainerclass MYSTICALMAN ; 43
	const EUSINE
	
	trainerclass BOSS
	const GIOVANNI

	trainerclass ROCKET_LEADER
	const ARCHER

	trainerclass PKMNTRAINERF
	const WEEBRA

NUM_TRAINER_CLASSES EQU __trainer_class__ - 1
