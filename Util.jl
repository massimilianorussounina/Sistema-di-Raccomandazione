function barra_di_caricamento(caricamento)
    larghezza = 50  # Larghezza totale della barra di caricamento
    percentuale = min(max(caricamento, 0.0), 1.0)  # Assicura che la percentuale sia compresa tra 0 e 1
    completamento = round(Int, percentuale * larghezza)  # Calcola la quantità di completamento

    # Costruisci la barra di caricamento
    barra = "[" * repeat("=" , completamento) * repeat(" ", larghezza - completamento) * "]"

    # Visualizza la barra di caricamento
    print("\r$barra $(round(percentuale * 100, digits=2))% ")
    flush(stdout)
end