#= Descrizione
	> data.jl: Questo script contiene tutte le funzioni necessarie per il caricamento dei dati dai file CSV.
	> Normal_URM.jl: Questo modulo si occupa della creazione della User-Item Rating Matrix (URM) e include anche una funzione per 	  	  normalizzare i dati.
	> latent_factor.jl: Questo script contiene l'algoritmo per il calcolo dei fattori latenti.
	> Test.jl: Questo script è utilizzato per eseguire test con la cross-validation e implementare il calcolo del Mean Absolute Error 	  (MAE).
	> Util.jl: Questo modulo contiene una funzione dedicata alla creazione di una barra di caricamento.
=#

Aprire il REPL di julia e inserire questo comando

include("*Path*/ProgettoItelligentweb/Test.jl")