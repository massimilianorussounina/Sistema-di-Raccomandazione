using CSV
using ZipFile
using DataFrames
FILENAME = "ml-latest-small.zip"
FILENAME = joinpath(@__DIR__, FILENAME)
NAMEFOLDER = "ml-latest-small/"

USERS = nothing
MOVIES = nothing
RATINGS = nothing

function download_file()
    global FILENAME
    if !isfile(FILENAME)
        download("http://files.grouplens.org/datasets/movielens/ml-1m.zip", FILENAME)
        @info "Downloaded data to [$(FILENAME)]"
    end
end

function load_ratings()
    global FILENAME, USERS, MOVIES, RATINGS
    if RATINGS === nothing
        ratingReader = ZipFile.Reader(FILENAME)
        rating_file = filter(x -> x.name == NAMEFOLDER*"ratings.csv", ratingReader.files)[1]
        RATINGS = CSV.File(rating_file, delim=",", header=[:uid, :mid, :rating, :timestamp]) |> DataFrame
        RATINGS = sort(RATINGS, [:uid, :timestamp])
        close(ratingReader)
    end
    return RATINGS
end

function load_users()
    global FILENAME, USERS, MOVIES, RATINGS
    if USERS === nothing
        userReader = ZipFile.Reader(FILENAME)
        println(userReader.files)
        user_file = filter(x -> x.name == "ml-latest/users.csv", userReader.files)[1]
        USERS = CSV.File(user_file, delim="::", header=[:uid, :gender, :age, :occupation, :other]) |> DataFrame
        close(userReader)
    end
    return USERS
end

function load_movies()
    global FILENAME, USERS, MOVIES, RATINGS
    if MOVIES === nothing
        movieReader = ZipFile.Reader(FILENAME)
        movie_file = filter(x -> x.name == NAMEFOLDER*"movies.csv", movieReader.files)[0]
        MOVIES = CSV.File(movie_file, delim=",", header=[:mid, :title, :genres]) |> DataFrame
        close(movieReader)
    end
    return MOVIES
end

if abspath(PROGRAM_FILE) == @__FILE__

    # stampa le prime 5 righe di users DataFrame
    load_users()
    @show first(USERS, 5)

    # stampa le prime 5 righe di movie DataFrame
    load_movies()
    @show first(MOVIES, 5)

    # stampa le prime 5 righe di ratings DataFrame
    load_ratings()
    @show first(RATINGS, 5)

end
