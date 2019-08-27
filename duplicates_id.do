* first change
/*-------------------------------------------------------*/
	/*		 [>  Cleaning Survey CTO and reports - dataset  <]

	Author: @samuelarispe
	Survey form version: MC_2018_verificacion_encuestadores_newversion_v1.dta
	*/
	/*----------------------------------------------------*/


	* Setting

	dis "`c(hostname)'"

	local machine "`c(hostname)'" // anyone who is working could add his/her
		// hostname 

	* In one of the next rows you can add your directory

		// note tha here every space is a ";" I dont like very big
		// sentence in a row. It looks terrible :)

	* Note in who you need to put your initials (e.g: Paulo Matos - PM)


	#d ; 

		if "`machine'" == "Paulos-MacBook-Pro.local" {;
			local db "/Users/paulomatos/Dropbox";
			local who "PM";
		};

		if "`machine'" == "Medina-PC" {;
			local db "C:/Users/Medina/Dropbox";
			local who "DM";
		};

		if "`machine'" == "LP100852" { ;
			local db "/Users/p.villaparo/Dropbox";
			local who "PV";
		};

		if "`machine'" == "Samuel-PC" { ;
			local db "C:/Users/Samuel/Dropbox";
			local who "SA";
		};

		if "`machine'" == "PC0661ZE" { ;
			local db "C:/Users/sarispe/Dropbox";
			local who "SA";
		};

		if "`machine'" == "IPA-V7NJIT0BIMH" {;
			local db "C:/Users/PMatos/Dropbox";
			local who "PM-Win";
		};


	#d cr

	* Working directory

	set more off

	local mc "Proyecto Matching Contribution 2017-2018"
	local bl "`db'/`mc'/07_Questionnaires&Data/Baseline_Quant"
	local monitor "interim/outputs/enumerators"


	cd "`bl'" // Set working directory the BaseLine


	* Other datasets

	local randomization "`db'/`mc'/04_ResearchDesign/03 Randomization"
	local randomization "`randomization'/PROYECTO/data"
	*local randomization ///
	*	"`randomization'/matching_randomized_11196_1208_recoding.dta"
	local randomization ///
		"`randomization'/matching_randomized_12588_13893_11196_1208.dta"
	local rand_geo "`db'/`mc'/04_ResearchDesign/03 Randomization"
	local rand_geo "`rand_geo'/PROYECTO/data/Samuel"

	local pilot_data "archive/baseline_matching.dta"
	local project_data "interim/matching_contributions_v1_clean.dta"
	 
		//data help of Samuel Arispe 
	local enumerator "raw/enumerators/Flujo"
	local listados "raw/enumerators/Listados"

		//data help of Dessire Medina
	local backch ///
	"Copy of formulario verificación de audios y llamadas (encuestadores).dta"
	local verificadora "raw/SCTO/DM/`backch'" 
	local semana 24 // aumentar cada semana o de acuerdo a lo que se quiera

	*primero actualizamos la data del flujo de encuestadores
	import excel using ///
		"`enumerator'/190305--flujo de encuestadores.xlsx", ///
		firstrow  clear

	destring dni_encuestador , replace

	tostring Nro_de_cuenta Ruc , replace format("%15.0f")

	keep apellidopaterno - Ruc 

	gen DNI = string(dni_encuestador,"%08.0f")

	drop if username == ""

	foreach name of var apellidopaterno apellidomaterno ///
		primernombre Banco {

		replace `name' = upper(`name')
	}

	save "`enumerator'/190305--flujo de encuestadores.dta", ///
		replace


	use "`project_data'", clear

	keep if estado!=9 & georeferencelatitude!=.

	gen latitud=int(georeferencelatitude*100)
	gen longitud=int(georeferencelongitude*100)

	sort starttime	
	bys id username : gen n=_n

	sort starttime
	bys id username : gen N=_N

	bys id username: gen last_visit=(n==_N) if n>1

	bys id: gen dup=_N
	bys id: gen last_visit_1=1 if (username[_N]!=username[_N-1]) & dup==2

	keep if last_visit==1 | last_visit_1==1
	bys id: gen dup_1=_N
	keep if dup_1>1

	bys id: gen error_id=((latitud[_N]>latitud[_N-1]) & ///
	(longitud[_N]>longitud[_N-1])) if dup_1==2

	bys id: replace error_id=((latitud[_N]>latitud[_N-1]) ///
	& (longitud[_N]>longitud[_N-1])) if error_id!=1 & ///
	dup_1==3 & id[_N]==id[_N-1]

	bys id: replace error_id=((latitud[_N]>latitud[_N-1]) ///
	& (longitud[_N]>longitud[_N-1])) if error_id!=1 & ///
	dup_1==3 & id[_N]==id[_N-2]

	bys id: replace error_id=((latitud[_N]<latitud[_N-1]) ///
	& (longitud[_N]<longitud[_N-1])) if error_id!=1 & dup_1==2 

	bys id: replace error_id=((latitud[_N]<latitud[_N-1]) ///
	& (longitud[_N]<longitud[_N-1])) if error_id!=1 & ///
	dup_1==3 & id[_N]==id[_N-1]

	bys id: replace error_id=((latitud[_N]<latitud[_N-1]) ///
	& (longitud[_N]<longitud[_N-1])) if error_id!=1 & ///
	dup_1==3 & id[_N]==id[_N-2]

	replace consent=0 if consent==.

	bys id: egen empresa_aceptada=total(consent)
