using StatsBase
include("./data.jl")
include("./Util.jl")

# Caricaemnto Rating da csv
load_ratings()


# Creazione URM 

# Trasformare la matrice di stringhe di RATINGS in una matrice di Float

#Dichiarazione dei vettori di supporto
Index_user=Array{Int}(undef, 0)
Index_movie=Array{Int}(undef, 0)
set_Index_movie=Array{Int}(undef, 0)
value_rating=Array{Float32}(undef, 0)

# creazione del vettore di indici degli utenti
array_string=filter(x -> x != "userId", RATINGS[:,1])
Index_user=[parse(Int64, x) for x in array_string]
num_user = maximum(Index_user)
# creazione del vettore degli  indici dei movie
array_string=filter(x -> x != "movieId", RATINGS[:,2]);
Index_movie=[parse(Int64, x) for x in array_string]

# set_Index_movie mappa gli indici dei movies in un intervallo da 1 a 9724 poiché gli Movieid non ha indici consecutivi
set_Index_movie=unique(Index_movie)
num_movie =  length(set_Index_movie)

# conversione valori rating da String -> Float
array_string=filter(x -> x != "rating", RATINGS[:,3]);
value_rating=[parse(Float32, x) for x in array_string]

# Inizzializzazione Matrice URM
URM = zeros(num_user, num_movie)


println("\n\t\t Creazione URM: ")
modulo=floor(length(value_rating)/100)
for i in 1: length(value_rating)
    if (i % modulo==0 && i!=0)
        barra_di_caricamento(i/length(value_rating))
    end
    URM[Index_user[i], findfirst(x -> x == Index_movie[i], set_Index_movie)]= value_rating[i]
end
print("\n")


function normalize_URM(URM::Matrix,num_row::Int64,num_column::Int64,shrink_term::Float64)
    
    # Calcolo della normalizzazione della URM


    # Step 1 calcolo del valore medio globale della URM

    global_average = mean(filter(x -> x != 0, URM))

    # Step 2 sottraggo la media globale alla URM

    URM_Normalization = copy(URM)
    URM_Normalization = URM_Normalization .- global_average

    # Step 3 calcolo bias item

    item_bias = zeros(Float64, 1 , num_column)

    for j in 1:num_column

        item_URM = URM_Normalization[:,j]
        somma_item = sum(item_URM)
        count_rating= count(!iszero,item_URM)

        item_bias[1,j]= somma_item / (count_rating + shrink_term)

    end

    # Step 4 ricalco URM sotraendo i bias

    for j in 1:num_column
        URM_Normalization[:,j]= URM_Normalization[:,j] .- item_bias[j]
    end 

    # Step 5 calcolo bias utente
    somma_item=0;
    user_bias = zeros(Float64, 1 , num_row)

    for i in 1:num_row

        item_URM = URM_Normalization[i,:]
        somma_item = sum(item_URM)
        count_rating= count(!iszero,item_URM)

        user_bias[1,i]= somma_item / (count_rating + shrink_term)

    end

    # Step 6 calcolo matrice normalizzata 

    URM_Normalization = zeros(num_row, num_column)

    for i in 1: num_row
        for j in 1: num_column
            URM_Normalization[i,j] = global_average + item_bias[j] + user_bias[i]
        end
    end
        return URM_Normalization
end

# URM_Normalization=normalize_URM(URM, num_user, num_movie, 0.5)