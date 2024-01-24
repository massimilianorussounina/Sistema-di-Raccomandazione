include("./Normal_URM.jl")
include("./latent_factor.jl")
using LinearAlgebra
using Random
using Statistics
using BenchmarkTools
p= nothing
q = nothing
s= nothing

function calculate_mae(R::Matrix{Float64}, P::Matrix{Float64}, Q::Matrix{Float64})
    num_users, num_items = size(R)
    mae = 0.0
    count = 0
    
    for i in 1:num_users
        for j in 1:num_items
            if R[i, j] != 0
                prediction = dot(P[i, :], Q[j, :])
                mae += abs(R[i, j] - prediction)
                count += 1
            end
        end
    end
    
    if count > 0
        mae /= count
    else
        mae = Inf  # Evita la divisione per zero se non ci sono valutazioni
    end
    
    return mae
end

function k_fold_cross_validation_mae(data, k,num_factor,alpha, lambda, step)
    n_users, n_items = size(data)
    indices = [(i, j) for i in 1:n_users for j in 1:n_items]
    Random.shuffle!(indices)
    
    fold_size = Int(ceil(length(indices) / k))
    mae_values = zeros(k)
    
    for i in 1:k
        test_indices = indices[((i - 1) * fold_size + 1):(min(i * fold_size, lastindex(indices)))]
        train_indices = setdiff(indices, test_indices)
        
        train_data = zeros(n_users, n_items)
        test_data = zeros(n_users, n_items)
        
        # Dividi i dati in addestramento e test
        for (user, item) in train_indices
            train_data[user, item] = data[user, item]
        end
        
        for (user, item) in test_indices
            test_data[user, item] = data[user, item]
        end
        
        # Addestra il modello sui dati djuliai addestramento
        p, q = matrix_factorization_with_regularization(train_data, num_factor, alpha, lambda,step)

        # Calcola l'errore MAE tra le previsioni e i dati di test
        mae_values[i] = calculate_mae(test_data,p,q)
    end
    
    return mae_values
end


function hyperparameter_search()
    best_params = Dict{String, Any}()
    best_mae = Inf
    file = open(joinpath(@__DIR__, "Risultati.txt"), "w")
    
    # Definisci una griglia di iperparametri da testare
    num_factors_grid = [2, 5,10,20]
    alpha_grid = [0.001, 0.005]
    lambda_grid = [0.0001, 0.001, 0.01, 0.1, 1.0]
      
    for num_factors in num_factors_grid
        for alpha in alpha_grid
            for lambda in lambda_grid
                # Addestra il modello con gli iperparametri correnti
              
                mae_values = k_fold_cross_validation_mae(URM, 5,num_factors, alpha, lambda, 100)
                mae=mean(mae_values)
                
                println("MAE per ciascun fold: ", mae_values)
                println("Media MAE: ", mae)
                # Scrivo i risultati su un file 
                write(file, "\n Iperparametri "*string(num_factors)*"\t"*string(alpha)*"\t"*string(lambda))
                write(file, "\n MAE per ciascun fold: "*string(mae_values))
                write(file, "\n Media MAE: "*string(mae))

                # Aggiorna i migliori iperparametri se si ottiene un MAE migliore
                if mae < best_mae
                    best_mae = mae
                    best_params["num_factors"] = num_factors
                    best_params["alpha"] = alpha
                    best_params["lambda"] = lambda
                end
            end
        end
    end
    close(file)
    return best_params, best_mae
end


best_params, best_mae = hyperparameter_search()

println("Migliori iperparametri:")
println("Numero di fattori latenti: ", best_params["num_factors"])
println("Tasso di apprendimento: ", best_params["alpha"])
println("Fattore di regolarizzazione: ", best_params["lambda"])
println("Miglior MAE sulla convalida: ", best_mae)



@btime k_fold_cross_validation_mae(URM, 5,best_params["num_factors"], best_params["alpha"], best_params["lambda"], 100)
