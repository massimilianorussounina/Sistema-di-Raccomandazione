using Random
using LinearAlgebra


function matrix_factorization_with_regularization(R::Matrix{Float64}, K::Int64, alpha::Float64, lambda::Float64, epochs::Int64)
    num_users, num_items = size(R)
    prec_rmse = Inf;

    
    # Inizializzazione casuale delle matrici latenti P e Q
    P = randn(num_users, K)
    Q = randn(num_items, K)
    best_P= randn(num_users, K)
    best_Q= randn(num_items, K)
    
    for epoch in 1:epochs
        for i in 1:num_users
            for j in 1:num_items
                if R[i, j] != 0
                    # Calcola l'errore tra la valutazione reale e la previsione
                    eij = R[i, j] - dot(P[i, :], Q[j, :])
                    
                    # Aggiorna le matrici latenti P e Q con regolarizzazione
                    for k in 1:K
                        P[i, k] += alpha * (2 * eij * Q[j, k] - lambda * P[i, k])
                        Q[j, k] += alpha * (2 * eij * P[i, k] - lambda * Q[j, k])
                    end
                end
            end
        end
        
        # Calcola l'errore 
        rmse=calculate_Frobenious_with_regularization(R,P,Q,lambda)
        if (rmse < 0.1)
            break
        end
        if isnan(rmse)
            break
        end
        if (prec_rmse> rmse)
            best_P=copy(P)
            best_Q=copy(Q)
            prec_rmse=rmse
        end
        #println("Epoch $epoch, RMSE: $rmse")
    end
    
    return best_P, best_Q
end


function calculate_Frobenious_with_regularization(R::Matrix{Float64}, P::Matrix{Float64}, Q::Matrix{Float64}, lambda::Float64)
    num_users, num_items = size(R)
    rmse = 0.0
    count = 0
    
    for i in 1:num_users
        for j in 1:num_items
            if R[i, j] != 0
                rmse += (R[i, j] - dot(P[i, :], Q[j, :]))^2
                count += 1
            end
        end
    end
    rmse=0.5*rmse

    for i in 1:num_users
        for j in 1:num_items
            if R[i, j] != 0
                # Aggiungi il termine di regolarizzazione L2
                for k in 1:size(P, 2)
                    rmse += 0.5 * lambda * (P[i, k]^2 + Q[j, k]^2)
                end
            end
        end
    end
    
    rmse = sqrt(rmse / count)
    return rmse
end





